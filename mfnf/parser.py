"""Module defining a parser for MediaWiki code."""

import json
import re
import logging

from collections import defaultdict
from itertools import chain, count
from html.parser import HTMLParser
from mfnf.transformations import NodeTransformation, ChainedAction, Action, \
     NodeTypeTransformation, check, NotInterested, Transformation, SectionTracking
from mfnf.utils import lookup, remove_prefix, remove_suffix, merge, log_parser_error

report_logger = logging.getLogger("report_logger")

TEMPLATE_SPEC = {
    "definition": lambda x: x in ["definition"],
    "beispiel": lambda x: x in ["beispiel"],
    "beweis": lambda x: x in ["beweis"],
    "alternativer beweis": lambda x: x in ["beweis"],
    "beweiszusammenfassung": lambda x: x in ["zusammenfassung"],
    "lösungsweg": lambda x: x in ["lösungsweg"],
    "lösung": lambda x: x in ["lösung"],
    "beweisschritt": lambda x: x in ["beweisschritt"],
    "warnung": lambda x: x in ["1"],
    "hinweis": lambda x: x in ["1"],
    "hauptartikel": lambda x: x in ["1"],
    "frage": lambda x: x in ["frage", "antwort"],
    "aufgabe": lambda x: x in ["aufgabe", "erklärung", "beispiel",
                               "zusammenfassung", "lösung", "lösungsweg",
                               "beweis", "beweis2"],
    "satz": lambda x: x in ["satz", "erklärung", "beispiel",
                            "zusammenfassung", "lösung", "lösungsweg",
                            "beweis", "beweis2"],
    "liste": lambda x: x.startswith("item") or x in ["liste"],
    # important paragraph
    "-": lambda x: x in ["1"],
    "fallunterscheidung": lambda x: x.startswith("beweis"),
    "vollständige induktion": lambda x: x in ["aussageform", "induktionsanfang",
                                              "induktionsvoraussetzung", "induktionsbehauptung",
                                              "beweis_induktionsschritt", "erfuellungsmenge"],
}

TEMPLATE_INLINE_SPEC = {
    "beweisschritt": lambda x: x in ["ziel"],
    "fallunterscheidung": lambda x: x.startswith("fall"),
    "formel": lambda x: x in ["1"],
    "definition": lambda x: x in ["titel"],
    "beispiel": lambda x: x in ["titel"],
    "lösungsweg": lambda x: x in ["titel"],
    "lösung": lambda x: x in ["titel"],
    "beweiszusammenfassung": lambda x: x in ["titel"],
    "alternativer beweis": lambda x: x in ["titel"],
    "beweis": lambda x: x in ["titel"],
    "satz": lambda x: x in ["titel"],
    "aufgabe": lambda x: x in ["titel"],
    "fg": lambda x: x in ["2"]
}

TEMPLATE_LIST_PARAMS = {
    "liste": ["item"],
    "fallunterscheidung": ["fall", "beweis"]
}

BOXSPEC = [
    ("definition", "definition",
     {"title": "titel", "definition": "definition"}),

    ("example", "beispiel", {"title": "titel", "example": "beispiel"}),

    ("solution", "lösung", {"title": "titel", "solution": "lösung"}),

    ("proofbycases", "fallunterscheidung",
     {"cases": "fall_list", "proofs": "beweis_list"}),

    ("solutionprocess", "lösungsweg",
     {"title": "titel", "solutionprocess": "lösungsweg"}),

    ("proofsummary", "beweiszusammenfassung",
     {"title": "titel", "proofsummary": "zusammenfassung"}),

    ("alternativeproof", "alternativer beweis",
     {"title": "titel", "alternativeproof": "beweis"}),

    ("proof", "beweis", {"title": "titel", "proof": "beweis"}),

    ("warning", "warnung", {"warning": "1"}),

    ("hint", "hinweis", {"hint": "1"}),

    ("coloredtext", "fg", {"color": "1", "content": "2"}),

    ("smiley", "smiley", {"name": "1"}),

    ("mainarticle", "hauptartikel", {"mainarticle": "1"}),

    ("question", "frage",
        {"question": "frage", "answer": "antwort", "questiontype": "typ"}),

    ("proofstep", "beweisschritt",
        {"name": "name", "target": "ziel", "proof": "beweisschritt"}),

    ("theorem", "satz",
     {"title": "titel", "theorem": "satz", "explanation": "erklärung",
      "example": "beispiel", "proofsummary": "zusammenfassung",
      "solution": "lösung", "solutionprocess": "lösungsweg",
      "proof": "beweis", "alternativeproof": "beweis2"}),

    ("exercise", "aufgabe",
     {"title": "titel", "exercise": "aufgabe", "explanation": "erklärung",
      "example": "beispiel", "proofsummary": "zusammenfassung",
      "solution": "lösung", "solutionprocess": "lösungsweg",
      "proof": "beweis", "alternativeproof": "beweis2"}),

    ("importantparagraph", "-", {"importantparagraph": "1"}),
    ("induction", "vollständige induktion", {"statement": "aussageform", "induction_start": "induktionsanfang",
                                             "induction_requirement": "induktionsvoraussetzung", "induction_goal": "induktionsbehauptung",
                                             "induction_step": "beweis_induktionsschritt", "baseset": "erfuellungsmenge"})
]

