import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  @override
  void dispose() {
    pinController.dispose();
    confirmPinController.dispose();
    super.dispose();
  }

  Future<void> savePin() async {
    final pin = pinController.text.trim();
    final confirm = confirmPinController.text.trim();

    if (pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN moet minimaal 4 cijfers zijn")),
      );
      return;
    }

    if (pin != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("PIN's komen niet overeen")),
      );
      return;
    }

    setState(() => isLoading = true);

    final authService = ref.read(authServiceProvider);

    await authService.setPin(widget.userId, pin);

    setState(() => isLoading = false);

    // Ga naar home/persons
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pincode instellen")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: pinController,
              obscureText: !pinVisible,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Nieuwe PIN",
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
            ),
            const SizedBox(height: 16),
            TextField(
              controller: confirmPinController,
              obscureText: !confirmPinVisible,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Herhaal PIN",
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    confirmPinVisible ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      confirmPinVisible = !confirmPinVisible;
                    });
                  },
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isLoading ? null : savePin,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text("Opslaan"),
            ),
          ],
        ),
      ),
    );
  }
}
