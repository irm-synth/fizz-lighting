<#
  Fizz Lighting - Redragon K617 Fizz lighting control for the STOCK firmware
  WinForms GUI, no install, Windows PowerShell 5.1 or newer.

  The USB protocol knowledge (report IDs and sequences, captured firmware frames, effect
  encoding, per-key and canvas layouts, keymap encoder) is ported from fizzctl, MIT License,
  Copyright (c) 2026 microgod - https://github.com/ayoubdya/fizzctl (see THIRD-PARTY-NOTICE.txt).
  Written with AI assistance (Claude, by Anthropic). Not affiliated with Redragon.
  The protocol is reverse-engineered: use at your own risk.

  Scope: firmware effects with an approximate animated preview, sync of the current effect from
  the keyboard, optional auto-apply, per-key paint saved to the keyboard (flash write), and an
  OFFLINE keymap / Fn-layer editor for the Redragon Cfg.ini (nothing is written to the keyboard
  from the Keymap tab yet). Macros are not handled.
#>
param([switch]$NoGui)
$ErrorActionPreference = 'Stop'

# ============================================================================
#  Protocol data (generated from fizzctl)
# ============================================================================
$script:Tpl = @{
  Init    = [Convert]::FromBase64String('BYO2AAAA')
  Mode    = [Convert]::FromBase64String('Bgi4AEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A////////AAAAAP8A/wD//wD/AP8A//////8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')
  Canvas  = [Convert]::FromBase64String('Bgm8AEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/wD/AP8AAAAAAAAAAAAAAAAAAAAA////AP8AAAAAAAAAAAAAAAAAAAAAAP8A/wD/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/AP8AAAAAAAAAAAAA/wD/AP8AAAAAAAAAAAAAAAAAAAAA////AP8AAP8AAP8AAAAAAAAAAAAAAP8A/wD/AAD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/AP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP8AAP8AAAAAAAAAAAAAAAAAAAAAAAD///8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//////8AAAAAAAAAAAAAAAAAAAD//////wAAAAAAAAAAAAAAAAAAAAAA////AP8AAAAAAAAAAAAAAAAAAAD/AAAAAAD/AAAAAAAAAAAAAAAAAAD/AP8AAP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')
  Routing = [Convert]::FromBase64String('BgnAAEAAAAAAAAAAAAD/////////AAAAAAAAAAAAAAAAAAD//////wAAAAAAAAAAAAAAAAAAAAD//////wAAAAAAAAAAAAAAAAAAAP8AAAD//wAAAAAAAAAAAAAAAAAAAP8AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAD/////////AAAAAAAAAAAAAAAAAAD/////AAAAAAAAAAAAAAAAAAAAAAD/////AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/wD/AAAAAAAAAAAAAAAAAAAAAAD///8AAAAAAAAAAAAAAAAAAAAAAP8AAAAAAAAAAAAAAAAAAAAAAAAAAP8A/wAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')
  Exec    = [Convert]::FromBase64String('BgO2AAAAAAAAAAAAAABapQMDAAAAASABAAAAAFVVAQAAAAAA//8ANAczBzMHMwczBzMHMwczBzMHMwczBzMHMwczBzMHMwczBzMHMwczWqUAEAdEB0QHRAdEB0QHRAdEBAQEBAQEBAQEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABapQMDAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')
}
$script:RgbSec  = [Convert]::FromBase64String('//////8AAAAAAAAAAAAAAAAAAAD//////wAAAAAAAAAAAAAAAAAAAAAA////AP8AAAAAAAAAAAAAAAAAAAD/AAAAAAAA/wAAAAAAAAAAAAAAAAAA/wD/AAD/AAAAAAAAAAAAAAAAAAAAAA==')
$script:RgbExec = [Convert]::FromBase64String('BgO2AAAAAAAAAAAAAABapQMDAwABFSABAAAAAFVVAQAAAAAA//8AMgczBzMHMwdEBzMHMwczBzMHMwczByIHMwczBzMHMwczBzMHMwczWqUAEAdEB0QHRAdEB0QHRAdEBAQEBAQEBAQEBAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAABapQMDAwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA')

# key name -> position in the 16x6 column-major raster used by the live per-key report
$script:PerKeyPos = @{
  'Esc' = 1
  '1' = 7
  '2' = 13
  '3' = 19
  '4' = 25
  '5' = 31
  '6' = 37
  '7' = 43
  '8' = 49
  '9' = 55
  '0' = 61
  '-' = 67
  '=' = 73
  'Bksp' = 79
  'Tab' = 2
  'Q' = 8
  'W' = 14
  'E' = 20
  'R' = 26
  'T' = 32
  'Y' = 38
  'U' = 44
  'I' = 50
  'O' = 56
  'P' = 62
  '[' = 68
  ']' = 74
  '\' = 80
  'CapsLk' = 3
  'A' = 9
  'S' = 15
  'D' = 21
  'F' = 27
  'G' = 33
  'H' = 39
  'J' = 45
  'K' = 51
  'L' = 57
  ';' = 63
  '''' = 69
  'Enter' = 81
  'LShift' = 4
  'Z' = 10
  'X' = 16
  'C' = 22
  'V' = 28
  'B' = 34
  'N' = 40
  'M' = 46
  ',' = 52
  '.' = 58
  '/' = 64
  'RShift' = 82
  'LCtrl' = 5
  'LWin' = 11
  'LAlt' = 17
  'Space' = 35
  'RAlt' = 53
  'Fn' = 59
  'Menu' = 77
  'RCtrl' = 83
}

# key name -> LED index inside the 1032-byte canvas frame (flash-backed paint)
$script:LedIndex = @{
  'Esc' = 21
  '1' = 22
  '2' = 23
  '3' = 24
  '4' = 25
  '5' = 26
  '6' = 27
  '7' = 28
  '8' = 29
  '9' = 30
  '0' = 31
  '-' = 32
  '=' = 33
  'Bksp' = 34
  'Tab' = 42
  'Q' = 43
  'W' = 44
  'E' = 45
  'R' = 46
  'T' = 47
  'Y' = 48
  'U' = 49
  'I' = 50
  'O' = 51
  'P' = 52
  '[' = 53
  ']' = 54
  '\' = 55
  'CapsLk' = 63
  'A' = 64
  'S' = 65
  'D' = 66
  'F' = 67
  'G' = 68
  'H' = 69
  'J' = 70
  'K' = 71
  'L' = 72
  ';' = 73
  '''' = 74
  'Enter' = 76
  'LShift' = 84
  'Z' = 86
  'X' = 87
  'C' = 88
  'V' = 89
  'B' = 90
  'N' = 91
  'M' = 92
  ',' = 93
  '.' = 94
  '/' = 95
  'RShift' = 97
  'LCtrl' = 105
  'LWin' = 106
  'LAlt' = 107
  'Space' = 110
  'RAlt' = 113
  'Fn' = 114
  'Menu' = 117
  'RCtrl' = 118
}

# firmware effects: Id = effect id, Sb = default (speed-1)<<4 | brightness
$script:EffectList = @(
  @{ Name = 'fixed-on'; Id = 1; Sb = 51 },
  @{ Name = 'respire'; Id = 2; Sb = 51 },
  @{ Name = 'rainbow'; Id = 3; Sb = 51 },
  @{ Name = 'flash-away'; Id = 4; Sb = 51 },
  @{ Name = 'raindrops'; Id = 5; Sb = 51 },
  @{ Name = 'rainbow-wheel'; Id = 6; Sb = 51 },
  @{ Name = 'ripples-shining'; Id = 7; Sb = 51 },
  @{ Name = 'stars-twinkle'; Id = 8; Sb = 51 },
  @{ Name = 'shadow-disappear'; Id = 9; Sb = 51 },
  @{ Name = 'retro-snake'; Id = 10; Sb = 68 },
  @{ Name = 'neon-stream'; Id = 11; Sb = 68 },
  @{ Name = 'reaction'; Id = 12; Sb = 68 },
  @{ Name = 'sine-wave'; Id = 13; Sb = 68 },
  @{ Name = 'retinue-scanning'; Id = 14; Sb = 68 },
  @{ Name = 'rotating-windmill'; Id = 15; Sb = 51 },
  @{ Name = 'colorful-waterfall'; Id = 16; Sb = 51 },
  @{ Name = 'blossoming'; Id = 17; Sb = 68 },
  @{ Name = 'rotating-storm'; Id = 18; Sb = 51 },
  @{ Name = 'collision'; Id = 19; Sb = 51 },
  @{ Name = 'perfect'; Id = 20; Sb = 51 },
  @{ Name = 'self-define'; Id = 21; Sb = 51 },
  @{ Name = 'off'; Id = 22; Sb = 0 }
)
$script:EffectTable = @{}
foreach ($e in $script:EffectList) { $script:EffectTable[$e.Name] = $e }

# ============================================================================
#  Frame builders (byte-for-byte ports of fizzctl)
# ============================================================================
function New-EffectFrames {
  param([string]$Name, $Color = $null, $Speed = $null, $Brightness = $null)
  $e = $script:EffectTable[$Name]
  if ($null -eq $e) { throw "Unknown effect '$Name'" }
  $eid = [int]$e.Id
  $mode    = [byte[]]$script:Tpl.Mode.Clone()
  $canvas  = [byte[]]$script:Tpl.Canvas.Clone()
  $routing = [byte[]]$script:Tpl.Routing.Clone()
  $exec    = [byte[]]$script:Tpl.Exec.Clone()

  # Color record for effect N starts at MODE[29 + 21*(N-1)] (R,G,B). fizzctl verified this on
  # hardware for effects 1, 10 and 13 only; the stride fits all three, so it is used for all.
  $caps = $script:EffectCaps[$eid]
  if ($null -ne $Color -and $null -ne $caps -and [int]$caps[3] -eq 1) {
    $slot = 29 + 21 * ($eid - 1)
    $mode[$slot]     = [byte]([int]$Color[0] -band 0xFF)
    $mode[$slot + 1] = [byte]([int]$Color[1] -band 0xFF)
    $mode[$slot + 2] = [byte]([int]$Color[2] -band 0xFF)
    $exec[38 + 2 * ($eid - 1)] = 0
  }
  $exec[21] = [byte]$eid

  $defSpeed = [int]$e.Sb -shr 4
  $defBri   = [int]$e.Sb -band 0x0F
  if ($null -ne $Speed)      { $ns = [Math]::Max(1, [Math]::Min(5, [int]$Speed)) - 1 } else { $ns = $defSpeed }
  if ($null -ne $Brightness) { $nb = [Math]::Max(0, [Math]::Min(4, [int]$Brightness)) } else { $nb = $defBri }
  $packed = (($ns -band 0x0F) -shl 4) -bor ($nb -band 0x0F)
  $exec[39] = [byte]$packed
  if ($eid -ge 1 -and $eid -le 20) { $exec[39 + 2 * ($eid - 1)] = [byte]$packed }

  return , @($script:Tpl.Init, $mode, $canvas, $routing, $exec)
}

function New-PerKeyFrame {
  param($Colors = $null)
  $f = New-Object byte[] 382
  $f[0] = 0x08; $f[1] = 0x0a; $f[2] = 0x7a; $f[3] = 0x01
  if ($null -ne $Colors) {
    foreach ($k in @($Colors.Keys)) {
      $pos = $script:PerKeyPos[$k]
      if ($null -eq $pos) { throw "Unknown key '$k' for per-key paint" }
      $o = 4 + [int]$pos * 3
      $c = $Colors[$k]
      $f[$o]     = [byte]([int]$c[0] -band 0xFF)
      $f[$o + 1] = [byte]([int]$c[1] -band 0xFF)
      $f[$o + 2] = [byte]([int]$c[2] -band 0xFF)
    }
  }
  return , $f
}

function New-PaintFrames {
  param($Colors)
  $canvas = New-Object byte[] 1032
  $hdr = 0x06, 0x09, 0xbc, 0x00, 0x40
  for ($i = 0; $i -lt 5; $i++) { $canvas[$i] = [byte]$hdr[$i] }
  foreach ($k in @($Colors.Keys)) {
    $idx = $script:LedIndex[$k]
    if ($null -eq $idx) { throw "Unknown key '$k' for paint" }
    $c = $Colors[$k]
    $canvas[260 + [int]$idx] = [byte]([int]$c[0] -band 0xFF)   # red plane
    $canvas[134 + [int]$idx] = [byte]([int]$c[1] -band 0xFF)   # green plane
    $canvas[8 + [int]$idx]   = [byte]([int]$c[2] -band 0xFF)   # blue plane
  }
  [Array]::Copy($script:RgbSec, 0, $canvas, 660, $script:RgbSec.Length)
  return , @($script:Tpl.Init, $canvas, $script:Tpl.Routing, $script:RgbExec)
}

function Get-FrameKind {
  param([byte[]]$F)
  if ($F.Length -eq 0) { return 'empty' }
  if ($F[0] -eq 0x05) { return 'INIT(05)' }
  if ($F[0] -eq 0x08) { return 'PERKEY(08)' }
  if ($F[0] -eq 0x06 -and $F.Length -ge 3) { return ('BLOCK(06 {0:x2} {1:x2})' -f $F[1], $F[2]) }
  return ('report 0x{0:x2}' -f $F[0])
}

# ============================================================================
#  Keymap model: Cfg.ini <-> keyboard keymap block (ported from fizzctl, MIT)
# ============================================================================
$script:VkLong = @{
  8 = 'Backspace'
  9 = 'Tab'
  13 = 'Enter'
  20 = 'Caps Lock'
  27 = 'Esc'
  32 = 'Space'
  33 = 'Page Up'
  34 = 'Page Down'
  35 = 'End'
  36 = 'Home'
  37 = 'Left'
  38 = 'Up'
  39 = 'Right'
  40 = 'Down'
  44 = 'Print Screen'
  45 = 'Insert'
  46 = 'Delete'
  48 = '0'
  49 = '1'
  50 = '2'
  51 = '3'
  52 = '4'
  53 = '5'
  54 = '6'
  55 = '7'
  56 = '8'
  57 = '9'
  65 = 'A'
  66 = 'B'
  67 = 'C'
  68 = 'D'
  69 = 'E'
  70 = 'F'
  71 = 'G'
  72 = 'H'
  73 = 'I'
  74 = 'J'
  75 = 'K'
  76 = 'L'
  77 = 'M'
  78 = 'N'
  79 = 'O'
  80 = 'P'
  81 = 'Q'
  82 = 'R'
  83 = 'S'
  84 = 'T'
  85 = 'U'
  86 = 'V'
  87 = 'W'
  88 = 'X'
  89 = 'Y'
  90 = 'Z'
  91 = 'Left Win'
  93 = 'Menu'
  112 = 'F1'
  113 = 'F2'
  114 = 'F3'
  115 = 'F4'
  116 = 'F5'
  117 = 'F6'
  118 = 'F7'
  119 = 'F8'
  120 = 'F9'
  121 = 'F10'
  122 = 'F11'
  123 = 'F12'
  160 = 'Left Shift'
  161 = 'Right Shift'
  162 = 'Left Ctrl'
  163 = 'Right Ctrl'
  164 = 'Left Alt'
  165 = 'Right Alt'
  166 = 'Left Win (alt code)'
  186 = ';'
  187 = '='
  188 = ','
  189 = '-'
  190 = '.'
  191 = '/'
  192 = '`'
  219 = '['
  220 = '\'
  221 = ']'
  222 = ''''
  250 = 'Fn'
}

$script:VkShort = @{
  8 = 'Bksp'
  9 = 'Tab'
  13 = 'Enter'
  20 = 'Caps'
  27 = 'Esc'
  32 = 'Space'
  33 = 'PgUp'
  34 = 'PgDn'
  35 = 'End'
  36 = 'Home'
  37 = 'Left'
  38 = 'Up'
  39 = 'Right'
  40 = 'Down'
  44 = 'PrtSc'
  45 = 'Ins'
  46 = 'Del'
  48 = '0'
  49 = '1'
  50 = '2'
  51 = '3'
  52 = '4'
  53 = '5'
  54 = '6'
  55 = '7'
  56 = '8'
  57 = '9'
  65 = 'A'
  66 = 'B'
  67 = 'C'
  68 = 'D'
  69 = 'E'
  70 = 'F'
  71 = 'G'
  72 = 'H'
  73 = 'I'
  74 = 'J'
  75 = 'K'
  76 = 'L'
  77 = 'M'
  78 = 'N'
  79 = 'O'
  80 = 'P'
  81 = 'Q'
  82 = 'R'
  83 = 'S'
  84 = 'T'
  85 = 'U'
  86 = 'V'
  87 = 'W'
  88 = 'X'
  89 = 'Y'
  90 = 'Z'
  91 = 'LWin'
  93 = 'Menu'
  112 = 'F1'
  113 = 'F2'
  114 = 'F3'
  115 = 'F4'
  116 = 'F5'
  117 = 'F6'
  118 = 'F7'
  119 = 'F8'
  120 = 'F9'
  121 = 'F10'
  122 = 'F11'
  123 = 'F12'
  160 = 'LShift'
  161 = 'RShift'
  162 = 'LCtrl'
  163 = 'RCtrl'
  164 = 'LAlt'
  165 = 'RAlt'
  166 = 'LWin'
  186 = ';'
  187 = '='
  188 = ','
  189 = '-'
  190 = '.'
  191 = '/'
  192 = '`'
  219 = '['
  220 = '\'
  221 = ']'
  222 = ''''
  250 = 'Fn'
}