DEFAULT_VALUES = {
    "proofstep": {
        "name": "Beweisschritt"
    },
    "smiley": {
        "name": ":)"
    }
}

USERNAMES = {
    "Claudia4": "Claudia Renner",
    "Agnessa power": "Agnes Pauer",
    "Mattlocke2.0": "Matthias Greger"
}

def canonical_image_name(name):
    name = remove_prefix(name, "./")
    name = remove_prefix(name, "Datei:")
    name = remove_prefix(name, "File:")

    return "File:" + name

def parse_content(api, title, text):
    """Parse MediaWiki code `text`."""
    return MediaWikiCodeParser(api=api, title=title)(text)

def parse_inline(api, title, text):
    """Parse MediaWiki code `text` in inline mode."""
    content = MediaWikiCodeParser(api=api, title=title)(text)

    assert len(content) == 1, text
    assert content[0]["type"] == "element", "{} in {} yields {}".format(text, title, content)
    assert content[0]["name"] == "p", "{} in {} yields {}".format(text, title, content)

    return content[0]["children"]

def text_rstrip(content):
    """Applies `rstrip()` to parsed MediaWiki content."""
    try:
        return content[:-1] + [{"type": "text",
                                "data": content[-1]["data"].rstrip()}]
    except (IndexError, KeyError):
        return content

