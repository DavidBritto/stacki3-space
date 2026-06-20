import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
I3 = ROOT / "payload/.config/i3/config"


class I3NetworkPanelRuleTest(unittest.TestCase):
    def test_network_tui_is_centered_without_forced_i3_resize(self):
        text = I3.read_text()
        specific = 'for_window [class="stack-network-panel"] floating enable, move scratchpad, move position center'
        self.assertIn(specific, text)
        self.assertNotIn('for_window [class="stack-network-panel"] floating enable, move scratchpad, resize set', text)


if __name__ == "__main__":
    unittest.main()
