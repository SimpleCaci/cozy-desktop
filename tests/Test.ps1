#Requires -Version 5.1
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$script:checks = 0
function Check([bool]$Condition, [string]$Message) {
    if (!$Condition) { throw "FAIL: $Message" }
    $script:checks++
}
function Expect-Failure([scriptblock]$Action, [string]$Message) {
    $failed = $false
    try { & $Action | Out-Null } catch { $failed = $true }
    Check $failed $Message
}
# Native desktop calls are replaced by a fake in this fresh test process.
# No actual wallpaper, cursor, task or shell icon is changed.
if ('KittyDesktop.Native' -as [type]) { throw 'Run tests in a fresh PowerShell process.' }
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
namespace KittyDesktop {
  public class Monitor { public string Id, Wallpaper; public int Width, Height; }
  public static class Native {
    public static Monitor[] Monitors = new[] {
      new Monitor { Id="wide", Wallpaper="", Width=1920, Height=1080 },
      new Monitor { Id="tall", Wallpaper="", Width=1080, Height=1920 }
    };
    public static Dictionary<string,string> Applied = new Dictionary<string,string>();
    public static int Fit = 2;
    public static Monitor[] Inspect() { return Monitors; }
    public static int GetPosition() { return Fit; }
    public static void Position(int mode) { Fit=mode; }
    public static void Apply(string id,string path) { Applied[id]=path; }
    public static void Refresh() {}
    public static bool SystemParametersInfo(uint a,uint p,IntPtr d,uint f) { return true; }
    public static string KnownFolder(string id) { return null; }
  }
}
'@
Import-Module (Join-Path $root 'scripts\CozyDesktop.psm1') -Force
$module = Get-Module CozyDesktop
$scratchRoot = Join-Path $root 'test-results'
$scratch = Join-Path $scratchRoot ('CozyDesktop-tests-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $scratch | Out-Null
$regSub = 'Software\CozyDesktopTests\' + [guid]::NewGuid().ToString('N')
try {
    # Parse every script with the current engine, including Windows PowerShell 5.1 in CI.
    foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File | Where-Object Extension -in '.ps1','.psm1') {
        $tokens = $null; $errors = $null
        $null = [Management.Automation.Language.Parser]::ParseFile($file.FullName, [ref]$tokens, [ref]$errors)
        Check ($errors.Count -eq 0) "Parse $($file.Name)"
    }
    $null = Assert-CozyAssets
    $starter = Assert-CozyAssets -ThemeName 'starter'
    Check ($starter.Manifest.Name -eq 'Starter') 'Validate the independently source-drawn release theme'
    Expect-Failure { Assert-CozyAssets -ThemeName '..\outside' } 'Reject alternate theme name traversal'
    $config = Get-CozyConfig
    foreach ($case in @(@(6,'Night'),@(7,'Day'),@(18,'Day'),@(19,'Night'),@(23,'Night'),@(0,'Night'))) {
        $actual = Resolve-CozyMode 'Auto' $config ([datetime]'2026-11-06 00:00:00').AddHours($case[0])
        Check ($actual -eq $case[1]) "Auto boundary at $($case[0])"
    }
    $overnight = [pscustomobject]@{ DayStartHour=19; NightStartHour=7 }
    Check ((Resolve-CozyMode 'Auto' $overnight ([datetime]'2026-11-06 23:00')) -eq 'Day') 'Overnight range'
    Check ((Resolve-CozyMode 'Auto' $overnight ([datetime]'2026-11-06 07:00')) -eq 'Night') 'Overnight boundary'
    Check ((Resolve-CozyMode 'Toggle' $config (Get-Date) 'Day') -eq 'Night') 'Toggle day to night'
    Check ((Resolve-CozyMode 'Toggle' $config (Get-Date) 'Night') -eq 'Day') 'Toggle night to day'
    Expect-Failure { Get-CozyAsset (Join-Path $root 'themes\sunbeam-kitty') '..\..\LICENSE' } 'Reject theme traversal'
    Expect-Failure { Get-CozyAsset (Join-Path $root 'themes\sunbeam-kitty') 'missing.png' } 'Reject missing assets'
    $junction = Join-Path $scratch 'linked-icons'
    New-Item -ItemType Junction -Path $junction -Target (Join-Path $root 'themes\sunbeam-kitty\icons') | Out-Null
    try {
        Expect-Failure { Get-CozyAsset $scratch 'linked-icons\blue.ico' } 'Reject theme assets reached through a junction'
    } finally { [IO.Directory]::Delete($junction) }
    & $module { param($p) $script:StatePath = Join-Path $p 'backup.json' } $scratch
    New-CozyState
    Expect-Failure { New-CozyState } 'Never replace original installation backup'
    # Real registry round trip is limited to a disposable test key, never appearance.
    $key = [Microsoft.Win32.Registry]::CurrentUser.CreateSubKey($regSub)
    $key.SetValue('Present', 'before', [Microsoft.Win32.RegistryValueKind]::String)
    $key.SetValue('Bytes', [byte[]]@(0,1,255), [Microsoft.Win32.RegistryValueKind]::Binary)
    $key.SetValue('Number', 42, [Microsoft.Win32.RegistryValueKind]::DWord)
    $key.SetValue('Large', [long]4294967296, [Microsoft.Win32.RegistryValueKind]::QWord)
    $key.SetValue('Many', [string[]]@('first','second'), [Microsoft.Win32.RegistryValueKind]::MultiString)
    $key.SetValue('Expandable', '%USERPROFILE%\original', [Microsoft.Win32.RegistryValueKind]::ExpandString)
    $key.SetValue('', 'original default', [Microsoft.Win32.RegistryValueKind]::String)
    $key.Dispose()
    $state = Get-CozyState
    Set-CozyRegistry $state $regSub 'Present' 'after'
    Set-CozyRegistry $state $regSub 'Present' 'again'
    Set-CozyRegistry $state $regSub 'Absent' 1 'DWord'
    Set-CozyRegistry $state $regSub 'Bytes' ([byte[]]@(9)) 'Binary'
    Set-CozyRegistry $state $regSub 'Number' 7 'DWord'
    Set-CozyRegistry $state $regSub 'Large' ([long]10) 'QWord'
    Set-CozyRegistry $state $regSub 'Many' ([string[]]@('changed')) 'MultiString'
    Set-CozyRegistry $state $regSub 'Expandable' '%TEMP%\changed' 'ExpandString'
    Set-CozyRegistry $state $regSub '' 'changed default'
    Remove-CozyRegistryValue $state $regSub 'Present'
    Check ($state.Registry.Count -eq 8) 'Original values are captured once, including removal'
    $removed = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($regSub)
    Check ($removed.GetValueNames() -notcontains 'Present') 'Remove a conflicting value after backing it up'
    $removed.Dispose()
    # Exercise real folder metadata preservation and byte-exact undo.
    $folder = Join-Path $scratch 'Project with spaces'
    New-Item -ItemType Directory -Path $folder | Out-Null
    $ini = Join-Path $folder 'desktop.ini'
    $original = "[.ShellClassInfo]`r`nLocalizedResourceName=My Project`r`nIconResource=old.ico,0`r`n[Other]`r`nKeep=Yes`r`n"
    [IO.File]::WriteAllText($ini, $original, [Text.Encoding]::Unicode)
    (Get-Item -LiteralPath $ini -Force).Attributes = [IO.FileAttributes]::Hidden -bor [IO.FileAttributes]::System
    $iniAttributes = [int](Get-Item -LiteralPath $ini -Force).Attributes
    $bytes = [Convert]::ToBase64String([IO.File]::ReadAllBytes($ini))
    $attributes = [int](Get-Item -LiteralPath $folder -Force).Attributes
    Set-CozyFolder $folder 'code'
    Set-CozyFolder $folder 'blue'
    $text = [IO.File]::ReadAllText($ini)
    Check ($text.Contains('LocalizedResourceName=My Project') -and $text.Contains('[Other]')) 'Preserve non-icon metadata'
    Check (([regex]::Matches($text,'IconResource=')).Count -eq 1) 'Do not duplicate icon entries'
    Check ((Get-CozyState).Folders.Count -eq 1) 'Preserve first folder backup on repeated changes'
    $emptyFolder = Join-Path $scratch 'No original ini'
    New-Item -ItemType Directory -Path $emptyFolder | Out-Null
    Set-CozyFolder $emptyFolder 'games'
    $headerFolder = Join-Path $scratch 'Header only'
    New-Item -ItemType Directory -Path $headerFolder | Out-Null
    $headerIni = Join-Path $headerFolder 'desktop.ini'
    [IO.File]::WriteAllText($headerIni, '[.ShellClassInfo]')
    Set-CozyFolder $headerFolder 'files'
    Check (([regex]::Matches([IO.File]::ReadAllText($headerIni),'\[\.ShellClassInfo\]')).Count -eq 1) 'Handle section headers without final newline'
    # Stub registry writes ONLY while exercising the theme controller, to avoid
    # touching real light/dark preferences. Save the real function for restoration.
    $realRegistry = & $module { ${function:Set-CozyRegistry} }
    $realRemove = & $module { ${function:Remove-CozyRegistryValue} }
    & $module {
        $script:Captured = @()
        function script:Set-CozyRegistry {
            param($State,$Subkey,$Name,$Value,$Kind)
            $script:Captured += [pscustomobject]@{ Subkey=$Subkey; Name=$Name; Value=$Value }
        }
        function script:Remove-CozyRegistryValue {
            param($State,$Subkey,$Name)
            $script:Captured += [pscustomobject]@{ Subkey=$Subkey; Name=$Name; Value=$null }
        }
    }
    Set-CozyIcons
    $captured = & $module { $script:Captured }
    Check (@($captured | Where-Object { $_.Subkey -like '*F02C1A0D*' -and $_.Name -eq '' }).Count -eq 2) 'Network icon in both shell views with actual unnamed default values'
    Check (@($captured | Where-Object { $_.Name -eq 'full' -and $null -ne $_.Value }).Count -eq 1) 'Recycle Bin state icon is registered in Explorer'
    Check (@($captured | Where-Object { $_.Subkey -like 'Software\Classes\*645FF040*' -and $null -ne $_.Value }).Count -eq 0) 'Never add a static class override for the Recycle Bin'
    Check (@($captured | Where-Object { $_.Subkey -like 'Software\Classes\*645FF040*' -and $null -eq $_.Value }).Count -eq 3) 'Remove conflicting bin class values with backup support'
    Set-CozyCursors
    $captured = & $module { $script:Captured }
    Check (@($captured | Where-Object { $_.Subkey -eq 'Control Panel\Cursors' -and $_.Name -eq 'Arrow' }).Count -eq 1) 'Cursor scheme writes role mapping'
    Set-CozyTheme 'Day' | Out-Null
    Check ([KittyDesktop.Native]::Applied['wide'].EndsWith('day-landscape.png')) 'Landscape wallpaper selection'
    Check ([KittyDesktop.Native]::Applied['tall'].EndsWith('day-portrait.png')) 'Portrait wallpaper selection'
    Set-CozyTheme 'Toggle' | Out-Null
    Check ((Get-CozyState).LastMode -eq 'Night') 'Toggle controller state'
    Set-CozyTheme 'Toggle' | Out-Null
    Check ((Get-CozyState).LastMode -eq 'Day') 'Repeated toggle controller state'
    Check ((Get-CozyState).Position -eq 2) 'Keep original wallpaper fit after repeated toggles'
    & $module { param($fn) Set-Item function:script:Set-CozyRegistry $fn } $realRegistry
    & $module { param($fn) Set-Item function:script:Remove-CozyRegistryValue $fn } $realRemove
    Restore-CozyDesktop | Out-Null
    Check ([KittyDesktop.Native]::Fit -eq 2) 'Restore original wallpaper fit'
    Check ([KittyDesktop.Native]::Applied['wide'] -eq '') 'Restore blank original wallpaper'
    Check ([Convert]::ToBase64String([IO.File]::ReadAllBytes($ini)) -eq $bytes) 'Byte-exact desktop.ini restoration'
    Check ([int](Get-Item -LiteralPath $ini -Force).Attributes -eq $iniAttributes) 'Restore original desktop.ini attributes'
    Check ([int](Get-Item -LiteralPath $folder -Force).Attributes -eq $attributes) 'Restore folder attributes'
    Check (!(Test-Path -LiteralPath (Join-Path $emptyFolder 'desktop.ini'))) 'Remove metadata that did not previously exist'
    $key = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($regSub)
    Check ($key.GetValue('Present') -eq 'before') 'Restore original registry string'
    Check ($key.GetValueNames() -notcontains 'Absent') 'Remove originally absent registry value'
    Check ([Convert]::ToBase64String($key.GetValue('Bytes')) -eq 'AAH/') 'Restore binary registry data'
    Check ($key.GetValue('Number') -eq 42 -and $key.GetValueKind('Number') -eq 'DWord') 'Restore DWORD value and type'
    Check ($key.GetValue('Large') -eq [long]4294967296 -and $key.GetValueKind('Large') -eq 'QWord') 'Restore QWORD without truncation'
    Check (($key.GetValue('Many') -join '|') -eq 'first|second' -and $key.GetValueKind('Many') -eq 'MultiString') 'Restore multiple registry strings'
    Check ($key.GetValue('Expandable',$null,[Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames) -eq '%USERPROFILE%\original') 'Restore expandable strings without expanding them in backup'
    Check ($key.GetValue('') -eq 'original default') 'Restore unnamed registry value'
    $key.Dispose()
    Expect-Failure { Get-CozyState } 'Archive backup only after successful reset'
    New-CozyState
    $state = Get-CozyState
    $state.Wallpapers = @([pscustomobject]@{ Id='disconnected'; Wallpaper='' })
    $state.Position = 2
    Save-CozyState $state
    Expect-Failure { Restore-CozyDesktop } 'Report disconnected monitors during reset'
    Check ($null -ne (Get-CozyState)) 'Keep backup available after incomplete reset'
    $state.Wallpapers = @([pscustomobject]@{ Id='wide'; Wallpaper=(Join-Path $scratch 'missing-original.png') })
    Save-CozyState $state
    Expect-Failure { Restore-CozyDesktop } 'Report missing original wallpaper'
    $state.Wallpapers = @()
    Save-CozyState $state
    Restore-CozyDesktop | Out-Null
    Write-Output "PASS: $script:checks checks. No real desktop appearance was changed."
} finally {
    [Microsoft.Win32.Registry]::CurrentUser.DeleteSubKeyTree($regSub, $false)
    # Verify the cleanup target stays within this run's unique temporary directory.
    $resolved = [IO.Path]::GetFullPath($scratch)
    $tempRoot = [IO.Path]::GetFullPath($scratchRoot).TrimEnd('\') + '\'
    if ($resolved.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase) -and (Split-Path $resolved -Leaf) -like 'CozyDesktop-tests-*') {
        Get-ChildItem -LiteralPath $resolved -Recurse -Force -File | ForEach-Object { $_.Attributes = [IO.FileAttributes]::Normal }
        Remove-Item -LiteralPath $resolved -Recurse -Force
    }
}
