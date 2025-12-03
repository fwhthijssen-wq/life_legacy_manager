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
  DateTime? _lastRegisterAttempt; // Debounce voor dubbele clicks

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
    // Debounce: voorkom clicks binnen 2 seconden van elkaar
    final now = DateTime.now();
    if (_lastRegisterAttempt != null && 
        now.difference(_lastRegisterAttempt!).inSeconds < 2) {
      print('⚠️ Debounce: te snel na vorige poging');
      return;
    }
    _lastRegisterAttempt = now;
    
    // Voorkom dubbele registratie
    if (_isRegistering) {
      print('⚠️ Registratie al bezig, skip dubbele aanroep');
      return;
    }
    _isRegistering = true; // Direct zetten voor synchrone lock
    print('🟢 Starting registration...');
    
    if (!_formKey.currentState!.validate()) {
      _isRegistering = false;
      return;
    }

    if (_selectedBirthDate == null) {
      _isRegistering = false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.registerSelectBirthDate),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Update UI om loading state te tonen
    setState(() {});

    bool userCreated = false; // Track of user al is aangemaakt
    
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
      
      userCreated = true; // User is aangemaakt - NIET meer resetten!
      print('✅ User created, userCreated=$userCreated');

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
                      print('🎯 onVerified called!');
                      
                      try {
                        // Save recovery phrase hash
                        print('💾 Saving recovery phrase...');
                        await authRepository.saveRecoveryPhrase(
                          userId,
                          recoveryPhrase,
                        );
                        print('✅ Recovery phrase saved!');
                        
                        // Continue to PIN setup
                        print('🔄 Navigating to PIN setup...');
                        
                        // Use pushReplacement directly without mounted check
                        // The callback is called synchronously from the verify screen
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => SetupPinScreen(userId: userId),
                          ),
                        );
                        print('✅ Navigation initiated!');
                      } catch (e) {
                        print('❌ Error in onVerified: $e');
                      }
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
      print('❌ Registration error: $e (userCreated=$userCreated)');
      
      // ALLEEN resetten als de USER nog niet is aangemaakt
      // Als user WEL is aangemaakt, NIET resetten - voorkomt dubbele registratie
      if (!userCreated && mounted) {
        setState(() {
          _isRegistering = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.registerFailed}: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (userCreated) {
        print('⚠️ Error na user creation - NIET resetten om dubbele registratie te voorkomen');
      }
    }
  }

  Future<void> _createDefaultDossier(String userId) async {
    final db = await AppDatabase.instance.database;
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context);
    
    // Create dossier
    final dossierId = const Uuid().v4();
    await db.insert('dossiers', {
      'id': dossierId,
      'user_id': userId,
      'name': locale.languageCode == 'nl' ? 'Mijn Dossier' : 'My Dossier',
      'description': null,
      'icon': 'folder',
      'color': 'teal',
      'is_active': 1,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    
    print('✅ Dossier created: $dossierId');
    
    // Create person entry for the account holder
    final personId = const Uuid().v4();
    await db.insert('persons', {
      'id': personId,
      'dossier_id': dossierId,
      'first_name': _firstNameController.text.trim(),
      'name_prefix': _namePrefixController.text.trim().isNotEmpty 
          ? _namePrefixController.text.trim() 
          : null,
      'last_name': _lastNameController.text.trim(),
      'email': _emailController.text.trim(),
      'gender': _selectedGender,
      'birth_date': _selectedBirthDate?.toIso8601String().substring(0, 10),
      'relation': null,
      'phone': null,
      'address': null,
      'postal_code': null,
      'city': null,
      'notes': null,
      'death_date': null,
      'is_contact': 0, // Accounthouder is geen extern contact
      'contact_categories': null,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    
    print('✅ Person created with email: $personId');
    
    // Add as household member (primary)
    await db.insert('household_members', {
      'id': const Uuid().v4(),
      'dossier_id': dossierId,
      'person_id': personId,
      'relation': 'accounthouder',
      'is_primary': 1,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    
    print('✅ Accounthouder added to household');
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
                  Icons.person_add,
                  size: 80,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                
                Text(
                  l10n.registerWelcome,
                  style: theme.textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                
                Text(
                  l10n.registerSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // First Name
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(
                    labelText: l10n.firstName,
                    prefixIcon: const Icon(Icons.person),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationRequired;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Name Prefix
                TextFormField(
                  controller: _namePrefixController,
                  decoration: InputDecoration(
                    labelText: '${l10n.namePrefix} (${l10n.optional})',
                    hintText: l10n.namePrefixHint,
                    prefixIcon: const Icon(Icons.text_fields),
                    border: const OutlineInputBorder(),
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
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationRequired;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: l10n.email,
                    prefixIcon: const Icon(Icons.email),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.validationRequired;
                    }
                    if (!value.contains('@')) {
                      return l10n.validationEmail;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Birth Date
                InkWell(
                  onTap: _selectBirthDate,
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: l10n.birthDate,
                      prefixIcon: const Icon(Icons.cake),
                      border: const OutlineInputBorder(),
                    ),
                    child: Text(
                      _selectedBirthDate == null
                          ? l10n.registerSelectDate
                          : '${_selectedBirthDate!.day}-${_selectedBirthDate!.month}-${_selectedBirthDate!.year}',
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Gender
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.gender,
                    prefixIcon: const Icon(Icons.wc),
                    border: const OutlineInputBorder(),
                  ),
                  value: _selectedGender,
                  items: [
                    DropdownMenuItem(value: 'male', child: Text(l10n.genderMale)),
                    DropdownMenuItem(value: 'female', child: Text(l10n.genderFemale)),
                    DropdownMenuItem(value: 'non-binary', child: Text(l10n.genderNonBinary)),
                    DropdownMenuItem(value: 'other', child: Text(l10n.genderOther)),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: l10n.password,
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.validationRequired;
                    }
                    if (value.length < 6) {
                      return l10n.validationPasswordLength;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: l10n.confirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.validationRequired;
                    }
                    if (value != _passwordController.text) {
                      return l10n.validationPasswordMatch;
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                  // onFieldSubmitted verwijderd om dubbele registratie te voorkomen
                  // Gebruiker moet op de knop klikken
                ),
                const SizedBox(height: 32),

                // Register Button
                ElevatedButton(
                  onPressed: _isRegistering ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
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
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.registerBackToLogin),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
