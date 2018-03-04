"""Compute the dependencies of an article."""

import argparse
import json
import sys

from lib.transformations import ChainedAction, NodeTypeTransformation, NotInterested
from lib.utils import quote_filename

def article_dependencies(article, revision_id):
    dependencies = DependencyParser()(article)
    return revision_id + ".pdf: " + " ".join(DependencyParser.dependencies)

def quote_image_name(image_name):
    return "media/" + quote_filename(image_name).replace(".svg", ".pdf")

class DependencyParser(ChainedAction):

    dependencies = []

    def __init__(self):
        super(DependencyParser, self).__init__()

    class GetFilesRequiredForBuild(NodeTypeTransformation):
        def transform_image(self, obj):
            DependencyParser.dependencies.append(quote_image_name(obj["name"]))
            raise NotInterested

        def transform_gallery(self, obj):
            for image in obj["items"]:
                DependencyParser.dependencies.append(quote_image_name(image["name"]))
            raise NotInterested

if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description=__doc__)
    arg_parser.add_argument("revision")
    args = arg_parser.parse_args()
    print(article_dependencies(json.loads(sys.stdin.read()), args.revision))