class HTML2JSONParser(HTMLParser):
    """Parser for converting HTML to JSON."""

    def __init__(self):
        super(HTML2JSONParser, self).__init__()

        self._node_stack = []
        self.content = []
        self._last_node = None
        self._is_first_node = True

    def _append(self, node):
        self._last_node = node

        if self._node_stack:
            self._node_stack[-1]["children"].append(node)
        else:
            self.content.append(node)

    def handle_starttag(self, tag, attrs):
        node = {"type": "element", "name": tag,
                "attrs": dict(attrs),
                "children": []}

        self._append(node)
        self._node_stack.append(node)
        self._is_first_node = True

    def handle_endtag(self, tag):
        assert self._last_node

        try:
            self._last_node["data"] = self._last_node["data"].rstrip()
        except KeyError:
            pass

        self._is_first_node = False

        assert self._node_stack
        assert self._node_stack[-1]["name"] == tag, \
            "end tag should be {}, but is {}. last nodes: {}" \
            .format(tag, self._node_stack[-1]["name"], self._node_stack)

        self._node_stack.pop()

    def handle_data(self, data):
        if re.search("\S", data):
            data = re.sub(r"(?<=\S\s)\s+$", "", data)
            data = re.sub(r"^\s+(?=\s\S)", "", data)
            data = re.sub(r"\s", " ", data)

            if self._is_first_node:
                data = data.lstrip()
                self._is_first_node = False

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

    class TemplateDeinclusion(NodeTypeTransformation):
        """Replaces included MediaWiki templates with template
        specification."""

        def __init__(self, **options):
            super().__init__(**options)

            self._template_ids = set()

        def parse_parameter_value(self, name, param_key, param_value):
            """Parses `param_value` in case `param_key` is a content
            parameter."""

            if not param_value:
                # Empty strings shall be interpreted as None
                return None
            elif name in TEMPLATE_SPEC and TEMPLATE_SPEC[name](param_key):
                return parse_content(self.api, self.title, param_value)
            elif name in TEMPLATE_INLINE_SPEC \
                    and TEMPLATE_INLINE_SPEC[name](param_key):
                return parse_inline(self.api, self.title, param_value)
            else:
                return param_value

        def transform_element(self, obj):
            if lookup(obj, "attrs", "about") in self._template_ids:
                return None

            check(obj, "attrs", "typeof").of(["mw:Transclusion",
                                              "mw:Transclusion mw:Video/Thumb",
                                              "mw:Transclusion mw:Image"])

            template = json.loads(obj["attrs"]["data-mw"])
            template = template["parts"][0]["template"]

            name = template["target"]["wt"].strip()

            # labeled section transclusion needs unchanged case.
            if not name.startswith("#lst:"):
                name = name.lower()

            if name != "(!":
                # Template includes a table afterwards
                self._template_ids.add(obj["attrs"]["about"])

            name = remove_prefix(name, ":mathe für nicht-freaks: vorlage:")

            params = template["params"]
            params = {k: v["wt"] for k, v in params.items()}
            params = {key: self.parse_parameter_value(name, key, value) \
                        for key, value in params.items()
                        if not params.get(key + "-noprint", False)}

            return {"type": "template", "name": name, "params": params}

    class HandleLabeledTranscludedSections(NodeTypeTransformation):
        def transform_template(self, obj):
            if obj["name"].startswith("#lst:"):
                article_name = remove_prefix(obj["name"], "#lst:")
                article = self.api.get_content(article_name)

                section_name = obj["params"]["1"]
                begin = r"\<section\s+begin\=[\"']?" + re.escape(section_name) + \
                        r"[\"']?\s*\/>"
                end = r"\<section\s+end\=[\"']?" + re.escape(section_name) + \
                        r"[\"']?\s*\/\>"

                section = re.search(begin + "(.*)" + end, article, re.DOTALL)

                if section:
                    section = section.group(1).strip()
                    content = parse_content(self.api, self.title, section)

                    return {"type": "included_section", "content": content}
                else:
                    message = "section '{}' of '{}' cannot be included" \
                              .format(section_name, article_name)

                    return {"type": "error", "message": message}
            else:
                raise NotInterested()

    class HandleGalleries(SectionTracking):
        def parse_gallery_item(self, text):
            try:
                name, caption = text.split("|", 1)
            except ValueError:
                message = "Gallery item needs a caption"
                log_parser_error(message, text, position=self.current_section)
                return {"type": "error",
                        "message": message}

            caption = parse_inline(self.api, self.title, caption.strip())

            return {"type": "galleryitem", "caption": caption,
                    "name": canonical_image_name(name)}

        def transform_dict(self, obj):
            check(obj, "type") == "element"
            check(obj, "name") == "ul"
            check(obj, "attrs", "typeof") == "mw:Extension/gallery"

            data_mw = json.loads(obj["attrs"]["data-mw"])
            spec = data_mw["body"]["extsrc"].strip()
            items = [self.parse_gallery_item(x) for x in spec.splitlines()]

            return {"type": "gallery",
                    "widths": int(data_mw["attrs"].get("widths", 120)),
                    "heights": int(data_mw["attrs"].get("heights", 120)),
                    "items": items}

