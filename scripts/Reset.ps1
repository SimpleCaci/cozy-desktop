#Requires -Version 5.1
[CmdletBinding(SupportsShouldProcess)]
param()
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot 'CozyDesktop.psm1') -Force
if ($PSCmdlet.ShouldProcess('Current user appearance', 'Reset every tracked Cozy Desktop change to its pre-install value')) {
    Invoke-CozyLocked { Restore-CozyDesktop }
}
