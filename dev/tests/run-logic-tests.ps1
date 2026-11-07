<#
  Logic tests for fizz-gui.ps1. No keyboard, no GUI and no personal files needed.
  Run with PowerShell 7 (Linux, macOS or Windows) or Windows PowerShell 5.1:
      pwsh dev/tests/run-logic-tests.ps1
  Exit code is 0 when everything passes.
#>
$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
$env:APPDATA = Join-Path ([System.IO.Path]::GetTempPath()) ('fizzlogic_' + [guid]::NewGuid().ToString('N'))
. (Join-Path $root 'fizz-gui.ps1') -NoGui

$script:Pass = 0; $script:Fail = 0
function Check { param([string]$Name, $Cond, [string]$Detail = '')
  if ($Cond) { $script:Pass++; Write-Host "  PASS  $Name" } else { $script:Fail++; Write-Host "  FAIL  $Name   $Detail" } }
function Sha { param($Frames) $ms = New-Object System.IO.MemoryStream
  foreach ($f in $Frames) { $b = [byte[]]$f; $ms.Write($b, 0, $b.Length) }
  $h = [System.Security.Cryptography.SHA256]::Create(); return (($h.ComputeHash($ms.ToArray()) | ForEach-Object { $_.ToString('x2') }) -join '') }

. (Join-Path $PSScriptRoot 'sample-cfg.ps1')
$Golden = @(
  @{ Label = 'rainbow, default colors, speed 3, brightness 3'; Kind = 'effect'; Name = 'rainbow'; Color = $null; Speed = 3; Bri = 3; Sha = '3a27aa91defdb6168c60130b212afc9700671df9a4db56cf3c218cae176e9caf' },
  @{ Label = 'fixed-on, color 10,20,30, speed 2, brightness 4'; Kind = 'effect'; Name = 'fixed-on'; Color = @(10,20,30); Speed = 2; Bri = 4; Sha = '9a4bf5a1296a747568e82a268facb73b6b98ff39cf3f78518eb19fd431bffaae' },
  @{ Label = 'retro-snake, color 10,20,30, speed 5, brightness 1'; Kind = 'effect'; Name = 'retro-snake'; Color = @(10,20,30); Speed = 5; Bri = 1; Sha = 'cf6e96dc76476b563c2455d8130f1c9eb80dbef6b2117924f2201c18c9ad8e20' },
  @{ Label = 'sine-wave, color 200,100,50, speed 1, brightness 2'; Kind = 'effect'; Name = 'sine-wave'; Color = @(200,100,50); Speed = 1; Bri = 2; Sha = '5e051fbb4c9c98f42df59d5b33d254b4437f20fe60a0a51465f35303b229a814' },
  @{ Label = 'off'; Kind = 'effect'; Name = 'off'; Color = $null; Speed = $null; Bri = $null; Sha = 'a8904278bb5ab21f231ccae185d5fbdf32d8db1b49c570d1302821b22d058ac9' },
  @{ Label = 'per-key frame, 5 keys'; Kind = 'perkey'; Colors = @{ 'Esc' = @(255,0,0);'Q' = @(0,255,0);'Space' = @(0,0,255);'RCtrl' = @(1,2,3);'/' = @(250,128,5) }; Sha = '0744b10138265937551b7e218159618c0123cd8affeb541a20597e0839ca6913' },
  @{ Label = 'paint (flash) sequence, 5 keys'; Kind = 'paint'; Colors = @{ 'Esc' = @(255,0,0);'Q' = @(0,255,0);'Space' = @(0,0,255);'RCtrl' = @(1,2,3);'/' = @(250,128,5) }; Sha = 'b2d5a401254f114beeb42a5b5124385538bfba53a3a3404d49fec24150e282d2' },
  @{ Label = 'keymap block for the stock K617 layout'; Kind = 'keymap'; Sha = '0d2d75be926acb9adcca6728ce99135db1d9f04149e65847b6fe83e30e5221fa' }
)

