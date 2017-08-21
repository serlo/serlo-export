from unittest import TestCase
from mfnf.utils import remove_prefix, add_dict

class TestUtilsFunctions(TestCase):

    def test_remove_prefix(self):
        self.assertEqual(remove_prefix("aa", "a"), "a")
        self.assertEqual(remove_prefix("aa", ""), "aa")
        self.assertEqual(remove_prefix("aa", "aaa"), "aa")
        self.assertEqual(remove_prefix("a 4 2", "a 4"), " 2")
        self.assertEqual(remove_prefix("", "a 4"), "")

    def test_add_dict(self):
        for dict1, dict2, output in [
                ({"a": 1}, {"b": 2}, {"a": 1, "b": 2}),
                ({"a": 1}, {"a": 2}, {"a": 2}),
                ({},       {"a": 2}, {"a": 2}),
                ({"a": 2}, {},       {"a": 2})]:
            dict1_before = dict1.copy()
            dict2_before = dict2.copy()

            self.assertDictEqual(add_dict(dict1, dict2), output)

            # dict1 and dict2 didn't change during execution of add_dict()
            self.assertDictEqual(dict1, dict1_before)
            self.assertDictEqual(dict2, dict2_before)
