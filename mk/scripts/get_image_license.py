import argparse
import requests
import sys
import json

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
    json.dump({
        "license": get_image_license(unquote_filename(args.image), args.timestamp)
    }, sys.stdout)
