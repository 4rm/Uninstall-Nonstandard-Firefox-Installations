# Uninstall-Nonstandard-Firefox-Installations
Remove copies of Firefox that were installed to a user's `AppData` folder (Windows) or outside of `\Applications` (macOS). User profiles and other data are left behind to maintain continuity for users switching from non-standard to standard installations. 

## Windows (foxHound.ps1)
Firefox can be installed without administrative privileges, placing it in a user's `AppData` folder instead of `Program Files`. If `helper.exe` is called to uninstall Firefox by a user that isn't the original installer (e.g. `SYSTEM`), the files will be deleted but the registry keys in `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\` are left behind. This is a [known issue](https://bugzilla.mozilla.org/show_bug.cgi?id=1895327). Some vulnerability scanning software (e.g. Rapid7 InsightVM) detects these keys as installations, which triggers false positives.

This script will call run `helper.exe -ms` for each `AppData` installation of Firefox, and then load the registry for each user and delete the keys.

## Mac (foxHound.sh)
`Firefox.app` can be dragged to custom folders by a non-admin user after downloading the `.dmg`. This script uses Spotlight search to find copies anywhere other than `/Applications/Firefox.app` and delete them. Once complete, it searches users' Trash and deletes copies of `Firefox.app` from there as well. Script should be run as `root` to capture copies in other all profiles.
