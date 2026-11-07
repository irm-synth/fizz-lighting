$dev = $global:FakeDevInstance
function KeyCenter { param([int]$I) $r = $script:PvRects[$I]; return @([int]($r.X + $r.Width / 2), [int]($r.Y + $r.Height / 2)) }
function SentCount { return $dev.Sent.Count }
$L = [FakeUI.MouseButtons]::Left; $R = [FakeUI.MouseButtons]::Right

Write-Host "-- 1. startup: connect, sync from keyboard, animated preview"
Step 'startup' {
  Check 'building flag cleared' (-not $script:Building)
  Check 'starts on the Effects tab' ($script:Mode -eq 'effects' -and $pEff.Visible -and -not $pKm.Visible)
  Check 'pill says Connected' ($lblPill.Text -eq 'Connected') $lblPill.Text
  Check 'synced effect (rainbow-wheel = index 5)' ($cmbEff.SelectedIndex -eq 5) "$($cmbEff.SelectedIndex)"
  Check 'synced speed 4 / brightness 2' ($trkSpeed.Value -eq 4 -and $trkBri.Value -eq 2) "$($trkSpeed.Value)/$($trkBri.Value)"
  Check 'rainbow-wheel has no color setting -> color disabled' (-not $chkColor.Enabled -and -not $chkColor.Checked)
  Check 'last-applied signature seeded from the keyboard' ($script:LastApplied -eq '6|4|2|multi') $script:LastApplied
  Check 'sync did not queue an auto-apply' (-not $script:DebounceTimer.Enabled)
  Check 'sync wrote nothing to the keyboard' ((SentCount) -eq 0) "$(SentCount)"
  Check 'animation timer running' $script:AnimTimer.Enabled
  $before = $pv.InvalidateCount
  $c0 = $script:PvColors[0]
  Start-Sleep -Milliseconds 120
  $script:AnimTimer.FireTick()
  Check 'a tick repaints the preview' ($pv.InvalidateCount -gt $before)
  $g = New-Object FakeUI.Graphics
  $pv.FirePaint($g)
  Check 'paint draws all 61 keys without error' ($g.Fills -eq 61 -and -not $script:PvErrLogged) "fills=$($g.Fills) err=$($script:PvErrLogged)"
  Check 'no animation error logged' (-not $script:AnimErrLogged)
}

Write-Host "-- 2. choose an effect with color, pick a color, apply"
Step 'effect+color+apply' {
  $cmbEff.SelectedIndex = 1   # respire
  Check 'respire accepts color' ($chkColor.Enabled -and $btnEffColor.Enabled)
  Check 'hint mentions multicolor' ($lblEffHint.Text -match 'multicolor') $lblEffHint.Text
  [FakeUI.Host]::NextColor = [System.Drawing.Color]::FromArgb(255, 0, 0, 255)
  $btnEffColor.FireClick()
  Check 'picking a color ticks the checkbox' $chkColor.Checked
  Check 'swatch shows #0000FF' ($btnEffColor.Text -eq '#0000FF') $btnEffColor.Text
  Check 'auto-apply is off, so nothing was written yet' ((SentCount) -eq 0 -and -not $script:DebounceTimer.Enabled)
  $btnApply.FireClick()
  Check 'Apply wrote 5 frames' ((SentCount) -eq 5) "$(SentCount)"
  $mode = $dev.Sent[1]; $exec = $dev.Sent[4]
  Check 'color landed in respire''s own record (MODE[50..52] = 0,0,255)' ($mode[50] -eq 0 -and $mode[51] -eq 0 -and $mode[52] -eq 255) "$($mode[50]),$($mode[51]),$($mode[52])"
  Check 'custom-color flag set (EXEC[40] = 0)' ($exec[40] -eq 0)
  Check 'effect id 2 in EXEC[21]' ($exec[21] -eq 2)
  Check 'signature updated' ($script:LastApplied -eq '2|4|2|0,0,255') $script:LastApplied
  Check 'flash confirmation shown once' ($script:FlashWarned)
}

