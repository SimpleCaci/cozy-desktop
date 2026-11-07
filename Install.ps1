#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param(
    [ValidateSet('Day','Night','Auto')][string]$Mode = 'Auto',
    [switch]$AutoSwitch,
    [switch]$SkipIcons,
    [switch]$SkipCursors,
    [switch]$FolderIcons,
    [string]$InstallPath = (Join-Path $env:LOCALAPPDATA 'CozyDesktop')
)
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'scripts\CozyDesktop.psm1') -Force
$null = Assert-CozyAssets
$config = Get-CozyConfig
$InstallPath = [IO.Path]::GetFullPath($InstallPath)
if (Test-Path -LiteralPath $InstallPath) { throw "Install location already exists: $InstallPath. Restore the previous installation first, then choose a new empty location." }
$sid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
$taskName = "CozyDesktop-$sid"
if ($AutoSwitch -and (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) { throw "Scheduled task already exists: $taskName. Restore that installation first." }
$desktop = [Environment]::GetFolderPath('Desktop')
$shortcuts = @('Toggle','Day','Night','Auto') | ForEach-Object { Join-Path $desktop ("Cozy Desktop - $_.lnk") }
foreach ($shortcut in $shortcuts) { if (Test-Path -LiteralPath $shortcut) { throw "Shortcut already exists: $shortcut" } }
if (!$PSCmdlet.ShouldProcess($InstallPath, 'Install files, back up appearance, apply theme and create desktop buttons')) { return }
& (Join-Path $PSScriptRoot 'scripts\Build.ps1')
New-Item -ItemType Directory -Path $InstallPath | Out-Null
foreach ($item in 'src','scripts','themes','bin','docs','config.json','README.md','CHANGELOG.md','CONTRIBUTING.md','LICENSE') {
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot $item) -Destination $InstallPath -Recurse
}
Import-Module (Join-Path $InstallPath 'scripts\CozyDesktop.psm1') -Force
Invoke-CozyLocked {
    New-CozyState
    try {
        Set-CozyTheme $Mode
        if (!$SkipIcons) { Set-CozyIcons }
        if (!$SkipCursors) { Set-CozyCursors }
        if ($FolderIcons) { Set-CozyKnownFolders }
        $state = Get-CozyState
        $shell = New-Object -ComObject WScript.Shell
        foreach ($choice in 'Toggle','Day','Night','Auto') {
            $path = Join-Path $desktop ("Cozy Desktop - $choice.lnk")
            $state.Shortcuts += $path
            Save-CozyState $state
            $link = $shell.CreateShortcut($path)
            $link.TargetPath = Join-Path $InstallPath 'bin\CozyDesktop.exe'
            $link.Arguments = $choice
            $link.WorkingDirectory = $InstallPath
            $link.IconLocation = Join-Path $InstallPath 'themes\sunbeam-kitty\icons\day-night-toggle.ico'
            $link.Description = "Cozy Desktop: $choice"
            $link.Save()
        }
        if ($AutoSwitch) {
            $state.TaskName = $taskName
            Save-CozyState $state
            $powershell = Join-Path $env:SystemRoot 'System32\WindowsPowerShell\v1.0\powershell.exe'
            $arguments = '-NoProfile -NonInteractive -STA -ExecutionPolicy Bypass -File "' + (Join-Path $InstallPath 'scripts\Set-Theme.ps1') + '" -Mode Auto'
            $action = New-ScheduledTaskAction -Execute $powershell -Argument $arguments -WorkingDirectory $InstallPath
            $triggers = @(
                New-ScheduledTaskTrigger -AtLogOn -User ([Security.Principal.WindowsIdentity]::GetCurrent().Name)
                New-ScheduledTaskTrigger -Daily -At ((Get-Date).Date.AddHours($config.DayStartHour))
                New-ScheduledTaskTrigger -Daily -At ((Get-Date).Date.AddHours($config.NightStartHour))
            )
            $principal = New-ScheduledTaskPrincipal -UserId $sid -LogonType Interactive -RunLevel Limited
            $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -MultipleInstances IgnoreNew
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Principal $principal -Settings $settings -Description 'Cozy Desktop: local-time day/night theme; runs briefly, then exits.' | Out-Null
        }
    } catch {
        Write-Warning "Installation stopped: $($_.Exception.Message)"
        Write-Warning "Your backup remains at $InstallPath\.state\backup.json. Run scripts\Restore.ps1 there to undo partial changes."
        throw
    }
}
Write-Output "Installed at $InstallPath. Use the Cozy Desktop buttons on your desktop."
