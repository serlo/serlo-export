"""Creates a PDF from an article of the project „Mathe für Nicht-Freaks“."""

import json
import shelve

import requests

from parser.api import HTTPMediaWikiAPI
from parser.parser import ArticleParser
from parser.utils import CachedFunction, stablehash

# title of article which shall be converted to PDF
ARTICLE = "Mathe für Nicht-Freaks: Ableitung und Differenzierbarkeit"

def run_script():
    """Runs this script."""
    with shelve.open(".cache.db", "c", writeback=True) as database:
        cached_function = CachedFunction(database)

        class CachedMediaWikiAPI(HTTPMediaWikiAPI):
            @cached_function
            def get_content(self, title):
                return super().get_content(title)

            @cached_function
            def convert_text_to_html(self, title, text):
                return super().convert_text_to_html(title, text)

        api = CachedMediaWikiAPI(requests.Session())

        parser = ArticleParser(api=api)

        article = {"type": "article", "title": ARTICLE}

        article = parser(article)

        print(json.dumps(article, indent=2))

if __name__ == "__main__":
    run_script()
