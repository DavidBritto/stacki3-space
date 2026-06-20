import importlib.util
from importlib.machinery import SourceFileLoader
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPACE = ROOT / "payload/.local/bin/space"
DESKMENU = ROOT / "payload/.local/bin/deskmenu"
TUI_PANEL = ROOT / "payload/.local/bin/tui-panel"
ROFI_FILES = ROOT / "payload/.local/bin/rofi-files"
STACK = ROOT / "stack.md"


def load_module(path, name):
    loader = SourceFileLoader(name, str(path))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    mod = importlib.util.module_from_spec(spec)
    loader.exec_module(mod)
    return mod


class TuiFileManagerTest(unittest.TestCase):
    def test_space_files_command_opens_yazi_panel(self):
        mod = load_module(SPACE, "space_for_files")
        self.assertEqual(mod.build_command(["files"]), [str(Path.home() / ".local/bin/tui-panel"), "files-yazi"])

    def test_deskmenu_exposes_file_manager_as_final_action(self):
        mod = load_module(DESKMENU, "deskmenu_for_files")
        labels = [a["label"] for a in mod.static_search_actions()]
        self.assertIn("󰉋 Files · Yazi", labels)
        source = DESKMENU.read_text()
        self.assertIn("category_label('files', 'files')", source)
        self.assertIn("'files': menu_files", source)

    def test_tui_panel_wraps_yazi_with_dedicated_surface(self):
        text = TUI_PANEL.read_text()
        self.assertIn("files-yazi)", text)
        self.assertIn('title="TUI: files · yazi"', text)
        self.assertIn('window_class="stack-files-panel"', text)

    def test_rofi_files_uses_yazi_for_directory_targets(self):
        text = ROFI_FILES.read_text()
        self.assertIn("stack-files-panel", text)
        self.assertIn("exec yazi", text)

    def test_stack_documents_yazi_direct_and_optional_launcher_usage(self):
        text = STACK.read_text()
        self.assertIn("File manager in terminal flow:** Yazi", text)
        self.assertIn("Yazi is the canonical file manager", text)
        self.assertIn("space files", text)
        self.assertNotIn("Experimental file manager:** lf", text)


if __name__ == "__main__":
    unittest.main()
