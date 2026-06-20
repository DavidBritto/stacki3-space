from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
HELPER = ROOT / "payload/.local/bin/polkit-agent-oceano"
SETTINGS = ROOT / "payload/.config/polkit-oceano/gtk-3.0/settings.ini"
CSS = ROOT / "payload/.config/polkit-oceano/gtk-3.0/gtk.css"
TRANSITION = ROOT / "docs/tui-auth-transition.md"


class PolkitStackStyleTest(unittest.TestCase):
    def test_polkit_agent_uses_stack_theme_environment(self):
        text = HELPER.read_text()
        self.assertIn('XDG_CONFIG_HOME="${HOME}/.config/polkit-oceano"', text)
        self.assertIn('GTK_THEME="StackPolkit"', text)
        self.assertIn("polkit-gnome-authentication-agent-1", text)
        self.assertNotIn("Breeze-Dark", text)

    def test_polkit_gtk_settings_are_dark_and_stack_aligned(self):
        text = SETTINGS.read_text()
        self.assertIn("gtk-application-prefer-dark-theme=true", text)
        self.assertIn("gtk-theme-name=StackPolkit", text)
        self.assertIn("gtk-font-name=Berkeley Mono 11", text)
        self.assertIn("gtk-decoration-layout=", text)
        self.assertNotIn("CrewDragon-Y", text)

    def test_polkit_css_copies_dunst_tokens(self):
        text = CSS.read_text()
        for token in ["#000000", "#d7e0ff", "#7c5cff", "#67c9e4"]:
            self.assertIn(token, text)
        self.assertIn("border-radius: 0", text)
        self.assertIn("box-shadow: none", text)

    def test_tui_auth_transition_doc_exists(self):
        text = TRANSITION.read_text()
        self.assertIn("# TUI auth transition", text)
        self.assertIn("Polkit remains the compatibility fallback", text)
        self.assertIn("Rofi → Kitty/TUI → explicit command", text)


if __name__ == "__main__":
    unittest.main()
