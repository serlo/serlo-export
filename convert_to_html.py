"""Module for converting an article to HTML using the MediaWiki API."""

import os
import requests
import sys

from api import MediaWikiSession, MediaWikiAPI

def convert(source_file_name, output_file_name, wikibook_api):
    """Download the HTML version of an article from the MediaWiki API.

    Arguments:
        source_file_name -- where the article in raw format is located
        output_file_name -- where the HTML article shall be stored
        wikibook_api -- MediaWikiAPI object to perform the download
    """
    with open(source_file_name, 'r') as source_file:
        article_text = source_file.read()

    article_html = wikibook_api.convert_text_to_html(article_text)

    os.makedirs(os.path.dirname(output_file_name), exist_ok=True)
    with open(output_file_name, 'w') as output_file:
        output_file.write(article_html)

def run_script(source_file_name, output_file_name):
    """Convert a raw markdown article to HTML.

    Arguments:
        source_file_name -- where the article in raw format is located
        output_file_name -- where the HTML article shall be stored
    """
    session = MediaWikiSession("de.wikibooks.org", requests.Session())
    wikibooks = MediaWikiAPI(session)

    convert(source_file_name, output_file_name, wikibooks)

if __name__ == "__main__":
    try:
        source_file_name = sys.argv[1]
        output_file_name = sys.argv[2]
    except IndexError:
        print("usage: python convert_to_html.py SOURCE_FILE OUTPUT_FILE")
    else:
        run_script(source_file_name, output_file_name)
