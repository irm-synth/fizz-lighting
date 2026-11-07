# A fake keyboard: records every frame written and answers the sync reads from a configurable effect state.
class FakeDev {
  [System.Collections.Generic.List[byte[]]] $Sent = (New-Object 'System.Collections.Generic.List[byte[]]')
  [hashtable] $State = @{ Name = 'rainbow-wheel'; Speed = 4; Bri = 2; Color = $null }
  [string] $Selected = ''
  [int] $SlotCount = 2
  [string] $LastSendMode = 'exact'
  [string] $LastRoute = 'mi_01/col06'
  [bool] $InRead = $false
  [void] SetFeature([byte[]] $d) {
    # The write sequence starts with 05 83 b6, which is also the "read EXEC" selector. A read always
    # begins with the MODE selector (05 88 b8), so treat 05 83 b6 as a read only right after that.
    if ($d.Length -eq 6 -and $d[0] -eq 5 -and $d[1] -eq 0x88) { $this.InRead = $true; $this.Selected = 'Mode'; return }
    if ($d.Length -eq 6 -and $d[0] -eq 5 -and $d[1] -eq 0x83 -and $this.InRead) { $this.Selected = 'Exec'; return }
    $this.Sent.Add($d)
  }
  [byte[]] GetFeature([int] $id, [int] $size) {
    if ($this.Selected -eq '') { return (New-Object byte[] 1032) }
    $fr = New-EffectFrames -Name $this.State.Name -Color $this.State.Color -Speed $this.State.Speed -Brightness $this.State.Bri
    $which = $this.Selected; $this.Selected = ''
    if ($which -eq 'Exec') { $this.InRead = $false }
    if ($which -eq 'Mode') { return [byte[]]$fr[1] }
    return [byte[]]$fr[4]
  }
  [bool] CarriesReport([int] $id) { return $false }
  [string[]] Diagnose() { return @('collection mi_01/col05 [fake]', '    GET report 5: ok') }
  [void] Dispose() { }
}
$global:FakeDevInstance = [FakeDev]::new()
function Test-FakeFind {
  $o = [pscustomobject]@{ Name = 'fake' } | Add-Member -MemberType ScriptMethod -Name Describe -Value { 'mi_01/col06  usage page 0xFF00, feature len 1032 (fake)' } -PassThru
  return , @($o)
}
function Test-FakeOpen { param($List) return $global:FakeDevInstance }
