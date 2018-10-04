"""Generate a revision map for articles used in a book."""

import argparse
import sys
from threading import Thread
from ruamel.yaml import YAML
import requests
from queue import Queue

from lib.utils import unquote_filename, quote_filename
MW_BASE = "https://de.wikibooks.org/api/rest_v1/"

concurrent = 100

def fetch(q):
    while True:
        task = q.get()
        if not task:
            q.task_done()
            break
        chapter, url = task
        r = requests.get(url)
        chapter["revision"] = str(r.json()["items"][0]["rev"])
        q.task_done()

def chapters(bookmap):
    for part in bookmap["parts"]:
        for chapter in part["chapters"]:
            yield chapter

if __name__ == "__main__":

    arg_parser = argparse.ArgumentParser(description=__doc__)
    arg_parser.add_argument("bookmap")
    args = arg_parser.parse_args()

    yaml = YAML(typ="rt")
    bookmap = yaml.load(open(args.bookmap))

    q = Queue(concurrent * 2)
    for _ in range(concurrent):
        t = Thread(target=fetch, args=(q,))
        t.daemon = True
        t.start()

    for chapter in chapters(bookmap):
        q.put((chapter, "{}page/title/{}".format(MW_BASE, chapter["path"])))
    q.put(None)
    q.join()
    yaml.dump(bookmap, sys.stdout)
