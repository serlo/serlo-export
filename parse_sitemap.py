"""Module for parsing the sitemap of MFNF into a JSON file."""

import requests

from api import MediaWikiSession, MediaWikiAPI

def run_script():
    """Parses the sitmap of MFNF and stores it into a JSON file."""
    session = MediaWikiSession("de.wikibooks.org", requests.Session())
    wikibooks = MediaWikiAPI(session)
    sitemap = wikibooks.get_content("Mathe für Nicht-Freaks: Sitemap")

    print(sitemap)


if __name__ == "__main__":
    run_script()