class ArticleContentParser(ChainedAction):
    class MediaWikiCode2HTML(Action):
        def __call__(self, text):
            return parse_content(self.api, self.title, text)

    class MergeListParametersInTemplates(NodeTypeTransformation):
        def transform_template(self, obj):
            if obj["name"] in TEMPLATE_LIST_PARAMS:
                params = obj["params"].copy()

                for param_prefix in TEMPLATE_LIST_PARAMS[obj["name"]]:
                    result = []

                    for n in count(1):
                        try:
                            result.append(params.pop(param_prefix + str(n)))
                        except KeyError:
                            break

                    params[param_prefix + "_list"] = result

                return merge(obj, {"params": params})
            else:
                raise NotInterested()

    class RemoveReferences(NodeTypeTransformation):
        # TODO: We need a better implementation
        def transform_element(self, obj):
            if lookup(obj, "attrs", "typeof") in ("mw:Extension/ref",
                                                  "mw:Extension/references"):
                # TODO: Proper parsing of references
                return None
            else:
                raise NotInterested()

    class HandleLists(NodeTransformation):
        def transform_dict(self, obj):
            check(obj, "type") == "element"
            check(obj, "name").of(("ul", "ol"))

            items = [{"type": "listitem",
                         "content": self(li["children"])}
                         for li in obj["children"]]

            return {"type": "list",
                    "ordered": obj["name"] == "ol",
                    "items": items}

    class HandleDefinitionLists(NodeTransformation):
        def transform_dict(self, obj):
            check(obj, "type") == "element"
            check(obj, "name") == "dl"

            items = [{"type": "definitionlistitem",
                      "definition": self(dt["children"]),
                      "explanation": self(dd["children"])}
                      for dt, dd in zip(obj["children"][::2],
                                        obj["children"][1::2])]

            return {"type": "definitionlist",
                    "items": items}

    class HandleFigures(NodeTransformation):
        def transform_dict(self, obj):
            check(obj, "type") == "element"
            check(obj, "name").of(("figure", "span"))
            check(obj, "attrs", "typeof").of(("mw:Image", "mw:Image/Thumb"))

            caption = [child
                       for child in obj["children"]
                       if child["name"] == "figcaption"]
            try:
                caption = caption[0]["children"]
            except IndexError:
                caption = []

            img = obj["children"][0]["children"][0]
            name = canonical_image_name(img["attrs"]["resource"])
            license = self.api.get_image_license(name)

            return {"type": "image", "caption": self(caption), "name": name,
                    "thumbnail": obj["attrs"]["typeof"] == "mw:Image/Thumb",
                    "inline": obj["name"] == "span", "license": license,
                    "noprint": "noprint" in obj["attrs"].get("class", "")}

    class HandleInlineFigures(SectionTracking):
        def transform_dict(self, obj):
            check(obj, "type") == "element"
            check(obj, "name") == "span"
            check(obj, "attrs", "typeof") == "mw:Image"

            message = "Inline images are not allowed"
            log_parser_error(message, obj, position=self.current_section)

            return {"type": "error",
                    "message": message}

    class HandleTable(NodeTransformation):
        def transform_dict(self, obj):
            check(obj, "type") == "element"
            check(obj, "name") == "table"

            content = obj["children"]

            if lookup(content, 0, "name") == "tbody":
                content = content[0]["children"]

            return {"type": "table", "content": self(content)}

    class ConvertInlineMath(NodeTransformation):
        def transform_dict(self, obj):
            check(obj, "attrs", "typeof") == "mw:Extension/math"

            formula = json.loads(obj["attrs"]["data-mw"])["body"]["extsrc"]

            return {"type": "inlinemath", "formula": formula.strip()}

    class FixNodeTypes(NodeTypeTransformation, SectionTracking):
        def transform_element(self, obj):
            if obj["name"] == "p":
                return {"type": "paragraph", "content": self(obj["children"])}
            elif obj["name"] == "br":
                message = "<br> not allowed"
                log_parser_error(message, obj, position=self.current_section)
                return {"type": "error", "message": message}
            elif obj["name"] == "dfn":
                return {"type": "i", "content": self(obj["children"])}
            elif obj["name"] in ("i", "b", "th", "tr", "td"):
                return {"type": obj["name"], "content": self(obj["children"])}
            elif obj["name"] in ("h2", "h3"):
                return {"type": "header",
                        # Header begin with h2 in our project -> subtract 1
                        "depth": int(obj["name"][-1])-1,
                        "content": self(obj["children"])}
            elif obj["name"] == "a":
                url = obj["attrs"].get("href", "")

                if url:
                    if url.startswith("./"):
                        # TODO: The URL prefix should not be hardcoded here
                        url = "https://de.wikibooks.org/wiki/" + url[2:]

                    assert url.startswith("http://") \
                        or url.startswith("https://")

                    return {"type": "href", "url": url,
                            "content": self(obj["children"])}
                else:
                    message = "<a> tag without `href` url"
                    log_parser_error(message, obj, position=self.current_section)

                    return {"type": "error",
                            "message": message}
            elif obj["name"] == "del":
                return {"type": "strikethrough", "content": self(obj["children"])}
            elif obj["name"] == "blockquote":
                return {"type": "blockquote", "content": self(obj["children"])}

            elif lookup(obj, "attrs", "typeof") == "mw:Video/Thumb":
                # TODO: Proper parsing of videos
                return None
            elif lookup(obj, "attrs", "typeof") == "mw:Extension/section":
                data = json.loads(obj["attrs"]["data-mw"])

                assert data["name"] == "section"

                if "begin" in data["attrs"]:
                    return {"type": "section_start",
                            "name": data["attrs"]["begin"]}
                elif "end" in data["attrs"]:
                    return {"type": "section_end",
                            "name": data["attrs"]["end"]}
                else:
                    return {"type": "error",
                            "message": "section must be either start or end."}
            elif obj["name"] in ("h1", "h4", "h5", "h6"):
                message = "Heading of depth {} is not allowed".format(obj["name"][1:])
                log_parser_error(message, obj, position=self.current_section)

                return {"type": "error",
                        "message": message.format(int(obj["name"][-1]))}
            elif lookup(obj, "attrs", "typeof") == "mw:Entity":
                # TODO: Are there other entities?
                return {"type": "entity", "kind": " "}
            elif (obj["name"] == "span" and
                    lookup(obj, "attrs", "typeof") == "mw:DisplaySpace mw:Placeholder"):
                msg = "Spans with type {} are not allowed".format(lookup(obj,
                                                                         "attrs",
                                                                         "typeof"))
                log_parser_error(msg, obj, position=self.current_section)
                return {"type": "error", "message": msg}
            else:
                message = "Parsing of HTML element `{}`".format(obj["name"])
                log_parser_error(message, obj, position=self.current_section)

                return {"type": "notimplemented",
                        "message": message,
                        "target": obj}

    class HandleHeadingAnchors(NodeTypeTransformation):
        def transform_header(self, obj):
            check(obj, "content", -1, "type") == "template"
            check(obj, "content", -1, "name") == "anker"

            heading = text_rstrip(obj["content"][:-1])
            anchor = obj["content"][-1]["params"]["1"]

            return merge(obj, {"content": heading, "anchor": anchor})

    class HandleTemplates(NodeTypeTransformation, SectionTracking):
        def transform_template(self, obj):
            for bname, tname, param_names in BOXSPEC:
                if obj["name"] == tname:
                    params = {k: self(obj["params"].get(v, None))
                              for k, v in param_names.items()}

                    return merge(params, {"type": bname})

            if obj["name"] == "liste":
                if "liste" in obj["params"]:
                    sublist = obj["params"]["liste"][0]

                    assert sublist["type"] == "list"

                    items = sublist["items"]
                    ordered = sublist["ordered"]
                else:
                    items = [{"type": "listitem", "content": self(x)}
                             for x in obj["params"]["item_list"]]
                    ordered = obj["params"].get("type", "") == "ol"

                return {"type": "list", "items": items, "ordered": ordered,
                        "spacing": obj["params"].get("abstand", None)}
            elif obj["name"] == "formel":
                formula = obj["params"].get("1", [])

                if len(formula) == 1 and \
                        lookup(formula, 0, "type") == "inlinemath":
                    formula = formula[0]["formula"]
                    if formula.startswith("\\begin{align}") and formula.endswith("\\end{align}"):
                        formula = remove_prefix(formula, "\\begin{align}")
                        formula = remove_suffix(formula, "\\end{align}")
                    formula = "\\begin{align}" + formula + "\\end{align}"
                    return {"type": "equation", "formula": formula}
                else:
                    message = "Wrong formatted equation"
                    details = "Equation source code must be completely contained in just one <math></math>.\n (use \\text{this is not math} macro instead)"

                    log_parser_error(message, obj, details, self.current_section)

                    return {"type": "error",
                            "message": message}
            elif obj["name"] == "(!":
                return None
            elif obj["name"].startswith("#invoke:"):
                # Template is header or footer
                return None
            elif obj["name"] == "noprint":
                return None
            elif obj["name"] == "todo":
                message = "Todo-Message in MediaWiki code."
                details = "Check if this TODO shoud be completed for a book release."
                log_parser_error(message, obj, details, self.current_section)

                return {"type": "error",
                        "message": message}
            else:
                message = "Parsing of template `{}`".format(obj["name"])
                log_parser_error(message, obj, position=self.current_section)

                return {"type": "notimplemented",
                        "target": obj,
                        "message": message}

    class NormalizeFormulas(NodeTypeTransformation):
        def normalize(self, obj, mode):
            try:
                formula = self.api.normalize_formula(obj["formula"], mode)

                if mode == "tex":
                    formula = remove_prefix(formula, "{\\begin{aligned}")
                    formula = remove_suffix(formula, "\\end{aligned}}")
            except ValueError:
                message = "Wrong formatted formula"
                log_parser_error(message, obj, position=self.current_section)
                return {"type": "error",
                        "message": message}

            return merge(obj, {"formula": formula})

        def transform_inlinemath(self, obj):
            return self.normalize(obj, "inline-tex")

        def transform_equation(self, obj):
            return self.normalize(obj, "tex")

    class DeleteEmptyNodes(Transformation):
        pass

    class AddDefaultValues(NodeTransformation):
        def transform_dict(self, obj):
            check(obj, "type").of(DEFAULT_VALUES)

            return merge(DEFAULT_VALUES[obj["type"]],
                         super(NodeTransformation, self).act_on_dict(obj))

