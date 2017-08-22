import requests

from unittest import TestCase
from mfnf.api import HTTPMediaWikiAPI

class TestHTTPMediaWikiAPI(TestCase):

    def setUp(self):
        self.api = HTTPMediaWikiAPI(requests.Session())

    def test_get_content(self):
        content = self.api.get_content("Mathe für Nicht-Freaks: Epsilon-Delta-Kriterium der Stetigkeit")

        self.assertTrue(content.startswith("{{#invoke:Mathe für Nicht-Freaks"))
