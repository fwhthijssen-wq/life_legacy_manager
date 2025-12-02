// lib/modules/auth/screens/setup_pin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_legacy_manager/l10n/app_localizations.dart';

import '../providers/auth_providers.dart';
import '../repository/auth_repository.dart';
// import '../services/auth_service.dart';  // DISABLED for Sprint 1B
// import '../services/biometric_service.dart';  // DISABLED for Sprint 1B

class SetupPinScreen extends ConsumerStatefulWidget {
  final String userId;

  const SetupPinScreen({super.key, required this.userId});

  @override
  ConsumerState<SetupPinScreen> createState() => _SetupPinScreenState();
}

class _SetupPinScreenState extends ConsumerState<SetupPinScreen> {
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();

  bool isLoading = false;
  bool pinVisible = false;
  bool confirmPinVisible = false;
  bool biometricsAvailable = false;

  @override
  void initState() {
    super.initState();
    // _checkBiometrics();  // DISABLED for Sprint 1B
  }

  @override
  void dispose() {
    pinController.dispose();
    confirmPinController.dispose();
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

  Future<void> _savePin() async {
    final l10n = AppLocalizations.of(context)!;
    final pin = pinController.text.trim();
    final confirm = confirmPinController.text.trim();

    if (pin.isEmpty) {
      _showSnackBar(l10n.validationPinEmpty);
      return;
    }

    if (pin.length < 4) {
      _showSnackBar(l10n.validationPinLength);
      return;
    }

    if (pin.length > 8) {
      _showSnackBar(l10n.validationPinMax);
      return;
    }

    if (pin != confirm) {
      _showSnackBar(l10n.validationPinMatch);
      return;
    }

    setState(() => isLoading = true);

    try {
      // Use AuthRepository directly instead of AuthService
      final authRepository = ref.read(authRepositoryProvider);
      
      print('💾 Setting up PIN for user: ${widget.userId}');
      print('📌 PIN length: ${pin.length}');
      
      await authRepository.setupPin(
        userId: widget.userId,
        pin: pin,
        enableBiometric: false,  // Disabled for Sprint 1B
      );
      
      print('✅ PIN saved successfully!');

      if (mounted) {
        // Skip biometrics setup for Sprint 1B
        // if (biometricsAvailable) {
        //   await _askForBiometrics();
        // } else {
        //   _goToHome();
        // }
        _goToHome();
      }
    } catch (e) {
      print('❌ Error setting up PIN: $e');
      _showSnackBar("${l10n.error}: $e");
      setState(() => isLoading = false);
    }
  }

  // DISABLED for Sprint 1B
  // Future<void> _askForBiometrics() async {
  //   final l10n = AppLocalizations.of(context)!;
  //   
  //   final shouldSetup = await showDialog<bool>(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text(l10n.pinBiometricTitle),
  //       content: Text(l10n.pinBiometricMessage),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: Text(l10n.pinBiometricNotNow),
  //         ),
  //         FilledButton(
  //           onPressed: () => Navigator.pop(context, true),
  //           child: Text(l10n.pinBiometricActivate),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   if (shouldSetup == true && mounted) {
  //     final authService = ref.read(authServiceProvider);
  //     await authService.enableBiometrics(widget.userId);
  //   }
  //
  //   _goToHome();
  // }

  void _skipSetup() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.pinSkipTitle),
        content: Text(l10n.pinSkipMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _goToHome();
            },
            child: Text(l10n.skip),
          ),
        ],
      ),
    );
  }

  void _goToHome() {
    if (mounted) {
      // Update auth state
      ref.read(authStateProvider.notifier).login(widget.userId);
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.pinSetupTitle),
        actions: [
          TextButton(
            onPressed: _skipSetup,
            child: Text(l10n.skip),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info sectie
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.lock_clock,
                      size: 64,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.pinSetupTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.pinSetupSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // PIN invoer
              Text(
                l10n.pinChooseTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.pinChooseSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: pinController,
                obscureText: !pinVisible,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: InputDecoration(
                  labelText: l10n.pinNew,
                  hintText: l10n.pinNewHint,
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
              ),

              const SizedBox(height: 16),

              TextField(
                controller: confirmPinController,
                obscureText: !confirmPinVisible,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: InputDecoration(
                  labelText: l10n.pinConfirm,
                  hintText: l10n.pinConfirmHint,
                  prefixIcon: const Icon(Icons.pin_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(
                      confirmPinVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() => confirmPinVisible = !confirmPinVisible);
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),

              const SizedBox(height: 32),

              // Opslaan knop
              SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: isLoading ? null : _savePin,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(
                    isLoading ? l10n.pinSetupInProgress : l10n.pinSetup,
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

              const SizedBox(height: 16),

              // Skip knop
              SizedBox(
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: _skipSetup,
                  icon: const Icon(Icons.skip_next),
                  label: Text(
                    l10n.pinSkipLater,
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Biometrie indicator - HIDDEN for Sprint 1B
              // if (biometricsAvailable)
              //   Container(...),

              const SizedBox(height: 16),

              // Tips
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber[800],
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.pinTipsTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip(l10n.pinTip1),
                    _buildTip(l10n.pinTip2),
                    _buildTip(l10n.pinTip3),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "• ",
            style: TextStyle(
              color: Colors.amber[900],
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.amber[900],
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
