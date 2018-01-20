"""Download a single image from Wikimedia."""

import argparse
import os
import requests

from lib.api import HTTPMediaWikiAPI
from lib.utils import unquote_filename

def download_image(image):
    with requests.Session() as session:
        api = HTTPMediaWikiAPI(session)
        image_uri = "File:" + image[:1].upper() + image[1:]
        image_info = api.get_image_info(image_uri)
        return requests.get(image_info["url"]).text

if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description=__doc__)
    arg_parser.add_argument("image")
    args = arg_parser.parse_args()
    image = unquote_filename(args.image)
    print(download_image(image))