$script:Vk2Hid = @{
  8 = 42
  9 = 43
  13 = 40
  20 = 57
  27 = 41
  32 = 44
  33 = 75
  34 = 78
  35 = 77
  36 = 74
  37 = 80
  38 = 82
  39 = 79
  40 = 81
  44 = 70
  45 = 73
  46 = 76
  48 = 39
  49 = 30
  50 = 31
  51 = 32
  52 = 33
  53 = 34
  54 = 35
  55 = 36
  56 = 37
  57 = 38
  65 = 4
  66 = 5
  67 = 6
  68 = 7
  69 = 8
  70 = 9
  71 = 10
  72 = 11
  73 = 12
  74 = 13
  75 = 14
  76 = 15
  77 = 16
  78 = 17
  79 = 18
  80 = 19
  81 = 20
  82 = 21
  83 = 22
  84 = 23
  85 = 24
  86 = 25
  87 = 26
  88 = 27
  89 = 28
  90 = 29
  91 = 227
  93 = 101
  112 = 58
  113 = 59
  114 = 60
  115 = 61
  116 = 62
  117 = 63
  118 = 64
  119 = 65
  120 = 66
  121 = 67
  122 = 68
  123 = 69
  160 = 225
  161 = 229
  162 = 224
  163 = 228
  164 = 226
  165 = 230
  166 = 227
  186 = 51
  187 = 46
  188 = 54
  189 = 45
  190 = 55
  191 = 56
  192 = 53
  219 = 47
  220 = 49
  221 = 48
  222 = 52
}

$script:MediaWire = @{
  34 = 205
  35 = 183
  36 = 182
  37 = 181
  38 = 233
  39 = 234
  40 = 226
}

$script:MediaLong = @{
  34 = 'Play/Pause'
  35 = 'Stop'
  36 = 'Previous'
  37 = 'Next'
  38 = 'Volume up'
  39 = 'Volume down'
  40 = 'Mute'
}

$script:MediaShort = @{
  34 = 'Play'
  35 = 'Stop'
  36 = 'Prev'
  37 = 'Next'
  38 = 'Vol+'
  39 = 'Vol-'
  40 = 'Mute'
}

$script:SpecialList = @(
  @{ Extra = 184550144; Long = 'Backlight mode (next effect)'; Short = 'Mode' },
  @{ Extra = 218104576; Long = 'Backlight speed (cycle)'; Short = 'Speed' },
  @{ Extra = 201327360; Long = 'Backlight brightness (cycle)'; Short = 'Bright' },
  @{ Extra = 234881031; Long = 'Backlight color (cycle)'; Short = 'Color' },
  @{ Extra = 234881030; Long = 'White backlight'; Short = 'White' },
  @{ Extra = 234881025; Long = 'Lock Windows key'; Short = 'WinLk' }
)

$script:StockBase = @{
  1 = @(2, 27, 0)
  2 = @(2, 49, 0)
  3 = @(2, 50, 0)
  4 = @(2, 51, 0)
  5 = @(2, 52, 0)
  6 = @(2, 53, 0)
  7 = @(2, 54, 0)
  8 = @(2, 55, 0)
  9 = @(2, 56, 0)
  10 = @(2, 57, 0)
  11 = @(2, 48, 0)
  12 = @(2, 189, 0)
  13 = @(2, 187, 0)
  14 = @(2, 8, 0)
  15 = @(2, 9, 0)
  16 = @(2, 81, 0)
  17 = @(2, 87, 0)
  18 = @(2, 69, 0)
  19 = @(2, 82, 0)
  20 = @(2, 84, 0)
  21 = @(2, 89, 0)
  22 = @(2, 85, 0)
  23 = @(2, 73, 0)
  24 = @(2, 79, 0)
  25 = @(2, 80, 0)
  26 = @(2, 219, 0)
  27 = @(2, 221, 0)
  28 = @(2, 220, 0)
  29 = @(2, 20, 0)
  30 = @(2, 65, 0)
  31 = @(2, 83, 0)
  32 = @(2, 68, 0)
  33 = @(2, 70, 0)
  34 = @(2, 71, 0)
  35 = @(2, 72, 0)
  36 = @(2, 74, 0)
  37 = @(2, 75, 0)
  38 = @(2, 76, 0)
  39 = @(2, 186, 0)
  40 = @(2, 222, 0)
  41 = @(2, 13, 0)
  42 = @(2, 160, 0)
  43 = @(2, 90, 0)
  44 = @(2, 88, 0)
  45 = @(2, 67, 0)
  46 = @(2, 86, 0)
  47 = @(2, 66, 0)
  48 = @(2, 78, 0)
  49 = @(2, 77, 0)
  50 = @(2, 188, 0)
  51 = @(2, 190, 0)
  52 = @(2, 191, 0)
  53 = @(2, 161, 0)
  54 = @(2, 162, 0)
  55 = @(2, 91, 0)
  56 = @(2, 164, 0)
  57 = @(2, 32, 0)
  58 = @(2, 165, 0)
  59 = @(2, 250, 0)
  60 = @(2, 93, 0)
  61 = @(2, 163, 0)
}

$script:StockFn = @{
  1 = @(2, 192, 0)
  2 = @(2, 112, 0)
  3 = @(2, 113, 0)
  4 = @(2, 114, 0)
  5 = @(2, 115, 0)
  6 = @(2, 116, 0)
  7 = @(2, 117, 0)
  8 = @(2, 118, 0)
  9 = @(2, 119, 0)
  10 = @(2, 120, 0)
  11 = @(2, 121, 0)
  12 = @(2, 122, 0)
  13 = @(2, 123, 0)
  17 = @(2, 38, 0)
  26 = @(2, 45, 0)
  27 = @(2, 46, 0)
  30 = @(2, 37, 0)
  31 = @(2, 40, 0)
  32 = @(2, 39, 0)
  39 = @(2, 36, 0)
  40 = @(2, 35, 0)
  49 = @(9, 0, 201327360)
  50 = @(9, 0, 218104576)
  51 = @(2, 33, 0)
  52 = @(2, 34, 0)
  55 = @(9, 0, 234881025)
  57 = @(9, 0, 234881031)
  58 = @(9, 0, 184550144)
}

$script:PickVkGroups = [ordered]@{
  'Letters' = @(65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90)
  'Numbers' = @(48, 49, 50, 51, 52, 53, 54, 55, 56, 57)
  'Function keys' = @(112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123)
  'Navigation and editing' = @(27, 9, 20, 13, 8, 32, 33, 34, 35, 36, 37, 38, 39, 40, 45, 46, 44)
  'Modifiers' = @(160, 161, 162, 163, 164, 165, 91, 93)
  'Punctuation' = @(186, 187, 188, 189, 190, 191, 192, 219, 220, 221, 222)
}

# per-effect capabilities from the K617 vendor table: @(speed, brightness, multicolor, custom color)
$script:EffectCaps = @{
  1 = @(0, 1, 1, 1)
  2 = @(1, 1, 1, 1)
  3 = @(1, 1, 0, 0)
  4 = @(1, 1, 1, 1)
  5 = @(1, 1, 1, 1)
  6 = @(1, 1, 0, 0)
  7 = @(1, 1, 1, 1)
  8 = @(1, 1, 1, 1)
  9 = @(1, 1, 1, 1)
  10 = @(1, 1, 1, 1)
  11 = @(1, 1, 1, 1)
  12 = @(1, 1, 1, 1)
  13 = @(1, 1, 1, 1)
  14 = @(1, 1, 1, 1)
  15 = @(1, 1, 0, 0)
  16 = @(1, 1, 0, 0)
  17 = @(1, 1, 0, 0)
  18 = @(1, 1, 1, 1)
  19 = @(1, 1, 1, 1)
  20 = @(1, 1, 1, 1)
  21 = @(0, 0, 0, 0)
  22 = @(0, 0, 0, 0)
}

$script:Latin1 = [System.Text.Encoding]::GetEncoding(28591)   # lossless bytes <-> chars, keeps the vendor's GBK text intact

function Format-Behavior {
  param($B)
  if ([int]$B[0] -eq 9) { return ('0x09,0x00,0x{0:x8}' -f [long]$B[2]) }
  return ('0x{0:X2},0x{1:X2},0x00' -f [int]$B[0], [int]$B[1])
}

function Get-BehaviorName {
  param($B, [bool]$Short = $false)
  if ($null -eq $B) { return '' }
  $t = [int]$B[0]
  if ($t -eq 2) {
    $c = [int]$B[1]
    $tbl = $script:VkLong; if ($Short) { $tbl = $script:VkShort }
    if ($tbl.ContainsKey($c)) { return [string]$tbl[$c] }
    return ('VK 0x{0:X2}' -f $c)
  }
  if ($t -eq 4) {
    $c = [int]$B[1]
    $tbl = $script:MediaLong; if ($Short) { $tbl = $script:MediaShort }
    if ($tbl.ContainsKey($c)) { return [string]$tbl[$c] }
    return ('media 0x{0:X2}' -f $c)
  }
  if ($t -eq 9) {
    foreach ($s in $script:SpecialList) {
      if ([long]$s.Extra -eq [long]$B[2]) { if ($Short) { return [string]$s.Short } else { return [string]$s.Long } }
    }
    return ('fn 0x{0:x8}' -f [long]$B[2])
  }
  return ('type {0}' -f $t)
}

function Test-SameBehavior {
  param($A, $B)
  if ($null -eq $A -and $null -eq $B) { return $true }
  if ($null -eq $A -or $null -eq $B) { return $false }
  return ([int]$A[0] -eq [int]$B[0] -and [int]$A[1] -eq [int]$B[1] -and [long]$A[2] -eq [long]$B[2])
}

function Read-HexTriple {
  param([string]$Text)
  $vals = New-Object System.Collections.Generic.List[long]
  foreach ($mt in [regex]::Matches($Text, '0x([0-9a-fA-F]+)')) { $vals.Add([Convert]::ToInt64($mt.Groups[1].Value, 16)) }
  if ($vals.Count -lt 3) { return $null }
  return @([int]$vals[0], [int]$vals[1], [long]$vals[2])
}

function ConvertFrom-CfgText {
  param([string]$Text, [string]$Path = '')
  $m = @{ Path = $Path; Text = $Text; Keys = @{}; BaseDirty = @{}; FnDirty = $false; FnTrail = @{}; FnOrphans = @{} }
  if ($Text.Contains("`r`n")) { $m.Eol = "`r`n" } else { $m.Eol = "`n" }
  $fnRaw = @{}
  $section = ''
  foreach ($raw in ($Text -split "`n")) {
    $ln = $raw.TrimEnd("`r")
    if ($ln -match '^\s*\[([^\]]+)\]') { $section = $Matches[1].Trim().ToUpper(); continue }
    if ($ln -match '^\s*(;|//|#)') { continue }
    if ($section -eq 'KEY') {
      if ($ln -match '^\s*K(\d+)\s*=\s*([^,]+),([^,]+),([^,]+),([^,]+),\s*((?:0x[0-9a-fA-F]+)(?:\s*,\s*0x[0-9a-fA-F]+)+)\s*(?:,\s*([0-9,\s]+))?\s*$') {
        $idx = [int]$Matches[1]
        $rect = @([int]$Matches[2].Trim(), [int]$Matches[3].Trim(), [int]$Matches[4].Trim(), [int]$Matches[5].Trim())
        $tri = Read-HexTriple $Matches[6]
        $col = -1; $led = -1
        if ($Matches[7]) {
          $parts = $Matches[7].Split(',')
          $col = [int]$parts[0].Trim()
          if ($parts.Length -gt 1 -and $parts[1].Trim()) { $led = [int]$parts[1].Trim() }
        }
        if ($null -ne $tri) { $m.Keys[$idx] = @{ Idx = $idx; Rect = $rect; Col = $col; Led = $led; Base = $tri; Fn = $null } }
      }
    } elseif ($section -eq 'FN') {
      if ($ln -match '^\s*K(\d+)\s*=\s*((?:0x[0-9a-fA-F]+)(?:\s*,\s*0x[0-9a-fA-F]+)*)(.*)$') {
        $idx = [int]$Matches[1]
        $tri = Read-HexTriple $Matches[2]
        $trail = [string]$Matches[3]
        if ($null -ne $tri) { $fnRaw[$idx] = @{ Tri = $tri; Trail = $trail; Line = $ln } }
      }
    }
  }
  foreach ($i in $fnRaw.Keys) {
    if ($m.Keys.ContainsKey($i)) { $m.Keys[$i].Fn = $fnRaw[$i].Tri; $m.FnTrail[$i] = $fnRaw[$i].Trail }
    else { $m.FnOrphans[$i] = $fnRaw[$i].Line }
  }
  return $m
}

function ConvertTo-CfgText {
  # Untouched file -> returns the original text byte for byte.
  # Edited base keys -> only the 3 hex values on that [KEY] line change.
  # Edited Fn layer  -> the [FN] section is regenerated (K entries in serial order).
  param($M)
  if ($M.BaseDirty.Count -eq 0 -and -not $M.FnDirty) { return $M.Text }
  $cr = ''; if ($M.Eol -eq "`r`n") { $cr = "`r" }
  $out = New-Object System.Collections.Generic.List[string]
  $section = ''
  $skipFn = $false
  foreach ($raw in ($M.Text -split "`n")) {
    $ln = $raw.TrimEnd("`r")
    if ($ln -match '^\s*\[([^\]]+)\]') {
      $newSec = $Matches[1].Trim().ToUpper()
      if ($skipFn) { $out.Add($cr); $skipFn = $false }
      $section = $newSec
      $out.Add($raw)
      if ($section -eq 'FN' -and $M.FnDirty) {
        $skipFn = $true
        $all = New-Object System.Collections.Generic.List[int]
        foreach ($i in $M.Keys.Keys) { if ($null -ne $M.Keys[$i].Fn) { $all.Add([int]$i) } }
        foreach ($i in $M.FnOrphans.Keys) { $all.Add([int]$i) }
        foreach ($i in ($all | Sort-Object)) {
          if ($M.FnOrphans.ContainsKey($i)) { $out.Add([string]$M.FnOrphans[$i] + $cr); continue }
          $label = 'K' + $i
          if ($script:StockBase.ContainsKey($i)) { $label = Get-BehaviorName $script:StockBase[$i] }
          $trail = ''; if ($M.FnTrail.ContainsKey($i)) { $trail = [string]$M.FnTrail[$i] }
          $out.Add(';' + $label + $cr)
          $out.Add('K' + $i + '=' + (Format-Behavior $M.Keys[$i].Fn) + $trail + $cr)
        }
      }
      continue
    }
    if ($skipFn) { continue }
    if ($section -eq 'KEY' -and $ln -match '^\s*K(\d+)\s*=') {
      $idx = [int]$Matches[1]
      if ($M.BaseDirty.ContainsKey($idx) -and $M.Keys.ContainsKey($idx)) {
        $pat = '^(\s*K' + $idx + '\s*=\s*[^,]+,[^,]+,[^,]+,[^,]+,\s*)(?:0x[0-9a-fA-F]+\s*,\s*){2}0x[0-9a-fA-F]+'
        $out.Add([regex]::Replace($raw, $pat, ('${1}' + (Format-Behavior $M.Keys[$idx].Base))))
        continue
      }
    }
    $out.Add($raw)
  }
  return ($out -join "`n")
}

function Read-CfgFile {
  param([string]$Path)
  $text = $script:Latin1.GetString([System.IO.File]::ReadAllBytes($Path))
  return (ConvertFrom-CfgText -Text $text -Path $Path)
}

