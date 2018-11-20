from ruamel.yaml import YAML
import argparse
import requests
import sys

from lib.api import HTTPMediaWikiAPI
from lib.utils import unquote_filename

def get_image_license(image, timestamp):
    with requests.Session() as session:
        api = HTTPMediaWikiAPI(session)
        return api.get_image_license(image, timestamp)

if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description=__doc__)
    arg_parser.add_argument("image")
    arg_parser.add_argument("timestamp")
    args = arg_parser.parse_args()
    yaml = YAML(typ="rt")
    yaml.dump({
        "license": get_image_license(unquote_filename(args.image), args.timestamp)
    }, sys.stdout)
