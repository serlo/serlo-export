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

    def index_call(self, params):
        """Make an HTTP request to the server's `index.php` file."""
        return self.req.get(self.index_url, params=params).text

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
