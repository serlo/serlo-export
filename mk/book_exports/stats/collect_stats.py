""" Collects book stats from article stats."""

import argparse
from collections import defaultdict
import sys
import os
from ruamel.yaml import YAML
# find the lib package
sys.path.append(os.path.dirname(os.path.dirname(os.path.dirname(__file__))))
from lib.utils import unquote_filename

book_stats = {
    "articles": []
}

def add_lint_stats(target, stats):
    target["kind"] = kinds = target.get("kind", {})
    target["severity"] = severities = target.get("severity", {})
    target["lints_total"] = target.get("lints_total", 0)

    for lint in stats:
        kinds[lint["kind"]] = 1 + kinds.get(lint["kind"], 0)
        severities[lint["severity"]] = 1 + severities.get(lint["severity"], 0)
        target["lints_total"] += 1

def add_dict(target, stats):
    for key, value in stats.items():
        if isinstance(value, (int, float)):
            target[key] = target.get(key, 0) + value
        elif isinstance(value, list):
            target[key] = target.get(key, [])
            target[key].extend(value)
        elif isinstance(value, dict):
            target[key] = target.get(key, {})
            add_dict(target[key], value)

def add_article_stats(target, stats):
    add_dict(target, stats)

def process_article_stats(article, stats):

    article_stats = yaml.load(open(article))

    article = article.rstrip(".stats.yml")
    lint_stats = yaml.load(open(article + ".lints.yml"))

    article_result = book_stats.get(article, {})
    name, revision = article.split("/")
    article_result["name"] = unquote_filename(name)
    article_result["revision"] = revision


    add_article_stats(book_stats, article_stats)
    add_article_stats(article_result, article_stats)
    add_lint_stats(book_stats, lint_stats)
    add_lint_stats(article_result, lint_stats)

    book_stats["articles"].append(article_result)


if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description=__doc__)
    arg_parser.add_argument("revision")
    args = arg_parser.parse_args()
    yaml = YAML(typ="safe")

    with open("{}.article_list".format(args.revision), "r") as f:
        lint_index = [l for l in f.read().split() if len(l) > 0]

    for article in lint_index:
        article_stats = yaml.load(open(article))
        process_article_stats(article, article_stats)

    YAML(typ="rt").dump(book_stats, sys.stdout)
