$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$manifestPath = Join-Path $projectRoot 'android\app\src\main\AndroidManifest.xml'
if (-not (Test-Path $manifestPath)) {
  throw "AndroidManifest.xml missing. Run flutter create first."
}
$manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8
if ($manifest -notmatch 'android.permission.INTERNET') {
  $openingEnd = $manifest.IndexOf('>')
  if ($openingEnd -lt 0) { throw 'Invalid AndroidManifest.xml' }
  $manifest = $manifest.Insert($openingEnd + 1, "`r`n    <uses-permission android:name=`"android.permission.INTERNET`" />")
}
$manifest = $manifest -replace 'android:label="[^"]*"', 'android:label="Court IQ"'
Set-Content -Path $manifestPath -Value $manifest -Encoding UTF8
Write-Host 'AndroidManifest.xml: INTERNET permission and Court IQ label confirmed.'
