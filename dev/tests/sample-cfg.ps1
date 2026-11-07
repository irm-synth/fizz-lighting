# Generates a small synthetic Cfg.ini (stock K617 layout) from the data embedded in fizz-gui.ps1.
# Dot-source this after loading the app with -NoGui.
# Matrix column of each key (K1..K61) in the K617's keymap block. Facts about the board, used to
# regenerate a small sample Cfg.ini from the data embedded in fizz-gui.ps1.
$Cols = @(1,7,13,19,25,31,37,43,49,55,61,67,73,79,2,8,14,20,26,32,38,44,50,56,62,68,74,80,3,9,15,21,27,33,39,45,51,57,63,69,81,4,10,16,22,28,34,40,46,52,58,64,82,5,11,17,35,53,59,77,83)
function New-SampleCfgText {
  $nl = "`r`n"
  $sb = New-Object System.Text.StringBuilder
  [void]$sb.Append('; Synthetic sample for tests: stock K617 layout, [FN] before [KEY] like the vendor file' + $nl)
  [void]$sb.Append('[FN]' + $nl)
  for ($i = 1; $i -le 61; $i++) {
    if ($script:StockFn.ContainsKey($i)) {
      [void]$sb.Append(';' + (Get-BehaviorName $script:StockBase[$i]) + $nl)
      [void]$sb.Append('K' + $i + '=' + (Format-Behavior $script:StockFn[$i]) + $nl)
    }
  }
  [void]$sb.Append($nl + '[KEY]' + $nl)
  for ($i = 1; $i -le 61; $i++) {
    $r = $script:KeyRects[$i - 1]
    $led = $script:LedIndex[[string]$script:KeyNames[$i - 1]]
    [void]$sb.Append(';' + (Get-BehaviorName $script:StockBase[$i]) + $nl)
    [void]$sb.Append(('K{0}={1},{2},{3},{4}, {5},{6},{7}' -f $i, $r[0], $r[1], $r[2], $r[3], (Format-Behavior $script:StockBase[$i]), $Cols[$i - 1], $led) + $nl)
  }
  return $sb.ToString()
}
