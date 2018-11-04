"""Get the image timestamp from Wikimedia"""

import argparse
import requests

from lib.api import HTTPMediaWikiAPI
from lib.utils import unquote_filename

def get_latest_timestamp(image):
    with requests.Session() as session:
        api = HTTPMediaWikiAPI(session)
        image_uri = "File:" + image[:1].upper() + image[1:]
        image_info = api.get_image_info(image_uri, "now")
        return image_info["timestamp"]

if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description=__doc__)
    arg_parser.add_argument("image")
    args = arg_parser.parse_args()
    image = unquote_filename(args.image)
    print (get_latest_timestamp(image))
