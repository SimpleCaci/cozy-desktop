# Windows integration references

- [IDesktopWallpaper](https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/nn-shobjidl_core-idesktopwallpaper) provides per-monitor wallpaper selection.
- [DESKTOP_WALLPAPER_POSITION](https://learn.microsoft.com/en-us/windows/win32/api/shobjidl_core/ne-shobjidl_core-desktop_wallpaper_position) defines Fill as value 4.
- [SystemParametersInfoW](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-systemparametersinfow) documents SPI_SETCURSORS (0x0057) to reload cursor settings.
- [Customizing folders with desktop.ini](https://learn.microsoft.com/en-us/windows/win32/shell/how-to-customize-folders-with-desktop-ini) describes the folder metadata used by the folder icon command.

Shell registry appearance settings and their visual effects can vary by Windows build. Only current-user settings are written. No system files are patched.
