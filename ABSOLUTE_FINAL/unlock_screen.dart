// lib/modules/auth/screens/unlock_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_legacy_manager/l10n/app_localizations.dart';

import '../providers/auth_providers.dart';
import '../repository/auth_repository.dart';
// import '../services/biometric_service.dart';  // DISABLED for Sprint 1B
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
    // _checkBiometrics();  // DISABLED for Sprint 1B
  }

  @override
  void dispose() {
    _pinController.dispose();
    super.dispose();
  }

  // DISABLED for Sprint 1B
  // Future<void> _checkBiometrics() async {
  //   final biometricService = ref.read(biometricServiceProvider);
  //   final available = await biometricService.canCheckBiometrics();
  //   setState(() {
  //     biometricsAvailable = available;
  //   });
  // }

  Future<void> _unlockWithPin() async {
    final l10n = AppLocalizations.of(context)!;
    final pin = _pinController.text.trim();

    if (pin.isEmpty) {
      _showError(l10n.validationPinEmpty);
      return;
    }

    if (pin.length < 4) {
      _showError(l10n.validationPinLength);
      return;
    }

    setState(() => isLoading = true);

    try {
      final authState = ref.read(authStateProvider);
      final userId = authState.userId;
      
      if (userId == null) {
        throw Exception('No user ID found in auth state');
      }

      // Verify PIN
      final authRepository = ref.read(authRepositoryProvider);
      final success = await authRepository.verifyPin(
        userId: userId,
        pin: pin,
      );

      setState(() => isLoading = false);

      if (success && mounted) {
        // Update state to authenticated
        ref.read(authStateProvider.notifier).markAsAuthenticated(userId);
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        _showError(l10n.unlockError);
        _pinController.clear();
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showError("${l10n.error}: $e");
      print("❌ Unlock error: $e");
    }
  }

  // DISABLED for Sprint 1B
  // Future<void> _unlockWithBiometrics() async {
  //   final l10n = AppLocalizations.of(context)!;
  //   
  //   try {
  //     final biometricService = ref.read(biometricServiceProvider);
  //     final success = await biometricService.authenticate(l10n.unlockBiometric);
  //
  //     if (success && mounted) {
  //       final authState = ref.read(authStateProvider);
  //       final userId = authState.userId;
  //       if (userId != null) {
  //         ref.read(authStateProvider.notifier).markAsAuthenticated(userId);
  //         Navigator.pushReplacementNamed(context, AppRoutes.home);
  //       }
  //     } else {
  //       _showError(l10n.unlockBiometricFailed);
  //     }
  //   } catch (e) {
  //     _showError(l10n.unlockBiometricUnavailable);
  //     print("❌ Biometric error: $e");
  //   }
  // }

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
    final l10n = AppLocalizations.of(context)!;

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
                  l10n.unlockTitle,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                Text(
                  l10n.unlockSubtitle,
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
                    labelText: l10n.unlockPinLabel,
                    hintText: l10n.unlockPinHint,
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
                      isLoading ? l10n.unlockInProgress : l10n.unlockButton,
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

                // Biometrie knop (DISABLED for Sprint 1B)
                // if (biometricsAvailable) ...[
                //   const SizedBox(height: 16),
                //   SizedBox(...),
                // ],

                const SizedBox(height: 32),

                // Inloggen met wachtwoord optie
                TextButton(
                  onPressed: _goToLogin,
                  child: Text(
                    l10n.unlockWithPassword,
                    style: const TextStyle(fontSize: 14),
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
                          l10n.unlockInfoMessage,
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
