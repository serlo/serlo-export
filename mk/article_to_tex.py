"""Creates a PDF from an article of the project „Mathe für Nicht-Freaks“."""

import time
import os
import shelve
import sys
import re
import logging
import json

import requests
from urllib3.util.retry import Retry

from lib.latex import LatexExporter, MediaWiki2Latex
from lib.api import HTTPMediaWikiAPI

report_logger = logging.getLogger("report_logger")
report_logger.setLevel(logging.DEBUG)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
report_logger.addHandler(console_handler)
file_handler = logging.FileHandler("parser_log.log", mode="w")
file_handler.setLevel(logging.DEBUG)
report_logger.addHandler(file_handler)

def article_to_tex(article):
    """Creates the LaTeX file of an article."""
    article = MediaWiki2Latex()(article)
    with requests.Session() as session:
        api = HTTPMediaWikiAPI(session)
        LatexExporter(api, "/tmp")(article, sys.stdout)

if __name__ == "__main__":
    article_to_tex(json.loads(sys.stdin.read()))
