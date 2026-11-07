#Requires -Version 5.1
[CmdletBinding()]
param([string]$OutputDirectory = '')
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
if (!$OutputDirectory) { $OutputDirectory = Join-Path $root 'dist' }
$OutputDirectory = [IO.Path]::GetFullPath($OutputDirectory)
$version = (Get-Content -LiteralPath (Join-Path $root 'VERSION') -Raw).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$') { throw 'VERSION must be a semantic version.' }
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$name = "cozy-desktop-$version-windows"
$zip = Join-Path $OutputDirectory ($name + '.zip')
if (Test-Path -LiteralPath $zip) { throw "Package already exists: $zip. Choose a new output directory." }
$stage = Join-Path $OutputDirectory ($name + '-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stage | Out-Null
try {
    # Explicit allowlist: no backups, local logs, Git metadata or unverified artwork.
    foreach ($item in 'src','scripts','docs','Install.ps1','README.md','CHANGELOG.md','CONTRIBUTING.md','CODE_OF_CONDUCT.md','SECURITY.md','LICENSE','THIRD_PARTY_NOTICES.md','VERSION') {
        Copy-Item -LiteralPath (Join-Path $root $item) -Destination $stage -Recurse
    }
    New-Item -ItemType Directory -Path (Join-Path $stage 'themes') | Out-Null
    Copy-Item -LiteralPath (Join-Path $root 'themes\starter') -Destination (Join-Path $stage 'themes') -Recurse
    # README previews for the unverified theme are not redistributed in the ZIP.
    $config = Get-Content -LiteralPath (Join-Path $root 'config.json') -Raw | ConvertFrom-Json
    $config.Theme = 'starter'
    $config | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $stage 'config.json') -Encoding UTF8
    $guide = @'
# Cozy Desktop preview build

This ZIP ships the source-drawn Starter theme. Sunbeam Kitty is excluded because
its original image-reference permissions have not been verified.

Extract the whole ZIP, open Windows PowerShell here, review the scripts, then run:

    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1 -WhatIf
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Install.ps1

Use the desktop Day/Night/Toggle/Auto buttons. Add -AutoSwitch at installation
for scheduling, or -FolderIcons for the supported Windows folder locations.
Read docs/SAFETY.md before installing. This is an unsigned experimental preview,
not a fully certified Windows 10/11 release. Windows policy may block it.

Reset from Windows PowerShell:

    $cozy = Join-Path $env:LOCALAPPDATA 'CozyDesktop'
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$cozy\scripts\Reset.ps1"

Reset restores recorded pre-install settings, not factory defaults. Keep the
installed files, backup and original wallpapers until reset succeeds.

Project: https://github.com/SimpleCaci/cozy-desktop
'@
    $guide | Set-Content -LiteralPath (Join-Path $stage 'START-HERE.md') -Encoding UTF8
    # Replace the repository landing page in the distributable so all local links work.
    Copy-Item -LiteralPath (Join-Path $stage 'START-HERE.md') -Destination (Join-Path $stage 'README.md') -Force
    & (Join-Path $stage 'scripts\Build.ps1')
    if (!(Test-Path -LiteralPath (Join-Path $stage 'bin\CozyDesktop.exe'))) { throw 'The packaged launcher is missing.' }
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [IO.Compression.ZipFile]::CreateFromDirectory($stage, $zip, [IO.Compression.CompressionLevel]::Optimal, $false)
    $hash = (Get-FileHash -LiteralPath $zip -Algorithm SHA256).Hash.ToLowerInvariant()
    "$hash  $([IO.Path]::GetFileName($zip))" | Set-Content -LiteralPath ($zip + '.sha256') -Encoding ASCII
    Write-Output $zip
} finally {
    $resolvedStage = [IO.Path]::GetFullPath($stage)
    $expectedRoot = $OutputDirectory.TrimEnd('\') + '\'
    if (!$resolvedStage.StartsWith($expectedRoot,[StringComparison]::OrdinalIgnoreCase) -or (Split-Path $resolvedStage -Leaf) -notlike ($name + '-*')) { throw 'Refusing cleanup outside the package staging directory.' }
    Remove-Item -LiteralPath $resolvedStage -Recurse -Force
}
