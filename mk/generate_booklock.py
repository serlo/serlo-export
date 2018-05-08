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

async def print_all(article_list):
    tasks = []
    result = {}

    for article in article_list:
        url = "{}page/title/{}".format(MW_BASE, article)
        task = await curio.spawn(fetch_one(url))
        tasks.append(task)

    for task in tasks:
        response, content = await task.join()
        content = content["items"][0]
        result[quote_filename(content["title"])] =  content["rev"]
    return result

def extract_articles(bookmap):
    for part in bookmap["parts"]:
        for chapter in part["chapters"]:
            yield chapter["path"]

if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description=__doc__)
    arg_parser.add_argument("bookmap")
    args = arg_parser.parse_args()

    yaml = YAML(typ="rt")
    bookmap = yaml.load(open(unquote_filename(args.bookmap)))
    t = time.time()
    result = curio.run(print_all(extract_articles(bookmap)))
    print ("took {} s.".format(time.time() - t))
    yaml.dump(result, sys.stdout)



