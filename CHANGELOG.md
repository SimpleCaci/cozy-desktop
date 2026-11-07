# Changelog

## Unreleased — initial toolkit, 2026-11-06

### Added

- Sunbeam Kitty day/night wallpaper pairs for landscape and portrait monitors, coordinated ICO icons, and 17 cursor roles with animated busy/working states.
- A rebuildable desktop button and Day, Night, Auto and Toggle commands.
- A per-user installer with optional local-time scheduling and individual feature switches.
- Recycle Bin empty/full, This PC, Network, user files and Libraries icon mappings.
- Optional matching icons for eight Windows known folders, using Windows-resolved paths.
- Backups, byte-exact folder metadata restoration, and Reset/Restore commands.
- Windows PowerShell 5.1 and PowerShell 7 CI, regression tests, setup guide, theme-authoring guide and asset credits.

### Fixed during development

- Atomic backup replacement under Windows PowerShell 5.1, where an ordinary null argument became an invalid empty backup path.
- Folder metadata handling for a section header without a final newline and icon entries containing extra spaces.
- Preserve the first backup across repeated changes, and keep it available when reset cannot find an original wallpaper or monitor.

### Validation limits

- Automated tests simulate native desktop changes and exercise disposable registry/folder data; they do not certify a full live installation.
- Native helper compilation, read-only monitor detection, launcher build and installer preview were checked locally on Windows 11.
- Broader Windows 10/11 visual checks and sleep/resume scheduled-task behavior are tracked in GitHub issues before a tagged release.
