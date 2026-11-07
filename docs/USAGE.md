# Installation and customization

## Install the bundled theme

For the packaged preview, download the ZIP attached to a release, extract all its
files, and open `START-HERE.md`. It selects Starter and excludes the unresolved
Sunbeam Kitty artwork. GitHub's automatic source archives retain the full repo;
its `config.json` currently selects Sunbeam Kitty. To use Starter from source,
change `Theme` to `starter` before installing. See [asset notices](../THIRD_PARTY_NOTICES.md).

For Windows 10/11 desktop sessions with Windows PowerShell 5.1 and .NET Framework 4.x. Development checks currently run on Windows 11; Windows 10 and managed PCs still need broader testing. Use your normal user account. No administrator terminal is needed.

1. Click **Code → Download ZIP** and extract the **whole folder** somewhere you can find again.
2. Open **Windows PowerShell** in that folder. Review the scripts, then preview the installation:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1 -WhatIf
   ```

3. Install:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1
   ```

Use **Cozy Desktop - Toggle** on your desktop whenever you want the other look.

The installer builds the tiny button program from source and copies the toolkit to `%LOCALAPPDATA%\CozyDesktop`. Windows keeps referring to those installed assets, so keep that folder in place. After installation, the downloaded/extracted source folder can be moved or removed.

`ExecutionPolicy Bypass` applies only to that PowerShell process; it does not change your saved execution policy. An organization's policy may still block scripts. The build uses Windows' included .NET Framework compiler; no SDK download is needed on the tested machine.

### Make it automatic

Use this **instead of** the install command above:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1 -AutoSwitch
```

Day starts at **7 am**, night at **7 pm**, using your PC's local clock. AutoSwitch creates a task for those times and sign-in, with missed runs allowed after sleep while signed in. The task runs briefly and exits. It does not calculate sunrise/sunset. To change the scheduled hours, edit `config.json` before installing. Restore before reinstalling with different options or hours.

**Day/Night** set a look now. **Toggle** alternates from the toolkit's last applied look. **Auto** chooses by the current hour once. A manual choice lasts until the next scheduled run when AutoSwitch is enabled.

### Include built-in folder locations

To include Desktop, Documents, Downloads, Pictures, Music, Videos, Favorites, and Saved Games folder icons, install with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1 -AutoSwitch -FolderIcons
```

Windows supplies the actual folder locations, including redirected and localized paths. Returned paths that do not exist are skipped. If Windows cannot resolve a known folder, the command can stop with an error; use the saved backup to reset any changes already made. Each changed folder is backed up individually. Some special shell views cache or substitute their own icons; reopen Explorer or sign out/in to see updates.

Already installed? Add these icons without reinstalling:

```powershell
$cozy = Join-Path $env:LOCALAPPDATA 'CozyDesktop'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$cozy\scripts\Set-DefaultIcons.ps1" -IncludeFolders
```

### Pick just the pieces you want

```powershell
# Wallpapers + Windows light/dark + buttons, without the system icons or cursors:
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1 -SkipIcons -SkipCursors
```

## Set an individual folder icon

After installation, run this in Windows PowerShell:

```powershell
$cozy = Join-Path $env:LOCALAPPDATA 'CozyDesktop'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$cozy\scripts\Set-FolderIcon.ps1" -Path "$HOME\Documents\My Project" -Icon code
```

The folder must already exist. Try `blue`, `yellow`, `navy`, `school`, `games`, `apps`, `files`, `archive`, `pictures`, `downloads`, `music`, `videos`, or `code`. More icons are in `themes/sunbeam-kitty/icons`. Add `-WhatIf` to preview.

This changes that folder's icon using `desktop.ini` and backs up its previous bytes and attributes. It does not move files or change the default save locations for Documents, Downloads, etc. Windows' Home tiles and some special folders may continue showing built-in icons. For an app shortcut, use **Properties → Change Icon** and choose an `.ico` from the installed theme; manual changes are not tracked by Restore.

## Undo it

In Windows PowerShell:

```powershell
$cozy = Join-Path $env:LOCALAPPDATA 'CozyDesktop'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$cozy\scripts\Reset.ps1"
```

Reset removes the toolkit's scheduled task and desktop buttons, restores the saved registry values, static monitor wallpapers and fit mode, and restores folder icon metadata. It returns your pre-install setup, including any custom appearance you already had. `Restore.ps1` does the same thing. It keeps the installed files and archives the backup. Once restoration succeeds, you can delete the installed folder yourself.

Backups stay locally in the installed `.state` folder and never belong in Git. Restore returns tracked settings to their **pre-install values**, including folder metadata, so later manual edits to those same settings will be replaced. Keep the original wallpaper files and reconnect themed monitors before restoring. Missing originals or disconnected monitors leave the backup in place so you can fix the issue and retry. Windows slideshow playback/position is not backed up; choose your slideshow again in Settings if needed.

If installation stops halfway through, use the same Restore command from the install location printed in the error. Folder and system icons can be cached; reopen Explorer or sign out/in if they do not update immediately. The toolkit does not force-close Explorer.


For the exact backup scope and known limits, read [Backup, reset, and compatibility](SAFETY.md). For a different theme, follow [the theme guide](THEMES.md). If a step fails, see [FAQ and troubleshooting](FAQ.md).
