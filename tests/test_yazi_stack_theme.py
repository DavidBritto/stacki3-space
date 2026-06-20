from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
THEME = ROOT / "payload/.config/yazi/theme.toml"


class YaziStackThemeTest(unittest.TestCase):
    def test_yazi_status_pills_are_flattened(self):
        text = THEME.read_text()
        self.assertIn("[status]", text)
        self.assertIn('sep_left = { open = "", close = "" }', text)
        self.assertIn('sep_right = { open = "", close = "" }', text)
        self.assertIn('overall = { fg = "#444b6f", bg = "#000000" }', text)

    def test_yazi_mode_indicator_is_dim_not_blue_pill(self):
        text = THEME.read_text()
        self.assertIn("[mode]", text)
        self.assertIn('normal_main = { fg = "#444b6f", bg = "#000000"', text)
        self.assertIn('normal_alt  = { fg = "#444b6f", bg = "#000000"', text)
        self.assertNotIn("light_blue", text)
        self.assertNotIn("blue", text)


if __name__ == "__main__":
    unittest.main()
