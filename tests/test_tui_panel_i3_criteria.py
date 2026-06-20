import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TUI_PANEL = ROOT / "payload/.local/bin/tui-panel"


class TuiPanelI3CriteriaTest(unittest.TestCase):
    def test_i3_criteria_uses_title_and_window_class_variable(self):
        text = TUI_PANEL.read_text()
        self.assertIn('i3-msg "[title=', text)
        self.assertIn('kitty --class "$window_class" --title "$title"', text)
        self.assertIn('$window_class', text)
        self.assertIn('title=', text)
        self.assertIn('$title', text)


if __name__ == "__main__":
    unittest.main()
