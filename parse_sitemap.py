"""Module for parsing the sitemap of MFNF into a JSON file."""

import json
import re
import requests

from api import MediaWikiSession, MediaWikiAPI

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

    def replace_node(self, node):
        """Parses the code of the node and returns a new node with the parsed
        link to the article and the node's name.
        """
        if "code" not in node:
            return {}

        code = node["code"].strip()

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

class Sitemap:
    """Functions for parsing sitemap."""

    @staticmethod
    def create_node(code, depth):
        """Returns a sitemap node with no children"""
        return {"code": code, "depth": depth, "children": []}

    @staticmethod
    def yield_nodes(sitemap):
        """Generator for all node specifications in a sitemap. It yields tuples
        `(code, depth)` whereas `code` is a string representation of the node
        and `depth` is a number corresponding to the depth the node corresponds
        to.
        """
        max_headline_depth = 6
        headline_re = r"(={1,%s})(.*)\1" % max_headline_depth
        list_re = r"([*]+)(.*)"

        for line in sitemap.splitlines():
            for regex, depth_start in ((headline_re, 0),
                                       (list_re, max_headline_depth)):
                match = re.match(regex, line)

                if match:
                    code = match.group(2).strip()
                    depth = depth_start + len(match.group(1))

                    yield Sitemap.create_node(code, depth)

    @staticmethod
    def insert_node(base, new_node):
        """Inserts a node at the right position."""
        if (len(base["children"]) > 0 and
                new_node["depth"] > base["children"][-1]["depth"]):
            Sitemap.insert_node(base["children"][-1], new_node)
        else:
            base["children"].append(new_node)

    @staticmethod
    def parse(sitemap):
        """Parse the sitemap and returns a JSON object of it.

        Arguments:
            sitemap -- content of the sitemap (a string)
        """
        root = {"children":[], "depth":0}

        for node in Sitemap.yield_nodes(sitemap):
            Sitemap.insert_node(root, node)

        root = ParseNodeCodes()(root)

        return root

def run_script(json_file_name):
    """Parses the sitmap of MFNF and stores it into a JSON file."""
    session = MediaWikiSession("de.wikibooks.org", requests.Session())
    wikibooks = MediaWikiAPI(session)
    sitemap = wikibooks.get_content("Mathe für Nicht-Freaks: Sitemap")

    with open(json_file_name, "w") as json_file:
        json.dump(Sitemap.parse(sitemap), json_file, sort_keys=True, indent=4)

if __name__ == "__main__":
    run_script("sitemap.json")
