from unittest import TestCase
from mfnf.utils import add_dict, lookup, remove_prefix, remove_suffix

class TestUtilsFunctions(TestCase):

    def test_remove_prefix(self):
        self.assertEqual(remove_prefix("aa", "a"), "a")
        self.assertEqual(remove_prefix("aa", ""), "aa")
        self.assertEqual(remove_prefix("aa", "aaa"), "aa")
        self.assertEqual(remove_prefix("a 4 2", "a 4"), " 2")
        self.assertEqual(remove_prefix("", "a 4"), "")

    def test_remove_suffix(self):
        self.assertEqual(remove_suffix("aa", "a"), "a")
        self.assertEqual(remove_suffix("aa", ""), "aa")
        self.assertEqual(remove_suffix("aa", "aaa"), "aa")
        self.assertEqual(remove_suffix("a 4 2", "4 2"), "a ")
        self.assertEqual(remove_suffix("", "a 4"), "")

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

    def test_lookup(self):
        obj = {"a": [23, 42], "b": { "e": [74] }, "c": True}

        self.assertEqual(lookup(obj, "a", 0), 23)
        self.assertEqual(lookup(obj, "b", "e", 0), 74)
        self.assertEqual(lookup(obj, "c"), True)

        self.assertDictEqual(lookup(obj), obj)
        self.assertListEqual(lookup(obj, "a"), [23, 42])

        self.assertIsNone(lookup(obj, 42))
        self.assertIsNone(lookup(obj, "a", 42))
        self.assertIsNone(lookup(obj, "c", "c"))
        self.assertIsNone(lookup(obj, "b", "e", 0, 0))
