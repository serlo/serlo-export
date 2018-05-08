"""Generate a revision map for articles used in a book."""

import argparse
import sys
from ruamel.yaml import YAML
import time
import curio
import curio_http

from lib.utils import unquote_filename, quote_filename
MW_BASE = "https://de.wikibooks.org/api/rest_v1/"

async def fetch_one(url):
    async with curio_http.ClientSession() as session:
        response = await session.get(url)
        content = await response.json()
        return response, content

async def fill(bookmap):
    tasks = []
    chapter_mapping = {}

    for chapter in chapters(bookmap):
        url = "{}page/title/{}".format(MW_BASE, chapter["path"])
        task = await curio.spawn(fetch_one(url))
        tasks.append(task)
        chapter_mapping[task] = chapter

    for task in tasks:
        response, content = await task.join()
        content = content["items"][0]
        chapter_mapping[task]["revision"] =  content["rev"]

def chapters(bookmap):
    for part in bookmap["parts"]:
        for chapter in part["chapters"]:
            yield chapter

if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description=__doc__)
    arg_parser.add_argument("bookmap")
    args = arg_parser.parse_args()

    yaml = YAML(typ="rt")
    bookmap = yaml.load(open(unquote_filename(args.bookmap)))
    t = time.time()
    curio.run(fill(bookmap))
    print ("took {} s.".format(time.time() - t))
    yaml.dump(bookmap, sys.stdout)



