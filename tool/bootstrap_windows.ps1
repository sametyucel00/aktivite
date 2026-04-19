$ErrorActionPreference = 'Stop'

Write-Host 'Bootstrapping Flutter project structure for Aktivite...'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
  throw 'Flutter SDK is not available on PATH. Install Flutter, then rerun this script.'
}

if (-not (Test-Path 'android')) {
  flutter create --platforms=android,ios,web,windows .
}

flutter pub get
flutter gen-l10n

Write-Host 'Bootstrap complete. Run .\tool\check.ps1 next.'
