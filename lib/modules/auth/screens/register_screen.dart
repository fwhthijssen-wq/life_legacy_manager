import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_legacy_manager/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';
import '../../../core/app_database.dart';
import '../repository/auth_repository.dart';
import '../services/recovery_phrase_service.dart';
import '../../dossier/dossier_model.dart';
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
  DossierType _selectedDossierType = DossierType.family;
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
    // Voorkom dubbele aanroep
    if (_isRegistering) {
      print('⚠️ Registratie al bezig, skip dubbele aanroep');
      return;
    }
    
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
    
    print('🚀 START REGISTRATIE');

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
      
      print('✅ Dossier created, checking mounted state...');
      if (!mounted) {
        print('⚠️ Widget unmounted after dossier creation!');
        return;
      }
      print('✅ Still mounted, continuing...');

      // Generate recovery phrase (based on app language)
      print('📝 Generating recovery phrase...');
      final locale = Localizations.localeOf(context).languageCode;
      print('📝 Locale: $locale');
      final language = locale == 'nl' 
          ? RecoveryPhraseLanguage.dutch 
          : RecoveryPhraseLanguage.english;
      
      final recoveryPhrase = RecoveryPhraseService.generatePhrase(
        language: language,
      );
      print('✅ Recovery phrase generated: ${recoveryPhrase.length} words');

      if (!mounted) {
        print('⚠️ Widget not mounted, aborting navigation');
        return;
      }

      // Navigate to recovery phrase setup
      print('🔄 Navigating to SetupRecoveryPhraseScreen...');
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
      print('❌ REGISTRATIE FOUT: $e');
      print('❌ Stack trace: ${StackTrace.current}');
      
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
    final locale = Localizations.localeOf(context);
    
    // Bepaal dossiernaam op basis van type
    final lastName = _lastNameController.text.trim();
    String dossierName;
    String? dossierDescription;
    
    switch (_selectedDossierType) {
      case DossierType.family:
        dossierName = locale.languageCode == 'nl' 
            ? 'Familie $lastName' 
            : 'Family $lastName';
        dossierDescription = locale.languageCode == 'nl'
            ? 'Gezinsdossier'
            : 'Family dossier';
        break;
      case DossierType.couple:
        dossierName = locale.languageCode == 'nl'
            ? 'Huishouden $lastName'
            : 'Household $lastName';
        dossierDescription = locale.languageCode == 'nl'
            ? 'Echtpaar/samenwonend'
            : 'Couple';
        break;
      case DossierType.single:
        final firstName = _firstNameController.text.trim();
        dossierName = '$firstName $lastName';
        dossierDescription = locale.languageCode == 'nl'
            ? 'Persoonlijk dossier'
            : 'Personal dossier';
        break;
      case DossierType.other:
        dossierName = locale.languageCode == 'nl' 
            ? 'Mijn Dossier' 
            : 'My Dossier';
        dossierDescription = null;
        break;
    }
    
    // Create dossier
    final dossierId = const Uuid().v4();
    await db.insert('dossiers', {
      'id': dossierId,
      'user_id': userId,
      'name': dossierName,
      'description': dossierDescription,
      'icon': _selectedDossierType.defaultIcon,
      'color': 'teal',
      'type': _selectedDossierType.name,
      'is_active': 1,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    
    print('✅ Dossier created: $dossierId');
    
    // Create person entry with registration data
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
      // created_at bestaat niet in persons tabel
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
                const SizedBox(height: 24),

                // Dossier Type Selection
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.home, color: theme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Uw leefsituatie',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Dit bepaalt hoe uw standaard dossier wordt aangemaakt.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: DossierType.values.map((type) {
                          final isSelected = _selectedDossierType == type;
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(type.emoji),
                                const SizedBox(width: 6),
                                Text(type.displayName),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedDossierType = type;
                                });
                              }
                            },
                            selectedColor: theme.primaryColor.withOpacity(0.2),
                            checkmarkColor: theme.primaryColor,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
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
                  onFieldSubmitted: (_) {
                    if (!_isRegistering) _handleRegister();
                  },
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
