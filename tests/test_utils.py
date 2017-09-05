from unittest import TestCase
from mfnf.utils import merge, lookup, remove_prefix, remove_suffix

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

    def test_merge(self):
        self.assertEqual(merge(None, "a"), "a")
        self.assertListEqual(merge(None, [1, 2]), [1, 2])
        self.assertIsNone(merge(None, None))

        for obj1, obj2, output in [
                ([1, 2], [3, 4], [1, 2, 3, 4]),
                ([],     [3, 4], [3, 4]),
                ([1, 2], [],     [1, 2]),
                (["a"],  ["b"],  ["a", "b"]),
                ({"a": 1}, {"b": 2}, {"a": 1, "b": 2}),
                ({"a": 1}, {"a": 2}, {"a": 2}),
                ({},       {"a": 2}, {"a": 2}),
                ({"a": 2}, {},       {"a": 2})]:
            obj1_before = obj1.copy()
            obj2_before = obj2.copy()

            test_func = self.assertDictEqual if isinstance(obj1, dict) else \
                        self.assertListEqual

            test_func(merge(obj1, obj2), output)

            # obj1 and obj2 didn't change during execution of add_dict()
            test_func(obj1, obj1_before)
            test_func(obj2, obj2_before)

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
