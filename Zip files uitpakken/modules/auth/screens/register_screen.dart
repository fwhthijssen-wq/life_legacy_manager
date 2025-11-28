import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../../../core/app_routes.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  DateTime? birthDate;
  String gender = "man";

  bool isLoading = false;
  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  @override
  void dispose() {
    firstNameCtrl.dispose();
    lastNameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> pickBirthDate() async {
    final now = DateTime.now();
    final initial = DateTime(now.year - 30, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: birthDate ?? initial,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      setState(() => birthDate = picked);
    }
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    if (birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Selecteer een geboortedatum.")),
      );
      return;
    }

    setState(() => isLoading = true);

    final repo = ref.read(authRepositoryProvider);

    final userId = await repo.register(
      firstName: firstNameCtrl.text.trim(),
      lastName: lastNameCtrl.text.trim(),
      email: emailCtrl.text.trim(),
      password: passwordCtrl.text.trim(),
      birthDate: birthDate!,
      gender: gender,
    );

    setState(() => isLoading = false);

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registratie mislukt.")),
      );
      return;
    }

    // Ga naar PIN instellen
    if (mounted) {
      Navigator.pushNamed(
        context,
        AppRoutes.setupPin,
        arguments: userId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Account aanmaken")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Voornaam
              TextFormField(
                controller: firstNameCtrl,
                decoration: const InputDecoration(
                labelText: "Voornaam",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Vul je voornaam in" : null,
              ),
              const SizedBox(height: 16),

              // Achternaam
              TextFormField(
                controller: lastNameCtrl,
                decoration: const InputDecoration(
                labelText: "Achternaam",
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Vul je achternaam in" : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                labelText: "E-mail",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Vul je e-mail in";
                  if (!v.contains("@") || !v.contains(".")) {
                    return "Ongeldig e-mailadres";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Geslacht dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                labelText: "Geslacht",
                prefixIcon: Icon(Icons.wc),
                border: OutlineInputBorder(),
              ),
                value: gender,
                items: const [
                  DropdownMenuItem(value: "man", child: Text("Man")),
                  DropdownMenuItem(value: "vrouw", child: Text("Vrouw")),
                  DropdownMenuItem(value: "anders", child: Text("Anders")),
                ],
                onChanged: (v) => setState(() => gender = v ?? "man"),
              ),
              const SizedBox(height: 16),

              // Geboortedatum
              InkWell(
                onTap: pickBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Geboortedatum",
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        birthDate == null
                            ? "Selecteer datum"
                            : "${birthDate!.day}-${birthDate!.month}-${birthDate!.year}",
                      ),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Wachtwoord
              TextFormField(
                controller: passwordCtrl,
                obscureText: !passwordVisible,
                decoration: InputDecoration(
                  labelText: "Wachtwoord",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Vul een wachtwoord in";
                  if (v.length < 6) {
                    return "Wachtwoord moet minimaal 6 tekens zijn";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Herhaal wachtwoord
              TextFormField(
                controller: confirmPasswordCtrl,
                obscureText: !confirmPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Herhaal wachtwoord",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      confirmPasswordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        confirmPasswordVisible = !confirmPasswordVisible;
                      });
                    },
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return "Herhaal je wachtwoord";
                  if (v != passwordCtrl.text) {
                    return "Wachtwoorden komen niet overeen";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // Knop: Account aanmaken
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : register,
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Account aanmaken"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
