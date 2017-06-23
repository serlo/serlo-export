"""Module for parsing the sitemap of MFNF into a JSON file.

Copyright 2017 Stephan Kulla
"""

import json
import requests
from gevent import monkey
monkey.patch_all()

from api import MediaWikiSession, MediaWikiAPI
import config
from sitemap import parse_sitemap

def run_script(json_file_name):
    """Parses the sitmap of MFNF and stores it into a JSON file."""
    session = MediaWikiSession("de.wikibooks.org", requests.Session())
    wikibooks = MediaWikiAPI(session)
    sitemap = wikibooks.get_content("Mathe für Nicht-Freaks: Sitemap")

    with open(json_file_name, "w") as json_file:
        json.dump(parse_sitemap(sitemap), json_file, sort_keys=True, indent=4)

if __name__ == "__main__":
    run_script(config.SITEMAP_FILE_NAME)
