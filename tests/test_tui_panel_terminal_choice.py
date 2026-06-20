import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TUI_PANEL = ROOT / "payload/.local/bin/tui-panel"


class TuiPanelTerminalChoiceTest(unittest.TestCase):
    def setUp(self):
        self.text = TUI_PANEL.read_text()

    def test_panels_use_kitty_stack_panel_surface(self):
        self.assertIn("kitty --class", self.text)
        self.assertIn("--override scrollback_lines=0", self.text)
        self.assertIn("--override remember_window_size=no", self.text)

    def test_nmtui_keeps_shell_and_tmux_disabled(self):
        self.assertIn("bash --noprofile --norc -c", self.text)
        self.assertIn("STACK_NO_AUTO_TMUX=1", self.text)

    def test_kitty_launcher_warnings_do_not_leak_to_parent_terminal(self):
        self.assertIn('/tmp/stacki3-tui-panel.log 2>&1 &', self.text)
        self.assertIn('>/dev/null 2>&1', self.text)


if __name__ == "__main__":
    unittest.main()
