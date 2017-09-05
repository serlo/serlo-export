import requests

from unittest import TestCase
from mfnf.api import HTTPMediaWikiAPI

class TestHTTPMediaWikiAPI(TestCase):

    def setUp(self):
        self.api = HTTPMediaWikiAPI(requests.Session())

    def test_get_image_revisions(self):
        # TODO: Implement more tests
        filename = "File:Hyperbola one over x.svg"
        revisions = self.api.get_image_revisions(filename)

        self.assertEqual(revisions[0]["url"],
                "https://upload.wikimedia.org/wikipedia/commons/4/43/"
                "Hyperbola_one_over_x.svg")

    def test_get_content(self):
        content = self.api.get_content("Mathe für Nicht-Freaks: Epsilon-Delta-Kriterium der Stetigkeit")

        self.assertTrue(content.startswith("{{#invoke:Mathe für Nicht-Freaks"))

    def test_convert_text_to_html(self):
        html = self.api.convert_text_to_html("Analysis", "Hello ''World''")

        self.assertEqual(html, '<p id="mwAQ">Hello <i id="mwAg">World</i></p>')
