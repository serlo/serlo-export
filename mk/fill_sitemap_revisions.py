"""Generate a revision map for articles used in a book."""

from multiprocessing.pool import ThreadPool
import os
import argparse
import sys
import subprocess
from threading import Thread
from ruamel.yaml import YAML
from queue import Queue

concurrent = 50

def fetch(q):
    while True:
        task = q.get()
        if not task:
            q.task_done()
            break
        chapter, article, rev_file = task
        script_path = os.path.abspath(os.path.dirname(__file__)) + "/get_revision.sh"
        result = subprocess.check_output([script_path, rev_file, article])
        chapter["revision"] = result.decode("utf-8").strip()
        q.task_done()

def chapters(bookmap):
    for part in bookmap["parts"]:
        for chapter in part["chapters"]:
            yield chapter

if __name__ == "__main__":

    arg_parser = argparse.ArgumentParser(description=__doc__)
    arg_parser.add_argument("bookmap")
    arg_parser.add_argument("revision_lockfile")
    args = arg_parser.parse_args()

    yaml = YAML(typ="rt")
    bookmap = yaml.load(open(args.bookmap))

    q = Queue(concurrent * 2)
    for _ in range(concurrent):
        t = Thread(target=fetch, args=(q,))
        t.daemon = True
        t.start()

    for chapter in chapters(bookmap):
        q.put((chapter, chapter["path"], args.revision_lockfile))
    q.put(None)
    q.join()
    yaml.dump(bookmap, sys.stdout)
