Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$script:Root = Split-Path $PSScriptRoot -Parent
$script:StatePath = Join-Path $script:Root '.state\backup.json'

function Read-Json([string]$Path) { Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json }
function Get-CozyConfig {
    $c = Read-Json (Join-Path $script:Root 'config.json')
    if ($c.Theme -notmatch '^[a-zA-Z0-9][a-zA-Z0-9_-]*$') { throw 'Theme must be a folder name under themes.' }
    foreach ($hour in @($c.DayStartHour, $c.NightStartHour)) {
        if (($hour -isnot [int] -and $hour -isnot [long]) -or $hour -lt 0 -or $hour -gt 23) { throw 'Start hours must be integers from 0 to 23.' }
    }
    if ($c.DayStartHour -eq $c.NightStartHour) { throw 'Day and night must start at different hours.' }
    return $c
}
function Resolve-CozyMode([string]$Mode, $Config, [datetime]$Now = (Get-Date), [string]$LastMode = '') {
    switch ($Mode) {
        'Day' { return 'Day' }
        'Night' { return 'Night' }
        'Toggle' {
            if ($LastMode -eq 'Day') { return 'Night' }
            if ($LastMode -eq 'Night') { return 'Day' }
            # With no previous choice, toggle away from the current time's theme.
            if ((Resolve-CozyMode 'Auto' $Config $Now) -eq 'Day') { return 'Night' }
            return 'Day'
        }
        'Auto' {
            $d = $Config.DayStartHour; $n = $Config.NightStartHour
            $day = if ($d -lt $n) { $Now.Hour -ge $d -and $Now.Hour -lt $n } else { $Now.Hour -ge $d -or $Now.Hour -lt $n }
            if ($day) { return 'Day' }; return 'Night'
        }
        default { throw "Unknown mode: $Mode" }
    }
}
function Get-CozyTheme {
    $config = Get-CozyConfig
    $base = Join-Path $script:Root ('themes\' + $config.Theme)
    [pscustomobject]@{ Base = $base; Manifest = (Read-Json (Join-Path $base 'theme.json')) }
}
function Get-CozyAsset([string]$Base, [string]$Relative) {
    $prefix = [IO.Path]::GetFullPath($Base).TrimEnd('\') + '\'
    $path = [IO.Path]::GetFullPath((Join-Path $Base $Relative))
    if (!$path.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase) -or !(Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing asset or path outside theme: $Relative"
    }
    return $path
}
function Assert-CozyAssets {
    $theme = Get-CozyTheme
    foreach ($mode in 'Day','Night') {
        foreach ($orientation in 'landscape','portrait') { $null = Get-CozyAsset $theme.Base $theme.Manifest.Wallpapers.$mode.$orientation }
    }
    foreach ($icon in $theme.Manifest.SystemIcons.PSObject.Properties) {
        foreach ($value in $icon.Value.PSObject.Properties) { $null = Get-CozyAsset $theme.Base $value.Value }
    }
    $cursors = Read-Json (Join-Path $theme.Base 'cursors\manifest.json')
    foreach ($role in $cursors.PSObject.Properties) { $null = Get-CozyAsset $theme.Base ('cursors\' + $role.Value.file) }
    return $theme
}
function Initialize-CozyNative {
    if (!('KittyDesktop.Native' -as [type])) { Add-Type -Path (Join-Path $script:Root 'src\DesktopWallpaper.cs') }
}
function Invoke-CozyLocked([scriptblock]$Action) {
    $sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
    $mutex = New-Object Threading.Mutex($false, "Local\CozyDesktop-$sid")
    $owned = $false
    try {
        try { $owned = $mutex.WaitOne(30000) } catch [Threading.AbandonedMutexException] { $owned = $true }
        if (!$owned) { throw 'Another Cozy Desktop operation is running.' }
        & $Action
    } finally { if ($owned) { $mutex.ReleaseMutex() }; $mutex.Dispose() }
}
function Get-CozyState {
    if (!(Test-Path -LiteralPath $script:StatePath)) { throw 'Install Cozy Desktop first. No backup was found.' }
    Read-Json $script:StatePath
}
function Save-CozyState($State) {
    $directory = Split-Path $script:StatePath -Parent
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
    $temp = $script:StatePath + '.tmp'
    $State | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $temp -Encoding UTF8
    Move-Item -LiteralPath $temp -Destination $script:StatePath -Force
}
function New-CozyState {
    if (Test-Path -LiteralPath $script:StatePath) { throw 'An installation backup already exists. Restore it before reinstalling.' }
    $state = [pscustomobject]@{ Version = 1; Registry = @(); Folders = @(); Wallpapers = @(); Position = $null; LastMode = ''; TaskName = ''; Shortcuts = @() }
    Save-CozyState $state
}
function Set-CozyRegistry($State, [string]$Subkey, [string]$Name, $Value, [string]$Kind = 'String') {
    if (!@($State.Registry | Where-Object { $_.Subkey -eq $Subkey -and $_.Name -eq $Name }).Count) {
        $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($Subkey)
        try {
            $exists = $null -ne $key -and $key.GetValueNames() -contains $Name
            $data = $null; $oldKind = 'String'
            if ($exists) {
                $oldKind = $key.GetValueKind($Name).ToString()
                $data = $key.GetValue($Name, $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
                if ($oldKind -eq 'Binary') { $data = [Convert]::ToBase64String($data) }
            }
            $State.Registry += [pscustomobject]@{ Subkey = $Subkey; Name = $Name; Existed = $exists; Kind = $oldKind; Data = $data }
            Save-CozyState $State
        } finally { if ($key) { $key.Dispose() } }
    }
    $key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($Subkey)
    try { $key.SetValue($Name, $Value, [Microsoft.Win32.RegistryValueKind]$Kind) } finally { $key.Dispose() }
}
function Set-CozyTheme([string]$Mode) {
    $theme = Assert-CozyAssets
    $config = Get-CozyConfig
    $state = Get-CozyState
    $resolved = Resolve-CozyMode $Mode $config (Get-Date) $state.LastMode
    Initialize-CozyNative
    $monitors = @([KittyDesktop.Native]::Inspect())
    if (!$monitors.Count) { throw 'No active desktop monitors were found.' }
    if ($null -eq $state.Position) {
        $state.Position = [KittyDesktop.Native]::GetPosition()
        $state.Wallpapers = @($monitors | Select-Object Id, Wallpaper)
        Save-CozyState $state
    }
    foreach ($monitor in $monitors) {
        # Remember newly connected monitors before their first change too.
        if (!@($state.Wallpapers | Where-Object Id -eq $monitor.Id).Count) {
            $state.Wallpapers += $monitor | Select-Object Id, Wallpaper
            Save-CozyState $state
        }
        $orientation = if ($monitor.Height -gt $monitor.Width) { 'portrait' } else { 'landscape' }
        $path = Get-CozyAsset $theme.Base $theme.Manifest.Wallpapers.$resolved.$orientation
        [KittyDesktop.Native]::Apply($monitor.Id, $path)
    }
    [KittyDesktop.Native]::Position(4)
    $light = if ($resolved -eq 'Day') { 1 } else { 0 }
    $sub = 'Software\Microsoft\Windows\CurrentVersion\Themes\Personalize'
    Set-CozyRegistry $state $sub 'AppsUseLightTheme' $light 'DWord'
    Set-CozyRegistry $state $sub 'SystemUsesLightTheme' $light 'DWord'
    $state.LastMode = $resolved
    Save-CozyState $state
    [KittyDesktop.Native]::Refresh()
    Write-Output "$resolved theme applied."
}
function Set-CozyIcons {
    $theme = Assert-CozyAssets; $state = Get-CozyState
    foreach ($icon in $theme.Manifest.SystemIcons.PSObject.Properties) {
        # Both per-user shell locations are needed for desktop and Explorer views.
        foreach ($prefix in 'Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID','Software\Classes\CLSID') {
            foreach ($value in $icon.Value.PSObject.Properties) {
                $path = Get-CozyAsset $theme.Base $value.Value
                $name = if ($value.Name -eq 'default') { '' } else { $value.Name }
                Set-CozyRegistry $state ($prefix + '\' + $icon.Name + '\DefaultIcon') $name ($path + ',0')
            }
        }
    }
    Initialize-CozyNative; [KittyDesktop.Native]::Refresh()
}
function Set-CozyCursors {
    $theme = Assert-CozyAssets; $state = Get-CozyState
    $manifest = Read-Json (Join-Path $theme.Base 'cursors\manifest.json')
    foreach ($role in $manifest.PSObject.Properties) {
        $path = Get-CozyAsset $theme.Base ('cursors\' + $role.Value.file)
        Set-CozyRegistry $state 'Control Panel\Cursors' $role.Name $path
    }
    Set-CozyRegistry $state 'Control Panel\Cursors' '' $theme.Manifest.Name
    Set-CozyRegistry $state 'Control Panel\Cursors' 'Scheme Source' 0 'DWord'
    Initialize-CozyNative
    if (![KittyDesktop.Native]::SystemParametersInfo(0x57, 0, [IntPtr]::Zero, 3)) { throw 'Windows could not reload the cursors.' }
}
function Set-CozyFolder([string]$Path, [string]$Icon) {
    $folder = Get-Item -LiteralPath $Path -Force
    if (!$folder.PSIsContainer -or ($folder.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Choose a real folder, not a link or junction.' }
    if ($folder.FullName -eq $folder.PSDrive.Root) { throw 'Drive roots are not supported.' }
    $theme = Get-CozyTheme
    $iconPath = Get-CozyAsset $theme.Base ('icons\' + $Icon + '.ico')
    $state = Get-CozyState
    $ini = Join-Path $folder.FullName 'desktop.ini'
    $exists = Test-Path -LiteralPath $ini
    if ($exists -and ((Get-Item -LiteralPath $ini -Force).Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'desktop.ini must not be a link.' }
    if (!@($state.Folders | Where-Object Path -eq $folder.FullName).Count) {
        $bytes = if ($exists) { [Convert]::ToBase64String([IO.File]::ReadAllBytes($ini)) } else { '' }
        $attrs = if ($exists) { [int](Get-Item -LiteralPath $ini -Force).Attributes } else { 0 }
        $state.Folders += [pscustomobject]@{ Path = $folder.FullName; Attributes = [int]$folder.Attributes; IniExisted = $exists; IniAttributes = $attrs; IniBytes = $bytes }
        Save-CozyState $state
    }
    $text = if ($exists) { [IO.File]::ReadAllText($ini) } else { '' }
    # Change icon entries only; retain localized names, infotips and other sections.
    $pattern = '(?ims)(^\[\.ShellClassInfo\][^\r\n]*\r?\n)(.*?)(?=^\[|\z)'
    $entry = "IconResource=$iconPath,0`r`n"
    if ([regex]::IsMatch($text, $pattern)) {
        $text = [regex]::Replace($text, $pattern, [Text.RegularExpressions.MatchEvaluator]{ param($m)
            $body = [regex]::Replace($m.Groups[2].Value, '(?im)^(IconResource|IconFile|IconIndex)=.*(?:\r?\n|$)', '')
            $m.Groups[1].Value + $entry + $body
        })
    } else { $text += "`r`n[.ShellClassInfo]`r`n$entry" }
    if ($exists) { (Get-Item -LiteralPath $ini -Force).Attributes = [IO.FileAttributes]::Normal }
    [IO.File]::WriteAllText($ini, $text, [Text.Encoding]::Unicode)
    (Get-Item -LiteralPath $ini -Force).Attributes = [IO.FileAttributes]::Hidden -bor [IO.FileAttributes]::System
    $folder.Attributes = $folder.Attributes -bor [IO.FileAttributes]::ReadOnly
    Initialize-CozyNative; [KittyDesktop.Native]::Refresh()
}
function Restore-CozyDesktop {
    $state = Get-CozyState
    # Stop future writers before restoring any appearance settings.
    if ($state.TaskName) {
        $task = Get-ScheduledTask -TaskName $state.TaskName -ErrorAction SilentlyContinue
        if ($task) {
            Disable-ScheduledTask -TaskName $state.TaskName | Out-Null
            Stop-ScheduledTask -TaskName $state.TaskName -ErrorAction SilentlyContinue
            Unregister-ScheduledTask -TaskName $state.TaskName -Confirm:$false
        }
    }
    foreach ($r in $state.Registry) {
        $key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($r.Subkey)
        try {
            if ($r.Existed) {
                $value = $r.Data
                if ($r.Kind -eq 'Binary') { $value = [Convert]::FromBase64String($r.Data) }
                if ($r.Kind -eq 'DWord') { $value = [int]$r.Data }
                if ($r.Kind -eq 'QWord') { $value = [long]$r.Data }
                if ($r.Kind -eq 'MultiString') { $value = [string[]]$r.Data }
                $key.SetValue($r.Name, $value, [Microsoft.Win32.RegistryValueKind]$r.Kind)
            } else { $key.DeleteValue($r.Name, $false) }
        } finally { $key.Dispose() }
    }
    foreach ($folder in $state.Folders) {
        if (!(Test-Path -LiteralPath $folder.Path -PathType Container)) { throw "Restore the missing folder to its original location and retry: $($folder.Path)" }
        $item = Get-Item -LiteralPath $folder.Path -Force
        if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Folder became a link: $($folder.Path)" }
        $ini = Join-Path $folder.Path 'desktop.ini'
        if (Test-Path -LiteralPath $ini) {
            if ((Get-Item -LiteralPath $ini -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "desktop.ini became a link: $ini" }
            (Get-Item -LiteralPath $ini -Force).Attributes = [IO.FileAttributes]::Normal
        }
        if ($folder.IniExisted) {
            [IO.File]::WriteAllBytes($ini, [Convert]::FromBase64String($folder.IniBytes))
            (Get-Item -LiteralPath $ini -Force).Attributes = [IO.FileAttributes]$folder.IniAttributes
        } elseif (Test-Path -LiteralPath $ini) { Remove-Item -LiteralPath $ini -Force }
        $item.Attributes = [IO.FileAttributes]$folder.Attributes
    }
    Initialize-CozyNative
    $active = @([KittyDesktop.Native]::Inspect())
    foreach ($monitor in $state.Wallpapers) {
        if (@($active | Where-Object Id -eq $monitor.Id).Count) {
            if ($monitor.Wallpaper -and !(Test-Path -LiteralPath $monitor.Wallpaper)) { throw "Original wallpaper is missing: $($monitor.Wallpaper)" }
            [KittyDesktop.Native]::Apply($monitor.Id, $monitor.Wallpaper)
        } else { throw 'Reconnect all previously themed monitors, then run Restore again.' }
    }
    if ($null -ne $state.Position) { [KittyDesktop.Native]::Position($state.Position) }
    if (@($state.Registry | Where-Object Subkey -eq 'Control Panel\Cursors').Count) {
        if (![KittyDesktop.Native]::SystemParametersInfo(0x57, 0, [IntPtr]::Zero, 3)) { throw 'Cursor restoration failed. Retry Restore.' }
    }
    foreach ($shortcut in $state.Shortcuts) { if (Test-Path -LiteralPath $shortcut) { Remove-Item -LiteralPath $shortcut -Force } }
    [KittyDesktop.Native]::Refresh()
    Move-Item -LiteralPath $script:StatePath -Destination ($script:StatePath + '.restored-' + (Get-Date -Format 'yyyyMMdd-HHmmss-fff'))
    Write-Output 'Original appearance restored. The installed files and archived backup remain for review.'
}
Export-ModuleMember -Function *-Cozy*
