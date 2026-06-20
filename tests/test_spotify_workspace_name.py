import importlib.util
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / 'payload/.config/i3/spotify_workspace_name.py'
spec = importlib.util.spec_from_file_location('spotify_workspace_name', SCRIPT)
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)


class SpotifyWorkspaceNameTest(unittest.TestCase):
    def test_track_label_prefers_title_and_artist_truncated(self):
        label = mod.workspace_label({'title': 'A Very Long Track Name That Keeps Going', 'artist': 'Artist Name'}, limit=24)
        self.assertTrue(label.startswith('9: A Very Long Track'))
        self.assertTrue(label.endswith('♪'))
        self.assertLessEqual(len(label), 24)

    def test_track_label_uses_spotify_when_offline(self):
        self.assertEqual(mod.workspace_label({'available': False}, limit=24), '9:spotify ♪')

    def test_i3_rename_command_quotes_label(self):
        self.assertEqual(
            mod.rename_command('9: AC/DC "Live" ♪', '9'),
            'rename workspace "9" to "9: AC/DC \\"Live\\" ♪"',
        )


if __name__ == '__main__':
    unittest.main()
