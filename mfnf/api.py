"""Module with an API for MediaWikis.

Copyright 2017 Stephan Kulla
"""

from abc import ABCMeta, abstractmethod
import urllib.request
from urllib.parse import quote

from mfnf.utils import stablehash, merge, query_path, select_singleton

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
    def download_image(self, image_name, image_path):
        """Downloads image `image_name` and stores it to `image_path`."""
        raise NotImplementedError()

    @abstractmethod
    def get_revisions(self, title):
        """Returns the revisions of the article `title`."""
        raise NotImplementedError()

    @abstractmethod
    def normalize_formula(self, formula, mode):
        """Normalizes the formula `formula`. In case the given formula is
        ilformatted a `ValueError` is raised. `mode` can be either `"tex"`
        or `inline-tex`."""
        raise NotImplementedError()

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
    def _api_url(self):
        """Returns the URL to the server's `api.php` file."""
        return "https://de.wikibooks.org/w/api.php"

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

    def query(self, params, path_to_result):
        params["format"] = "json"
        params["action"] = "query"
        path_to_result = ["query"] + path_to_result
        result = None

        while True:
            api_result = self.req.get(self._api_url, params=params).json()
            result = merge(result, query_path(api_result, path_to_result))

            if "continue" in api_result:
                params.update(api_result["continue"])
            else:
                return result

    def get_image_revisions(self, filename):
        """Returns the history of the image `filename`."""
        params = {"titles": filename, "prop": "imageinfo", "iiprop": "url"}

        return self.query(params, ["pages", select_singleton, "imageinfo"])

    def get_image_url(self, filename):
        """Returns the URL to the current version of the image `filename`."""
        return self.get_image_revisions(filename)[-1]["url"]

    def get_content(self, title):
        return self._index_call({"action": "raw", "title": title})

    def convert_text_to_html(self, title, text):
        endpoint = ["transform", "wikitext", "to", "html", quote(title)]
        data = {"title": title, "wikitext": text, "body_only": True}

        return self._api_call(endpoint, data).text

    def get_revisions(self, title):
        params = {"prop": "revisions", "rvprop": "size|user", "titles": title,
                  "rvlimit": "max"}

        return self.query(params, ["pages", select_singleton, "revisions"])

    def download_image(self, image_name, image_path):
        urllib.request.urlretrieve(self.get_image_url(image_name), image_path)

    def normalize_formula(self, formula, mode):
        assert mode in ["tex", "inline-tex"]

        endpoint = ["media", "math", "check"] + [mode]
        params = {"type": mode, "q": formula}
        result = self._api_call(endpoint, params).json()

        if result.get("title", None) == "Bad Request":
            raise ValueError()

        return result["checked"]
