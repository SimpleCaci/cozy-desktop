# Help make more desktops cozy

Theme ideas, bug reports and small fixes are welcome.

For bugs, include your Windows version, the exact command and error, and whether the problem affects wallpapers, icons, cursors or reset. Remove usernames, monitor IDs and private paths from any logs you share. Do not upload your `.state` folder.

For code changes, run `scripts/Build.ps1` and `tests/Test.ps1` in a fresh Windows PowerShell 5.1 process. The regression tests use temporary folders and a disposable registry key under `HKCU\Software\CozyDesktopTests`; real desktop calls are simulated. CI also checks PowerShell 7.

For theme contributions, follow [the theme guide](docs/THEMES.md), include asset credits and permission, and show a day/night preview. Keep installer changes per-user and reversible. Save the original value before every change; failed restoration must keep the backup available for retry.

Use focused commits with `feat:`, `fix:`, `docs:`, or `test:` subjects. Bug fixes should include a regression check where practical. Link related issues in pull requests and explain how you verified the change.

For a first task, see [good first issues](https://github.com/SimpleCaci/cozy-desktop/labels/good%20first%20issue).
Read [the roadmap](docs/ROADMAP.md) before starting a large feature. Small PRs are
easier to review than a new installer, theme system and GUI in the same change.

For documentation, use [the writing notes](docs/PRESENTATION.md). Keep the author's
motivation and voice. Show substantial wording changes in the PR, remove repeated
or vague claims, and keep technical limits and artwork sources visible. A writing
checklist is not a test of whether someone used AI.

For release-related changes, also run `scripts/Validate-Repository.ps1`,
`scripts/Package.ps1`, and `tests/Test-Package.ps1 -PackagePath <zip>` from the source
repo. The generated `dist` directory is ignored. See [release procedure](docs/RELEASING.md).

Follow [community conduct](CODE_OF_CONDUCT.md). Report security issues using the
private route in [SECURITY.md](SECURITY.md), rather than opening a public exploit report.
