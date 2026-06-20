import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TUI_PANEL = ROOT / "payload/.local/bin/tui-panel"
I3 = ROOT / "payload/.config/i3/config"


class NetworkPanelClassTest(unittest.TestCase):
    def test_network_panel_uses_dedicated_class(self):
        text = TUI_PANEL.read_text()
        self.assertIn('window_class="stack-network-panel"', text)
        self.assertIn('--class "$window_class"', text)

    def test_i3_network_panel_rule_does_not_resize(self):
        text = I3.read_text()
        self.assertIn('for_window [class="stack-network-panel"] floating enable, move scratchpad, move position center', text)
        self.assertNotIn('for_window [class="stack-network-panel"] floating enable, move scratchpad, resize set', text)


if __name__ == "__main__":
    unittest.main()
