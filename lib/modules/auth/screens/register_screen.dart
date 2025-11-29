// lib/modules/auth/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_routes.dart';
import '../../../l10n/app_localizations.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _namePrefixController = TextEditingController();  // ← NIEUW
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _namePrefixController.dispose();  // ← NIEUW
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: l10n.registerSelectDate,
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.registerSelectBirthDate),
        ),
      );
      return;
    }

    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecteer een geslacht')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = await ref.read(authRepositoryProvider).register(
        firstName: _firstNameController.text.trim(),
        namePrefix: _namePrefixController.text.trim().isEmpty  // ← NIEUW
            ? null 
            : _namePrefixController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        birthDate: _selectedDate!,
        gender: _selectedGender!,
      );

      if (userId != null && mounted) {
        // Registratie gelukt
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.registerSuccess),
          ),
        );

        // Ga naar PIN setup
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.setupPin,
          arguments: userId,
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.registerFailed),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Voornaam
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: l10n.firstName,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'Voornaam moet minimaal 2 tekens bevatten';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tussenvoegsel - ← NIEUW
            TextFormField(
              controller: _namePrefixController,
              decoration: InputDecoration(
                labelText: '${l10n.namePrefix} (optioneel)',
                hintText: 'bijv. van, van der, de',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.text_fields),
              ),
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: 16),

            // Achternaam
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: l10n.lastName,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.person_outline),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().length < 2) {
                  return 'Achternaam moet minimaal 2 tekens bevatten';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.email,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              textCapitalization: TextCapitalization.none,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validationRequired;
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return l10n.validationEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Wachtwoord
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: l10n.password,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.length < 6) {
                  return l10n.validationPasswordLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Bevestig wachtwoord
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: l10n.confirmPassword,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword);
                  },
                ),
              ),
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value != _passwordController.text) {
                  return l10n.validationPasswordMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Geboortedatum
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.birthDate,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
                child: Text(
                  _selectedDate == null
                      ? l10n.registerSelectDate
                      : '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}',
                  style: TextStyle(
                    color: _selectedDate == null ? Colors.grey : null,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Geslacht
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.gender,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.wc),
              ),
              value: _selectedGender,
              items: [
                DropdownMenuItem(
                  value: l10n.genderMale,
                  child: Text(l10n.genderMale),
                ),
                DropdownMenuItem(
                  value: l10n.genderFemale,
                  child: Text(l10n.genderFemale),
                ),
                DropdownMenuItem(
                  value: l10n.genderNonBinary,
                  child: Text(l10n.genderNonBinary),
                ),
                DropdownMenuItem(
                  value: l10n.genderOther,
                  child: Text(l10n.genderOther),
                ),
              ],
              onChanged: (value) {
                setState(() => _selectedGender = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Selecteer een geslacht';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Registreer knop
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(l10n.registerButton),
              ),
            ),
            const SizedBox(height: 16),

            // Login link
            TextButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: Text(l10n.loginTitle),
            ),
          ],
        ),
      ),
    );
  }
}