Write-Host "== 1. byte-for-byte parity with fizzctl 0.5.1 (golden hashes)"
foreach ($g in $Golden) {
  switch ($g.Kind) {
    'effect' { $got = Sha (New-EffectFrames -Name $g.Name -Color $g.Color -Speed $g.Speed -Brightness $g.Bri) }
    'perkey' { $d = @{}; foreach ($k in $g.Colors.Keys) { $d[$k] = $g.Colors[$k] }; $got = Sha @(, (New-PerKeyFrame $d)) }
    'paint'  { $d = @{}; foreach ($k in $g.Colors.Keys) { $d[$k] = $g.Colors[$k] }; $got = Sha (New-PaintFrames $d) }
    'keymap' { $m = ConvertFrom-CfgText -Text (New-SampleCfgText); $got = Sha @(, (New-KeymapBlock $m)) }
  }
  Check $g.Label ($got -eq $g.Sha) "$got"
}

Write-Host "== 2. sync: everything the app writes can be read back"
$bad = 0; $n = 0
foreach ($e in $script:EffectList) {
  $id = [int]$e.Id; $caps = $script:EffectCaps[$id]; $capable = ($null -ne $caps -and [int]$caps[3] -eq 1)
  foreach ($s in 1..5) { foreach ($b in 0..4) { foreach ($c in @($null, @(12, 200, 99))) {
    $fr = New-EffectFrames -Name $e.Name -Color $c -Speed $s -Brightness $b
    $d = ConvertFrom-LightingFrames -Mode $fr[1] -Exec $fr[4]; $n++
    $ok = ($d.EffectId -eq $id) -and ($d.Speed -eq $s) -and ($d.Brightness -eq $b)
    if ($capable -and $null -ne $c) { $ok = $ok -and $d.Custom -and ($d.Color[0] -eq 12) -and ($d.Color[1] -eq 200) -and ($d.Color[2] -eq 99) }
    if (-not $capable) { $ok = $ok -and (-not $d.Custom) }
    if (-not $ok) { $bad++ }
  } } }
}
Check "encode -> decode round trip ($n cases)" ($bad -eq 0) "$bad mismatches"

Write-Host "== 3. color goes into the effect's own 21-byte record"
$wrong = @()
foreach ($e in $script:EffectList) {
  $f0 = New-EffectFrames -Name $e.Name; $f1 = New-EffectFrames -Name $e.Name -Color @(9, 8, 7)
  $changed = @(); for ($i = 0; $i -lt 1032; $i++) { if ($f0[1][$i] -ne $f1[1][$i]) { $changed += $i } }
  $caps = $script:EffectCaps[[int]$e.Id]
  if ($caps -and [int]$caps[3] -eq 1) { if (-not ($changed.Count -eq 3 -and $changed[0] -eq (29 + 21 * ($e.Id - 1)))) { $wrong += $e.Name } }
  elseif ($changed.Count -ne 0) { $wrong += $e.Name }
}
Check 'color-capable effects patch exactly their own record; the others ignore color' ($wrong.Count -eq 0) ($wrong -join ',')
Check 'the capability table covers effects 1..22' (@($script:EffectCaps.Keys).Count -eq 22)

Write-Host "== 4. animation engine"
Initialize-AnimLayout
$bounds = $true; $dead = @()
foreach ($e in $script:EffectList) {
  $id = [int]$e.Id; if ($id -gt 20) { continue }
  $first = $null; $moves = $false
  foreach ($t in 0..20) {
    $f = [FizzAnim]::Render($id, $t * 0.5, 3, 4, $false, 255, 0, 0)
    if ($f.Length -ne 183) { $bounds = $false }
    if ($null -eq $first) { $first = $f } elseif (Compare-Object $f $first -SyncWindow 0) { $moves = $true }
  }
  if (-not $moves -and $id -ne 1) { $dead += $e.Name }
}
Check 'every effect renders 61 keys, and every effect except fixed-on moves over time' ($bounds -and $dead.Count -eq 0) ($dead -join ',')
$mono = $true
foreach ($id in 1..20) { $last = -1; foreach ($b in 0..4) {
  $f = [FizzAnim]::Render($id, 3.3, 3, $b, $true, 200, 100, 0); $sum = 0; foreach ($v in $f) { $sum += $v }
  if ($sum -lt $last) { $mono = $false }; $last = $sum } }
