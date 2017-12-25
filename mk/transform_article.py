"""Creates a PDF from an article of the project „Mathe für Nicht-Freaks“."""

import argparse
import time
import os
import shelve
import sys
import re
import logging

import json

import requests
from urllib3.util.retry import Retry

from lib.api import HTTPMediaWikiAPI
from lib.parser import ArticleParser, ArticleContentParser
from lib.utils import CachedFunction
from lib.utils import to_snake_case, open_database, mkdirs, unquote_filename

report_logger = logging.getLogger("report_logger")
report_logger.setLevel(logging.DEBUG)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
report_logger.addHandler(console_handler)
file_handler = logging.FileHandler("parser_log.log", mode="w")
file_handler.setLevel(logging.DEBUG)
report_logger.addHandler(file_handler)

# title of article which shall be converted to PDF
CACHE = ".cache/cache.db"

def transform_article(book, api):
    report_logger.info("= Export of Book {} =".format("bar"))
    print(json.dumps(book, indent=2))

def run_script(article, revision):
    """Runs this script."""
    with open_database(CACHE) as database:
        cached_function = CachedFunction(database)

        class CachedMediaWikiAPI(HTTPMediaWikiAPI):
            """A version of the API where the main function calls are
            cached."""

            @cached_function
            def convert_text_to_html(self, title, text):
                return super().convert_text_to_html(title, text)

            @cached_function
            def normalize_formula(self, formula, mode):
                return super().normalize_formula(formula, mode)

            @cached_function
            def get_revisions(self, title):
                # TODO: The list of revisions can change, thus this caching
                # need to be implemented in a better way in the future.
                return super().get_revisions(title)

        ses = requests.Session()
        retry = Retry(total=20, connect=10, read=10, status=10,
                      status_forcelist=[504, 503], backoff_factor=1,
                      method_whitelist=frozenset(['HEAD', 'TRACE', 'GET',
                                                  'PUT', 'OPTIONS', 'DELETE',
                                                  'POST']),
                      raise_on_status=True)
        ses.mount("", requests.adapters.HTTPAdapter(max_retries=retry))

        api = CachedMediaWikiAPI(ses)
        parser = ArticleParser(api=api)

        report_logger.info("= Report for pdf export of {} at {}. =\n".format("foo", time.strftime("%a, %d %b %Y %H:%M:%S", time.localtime())))
        article = {"type": "article",
                   "title": article.replace("_", " "),
                   "excludes": [],
                   "content": sys.stdin.read()}
        transform_article(parser(article), api)

if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description=__doc__)
    arg_parser.add_argument("article")
    arg_parser.add_argument("revision")
    args = arg_parser.parse_args()
    article = unquote_filename(args.article)
    run_script(article, args.revision)
