import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
WRAPPER = ROOT / "bin/stacki3-space"
CONTROL = ROOT / "debian/control"
INSTALL = ROOT / "debian/install"
CHANGELOG = ROOT / "debian/changelog"
VERSION = ROOT / "VERSION"


class DebianPackageTest(unittest.TestCase):
    def test_package_installs_payload_under_usr_share(self):
        install = INSTALL.read_text()

        self.assertIn("payload usr/share/stacki3-space/", install)
        self.assertIn("scripts usr/share/stacki3-space/", install)
        self.assertIn("install.sh usr/share/stacki3-space/", install)
        self.assertIn("bin/stacki3-space usr/bin/", install)

    def test_control_keeps_desktop_apps_as_recommendations(self):
        control = CONTROL.read_text()

        self.assertIn("Package: stacki3-space", control)
        self.assertIn("Architecture: all", control)
        self.assertIn("rsync", control)
        self.assertIn("Recommends:", control)
        self.assertIn("i3-wm", control)
        self.assertIn("polybar", control)
        self.assertIn("apt\n upgrades do not overwrite files in $HOME automatically", control)

    def test_version_file_matches_debian_changelog(self):
        version = VERSION.read_text().strip()
        changelog = CHANGELOG.read_text()

        self.assertIn(f"stacki3-space ({version})", changelog)

    def test_wrapper_help_documents_explicit_apply(self):
        proc = subprocess.run(
            ["bash", str(WRAPPER), "help"],
            text=True,
            capture_output=True,
            check=True,
        )

        self.assertIn("stacki3-space apply [--deps]", proc.stdout)
        self.assertIn("apt upgrades only update", proc.stdout)

    def test_wrapper_apply_delegates_to_packaged_installer(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            installer = root / "install.sh"
            installer.write_text("#!/usr/bin/env bash\nprintf 'installer:%s\\n' \"$*\"\n")

            proc = subprocess.run(
                ["bash", str(WRAPPER), "apply", "--deps"],
                env={"STACKI3_SPACE_ROOT": str(root)},
                text=True,
                capture_output=True,
                check=True,
            )

        self.assertEqual("installer:--deps\n", proc.stdout)


if __name__ == "__main__":
    unittest.main()