function Write-CfgFile {
  param($M, [string]$Path)
  [System.IO.File]::WriteAllBytes($Path, $script:Latin1.GetBytes((ConvertTo-CfgText $M)))
}

function Get-FnKeyOrder {
  # Row-major order used by the keyboard's Fn tables: row bucket = rect y / 36, then rect x.
  param($M)
  $list = New-Object System.Collections.Generic.List[object]
  foreach ($i in $M.Keys.Keys) {
    $k = $M.Keys[$i]
    if ($null -ne $k.Fn) { $list.Add(@{ Idx = [int]$i; Order = ([Math]::Floor($k.Rect[1] / 36) * 100000 + $k.Rect[0]) }) }
  }
  return @($list | Sort-Object { $_.Order }, { $_.Idx } | ForEach-Object { $_.Idx })
}

function Get-Hid {
  param([int]$Vk)
  if ($script:Vk2Hid.ContainsKey($Vk)) { return [byte]$script:Vk2Hid[$Vk] }
  return [byte]0
}

function Test-IsModifier {
  param([int]$Vk)
  return (($Vk -ge 0xA0 -and $Vk -le 0xA6) -or $Vk -eq 0x5B)
}

function New-KeymapBlock {
  # Byte-for-byte port of fizzctl's KeymapEncoder.build() (the 1032-byte "06 04 d4" block).
  param($M)
  $b = New-Object byte[] 1032
  $hdr = 0x06, 0x04, 0xd4, 0x00, 0x40, 0x00, 0x00, 0x00
  for ($i = 0; $i -lt 8; $i++) { $b[$i] = [byte]$hdr[$i] }
  $order = @(Get-FnKeyOrder $M)
  if ($order.Count -gt 48) { throw ('The Fn layer holds at most 48 keys (this layout has {0}).' -f $order.Count) }
  $fnIndex = @{}
  for ($p = 0; $p -lt $order.Count; $p++) { $fnIndex[[int]$order[$p]] = $p }

  $cols = @{}
  foreach ($i in $M.Keys.Keys) { $k = $M.Keys[$i]; if ($k.Col -ge 0) { $cols[[int]$k.Col] = $k } }
  for ($col = 0; $col -lt 256; $col++) {
    $off = 8 + $col * 4
    if (-not $cols.ContainsKey($col)) { continue }
    $key = $cols[$col]
    $vk = [int]$key.Base[1]
    if ($vk -eq 0xFA) { $b[$off] = 0x20 }
    elseif ($fnIndex.ContainsKey([int]$key.Idx)) { $b[$off] = 2; $b[$off + 3] = [byte]$fnIndex[[int]$key.Idx] }
    elseif (Test-IsModifier $vk) { $b[$off] = 6; $b[$off + 3] = Get-Hid $vk }
    else { $b[$off + 3] = Get-Hid $vk }
  }
  for ($p = 0; $p -lt $order.Count; $p++) {
    $key = $M.Keys[[int]$order[$p]]
    $vk = [int]$key.Base[1]
    $bOff = 0x218 + $p * 4
    $cOff = 0x2d8 + $p * 4
    if (Test-IsModifier $vk) { $b[$bOff] = 6 }
    $b[$bOff + 3] = Get-Hid $vk
    $fn = $key.Fn
    $t = [int]$fn[0]
    if ($t -eq 4) {
      $wire = 0
      if ($script:MediaWire.ContainsKey([int]$fn[1])) { $wire = [int]$script:MediaWire[[int]$fn[1]] }
      $b[$cOff] = 4; $b[$cOff + 3] = [byte]$wire
    } elseif ($t -eq 9) {
      $x = [long]$fn[2]
      $b[$cOff] = [byte](($x -shr 24) -band 0xFF); $b[$cOff + 1] = [byte](($x -shr 16) -band 0xFF)
      $b[$cOff + 2] = [byte](($x -shr 8) -band 0xFF); $b[$cOff + 3] = [byte]($x -band 0xFF)
    } else {
      $b[$cOff + 3] = Get-Hid ([int]$fn[1])
    }
  }
  return , $b
}

function Get-KeymapIssues {
  # Returns objects with Level ('error' blocks saving, 'warn' asks first) and Text.
  param($M)
  $issues = New-Object System.Collections.Generic.List[object]
  $fnCount = 0
  $fnKeys = 0
  foreach ($i in ($M.Keys.Keys | Sort-Object)) {
    $k = $M.Keys[$i]
    $name = Get-BehaviorName $script:StockBase[[int]$i]
    $bt = [int]$k.Base[0]; $bc = [int]$k.Base[1]
    if ($bt -ne 2 -or (-not $script:Vk2Hid.ContainsKey($bc) -and $bc -ne 0xFA)) {
      $issues.Add(@{ Level = 'error'; Text = ('K{0} ({1}): base output {2} is not supported and would be a dead key.' -f $i, $name, (Get-BehaviorName $k.Base)) })
    }
    if ($bc -eq 0xFA -and $bt -eq 2) {
      $fnKeys++
      if ($null -ne $k.Fn) { $issues.Add(@{ Level = 'error'; Text = ('K{0} ({1}) is the Fn key but also has an Fn-layer entry; the keyboard would not switch layers.' -f $i, $name) }) }
    }
    if ($null -ne $k.Fn) {
      $fnCount++
      $ft = [int]$k.Fn[0]; $fc = [int]$k.Fn[1]
      $bad = $false
      if ($ft -eq 2 -and -not $script:Vk2Hid.ContainsKey($fc)) { $bad = $true }
      elseif ($ft -eq 4 -and -not $script:MediaWire.ContainsKey($fc)) { $bad = $true }
      elseif ($ft -eq 9) {
        $known = $false
        foreach ($s in $script:SpecialList) { if ([long]$s.Extra -eq [long]$k.Fn[2]) { $known = $true } }
        if (-not $known) { $bad = $true }
      } elseif ($ft -ne 2 -and $ft -ne 4 -and $ft -ne 9) { $bad = $true }
      if ($bad) { $issues.Add(@{ Level = 'warn'; Text = ('K{0} ({1}): Fn output {2} is not one of the verified codes and may be dead.' -f $i, $name, (Get-BehaviorName $k.Fn)) }) }
    }
  }
  if ($fnCount -gt 48) { $issues.Add(@{ Level = 'error'; Text = ('The Fn layer holds at most 48 keys; you have {0}.' -f $fnCount) }) }
  if ($fnCount -gt 0 -and $fnKeys -eq 0) { $issues.Add(@{ Level = 'warn'; Text = 'No key on the base layer is the Fn key, so the Fn layer cannot be reached.' }) }
  return , $issues
}

