<#
  Drives the real fizz-gui.ps1 through a scripted session without a keyboard or a display.
  WinForms/GDI+ are replaced by a small stand-in library (ui/fakeui.cs) and the keyboard by a fake
  device (ui/fakedev.ps1); ui/scenario.ps1 clicks through every tab and asserts on the results.
  Run with PowerShell 7:   pwsh dev/tests/run-ui-test.ps1
  Exit code is 0 when everything passes.
#>
$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$work = Join-Path ([System.IO.Path]::GetTempPath()) ('fizzui_' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work | Out-Null
$env:APPDATA = Join-Path $work 'appdata'

# data for the sample Cfg.ini comes from the app itself
. (Join-Path $root 'fizz-gui.ps1') -NoGui
. (Join-Path $PSScriptRoot 'sample-cfg.ps1')
[System.IO.File]::WriteAllBytes((Join-Path $work 'Cfg.ini'), [System.Text.Encoding]::ASCII.GetBytes((New-SampleCfgText)))

# stand-in UI library
$src = Get-Content -Raw (Join-Path $PSScriptRoot 'ui/fakeui.cs')
if ($PSVersionTable.PSEdition -eq 'Desktop') { Add-Type -TypeDefinition $src -ReferencedAssemblies 'System.Drawing' } else { Add-Type -TypeDefinition $src }

# build a copy of the app that talks to the stand-ins
$t = [System.IO.File]::ReadAllText((Join-Path $root 'fizz-gui.ps1'))
$t = [regex]::Replace($t, '(?m)^Add-Type -AssemblyName System\.(Windows\.Forms|Drawing)\s*$', '')
$t = $t.Replace('System.Windows.Forms.', 'FakeUI.').Replace('System.Drawing.Drawing2D.', 'FakeUI.').Replace('System.Drawing.Text.', 'FakeUI.')
$t = [regex]::Replace($t, 'System\.Drawing\.(Font|SolidBrush|Pen|StringFormat|StringAlignment|StringTrimming|StringFormatFlags|Graphics|Brush)\b', 'FakeUI.$1')
foreach ($pair in @(@('[FizzDevice]::Find()', 'Test-FakeFind'), @('[FizzDevice]::OpenAll($list)', 'Test-FakeOpen $list'))) {
  if (-not $t.Contains($pair[0])) { throw "cannot patch: '$($pair[0])' not found - update run-ui-test.ps1" }
  $t = $t.Replace($pair[0], $pair[1])
}
$last = '[void]$form.ShowDialog()'
$idx = $t.LastIndexOf($last)
if ($idx -lt 0) { throw 'cannot patch: final ShowDialog call not found' }
$scenario = (Join-Path $PSScriptRoot 'ui/scenario.ps1').Replace("'", "''")
$t = $t.Substring(0, $idx) + "[FakeUI.Host]::AfterShown = [Action]{ . '" + $scenario + "' }`r`n" + $last + "`r`n"
$patched = Join-Path $work 'fizz-gui-under-test.ps1'
[System.IO.File]::WriteAllText($patched, $t)

$global:T_Pass = 0; $global:T_Fail = 0
function Check { param([string]$Name, $Cond, [string]$Detail = '')
  if ($Cond) { $global:T_Pass++; Write-Host "  PASS  $Name" } else { $global:T_Fail++; Write-Host "  FAIL  $Name   $Detail" } }
function Step { param([string]$Name, [scriptblock]$Body)
  try { & $Body } catch { $global:T_Fail++; Write-Host ("  FAIL  $Name -> EXCEPTION: " + $_.Exception.Message + '  @ ' + (($_.ScriptStackTrace -split "`n" | Select-Object -First 2) -join ' | ')) } }
. (Join-Path $PSScriptRoot 'ui/fakedev.ps1')

& $patched

Write-Host ''
Write-Host "==== $($global:T_Pass) passed, $($global:T_Fail) failed ===="
Remove-Item -Recurse -Force $work -ErrorAction SilentlyContinue
if ($global:T_Fail -gt 0) { exit 1 }
