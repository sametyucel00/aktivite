param(
  [switch]$BuildWeb
)

$ErrorActionPreference = 'Stop'

function Invoke-Step {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Name,
    [Parameter(Mandatory = $true)]
    [scriptblock]$Script
  )

  Write-Host ""
  Write-Host "==> $Name"
  & $Script
}

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw 'Flutter SDK is not available on PATH. Install Flutter, then rerun this script.'
}

if (-not (Get-Command dart -ErrorAction SilentlyContinue)) {
  throw 'Dart SDK is not available on PATH. Install Flutter, then rerun this script.'
}

Invoke-Step 'Install dependencies' {
  flutter pub get
}

Invoke-Step 'Generate localizations' {
  flutter gen-l10n
}

Invoke-Step 'Verify formatting' {
  dart format --output=none --set-exit-if-changed .
}

Invoke-Step 'Analyze' {
  flutter analyze
}

Invoke-Step 'Test' {
  flutter test
}

if ($BuildWeb) {
  Invoke-Step 'Build web' {
    flutter build web
  }
}

Write-Host ""
Write-Host 'All requested checks completed.'
