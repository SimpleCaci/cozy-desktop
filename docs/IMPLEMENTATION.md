# Implementation notes

## Switching without a resident helper

`src/Launcher.cs` validates the requested mode, starts the installed `Set-Theme.ps1` in a separate Windows PowerShell process, waits for completion, and exits. An error is shown in a message box. Automatic switching uses a per-user scheduled task at sign-in and the two configured local-clock hours.

This describes the process lifecycle, not a measured performance advantage. There are no published CPU/RAM measurements or gaming benchmarks. The launcher, PowerShell, Windows services, wallpaper storage and icon caches still use resources.

## Working with Windows appearance settings

There is no single configuration object in this implementation that covers every component. `src/DesktopWallpaper.cs` wraps `IDesktopWallpaper` for monitor detection, per-monitor wallpaper changes and fit mode. The module writes current-user shell icon/cursor preferences and reloads them through native APIs. Folder icons use `desktop.ini` and folder/file attributes. Windows supplies the actual known-folder paths.

These interfaces have different failure modes. A wallpaper can be missing, a monitor can be disconnected, a folder can have existing localized metadata, or Explorer can continue showing a cached icon. The installer does not force-close Explorer or treat every icon view as verified. Current system-icon mappings are implementation support, with visual compatibility still tracked in issues.

## Keeping an undo path

`Set-CozyRegistry` records a value's original data, type and existence before the first write. Folder changes preserve the original `desktop.ini` bytes and attributes. Repeated switches keep the first baseline. The state file is updated through a temporary file and atomic replacement when a previous state exists.

The restore function first removes future scheduled writers, then restores registry values, folders and monitor wallpaper state. It archives the backup only after reaching the end. A missing original file or disconnected monitor keeps the backup available for retry. Restore is not an all-or-nothing transaction; earlier steps may already have completed when a later one fails.

Development testing caught a Windows PowerShell 5.1 interop detail: passing ordinary `$null` to `File.Replace` became an invalid empty backup path. The module now passes `NullString.Value` for the null string argument. Folder tests also cover a section header without a final newline and preserving non-icon metadata.

## Build and verify

In a fresh Windows PowerShell process from the source repository:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\Build.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tests\Test.ps1
```

The tests write only a disposable `HKCU\Software\CozyDesktopTests\<unique ID>` key and a temporary directory under ignored `test-results`. Native appearance calls are simulated. CI compiles the real native helper and launcher in separate steps and runs the suite with both PowerShell engines. See [backup scope and validation limits](SAFETY.md) and [Windows API references](REFERENCES.md).
