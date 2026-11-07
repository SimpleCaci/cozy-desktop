# Cozy Desktop

Windows theme toolkit

[![Windows checks](https://github.com/SimpleCaci/cozy-desktop/actions/workflows/windows.yml/badge.svg)](https://github.com/SimpleCaci/cozy-desktop/actions/workflows/windows.yml)
[![Code license: MIT](https://img.shields.io/badge/code-MIT-89bed0?labelColor=23455d)](LICENSE)
[![Experimental preview](https://img.shields.io/badge/status-experimental-e7c56e?labelColor=23455d)](docs/releases/v0.1.0-alpha.1.md)

Introducing **Cozy Desktop** — an easy way to upgrade your Windows system without having to go through all the technical know-how yourself.

[Install](#install) · [Customize](docs/USAGE.md) · [Reset](#reset) · [FAQ](docs/FAQ.md) · [Roadmap](docs/ROADMAP.md)

| Starter: day | Starter: night |
| --- | --- |
| ![Source-drawn day wallpaper](themes/starter/wallpapers/day-landscape.png) | ![Source-drawn night wallpaper](themes/starter/wallpapers/night-landscape.png) |

These are wallpaper previews, not desktop screenshots. The downloadable preview
ships **Starter**, drawn from source. The original **Sunbeam Kitty** design remains
in the repository; its Pinterest reference is still [being traced](docs/ASSET-AUDIT.md)
and is excluded from release ZIPs.

## What changes

Use desktop buttons to choose **Day**, **Night**, **Toggle**, or **Auto**. Each
monitor gets landscape or portrait artwork, and Windows light/dark preferences
follow the mode. Optional scheduling uses your PC's local clock.

The toolkit also supports empty/full Recycle Bin, Network, This PC, user files and
Libraries icons; folder icons for supported built-in locations or folders you
choose; and 17 native cursor roles, including animated busy/working pointers.
Some Windows views keep their own icons or cache old ones.

The button and its PowerShell process exit after switching. There is no resident
Cozy Desktop helper. Launching and switching still use CPU/RAM; there are no gaming
benchmarks or performance-improvement claims.

## Install

**Experimental Windows preview.** Use a normal account on Windows 10/11 with
Windows PowerShell 5.1 and .NET Framework 4.x. Full live install/reset and
sleep/resume validation are still [open work](docs/ROADMAP.md).

1. [Download the Starter preview ZIP](https://github.com/SimpleCaci/cozy-desktop/releases/download/v0.1.0-alpha.1/cozy-desktop-0.1.0-alpha.1-windows.zip) and extract the whole folder. Builds are unsigned; do not disable Windows security protections if a policy blocks them.
2. Open **Windows PowerShell** in that folder, review the scripts and [backup limits](docs/SAFETY.md), then preview the operation:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1 -WhatIf
   ```

3. Install:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1
   ```

The installer copies the toolkit and theme to `%LOCALAPPDATA%\CozyDesktop`, saves
the tracked originals as it changes settings, applies the theme and creates desktop
buttons. There is no separate import step. It writes current-user registry values
and folder metadata; it does not require administrator access or download code
during installation. Keep the installed folder in place.

To include scheduling and built-in folder icons, use this instead of step 3:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1 -AutoSwitch -FolderIcons
```

For a different theme or fewer changes, see [installation and customization](docs/USAGE.md).
GitHub's **Source code** archives contain the full repo and differ from the packaged Starter build.

## Reset

In Windows PowerShell:

```powershell
$cozy = Join-Path $env:LOCALAPPDATA 'CozyDesktop'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$cozy\scripts\Reset.ps1"
```

Reset returns tracked settings to their **pre-install values**, including previous
customizations. Keep the installed files, `.state` backup and original wallpaper
files until it succeeds. It is not a factory reset or a full PC backup. Missing
originals or disconnected monitors can stop reset after earlier steps have run;
the backup remains for retry. [Exact coverage and recovery steps](docs/SAFETY.md).

<details>
<summary>Why I built this</summary>

Seeing different desktop aesthetics on subreddits online, and seeing apps such as Wallpaper Engine, inspired me to question whether this was something I could build for myself.

For Linux systems, there are tons of repositories out there that allow you to create these cool, anime-esque desktop profiles and completely upgrade the appearance of your desktop. I wanted a more accessible, personal solution for Windows.

I wanted to make something that puts customization within your control, without having to hand off unnecessary resources or RAM to background applications, especially when you're gaming or doing other things.

Normally, Windows customization requires you to navigate through multiple settings, understand some technical details, and repeat the same process for different components. I wanted to simplify that experience and save people time.

I want this repository to feel like an actual personal open-source project that others can learn from, customize, contribute to, and use to transform their Windows desktop.

</details>

## Themes and contributions

Starter is included in preview builds. [Sunbeam Kitty day](themes/sunbeam-kitty/wallpapers/day-landscape.png)
and [night](themes/sunbeam-kitty/wallpapers/night-landscape.png) artwork is retained
for the original design, with its reference uncertainty recorded. See
[theme creation](docs/THEMES.md) for custom assets and [notices](THIRD_PARTY_NOTICES.md)
for the license scope.

For a small first contribution, try [improving the setup guide](https://github.com/SimpleCaci/cozy-desktop/issues/4).
Read [Contributing](CONTRIBUTING.md) and [community conduct](CODE_OF_CONDUCT.md).
Report vulnerabilities through [Security](SECURITY.md), not a public issue.

[Implementation](docs/IMPLEMENTATION.md) · [Changelog](CHANGELOG.md) · [Release process](docs/RELEASING.md) · [Credits](docs/CREDITS.md)

Project code and the source-drawn Starter assets use [MIT](LICENSE). That license
does not establish permission for Sunbeam Kitty's unresolved reference material.
This project is not affiliated with Microsoft or Wallpaper Engine.
