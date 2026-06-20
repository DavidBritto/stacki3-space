import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "payload/.config/polybar/scripts/calendar_tui.sh"
POLYBAR = ROOT / "payload/.config/polybar/config.ini"
I3 = ROOT / "payload/.config/i3/config"


class CalendarTuiTest(unittest.TestCase):
    def test_date_module_click_opens_calendar_tui(self):
        text = (ROOT / "payload/.config/polybar/scripts/date_updates_status.sh").read_text()
        self.assertIn('calendar_cmd="__STACKI3_HOME__/.config/polybar/scripts/calendar_tui.sh"', text)
        self.assertIn('%{A1:%s:}', text)

    def test_calendar_tui_has_dependency_free_python_fallback(self):
        text = SCRIPT.read_text()
        self.assertIn("python3 - <<", text)
        self.assertIn("PY", text)
        self.assertIn("import calendar", text)
        self.assertIn("calendar.month", text)
        self.assertIn("Press q to close", text)

    def test_calendar_tui_uses_compact_space_terminal(self):
        text = SCRIPT.read_text()
        self.assertIn("--class stack-calendar-panel", text)
        self.assertIn('--title "Space Calendar"', text)
        self.assertIn("--override initial_window_width=24c", text)
        self.assertIn("--override initial_window_height=10c", text)
        self.assertIn("--override background=#000000", text)
        self.assertIn('\\033]11;#000000', text)
        self.assertNotIn("initial_window_width=34c", text)
        self.assertNotIn("resize set 360 220", text)

    def test_calendar_reuses_existing_panel_before_spawning(self):
        text = SCRIPT.read_text()
        self.assertIn("calendar_exists()", text)
        self.assertIn("position_calendar_popover", text)
        self.assertIn("if calendar_exists; then", text)

    def test_calendar_positions_as_top_center_popover_below_polybar(self):
        text = SCRIPT.read_text()
        self.assertIn("position_calendar_popover()", text)
        self.assertIn('local reveal="${1:-no}"', text)
        self.assertIn("polybar_gap=12", text)
        self.assertIn("for _ in {1..20}; do", text)
        self.assertIn("sleep 0.1", text)
        self.assertIn("subprocess.check_output(['i3-msg', '-t', kind]", text)
        self.assertIn("load_i3('get_tree')", text)
        self.assertIn("load_i3('get_workspaces')", text)
        self.assertIn("move position", text)
        self.assertIn("scratchpad show", text)
        self.assertIn("position_calendar_popover reveal", text)
        self.assertNotIn("move position center", text)

    def test_calendar_copies_dunst_style_tokens(self):
        text = SCRIPT.read_text()
        self.assertIn("--override background=#000000", text)
        self.assertIn("--override foreground=#d7e0ff", text)
        self.assertIn("--override color1=#7c5cff", text)
        self.assertIn("--override color6=#67c9e4", text)
        self.assertIn("--override window_padding_width=14", text)
        self.assertIn("--override active_window_border_color=#7c5cff", text)

    def test_calendar_panel_has_dedicated_i3_rule(self):
        text = I3.read_text()
        self.assertIn('for_window [class="stack-calendar-panel"] floating enable, move scratchpad', text)
        self.assertNotIn('for_window [class="stack-calendar-panel"] floating enable, move position center', text)
        self.assertNotIn('for_window [class="stack-calendar-panel"] floating enable, resize set', text)
        self.assertNotIn('for_window [title="Calendar Mini"] floating enable, resize set 980 620', text)


if __name__ == "__main__":
    unittest.main()
