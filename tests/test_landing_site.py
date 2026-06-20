import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SITE_INDEX = ROOT / "site/index.html"
SITE_STYLES = ROOT / "site/styles.css"
WORKFLOW = ROOT / ".github/workflows/apt-package.yml"


class LandingSiteTest(unittest.TestCase):
    def test_landing_has_core_positioning_and_install_flow(self):
        html = SITE_INDEX.read_text()

        self.assertIn("STACKI3-Space", html)
        self.assertIn("i3/X11 keyboard-first", html)
        self.assertIn("Omarchy-like", html)
        self.assertIn("sin GPU dedicada", html)
        self.assertIn("sudo apt install stacki3-space", html)
        self.assertIn("stacki3-space apply --deps", html)
        self.assertIn("sudo apt update && sudo apt upgrade", html)
        self.assertIn("https://github.com/DavidBritto", html)

    def test_landing_uses_local_css_only(self):
        html = SITE_INDEX.read_text()
        css = SITE_STYLES.read_text()

        self.assertIn('href="./styles.css"', html)
        self.assertIn("--bg:", css)
        self.assertIn("--bg: #000000", css)
        self.assertIn("background: #000000", css)
        self.assertIn("--green:", css)
        self.assertNotIn("https://fonts.googleapis.com", html)

    def test_pages_workflow_publishes_landing_with_apt_repo(self):
        workflow = WORKFLOW.read_text()

        self.assertIn("Build APT repository", workflow)
        self.assertIn("cp -a site/. dist/apt-repo/", workflow)
        self.assertIn("actions/upload-pages-artifact", workflow)


if __name__ == "__main__":
    unittest.main()
