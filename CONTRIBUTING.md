# Help make more desktops cozy

Theme ideas, bug reports and small fixes are welcome.

For bugs, include your Windows version, the exact command and error, and whether the problem affects wallpapers, icons, cursors or reset. Remove usernames, monitor IDs and private paths from any logs you share. Do not upload your `.state` folder.

For code changes, run `scripts/Build.ps1` and `tests/Test.ps1` in a fresh Windows PowerShell 5.1 process. The regression tests use temporary folders and a disposable registry key under `HKCU\Software\CozyDesktopTests`; real desktop calls are simulated. CI also checks PowerShell 7.

For theme contributions, follow [the theme guide](docs/THEMES.md), include asset credits and permission, and show a day/night preview. Keep installer changes per-user and reversible. Save the original value before every change; failed restoration must keep the backup available for retry.

Use focused commits with `feat:`, `fix:`, `docs:`, or `test:` subjects. Bug fixes should include a regression check where practical. Link related issues in pull requests and explain how you verified the change.
