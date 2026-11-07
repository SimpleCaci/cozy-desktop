# Release process

`VERSION` contains the semantic version. The current line is an experimental
prerelease (`0.1.0-alpha.1`). Change it for a real release, not to create activity.

1. Run the regression suite in Windows PowerShell 5.1 and PowerShell 7.
2. Run `scripts/Validate-Repository.ps1` and review the changelog and asset notices.
3. Add `docs/releases/v<version>.md` with actual changes and known limitations.
4. Run `scripts/Package.ps1`, then `tests/Test-Package.ps1 -PackagePath <zip>`.
5. Merge the tested changes, then push `v<version>` or run the Preview release workflow from Actions.
6. Review the resulting **draft** release and its ZIP/checksum. Publishing remains a deliberate maintainer step.

The workflow tests, builds the package, uploads short-lived CI artifacts and
creates/updates a draft prerelease. It refuses to overwrite a published release.
Only that job requests `contents: write`; ordinary CI is read-only. GitHub Actions
is not allowed to approve pull requests by default.

Packages contain only the Starter theme, selected source/scripts/docs, a compiled
button, notices and a beginner guide. They exclude `.state`, logs, Git metadata,
and the unverified Sunbeam Kitty art. The package is unsigned. A SHA-256 file is
published beside it; its hash is for the ZIP bytes, not a reproducible-build claim.

Do not call a preview stable until the live Windows install/reset and scheduler
issues are resolved. If Sunbeam Kitty's source is identified, review the permission
before changing the packaging allowlist. Screenshots, counts and performance
claims in release notes must come from actual observations.