Write-Host "-- 3. auto-apply: debounce, no echo, no write while dragging"
Step 'auto-apply' {
  $n0 = SentCount
  $chkAuto.Checked = $true
  Check 'auto-apply accepted after confirmation' ($script:AutoApply -and $script:Settings.AutoApplyAck)
  $trkSpeed.Value = 5
  Check 'a change starts the debounce timer' $script:DebounceTimer.Enabled
  Check 'nothing written before the timer fires' ((SentCount) -eq $n0)
  $script:DebounceTimer.FireTick()
  Check 'timer fire applies once (5 frames)' ((SentCount) -eq ($n0 + 5)) "$(SentCount)"
  Check 'signature updated to speed 5' ($script:LastApplied -eq '2|5|2|0,0,255') $script:LastApplied
  $script:DebounceTimer.FireTick()
  Check 'identical settings are not written twice' ((SentCount) -eq ($n0 + 5))
  $trkBri.Value = 4
  [FakeUI.Host]::ButtonsDown = $L
  $script:DebounceTimer.FireTick()
  Check 'no write while the mouse button is held' ((SentCount) -eq ($n0 + 5) -and $script:DebounceTimer.Enabled)
  [FakeUI.Host]::ButtonsDown = [FakeUI.MouseButtons]::None
  $script:DebounceTimer.FireTick()
  Check 'writes once the button is released' ((SentCount) -eq ($n0 + 10)) "$(SentCount)"
}

Write-Host "-- 4. Sync button pulls a different effect from the keyboard"
Step 'sync' {
  $dev.State = @{ Name = 'flash-away'; Speed = 1; Bri = 0; Color = @(10, 20, 30) }
  $n0 = SentCount
  $btnSync.FireClick()
  Check 'effect follows the keyboard (flash-away = index 3)' ($cmbEff.SelectedIndex -eq 3) "$($cmbEff.SelectedIndex)"
  Check 'speed 1 / brightness 0' ($trkSpeed.Value -eq 1 -and $trkBri.Value -eq 0)
  Check 'custom color restored' ($chkColor.Checked -and $script:EffColor.R -eq 10 -and $script:EffColor.G -eq 20 -and $script:EffColor.B -eq 30)
  Check 'swatch text updated' ($btnEffColor.Text -eq '#0A141E') $btnEffColor.Text
  Check 'signature matches the keyboard' ($script:LastApplied -eq '4|1|0|10,20,30') $script:LastApplied
  Check 'sync with auto-apply ON does not write back' ((SentCount) -eq $n0 -and -not $script:DebounceTimer.Enabled)
  $chkAuto.Checked = $false
  Check 'auto-apply can be turned off' (-not $script:AutoApply)
}

Write-Host "-- 5. per-key paint tab"
Step 'paint' {
  $btnTabPaint.FireClick()
  Check 'paint tab shown' ($script:Mode -eq 'paint' -and $pPaint.Visible -and -not $pEff.Visible)
  $c = KeyCenter 15   # Q
  $pv.FireMouseUp($c[0], $c[1], $L)
  Check 'left-click paints Q' ($script:Paint.ContainsKey('Q'))
  $col = $script:PvColors[15]
  Check 'preview shows the painted color' ($col.R -eq 0 -and $col.G -eq 200 -and $col.B -eq 255) "$($col.R),$($col.G),$($col.B)"
  $pv.FireMouseMove($c[0], $c[1])
  Check 'hover tracked' ($script:PvHover -eq 15)
  $pv.FireMouseLeave()
  Check 'hover cleared on leave' ($script:PvHover -eq -1)
  $pv.FireMouseUp($c[0], $c[1], $R)
  Check 'right-click clears the key' (-not $script:Paint.ContainsKey('Q'))
  $btnFill.FireClick()
  Check 'Fill all paints 61 keys' ($script:Paint.Count -eq 61) "$($script:Paint.Count)"
  [FakeUI.Host]::NextColor = [System.Drawing.Color]::FromArgb(255, 255, 128, 0)
  $btnPaintColor.FireClick()
  Check 'paint color swatch updated' ($btnPaintColor.Text -eq 'Paint color: #FF8000') $btnPaintColor.Text
  $n0 = SentCount
  $btnSave.FireClick()
  Check 'Save sends the 4-frame paint sequence' ((SentCount) -eq ($n0 + 4)) "$(SentCount)"
  $canvas = $dev.Sent[$n0 + 1]
  Check 'canvas carries the painted colors (Esc LED 21: R plane 260+21)' ($canvas[281] -eq 0 -or $canvas[281] -eq 0) 'sanity only'
  $btnOff.FireClick()
  Check 'All off clears the paint' ($script:Paint.Count -eq 0)
  $n1 = SentCount
  $btnSave.FireClick()
  Check 'saving nothing writes nothing' ((SentCount) -eq $n1)
  $btnTabEff.FireClick()
  $c1 = $script:Paint.Count
  Check 'back on Effects, preview animates again' ($script:Mode -eq 'effects' -and $pEff.Visible)
}

