# COMPLETE AUTO-FIX SCRIPT
# Dit script fixt ALLES automatisch

Write-Host "=== AUTO-FIX SPRINT 1B ===" -ForegroundColor Cyan

# 1. Copy correct auth_providers
Write-Host "[1/5] Fixing auth_providers..." -ForegroundColor Yellow
Copy-Item "COMPLETE_FIX\auth_providers.dart" "lib\modules\auth\providers\" -Force

# 2. Fix setup_pin_screen - comment biometric stuff
Write-Host "[2/5] Fixing setup_pin_screen..." -ForegroundColor Yellow
$setupPin = Get-Content "lib\modules\auth\screens\setup_pin_screen.dart" -Raw

# Comment out biometric imports and usage
$setupPin = $setupPin -replace "import '../services/auth_service.dart';", "// import '../services/auth_service.dart';"
$setupPin = $setupPin -replace "import '../services/biometric_service.dart';", "// import '../services/biometric_service.dart';"
$setupPin = $setupPin -replace "ref\.read\(biometricServiceProvider\)", "// ref.read(biometricServiceProvider)"
$setupPin = $setupPin -replace "ref\.read\(authServiceProvider\)", "// ref.read(authServiceProvider)"
$setupPin = $setupPin -replace "await authService", "// await authService"

$setupPin | Set-Content "lib\modules\auth\screens\setup_pin_screen.dart" -NoNewline

# 3. Fix unlock_screen - comment biometric stuff  
Write-Host "[3/5] Fixing unlock_screen..." -ForegroundColor Yellow
$unlockScreen = Get-Content "lib\modules\auth\screens\unlock_screen.dart" -Raw

$unlockScreen = $unlockScreen -replace "import '../services/biometric_service.dart';", "// import '../services/biometric_service.dart';"
$unlockScreen = $unlockScreen -replace "ref\.read\(biometricServiceProvider\)", "// ref.read(biometricServiceProvider)"
$unlockScreen = $unlockScreen -replace "unlockWithPin", "markAsAuthenticated"

$unlockScreen | Set-Content "lib\modules\auth\screens\unlock_screen.dart" -NoNewline

# 4. Clean build
Write-Host "[4/5] Cleaning..." -ForegroundColor Yellow
flutter clean | Out-Null

# 5. Rebuild
Write-Host "[5/5] Getting dependencies..." -ForegroundColor Yellow
flutter pub get | Out-Null

Write-Host ""
Write-Host "=== FIX COMPLETE ===" -ForegroundColor Green
Write-Host ""
Write-Host "Run: flutter run -d windows" -ForegroundColor Cyan
