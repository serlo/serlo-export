import os
import shelve

from unittest import TestCase

import requests
import yaml

from mfnf.api import HTTPMediaWikiAPI
from mfnf.parser import HTML2JSONParser, ArticleContentParser
from mfnf.utils import CachedFunction, open_database

class TestParser(TestCase):

    @classmethod
    def setUpClass(cls):
        cls.database = open_database(".cache/.cache.db")
        cached_function = CachedFunction(cls.database)

        class CachedMediaWikiAPI(HTTPMediaWikiAPI):
            @cached_function
            def get_content(self, title):
                return super().get_content(title)

            @cached_function
            def convert_text_to_html(self, title, text):
                return super().convert_text_to_html(title, text)

        cls.api = CachedMediaWikiAPI(requests.Session())

    @classmethod
    def tearDownClass(cls):
        cls.database.close()

    def setUp(self):
        self.title = "Mathe für Nicht-Freaks: Analysis 1"
        self.maxDiff = None

    def parse(self, text):
        return ArticleContentParser(api=self.api, title=self.title)(text)

    def test_html2json_parser(self):
        with open("docs/html.spec.yml") as spec_file:
            spec = yaml.load(spec_file)

        for html, target_json in ((x["in"], x["out"]) for x in spec):
            with self.subTest(html=html):
                parser = HTML2JSONParser()
                parser.feed(html)

                self.assertListEqual(parser.content, target_json, msg=html)

    def test_parsing_block_elements(self):
        with open("docs/mfnf-block-elements.spec.yml") as spec_file:
            spec = yaml.load(spec_file)

        for text, target in ((x["in"], x["out"]) for x in spec):
            with self.subTest(text=text):
                self.assertListEqual(self.parse(text), target, msg=text)

    def test_parsing_inline_elements(self):
        with open("docs/mfnf-inline-elements.spec.yml") as spec_file:
            spec = yaml.load(spec_file)

        for text, target in ((x["in"], x["out"]) for x in spec):
            with self.subTest(text=text):
                target = [{"type": "paragraph", "content": [target]}]

                self.assertListEqual(self.parse(text), target, msg=text)
