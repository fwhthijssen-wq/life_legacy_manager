// lib/modules/auth/screens/setup_pin_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../services/auth_service.dart';

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
    _checkBiometrics();
  }

  @override
  void dispose() {
    pinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometrics() async {
    final biometricService = ref.read(biometricServiceProvider);
    final available = await biometricService.canCheckBiometrics();
    setState(() {
      biometricsAvailable = available;
    });
  }

  Future<void> _savePin() async {
    final pin = pinController.text.trim();
    final confirm = confirmPinController.text.trim();

    if (pin.isEmpty) {
      _showSnackBar("Vul een PIN in");
      return;
    }

    if (pin.length < 4) {
      _showSnackBar("PIN moet minimaal 4 cijfers zijn");
      return;
    }

    if (pin.length > 8) {
      _showSnackBar("PIN mag maximaal 8 cijfers zijn");
      return;
    }

    if (pin != confirm) {
      _showSnackBar("PIN's komen niet overeen");
      return;
    }

    setState(() => isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.setPin(widget.userId, pin);

      if (mounted) {
        // Vraag of gebruiker biometrie wil activeren
        if (biometricsAvailable) {
          await _askForBiometrics();
        } else {
          _goToHome();
        }
      }
    } catch (e) {
      _showSnackBar("Fout bij opslaan PIN: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _askForBiometrics() async {
    final shouldSetup = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Biometrische beveiliging"),
        content: const Text(
          "Uw apparaat ondersteunt vingerafdruk of gezichtsherkenning. "
          "Wilt u dit ook activeren voor snelle toegang?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Nu niet"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Activeren"),
          ),
        ],
      ),
    );

    if (shouldSetup == true && mounted) {
      final authService = ref.read(authServiceProvider);
      await authService.enableBiometrics(widget.userId);
    }

    _goToHome();
  }

  void _skipSetup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("PIN overslaan"),
        content: const Text(
          "Weet u zeker dat u geen PIN wilt instellen? "
          "U kunt dit later alsnog doen via instellingen.\n\n"
          "Zonder PIN moet u steeds uw volledige wachtwoord invoeren.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuleren"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _goToHome();
            },
            child: const Text("Overslaan"),
          ),
        ],
      ),
    );
  }

  void _goToHome() {
    if (mounted) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Snel Inloggen"),
        actions: [
          TextButton(
            onPressed: _skipSetup,
            child: const Text("Overslaan"),
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
                      "Snel en veilig inloggen",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Stel een pincode in om voortaan snel en gemakkelijk "
                      "in te loggen zonder uw volledige wachtwoord te typen.",
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
                "Kies uw pincode",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "4 tot 8 cijfers",
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
                  labelText: "Nieuwe PIN",
                  hintText: "Voer 4-8 cijfers in",
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
                  labelText: "Herhaal PIN",
                  hintText: "Voer dezelfde PIN nogmaals in",
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
                    isLoading ? "Bezig met opslaan..." : "PIN Instellen",
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
                  label: const Text(
                    "Nu niet, later instellen",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Biometrie indicator
              if (biometricsAvailable)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fingerprint,
                        color: Colors.green[700],
                        size: 32,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          "Biometrische beveiliging beschikbaar! "
                          "Na het instellen van de PIN kunt u ook "
                          "vingerafdruk/gezichtsherkenning activeren.",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green[900],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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
                          "Tips voor een veilige PIN",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[900],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip("Gebruik geen voor de hand liggende cijfers zoals 1234 of uw geboortejaar"),
                    _buildTip("Vertel uw PIN niet aan anderen"),
                    _buildTip("U kunt de PIN later wijzigen via instellingen"),
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