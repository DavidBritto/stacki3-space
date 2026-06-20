from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
YAZI_DIR = ROOT / "payload/.config/yazi"
KEYMAP = YAZI_DIR / "keymap.toml"
CHEATSHEET = YAZI_DIR / "cheatsheet.txt"
INIT = YAZI_DIR / "init.lua"


class YaziFooterTest(unittest.TestCase):
    def test_yazi_does_not_inject_footer_help_overlay(self):
        self.assertFalse(INIT.exists(), "Yazi should not inject footer help that overlaps tmux/status bars")

    def test_yazi_help_lives_in_keymap_and_cheatsheet(self):
        self.assertIn('on = "H"', KEYMAP.read_text())
        self.assertIn("shortcuts-help yazi", KEYMAP.read_text())
        text = CHEATSHEET.read_text()
        self.assertIn("YAZI CHEATSHEET", text)
        self.assertIn("H         abrir esta chuleta", text)


if __name__ == "__main__":
    unittest.main()
