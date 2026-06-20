import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INSTALLER = ROOT / "install.sh"
README = ROOT / "README.md"
NEW_MACHINE = ROOT / "docs/new-machine-install.md"


class ZshrcPreservationTest(unittest.TestCase):
    def test_installer_preserves_existing_zshrc_by_default(self):
        text = INSTALLER.read_text()
        self.assertIn("STACKI3_SPACE_OVERWRITE_ZSHRC", text)
        self.assertIn("--exclude='.zshrc'", text)
        self.assertIn("ensure_zsh_line", text)

    def test_docs_explain_zshrc_overwrite_escape_hatch(self):
        for path in [README, NEW_MACHINE]:
            text = path.read_text()
            self.assertIn("STACKI3_SPACE_OVERWRITE_ZSHRC=1 bash install.sh", text)

    def test_install_docs_include_full_deps_flow(self):
        installer = INSTALLER.read_text()
        self.assertIn("--deps|--install-deps|--full", installer)
        self.assertIn('scripts/install-dependencies.sh" --apply', installer)

        for path in [README, NEW_MACHINE]:
            text = path.read_text()
            self.assertIn("bash install.sh --deps", text)


if __name__ == "__main__":
    unittest.main()
