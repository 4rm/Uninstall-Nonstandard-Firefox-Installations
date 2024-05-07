# Uninstall-Nonstandard-Firefox-Installations
Remove copies of Firefox that were installed to a user's `AppData` folder (Windows) or outside of `\Applications` (macOS)

## Windows
Firefox can be installed without administrative privileges, placing it in a user's `AppData` folder instead of `Program Files`. If `helper.exe` is called to uninstall by a user other than the user that installed the software (e.g. `SYSTEM` from your endpoint management program of choise), the files will be deleted but the registry key in `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\` is left behind. Some vulnerability scanning software (e.g. Rapid7 InsightVM) detects these keys as installations, which is very annoying.

This script will call run `helper.exe -ms` for each `AppData` installation of Firefox, and then load the registry for each user and delete the keys.
