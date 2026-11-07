# Starter

A source-drawn theme for downloadable builds: blue skies, simple hills, a sun or crescent, and matching geometric icons. It uses no input images or Pinterest references. Native cursors come from the project's geometric cursor generator.

Rebuild wallpapers and PNG/ICO icons on Windows with:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\scripts\artwork\New-StarterTheme.ps1
```

To rebuild the cursors, install Pillow in your own Python development environment and run `python scripts/artwork/build-cursors.py`. Python/Pillow are not needed to install the generated theme.

The plain category folder icons share a common mark; Downloads and Code have distinct symbols. This is an initial release theme, not a claim that every folder has unique artwork. Additional source-drawn symbols are a good first contribution.
