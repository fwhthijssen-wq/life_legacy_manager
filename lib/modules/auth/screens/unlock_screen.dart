// lib/modules/auth/screens/unlock_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../services/biometric_service.dart';
import '../../../core/app_routes.dart';
import '../state/auth_state.dart';

class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _pinController = TextEditingController();
  bool pinVisible = false;
  bool isLoading = false;
  bool biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    final biometricService = ref.read(biometricServiceProvider);
    final available = await biometricService.canCheckBiometrics();
    setState(() {
      biometricsAvailable = available;
    });
  }

  Future<void> _unlockWithPin() async {
    final pin = _pinController.text.trim();

    if (pin.isEmpty) {
      _showError("Voer een PIN in");
      return;
    }

    if (pin.length < 4) {
      _showError("PIN moet minimaal 4 cijfers zijn");
      return;
    }

    setState(() => isLoading = true);

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      final success = await authNotifier.unlockWithPin(pin);

      setState(() => isLoading = false);

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        _showError("Onjuiste PIN. Probeer opnieuw.");
        _pinController.clear();
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError("Er ging iets mis: $e");
      print("❌ Unlock error: $e");
    }
  }

  Future<void> _unlockWithBiometrics() async {
    try {
      final biometricService = ref.read(biometricServiceProvider);
      final success = await biometricService.authenticate("Ontgrendel Life & Legacy Manager");

      if (success && mounted) {
        // Biometrie geslaagd → naar home
        final authNotifier = ref.read(authStateProvider.notifier);
        authNotifier.markAsAuthenticated();
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        _showError("Biometrische authenticatie mislukt");
      }
    } catch (e) {
      _showError("Biometrie niet beschikbaar");
      print("❌ Biometric error: $e");
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_clock,
                    size: 50,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  "Welkom terug",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  "Voer uw pincode in om door te gaan",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),

                // PIN invoer
                TextField(
                  controller: _pinController,
                  obscureText: !pinVisible,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(8),
                  ],
                  decoration: InputDecoration(
                    labelText: "Pincode",
                    hintText: "Voer uw PIN in",
                    prefixIcon: const Icon(Icons.pin),
                    suffixIcon: IconButton(
                      icon: Icon(
                        pinVisible ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => pinVisible = !pinVisible);
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onSubmitted: (_) => _unlockWithPin(),
                ),

                const SizedBox(height: 24),

                // Ontgrendel knop
                SizedBox(
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : _unlockWithPin,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.lock_open),
                    label: Text(
                      isLoading ? "Bezig..." : "Ontgrendelen",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                // Biometrie knop (als beschikbaar)
                if (biometricsAvailable) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      onPressed: _unlockWithBiometrics,
                      icon: const Icon(Icons.fingerprint),
                      label: const Text(
                        "Biometrisch Ontgrendelen",
                        style: TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Inloggen met wachtwoord optie
                TextButton(
                  onPressed: _goToLogin,
                  child: const Text(
                    "Inloggen met wachtwoord",
                    style: TextStyle(fontSize: 14),
                  ),
                ),

                const SizedBox(height: 16),

                // Info text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Uw gegevens zijn veilig opgeslagen op dit apparaat",
                          style: TextStyle(
                            color: Colors.blue[900],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}