# ============================================================================
#  Preview layout, effect animation (approximate), lighting sync and settings
# ============================================================================
$script:KeyNames = @(
  'Esc',
  '1',
  '2',
  '3',
  '4',
  '5',
  '6',
  '7',
  '8',
  '9',
  '0',
  '-',
  '=',
  'Bksp',
  'Tab',
  'Q',
  'W',
  'E',
  'R',
  'T',
  'Y',
  'U',
  'I',
  'O',
  'P',
  '[',
  ']',
  '\',
  'CapsLk',
  'A',
  'S',
  'D',
  'F',
  'G',
  'H',
  'J',
  'K',
  'L',
  ';',
  '''',
  'Enter',
  'LShift',
  'Z',
  'X',
  'C',
  'V',
  'B',
  'N',
  'M',
  ',',
  '.',
  '/',
  'RShift',
  'LCtrl',
  'LWin',
  'LAlt',
  'Space',
  'RAlt',
  'Fn',
  'Menu',
  'RCtrl'
)

# key rectangles (x1,y1,x2,y2) in the vendor's 560x200 design space, K1..K61
$script:KeyRects = @(
  @(13, 14, 37, 42),
  @(49, 14, 73, 42),
  @(85, 14, 109, 42),
  @(122, 14, 146, 42),
  @(158, 14, 182, 42),
  @(195, 14, 219, 42),
  @(232, 15, 256, 43),
  @(268, 14, 292, 42),
  @(304, 14, 328, 42),
  @(341, 14, 365, 42),
  @(378, 14, 402, 42),
  @(414, 14, 438, 42),
  @(450, 14, 474, 42),
  @(487, 14, 546, 42),
  @(13, 51, 54, 79),
  @(67, 51, 91, 79),
  @(104, 51, 128, 79),
  @(140, 51, 164, 79),
  @(177, 50, 201, 78),
  @(213, 50, 237, 78),
  @(250, 50, 274, 78),
  @(286, 50, 310, 78),
  @(322, 50, 346, 78),
  @(359, 51, 383, 79),
  @(395, 51, 419, 79),
  @(432, 51, 456, 79),
  @(468, 51, 492, 79),
  @(505, 51, 547, 79),
  @(14, 86, 65, 114),
  @(77, 87, 101, 115),
  @(113, 87, 137, 115),
  @(149, 87, 173, 115),
  @(186, 87, 210, 115),
  @(223, 87, 247, 115),
  @(259, 87, 283, 115),
  @(296, 87, 320, 115),
  @(332, 87, 356, 115),
  @(368, 87, 392, 115),
  @(405, 87, 429, 115),
  @(441, 87, 465, 115),
  @(478, 87, 546, 115),
  @(14, 123, 83, 151),
  @(94, 123, 118, 151),
  @(132, 123, 156, 151),
  @(168, 123, 192, 151),
  @(204, 123, 228, 151),
  @(240, 123, 264, 151),
  @(277, 123, 301, 151),
  @(313, 123, 337, 151),
  @(349, 123, 373, 151),
  @(386, 123, 410, 151),
  @(422, 123, 446, 151),
  @(459, 123, 546, 151),
  @(12, 160, 44, 188),
  @(59, 160, 91, 188),
  @(105, 160, 137, 188),
  @(150, 160, 364, 188),
  @(377, 160, 409, 188),
  @(423, 160, 456, 188),
  @(468, 160, 501, 188),
  @(514, 160, 547, 188)
)

if (-not ('FizzAnim' -as [type])) {
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;

// Approximate preview of the keyboard's built-in effects. The firmware's real animations are not
// documented, so these are look-alikes driven by the selected speed, brightness and color.
public static class FizzAnim
{
    static double[] X = new double[0];
    static double[] Y = new double[0];
    static int[] Row = new int[0];
    static int[] PathPos = new int[0];
    static int N = 0;

    static readonly double[] SpeedScale = new double[] { 0.45, 0.7, 1.0, 1.5, 2.2 };
    static readonly double[] BriScale = new double[] { 0.14, 0.34, 0.56, 0.78, 1.0 };

    public static int Count { get { return N; } }

    // xs, ys: key centers normalised to 0..1; rows: row index (0..4) of each key
    public static void SetLayout(double[] xs, double[] ys, int[] rows)
    {
        N = xs.Length;
        X = xs;
        Y = ys;
        Row = rows;
        PathPos = new int[N];
        int maxRow = 0;
        for (int i = 0; i < N; i++) if (rows[i] > maxRow) maxRow = rows[i];
        int offset = 0;
        for (int r = 0; r <= maxRow; r++)
        {
            List<int> idx = new List<int>();
            for (int i = 0; i < N; i++) if (rows[i] == r) idx.Add(i);
            for (int a = 1; a < idx.Count; a++)
            {
                int k = idx[a];
                int b = a - 1;
                while (b >= 0 && xs[idx[b]] > xs[k]) { idx[b + 1] = idx[b]; b--; }
                idx[b + 1] = k;
            }
            if (r % 2 == 1) idx.Reverse();
            for (int a = 0; a < idx.Count; a++) PathPos[idx[a]] = offset + a;
            offset += idx.Count;
        }
    }

    static double Frac(double v) { return v - Math.Floor(v); }
    static double Clamp01(double v) { return v < 0 ? 0 : (v > 1 ? 1 : v); }
    static double Ping(double v)
    {
        v = v - Math.Floor(v / 2.0) * 2.0;
        return v <= 1.0 ? v : 2.0 - v;
    }

    static double Hash(int i, int salt)
    {
        unchecked
        {
            uint x = (uint)(i * 374761393 + salt * 668265263);
            x = (x ^ (x >> 13)) * 1274126177u;
            x = x ^ (x >> 16);
            return (x & 0xFFFFFF) / 16777216.0;
        }
    }

    static void Hsv(double h, double s, double v, out double r, out double g, out double b)
    {
        h = Frac(h);
        double hh = h * 6.0;
        int i = (int)Math.Floor(hh);
        double f = hh - i;
        double p = v * (1.0 - s);
        double q = v * (1.0 - s * f);
        double t = v * (1.0 - s * (1.0 - f));
        switch (i % 6)
        {
            case 0: r = v; g = t; b = p; break;
            case 1: r = q; g = v; b = p; break;
            case 2: r = p; g = v; b = t; break;
            case 3: r = p; g = q; b = v; break;
            case 4: r = t; g = p; b = v; break;
            default: r = v; g = p; b = q; break;
        }
    }

    static byte ToByte(double v)
    {
        double d = Math.Round(v * 255.0);
        if (d < 0) d = 0;
        if (d > 255) d = 255;
        return (byte)d;
    }

    // Returns r,g,b for every key (3 bytes per key). id 1..20; 21 and 22 are handled by the caller.
    public static byte[] Render(int id, double t, int speed, int bri, bool custom, int cr, int cg, int cb)
    {
        byte[] outv = new byte[N * 3];
        int si = Math.Max(1, Math.Min(5, speed)) - 1;
        int bi = Math.Max(0, Math.Min(4, bri));
        double T = t * SpeedScale[si];
        double B = BriScale[bi];
        for (int i = 0; i < N; i++)
        {
            double x = X[i], y = Y[i];
            double hue = 0.0, v = 1.0;
            double dx = (x - 0.5) * 2.2, dy = (y - 0.5);
            double rad = Math.Sqrt(dx * dx + dy * dy);
            double ang = Math.Atan2(dy, dx) / (2.0 * Math.PI);
            double h0 = Hash(i, 1);
            switch (id)
            {
                case 1:  // fixed on
                    hue = 0.0; v = 1.0; break;
                case 2:  // respire (breathing)
                    hue = Frac(T * 0.05); v = 0.08 + 0.92 * (0.5 + 0.5 * Math.Sin(2.0 * Math.PI * T / 4.0 - 1.57)); break;
                case 3:  // rainbow
                    hue = x * 0.9 + y * 0.2 + T * 0.15; v = 1.0; break;
                case 4:  // flash away
                {
                    double p = Frac(T * 0.8 + h0);
                    v = Math.Pow(Math.Max(0.0, 1.0 - p * 2.2), 2.0); hue = h0; break;
                }
                case 5:  // raindrops
                {
                    int col = (int)Math.Floor(x * 14.0);
                    double ph = Hash(col, 7);
                    double pos = Frac(T * 0.55 + ph) * 1.5;
                    double d = pos - y;
                    v = (d >= 0 && d < 0.55) ? 1.0 - d / 0.55 : 0.05;
                    hue = Hash(col, 3); break;
                }
                case 6:  // rainbow wheel
                    hue = ang + T * 0.2; v = 1.0; break;
                case 7:  // ripples shining
                    v = Math.Pow(0.5 + 0.5 * Math.Sin(2.0 * Math.PI * (rad * 1.8 - T * 0.5)), 2.0);
                    hue = rad * 0.6 + T * 0.1; break;
                case 8:  // stars twinkle
                    v = 0.04 + 0.96 * Math.Pow(0.5 + 0.5 * Math.Sin(T * (1.0 + 3.0 * h0) * 2.0 + h0 * 40.0), 6.0);
                    hue = Hash(i, 5); break;
                case 9:  // shadow disappear
                {
                    double p = Frac(T * 0.4 + h0);
                    v = Math.Pow(1.0 - p, 2.0); hue = h0; break;
                }
                case 10: // retro snake
                {
                    double len = 9.0;
                    double head = Frac(T * 0.2) * N;
                    double d = head - PathPos[i];
                    if (d < 0) d += N;
                    v = d < len ? 1.0 - d / len : 0.04;
                    hue = 0.33; break;
                }
                case 11: // neon stream
                    hue = x * 1.5 - T * 0.3 + y * 0.3;
                    v = 0.3 + 0.7 * (0.5 + 0.5 * Math.Sin(2.0 * Math.PI * (x * 3.0 - T * 0.8))); break;
                case 12: // reaction (idle look: dim keys with occasional pulses)
                {
                    double p = Frac(T * 0.35 + h0);
                    v = Math.Max(0.14, 1.0 - p * 3.0); hue = h0 * 0.6 + 0.5; break;
                }
                case 13: // sine wave
                {
                    double yc = 0.5 + 0.34 * Math.Sin(2.0 * Math.PI * (x * 1.3 - T * 0.4));
                    v = 0.05 + 0.95 * Math.Exp(-Math.Pow((y - yc) * 4.0, 2.0));
                    hue = x + T * 0.1; break;
                }
                case 14: // retinue scanning
                {
                    double pos = Ping(T * 0.35);
                    v = 0.04 + 0.96 * Math.Exp(-Math.Pow((x - pos) * 7.0, 2.0));
                    hue = pos; break;
                }
                case 15: // rotating windmill
                    v = 0.05 + 0.95 * Math.Pow(0.5 + 0.5 * Math.Cos(2.0 * Math.PI * 3.0 * (ang - T * 0.18)), 3.0);
                    hue = ang + T * 0.1; break;
                case 16: // colorful waterfall
                {
                    int col = (int)Math.Floor(x * 14.0);
                    double ph = Hash(col, 11);
                    v = 0.15 + 0.85 * Frac(-y * 1.0 + T * 0.5 + ph);
                    hue = Hash(col, 13) + T * 0.05; break;
                }
                case 17: // blossoming
                    hue = rad * 0.8 - T * 0.25;
                    v = 0.25 + 0.75 * Math.Pow(0.5 + 0.5 * Math.Sin(2.0 * Math.PI * (rad * 1.6 - T * 0.4)), 2.0); break;
                case 18: // rotating storm
                    hue = ang + rad * 0.9 - T * 0.3;
                    v = 0.3 + 0.7 * (0.5 + 0.5 * Math.Cos(2.0 * Math.PI * 2.0 * (ang + rad * 0.9 - T * 0.3))); break;
                case 19: // collision
                {
                    double pos = Frac(T * 0.3) * 0.5;
                    double a = Math.Exp(-Math.Pow((x - pos) * 8.0, 2.0));
                    double b2 = Math.Exp(-Math.Pow((x - (1.0 - pos)) * 8.0, 2.0));
                    v = 0.05 + 0.95 * Math.Max(a, b2);
                    hue = (x < 0.5) ? 0.0 : 0.5; break;
                }
                case 20: // perfect (gentle shifting gradient)
                    hue = x * 0.5 + T * 0.08; v = 0.65 + 0.35 * Math.Sin(2.0 * Math.PI * (T * 0.15 + y * 0.3)); break;
                default:
                    v = 0.0; break;
            }
            v = Clamp01(v);
            double r, g, b;
            if (custom)
            {
                r = cr / 255.0 * v; g = cg / 255.0 * v; b = cb / 255.0 * v;
            }
            else
            {
                Hsv(hue, 1.0, v, out r, out g, out b);
            }
            outv[i * 3] = ToByte(r * B);
            outv[i * 3 + 1] = ToByte(g * B);
            outv[i * 3 + 2] = ToByte(b * B);
        }
        return outv;
    }
}
'@
}

function Initialize-AnimLayout {
  # key centers normalised to 0..1 inside the vendor's design space (x 12..547, y 14..188)
  $xs = New-Object 'double[]' 61
  $ys = New-Object 'double[]' 61
  $rows = New-Object 'int[]' 61
  for ($i = 0; $i -lt 61; $i++) {
    $r = $script:KeyRects[$i]
    $xs[$i] = ((($r[0] + $r[2]) / 2.0) - 12.0) / (547.0 - 12.0)
    $ys[$i] = ((($r[1] + $r[3]) / 2.0) - 14.0) / (188.0 - 14.0)
    $rows[$i] = [int][Math]::Floor($r[1] / 36)
  }
  [FizzAnim]::SetLayout($xs, $ys, $rows)
}

function ConvertFrom-LightingFrames {
  # Decodes what the keyboard reports for its current effect. Offsets mirror the write path:
  # EXEC[21] = effect id, EXEC[39+2*(id-1)] = remembered (speed-1)<<4 | brightness,
  # EXEC[38+2*(id-1)] = 0 means "single custom color", MODE[29+21*(id-1)..+2] = that color.
  param([byte[]]$Mode, [byte[]]$Exec)
  $id = [int]$Exec[21]
  $res = @{ EffectId = $id; Known = ($id -ge 1 -and $id -le 22); Speed = 3; Brightness = 3; Custom = $false; Color = @(255, 0, 0); Packed = 0 }
  if ($id -ge 1 -and $id -le 20) { $packed = [int]$Exec[39 + 2 * ($id - 1)] } else { $packed = [int]$Exec[39] }
  $res.Packed = $packed
  $res.Speed = [Math]::Max(1, [Math]::Min(5, (($packed -shr 4) -band 0x0F) + 1))
  $res.Brightness = [Math]::Max(0, [Math]::Min(4, $packed -band 0x0F))
  $caps = $script:EffectCaps[$id]
  if ($id -ge 1 -and $id -le 20) {
    $res.Custom = ([int]$Exec[38 + 2 * ($id - 1)] -eq 0)
  }
  if ($id -ge 1 -and $id -le 21) {
    $slot = 29 + 21 * ($id - 1)
    $res.Color = @([int]$Mode[$slot], [int]$Mode[$slot + 1], [int]$Mode[$slot + 2])
  }
  if ($null -eq $caps -or [int]$caps[3] -ne 1) { $res.Custom = $false }
  return $res
}

function Read-DeviceLighting {
  # Read-only: select a block with a 05 8x xx frame, wait, then GET report 6 (same as fizzctl).
  param($Device)
  $blocks = @{}
  $wanted = @(@('Mode', 0x88, 0xb8), @('Exec', 0x83, 0xb6))
  foreach ($w in $wanted) {
    $sel = [byte[]]@(0x05, [int]$w[1], [int]$w[2], 0, 0, 0)
    $Device.SetFeature($sel)
    Start-Sleep -Milliseconds 60
    $blocks[[string]$w[0]] = [byte[]]$Device.GetFeature(0x06, 1032)
  }
  return (ConvertFrom-LightingFrames -Mode $blocks['Mode'] -Exec $blocks['Exec'])
}

function Get-EffectSignature {
  param([int]$Id, [int]$Speed, [int]$Bri, [bool]$Custom, $Color)
  if ($Custom) { return ('{0}|{1}|{2}|{3},{4},{5}' -f $Id, $Speed, $Bri, $Color[0], $Color[1], $Color[2]) }
  return ('{0}|{1}|{2}|multi' -f $Id, $Speed, $Bri)
}

function Get-SettingsPath {
  $base = $env:APPDATA
  if (-not $base) { $base = Join-Path $HOME '.config' }
  return (Join-Path (Join-Path $base 'FizzLighting') 'settings.json')
}

function Read-Settings {
  $d = @{ AutoApply = $false; AutoApplyAck = $false; ShowLog = $false; LastCfg = ''; Tab = 'effects' }
  try {
    $p = Get-SettingsPath
    if (Test-Path $p) {
      $j = Get-Content -Raw $p | ConvertFrom-Json
      foreach ($k in @($d.Keys)) { if ($null -ne $j.$k) { $d[$k] = $j.$k } }
    }
  } catch { }
  return $d
}

function Write-Settings {
  param($S)
  try {
    $p = Get-SettingsPath
    $dir = Split-Path $p
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    ($S | ConvertTo-Json) | Set-Content -Path $p -Encoding UTF8
  } catch { }
}

# ============================================================================
#  Windows HID access (hid.dll / setupapi.dll via P/Invoke, no drivers)
#  Written in plain C# 5 so Windows PowerShell 5.1 can compile it.
# ============================================================================
if (-not ('FizzDevice' -as [type])) {
Add-Type -TypeDefinition @'
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;
using Microsoft.Win32.SafeHandles;

public class FizzHidInfo
{
    public string Path = "";
    public ushort UsagePage;
    public ushort Usage;
    public int FeatureLen;
    public int InputLen;
    public int OutputLen;
    public string FeatureIds = "";

    public bool HasId(int id)
    {
        if (FeatureIds.Length == 0) return false;
        foreach (string s in FeatureIds.Split(','))
            if (s == id.ToString()) return true;
        return false;
    }

    public string ShortName()
    {
        string p = Path.ToLowerInvariant();
        int i = p.IndexOf("mi_");
        string mi = (i >= 0 && p.Length >= i + 5) ? p.Substring(i, 5) : "mi_--";
        int c = p.IndexOf("&col");
        string col = (c >= 0 && p.Length >= c + 6) ? p.Substring(c + 1, 5) : "col--";
        return mi + "/" + col;
    }

    public string Describe()
    {
        return string.Format("{0}  usage page 0x{1:X4}, usage 0x{2:X}, feature len {3}, in {4}, out {5}, feature report ids [{6}]",
            ShortName(), UsagePage, Usage, FeatureLen, InputLen, OutputLen, FeatureIds);
    }
}

public class FizzSlot
{
    public FizzHidInfo Info;
    public SafeFileHandle Handle;
    public string OpenMode;
}

public class FizzDevice : IDisposable
{
    public const ushort VID = 0x258A;
    public const ushort PID = 0x0049;

    [StructLayout(LayoutKind.Sequential)]
    struct SP_DEVICE_INTERFACE_DATA
    {
        public int cbSize;
        public Guid InterfaceClassGuid;
        public int Flags;
        public IntPtr Reserved;
    }

    [StructLayout(LayoutKind.Sequential)]
    struct HIDD_ATTRIBUTES
    {
        public int Size;
        public ushort VendorID;
        public ushort ProductID;
        public ushort VersionNumber;
    }

    [StructLayout(LayoutKind.Sequential)]
    struct HIDP_CAPS
    {
        public ushort Usage;
        public ushort UsagePage;
        public ushort InputReportByteLength;
        public ushort OutputReportByteLength;
        public ushort FeatureReportByteLength;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 17)]
        public ushort[] Reserved;
        public ushort NumberLinkCollectionNodes;
        public ushort NumberInputButtonCaps;
        public ushort NumberInputValueCaps;
        public ushort NumberInputDataIndices;
        public ushort NumberOutputButtonCaps;
        public ushort NumberOutputValueCaps;
        public ushort NumberOutputDataIndices;
        public ushort NumberFeatureButtonCaps;
        public ushort NumberFeatureValueCaps;
        public ushort NumberFeatureDataIndices;
    }

    [DllImport("hid.dll")]
    static extern void HidD_GetHidGuid(out Guid g);
    [DllImport("hid.dll", SetLastError = true)]
    static extern bool HidD_GetAttributes(SafeFileHandle h, ref HIDD_ATTRIBUTES a);
    [DllImport("hid.dll", SetLastError = true)]
    static extern bool HidD_GetPreparsedData(SafeFileHandle h, out IntPtr pp);
    [DllImport("hid.dll", SetLastError = true)]
    static extern bool HidD_FreePreparsedData(IntPtr pp);
    [DllImport("hid.dll")]
    static extern int HidP_GetCaps(IntPtr pp, out HIDP_CAPS caps);
    [DllImport("hid.dll")]
    static extern int HidP_GetValueCaps(int reportType, IntPtr caps, ref ushort length, IntPtr pp);
    [DllImport("hid.dll")]
    static extern int HidP_GetButtonCaps(int reportType, IntPtr caps, ref ushort length, IntPtr pp);
    [DllImport("hid.dll", SetLastError = true)]
    static extern bool HidD_SetFeature(SafeFileHandle h, byte[] buf, int len);
    [DllImport("hid.dll", SetLastError = true)]
    static extern bool HidD_GetFeature(SafeFileHandle h, byte[] buf, int len);

    [DllImport("setupapi.dll", SetLastError = true)]
    static extern IntPtr SetupDiGetClassDevs(ref Guid g, IntPtr enumerator, IntPtr hwnd, int flags);
    [DllImport("setupapi.dll", SetLastError = true)]
    static extern bool SetupDiEnumDeviceInterfaces(IntPtr set, IntPtr info, ref Guid g, int index, ref SP_DEVICE_INTERFACE_DATA data);
    [DllImport("setupapi.dll", CharSet = CharSet.Auto, SetLastError = true)]
    static extern bool SetupDiGetDeviceInterfaceDetail(IntPtr set, ref SP_DEVICE_INTERFACE_DATA data, IntPtr detail, int size, out int required, IntPtr info);
    [DllImport("setupapi.dll")]
    static extern bool SetupDiDestroyDeviceInfoList(IntPtr set);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    static extern SafeFileHandle CreateFile(string name, uint access, uint share, IntPtr sec, uint disp, uint flags, IntPtr tmpl);

    List<FizzSlot> slots = new List<FizzSlot>();
    Dictionary<byte, FizzSlot> route = new Dictionary<byte, FizzSlot>();
    public string LastSendMode = "";
    public string LastRoute = "";

    public int SlotCount { get { return slots.Count; } }

    // ---- discovery: every HID collection of this keyboard, with its feature report ids ----
    public static List<FizzHidInfo> Find()
    {
        List<FizzHidInfo> result = new List<FizzHidInfo>();
        Guid hidGuid;
        HidD_GetHidGuid(out hidGuid);
        // DIGCF_PRESENT (0x2) | DIGCF_DEVICEINTERFACE (0x10)
        IntPtr set = SetupDiGetClassDevs(ref hidGuid, IntPtr.Zero, IntPtr.Zero, 0x12);
        if (set == new IntPtr(-1)) return result;
        try
        {
            for (int i = 0; ; i++)
            {
                SP_DEVICE_INTERFACE_DATA did = new SP_DEVICE_INTERFACE_DATA();
                did.cbSize = Marshal.SizeOf(typeof(SP_DEVICE_INTERFACE_DATA));
                if (!SetupDiEnumDeviceInterfaces(set, IntPtr.Zero, ref hidGuid, i, ref did)) break;

                int required;
                SetupDiGetDeviceInterfaceDetail(set, ref did, IntPtr.Zero, 0, out required, IntPtr.Zero);
                if (required <= 0) continue;

                IntPtr buf = Marshal.AllocHGlobal(required);
                try
                {
                    Marshal.WriteInt32(buf, IntPtr.Size == 8 ? 8 : 6);
                    if (!SetupDiGetDeviceInterfaceDetail(set, ref did, buf, required, out required, IntPtr.Zero)) continue;
                    string path = Marshal.PtrToStringAuto(new IntPtr(buf.ToInt64() + 4));
                    FizzHidInfo info = Probe(path);
                    if (info != null) result.Add(info);
                }
                finally
                {
                    Marshal.FreeHGlobal(buf);
                }
            }
        }
        finally
        {
            SetupDiDestroyDeviceInfoList(set);
        }
        return result;
    }

    // HIDP_VALUE_CAPS and HIDP_BUTTON_CAPS are both 72 bytes; ReportID is the byte at offset 2.
    static void CollectIds(int kind, ushort count, IntPtr pp, List<int> ids)
    {
        if (count == 0) return;
        IntPtr buf = Marshal.AllocHGlobal(72 * count);
        try
        {
            ushort len = count;
            int status = (kind == 0) ? HidP_GetValueCaps(2, buf, ref len, pp) : HidP_GetButtonCaps(2, buf, ref len, pp);
            if (status < 0) return;
            for (int n = 0; n < len; n++)
            {
                int id = Marshal.ReadByte(buf, n * 72 + 2);
                if (!ids.Contains(id)) ids.Add(id);
            }
        }
        finally
        {
            Marshal.FreeHGlobal(buf);
        }
    }

    static FizzHidInfo Probe(string path)
    {
        // access 0 = query only; works even for collections Windows keeps exclusive
        SafeFileHandle h = CreateFile(path, 0, 3, IntPtr.Zero, 3, 0, IntPtr.Zero);
        if (h.IsInvalid) return null;
        try
        {
            HIDD_ATTRIBUTES a = new HIDD_ATTRIBUTES();
            a.Size = Marshal.SizeOf(typeof(HIDD_ATTRIBUTES));
            if (!HidD_GetAttributes(h, ref a)) return null;
            if (a.VendorID != VID || a.ProductID != PID) return null;

            FizzHidInfo info = new FizzHidInfo();
            info.Path = path;
            IntPtr pp;
            if (HidD_GetPreparsedData(h, out pp))
            {
                try
                {
                    HIDP_CAPS caps;
                    if (HidP_GetCaps(pp, out caps) >= 0)
                    {
                        info.UsagePage = caps.UsagePage;
                        info.Usage = caps.Usage;
                        info.FeatureLen = caps.FeatureReportByteLength;
                        info.InputLen = caps.InputReportByteLength;
                        info.OutputLen = caps.OutputReportByteLength;
                        List<int> ids = new List<int>();
                        CollectIds(0, caps.NumberFeatureValueCaps, pp, ids);
                        CollectIds(1, caps.NumberFeatureButtonCaps, pp, ids);
                        ids.Sort();
                        List<string> txt = new List<string>();
                        foreach (int id in ids) txt.Add(id.ToString());
                        info.FeatureIds = string.Join(",", txt.ToArray());
                    }
                }
                finally
                {
                    HidD_FreePreparsedData(pp);
                }
            }
            return info;
        }
        finally
        {
            h.Close();
        }
    }

    // ---- open every collection that has feature reports ----
    public static FizzDevice OpenAll(List<FizzHidInfo> infos)
    {
        FizzDevice d = new FizzDevice();
        List<string> failures = new List<string>();
        foreach (FizzHidInfo i in infos)
        {
            if (i.FeatureLen <= 0) continue;   // this collection has no feature reports
            SafeFileHandle h = CreateFile(i.Path, 0xC0000000, 3, IntPtr.Zero, 3, 0, IntPtr.Zero);
            string mode = "read/write";
            if (h.IsInvalid)
            {
                int e1 = Marshal.GetLastWin32Error();
                h = CreateFile(i.Path, 0, 3, IntPtr.Zero, 3, 0, IntPtr.Zero);
                mode = "query-only";
                if (h.IsInvalid)
                {
                    failures.Add(i.ShortName() + ": open failed, Windows error " + e1);
                    continue;
                }
            }
            FizzSlot s = new FizzSlot();
            s.Info = i;
            s.Handle = h;
            s.OpenMode = mode;
            d.slots.Add(s);
        }
        if (d.slots.Count == 0)
            throw new InvalidOperationException("No HID collection with feature reports could be opened. " +
                string.Join("; ", failures.ToArray()));
        return d;
    }

    // Which collections could carry this report, best first. A collection whose feature length
    // is shorter than the frame is skipped: Windows would silently truncate the frame.
    public List<FizzSlot> Candidates(byte id, int length)
    {
        List<FizzSlot> order = new List<FizzSlot>();
        FizzSlot cached;
        if (route.TryGetValue(id, out cached)) { order.Add(cached); return order; }
        foreach (FizzSlot s in slots)
            if (s.Info.FeatureLen >= length && s.Info.HasId(id)) order.Add(s);
        foreach (FizzSlot s in slots)
            if (s.Info.FeatureLen >= length && !order.Contains(s)) order.Add(s);
        return order;
    }

    public string Summary()
    {
        List<string> parts = new List<string>();
        foreach (FizzSlot s in slots) parts.Add(s.Info.Describe());
        return string.Join(" | ", parts.ToArray());
    }

    // Try the exact frame length first (what the vendor software sends); if Windows rejects it,
    // pad to the collection's feature report length (what hidapi does).
    static bool TrySet(FizzSlot s, byte[] data, out int err, out string mode)
    {
        err = 0;
        mode = "";
        if (HidD_SetFeature(s.Handle, data, data.Length)) { mode = "exact"; return true; }
        err = Marshal.GetLastWin32Error();
        if (s.Info.FeatureLen > data.Length)
        {
            byte[] padded = new byte[s.Info.FeatureLen];
            Array.Copy(data, padded, data.Length);
            if (HidD_SetFeature(s.Handle, padded, padded.Length)) { mode = "padded"; return true; }
            err = Marshal.GetLastWin32Error();
        }
        return false;
    }

    public void SetFeature(byte[] data)
    {
        byte id = data[0];
        List<FizzSlot> order = Candidates(id, data.Length);
        if (order.Count == 0)
            throw new InvalidOperationException(string.Format(
                "No HID collection can carry report 0x{0:X2} ({1} bytes). Collections: {2}", id, data.Length, Summary()));

        int lastErr = 0;
        List<string> tried = new List<string>();
        foreach (FizzSlot s in order)
        {
            int err;
            string mode;
            if (TrySet(s, data, out err, out mode))
            {
                route[id] = s;
                LastSendMode = mode;
                LastRoute = s.Info.ShortName();
                return;
            }
            lastErr = err;
            tried.Add(s.Info.ShortName() + " -> error " + err);
        }
        route.Remove(id);
        throw new Win32Exception(lastErr, string.Format(
            "HidD_SetFeature failed for report 0x{0:X2} ({1} bytes): Windows error {2} ({3}). Tried: {4}",
            id, data.Length, lastErr, new Win32Exception(lastErr).Message, string.Join("; ", tried.ToArray())));
    }

    public byte[] GetFeature(byte reportId, int size)
    {
        List<FizzSlot> order = Candidates(reportId, size);
        if (order.Count == 0)
            throw new InvalidOperationException(string.Format(
                "No HID collection can carry report 0x{0:X2} ({1} bytes). Collections: {2}", reportId, size, Summary()));

        int lastErr = 0;
        List<string> tried = new List<string>();
        foreach (FizzSlot s in order)
        {
            int len = Math.Max(size, s.Info.FeatureLen);
            byte[] buf = new byte[len];
            buf[0] = reportId;
            if (HidD_GetFeature(s.Handle, buf, len))
            {
                route[reportId] = s;
                return buf;
            }
            lastErr = Marshal.GetLastWin32Error();
            tried.Add(s.Info.ShortName() + " -> error " + lastErr);
        }
        throw new Win32Exception(lastErr, string.Format(
            "HidD_GetFeature failed for report 0x{0:X2}: Windows error {1} ({2}). Tried: {3}",
            reportId, lastErr, new Win32Exception(lastErr).Message, string.Join("; ", tried.ToArray())));
    }

    // Read-only: ask every opened collection for reports 5, 6 and 8 and say what came back.
    public string[] Diagnose()
    {
        List<string> lines = new List<string>();
        foreach (FizzSlot s in slots)
        {
            lines.Add("collection " + s.Info.Describe() + "  [opened " + s.OpenMode + "]");
            foreach (int id in new int[] { 5, 6, 8 })
            {
                int len = Math.Max(s.Info.FeatureLen, 8);
                byte[] buf = new byte[len];
                buf[0] = (byte)id;
                if (HidD_GetFeature(s.Handle, buf, len))
                    lines.Add("    GET report " + id + ": ok, first bytes " + BitConverter.ToString(buf, 0, Math.Min(8, buf.Length)));
                else
                {
                    int err = Marshal.GetLastWin32Error();
                    lines.Add("    GET report " + id + ": error " + err + " (" + new Win32Exception(err).Message + ")");
                }
            }
        }
        return lines.ToArray();
    }

    public bool CarriesReport(int id)
    {
        foreach (FizzSlot s in slots)
            if (s.Info.HasId(id)) return true;
        return false;
    }

    public void Dispose()
    {
        foreach (FizzSlot s in slots)
            if (s.Handle != null && !s.Handle.IsClosed) s.Handle.Close();
        slots.Clear();
        route.Clear();
    }
}
'@
}

# ============================================================================
#  Shared helpers
# ============================================================================
$script:Dev = $null
$script:DryRun = $false
$script:GuiReady = $false
$script:LogBox = $null
$script:LogHook = $null
$script:FlashWarned = $false

function Write-Log {
  param([string]$Message)
  if ($null -ne $script:LogBox) {
    $script:LogBox.AppendText(('[{0}] {1}{2}' -f (Get-Date -Format 'HH:mm:ss'), $Message, [Environment]::NewLine))
    if ($null -ne $script:LogHook) { & $script:LogHook $Message }
  } else {
    Write-Host $Message
  }
}

function Send-Frames {
  # Mirrors fizzctl send_burst: SET_FEATURE each frame, 60 ms apart; after the first frame
  # the firmware needs a GET_FEATURE(0x06, 1032) handshake or it silently ignores the burst.
  param($Frames, [bool]$Handshake = $true, [int]$DelayMs = 60)
  $i = 0
  foreach ($f in $Frames) {
    $i++
    $kind = Get-FrameKind ([byte[]]$f)
    if ($script:DryRun) {
      Write-Log ('  [dry run] {0}/{1} {2}, {3} bytes' -f $i, $Frames.Count, $kind, $f.Length)
    } else {
      $script:Dev.SetFeature([byte[]]$f)
      Write-Log ('  sent {0}/{1} {2}, {3} bytes ({4}, {5})' -f $i, $Frames.Count, $kind, $f.Length, $script:Dev.LastSendMode, $script:Dev.LastRoute)
    }
    Start-Sleep -Milliseconds $DelayMs
    if ($Handshake -and $i -eq 1) {
      if ($script:DryRun) {
        Write-Log '  [dry run] handshake GET_FEATURE(0x06)'
      } else {
        try { [void]$script:Dev.GetFeature(0x06, 1032) }
        catch { Write-Log ('  handshake warning: ' + $_.Exception.Message) }
      }
      Start-Sleep -Milliseconds $DelayMs
    }
    if ($script:GuiReady) { [System.Windows.Forms.Application]::DoEvents() }
  }
}

if ($NoGui) { return }

# ============================================================================
#  GUI
# ============================================================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

$script:Settings = Read-Settings
$script:Mode = 'effects'
$script:Syncing = $false
$script:Building = $true
$script:Connected = $false
$script:LastApplied = ''
$script:AutoApply = [bool]$script:Settings.AutoApply
$script:LogOpen = $false
$script:PvHover = -1
$script:PvErrLogged = $false
$script:AnimErrLogged = $false

# ---------------- theme ----------------
function New-Rgb { param([int]$R, [int]$G, [int]$B) return [System.Drawing.Color]::FromArgb(255, $R, $G, $B) }
$cBg     = New-Rgb 14 14 18
$cCard   = New-Rgb 26 26 33
$cKey    = New-Rgb 44 44 56
$cDimKey = New-Rgb 34 34 42
$cEdge   = New-Rgb 62 62 76
$cText   = New-Rgb 236 236 242
$cMute   = New-Rgb 150 150 164
$cAcc    = New-Rgb 225 45 58
$cOk     = New-Rgb 52 211 153
$cWarn   = New-Rgb 251 191 36
$cErr    = New-Rgb 248 113 113
$cFnTint = New-Rgb 112 34 44
$fontUi   = New-Object System.Drawing.Font('Segoe UI', 9.5)
$fontBold = New-Object System.Drawing.Font('Segoe UI Semibold', 9.5)
$fontHead = New-Object System.Drawing.Font('Segoe UI Semibold', 18)
$fontSmall = New-Object System.Drawing.Font('Segoe UI', 8.5)
$fontKey  = New-Object System.Drawing.Font('Segoe UI', 8)
$fontLog  = New-Object System.Drawing.Font('Consolas', 8.5)

function New-Ctl {
  param([string]$Type, [int]$X, [int]$Y, [int]$W, [int]$H, [string]$Text = '')
  $c = New-Object $Type
  $c.Location = New-Object System.Drawing.Point($X, $Y)
  $c.Size = New-Object System.Drawing.Size($W, $H)
  if ($Text) { $c.Text = $Text }
  $c.Font = $fontUi
  $c.ForeColor = $cText
  return $c
}

function Set-Flat {
  param($B, $Back)
  $B.FlatStyle = 'Flat'
  $B.FlatAppearance.BorderSize = 0
  $B.BackColor = $Back
  $B.ForeColor = $cText
  $B.Cursor = 'Hand'
  $B.Font = $fontBold
}

function Get-TextColor {
  param([System.Drawing.Color]$C)
  $lum = 0.299 * $C.R + 0.587 * $C.G + 0.114 * $C.B
  if ($lum -gt 140) { return [System.Drawing.Color]::Black }
  return [System.Drawing.Color]::White
}

# ---------------- shared keyboard preview ----------------
$script:PvRects = New-Object 'System.Drawing.RectangleF[]' 61
$script:PvPaths = New-Object 'System.Drawing.Drawing2D.GraphicsPath[]' 61
$script:PvColors = New-Object 'System.Drawing.Color[]' 61
$script:PvTextColors = New-Object 'System.Drawing.Color[]' 61
$script:PvBorder = New-Object 'System.Drawing.Color[]' 61
$script:PvBorderW = New-Object 'single[]' 61
$script:PvText = New-Object 'string[]' 61
$script:PvBrush = New-Object System.Drawing.SolidBrush($cKey)
$script:PvTextBrush = New-Object System.Drawing.SolidBrush($cText)
$script:PvPen = New-Object System.Drawing.Pen($cEdge, 1)
$script:PvSf = New-Object System.Drawing.StringFormat
$script:PvSf.Alignment = [System.Drawing.StringAlignment]::Center
$script:PvSf.LineAlignment = [System.Drawing.StringAlignment]::Center
$script:PvSf.Trimming = [System.Drawing.StringTrimming]::None
$script:PvSf.FormatFlags = [System.Drawing.StringFormatFlags]::NoWrap

function New-RoundedPath {
  param([System.Drawing.RectangleF]$R, [single]$Rad)
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $Rad * 2
  $p.AddArc($R.X, $R.Y, $d, $d, 180, 90)
  $p.AddArc($R.Right - $d, $R.Y, $d, $d, 270, 90)
  $p.AddArc($R.Right - $d, $R.Bottom - $d, $d, $d, 0, 90)
  $p.AddArc($R.X, $R.Bottom - $d, $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

function Initialize-PvLayout {
  $scale = (760.0 - 28.0) / (547.0 - 12.0)
  for ($i = 0; $i -lt 61; $i++) {
    $r = $script:KeyRects[$i]
    $x = ($r[0] - 12) * $scale + 14
    $y = ($r[1] - 14) * $scale + 12
    $w = ($r[2] - $r[0]) * $scale
    $h = ($r[3] - $r[1]) * $scale
    $script:PvRects[$i] = New-Object System.Drawing.RectangleF([single]$x, [single]$y, [single]$w, [single]$h)
    $inner = New-Object System.Drawing.RectangleF([single]($x + 1.5), [single]($y + 1.5), [single]($w - 3), [single]($h - 3))
    $script:PvPaths[$i] = New-RoundedPath $inner 6
    $script:PvColors[$i] = $cKey
    $script:PvTextColors[$i] = $cText
    $script:PvBorder[$i] = $cEdge
    $script:PvBorderW[$i] = 1
    $script:PvText[$i] = ''
  }
}
Initialize-PvLayout
Initialize-AnimLayout

$pv = New-Object System.Windows.Forms.Panel
$pv.Location = New-Object System.Drawing.Point(30, 128)
$pv.Size = New-Object System.Drawing.Size(760, 264)
$pv.BackColor = $cCard
# smooth repainting: Panel.DoubleBuffered is protected, so set it by reflection
$dbProp = [System.Windows.Forms.Control].GetProperty('DoubleBuffered', [System.Reflection.BindingFlags]'Instance,NonPublic')
$dbProp.SetValue($pv, $true, $null)

function Get-PvHit {
  param([int]$X, [int]$Y)
  for ($i = 0; $i -lt 61; $i++) { if ($script:PvRects[$i].Contains([single]$X, [single]$Y)) { return $i } }
  return -1
}

function Draw-Preview {
  param($g)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
  for ($i = 0; $i -lt 61; $i++) {
    $script:PvBrush.Color = $script:PvColors[$i]
    $g.FillPath($script:PvBrush, $script:PvPaths[$i])
    $bw = $script:PvBorderW[$i]
    $border = $script:PvBorder[$i]
    if ($i -eq $script:PvHover -and $script:Mode -ne 'effects') { $bw = 2; $border = $cText }
    if ($bw -gt 0) {
      $script:PvPen.Color = $border
      $script:PvPen.Width = $bw
      $g.DrawPath($script:PvPen, $script:PvPaths[$i])
    }
    $txt = $script:PvText[$i]
    if ($txt) {
      $script:PvTextBrush.Color = $script:PvTextColors[$i]
      $g.DrawString($txt, $fontKey, $script:PvTextBrush, $script:PvRects[$i], $script:PvSf)
    }
  }
  if ($script:Mode -eq 'keymap' -and $null -eq $script:Km) {
    $veil = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(205, 14, 14, 18))
    $g.FillRectangle($veil, 0, 0, 760, 264)
    $veil.Dispose()
    $rect = New-Object System.Drawing.RectangleF(0, 0, 760, 264)
    $script:PvTextBrush.Color = $cText
    $g.DrawString(('Open your Cfg.ini to edit the keymap' + [Environment]::NewLine + '(or put a copy next to this script)'), $fontBold, $script:PvTextBrush, $rect, $script:PvSf)
  }
}

$pv.Add_Paint({
  param($sender, $ev)
  try { Draw-Preview $ev.Graphics }
  catch {
    if (-not $script:PvErrLogged) { $script:PvErrLogged = $true; Write-Log ('ERROR: preview drawing failed: ' + $_.Exception.Message) }
  }
})

# ---------------- window and header ----------------
$form = New-Object System.Windows.Forms.Form
$form.Text = 'Fizz Lighting - Redragon K617'
$form.ClientSize = New-Object System.Drawing.Size(820, 608)
$form.FormBorderStyle = 'FixedDialog'
$form.MaximizeBox = $false
$form.StartPosition = 'CenterScreen'
$form.BackColor = $cBg
$form.ForeColor = $cText
$form.Font = $fontUi

$lblTitle = New-Ctl 'System.Windows.Forms.Label' 28 14 320 36 'Fizz Lighting'
$lblTitle.Font = $fontHead
$lblSub = New-Ctl 'System.Windows.Forms.Label' 30 50 380 20 'Redragon K617 Fizz - stock firmware'
$lblSub.ForeColor = $cMute
$lblSub.Font = $fontSmall

$lblPill = New-Ctl 'System.Windows.Forms.Label' 480 20 168 28 'Not connected'
$lblPill.TextAlign = 'MiddleCenter'
$lblPill.Font = $fontBold
$btnSync = New-Ctl 'System.Windows.Forms.Button' 656 16 84 34 'Sync'
Set-Flat $btnSync $cKey
$btnMenu = New-Ctl 'System.Windows.Forms.Button' 748 16 44 34 '...'
Set-Flat $btnMenu $cKey

function Set-Pill {
  param([string]$Text, $Back)
  $lblPill.Text = $Text
  $lblPill.BackColor = $Back
  $lblPill.ForeColor = Get-TextColor $Back
}
Set-Pill 'Not connected' $cKey

$btnTabEff = New-Ctl 'System.Windows.Forms.Button' 30 82 150 36 'Effects'
$btnTabPaint = New-Ctl 'System.Windows.Forms.Button' 186 82 150 36 'Per-key paint'
$btnTabKm = New-Ctl 'System.Windows.Forms.Button' 342 82 150 36 'Keymap'
foreach ($b in @($btnTabEff, $btnTabPaint, $btnTabKm)) { Set-Flat $b $cKey }
$lblPvHint = New-Ctl 'System.Windows.Forms.Label' 500 90 290 22 ''
$lblPvHint.ForeColor = $cMute
$lblPvHint.Font = $fontSmall
$lblPvHint.TextAlign = 'MiddleRight'

# ---------------- Effects controls ----------------
$pEff = New-Ctl 'System.Windows.Forms.Panel' 30 400 760 164
$pEff.BackColor = $cCard
$lblEff = New-Ctl 'System.Windows.Forms.Label' 18 10 200 18 'Effect'
$lblEff.ForeColor = $cMute
$lblEff.Font = $fontSmall
$cmbEff = New-Ctl 'System.Windows.Forms.ComboBox' 18 30 270 28
$cmbEff.DropDownStyle = 'DropDownList'
$cmbEff.FlatStyle = 'Flat'
$cmbEff.BackColor = $cKey
$cmbEff.ForeColor = $cText
$ti = (Get-Culture).TextInfo
foreach ($e in $script:EffectList) { [void]$cmbEff.Items.Add($ti.ToTitleCase($e.Name.Replace('-', ' '))) }
$cmbEff.SelectedIndex = 0

$script:EffColor = New-Rgb 255 0 0
$chkColor = New-Ctl 'System.Windows.Forms.CheckBox' 312 10 200 22 'Custom color'
$btnEffColor = New-Ctl 'System.Windows.Forms.Button' 312 34 150 28 '#FF0000'
Set-Flat $btnEffColor $script:EffColor
$btnEffColor.ForeColor = Get-TextColor $script:EffColor
$lblEffHint = New-Ctl 'System.Windows.Forms.Label' 312 66 290 18 ''
$lblEffHint.ForeColor = $cMute
$lblEffHint.Font = $fontSmall

$btnApply = New-Ctl 'System.Windows.Forms.Button' 612 12 132 36 'Apply now'
Set-Flat $btnApply $cAcc
$chkAuto = New-Ctl 'System.Windows.Forms.CheckBox' 612 56 140 22 'Auto-apply'
$chkAuto.Checked = $script:AutoApply

$lblSpeed = New-Ctl 'System.Windows.Forms.Label' 18 92 200 18 'Speed'
$lblSpeed.ForeColor = $cMute
$lblSpeed.Font = $fontSmall
$trkSpeed = New-Ctl 'System.Windows.Forms.TrackBar' 14 108 276 36
$trkSpeed.Minimum = 1; $trkSpeed.Maximum = 5; $trkSpeed.Value = 3; $trkSpeed.TickStyle = 'None'; $trkSpeed.AutoSize = $false
$trkSpeed.BackColor = $cCard
$lblSpeedVal = New-Ctl 'System.Windows.Forms.Label' 296 114 36 20 '3'
$lblBri = New-Ctl 'System.Windows.Forms.Label' 356 92 200 18 'Brightness'
$lblBri.ForeColor = $cMute
$lblBri.Font = $fontSmall
$trkBri = New-Ctl 'System.Windows.Forms.TrackBar' 352 108 276 36
$trkBri.Minimum = 0; $trkBri.Maximum = 4; $trkBri.Value = 3; $trkBri.TickStyle = 'None'; $trkBri.AutoSize = $false
$trkBri.BackColor = $cCard
$lblBriVal = New-Ctl 'System.Windows.Forms.Label' 634 114 36 20 '3'
foreach ($c in @($lblEff, $cmbEff, $chkColor, $btnEffColor, $lblEffHint, $btnApply, $chkAuto, $lblSpeed, $trkSpeed, $lblSpeedVal, $lblBri, $trkBri, $lblBriVal)) { $pEff.Controls.Add($c) }

# ---------------- Per-key paint controls ----------------
$pPaint = New-Ctl 'System.Windows.Forms.Panel' 30 400 760 164
$pPaint.BackColor = $cCard
$pPaint.Visible = $false
$script:PaintColor = New-Rgb 0 200 255
$script:Paint = @{}
$btnPaintColor = New-Ctl 'System.Windows.Forms.Button' 18 16 200 36 'Paint color: #00C8FF'
Set-Flat $btnPaintColor $script:PaintColor
$btnPaintColor.ForeColor = Get-TextColor $script:PaintColor
$btnFill = New-Ctl 'System.Windows.Forms.Button' 226 16 110 36 'Fill all'
Set-Flat $btnFill $cKey
$btnOff = New-Ctl 'System.Windows.Forms.Button' 342 16 110 36 'All off'
Set-Flat $btnOff $cKey
$btnSave = New-Ctl 'System.Windows.Forms.Button' 540 16 204 36 'Save to keyboard'
Set-Flat $btnSave $cAcc
$lblPaintNote = New-Ctl 'System.Windows.Forms.Label' 18 70 724 70 ('Click keys on the preview to paint them; right-click clears a key.' + [Environment]::NewLine + 'Windows cannot show paint live on the keyboard, so "Save to keyboard" sends the colors to it (this writes to flash).')
$lblPaintNote.ForeColor = $cMute
foreach ($c in @($btnPaintColor, $btnFill, $btnOff, $btnSave, $lblPaintNote)) { $pPaint.Controls.Add($c) }

# ---------------- Keymap controls ----------------
$pKm = New-Ctl 'System.Windows.Forms.Panel' 30 400 760 164
$pKm.BackColor = $cCard
$pKm.Visible = $false
$script:Km = $null
$script:KmLayer = 'base'
$script:KmSelected = 0
$btnKmOpen = New-Ctl 'System.Windows.Forms.Button' 18 12 132 32 'Open Cfg.ini...'
Set-Flat $btnKmOpen $cKey
$btnKmSave = New-Ctl 'System.Windows.Forms.Button' 156 12 112 32 'Save as...'
Set-Flat $btnKmSave $cKey
$btnKmBase = New-Ctl 'System.Windows.Forms.Button' 300 12 100 32 'Base layer'
Set-Flat $btnKmBase $cAcc
$btnKmFn = New-Ctl 'System.Windows.Forms.Button' 406 12 100 32 'Fn layer'
Set-Flat $btnKmFn $cKey
$lblKmHint = New-Ctl 'System.Windows.Forms.Label' 520 18 224 20 'Left-click edit, right-click reset'
$lblKmHint.ForeColor = $cMute
$lblKmHint.Font = $fontSmall
$lblKmInfo = New-Ctl 'System.Windows.Forms.Label' 18 58 724 20 ''
$lblKmStatus = New-Ctl 'System.Windows.Forms.Label' 18 82 724 70 ''
$lblKmStatus.ForeColor = $cMute
$lblKmStatus.Font = $fontSmall
foreach ($c in @($btnKmOpen, $btnKmSave, $btnKmBase, $btnKmFn, $lblKmHint, $lblKmInfo, $lblKmStatus)) { $pKm.Controls.Add($c) }

# ---------------- footer + log drawer ----------------
$lblMsg = New-Ctl 'System.Windows.Forms.Label' 30 572 636 24 ''
$lblMsg.ForeColor = $cMute
$lblMsg.Font = $fontSmall
$lblMsg.AutoEllipsis = $true
$lblMsg.TextAlign = 'MiddleLeft'
$btnLog = New-Ctl 'System.Windows.Forms.Button' 672 568 118 30 'Show log'
Set-Flat $btnLog $cKey
$btnLog.Font = $fontSmall
$txtLog = New-Ctl 'System.Windows.Forms.TextBox' 30 606 760 150
$txtLog.Multiline = $true
$txtLog.ReadOnly = $true
$txtLog.ScrollBars = 'Vertical'
$txtLog.BackColor = New-Rgb 10 10 13
$txtLog.ForeColor = $cMute
$txtLog.BorderStyle = 'None'
$txtLog.Font = $fontLog
$txtLog.Visible = $false
$script:LogBox = $txtLog

foreach ($c in @($lblTitle, $lblSub, $lblPill, $btnSync, $btnMenu, $btnTabEff, $btnTabPaint, $btnTabKm, $lblPvHint, $pv, $pEff, $pPaint, $pKm, $lblMsg, $btnLog, $txtLog)) { $form.Controls.Add($c) }

# ---------------- tools menu ----------------
$menu = New-Object System.Windows.Forms.ContextMenuStrip
$menu.BackColor = $cCard
$menu.ForeColor = $cText
$miSync = New-Object System.Windows.Forms.ToolStripMenuItem('Sync from keyboard')
$miReconnect = New-Object System.Windows.Forms.ToolStripMenuItem('Reconnect')
$miDiag = New-Object System.Windows.Forms.ToolStripMenuItem('Diagnose connection')
$miCopy = New-Object System.Windows.Forms.ToolStripMenuItem('Copy log')
$miDry = New-Object System.Windows.Forms.ToolStripMenuItem('Dry run (send nothing)')
$miDry.CheckOnClick = $true
foreach ($mi in @($miSync, $miReconnect, $miDiag, $miCopy)) { $mi.ForeColor = $cText; $mi.BackColor = $cCard }
$miDry.ForeColor = $cText; $miDry.BackColor = $cCard
[void]$menu.Items.Add($miSync)
[void]$menu.Items.Add($miReconnect)
[void]$menu.Items.Add($miDiag)
[void]$menu.Items.Add((New-Object System.Windows.Forms.ToolStripSeparator))
[void]$menu.Items.Add($miCopy)
[void]$menu.Items.Add($miDry)

# ============================================================================
#  Behaviour
# ============================================================================
function Save-AppSettings {
  $script:Settings.AutoApply = $script:AutoApply
  $script:Settings.ShowLog = $script:LogOpen
  $script:Settings.Tab = $script:Mode
  Write-Settings $script:Settings
}

function Set-Status {
  param([string]$Text, $Color)
  $lblMsg.Text = $Text
  if ($null -ne $Color) { $lblMsg.ForeColor = $Color } else { $lblMsg.ForeColor = $cMute }
}

function Set-LogVisible {
  param([bool]$Show)
  $script:LogOpen = $Show
  $txtLog.Visible = $Show
  if ($Show) { $form.ClientSize = New-Object System.Drawing.Size(820, 776); $btnLog.Text = 'Hide log' }
  else { $form.ClientSize = New-Object System.Drawing.Size(820, 608); $btnLog.Text = 'Show log' }
}

# mirror log lines into the footer and open the drawer when something goes wrong
$script:LogHook = {
  param($m)
  if ($m -and -not $m.StartsWith(' ')) {
    $short = $m
    if ($short.Length -gt 110) { $short = $short.Substring(0, 107) + '...' }
    if ($m.StartsWith('ERROR')) { Set-Status $short $cErr; if (-not $script:LogOpen) { Set-LogVisible $true } }
    elseif ($m -match 'failed|could not|skipped') { Set-Status $short $cWarn }
    else { Set-Status $short $cMute }
  }
}

function Close-Keyboard {
  if ($null -ne $script:Dev) {
    try { $script:Dev.Dispose() } catch { }
    $script:Dev = $null
  }
  $script:Connected = $false
}

function Connect-Keyboard {
  Close-Keyboard
  try {
    $list = [FizzDevice]::Find()
    if ($list.Count -eq 0) {
      Set-Pill 'Not connected' $cKey
      Write-Log 'No HID interface with VID 258A / PID 0049 found. Plug the keyboard in and use Reconnect.'
      return $false
    }
    Write-Log ('Found {0} HID collection(s) for 258A:0049:' -f $list.Count)
    foreach ($i in $list) { Write-Log ('  ' + $i.Describe()) }
    $script:Dev = [FizzDevice]::OpenAll($list)
    $script:Connected = $true
    Set-Pill 'Connected' $cOk
    Write-Log ('Opened {0} collection(s) with feature reports.' -f $script:Dev.SlotCount)
    return $true
  } catch {
    Set-Pill 'Error' $cErr
    Write-Log ('ERROR: could not open the keyboard: ' + $_.Exception.Message)
    return $false
  }
}

function Ensure-Device {
  if ($script:DryRun) { return $true }
  if ($null -ne $script:Dev) { return $true }
  return (Connect-Keyboard)
}

function Confirm-Flash {
  if ($script:DryRun -or $script:FlashWarned) { return $true }
  $r = [System.Windows.Forms.MessageBox]::Show(
    "This writes to the keyboard's flash memory. Keep it plugged in until the message says Done.",
    'Save to keyboard', 'OKCancel', 'Information')
  if ($r -ne [System.Windows.Forms.DialogResult]::OK) { return $false }
  $script:FlashWarned = $true
  return $true
}

function Pick-Color {
  param([System.Drawing.Color]$Current)
  $dlg = New-Object System.Windows.Forms.ColorDialog
  $dlg.FullOpen = $true
  $dlg.Color = $Current
  if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { return $dlg.Color }
  return $null
}

function Get-Sha256Hex {
  param([byte[]]$Bytes)
  $h = [System.Security.Cryptography.SHA256]::Create()
  return (($h.ComputeHash($Bytes) | ForEach-Object { $_.ToString('x2') }) -join '')
}

# ---------------- preview content per tab ----------------
function Set-PvEffectStyle {
  for ($i = 0; $i -lt 61; $i++) {
    $script:PvText[$i] = ''
    $script:PvBorder[$i] = New-Rgb 36 36 46
    $script:PvBorderW[$i] = 1
  }
}

function Get-EffectParams {
  $e = $script:EffectList[$cmbEff.SelectedIndex]
  return @{
    Id = [int]$e.Id
    Name = [string]$e.Name
    Speed = [int]$trkSpeed.Value
    Bri = [int]$trkBri.Value
    Custom = [bool]($chkColor.Checked -and $chkColor.Enabled)
    Color = @([int]$script:EffColor.R, [int]$script:EffColor.G, [int]$script:EffColor.B)
  }
}

$script:AnimSw = [System.Diagnostics.Stopwatch]::StartNew()
function Step-Anim {
  if ($script:Mode -ne 'effects' -or -not $form.Visible) { return }
  try {
    $p = Get-EffectParams
    $levels = @(0.14, 0.34, 0.56, 0.78, 1.0)
    if ($p.Id -eq 22) {
      for ($i = 0; $i -lt 61; $i++) { $script:PvColors[$i] = $cDimKey }
    } elseif ($p.Id -eq 21) {
      $f = $levels[$p.Bri]
      for ($i = 0; $i -lt 61; $i++) {
        $n = [string]$script:KeyNames[$i]
        if ($script:Paint.ContainsKey($n)) {
          $c = $script:Paint[$n]
          $script:PvColors[$i] = [System.Drawing.Color]::FromArgb(255, [int]($c[0] * $f), [int]($c[1] * $f), [int]($c[2] * $f))
        } else { $script:PvColors[$i] = $cDimKey }
      }
    } else {
      $f = [FizzAnim]::Render($p.Id, $script:AnimSw.Elapsed.TotalSeconds, $p.Speed, $p.Bri, $p.Custom, $p.Color[0], $p.Color[1], $p.Color[2])
      for ($i = 0; $i -lt 61; $i++) {
        $script:PvColors[$i] = [System.Drawing.Color]::FromArgb(255, [int]$f[3 * $i], [int]$f[3 * $i + 1], [int]$f[3 * $i + 2])
      }
    }
    $pv.Invalidate()
  } catch {
    if (-not $script:AnimErrLogged) { $script:AnimErrLogged = $true; Write-Log ('ERROR: preview animation failed: ' + $_.Exception.Message) }
  }
}

function Update-PaintPreview {
  for ($i = 0; $i -lt 61; $i++) {
    $n = [string]$script:KeyNames[$i]
    $script:PvBorder[$i] = $cEdge
    $script:PvBorderW[$i] = 1
    $script:PvText[$i] = $n
    if ($script:Paint.ContainsKey($n)) {
      $c = $script:Paint[$n]
      $col = [System.Drawing.Color]::FromArgb(255, [int]$c[0], [int]$c[1], [int]$c[2])
      $script:PvColors[$i] = $col
      $script:PvTextColors[$i] = Get-TextColor $col
    } else {
      $script:PvColors[$i] = $cKey
      $script:PvTextColors[$i] = $cMute
    }
  }
  $pv.Invalidate()
}

function Update-KmPreview {
  for ($i = 0; $i -lt 61; $i++) {
    $idx = $i + 1
    $edited = $false
    if ($null -eq $script:Km -or -not $script:Km.Keys.ContainsKey($idx)) {
      $script:PvColors[$i] = $cDimKey
      $script:PvText[$i] = [string]$script:KeyNames[$i]
      $script:PvTextColors[$i] = $cMute
    } else {
      $k = $script:Km.Keys[$idx]
      if ($script:KmLayer -eq 'base') {
        $script:PvText[$i] = Get-BehaviorName $k.Base $true
        if ([int]$k.Base[1] -eq 250) { $script:PvColors[$i] = $cAcc } else { $script:PvColors[$i] = $cKey }
        $script:PvTextColors[$i] = $cText
        $edited = -not (Test-SameBehavior $k.Base $script:StockBase[$idx])
      } else {
        if ($null -ne $k.Fn) {
          $script:PvText[$i] = Get-BehaviorName $k.Fn $true
          $script:PvColors[$i] = $cFnTint
          $script:PvTextColors[$i] = $cText
        } else {
          $script:PvText[$i] = Get-BehaviorName $k.Base $true
          $script:PvColors[$i] = $cDimKey
          $script:PvTextColors[$i] = $cMute
        }
        $edited = -not (Test-SameBehavior $k.Fn $script:StockFn[$idx])
      }
    }
    if ($idx -eq $script:KmSelected) { $script:PvBorder[$i] = [System.Drawing.Color]::White; $script:PvBorderW[$i] = 2 }
    elseif ($edited) { $script:PvBorder[$i] = $cWarn; $script:PvBorderW[$i] = 2 }
    else { $script:PvBorder[$i] = $cEdge; $script:PvBorderW[$i] = 1 }
  }
  $pv.Invalidate()
}

function Set-Tab {
  param([string]$Mode)
  $script:Mode = $Mode
  $pEff.Visible = ($Mode -eq 'effects')
  $pPaint.Visible = ($Mode -eq 'paint')
  $pKm.Visible = ($Mode -eq 'keymap')
  foreach ($b in @($btnTabEff, $btnTabPaint, $btnTabKm)) { $b.BackColor = $cKey }
  $script:PvHover = -1
  if ($Mode -eq 'effects') {
    $btnTabEff.BackColor = $cAcc
    $lblPvHint.Text = 'Approximate preview of the selected effect'
    Set-PvEffectStyle
    Step-Anim
  } elseif ($Mode -eq 'paint') {
    $btnTabPaint.BackColor = $cAcc
    $lblPvHint.Text = 'Click keys to paint, right-click to clear'
    Update-PaintPreview
  } else {
    $btnTabKm.BackColor = $cAcc
    $lblPvHint.Text = 'Click a key to edit it'
    if ($null -eq $script:Km) { Open-DefaultCfg }
    Update-KmPreview
    Update-KmInfo
    Update-KmStatus
  }
}

# ---------------- effects: capabilities, apply, auto-apply, sync ----------------
function Update-EffControls {
  $e = $script:EffectList[$cmbEff.SelectedIndex]
  $caps = $script:EffectCaps[[int]$e.Id]
  $hasColor = ($null -ne $caps -and [int]$caps[3] -eq 1)
  $hasSpeed = ($null -ne $caps -and [int]$caps[0] -eq 1)
  $hasBri = ($null -ne $caps -and [int]$caps[1] -eq 1)
  $chkColor.Enabled = $hasColor
  $btnEffColor.Enabled = $hasColor
  if (-not $hasColor) { $chkColor.Checked = $false }
  $trkSpeed.Enabled = $hasSpeed
  $trkBri.Enabled = $hasBri
  if ($hasColor) { $lblEffHint.Text = 'Leave unticked for the effect''s own multicolor.' }
  else { $lblEffHint.Text = 'This effect uses its own colors.' }
}

function Invoke-ApplyEffect {
  param([bool]$Auto = $false)
  if (-not (Ensure-Device)) { return $false }
  if (-not $Auto -and -not (Confirm-Flash)) { return $false }
  $p = Get-EffectParams
  $color = $null
  if ($p.Custom) { $color = $p.Color }
  try {
    $btnApply.Enabled = $false
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    $how = ''; if ($Auto) { $how = ' (auto)' }
    Write-Log ('Applying "{0}" - speed {1}, brightness {2}{3}{4}' -f $p.Name, $p.Speed, $p.Bri, $(if ($p.Custom) { ', custom color' } else { '' }), $how)
    $frames = New-EffectFrames -Name $p.Name -Color $color -Speed $p.Speed -Brightness $p.Bri
    Send-Frames $frames $true
    $script:LastApplied = Get-EffectSignature $p.Id $p.Speed $p.Bri $p.Custom $p.Color
    Write-Log 'Done.'
    return $true
  } catch {
    Write-Log ('ERROR: apply failed: ' + $_.Exception.Message)
    return $false
  } finally {
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
    $btnApply.Enabled = $true
  }
}

$script:DebounceTimer = New-Object System.Windows.Forms.Timer
$script:DebounceTimer.Interval = 700

function Queue-AutoApply {
  if (-not $script:AutoApply -or $script:Syncing -or $script:Building -or $script:Mode -ne 'effects') { return }
  $script:DebounceTimer.Stop()
  $script:DebounceTimer.Start()
}

$script:DebounceTimer.Add_Tick({
  $script:DebounceTimer.Stop()
  if ([System.Windows.Forms.Control]::MouseButtons -ne [System.Windows.Forms.MouseButtons]::None) { $script:DebounceTimer.Start(); return }
  $p = Get-EffectParams
  $sig = Get-EffectSignature $p.Id $p.Speed $p.Bri $p.Custom $p.Color
  if ($sig -eq $script:LastApplied) { return }
  [void](Invoke-ApplyEffect $true)
})

function Sync-FromKeyboard {
  if ($script:DryRun) { Write-Log 'Dry run is on: sync skipped.'; return $false }
  if (-not (Ensure-Device)) { return $false }
  try {
    $st = Read-DeviceLighting $script:Dev
    if (-not $st.Known) {
      Write-Log ('The keyboard reported effect id {0}, which this app does not know; nothing changed.' -f $st.EffectId)
      return $false
    }
    $script:Syncing = $true
    $cmbEff.SelectedIndex = [int]$st.EffectId - 1
    Update-EffControls
    $trkSpeed.Value = [int]$st.Speed
    $trkBri.Value = [int]$st.Brightness
    $lblSpeedVal.Text = [string]$trkSpeed.Value
    $lblBriVal.Text = [string]$trkBri.Value
    $custom = ([bool]$st.Custom -and $chkColor.Enabled)
    $chkColor.Checked = $custom
    if ($custom) {
      $script:EffColor = New-Rgb ([int]$st.Color[0]) ([int]$st.Color[1]) ([int]$st.Color[2])
      $btnEffColor.BackColor = $script:EffColor
      $btnEffColor.ForeColor = Get-TextColor $script:EffColor
      $btnEffColor.Text = ('#{0:X2}{1:X2}{2:X2}' -f $script:EffColor.R, $script:EffColor.G, $script:EffColor.B)
    }
    $name = [string]$script:EffectList[[int]$st.EffectId - 1].Name
    $script:LastApplied = Get-EffectSignature ([int]$st.EffectId) ([int]$st.Speed) ([int]$st.Brightness) $custom @([int]$st.Color[0], [int]$st.Color[1], [int]$st.Color[2])
    Write-Log ('Synced from keyboard: "{0}", speed {1}, brightness {2}{3} (raw speed/brightness byte 0x{4:X2}).' -f $name, $st.Speed, $st.Brightness, $(if ($custom) { ', custom color' } else { '' }), $st.Packed)
    return $true
  } catch {
    Write-Log ('Sync skipped: could not read the keyboard state (' + $_.Exception.Message + ')')
    return $false
  } finally {
    $script:Syncing = $false
  }
}

# ---------------- keymap tab ----------------
function Get-PickItems {
  param([string]$Category)
  $items = New-Object System.Collections.Generic.List[object]
  if ($script:PickVkGroups.Contains($Category)) {
    foreach ($vk in $script:PickVkGroups[$Category]) { $items.Add(@{ Label = [string]$script:VkLong[[int]$vk]; Type = 2; Code = [int]$vk; Extra = [long]0 }) }
  } elseif ($Category -eq 'Fn key') {
    $items.Add(@{ Label = 'Fn (switches to the Fn layer)'; Type = 2; Code = 250; Extra = [long]0 })
  } elseif ($Category -eq 'Media') {
    foreach ($c in ($script:MediaLong.Keys | Sort-Object)) { $items.Add(@{ Label = [string]$script:MediaLong[[int]$c]; Type = 4; Code = [int]$c; Extra = [long]0 }) }
  } elseif ($Category -eq 'Keyboard functions') {
    foreach ($s in $script:SpecialList) { $items.Add(@{ Label = [string]$s.Long; Type = 9; Code = 0; Extra = [long]$s.Extra }) }
  }
  return , $items
}

function Update-KmInfo {
  param([int]$Idx = 0)
  if ($Idx -le 0) { $Idx = $script:KmSelected }
  if ($null -eq $script:Km -or $Idx -le 0 -or -not $script:Km.Keys.ContainsKey($Idx)) { $lblKmInfo.Text = ''; return }
  $k = $script:Km.Keys[$Idx]
  $fnText = 'none'
  if ($null -ne $k.Fn) { $fnText = ('{0} ({1})' -f (Get-BehaviorName $k.Fn), (Format-Behavior $k.Fn)) }
  $lblKmInfo.Text = ('K{0}  keycap {1}   matrix {2}, LED {3}   base: {4}   Fn: {5}' -f $Idx, (Get-BehaviorName $script:StockBase[$Idx]), $k.Col, $k.Led, (Get-BehaviorName $k.Base), $fnText)
}

function Update-KmStatus {
  if ($null -eq $script:Km) { $lblKmStatus.Text = 'No Cfg.ini loaded.'; $lblKmStatus.ForeColor = $cMute; return }
  $fnN = 0; $eb = 0; $ef = 0
  foreach ($i in $script:Km.Keys.Keys) {
    $k = $script:Km.Keys[$i]
    if ($null -ne $k.Fn) { $fnN++ }
    if (-not (Test-SameBehavior $k.Base $script:StockBase[[int]$i])) { $eb++ }
    if (-not (Test-SameBehavior $k.Fn $script:StockFn[[int]$i])) { $ef++ }
  }
  $issues = Get-KeymapIssues $script:Km
  $text = ('Fn layer {0}/48 entries   |   differs from stock: base {1}, Fn {2}   |   yellow outline = differs from stock' -f $fnN, $eb, $ef)
  $errs = @($issues | Where-Object { $_.Level -eq 'error' })
  $warns = @($issues | Where-Object { $_.Level -eq 'warn' })
  if ($errs.Count -gt 0) { $text += [Environment]::NewLine + 'ERROR: ' + $errs[0].Text; $lblKmStatus.ForeColor = $cErr }
  elseif ($warns.Count -gt 0) { $text += [Environment]::NewLine + 'Warning: ' + $warns[0].Text; $lblKmStatus.ForeColor = $cWarn }
  else { $lblKmStatus.ForeColor = $cMute }
  $lblKmStatus.Text = $text
}

function Open-KmFile {
  param([string]$Path)
  try {
    $model = Read-CfgFile $Path
    if ($model.Keys.Count -eq 0) {
      [System.Windows.Forms.MessageBox]::Show('No [KEY] entries found. Is this the Redragon Cfg.ini?', 'Open Cfg.ini', 'OK', 'Warning') | Out-Null
      return
    }
    $script:Km = $model
    $script:KmSelected = 0
    $script:Settings.LastCfg = $Path
    $fnN = @($model.Keys.Values | Where-Object { $null -ne $_.Fn }).Count
    $blk = New-KeymapBlock $model
    Write-Log ('Loaded {0}: {1} keys, {2} Fn-layer entries. Keymap block sha256 {3}...' -f $Path, $model.Keys.Count, $fnN, (Get-Sha256Hex $blk).Substring(0, 16))
    Update-KmPreview
    Update-KmInfo
    Update-KmStatus
  } catch {
    Write-Log ('ERROR: could not open the Cfg.ini: ' + $_.Exception.Message)
  }
}

function Open-DefaultCfg {
  $cands = New-Object System.Collections.Generic.List[string]
  if ($script:Settings.LastCfg) { $cands.Add([string]$script:Settings.LastCfg) }
  if ($PSScriptRoot) { $cands.Add((Join-Path $PSScriptRoot 'Cfg.ini')) }
  foreach ($c in $cands) { if ($c -and (Test-Path $c)) { Open-KmFile $c; return } }
}

function Reset-KmKey {
  param([int]$Idx)
  $k = $script:Km.Keys[$Idx]
  if ($script:KmLayer -eq 'base') {
    $k.Base = @($script:StockBase[$Idx][0], $script:StockBase[$Idx][1], $script:StockBase[$Idx][2])
    $script:Km.BaseDirty[$Idx] = $true
  } else {
    if ($script:StockFn.ContainsKey($Idx)) { $k.Fn = @($script:StockFn[$Idx][0], $script:StockFn[$Idx][1], $script:StockFn[$Idx][2]) } else { $k.Fn = $null }
    $script:Km.FnDirty = $true
  }
}

function Show-KeyEditor {
  param([int]$Idx)
  $k = $script:Km.Keys[$Idx]
  $layer = $script:KmLayer
  $keycap = Get-BehaviorName $script:StockBase[$Idx]
  $layerName = 'Fn layer'; if ($layer -eq 'base') { $layerName = 'base layer' }
  $dlg = New-Object System.Windows.Forms.Form
  $dlg.Text = ('K{0} - keycap {1} - {2}' -f $Idx, $keycap, $layerName)
  $dlg.ClientSize = New-Object System.Drawing.Size(420, 232)
  $dlg.FormBorderStyle = 'FixedDialog'
  $dlg.MaximizeBox = $false
  $dlg.MinimizeBox = $false
  $dlg.StartPosition = 'CenterParent'
  $dlg.BackColor = $cBg
  $dlg.ForeColor = $cText
  $dlg.Font = $fontUi

  $cur = $k.Base
  if ($layer -eq 'fn') { $cur = $k.Fn }
  $curText = 'none (the key passes through its base output)'
  if ($null -ne $cur) { $curText = ('{0}   {1}' -f (Get-BehaviorName $cur), (Format-Behavior $cur)) }
  $l0 = New-Ctl 'System.Windows.Forms.Label' 16 14 390 20 ('Currently: ' + $curText)
  $l0.ForeColor = $cMute
  $l1 = New-Ctl 'System.Windows.Forms.Label' 16 46 200 20 'Category'
  $cmbCat = New-Ctl 'System.Windows.Forms.ComboBox' 16 68 388 28
  $l2 = New-Ctl 'System.Windows.Forms.Label' 16 108 200 20 'Output'
  $cmbOut = New-Ctl 'System.Windows.Forms.ComboBox' 16 130 388 28
  foreach ($c in @($cmbCat, $cmbOut)) { $c.DropDownStyle = 'DropDownList'; $c.FlatStyle = 'Flat'; $c.BackColor = $cKey; $c.ForeColor = $cText }

  $cats = New-Object System.Collections.Generic.List[string]
  if ($layer -eq 'fn') { $cats.Add('None (pass through)') }
  foreach ($n in $script:PickVkGroups.Keys) { $cats.Add([string]$n) }
  if ($layer -eq 'base') { $cats.Add('Fn key') } else { $cats.Add('Media'); $cats.Add('Keyboard functions') }
  foreach ($n in $cats) { [void]$cmbCat.Items.Add($n) }

  $state = @{ Items = $null }
  $fillOut = {
    $cmbOut.Items.Clear()
    $cat = [string]$cmbCat.SelectedItem
    if ($cat -eq 'None (pass through)') { $cmbOut.Enabled = $false; $state.Items = @(); return }
    $cmbOut.Enabled = $true
    $state.Items = Get-PickItems $cat
    foreach ($it in $state.Items) { [void]$cmbOut.Items.Add([string]$it.Label) }
    if ($cmbOut.Items.Count -gt 0) { $cmbOut.SelectedIndex = 0 }
  }
  $cmbCat.Add_SelectedIndexChanged($fillOut)

  $selCat = 0
  $selItem = 0
  if ($null -ne $cur) {
    for ($ci = 0; $ci -lt $cats.Count; $ci++) {
      $cn = $cats[$ci]
      if ($cn -eq 'None (pass through)') { continue }
      $its = Get-PickItems $cn
      for ($ii = 0; $ii -lt $its.Count; $ii++) {
        if ([int]$its[$ii].Type -eq [int]$cur[0] -and [int]$its[$ii].Code -eq [int]$cur[1] -and [long]$its[$ii].Extra -eq [long]$cur[2]) { $selCat = $ci; $selItem = $ii }
      }
    }
  }
  $cmbCat.SelectedIndex = $selCat
  if ($cmbOut.Items.Count -gt $selItem -and $cmbOut.Enabled) { $cmbOut.SelectedIndex = $selItem }

  $note = 'Output is what the key sends'
  if ($layer -eq 'fn') { $note = 'Output is what the key sends while Fn is held' }
  $l3 = New-Ctl 'System.Windows.Forms.Label' 16 168 388 20 $note
  $l3.ForeColor = $cMute
  $l3.Font = $fontKey
  $btnOk = New-Ctl 'System.Windows.Forms.Button' 16 192 100 32 'OK'
  Set-Flat $btnOk $cAcc
  $btnOk.DialogResult = [System.Windows.Forms.DialogResult]::OK
  $btnCancel = New-Ctl 'System.Windows.Forms.Button' 122 192 100 32 'Cancel'
  Set-Flat $btnCancel $cKey
  $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
  $btnStock = New-Ctl 'System.Windows.Forms.Button' 268 192 136 32 'Reset to stock'
  Set-Flat $btnStock $cKey
  $btnStock.Add_Click({ $dlg.Tag = 'stock'; $dlg.DialogResult = [System.Windows.Forms.DialogResult]::OK })
  foreach ($c in @($l0, $l1, $cmbCat, $l2, $cmbOut, $l3, $btnOk, $btnCancel, $btnStock)) { $dlg.Controls.Add($c) }
  $dlg.AcceptButton = $btnOk
  $dlg.CancelButton = $btnCancel

  $result = $dlg.ShowDialog($form)
  $changed = $false
  if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    if ([string]$dlg.Tag -eq 'stock') {
      Reset-KmKey $Idx
      $changed = $true
    } elseif ([string]$cmbCat.SelectedItem -eq 'None (pass through)') {
      if ($null -ne $k.Fn) { $k.Fn = $null; $script:Km.FnDirty = $true; $changed = $true }
    } elseif ($cmbOut.SelectedIndex -ge 0 -and $state.Items.Count -gt $cmbOut.SelectedIndex) {
      $it = $state.Items[$cmbOut.SelectedIndex]
      if ($layer -eq 'base') {
        $k.Base = @(2, [int]$it.Code, [long]0)
        $script:Km.BaseDirty[$Idx] = $true
      } else {
        $k.Fn = @([int]$it.Type, [int]$it.Code, [long]$it.Extra)
        $script:Km.FnDirty = $true
      }
      $changed = $true
    }
  }
  $dlg.Dispose()
  return $changed
}

function Invoke-KmClick {
  param([int]$Idx, [bool]$Right)
  if ($null -eq $script:Km -or -not $script:Km.Keys.ContainsKey($Idx)) { return }
  $script:KmSelected = $Idx
  if ($Right) { Reset-KmKey $Idx } else { [void](Show-KeyEditor $Idx) }
  Update-KmPreview
  Update-KmInfo
  Update-KmStatus
}

function Set-KmLayer {
  param([string]$Layer)
  $script:KmLayer = $Layer
  if ($Layer -eq 'base') { $btnKmBase.BackColor = $cAcc; $btnKmFn.BackColor = $cKey } else { $btnKmBase.BackColor = $cKey; $btnKmFn.BackColor = $cAcc }
  Update-KmPreview
}

# ---------------- paint tab ----------------
function Invoke-PaintClick {
  param([int]$I, [bool]$Right)
  $n = [string]$script:KeyNames[$I]
  if ($Right) { [void]$script:Paint.Remove($n) }
  else { $script:Paint[$n] = @([int]$script:PaintColor.R, [int]$script:PaintColor.G, [int]$script:PaintColor.B) }
  Update-PaintPreview
}

# ---------------- event wiring ----------------
$pv.Add_MouseUp({
  param($sender, $ev)
  $i = Get-PvHit $ev.X $ev.Y
  if ($i -lt 0) { return }
  $right = ($ev.Button -eq [System.Windows.Forms.MouseButtons]::Right)
  if ($script:Mode -eq 'paint') { Invoke-PaintClick $i $right }
  elseif ($script:Mode -eq 'keymap') { Invoke-KmClick ($i + 1) $right }
})

$pv.Add_MouseMove({
  param($sender, $ev)
  if ($script:Mode -eq 'effects') { return }
  $i = Get-PvHit $ev.X $ev.Y
  if ($i -ne $script:PvHover) {
    $script:PvHover = $i
    if ($script:Mode -eq 'keymap') { if ($i -ge 0) { Update-KmInfo ($i + 1) } else { Update-KmInfo } }
    $pv.Invalidate()
  }
})

$pv.Add_MouseLeave({
  if ($script:PvHover -ne -1) { $script:PvHover = -1; if ($script:Mode -eq 'keymap') { Update-KmInfo }; $pv.Invalidate() }
})

$btnTabEff.Add_Click({ Set-Tab 'effects' })
$btnTabPaint.Add_Click({ Set-Tab 'paint' })
$btnTabKm.Add_Click({ Set-Tab 'keymap' })

$btnMenu.Add_Click({ $menu.Show($btnMenu, 0, $btnMenu.Height) })
$btnSync.Add_Click({ [void](Sync-FromKeyboard) })
$miSync.Add_Click({ [void](Sync-FromKeyboard) })
$miReconnect.Add_Click({ if (Connect-Keyboard) { [void](Sync-FromKeyboard) } })
$miCopy.Add_Click({
  try { [System.Windows.Forms.Clipboard]::SetText($txtLog.Text); Write-Log 'Log copied to the clipboard.' }
  catch { Write-Log ('Could not copy: ' + $_.Exception.Message) }
})
$miDiag.Add_Click({
  Set-LogVisible $true
  Write-Log '--- Diagnose (read-only: asks each HID collection for reports 5, 6 and 8) ---'
  if (-not (Connect-Keyboard)) { return }
  try { foreach ($l in $script:Dev.Diagnose()) { Write-Log $l } }
  catch { Write-Log ('ERROR: ' + $_.Exception.Message) }
  Write-Log '--- end of diagnose ---'
})
$miDry.Add_Click({
  $script:DryRun = $miDry.Checked
  if ($script:DryRun) { Write-Log 'Dry run ON: nothing will be sent to the keyboard.'; Set-Pill 'Dry run' $cWarn }
  else { Write-Log 'Dry run OFF.'; if ($script:Connected) { Set-Pill 'Connected' $cOk } else { Set-Pill 'Not connected' $cKey } }
})
$btnLog.Add_Click({ Set-LogVisible (-not $script:LogOpen); Save-AppSettings })

$cmbEff.Add_SelectedIndexChanged({ Update-EffControls; Queue-AutoApply })
$chkColor.Add_CheckedChanged({ Queue-AutoApply })
$trkSpeed.Add_ValueChanged({ $lblSpeedVal.Text = [string]$trkSpeed.Value; Queue-AutoApply })
$trkBri.Add_ValueChanged({ $lblBriVal.Text = [string]$trkBri.Value; Queue-AutoApply })
$btnEffColor.Add_Click({
  $c = Pick-Color $script:EffColor
  if ($null -ne $c) {
    $script:EffColor = $c
    $btnEffColor.BackColor = $c
    $btnEffColor.ForeColor = Get-TextColor $c
    $btnEffColor.Text = ('#{0:X2}{1:X2}{2:X2}' -f $c.R, $c.G, $c.B)
    $chkColor.Checked = $true
    Queue-AutoApply
  }
})
$btnApply.Add_Click({ [void](Invoke-ApplyEffect $false) })
$chkAuto.Add_CheckedChanged({
  if ($script:Building) { return }
  if ($chkAuto.Checked -and -not $script:Settings.AutoApplyAck) {
    $r = [System.Windows.Forms.MessageBox]::Show(
      "Auto-apply writes the effect to the keyboard's flash about 0.7 s after you stop changing something (never while a slider is dragged, and never twice for the same settings). Turn it on?",
      'Auto-apply', 'OKCancel', 'Information')
    if ($r -ne [System.Windows.Forms.DialogResult]::OK) { $chkAuto.Checked = $false; return }
    $script:Settings.AutoApplyAck = $true
  }
  $script:AutoApply = $chkAuto.Checked
  Save-AppSettings
})

$btnPaintColor.Add_Click({
  $c = Pick-Color $script:PaintColor
  if ($null -ne $c) {
    $script:PaintColor = $c
    $btnPaintColor.BackColor = $c
    $btnPaintColor.ForeColor = Get-TextColor $c
    $btnPaintColor.Text = ('Paint color: #{0:X2}{1:X2}{2:X2}' -f $c.R, $c.G, $c.B)
  }
})
$btnFill.Add_Click({
  foreach ($n in $script:KeyNames) { $script:Paint[[string]$n] = @([int]$script:PaintColor.R, [int]$script:PaintColor.G, [int]$script:PaintColor.B) }
  Update-PaintPreview
})
$btnOff.Add_Click({ $script:Paint.Clear(); Update-PaintPreview })
$btnSave.Add_Click({
  if (-not (Ensure-Device)) { return }
  if ($script:Paint.Count -eq 0) { Write-Log 'Nothing painted yet.'; return }
  if (-not (Confirm-Flash)) { return }
  try {
    $btnSave.Enabled = $false
    $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
    Write-Log ('Saving {0} painted key(s) to the keyboard' -f $script:Paint.Count)
    $frames = New-PaintFrames $script:Paint
    Send-Frames $frames $true
    Write-Log 'Done.'
  } catch {
    Write-Log ('ERROR: save failed: ' + $_.Exception.Message)
    [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Save failed', 'OK', 'Error') | Out-Null
  } finally {
    $form.Cursor = [System.Windows.Forms.Cursors]::Default
    $btnSave.Enabled = $true
  }
})

$btnKmBase.Add_Click({ Set-KmLayer 'base' })
$btnKmFn.Add_Click({ Set-KmLayer 'fn' })
$btnKmOpen.Add_Click({
  $dlg = New-Object System.Windows.Forms.OpenFileDialog
  $dlg.Title = 'Open the Redragon Cfg.ini'
  $dlg.Filter = 'Cfg.ini|*.ini|All files|*.*'
  if ($script:Settings.LastCfg -and (Test-Path ([string]$script:Settings.LastCfg))) { $dlg.InitialDirectory = [System.IO.Path]::GetDirectoryName([string]$script:Settings.LastCfg) }
  elseif ($PSScriptRoot) { $dlg.InitialDirectory = $PSScriptRoot }
  if ($dlg.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { Open-KmFile $dlg.FileName }
})
$btnKmSave.Add_Click({
  if ($null -eq $script:Km) { return }
  $issues = Get-KeymapIssues $script:Km
  $errs = @($issues | Where-Object { $_.Level -eq 'error' })
  if ($errs.Count -gt 0) {
    [System.Windows.Forms.MessageBox]::Show((($errs | ForEach-Object { $_.Text }) -join [Environment]::NewLine), 'Fix these first', 'OK', 'Error') | Out-Null
    return
  }
  $warns = @($issues | Where-Object { $_.Level -eq 'warn' })
  if ($warns.Count -gt 0) {
    $r = [System.Windows.Forms.MessageBox]::Show((($warns | ForEach-Object { $_.Text }) -join [Environment]::NewLine) + [Environment]::NewLine + [Environment]::NewLine + 'Save anyway?', 'Warnings', 'YesNo', 'Warning')
    if ($r -ne [System.Windows.Forms.DialogResult]::Yes) { return }
  }
  $dlg = New-Object System.Windows.Forms.SaveFileDialog
  $dlg.Title = 'Save the edited Cfg.ini'
  $dlg.Filter = 'Cfg.ini|*.ini|All files|*.*'
  $dlg.FileName = 'Cfg.edited.ini'
  if ($script:Km.Path) { $dlg.InitialDirectory = [System.IO.Path]::GetDirectoryName($script:Km.Path) }
  if ($dlg.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { return }
  try {
    $target = $dlg.FileName
    if ($script:Km.Path -and ([System.IO.Path]::GetFullPath($target) -ieq [System.IO.Path]::GetFullPath($script:Km.Path)) -and (Test-Path $target)) {
      $bak = $target + '.bak'
      if (-not (Test-Path $bak)) { Copy-Item $target $bak; Write-Log ('Backed up the original to ' + $bak) }
    }
    Write-CfgFile $script:Km $target
    $blk = New-KeymapBlock $script:Km
    Write-Log ('Saved ' + $target + ' (keymap block sha256 ' + (Get-Sha256Hex $blk).Substring(0, 16) + '...)')
    Write-Log 'To apply it now: put this file where the Redragon software keeps Cfg.ini (keep a backup of the original), open the software and press RESTORE (not APPLY).'
  } catch {
    Write-Log ('ERROR: save failed: ' + $_.Exception.Message)
    [System.Windows.Forms.MessageBox]::Show($_.Exception.Message, 'Save failed', 'OK', 'Error') | Out-Null
  }
})

$script:AnimTimer = New-Object System.Windows.Forms.Timer
$script:AnimTimer.Interval = 40
$script:AnimTimer.Add_Tick({ Step-Anim })

$form.Add_FormClosing({
  $script:AnimTimer.Stop()
  $script:DebounceTimer.Stop()
  Save-AppSettings
  Close-Keyboard
})

$form.Add_Shown({
  $script:GuiReady = $true
  Write-Log 'Fizz Lighting ready. Protocol ported from fizzctl (MIT).'
  Update-EffControls
  $lblSpeedVal.Text = [string]$trkSpeed.Value
  $lblBriVal.Text = [string]$trkBri.Value
  $script:Building = $false
  if ($script:Settings.ShowLog) { Set-LogVisible $true }
  $startTab = [string]$script:Settings.Tab
  if ($startTab -ne 'paint' -and $startTab -ne 'keymap') { $startTab = 'effects' }
  Set-Tab $startTab
  $script:AnimTimer.Start()
  if (Connect-Keyboard) { [void](Sync-FromKeyboard) }
})

[void]$form.ShowDialog()
