import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PAYLOAD = ROOT / "payload"
INSTALLER = ROOT / "install.sh"
PACKAGE = ROOT / "scripts/package.sh"
README = ROOT / "README.md"
PACKAGE_LINK = ROOT / "PACKAGE_LINK.txt"


class OfflinePackageTest(unittest.TestCase):
    def test_payload_does_not_ship_local_home_paths(self):
        offenders = []
        for path in PAYLOAD.rglob("*"):
            if path.is_file():
                if "__pycache__" in path.parts or path.suffix == ".pyc":
                    continue
                data = path.read_bytes()
                if b"/home/david" in data:
                    offenders.append(path.relative_to(ROOT).as_posix())

        self.assertEqual([], offenders)

    def test_installer_replaces_home_placeholders(self):
        text = INSTALLER.read_text()
        self.assertIn("replace_home_placeholders", text)
        self.assertIn("__STACKI3_SPACE_HOME__", text)
        self.assertIn('sed -i "s#__STACKI3_SPACE_HOME__#$escaped_home#g"', text)

    def test_package_script_uses_explicit_manifest(self):
        text = PACKAGE.read_text()
        self.assertIn('"$ROOT/install.sh"', text)
        self.assertIn('"$ROOT/payload"', text)
        self.assertIn("__pycache__", text)
        self.assertIn("*.pyc", text)
        self.assertNotIn("-czf \"$ARCHIVE\" \\\n  .", text)

    def test_docs_explain_scp_tarball_flow(self):
        for path in [README, PACKAGE_LINK]:
            text = path.read_text()
            self.assertIn("scp dist/stacki3-space-package.tar.gz", text)
            self.assertIn("bash install.sh --deps", text)

    def test_package_does_not_install_or_configure_cursor_app(self):
        packaged_roots = [
            ROOT / "install.sh",
            ROOT / "README.md",
            ROOT / "stack.md",
            ROOT / "docs",
            ROOT / "scripts",
            ROOT / "payload",
        ]
        forbidden = [
            "Gentle AI",
            "gentle-ai",
            ".config/Cursor",
            "apply_cursor",
            "cursor_colors",
            "· cursor",
            "['cursor'",
            '"cursor":',
        ]
        offenders = []
        for root in packaged_roots:
            paths = [root] if root.is_file() else [p for p in root.rglob("*") if p.is_file()]
            for path in paths:
                text = path.read_text(errors="ignore")
                for needle in forbidden:
                    if needle in text:
                        offenders.append(f"{path.relative_to(ROOT).as_posix()}: {needle}")

        self.assertEqual([], offenders)


if __name__ == "__main__":
    unittest.main()
