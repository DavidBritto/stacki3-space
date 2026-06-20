import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ZSHRC = ROOT / "payload/.zshrc"
FD = ROOT / "payload/.local/bin/fd"
TRY = ROOT / "payload/.local/bin/try"
DEPS = ROOT / "docs/dependencies.md"
INSTALL = ROOT / "install.sh"


class ShellToolsTest(unittest.TestCase):
    def test_fd_wrapper_maps_to_ubuntu_fdfind(self):
        text = FD.read_text()
        self.assertIn("exec fdfind", text)
        self.assertIn("fd-find", DEPS.read_text())

    def test_try_script_creates_work_tries_directory(self):
        text = TRY.read_text()
        self.assertIn("$HOME/Work/tries", text)
        self.assertIn("date +%Y-%m-%d", text)
        self.assertIn("exec ${SHELL:-bash}", text)

    def test_zsh_has_omarchy_like_shell_helpers(self):
        text = ZSHRC.read_text()
        self.assertIn("alias ff=", text)
        self.assertIn("alias lsa=", text)
        self.assertIn("alias lta=", text)
        self.assertIn("try()", text)
        self.assertIn("$HOME/Work/tries", text)

    def test_dependencies_include_omarchy_shell_tools(self):
        text = DEPS.read_text()
        for package in ["fzf", "zoxide", "ripgrep", "fd-find", "eza"]:
            self.assertIn(package, text)

    def test_installer_marks_fd_and_try_executable(self):
        text = INSTALL.read_text()
        self.assertIn('"$TARGET_HOME/.local/bin/fd"', text)
        self.assertIn('"$TARGET_HOME/.local/bin/try"', text)


if __name__ == "__main__":
    unittest.main()
