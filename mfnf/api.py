"""Module with an API for MediaWikis.

Copyright 2017 Stephan Kulla
"""

import urllib.request

from abc import ABCMeta, abstractmethod
from urllib.parse import quote
from mfnf.utils import stablehash

class MediaWikiAPI(metaclass=ABCMeta):
    """Interface for accessing content of a MediaWiki project."""

    @abstractmethod
    def get_content(self, title):
        """Returns the content of the article with title `title`."""
        raise NotImplementedError()

    @abstractmethod
    def convert_text_to_html(self, title, text):
        """Converts MediaWiki code `text` into HTML representing it."""
        raise NotImplementedError()

    @abstractmethod
    def download_image(self, image_url, image_path):
        """Downloads image from `image_url` and stores it to `image_path`"""
        raise NotImplementedError

class HTTPMediaWikiAPI(MediaWikiAPI):
    """Implements an API for content stored on a MediaWiki."""

    def __init__(self, req, domain="de.wikibooks.org"):
        """Initializes the object.

        Arguments:
        domain -- domain of the MediaWiki, e.g. `"de.wikibooks.org"`
        req    -- an session object of the `request` framework
        """
        self.domain = domain
        self.req = req

    def _stablehash(self):
        return stablehash((self.__class__.__name__, self.domain))

    @property
    def _index_url(self):
        """Returns the URL to the server's `index.php` file."""
        return "http://" + self.domain + "/w/index.php"

    @property
    def _rest_api_url(self):
        """Returns the URL to the server's REST API endpoints."""
        return "https://de.wikibooks.org/api/rest_v1"

    def _index_call(self, params):
        """Make an HTTP request to the server's `index.php` file."""
        return self.req.get(self._index_url, params=params).text

    def _api_call(self, endpoint, data):
        """Call an REST API endpoint."""
        endpoint_url = "/".join([self._rest_api_url] + endpoint)
        return self.req.post(endpoint_url, data=data)

    def get_content(self, title):
        return self._index_call({"action": "raw", "title": title})

    def convert_text_to_html(self, title, text):
        endpoint = ["transform", "wikitext", "to", "html", quote(title)]
        data = {"title": title, "wikitext": text, "body_only": True}

        return self._api_call(endpoint, data).text

    def download_image(self, image_url, image_path):
        urllib.request.urlretrieve(image_url, image_path)
