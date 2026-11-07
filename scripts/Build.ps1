[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Import-Module (Join-Path $PSScriptRoot 'CozyDesktop.psm1') -Force
$theme = Get-CozyTheme
$icon = Get-CozyAsset $theme.Base 'icons\day-night-toggle.ico'
$compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'
if (!(Test-Path -LiteralPath $compiler)) { $compiler = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v4.0.30319\csc.exe' }
if (!(Test-Path -LiteralPath $compiler)) { throw 'The Windows .NET Framework C# compiler was not found.' }
New-Item -ItemType Directory -Path (Join-Path $root 'bin') -Force | Out-Null
& $compiler /nologo /target:winexe /reference:System.Windows.Forms.dll "/win32icon:$icon" "/out:$root\bin\CozyDesktop.exe" "$root\src\Launcher.cs"
if ($LASTEXITCODE -ne 0) { throw 'Launcher compilation failed.' }
Write-Output 'Built bin\CozyDesktop.exe'
