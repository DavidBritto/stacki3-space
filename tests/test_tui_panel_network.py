import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TUI_PANEL = ROOT / "payload/.local/bin/tui-panel"


class TuiPanelNetworkTest(unittest.TestCase):
    def setUp(self):
        self.text = TUI_PANEL.read_text()

    def test_network_panel_has_compact_geometry(self):
        self.assertIn("panel_width=760", self.text)
        self.assertIn("panel_height=520", self.text)
        self.assertIn("resize set $panel_width $panel_height", self.text)

    def test_network_panel_disables_auto_tmux_and_sets_newt_colors(self):
        self.assertIn("STACK_NO_AUTO_TMUX=1", self.text)
        self.assertIn("NEWT_COLORS", self.text)
        self.assertIn("exec nmtui", self.text)

    def test_network_connect_panel_opens_nmtui_connect_flow(self):
        self.assertIn("network-connect)", self.text)
        self.assertIn("title=\"TUI: connect network\"", self.text)
        self.assertIn("nmtui-connect", self.text)
        self.assertIn("exec nmtui connect", self.text)

    def test_panels_run_in_bash_without_profile_startup(self):
        self.assertIn("bash --noprofile --norc -c", self.text)


if __name__ == "__main__":
    unittest.main()
