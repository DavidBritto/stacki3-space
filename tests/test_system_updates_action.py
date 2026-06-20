import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
DESKMENU = ROOT / "payload/.local/bin/deskmenu"
POLYBAR = ROOT / "payload/.config/polybar/config.ini"
DATE_UPDATES = ROOT / "payload/.config/polybar/scripts/date_updates_status.sh"
UPDATER = ROOT / "payload/.local/bin/space-system-update"
INSTALLER = ROOT / "install.sh"
DEPENDENCIES = ROOT / "docs/dependencies.md"
REMINDER_SCRIPT = ROOT / "payload/.local/bin/system-update-reminder"
REMINDER_SERVICE = ROOT / "payload/.config/systemd/user/system-update-reminder.service"
REMINDER_TIMER = ROOT / "payload/.config/systemd/user/system-update-reminder.timer"


class SystemUpdatesActionTest(unittest.TestCase):
    def test_polybar_updates_click_opens_system_menu(self):
        text = POLYBAR.read_text()
        self.assertIn("[module/date]", text)
        self.assertIn("date_updates_status.sh", text)
        script = DATE_UPDATES.read_text()
        self.assertIn('updates_cmd="__STACKI3_HOME__/.local/bin/space menu system"', script)
        self.assertNotIn("click-left = __STACKI3_HOME__/.local/bin/space-system-update", text)

    def test_system_menu_exposes_update_apps_not_reminder(self):
        text = DESKMENU.read_text()
        self.assertIn("category_label('system', 'update apps')", text)
        self.assertIn("confirm_update_apps", text)
        self.assertIn("paste_update_command", text)
        self.assertNotIn("run update reminder now", text)
        self.assertNotIn("system-update-reminder", text)

    def test_update_action_pastes_clean_apt_command_without_enter(self):
        text = DESKMENU.read_text()
        self.assertIn("sudo apt update", text)
        self.assertIn("sudo apt upgrade -y", text)
        self.assertIn("sudo apt autoremove --purge -y", text)
        self.assertIn("sudo apt autoclean", text)
        self.assertIn("xdotool", text)
        self.assertIn("ctrl+shift+v", text)
        self.assertNotIn("xdotool key Return", text)
        self.assertNotIn("xdotool key KP_Enter", text)

    def test_update_action_requires_terminal_focus(self):
        text = DESKMENU.read_text()
        self.assertIn("def active_window_class():", text)
        self.assertIn("def is_terminal_window", text)
        self.assertIn("xdotool no está instalado", text)
        self.assertIn("gnome-terminal", text)
        self.assertIn("alacritty", text)
        self.assertIn("kitty", text)


    def test_update_action_does_not_use_invalid_xdotool_class_command(self):
        text = DESKMENU.read_text()
        self.assertNotIn("getwindowclassname", text)
        self.assertIn("def focused_window_class(node):", text)
        self.assertIn("window_properties", text)

    def test_old_interactive_updater_is_not_shipped(self):
        self.assertFalse(UPDATER.exists())

    def test_legacy_update_reminder_is_not_shipped(self):
        self.assertFalse(REMINDER_SCRIPT.exists())
        self.assertFalse(REMINDER_SERVICE.exists())
        self.assertFalse(REMINDER_TIMER.exists())

    def test_installer_does_not_enable_legacy_update_reminder(self):
        text = INSTALLER.read_text()
        self.assertNotIn("system-update-reminder", text)
        self.assertNotIn("enable --now system-update-reminder.timer", text)

    def test_dependencies_document_xdotool_for_update_paste(self):
        text = DEPENDENCIES.read_text()
        self.assertIn("xdotool", text)


if __name__ == "__main__":
    unittest.main()
