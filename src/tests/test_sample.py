import unittest

from main import handler

class Test_Sample(unittest.TestCase):
    def test_sample(self):
        result = handler(None, None)
        self.assertEqual('Hello world', result)