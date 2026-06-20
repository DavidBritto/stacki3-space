import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
I3 = ROOT / "payload/.config/i3/config"


class I3SpaceBindingsTest(unittest.TestCase):
    def setUp(self):
        self.text = I3.read_text()

    def test_mod_p_opens_space_search(self):
        self.assertIn("bindsym $mod+p exec --no-startup-id ~/.local/bin/space search", self.text)

    def test_existing_project_and_panel_bindings_remain(self):
        self.assertIn("bindsym $mod+Shift+p exec --no-startup-id ~/.local/bin/space menu projects", self.text)
        self.assertIn("bindsym $mod+grave exec --no-startup-id ~/.local/bin/space menu panels", self.text)


if __name__ == "__main__":
    unittest.main()
