import importlib.util
from importlib.machinery import SourceFileLoader
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DESKMENU = ROOT / "payload/.local/bin/deskmenu"

loader = SourceFileLoader("deskmenu_audio", str(DESKMENU))
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)


class AudioMenuTest(unittest.TestCase):
    def test_audio_menu_is_small_and_actionable_from_polybar_volume(self):
        self.assertEqual(
            mod.audio_menu_entries(),
            [
                "open mixer panel",
                "toggle mute",
                "volume up",
                "volume down",
                "toggle mic mute",
            ],
        )

    def test_audio_menu_has_no_sink_picker_dead_end(self):
        self.assertNotIn("choose output sink", mod.audio_menu_entries())


if __name__ == "__main__":
    unittest.main()
