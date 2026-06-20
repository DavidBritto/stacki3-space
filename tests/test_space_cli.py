import importlib.util
from importlib.machinery import SourceFileLoader
import os
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SPACE = ROOT / "payload/.local/bin/space"


def load_space():
    loader = SourceFileLoader("space_cli", str(SPACE))
    spec = importlib.util.spec_from_loader(loader.name, loader)
    mod = importlib.util.module_from_spec(spec)
    loader.exec_module(mod)
    return mod


class SpaceCliTest(unittest.TestCase):
    def test_space_script_exists_in_payload(self):
        self.assertTrue(SPACE.exists(), "payload/.local/bin/space should exist")

    def test_theme_commands_delegate_to_existing_stack_theme(self):
        mod = load_space()
        self.assertEqual(mod.build_command(["theme", "list"]), [str(Path.home() / ".local/bin/stack-theme"), "list"])
        self.assertEqual(mod.build_command(["theme", "apply", "deep-space"]), [str(Path.home() / ".local/bin/stack-theme"), "apply", "deep-space"])

    def test_wall_commands_delegate_to_existing_stack_wall(self):
        mod = load_space()
        self.assertEqual(mod.build_command(["wall", "next"]), [str(Path.home() / ".local/bin/stack-wall"), "next"])
        self.assertEqual(mod.build_command(["wall", "apply", "/tmp/wall.png"]), [str(Path.home() / ".local/bin/stack-wall"), "apply", "/tmp/wall.png"])

    def test_search_and_menu_delegate_to_deskmenu(self):
        mod = load_space()
        deskmenu = str(Path.home() / ".local/bin/deskmenu")
        self.assertEqual(mod.build_command(["menu"]), [deskmenu, "palette"])
        self.assertEqual(mod.build_command(["search"]), [deskmenu, "search"])

    def test_dry_run_prints_command_without_executing(self):
        proc = subprocess.run(
            ["python3", str(SPACE), "--dry-run", "bar", "restart"],
            text=True,
            capture_output=True,
            check=True,
        )
        self.assertIn(".config/polybar/launch.sh", proc.stdout)


if __name__ == "__main__":
    unittest.main()
