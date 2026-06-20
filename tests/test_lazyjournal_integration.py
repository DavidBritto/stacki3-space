import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DESKMENU = ROOT / "payload/.local/bin/deskmenu"
TUI_PANEL = ROOT / "payload/.local/bin/tui-panel"
ZSHRC = ROOT / "payload/.zshrc"
INSTALLER = ROOT / "scripts/install-lazyjournal.sh"
VERIFY = ROOT / "scripts/verify-install.sh"
DEPS = ROOT / "docs/dependencies.md"
NEW_MACHINE = ROOT / "docs/new-machine-install.md"
STACK = ROOT / "stack.md"


class LazyjournalIntegrationTest(unittest.TestCase):
    def test_panel_menu_exposes_lazyjournal(self):
        text = DESKMENU.read_text()
        self.assertIn("Logs · Lazyjournal", text)
        self.assertIn("'lazyjournal'", text)

    def test_tui_panel_wraps_lazyjournal(self):
        text = TUI_PANEL.read_text()
        self.assertIn("lazyjournal|logs)", text)
        self.assertIn('title="TUI: logs · lazyjournal"', text)
        self.assertIn("exec lazyjournal", text)

    def test_install_script_uses_upstream_user_local_installer(self):
        text = INSTALLER.read_text()
        self.assertIn("https://raw.githubusercontent.com/Lifailon/lazyjournal/main/scripts/install.sh", text)
        self.assertIn("~/.local/bin/lazyjournal", text)

    def test_docs_and_verifier_include_lazyjournal(self):
        self.assertIn("lazyjournal", VERIFY.read_text())
        self.assertIn("scripts/install-lazyjournal.sh", DEPS.read_text())
        self.assertIn("scripts/install-lazyjournal.sh", NEW_MACHINE.read_text())
        self.assertIn("Logs TUI:** lazyjournal", STACK.read_text())

    def test_shell_alias_is_available_when_installed(self):
        text = ZSHRC.read_text()
        self.assertIn("alias lj='lazyjournal'", text)


if __name__ == "__main__":
    unittest.main()
