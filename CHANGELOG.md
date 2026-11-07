# Changelog

## 0.1.0-alpha.1 — 2026-11-06

### Added

- Source-drawn Starter theme, with rebuildable wallpapers/icons and preserved geometric cursor source. Release packages exclude the unresolved Sunbeam Kitty art.
- Versioned ZIP packaging, SHA-256 checksums, extracted-package validation, and a draft preview-release workflow.
- Read-only CI defaults, pinned Actions, weekly Dependabot updates, documentation/private-path checks and a packaging job.
- Security reporting, community conduct, contribution/issue/PR templates, code ownership, FAQ, roadmap and release procedure.
- A lightweight README with the author's motivation preserved, labelled artwork previews, setup/reset instructions, and a source-drawn social-preview image.

### Fixed

- Reject linked theme files/directories after validating their textual paths.
- Avoid static Recycle Bin class overrides that can interfere with empty/full state selection, while saving removed values for reset.
- Release the native wallpaper COM object even when monitor inspection fails.
- Retrieve known-folder paths before checking whether optional folders exist.
- Build and install button artwork from the configured theme.
- Preserve license/notices and linked documents in the installed copy.

### Still open

- Full live install/reset coverage on Windows 10/11 and scheduled sleep/resume behavior.
- Original creator/permission for the Pinterest-derived Sunbeam Kitty references.
- Executable signing and performance measurements. No benchmarks or stable-release certification are claimed.

## Unreleased — documentation and provenance review, 2026-11-06

- Replaced the earlier assistant-written introduction with the author's own motivation and first-person wording.
- Separated installation, backup/reset scope, compatibility and implementation details into dedicated guides.
- Clarified that installation copies bundled assets and reset restores recorded pre-install values rather than factory defaults.
- Documented resource use without making unmeasured performance claims.
- Corrected artwork credits: Pinterest-based references remain unverified; no exact online source match was confirmed.
- Expanded restoration checks to cover registry types, unnamed values and original folder metadata attributes: 53 checks pass locally in both PowerShell engines.
- Included changelog and contribution documents in the installed copy so README links remain usable there.

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
