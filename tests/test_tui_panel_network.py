import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TUI_PANEL = ROOT / "payload/.local/bin/tui-panel"


class TuiPanelNetworkTest(unittest.TestCase):
    def setUp(self):
        self.text = TUI_PANEL.read_text()

    def test_network_panel_has_compact_geometry(self):
        self.assertIn("panel_width=780", self.text)
        self.assertIn("panel_height=560", self.text)
        self.assertIn("resize set $panel_width $panel_height", self.text)

    def test_network_panel_opens_fzf_wifi_manager(self):
        self.assertIn("network-tui)", self.text)
        self.assertIn("title=\"TUI: network\"", self.text)
        self.assertIn("network_tui.sh", self.text)
        self.assertIn("stack-network-panel", self.text)

    def test_network_nmtui_panel_keeps_legacy_flow(self):
        self.assertIn("network-nmtui)", self.text)
        self.assertIn("title=\"TUI: nmtui\"", self.text)
        self.assertIn("NEWT_COLORS", self.text)
        self.assertIn("exec nmtui", self.text)

    def test_bluetooth_panel_opens_fzf_manager(self):
        self.assertIn("bluetooth-tui)", self.text)
        self.assertIn("title=\"TUI: bluetooth\"", self.text)
        self.assertIn("bluetooth_tui.sh", self.text)
        self.assertIn("stack-bluetooth-panel", self.text)

    def test_panels_run_in_bash_without_profile_startup(self):
        self.assertIn("bash --noprofile --norc -c", self.text)


if __name__ == "__main__":
    unittest.main()
