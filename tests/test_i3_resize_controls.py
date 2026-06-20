from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
I3_CONFIG = ROOT / "payload/.config/i3/config"
DESKTOP_HELP = ROOT / "payload/.config/shortcuts/pages/desktop.txt"


class I3ResizeControlsTest(unittest.TestCase):
    def setUp(self):
        self.config = I3_CONFIG.read_text()
        self.help_text = DESKTOP_HELP.read_text().lower()

    def test_tiling_windows_can_be_resized_by_mouse_without_dependencies(self):
        self.assertIn("floating_modifier $mod", self.config)
        self.assertIn("tiling_drag modifier titlebar", self.config)
        self.assertIn("win+arrastrar", self.help_text)

    def test_direct_resize_shortcuts_exist_without_entering_resize_mode(self):
        expected = [
            "bindsym $mod+Ctrl+Left  resize shrink width  10 px or 10 ppt",
            "bindsym $mod+Ctrl+Right resize grow   width  10 px or 10 ppt",
            "bindsym $mod+Ctrl+Up    resize shrink height 10 px or 10 ppt",
            "bindsym $mod+Ctrl+Down  resize grow   height 10 px or 10 ppt",
        ]
        for line in expected:
            self.assertIn(line, self.config)


if __name__ == "__main__":
    unittest.main()