def parse_article_inline(api, title, text):
    # TODO: there might be a better solution by merging with parse_inline()
    result = ArticleContentParser(api=api, title=title)(text)

    assert len(result) == 1
    assert result[0]["type"] == "paragraph"

    return result[0]["content"]

class ArticleParser(ChainedAction):
    class LoadArticleContent(NodeTypeTransformation):
        """Loads the content of an article."""

        def get_article_authors(self, title):
            revisions = self.api.get_revisions(title)

            authors = defaultdict(int)
            article_size = 0

            for rev in (x for x in reversed(revisions) if "anon" not in x):
                user = USERNAMES.get(rev["user"], rev["user"])
                authors[user] += max(rev["size"] - article_size, 50)
                article_size = rev["size"]

            return [x[0] for x in sorted(authors.items(), reverse=True,
                                         key=lambda x: x[1])]

        def transform_article(self, article):
            parser = ArticleContentParser(api=self.api, title=article["title"])

            article_link = self.api._index_url + "?title=" + article["title"].replace(" ", "+")
            report_logger.info("== Parsing of Article [{} {}] ==".format(article_link, article["title"]))

            content = parser(self.api.get_content(article["title"]))
            authors = self.get_article_authors(article["title"])

            return merge(article, {"content": content, "authors": authors})

    class MergeIncludedSections(NodeTypeTransformation):
        """Removes the `included_section` intermediate node."""

        def transform_included_section(self, obj):
            return {"type": "error",
                    "message": "Included section not merged."}

        def transform_article(self, obj):
            if not next(filter(lambda x: x["type"] == "included_section",
                               obj["content"]),
                        None):
                return obj
            merged_content = chain(*(x["content"]
                                     if x["type"] == "included_section"
                                     else [x]
                                     for x in obj["content"]))
            return merge(obj, {"content": list(merged_content)})

    class BuildStructureTree(NodeTypeTransformation, SectionTracking):
        """Transforms a flat article into a tree based on its structure."""

        def split_list(self, prd, lst):
            subforest = [[]]
            for elem in lst:
                if prd(elem):
                    subforest.append([])
                else:
                    subforest[-1].append(elem)
            return subforest if len(subforest[0]) > 0 else subforest[1:]

        def unfold_section(self, obj, level):
            test = lambda x: x["type"] == "header" and x["depth"] == level
            headings = list(filter(test, obj["content"]))
            contents = self.split_list(test, obj["content"])
            # case 1: no underlying structure
            if not headings and len(contents) == 1:
                subsections = obj["content"]
            # case 2: no paragraph before first header
            elif len(headings) == len(contents):
                subsections = [{"type": "section",
                                "title": h["content"],
                                "depth": h["depth"],
                                "content": c}
                               for h, c in zip(headings, contents)]
            # case 3: one paragraph before first header
            elif len(headings) == len(contents) - 1:
                subsections = (contents[0] +
                               [{"type": "section",
                                 "title": h["content"],
                                 "depth": h["depth"],
                                 "content": c}
                                for h, c in zip(headings, contents[1:])])
            # mismatch between headers and paragraphs
            else:
                message = "ill-formed structure in article"
                subsections = [{"type": "error",
                                "message": message}]
                log_parser_error(message, obj, position=self.current_position)
            return merge(obj, {"content": self(subsections)})

        def transform_article(self, obj):
            return self.unfold_section(obj, 1)

        def transform_section(self, obj):
            return self.unfold_section(obj, obj["depth"] + 1)

    class RemoveExcludedSections(NodeTypeTransformation):
        def __init__(self, **options):
            super().__init__(**options)
            self.excludes = []

        def transform_article(self, obj):
            # TODO: parse_inline(x) should be called before
            self.excludes = [parse_article_inline(self.api, obj["title"], x)
                             for x in obj["excludes"]]

            raise NotInterested()

        def transform_section(self, obj):
            if obj["title"] in self.excludes:
                return
            else:
                raise NotInterested()
