import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
POLYBAR = ROOT / "payload/.config/polybar/config.ini"
DATE_UPDATES = ROOT / "payload/.config/polybar/scripts/date_updates_status.sh"
VOLUME_STATUS = ROOT / "payload/.config/polybar/scripts/volume_status.sh"
COLORS_GENERATED = ROOT / "payload/.config/polybar/colors-generated.ini"


class PolybarSpaceModulesTest(unittest.TestCase):
    def setUp(self):
        self.text = POLYBAR.read_text()

    def test_bar_has_quiet_status_modules_without_network_or_music_noise(self):
        self.assertIn("modules-right = ram cpu bluetooth volume power", self.text)
        self.assertIn("modules-center = date", self.text)
        self.assertNotIn("[module/music]", self.text)
        self.assertNotIn("music_status.sh", self.text)
        self.assertIn("[module/date]", self.text)
        self.assertIn("[module/bluetooth]", self.text)
        self.assertNotIn("[module/updates]", self.text)
        self.assertNotIn("[module/net]", self.text)
        self.assertNotIn("network_status.sh", self.text)

    def test_bar_clicks_use_space_cli(self):
        self.assertIn("click-left = __STACKI3_SPACE_HOME__/.local/bin/space menu panels", self.text)
        script = DATE_UPDATES.read_text()
        self.assertIn('calendar_cmd="__STACKI3_SPACE_HOME__/.config/polybar/scripts/calendar_tui.sh"', script)
        self.assertNotIn("click-left = __STACKI3_SPACE_HOME__/.local/bin/space menu network", self.text)

    def test_updates_indicator_is_embedded_in_date_module(self):
        self.assertIn("exec = __STACKI3_SPACE_HOME__/.config/polybar/scripts/date_updates_status.sh", self.text)
        script = DATE_UPDATES.read_text()
        self.assertIn('updates_cmd="__STACKI3_SPACE_HOME__/.local/bin/space menu system"', script)
        self.assertIn('%{F#7c5cff}', script)

    def test_updates_status_hides_zero_and_shows_icon_when_nonzero(self):
        script = DATE_UPDATES.read_text()
        self.assertIn('if [ "${count:-0}" != "0" ]; then', script)
        self.assertIn("printf '\\n'", script)
        self.assertIn("↻", script)
        self.assertNotIn("UPD %s |", script)

    def test_date_module_embeds_battery_status_when_present(self):
        script = DATE_UPDATES.read_text()
        self.assertIn("__STACKI3_SPACE_HOME__/.config/polybar/scripts/battery_status.sh", script)
        self.assertIn('if [ -n "$battery_label" ]; then', script)

    def test_volume_slider_reads_generated_theme_colors(self):
        script = VOLUME_STATUS.read_text()
        colors = COLORS_GENERATED.read_text()

        self.assertIn('colors_file="$HOME/.config/polybar/colors-generated.ini"', script)
        self.assertIn('/^primary = /', script)
        self.assertIn('/^dim = /', script)
        self.assertIn('/^white = /', script)
        self.assertNotIn('%{F#ffffff}│', script)
        self.assertIn("dim = #444b6f", colors)
        self.assertIn("white = #ffffff", colors)


if __name__ == "__main__":
    unittest.main()
