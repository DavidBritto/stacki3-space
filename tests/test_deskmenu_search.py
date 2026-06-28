import importlib.util
from importlib.machinery import SourceFileLoader
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DESKMENU = ROOT / "payload/.local/bin/deskmenu"

loader = SourceFileLoader("deskmenu", str(DESKMENU))
spec = importlib.util.spec_from_loader(loader.name, loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)


class DeskmenuSearchTest(unittest.TestCase):
    def test_static_catalog_contains_core_actions(self):
        actions = mod.static_search_actions()
        labels = [a["label"] for a in actions]
        self.assertIn("󰍜 system · reload i3", labels)
        self.assertIn("󰓩 bar · restart polybar", labels)
        self.assertIn("󰍜 System · Monitor", labels)
        self.assertIn("󰾆 compositor · restart picom", labels)
        self.assertIn("󰂚 notify · restart dunst", labels)


    def test_static_search_contains_only_final_actions_not_submenu_hops(self):
        labels = [a["label"] for a in mod.static_search_actions()]
        joined = "\n".join(labels)
        self.assertNotIn("open menu", joined)
        self.assertNotIn("current theme", joined)
        self.assertNotIn("list themes", joined)

    def test_static_search_exposes_actionable_audio_shortcuts(self):
        labels = [a["label"] for a in mod.static_search_actions()]
        self.assertIn("󰕾 audio · toggle mic mute", labels)
        self.assertIn("󰕾 audio · open mixer panel", labels)

    def test_catalog_action_for_theme_apply_runs_stack_theme(self):
        actions = {a["label"]: a for a in mod.static_search_actions()}
        for name, _display in mod.iter_stack_themes():
            label = mod.category_label('theme', f'apply {name}')
            self.assertIn(label, actions, msg=f'missing search action for theme {name}')
            self.assertEqual(actions[label]["command"][-2:], ["apply", name])
            self.assertTrue(actions[label]["command"][0].endswith("stack-theme"))

    def test_system_menu_exposes_theme_submenu(self):
        source = DESKMENU.read_text()
        self.assertIn("category_label('theme', 'themes')", source)
        self.assertIn("def menu_themes", source)
        self.assertIn("theme_apply_actions", source)

    def test_back_copy_is_minimal_and_vim_like(self):
        self.assertEqual(mod.BACK_LABEL, "← volver")
        self.assertEqual(mod.BACK_MESSAGE, "<- volver")
        source = DESKMENU.read_text()
        self.assertNotIn("Selecciona [← volver] para regresar", source)
        self.assertNotIn("[← volver]", source)

    def test_system_menu_uses_category_glyphs(self):
        source = DESKMENU.read_text()
        self.assertIn("category_label('system', 'reload i3')", source)
        self.assertIn("category_label('bar', 'restart polybar')", source)
        self.assertIn("category_label('notify', 'restart dunst')", source)
        self.assertIn("category_label('compositor', 'restart picom')", source)


if __name__ == "__main__":
    unittest.main()
