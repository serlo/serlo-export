"""Functions for parsing sitemap.

Copyright 2017 Stephan Kulla
"""

import re

class SitemapTransformer(object):
    """Transforms a JSON by changing its dictionaries."""

    def __call__(self, node):
        """Replacing all nodes in a sitemap tree.

        Not the most generic solution for a JSON transformer! :-)"""
        result = self.replace_node(node)
        result["children"] = [self(x) for x in node["children"]]

        return result

    def replace_node(self, oldnode):
        """Returns a new node."""
        pass


class ParseNodeCodes(SitemapTransformer):
    """Parses the specification of each node in a tree."""

    def replace_node(self, oldnode):
        """Parses the code of the node and returns a new node with the parsed
        link to the article and the node's name.
        """
        if "code" not in oldnode:
            return {}

        code = oldnode["code"].strip()

        match = re.match(r"(.*)\{\{Symbol\|\d+%\}}", code)

        if match:
            code = match.group(1).strip()

        match = re.match(r"\[\[([^|\]]+)\|([^|\]]+)\]\]", code)

        if match:
            link = match.group(1)
            name = match.group(2)
        else:
            name = code
            link = None

        return {"link": link, "name": name}

def generate_sitemap_nodes(sitemap_text):
    """Generator for all node specifications in a sitemap source code. It
    yields dictionaries of the form:

        { "code": code, "depth": depth, "children": [] }

    Thereby `code` is a string representation of the node and `depth` is a
    number corresponding to the node's depth. The higher the depth is, the
    deeper the node need to be included in the final tree.
    """
    # In MediaWiki the maximal depth of a headline is 6 (as in HTML).
    # For list elements this maximal header depth is added so that list
    # elements will always be included under a headline node.
    max_headline_depth = 6

    headline_re = re.compile(r"""(={1,%s}) # Equal signs of the headline
                                 (.*)      # code defining the node
                                 \1        # Repeatation of the equal signs
                              """ % max_headline_depth, re.X)

    list_re = re.compile(r"""([*]+) # asteriks of a list element
                             (.*)   # code defining a sitemap node
                          """, re.X)

    for line in sitemap_text.splitlines():
        for regex, depth_start in ((headline_re, 0),
                                   (list_re, max_headline_depth)):
            match = regex.fullmatch(line.strip())

            if match:
                yield {
                    "code": match.group(2).strip(),
                    "depth": depth_start + len(match.group(1)),
                    "children": []
                }

def insert_node(node, new_node):
    """Inserts the node `new_node` in the tree `node` at the right position
    regarding to the attribute `depth` of `node`."""
    if node["children"] and new_node["depth"] > node["children"][-1]["depth"]:
        insert_node(node["children"][-1], new_node)
    else:
        node["children"].append(new_node)

def parse(sitemap):
    """Parse the sitemap and returns a JSON object of it.

    Arguments:
        sitemap -- content of the sitemap (a string)
    """
    root = {"children":[], "depth":0}

    for node in generate_sitemap_nodes(sitemap):
        insert_node(root, node)

    root = ParseNodeCodes()(root)

    return root
