import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TUI_PANEL = ROOT / "payload/.local/bin/tui-panel"
STACK_TERMINAL = ROOT / "payload/.local/bin/stack-terminal"
KITTY_PANEL = ROOT / "payload/.config/kitty/panel.conf"


class TuiPanelTerminalChoiceTest(unittest.TestCase):
    def setUp(self):
        self.text = TUI_PANEL.read_text()

    def test_panels_use_stack_terminal_themed_surface(self):
        self.assertIn('stack-terminal" panel', self.text)
        self.assertIn('--class "$window_class"', self.text)
        self.assertIn("--title \"$title\"", self.text)

    def test_stack_terminal_panel_profile_exists(self):
        self.assertTrue(STACK_TERMINAL.exists())
        panel = KITTY_PANEL.read_text()
        self.assertIn("include kitty.conf", panel)
        self.assertIn("scrollback_lines      0", panel)
        self.assertIn("remember_window_size  no", panel)

    def test_nmtui_keeps_shell_and_tmux_disabled(self):
        self.assertIn("bash --noprofile --norc -c", self.text)
        self.assertIn("STACK_NO_AUTO_TMUX=1", self.text)

    def test_kitty_launcher_warnings_do_not_leak_to_parent_terminal(self):
        self.assertIn('/tmp/stacki3-space-tui-panel.log 2>&1 &', self.text)
        self.assertIn('>/dev/null 2>&1', self.text)


if __name__ == "__main__":
    unittest.main()
