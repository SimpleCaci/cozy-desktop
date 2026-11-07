# Security policy

## Supported versions

The current `0.1.0-alpha` line is experimental. Security fixes are made on `main`
and included in the next preview. Older previews do not receive separate fixes.

## Report privately

Use [GitHub's private vulnerability report form](https://github.com/SimpleCaci/cozy-desktop/security/advisories/new).
Include affected versions, reproduction steps, expected behavior and impact.
Do not open a public issue with an exploit or attach your `.state` backup.

Reports are reviewed by the maintainer as time permits; there is no response-time
guarantee or paid support agreement. Ordinary display bugs belong in Issues.

## Installation boundaries

The toolkit uses the current user's registry and files. It does not require an
administrator terminal, download executable code during installation, patch
system files, or include a telemetry client or network requests of its own.
Windows may access redirected/network-backed user folders. GitHub's website,
release downloads and badges have their own network behavior.

Treat themes and scripts as code/assets to review before running. Linked theme
assets are rejected, but the toolkit is not a sandbox for hostile themes. Keep
backups private and preserve original wallpaper files. See [backup and reset
limits](docs/SAFETY.md). Builds are currently unsigned; signatures and checksums
are different things. A published SHA-256 checksum detects differing bytes; it
does not replace code review or prove that the publisher's account is secure.
