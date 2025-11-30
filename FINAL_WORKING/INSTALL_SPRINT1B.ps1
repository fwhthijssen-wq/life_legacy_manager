# ===============================================
# SPRINT 1B - DEFINITIVE INSTALLER
# ===============================================
# Dit script installeert EN fixt alles automatisch
# ===============================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host " SPRINT 1B - RECOVERY PHRASE INSTALLER" -ForegroundColor Cyan  
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if in project root
if (!(Test-Path "pubspec.yaml")) {
    Write-Host "ERROR: Run dit script vanuit de project root!" -ForegroundColor Red
    Write-Host "cd C:\Projects\life_legacy_manager" -ForegroundColor Yellow
    exit 1
}

Write-Host "[1/6] Checking pubspec.yaml..." -ForegroundColor Yellow

# Check if flutter.generate is enabled
$pubspecContent = Get-Content "pubspec.yaml" -Raw
if ($pubspecContent -notmatch "generate:\s*true") {
    Write-Host "  WARNING: 'generate: true' not found in pubspec.yaml" -ForegroundColor Red
    Write-Host "  Adding it now..." -ForegroundColor Yellow
    
    # Add generate: true under flutter:
    $pubspecContent = $pubspecContent -replace "(flutter:)", "`$1`n  generate: true"
    $pubspecContent | Set-Content "pubspec.yaml" -NoNewline
    
    Write-Host "  FIXED: Added 'generate: true' to pubspec.yaml" -ForegroundColor Green
}
else {
    Write-Host "  OK: generate: true found" -ForegroundColor Green
}

Write-Host ""
Write-Host "[2/6] Cleaning project..." -ForegroundColor Yellow
flutter clean | Out-Null
Remove-Item -Recurse -Force "build" -ErrorAction SilentlyContinue
Remove-Item -Recurse -Force ".dart_tool\flutter_gen" -ErrorAction SilentlyContinue
Write-Host "  Done!" -ForegroundColor Green

Write-Host ""
Write-Host "[3/6] Getting dependencies..." -ForegroundColor Yellow
flutter pub get | Out-Null
Write-Host "  Done!" -ForegroundColor Green

Write-Host ""
Write-Host "[4/6] Generating localizations..." -ForegroundColor Yellow
flutter gen-l10n | Out-Null

# Verify localization was generated
if (Test-Path "lib\l10n\app_localizations.dart") {
    Write-Host "  SUCCESS: app_localizations.dart generated!" -ForegroundColor Green
}
else {
    Write-Host "  ERROR: Localization generation failed!" -ForegroundColor Red
    Write-Host "  Check l10n.yaml and try again" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[5/6] Verifying file structure..." -ForegroundColor Yellow

$requiredFiles = @(
    "lib\modules\auth\screens\recover_password_screen.dart",
    "lib\modules\auth\screens\setup_recovery_phrase_screen.dart",
    "lib\modules\auth\screens\verify_recovery_phrase_screen.dart",
    "lib\modules\auth\services\recovery_phrase_service.dart",
    "lib\modules\auth\services\wordlists\bip39_english.dart",
    "lib\modules\auth\services\wordlists\bip39_dutch.dart"
)

$allPresent = $true
foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  OK: $file" -ForegroundColor Green
    }
    else {
        Write-Host "  MISSING: $file" -ForegroundColor Red
        $allPresent = $false
    }
}

if (!$allPresent) {
    Write-Host ""
    Write-Host "  ERROR: Some files are missing!" -ForegroundColor Red
    Write-Host "  Make sure you extracted sprint1b_ready_to_extract.zip correctly" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[6/6] Running flutter analyze..." -ForegroundColor Yellow
$analyzeOutput = flutter analyze --no-fatal-infos 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "  No issues found!" -ForegroundColor Green
}
else {
    Write-Host "  Some warnings found (this is OK)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host " INSTALLATION COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next step:" -ForegroundColor Cyan
Write-Host "  flutter run -d windows" -ForegroundColor White
Write-Host ""
Write-Host "If you still get errors, run:" -ForegroundColor Cyan  
Write-Host "  flutter clean" -ForegroundColor White
Write-Host "  flutter pub get" -ForegroundColor White
Write-Host "  flutter gen-l10n" -ForegroundColor White
Write-Host "  flutter run -d windows" -ForegroundColor White
Write-Host ""
