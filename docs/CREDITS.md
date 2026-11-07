# Where this came from

Starter was added for preview releases in November 2026. Its wallpapers and icons
are drawn from geometric primitives by `scripts/artwork/New-StarterTheme.ps1`,
without input images. Its cursor set comes from the project's earlier geometric
cursor code, now preserved in `scripts/artwork/build-cursors.py`. Release packages
include Starter and exclude the unverified Sunbeam Kitty art.

Sunbeam Kitty began as SimpleCaci's personal Windows desktop theme in November 2026. The wallpapers and most cat-themed icon artwork were generated with OpenAI's image generation tool and exported as PNG/ICO assets. The earlier prompt notes explicitly mention user-supplied image references, whose creators, source URLs and reuse permissions were not recorded. Generation alone does not establish that all underlying visual references are original or cleared for redistribution.

The native cursor artwork was drawn with local Python/Pillow geometric paths and exported as CUR/ANI. The plain blue/yellow/navy folders and the simple `day-night-toggle` button were also drawn with local Python/Pillow code. They were not all produced by image generation, as the first version of these credits implied.

The original native multi-monitor helper was adapted into this toolkit. The old machine-specific registry files, personal shortcuts, logs, executables, backups, and folder-move scripts are intentionally excluded from this repository. The public installer is newly written for portable paths, local-time scheduling, scoped backups and restoration.

The MIT license covers the repository's own code and contributions to the extent the contributor has rights to them; it cannot grant rights to unverified third-party reference material. AI-generated artwork may not receive copyright protection in all jurisdictions. See [the asset audit](ASSET-AUDIT.md) for findings and limitations. New contributors should document their assets, references and permissions.

The file-by-file license scope is summarized in [third-party and asset notices](../THIRD_PARTY_NOTICES.md).
