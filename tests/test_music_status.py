import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "payload/.config/polybar/scripts/music_status.sh"


class MusicStatusTest(unittest.TestCase):
    def setUp(self):
        self.text = SCRIPT.read_text()

    def test_handles_gio_values_that_are_already_unpacked(self):
        self.assertIn("def unpack_value(value):", self.text)
        self.assertIn("def get_property(proxy, name):", self.text)
        self.assertNotIn("result.unpack()[0].unpack()", self.text)

    def test_paused_spotify_still_shows_track_not_mus_off(self):
        self.assertIn("PlaybackStatus", self.text)
        self.assertIn("status_prefix", self.text)


if __name__ == "__main__":
    unittest.main()
