"""Module with an API for MediaWikis."""

class MediaWikiSession(object):
    """Encapsulates a session for requests to a MediaWiki server. This class
    implements all methods which are related to HTTP requests."""

    def __init__(self, domain, req):
        """Initializes the object.

        Arguments:
        domain -- domain of the MediaWiki, e.g. `"de.wikibooks.org"`
        req    -- an session object of the `request` framework
        """
        self.domain = str(domain)
        self.req = req

    @property
    def index_url(self):
        """Returns the URL to the server's `index.php` file."""
        return "http://" + self.domain + "/w/index.php"

    @property
    def rest_api_url(self):
        """Returns the URL to the server's REST API endpoints."""
        return "https://en.wikipedia.org/api/rest_v1"

    def index_call(self, params):
        """Make an HTTP request to the server's `index.php` file."""
        return self.req.get(self.index_url, params=params).text

    def api_call(self, endpoint, data):
        """Call an REST API endpoint."""
        endpoint_url = "/".join([self.rest_api_url] + endpoint)
        return self.req.post(endpoint_url, data=data)

class MediaWikiAPI(object):
    """Implements an API for content stored on a MediaWiki."""

    def __init__(self, session):
        """Initializes the object.

        Arguments:
        session -- an object of the class `MediaWikiSession`
        """
        self.session = session

    def get_content(self, title):
        """Returns the content of an article with title `title`."""
        return self.session.index_call({"action": "raw", "title": title})

    def convert_text_to_html(self, text):
        """Returns the markdown string `text` converted to HTML."""
        endpoint = ["transform", "wikitext", "to", "html"]
        data     = {"wikitext": text, "original": {}}
        return self.session.api_call(endpoint, data).text
