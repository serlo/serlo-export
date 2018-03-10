"""Resolve a revision id of an article if it is `latest`."""

import argparse
import os
import requests

from lib.api import HTTPMediaWikiAPI
from lib.utils import unquote_filename

def resolve_revid(article, revision):
    if revision != "latest":
        print(revision)
        return
    with requests.Session() as session:
        api = HTTPMediaWikiAPI(session)
        revisions = api.get_revisions(article)
        latest = max(revisions, key=lambda r: r["revid"])
        print(latest["revid"])

if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description=__doc__)
    arg_parser.add_argument("article")
    arg_parser.add_argument("revision")
    args = arg_parser.parse_args()
    article = unquote_filename(args.article)
    resolve_revid(article, args.revision)
