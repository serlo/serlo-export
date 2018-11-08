"""Download a single revision of a single article."""

import argparse
import os
import requests

from lib.api import HTTPMediaWikiAPI
from lib.utils import unquote_filename

def download_article(article, revision):
    with requests.Session() as session:
        api = HTTPMediaWikiAPI(session)
        print(api.get_content(article, revision))

if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description=__doc__)
    arg_parser.add_argument("article")
    arg_parser.add_argument("revision")
    args = arg_parser.parse_args()
    article = unquote_filename(args.article)
    download_article(article, args.revision)
