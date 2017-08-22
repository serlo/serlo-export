"""Creates a PDF from an article of the project „Mathe für Nicht-Freaks“."""

import json
import requests

from parser.api import HTTPMediaWikiAPI
from parser.parser import ArticleParser

# title of article which shall be converted to PDF
ARTICLE = "Mathe für Nicht-Freaks: Ableitung und Differenzierbarkeit"

def run_script():
    """Runs this script."""
    api = HTTPMediaWikiAPI(requests.Session())
    parser = ArticleParser(api=api)

    article = {"type": "article", "title": ARTICLE}

    article = parser(article)

    print(json.dumps(article, indent=2))

if __name__ == "__main__":
    run_script()
