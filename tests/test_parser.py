import yaml

from unittest import TestCase
from mfnf.parser import HTML2JSONParser

class TestHTML2JSONParser(TestCase):
    def test_html2json_parser(self):
        with open("tests/html.spec.yml") as spec_file:
            html_spec = yaml.load(spec_file)

        for spec in html_spec:
            html_text = spec["in"]
            target_json = spec["out"]

            with self.subTest(html_text=html_text):
                parser = HTML2JSONParser()
                parser.feed(html_text)

                self.assertListEqual(parser.content, target_json)
