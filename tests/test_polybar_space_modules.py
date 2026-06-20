import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
POLYBAR = ROOT / "payload/.config/polybar/config.ini"
DATE_UPDATES = ROOT / "payload/.config/polybar/scripts/date_updates_status.sh"


class PolybarSpaceModulesTest(unittest.TestCase):
    def setUp(self):
        self.text = POLYBAR.read_text()

    def test_bar_has_quiet_status_modules_without_network_or_music_noise(self):
        self.assertIn("modules-right = ram cpu volume power", self.text)
        self.assertIn("modules-center = date", self.text)
        self.assertNotIn("[module/music]", self.text)
        self.assertNotIn("music_status.sh", self.text)
        self.assertIn("[module/date]", self.text)
        self.assertNotIn("[module/updates]", self.text)
        self.assertNotIn("[module/net]", self.text)
        self.assertNotIn("network_status.sh", self.text)

    def test_bar_clicks_use_space_cli(self):
        self.assertIn("click-left = __STACKI3_HOME__/.local/bin/space menu panels", self.text)
        script = DATE_UPDATES.read_text()
        self.assertIn('calendar_cmd="__STACKI3_HOME__/.config/polybar/scripts/calendar_tui.sh"', script)
        self.assertNotIn("click-left = __STACKI3_HOME__/.local/bin/space menu network", self.text)

    def test_updates_indicator_is_embedded_in_date_module(self):
        self.assertIn("exec = __STACKI3_HOME__/.config/polybar/scripts/date_updates_status.sh", self.text)
        script = DATE_UPDATES.read_text()
        self.assertIn('updates_cmd="__STACKI3_HOME__/.local/bin/space menu system"', script)
        self.assertIn('%{F#7c5cff}', script)

    def test_updates_status_hides_zero_and_shows_icon_when_nonzero(self):
        script = DATE_UPDATES.read_text()
        self.assertIn('if [ "${count:-0}" != "0" ]; then', script)
        self.assertIn("printf '\\n'", script)
        self.assertIn("↻", script)
        self.assertNotIn("UPD %s |", script)


if __name__ == "__main__":
    unittest.main()
