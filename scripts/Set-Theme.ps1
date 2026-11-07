#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param([ValidateSet('Auto','Day','Night','Toggle')][string]$Mode = 'Toggle')
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'CozyDesktop.psm1') -Force
$null = Assert-CozyAssets
if ($PSCmdlet.ShouldProcess('Current user appearance', "Apply $Mode theme")) { Invoke-CozyLocked { Set-CozyTheme $Mode } }
