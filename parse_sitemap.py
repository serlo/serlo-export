"""Module for parsing the sitemap of MFNF into a JSON file."""

import re
import requests

from api import MediaWikiSession, MediaWikiAPI

class Sitemap:

    @staticmethod
    def compute_tokens(sitemap):
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
                    yield (match.group(2).strip(),
                           depth_start + len(match.group(1)))

    @staticmethod
    def parse(sitemap):
        """Parse the sitemap and returns a JSON object of it.

        Arguments:
            sitemap -- content of the sitemap (a string)
        """
        for code, depth in Sitemap.compute_tokens(sitemap):
            print("%2d - %s" % (depth, code))


def run_script():
    """Parses the sitmap of MFNF and stores it into a JSON file."""
    session = MediaWikiSession("de.wikibooks.org", requests.Session())
    wikibooks = MediaWikiAPI(session)
    sitemap = wikibooks.get_content("Mathe für Nicht-Freaks: Sitemap")

    Sitemap.parse(sitemap)

if __name__ == "__main__":
    run_script()
