"""Module defining a parser for MediaWiki code."""

import json

from html.parser import HTMLParser
from mfnf.transformations import NodeTransformation, ChainedAction, Action, \
    NodeTypeTransformation, DeleteTransformation, check
from mfnf.utils import lookup, remove_prefix, add_dict

TEMPLATE_SPEC = {
    "Definition": lambda x: x in ["definition"],
    "Warnung": lambda x: x in ["1"],
    "Aufgabe": lambda x: x in ["aufgabe", "lösung", "beweis"]
}

class HTML2JSONParser(HTMLParser):
    """Parser for converting HTML to JSON."""

    def __init__(self):
        super(HTML2JSONParser, self).__init__()

        self._node_stack = []
        self.content = []

    def _append(self, node):
        if self._node_stack:
            self._node_stack[-1]["children"].append(node)
        else:
            self.content.append(node)

    def handle_starttag(self, tag, attrs):
        node = {"type": "element", "name": tag,
                "attrs": add_dict(dict(attrs), {"type": "attrs"}),
                "children": []}

        self._append(node)
        self._node_stack.append(node)

    def handle_endtag(self, tag):
        assert self._node_stack
        assert self._node_stack[-1]["name"] == tag

        self._node_stack.pop()

    def handle_data(self, data):
        data = data.strip()

        if data:
            self._append({"type": "text", "data": data})

    def error(self, message):
        raise AssertionError(message)

class MediaWikiCodeParser(ChainedAction):
    """Parses MediaWikiCode and restore template definitions."""

    class MediaWikiCode2HTML(Action):
        """Converts MediaWiki code to HTML"""

        def __call__(self, text):
            return self.api.convert_text_to_html(self.title, text)

    class MediaWikiCodeHTML2JSON(Action):
        """Converts HTML of a MediaWiki document to JSON."""

        def __call__(self, text):
            parser = HTML2JSONParser()

            parser.feed(text)

            return parser.content

    class TemplateDeinclusion(NodeTransformation):
        """Replaces included MediaWiki templates with template
        specification."""

        def parse_parameter_value(self, name, param_key, param_value):
            """Parses `param_value` in case `param_key` is a content
            parameter."""
            if name in TEMPLATE_SPEC and TEMPLATE_SPEC[name](param_key):
                parser = MediaWikiCodeParser(api=self.api, title=self.title)

                return parser(param_value)
            else:
                return param_value

        def transform_dict(self, obj):
            check(obj, "type") == "element"
            check(obj, "attrs", "typeof") == "mw:Transclusion"

            template = json.loads(obj["attrs"]["data-mw"])
            template = template["parts"][0]["template"]

            name = template["target"]["wt"].strip()
            name = remove_prefix(name, ":Mathe für Nicht-Freaks: Vorlage:")

            params = template["params"]
            params = {k: v["wt"] for k, v in params.items()}
            params = {key: self.parse_parameter_value(name, key, value) \
                        for key, value in params.items()}

            return {"type": "template", "name": name, "params": params}

class ArticleContentParser(ChainedAction):
    class MediaWikiCode2HTML(Action):
        def __call__(self, text):
            return MediaWikiCodeParser(api=self.api, title=self.title)(text)

    class HandleLists(NodeTransformation):
        def transform_dict(self, obj):
            check(obj, "type") == "element"
            check(obj, "name").of("ul", "ol")

            children = [self(li["children"]) for li in obj["children"]]

            return {"type": "list",
                    "ordered": obj["name"] == "ol",
                    "children": children}

    class HandleFigures(NodeTransformation):
        def transform_dict(self, obj):
            check(obj, "type") == "element"
            check(obj, "name") == "figure"
            check(obj, "attrs", "typeof").of("mw:Image", "mw:Image/Thumb")

            caption = [child
                       for child in obj["children"]
                       if child["name"] == "figcaption"]
            try:
                caption = caption[0]["children"]
            except IndexError:
                caption = []

            img = obj["children"][0]["children"][0]["attrs"]

            return {"type": "image", "caption": self(caption),
                    "name": img["resource"], "url": img["src"],
                    "thumbnail": obj["attrs"]["typeof"] == "mw:Image/Thumb"}

    class HandleTable(NodeTransformation):
        def transform_dict(self, obj):
            check(obj, "type") == "element"
            check(obj, "name") == "table"

            content = obj["children"]

            if lookup(content, 0, "name") == "tbody":
                content = content[0]["children"]

            return {"type": "table", "children": self(content)}

    class ConvertInlineMath(NodeTransformation):
        def transform_dict(self, obj):
            check(obj, "attrs", "typeof") == "mw:Extension/math"

            formula = json.loads(obj["attrs"]["data-mw"])["body"]["extsrc"]

            return {"type": "inlinemath", "formula": formula}

    class CleanupTemplateInclusion(DeleteTransformation):
        """The restoring of template definitions only replaces the top level
        HTML element. This step deletes the other ones."""

        #def shall_delete_dict(self, obj):
        #    return lookup(obj, "type") == "element" \
        #            and lookup(obj, "attrs", "about") != None

    class DeleteHeaderAndFooter(DeleteTransformation):

        def shall_delete_dict(self, obj):
            return lookup(obj, "type") == "template" \
                    and obj["name"].startswith("#invoke:")

    class FixNodeTypes(NodeTypeTransformation):

        def transform_element(self, obj):
            if obj["name"] == "p":
                return {"type": "paragraph", "children": self(obj["children"])}
            elif obj["name"] == "dfn":
                return {"type": "i", "children": self(obj["children"])}
            elif obj["name"] in ("i", "b", "th", "tr", "td"):
                return {"type": obj["name"], "children": self(obj["children"])}
            elif obj["name"] in ("h1", "h2", "h3"):
                return {"type": "header",
                        # Header begin with h2 in our project -> subtract 1
                        "depth": int(obj["name"][-1])-1,
                        "children": self(obj["children"])}
            elif obj["name"] in ("h4", "h5", "h6"):
                message = "Heading of depth {} is not allowed"

                return {"type": "error",
                        "message": message.format(int(obj["name"][-1]))}
            else:
                return {"type": "notimplemnted",
                        "target": obj}

class ArticleParser(ChainedAction):
    class LoadArticleContent(NodeTypeTransformation):
        """Loads the content of an article."""

        def transform_article(self, article):
            parser = ArticleContentParser(api=self.api, title=article["title"])

            content = parser(self.api.get_content(article["title"]))

            return add_dict(article, {"content": content})
