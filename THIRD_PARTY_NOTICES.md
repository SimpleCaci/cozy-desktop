# Licenses and asset sources

The project code and source-drawn Starter theme are offered under the root MIT license, copyright 2026 SimpleCaci, to the extent copyright applies. No third-party font, Windows binary, or external image library is bundled with the application.

| Files | Source and license status |
| --- | --- |
| `src/`, `scripts/`, tests and project documentation | Project contributions, MIT. |
| `themes/starter/wallpapers/` and `themes/starter/icons/` | Generated from local geometric drawing code in `scripts/artwork/New-StarterTheme.ps1`; no image input. MIT. |
| `themes/starter/cursors/` and `themes/sunbeam-kitty/cursors/` | Local geometric cursor drawing/export code, now preserved in `scripts/artwork/build-cursors.py`. MIT. The help/preview text is rasterized using installed Windows fonts; font files are not distributed. |
| `themes/sunbeam-kitty/icons/blue.*`, `yellow.*`, `navy.*`, `day-night-toggle.*` | Earlier local geometric drawing code; provenance recorded in the asset audit. MIT for the project's contributions. |
| Other Sunbeam Kitty icons and its four wallpapers | AI-generated artwork with an unresolved image-reference chain, reportedly from Pinterest. Underlying creator and reuse permissions are unverified. These files are excluded from release packages. Do not treat the root MIT license as proof of permission for that reference material. |

The Starter cursors were copied from the earlier code-generated cursor outputs; the generator is included for inspection and rebuilding. Pillow is an optional development dependency for that generator, not a bundled runtime dependency. Windows/.NET APIs and fonts are supplied by the user's operating system under its own terms.

The README collections and writing guide listed in `docs/PRESENTATION.md` informed structure and editing. Their templates, artwork and scripts were not copied into this project.

See [credits](docs/CREDITS.md), [the asset audit](docs/ASSET-AUDIT.md), and [the open source-tracing issue](https://github.com/SimpleCaci/cozy-desktop/issues/3).
