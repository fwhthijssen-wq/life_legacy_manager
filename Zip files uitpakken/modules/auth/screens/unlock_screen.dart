// lib/modules/auth/screens/unlock_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_providers.dart';
import '../services/biometric_service.dart';
import '../../../core/app_routes.dart';
import '../providers/auth_providers.dart';
import '../state/auth_state.dart';


class UnlockScreen extends ConsumerStatefulWidget {
  const UnlockScreen({super.key});

  @override
  ConsumerState<UnlockScreen> createState() => _UnlockScreenState();
}

class _UnlockScreenState extends ConsumerState<UnlockScreen> {
  final _pinController = TextEditingController();
  final biometry = BiometricService();
  bool pinVisible = false;

  @override
  Widget build(BuildContext context) {
    final authNotifier = ref.read(authStateProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text("Ontgrendel app")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Voer je pincode in"),
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              decoration: InputDecoration(
                labelText: 'Pincode',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    pinVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      pinVisible = !pinVisible;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              obscureText: !pinVisible,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await authNotifier.unlockWithPin(_pinController.text);

                if (ref.read(authStateProvider).status ==
                    AuthStatus.authenticated) {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Pincode fout")),
                  );
                }
              },
              child: const Text("Ontgrendel"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final ok = await biometry.authenticate("Ontgrendel de app");
                if (ok) {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                }
              },
              child: const Text("Biometrisch ontgrendelen"),
            ),
          ],
        ),
      ),
    );
  }
}
