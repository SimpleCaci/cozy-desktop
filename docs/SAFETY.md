# Backup, reset, and compatibility

## What changes

The default setup applies per-monitor wallpapers, Windows light/dark preferences, system icon overrides, and cursor paths. `-SkipIcons` and `-SkipCursors` omit those components. `-FolderIcons` adds the supported built-in folder icons. Automatic switching is only added with `-AutoSwitch`.

Registry writes are under **HKEY_CURRENT_USER**. The toolkit does not patch Windows system files or require machine-wide registry changes. Registry changes can still produce incorrect appearance or broken paths if assets are removed, another tool changes the same settings, or a Windows build handles an override differently. Review the scripts before running them.

Use a normal user account. The task requests limited privileges and an interactive sign-in. Administrator access is not part of the default installation; a protected custom install path may fail instead. On managed PCs, organization policies may prevent PowerShell, compilation, COM access, or task registration. Do not bypass an organization's restrictions by running the installer as administrator.

The documented `ExecutionPolicy Bypass` flag applies to the new PowerShell process. It does not permanently change execution policy, and it does not verify that a script is trustworthy. `-WhatIf` checks inputs and reports the proposed operation; it is not a full permissions check, backup, or installation test.

## What is backed up

Backups are saved in `<install folder>\.state\backup.json`. The installer does not make a Windows restore point or an image backup of your PC.

| Component | Recorded before its first change | Reset behavior |
| --- | --- | --- |
| Registry values written by the toolkit | Subkey, value name, whether the value existed, original data and registry type | Restore existing values; delete values originally absent |
| Monitor wallpapers | Monitor device ID and original wallpaper path | Reapply the recorded static wallpaper to the same connected monitor |
| Wallpaper fit | Original desktop wallpaper position/fit value | Restore that value |
| Folder icon metadata | Original `desktop.ini` bytes, whether the file existed, its attributes, and the folder attributes | Restore bytes and attributes; remove `desktop.ini` if the toolkit originally created it |
| Toolkit desktop buttons | Paths of buttons created by this installation | Delete the recorded shortcut paths |
| Optional scheduled task | Name of the task created by this installation | Disable, stop and unregister that task before restoring appearance |

Registry values are saved once, even if you switch themes repeatedly. New monitors and folders are recorded when they are first changed. Reset returns these tracked settings to their recorded baseline, including prior custom appearance. It does not select Microsoft's factory defaults.

The backup holds paths, preferences, and potentially other pre-existing `desktop.ini` metadata. Keep it private. It is excluded from Git by `.gitignore`.

## What is not restored

- Wallpaper image files are not copied into the backup. Missing originals must be put back at their saved paths.
- Slideshow configuration, playback state and progress are not captured. Select your slideshow again in Windows Settings if needed.
- Registry **key** existence is not tracked. Reset can leave empty keys after removing newly added values; this is not a byte-for-byte registry rollback.
- Manual app-shortcut icon edits, unrelated Windows settings, lock-screen appearance, browser themes and changes made by other tools are not tracked.
- Later manual edits to tracked registry values or `desktop.ini` are replaced by the original backup. Edits to a toolkit shortcut at its recorded path do not protect it from removal.
- Icon caches and every special shell view's display behavior are not backed up. You may need to reopen Explorer or sign out/in.

## If reset fails

Run `scripts/Reset.ps1` or `scripts/Restore.ps1` from the installed toolkit. Both call the same restore function.

Reset is not transactional: an error can occur after earlier components have already been restored. The backup stays in place until the restore function reaches the end successfully. Reconnect previously themed monitors, restore missing wallpaper files or folder locations, resolve the reported problem, then retry. The scheduled task may already have been removed on the first attempt.

After success, the backup is renamed to `backup.json.restored-<timestamp>`. The installed files remain. Keep that archive if you want a record; delete the installed toolkit manually only after confirming you no longer need it.

If installation fails while applying appearance, it reports the installed location and the restore command to use. Failures earlier in copying/building may leave an incomplete install folder. The installer refuses to overwrite an existing install location, task name or desktop button path. Use a new empty location for a later installation, or remove an old restored installation yourself.

## Compatibility and evidence

Intended environment: Windows 10/11 desktop sessions, Windows PowerShell 5.1, and .NET Framework 4.x. The compiler uses the Windows .NET Framework tools. The scripts also have PowerShell 7 regression coverage; the desktop launcher uses Windows PowerShell 5.1.

Known-folder paths are requested from Windows rather than assumed to be under `$HOME`. Folder symlinks/junctions and linked `desktop.ini` files are rejected. Redirected folders may still be subject to cloud availability, attributes, permissions or provider behavior. Shell icon overrides can appear differently across Windows versions and views.

The regression suite runs in both Windows PowerShell 5.1 and PowerShell 7. It
tests real disposable registry values and temporary folder metadata, while
simulating native wallpaper, cursor and shell-refresh calls. It checks boundary
times, repeated switches, first-backup preservation, registry types, exact folder
restoration, missing wallpaper paths, disconnected monitors and linked asset
rejection. CI also builds a Starter ZIP and verifies its checksum, extracted
assets, file allowlist and launcher rebuild. See the Actions run for the results
for a specific commit.

This does not certify a complete live installation/reset cycle. Real Task Scheduler lifecycle, sleep/resume behavior, all system-icon views and broader Windows 10/11 visual coverage remain in [issue 1](https://github.com/SimpleCaci/cozy-desktop/issues/1) and [issue 2](https://github.com/SimpleCaci/cozy-desktop/issues/2).
