# Bring your own cozy

1. Copy `themes/sunbeam-kitty` to a new folder such as `themes/my-theme`.
2. Replace the four PNG wallpapers, icon ICO files and cursor CUR/ANI files. Keep both orientations for both times of day.
3. Edit `theme.json`: `Wallpapers` maps Day/Night and landscape/portrait to relative file paths. `SystemIcons` maps shell class GUIDs to their default/empty/full icon files. The Recycle Bin needs its empty and full states.
4. Edit `cursors/manifest.json` to map the 17 Windows role names to files. The `file` field is used by the installer; hotspot/frame/size fields document the source assets. Preserve working hotspots in your actual CUR/ANI exports.
5. Set `Theme` in the root `config.json` to your folder name. Folder names may contain letters, digits, underscores and hyphens. Set different integer DayStartHour/NightStartHour values from 0 to 23. Overnight day ranges are supported.
6. Run `tests/Test.ps1` and preview `Install.ps1 -WhatIf`, then install. Restore an existing installation before testing a replacement.

All asset paths must stay within the theme folder; symbolic links and junctions
inside it are rejected. The folder icon command looks for `icons/<name>.ico`.
Both the launcher build and desktop shortcuts use `icons/day-night-toggle.ico`
from the selected theme, so include that file.

`starter` is a complete source-drawn example and the theme included in release
ZIPs. `sunbeam-kitty` is retained in the source repository with an unresolved
reference history; do not use it as a redistribution example until its permission
is established. See [notices](../THIRD_PARTY_NOTICES.md).

Keep private data, generated backups and machine-specific paths out of your theme. Include the provenance and license for any assets you contribute. Test new themes on your own PC before recommending them to others.
