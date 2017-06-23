"""Module for converting an article to HTML using the MediaWiki API.

Copyright 2017 Richard Mörbitz
"""

import os
import sys

from api import MediaWikiAPI

def convert(wikibook_api):
    """Download the HTML version of an article from the MediaWiki API.

    Arguments:
        wikibook_api -- MediaWikiAPI object to perform the download
    """
    article_text = sys.stdin.read()
    article_html = wikibook_api.convert_text_to_html(article_text)
    sys.stdout.write(article_html)

def run_script():
    """Convert a raw markdown article to HTML."""
    convert(MediaWikiAPI())

if __name__ == "__main__":
    run_script()
