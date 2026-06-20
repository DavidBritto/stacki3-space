import json
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
THEMES = ROOT / "payload/.config/stack-theme/themes"
README = ROOT / "README.md"


class StackThemeCatalogTest(unittest.TestCase):
    def test_space_lime_theme_exists_with_full_dark_neon_palette(self):
        theme = json.loads((THEMES / "space-lime.json").read_text())
        colors = theme["colors"]

        self.assertEqual("space-lime", theme["name"])
        self.assertEqual("#000000", colors["bg"])
        self.assertEqual("#030303", colors["surface"])
        self.assertEqual("#21e6ff", colors["accent"])
        self.assertEqual("#b8ff3d", colors["accent2"])
        self.assertEqual("#b8ff3d", colors["success"])
        self.assertIn("#a855ff", theme["terminal"]["palette"])

    def test_readme_lists_space_lime_as_official_theme(self):
        text = README.read_text()

        self.assertIn("stack-theme apply space-lime", text)
        self.assertIn("full dark con acentos cian/lima", text)


if __name__ == "__main__":
    unittest.main()
