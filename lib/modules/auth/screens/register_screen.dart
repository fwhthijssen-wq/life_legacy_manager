import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_legacy_manager/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    
    if (!_formKey.currentState!.validate()) return;

    if (birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.registerSelectBirthDate)),
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
        SnackBar(content: Text(l10n.registerFailed)),
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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Voornaam
              TextFormField(
                controller: firstNameCtrl,
                decoration: InputDecoration(labelText: l10n.firstName),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Vul ${l10n.firstName.toLowerCase()} in";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Achternaam
              TextFormField(
                controller: lastNameCtrl,
                decoration: InputDecoration(labelText: l10n.lastName),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Vul ${l10n.lastName.toLowerCase()} in";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: emailCtrl,
                decoration: InputDecoration(labelText: l10n.email),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Vul ${l10n.email.toLowerCase()} in";
                  }
                  if (!v.contains("@") || !v.contains(".")) {
                    return l10n.validationEmail;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Geslacht dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: l10n.gender),
                value: gender,
                items: [
                  DropdownMenuItem(value: "man", child: Text(l10n.genderMale)),
                  DropdownMenuItem(value: "vrouw", child: Text(l10n.genderFemale)),
                  DropdownMenuItem(value: "anders", child: Text(l10n.genderOther)),
                ],
                onChanged: (v) => setState(() => gender = v ?? "man"),
              ),
              const SizedBox(height: 16),

              // Geboortedatum
              InkWell(
                onTap: pickBirthDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.birthDate,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        birthDate == null
                            ? l10n.registerSelectDate
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
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.password),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Vul ${l10n.password.toLowerCase()} in";
                  }
                  if (v.length < 6) {
                    return l10n.validationPasswordLength;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Herhaal wachtwoord
              TextFormField(
                controller: confirmPasswordCtrl,
                obscureText: true,
                decoration: InputDecoration(labelText: l10n.confirmPassword),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Vul ${l10n.confirmPassword.toLowerCase()} in";
                  }
                  if (v != passwordCtrl.text) {
                    return l10n.validationPasswordMatch;
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
                      : Text(l10n.registerButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}