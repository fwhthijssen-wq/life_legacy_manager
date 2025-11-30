import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_legacy_manager/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../../core/app_database.dart';
import '../repository/auth_repository.dart';
import '../services/recovery_phrase_service.dart';
import 'setup_recovery_phrase_screen.dart';
import 'verify_recovery_phrase_screen.dart';
import 'setup_pin_screen.dart';

/// Register Screen
/// Allows new users to create an account
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _namePrefixController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  DateTime? _selectedBirthDate;
  String? _selectedGender;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegistering = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _namePrefixController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.registerSelectBirthDate),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isRegistering = true;
    });

    try {
      final authRepository = AuthRepository();

      // Register user
      final userId = await authRepository.registerUser(
        firstName: _firstNameController.text.trim(),
        namePrefix: _namePrefixController.text.trim().isNotEmpty 
            ? _namePrefixController.text.trim() 
            : null,
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        gender: _selectedGender,
        birthDate: _selectedBirthDate?.millisecondsSinceEpoch,
      );

      if (userId == null) {
        throw Exception('Registration failed');
      }

      // Create default dossier
      await _createDefaultDossier(userId);

      // Generate recovery phrase (based on app language)
      final locale = Localizations.localeOf(context).languageCode;
      final language = locale == 'nl' 
          ? RecoveryPhraseLanguage.dutch 
          : RecoveryPhraseLanguage.english;
      
      final recoveryPhrase = RecoveryPhraseService.generatePhrase(
        language: language,
      );

      if (!mounted) return;

      // Navigate to recovery phrase setup
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => SetupRecoveryPhraseScreen(
            recoveryPhrase: recoveryPhrase,
            onConfirmed: () {
              // Navigate to verification
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => VerifyRecoveryPhraseScreen(
                    recoveryPhrase: recoveryPhrase,
                    onVerified: () async {
                      // Save recovery phrase hash
                      await authRepository.saveRecoveryPhrase(
                        userId,
                        recoveryPhrase,
                      );
                      
                      // Continue to PIN setup
                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => SetupPinScreen(userId: userId),
                        ),
                      );
                    },
                    onBack: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isRegistering = false;
      });

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${AppLocalizations.of(context)!.registerFailed}: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createDefaultDossier(String userId) async {
    final db = await AppDatabase.instance.database;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    
    await db.insert('dossiers', {
      'id': const Uuid().v4(),
      'user_id': userId,
      'name': locale.languageCode == 'nl' ? 'Mijn Dossier' : 'My Dossier',
      'description': null,
      'icon': 'folder',
      'color': 'teal',
      'is_active': 1,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _selectBirthDate() async {
    final l10n = AppLocalizations.of(context)!;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: l10n.registerSelectDate,
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.registerTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Welcome Icon
                Icon(
                  Icons.person_add_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: l10n.firstName,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationRequired;
                    }
                    if (value.trim().length < 2) {
                      return 'Minimaal 2 tekens vereist';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Name Prefix (Tussenvoegsel)
                TextFormField(
                  controller: _namePrefixController,
                  decoration: InputDecoration(
                    labelText: l10n.namePrefix,
                    hintText: 'van, van der, de, etc.',
                    prefixIcon: const Icon(Icons.text_fields),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Last Name
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(
                    labelText: l10n.lastName,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationRequired;
                    }
                    if (value.trim().length < 2) {
                      return 'Minimaal 2 tekens vereist';
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
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
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

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.validationRequired;
                    }
                    if (value.length < 6) {
                      return l10n.validationPasswordLength;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.validationRequired;
                    }
                    if (value != _passwordController.text) {
                      return l10n.validationPasswordMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Gender Selection
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: InputDecoration(
                    labelText: l10n.gender,
                    prefixIcon: const Icon(Icons.wc),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'male',
                      child: Text(l10n.genderMale),
                    ),
                    DropdownMenuItem(
                      value: 'female',
                      child: Text(l10n.genderFemale),
                    ),
                    DropdownMenuItem(
                      value: 'other',
                      child: Text(l10n.genderOther),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Birth Date
                InkWell(
                  onTap: _selectBirthDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.birthDate,
                      prefixIcon: const Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _selectedBirthDate != null
                          ? '${_selectedBirthDate!.day}-${_selectedBirthDate!.month}-${_selectedBirthDate!.year}'
                          : l10n.personSelectDate,
                      style: TextStyle(
                        color: _selectedBirthDate != null
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Register Button
                FilledButton(
                  onPressed: _isRegistering ? null : _handleRegister,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isRegistering
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.registerButton),
                ),
                const SizedBox(height: 16),

                // Back to Login
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.back),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
