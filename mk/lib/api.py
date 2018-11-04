"""Module with an API for MediaWikis.

Copyright 2017 Stephan Kulla
"""

from abc import ABCMeta, abstractmethod
import urllib.request
from urllib.parse import quote
import re
import os
import sys
from functools import wraps
from requests.exceptions import HTTPError
import time

import logging
report_logger = logging.getLogger("report_logger")

from lib.utils import stablehash, merge, query_path, select_singleton, mkdirs, resolve_usernames

def quote_image_name(text):
    return re.sub(r"[^a-zA-Z0-9]", lambda x: str(ord(x.group())), text)

def retry(max_retries):
    """
    Retry a function `max_retries` times.
    taken from https://stackoverflow.com/questions/23892210/python-catch-timeout-and-repeat-request.
    """
    def retry(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            num_retries = 0
            while num_retries <= max_retries:
                try:
                    ret = func(*args, **kwargs)
                    break
                except HTTPError:
                    if num_retries == max_retries:
                        raise
                    num_retries += 1
                    time.sleep(1)
            return ret
        return wrapper
    return retry

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
        return "https://" + self.domain + "/w/index.php"

    @property
    def _api_url(self):
        """Returns the URL to the server's `api.php` file."""
        return "https://" + self.domain + "/w/api.php"

    @property
    def _rest_api_url(self):
        """Returns the URL to the server's REST API endpoints."""
        return "https://" + self.domain + "/api/rest_v1"

    @retry(5)
    def _index_call(self, params):
        """Make an HTTP request to the server's `index.php` file."""
        req = self.req.get(self._index_url, params=params)

        req.raise_for_status()

        return req.text

    @retry(5)
    def _api_call(self, endpoint, data):
        """Call an REST API endpoint."""
        endpoint_url = "/".join([self._rest_api_url] + endpoint)

        result = self.req.post(endpoint_url, data=data)
        result.raise_for_status()

        return result

    @retry(5)
    def query(self, params, path_to_result):
        params["format"] = "json"
        params["action"] = "query"
        path_to_result = ["query"] + path_to_result
        result = None

        while True:
            api_result = self.req.get(self._api_url, params=params).json()

            if "error" in api_result:
                message = "Error while making API call."

                raise ConnectionError(api_result.get("info", message))

            try:
                result = merge(result, query_path(api_result, path_to_result))
            except KeyError:
                print ("Key error with path", path_to_result, "in", api_result, file=sys.stderr)
                sys.exit(1)

            if "continue" in api_result:
                params.update(api_result["continue"])
            else:
                return result

    def get_image_revisions(self, filename, timestamp="now"):
        """Returns the history of the image `filename`."""
        params = {"titles": filename, "prop": "imageinfo", "iilimit": "max",
                  "iiprop": "url|sha1|timestamp", "iistart": timestamp}

        return list(reversed(self.query(params,
                             ["pages", select_singleton, "imageinfo"])))

    def get_image_license(self, filename, timestamp="now"):
        """Returns licensing information for an image."""
        params = {"titles": "File:" + filename, "prop": "imageinfo", "iiprop": "user|extmetadata|url", "iilimit": "max",
                "iiextmetadatafilter": "LicenseShortName|UsageTerms|AttributionRequired|Restrictions|Artist|ImageDescription|DateTimeOriginal|Credit", "iistart": timestamp}

        query = self.query(params, ["pages", select_singleton, "imageinfo"])
        result = query[0]
        meta = result["extmetadata"]
        shortname = meta.get("LicenseShortName", {}).get("value", "")
        source = meta.get("Artist", {}).get("value", "")

        url = ""
        # creative commons
        if shortname.startswith("CC"):
            if shortname == "CC0":
                url = "https://creativecommons.org/publicdomain/zero/1.0/"
            else:
                components = shortname.lower().split(" ")
                if len(components) != 3:

                    if shortname.startswith("CC-"):
                        last = shortname.rfind("-")
                        mode = shortname[:last].lower()
                        version = shortname[last + 1:].lower()
                    else:

                        report_logger.error("Unkown license: " + shortname)
                        return {}
                else:
                     _, mode, version = components
                url = "https://creativecommons.org/licenses/{}/{}/".format(mode, version)

        elif shortname.lower() == "public domain":
            url = "https://creativecommons.org/licenses/publicdomain/"
        elif shortname.lower().startswith("gfdl"):
            url = "http://www.gnu.org/licenses/fdl.html"
        else:
            report_logger.error("Unkown license: " + shortname)
            url = "unknown"

        authors = list(sorted(set([res["user"] for res in query])))

        return {"user": resolve_usernames(result["user"]), "name": meta.get("UsageTerms", {}).get("value", ""),
                "shortname": shortname, "licenseurl": url, "detailsurl": "https://commons.wikimedia.org/wiki/File:"+filename,
                "url": result["url"], "authors": resolve_usernames(authors), "source": source, "filename": filename}

    def get_image_info(self, filename, timestamp="now"):
        """Returns the URL and sha1 to the current version of the image
        `filename`."""
        return self.get_image_revisions(filename, timestamp)[-1]

    def get_content(self, title, revision_id=None):
        return self._index_call({"action": "raw", "title": title, "oldid": revision_id})

    def convert_text_to_html(self, title, text):
        path = ["transform", "wikitext", "to", "html", quote(title, safe="")]
        data = {"title": title, "wikitext": text, "body_only": True}

        return self._api_call(path, data).text

    def get_revisions(self, title):
        params = {"prop": "revisions", "rvprop": "size|user|ids", "titles": title,
                  "rvlimit": "max"}

        return self.query(params, ["pages", select_singleton, "revisions"])

    def download_image(self, image_name, directory):
        image_info = self.get_image_info(image_name)

        name, ext = os.path.splitext(image_name.lower())
        name +=  "_"  + image_info["sha1"]
        image_name = quote_image_name(name)
        image_file = os.path.join(directory, image_name + ext)

        if not os.path.exists(image_file):
            mkdirs(directory)
            urllib.request.urlretrieve(image_info["url"], image_file)

        return image_name

    def normalize_formula(self, formula, mode):
        assert mode in ["tex", "inline-tex"]

        endpoint = ["media", "math", "check"] + [mode]
        params = {"type": mode, "q": re.sub(r"\s", " ", formula)}

        try:
            result = self._api_call(endpoint, params).json()

            return result["checked"]
        except IOError as error:
            if error.response.status_code == 400:
                # Wrongly formatted math formula
                raise ValueError()
            else:
                raise error
