<#
  Compares the frames fizz-gui.ps1 builds with the cases generated from fizzctl by gen_cases.py.
      pwsh dev/reference/check-frames.ps1 cases.json
#>
param([Parameter(Mandatory = $true)][string]$CasesFile)
$ErrorActionPreference = 'Stop'
$root = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../..'))
. (Join-Path $root 'fizz-gui.ps1') -NoGui
$cases = Get-Content -Raw $CasesFile | ConvertFrom-Json
$h = [System.Security.Cryptography.SHA256]::Create()
function HashFrames($frames) {
  $ms = New-Object System.IO.MemoryStream
  foreach ($f in $frames) { $b = [byte[]]$f; $ms.Write($b, 0, $b.Length) }
  return (($h.ComputeHash($ms.ToArray()) | ForEach-Object { $_.ToString('x2') }) -join '')
}
function ToDict($pairs) { $d = @{}; foreach ($p in $pairs) { $d[[string]$p[0]] = @([int]$p[1][0], [int]$p[1][1], [int]$p[1][2]) }; return $d }
$ok = 0; $bad = 0
foreach ($c in $cases) {
  switch ($c.kind) {
    'effect' {
      $col = $null; if ($null -ne $c.color) { $col = @([int]$c.color[0], [int]$c.color[1], [int]$c.color[2]) }
      $got = HashFrames (New-EffectFrames -Name $c.name -Color $col -Speed $c.speed -Brightness $c.bri)
    }
    'perkey' { $got = HashFrames @(, (New-PerKeyFrame (ToDict $c.colors))) }
    'paint'  { $got = HashFrames (New-PaintFrames (ToDict $c.colors)) }
  }
  if ($got -eq $c.sha) { $ok++ } else { $bad++; if ($bad -le 5) { Write-Host "MISMATCH $($c.kind) $($c.name) speed=$($c.speed) bri=$($c.bri)" } }
}
Write-Host "identical: $ok   mismatched: $bad"
if ($bad -gt 0) { exit 1 }
