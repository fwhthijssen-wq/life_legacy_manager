# 🚨 FINAL FIX - Auth Providers

**Probleem:** Andere bestanden importeren nog oude auth_service.dart

---

## ✅ SNELLE FIX (COPY-PASTE)

```powershell
cd C:\Projects\life_legacy_manager

# Fix auth_providers.dart
copy FINAL_FIX\auth_providers.dart lib\modules\auth\providers\

# Fix setup_pin_screen.dart - verwijder de import van auth_service
# Open het bestand en comment regel 9 uit:
# // import '../services/auth_service.dart';

# OF gebruik deze command om het automatisch te doen:
(Get-Content lib\modules\auth\screens\setup_pin_screen.dart) -replace "import '../services/auth_service.dart';", "// import '../services/auth_service.dart';" | Set-Content lib\modules\auth\screens\setup_pin_screen.dart

# Comment de lines uit die authServiceProvider gebruiken (regel 78 en 117)
# OF temporary disable biometrics:
(Get-Content lib\modules\auth\screens\setup_pin_screen.dart) -replace "ref.read\(authServiceProvider\)", "// ref.read(authServiceProvider)" | Set-Content lib\modules\auth\screens\setup_pin_screen.dart

# Build
flutter clean
flutter run -d windows
```

---

## ⚡ SIMPELSTE OPLOSSING

Comment gewoon de biometric code uit in setup_pin_screen.dart:

Regel 78 en 117 - comment deze uit:
```dart
// await ref.read(authServiceProvider).enableBiometric(widget.userId);
```

Sprint 1B werkt dan zonder biometrics (die komen later toch).

---

**DAARNA ZOU HET MOETEN WERKEN!** ✅
