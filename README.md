# Cozy Desktop — Windows Theme Toolkit

[![Windows checks](https://github.com/SimpleCaci/cozy-desktop/actions/workflows/windows.yml/badge.svg)](https://github.com/SimpleCaci/cozy-desktop/actions/workflows/windows.yml)

Introducing **Cozy Desktop** — an easy way to upgrade your Windows system without having to go through all the technical know-how yourself.

Some of the features include day/night wallpaper switching, desktop buttons, customizable Windows icons, and more. The bundled theme, **Sunbeam Kitty**, brings together a black cat, paper textures, blue skies, and moonlight.

## Why I Built This

Seeing different desktop aesthetics on subreddits online, and seeing apps such as Wallpaper Engine, inspired me to question whether this was something I could build for myself.

For Linux systems, there are tons of repositories out there that allow you to create these cool, anime-esque desktop profiles and completely upgrade the appearance of your desktop. I wanted a more accessible, personal solution for Windows.

I wanted to make something that puts customization within your control, without having to hand off unnecessary resources or RAM to background applications, especially when you're gaming or doing other things.

Normally, Windows customization requires you to navigate through multiple settings, understand some technical details, and repeat the same process for different components. I wanted to simplify that experience and save people time.

I want this repository to feel like an actual personal open-source project that others can learn from, customize, contribute to, and use to transform their Windows desktop.

## What it does

| Day | Night |
| --- | --- |
| ![Day wallpaper](themes/sunbeam-kitty/wallpapers/day-landscape.png) | ![Night wallpaper](themes/sunbeam-kitty/wallpapers/night-landscape.png) |

- **Wallpaper controls:** Day, Night, Toggle, and Auto desktop buttons, with landscape or portrait artwork chosen for each monitor.
- **Windows appearance:** light/dark preferences follow the wallpaper mode. Optional scheduled switching uses local time, with 7 am/7 pm defaults.
- **System icons:** empty/full Recycle Bin, Network, This PC, user files, and Libraries.
- **Folders:** optional icons for Desktop, Documents, Downloads, Pictures, Music, Videos, Favorites, and Saved Games, plus a command for individual folders.
- **Cursors:** 17 native Windows pointer roles, including animated busy and working states.
- **Reset:** restore the settings recorded before this toolkit changed them. This is not a factory-default Windows reset.

Some shell views keep their built-in icons or cache old ones. See [compatibility and restoration limits](docs/SAFETY.md).

The artwork was generated using earlier image references, reportedly found on Pinterest. The original reference's creator and permissions remain unverified. Read [the asset audit](docs/ASSET-AUDIT.md) before reusing the artwork.

## Get started

Use a normal Windows user account. The toolkit is intended for Windows 10/11 with Windows PowerShell 5.1 and .NET Framework 4.x. Local checks were performed on Windows 11; broader live install/reset validation remains [open work](https://github.com/SimpleCaci/cozy-desktop/issues/1).

**Before running it:** the installer changes current-user registry values, wallpapers, and folder metadata. It saves the tracked originals locally. Review the scripts and [what reset can and cannot restore](docs/SAFETY.md). No administrator terminal is required for the default per-user setup.

1. Choose **Code → Download ZIP** and extract the whole repository.
2. Open **Windows PowerShell** in the extracted folder and preview:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1 -WhatIf
   ```

3. Install the bundled theme:

   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1
   ```

The installer builds the button program, copies the bundled theme to `%LOCALAPPDATA%\CozyDesktop`, backs up the settings as they are first changed, applies the selected theme, and creates desktop buttons. There is no separate asset-import step.

For automatic switching, built-in folder icons, or a wallpaper-only setup, use [the installation options](docs/USAGE.md). To supply your own assets, follow [the theme guide](docs/THEMES.md) before installing.

## Reset your appearance

In Windows PowerShell:

```powershell
$cozy = Join-Path $env:LOCALAPPDATA 'CozyDesktop'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$cozy\scripts\Reset.ps1"
```

Reset returns tracked settings to their **pre-install values**, which may already include your own customizations. Keep the installed toolkit, its `.state` backup, and your original wallpaper files until reset succeeds. It does not promise complete restoration of every Windows appearance setting. [Read the backup scope and failure behavior](docs/SAFETY.md).

## How it works

The desktop button starts a PowerShell script, waits for it to finish, then exits. With automatic switching enabled, Windows Task Scheduler starts that script at sign-in and at the configured hours. There is no continuously running Cozy Desktop helper, but launching and switching still use CPU and RAM. No RAM, CPU, or gaming-performance benchmarks have been recorded.

Windows exposes these appearance settings in different places: wallpapers through a per-monitor COM interface, shell icons and cursors through current-user registry settings, and folder icons through `desktop.ini`. Keeping those changes reversible means saving each original value before the first write and keeping the backup if reset cannot finish. More detail is in [the implementation notes](docs/IMPLEMENTATION.md).

## Customize or contribute

The documentation should teach people how to use the toolkit, but also explain why certain design decisions were made.

- [Install and customize](docs/USAGE.md)
- [Create a theme](docs/THEMES.md)
- [Backup, reset, and compatibility](docs/SAFETY.md)
- [Implementation and validation](docs/IMPLEMENTATION.md)
- [Contributing](CONTRIBUTING.md), [changelog](CHANGELOG.md), and [open issues](https://github.com/SimpleCaci/cozy-desktop/issues)
- [Artwork credits](docs/CREDITS.md) and [source audit](docs/ASSET-AUDIT.md)

Project code is licensed under [MIT](LICENSE). The asset audit records the unresolved reference history; the license does not establish permissions for those references. This project is not affiliated with Microsoft or Wallpaper Engine.
