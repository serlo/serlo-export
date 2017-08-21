from unittest import TestCase
from mfnf.utils import remove_prefix

class TestUtilsFunctions(TestCase):

    def test_remove_prefix(self):
        self.assertEqual(remove_prefix("aa", "a"), "a")
        self.assertEqual(remove_prefix("aa", ""), "aa")
        self.assertEqual(remove_prefix("aa", "aaa"), "aa")
        self.assertEqual(remove_prefix("a 4 2", "a 4"), " 2")
        self.assertEqual(remove_prefix("", "a 4"), "")
