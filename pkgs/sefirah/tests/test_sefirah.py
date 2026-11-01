import unittest

from sefirah.layout import lock_layout, parse_outputs


class ParseOutputsTest(unittest.TestCase):
    def test_scaled_logical_is_physical(self):
        outputs = {"eDP-1": {"logical": {"width": 1600, "height": 900, "scale": 1.2}}}
        self.assertEqual(parse_outputs(outputs), (1920, 1080))

    def test_rotated(self):
        outputs = {"eDP-1": {"logical": {"width": 900, "height": 1600, "scale": 1.2}}}
        self.assertEqual(parse_outputs(outputs), (1080, 1920))

    def test_no_logical(self):
        self.assertIsNone(parse_outputs({}))


class LockLayoutTest(unittest.TestCase):
    def test_card_even_and_positive(self):
        layout = lock_layout((1920, 1080), 0, 2)
        self.assertEqual(layout["card_w"], 320)
        self.assertGreaterEqual(layout["lock_x"], 72)


if __name__ == "__main__":
    unittest.main()
