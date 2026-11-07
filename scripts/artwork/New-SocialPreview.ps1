#Requires -Version 5.1
[CmdletBinding()]
param()
$ErrorActionPreference='Stop'
Add-Type -AssemblyName System.Drawing
$root=Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$path=Join-Path $root 'docs\media\social-preview.png'
New-Item -ItemType Directory -Path (Split-Path $path -Parent) -Force | Out-Null
$image=New-Object Drawing.Bitmap(1280,640)
$g=[Drawing.Graphics]::FromImage($image)
$navy=New-Object Drawing.SolidBrush([Drawing.ColorTranslator]::FromHtml('#23455D'))
$blue=New-Object Drawing.SolidBrush([Drawing.ColorTranslator]::FromHtml('#89BED0'))
$gold=New-Object Drawing.SolidBrush([Drawing.ColorTranslator]::FromHtml('#E7C56E'))
$cream=New-Object Drawing.SolidBrush([Drawing.ColorTranslator]::FromHtml('#FFF8E9'))
$title=New-Object Drawing.Font('Segoe UI',64,[Drawing.FontStyle]::Bold)
$body=New-Object Drawing.Font('Segoe UI',25)
try {
    $g.SmoothingMode=[Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint=[Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $g.Clear([Drawing.ColorTranslator]::FromHtml('#FFF8E9'))
    $g.FillEllipse($blue,960,-120,460,460)
    $g.FillEllipse($gold,1030,70,125,125)
    $g.FillEllipse($navy,1090,145,140,140)
    $g.FillEllipse($blue,1135,120,140,140)
    $g.DrawString('Cozy Desktop',$title,$navy,70,190)
    $g.DrawString('Windows theme toolkit',$body,$navy,78,310)
    $g.FillRectangle($gold,78,393,100,8)
    $g.DrawString('Day / Night   |   Icons   |   Backup + reset',$body,$navy,78,445)
    $g.DrawString('github.com/SimpleCaci/cozy-desktop',$body,$navy,78,535)
    $image.Save($path,[Drawing.Imaging.ImageFormat]::Png)
} finally { $g.Dispose();$image.Dispose();$navy.Dispose();$blue.Dispose();$gold.Dispose();$cream.Dispose();$title.Dispose();$body.Dispose() }
Write-Output $path
