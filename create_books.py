"""Creates a PDF from an article of the project „Mathe für Nicht-Freaks“."""

import time
import os
import shelve
import sys
import logging
import requests

report_logger = logging.getLogger("report_logger")
report_logger.setLevel(logging.DEBUG)
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
report_logger.addHandler(console_handler)
file_handler = logging.FileHandler(os.path.join("out", "parser_log.log"), mode="w")
file_handler.setLevel(logging.DEBUG)
report_logger.addHandler(file_handler)

from mfnf.api import HTTPMediaWikiAPI
from mfnf.parser import ArticleParser
from mfnf.utils import CachedFunction
from mfnf.sitemap import parse_sitemap
from mfnf.latex import LatexExporter, MediaWiki2Latex
from mfnf.utils import to_snake_case

# title of article which shall be converted to PDF
SITEMAP_ARTICLE_NAME = "Mathe für Nicht-Freaks: Projekte/LMU Buchprojekte"
CACHE = ".cache/cache.db"

def create_book(book, api):
    """Creates the LaTeX file of a book."""
    book_name = to_snake_case(book["name"])
    target = os.path.join("out", book_name, book_name + ".tex")

    try:
        os.makedirs(os.path.dirname(target))
    except FileExistsError:
        pass

    report_logger.info("= Export of Book {} =".format(book["name"]))
    book = MediaWiki2Latex()(book)

    with open(target, "w") as latex_file:
        LatexExporter(api, os.path.dirname(target))(book, latex_file)

def run_script():
    """Runs this script."""
    try:
        os.mkdir(os.path.dirname(CACHE))
    except FileExistsError:
        pass

    with shelve.open(CACHE, "c", writeback=True) as database:
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

        api = CachedMediaWikiAPI(requests.Session())
        parser = ArticleParser(api=api)

        sitemap = parse_sitemap(api.get_content(SITEMAP_ARTICLE_NAME))

        if len(sys.argv) >= 2:
            sitemap["children"] = [x for x in sitemap["children"]
                                   if to_snake_case(x["name"]) ==
                                   to_snake_case(sys.argv[1])]

        report_logger.info("= Report for pdf export of {} at {}. =\n".format(SITEMAP_ARTICLE_NAME, time.strftime("%a, %d %b %Y %H:%M:%S", time.localtime())))
        sitemap = parser(sitemap)

        for book in sitemap["children"]:
            create_book(book, api)

if __name__ == "__main__":
    run_script()
