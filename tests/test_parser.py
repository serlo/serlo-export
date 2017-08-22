import requests
import yaml

from unittest import TestCase
from mfnf.api import HTTPMediaWikiAPI
from mfnf.parser import HTML2JSONParser, ArticleContentParser

class TestHTML2JSONParser(TestCase):

    def setUp(self):
        self.api = HTTPMediaWikiAPI(requests.Session())

    def test_html2json_parser(self):
        with open("docs/html.spec.yml") as spec_file:
            html_spec = yaml.load(spec_file)

        for spec in html_spec:
            html_text = spec["in"]
            target_json = spec["out"]

            with self.subTest(html_text=html_text):
                parser = HTML2JSONParser()
                parser.feed(html_text)

                self.assertListEqual(parser.content, target_json)

    def test_parsing_block_elements(self):
        with open("docs/mfnf-block-elements.spec.yml") as spec_file:
            spec = yaml.load(spec_file)

        for text, target in ((x["in"], x["out"]) for x in spec):
            parser = ArticleContentParser(api=self.api, title="Foo")

            self.assertListEqual(parser(text), target)