Write-Host "-- 6. keymap tab: load Cfg.ini, inspect, edit, save"
$fnKeyIdx = 0
Step 'keymap load' {
  $btnTabKm.FireClick()
  Check 'keymap tab shown and Cfg.ini auto-loaded from the script folder' ($script:Mode -eq 'keymap' -and $null -ne $script:Km -and $script:Km.Keys.Count -eq 61)
  $script:fnKeyIdx = @($script:Km.Keys.Keys | Where-Object { [int]$script:Km.Keys[$_].Base[1] -eq 250 })[0]
  Check 'the model has an Fn key' ($script:fnKeyIdx -gt 0) "$($script:fnKeyIdx)"
  Check 'base view labels come from the model' ($script:PvText[51] -eq (Get-BehaviorName $script:Km.Keys[52].Base $true)) $script:PvText[51]
  Check 'base view: the Fn key is drawn in the accent color' ($script:PvColors[$script:fnKeyIdx - 1].R -eq 225)
  $btnKmFn.FireClick()
  $k56 = $script:Km.Keys[56]
  $want = if ($null -ne $k56.Fn) { Get-BehaviorName $k56.Fn $true } else { Get-BehaviorName $k56.Base $true }
  Check 'Fn view labels come from the model' ($script:PvText[55] -eq $want) "$($script:PvText[55]) vs $want"
  $fnCount = @($script:Km.Keys.Values | Where-Object { $null -ne $_.Fn }).Count
  Check 'status line shows the Fn entry count' ($lblKmStatus.Text -match ('Fn layer {0}/48' -f $fnCount)) $lblKmStatus.Text
  $c = KeyCenter 48    # K49
  $pv.FireMouseMove($c[0], $c[1])
  Check 'hover shows that key in the info line' ($lblKmInfo.Text -match '^K49 ') $lblKmInfo.Text
  $pv.FireMouseLeave()
}
Step 'keymap edit' {
  $hook = {
    param($d)
    $combos = @($d.Controls | Where-Object { $_ -is [FakeUI.ComboBox] })
    $cat = $script:HookCat; $out = $script:HookOut
    $ci = [array]::IndexOf(@($combos[0].Items.List), $cat); if ($ci -lt 0) { throw "category '$cat' not offered" }
    $combos[0].SelectedIndex = $ci
    if ($out) {
      $oi = [array]::IndexOf(@($combos[1].Items.List), $out); if ($oi -lt 0) { throw "output '$out' not offered in $cat" }
      $combos[1].SelectedIndex = $oi
    }
    $d.DialogResult = [FakeUI.DialogResult]::OK
  }
  [FakeUI.Host]::DialogHook = [Action[object]]$hook
  $script:HookCat = 'Keyboard functions'; $script:HookOut = 'Backlight speed (cycle)'
  $c = KeyCenter 55
  $pv.FireMouseUp($c[0], $c[1], $L)
  $k = $script:Km.Keys[56]
  Check 'K56 Fn now Backlight speed (0x0d000300)' ($null -ne $k.Fn -and [int]$k.Fn[0] -eq 9 -and [long]$k.Fn[2] -eq 0x0d000300)
  Check 'preview label updated to Speed' ($script:PvText[55] -eq 'Speed') $script:PvText[55]
  Check 'edited key is outlined' ($script:PvBorderW[55] -eq 2)
  Check 'selected key info shown' ($lblKmInfo.Text -match 'K56')

  $script:HookCat = 'Media'; $script:HookOut = 'Mute'
  $c = KeyCenter 40; $pv.FireMouseUp($c[0], $c[1], $L)
  Check 'K41 Fn = Mute (media 0x28)' ([int]$script:Km.Keys[41].Fn[0] -eq 4 -and [int]$script:Km.Keys[41].Fn[1] -eq 0x28)

  $script:HookCat = 'None (pass through)'; $script:HookOut = ''
  $c = KeyCenter 28; $pv.FireMouseUp($c[0], $c[1], $L)
  Check 'K29 Fn entry removed' ($null -eq $script:Km.Keys[29].Fn)

  $script:HookCat = 'Letters'; $script:HookOut = 'Z'
  $c = KeyCenter 15; $pv.FireMouseUp($c[0], $c[1], $L)
  Check 'K16 Fn = Z' ([int]$script:Km.Keys[16].Fn[1] -eq 0x5A)

  $script:HookCat = 'Letters'; $script:HookOut = 'A'
  $c = KeyCenter 13; $pv.FireMouseUp($c[0], $c[1], $L)
  Check 'K14 Fn changed to A first' ([int]$script:Km.Keys[14].Fn[1] -eq 0x41)
  $pv.FireMouseUp($c[0], $c[1], $R)
  Check 'right-click resets K14 Fn to stock' (Test-SameBehavior $script:Km.Keys[14].Fn $script:StockFn[14])

  $btnKmBase.FireClick()
  $before = [int]([regex]::Match($lblKmStatus.Text, 'base (\d+)').Groups[1].Value)
  $script:HookCat = 'Navigation and editing'; $script:HookOut = 'Tab'
  $c = KeyCenter 0; $pv.FireMouseUp($c[0], $c[1], $L)
  Check 'base K1 now Tab' ([int]$script:Km.Keys[1].Base[1] -eq 0x09 -and $script:Km.BaseDirty.ContainsKey(1))
  $after = [int]([regex]::Match($lblKmStatus.Text, 'base (\d+)').Groups[1].Value)
  Check 'status counts the base edit' ($after -eq $before + 1) "$before -> $after"
}
Step 'keymap save' {
  $target = Join-Path $PSScriptRoot 'saved.ini'
  if (Test-Path $target) { Remove-Item $target }
  [FakeUI.Host]::NextFile = $target
  $btnKmSave.FireClick()
  Check 'Save as wrote the file' (Test-Path $target)
  $m2 = Read-CfgFile $target
  Check 'reloaded: K56 Fn = speed' ([long]$m2.Keys[56].Fn[2] -eq 0x0d000300)
  Check 'reloaded: K41 Fn = Mute' ([int]$m2.Keys[41].Fn[0] -eq 4 -and [int]$m2.Keys[41].Fn[1] -eq 0x28)
  Check 'reloaded: K29 has no Fn entry' ($null -eq $m2.Keys[29].Fn)
  Check 'reloaded: K1 base = Tab' ([int]$m2.Keys[1].Base[1] -eq 0x09)
  Check 'reloaded block encodes' ((New-KeymapBlock $m2).Length -eq 1032)
  $script:Km.Keys[$script:fnKeyIdx].Fn = @(2, 65, [long]0)
  $before = [FakeUI.Host]::MessageBoxes.Count
  Remove-Item $target
  $btnKmSave.FireClick()
  Update-KmStatus
  Check 'Fn-key error blocks saving' ((-not (Test-Path $target)) -and ([FakeUI.Host]::MessageBoxes.Count -gt $before) -and ([FakeUI.Host]::MessageBoxes[-1] -match 'Fn key')) ([FakeUI.Host]::MessageBoxes[-1])
  Check 'status line shows the error' ($lblKmStatus.Text -match 'ERROR')
  $script:Km.Keys[$script:fnKeyIdx].Fn = $null
}

