import importlib.util
from importlib.machinery import SourceFileLoader
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DESKMENU = ROOT / "payload/.local/bin/deskmenu"


def load_deskmenu():
    loader = SourceFileLoader("deskmenu_panels", str(DESKMENU))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    mod = importlib.util.module_from_spec(spec)
    loader.exec_module(mod)
    return mod


class SpacePanelsNavigationTest(unittest.TestCase):
    def test_panels_menu_uses_human_final_action_labels(self):
        mod = load_deskmenu()
        labels = [label for label, _panel in mod.panel_menu_entries()]
        self.assertEqual(
            labels,
            [
                "󰉋 Files · Yazi",
                "󰍜 System · Monitor",
                "󰍜 Logs · Lazyjournal",
                "󰊢 Git · Lazygit",
                "󰕾 Audio · Mixer",
                "󰖩 Network · Nmtui",
                "󰅌 Clipboard · History",
                "󰓝 Notes · Quick notes",
            ],
        )

    def test_panels_menu_hides_internal_panel_ids_from_users(self):
        mod = load_deskmenu()
        labels = [label for label, _panel in mod.panel_menu_entries()]
        visible = "\n".join(labels)
        for internal in ["audio-mixer", "network-tui", "clipboard-view", "quick-notes", "files-yazi", "lazyjournal"]:
            self.assertNotIn(internal, visible)


if __name__ == "__main__":
    unittest.main()