Check 'brightness never makes a frame dimmer as it goes up' $mono

Write-Host "== 5. settings file"
$s0 = Read-Settings
Check 'defaults when there is no file' ((-not $s0.AutoApply) -and $s0.Tab -eq 'effects')
$s0.AutoApply = $true; $s0.Tab = 'keymap'; Write-Settings $s0
$s1 = Read-Settings
Check 'values survive a save and reload' ($s1.AutoApply -and $s1.Tab -eq 'keymap')
Set-Content -Path (Get-SettingsPath) -Value '{ not json'
Check 'a corrupt file falls back to defaults' ((-not (Read-Settings).AutoApply))

Write-Host "== 6. Cfg.ini model"
$text = New-SampleCfgText
$m = ConvertFrom-CfgText -Text $text
Check 'sample parses: 61 keys, Fn layer entries present' ($m.Keys.Count -eq 61 -and @($m.Keys.Values | Where-Object { $null -ne $_.Fn }).Count -gt 0)
Check 'an untouched file is written back byte for byte' ((ConvertTo-CfgText $m) -ceq $text)
$stockIssues = Get-KeymapIssues $m
Check 'the stock layout has no validation issues' (@($stockIssues | ForEach-Object { $_ }).Count -eq 0)
$m.Keys[1].Base = @(2, 0x09, [long]0); $m.BaseDirty[1] = $true
$m.Keys[16].Fn = @(4, 0x28, [long]0); $m.FnDirty = $true
$m.Keys[29].Fn = @(9, 0, [long]0x0b000300); $m.FnDirty = $true
$m2 = ConvertFrom-CfgText -Text (ConvertTo-CfgText $m)
Check 'edits survive save and reload' (([int]$m2.Keys[1].Base[1] -eq 9) -and ([int]$m2.Keys[16].Fn[0] -eq 4) -and ([long]$m2.Keys[29].Fn[2] -eq 0x0b000300))
Check 'the keymap block encodes and stays 1032 bytes' ((New-KeymapBlock $m2).Length -eq 1032)
$many = ConvertFrom-CfgText -Text $text
foreach ($i in 1..61) { if ($null -eq $many.Keys[$i].Fn) { $many.Keys[$i].Fn = @(2, 65, [long]0) } }
$msg = ''; try { [void](New-KeymapBlock $many) } catch { $msg = $_.Exception.Message }
Check 'more than 48 Fn entries is refused' ($msg -match '48') $msg
$e1 = ConvertFrom-CfgText -Text $text
$fnKey = @($e1.Keys.Keys | Where-Object { [int]$e1.Keys[$_].Base[1] -eq 250 })[0]
$e1.Keys[$fnKey].Fn = @(2, 65, [long]0)
Check 'an Fn entry on the Fn key itself is an error' (@((Get-KeymapIssues $e1) | Where-Object { $_.Level -eq 'error' }).Count -ge 1)
$e2 = ConvertFrom-CfgText -Text $text
$e2.Keys[$fnKey].Base = @(2, 163, [long]0)
Check 'no Fn key on the base layer is a warning' (@((Get-KeymapIssues $e2) | Where-Object { $_.Level -eq 'warn' }).Count -ge 1)

Write-Host ""
Write-Host "==== $($script:Pass) passed, $($script:Fail) failed ===="
if (Test-Path $env:APPDATA) { Remove-Item -Recurse -Force $env:APPDATA }
if ($script:Fail -gt 0) { exit 1 }