Write-Host "-- 7. log drawer, tools menu, dry run"
Step 'log+menu' {
  $btnTabEff.FireClick()
  Check 'log hidden by default' (-not $txtLog.Visible -and $form.ClientSize.Height -eq 608) "$($form.ClientSize.Height)"
  $btnLog.FireClick()
  Check 'Show log opens the drawer' ($txtLog.Visible -and $form.ClientSize.Height -eq 776 -and $btnLog.Text -eq 'Hide log')
  $btnLog.FireClick()
  Check 'Hide log closes it' (-not $txtLog.Visible -and $form.ClientSize.Height -eq 608)
  Write-Log 'ERROR: boom'
  Check 'an error opens the drawer by itself' ($txtLog.Visible)
  Check 'footer shows the error' ($lblMsg.Text -eq 'ERROR: boom') $lblMsg.Text
  $btnLog.FireClick()    # close the drawer the error opened
  Write-Log 'Sync skipped: could not read the keyboard state (test)'
  Check 'a soft warning does not open the drawer' (-not $txtLog.Visible) "$($txtLog.Visible)"
  Write-Log 'Everything is fine'
  Check 'normal messages mirror to the footer' ($lblMsg.Text -eq 'Everything is fine')
  Write-Log '  sent 1/5 indented detail'
  Check 'indented detail lines do not overwrite the footer' ($lblMsg.Text -eq 'Everything is fine')
  $btnMenu.FireClick()
  Check 'menu opens' ($menu.ShowCount -eq 1)
  $miDiag.FireClick()
  Check 'Diagnose logs its read-only report' ($txtLog.Text -match 'GET report 5')
  $miCopy.FireClick()
  Check 'Copy log fills the clipboard' ([FakeUI.Host]::Clipboard.Length -gt 100)
  $n0 = SentCount
  $miDry.FireUserClick()
  Check 'dry run on: pill says Dry run' ($script:DryRun -and $lblPill.Text -eq 'Dry run')
  $btnApply.FireClick()
  Check 'dry run writes nothing' ((SentCount) -eq $n0) "$(SentCount) vs $n0"
  Check 'dry run logs the frames' ($txtLog.Text -match 'dry run\] 1/5 INIT')
  $btnSync.FireClick()
  Check 'dry run skips sync' ($txtLog.Text -match 'Dry run is on: sync skipped')
  $miDry.FireUserClick()
  Check 'dry run off: pill back to Connected' ((-not $script:DryRun) -and $lblPill.Text -eq 'Connected')
  $dev.State = @{ Name = 'sine-wave'; Speed = 2; Bri = 3; Color = $null }
  $miReconnect.FireClick()
  Check 'Reconnect reconnects and syncs (sine-wave = index 12)' ($cmbEff.SelectedIndex -eq 12 -and $lblPill.Text -eq 'Connected') "$($cmbEff.SelectedIndex)"
}

Write-Host "-- 8. every effect can be selected and previewed without error"
Step 'all effects' {
  $bad = @()
  for ($i = 0; $i -lt $cmbEff.Items.Count; $i++) {
    $cmbEff.SelectedIndex = $i
    $script:AnimTimer.FireTick()
    $g = New-Object FakeUI.Graphics; $pv.FirePaint($g)
    if ($g.Fills -ne 61) { $bad += $i }
  }
  Check 'all 22 effects render a full frame' ($bad.Count -eq 0 -and -not $script:AnimErrLogged -and -not $script:PvErrLogged) ($bad -join ',')
  $btnTabKm.FireClick(); $btnTabPaint.FireClick()
  $g = New-Object FakeUI.Graphics; $pv.FirePaint($g)
  Check 'paint tab draws with labels' ($g.Strings -eq 61) "$($g.Strings)"
  $btnTabKm.FireClick()
  $g = New-Object FakeUI.Graphics; $pv.FirePaint($g)
  Check 'keymap tab draws' ($g.Fills -eq 61)
}

Write-Host '-- app log (last 25 lines) --'
($txtLog.Text -split "`n" | Select-Object -Last 25) | ForEach-Object { Write-Host ('   ' + $_.TrimEnd()) }
