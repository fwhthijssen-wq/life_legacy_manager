// lib/modules/person/edit_person_screen.dart

import 'package:flutter/material.dart';
import 'package:life_legacy_manager/l10n/app_localizations.dart';

import '../../core/person_repository.dart';
import 'person_model.dart';

class EditPersonScreen extends StatefulWidget {
  final String personId;

  const EditPersonScreen({super.key, required this.personId});

  @override
  State<EditPersonScreen> createState() => _EditPersonScreenState();
}

class _EditPersonScreenState extends State<EditPersonScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();
  final _deathDateController = TextEditingController();

  String? _selectedGender;
  String? _selectedRelation;

  bool _loading = true;
  PersonModel? _person;

  @override
  void initState() {
    super.initState();
    _loadPerson();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    _deathDateController.dispose();
    super.dispose();
  }

  Future<void> _loadPerson() async {
    print('🔵 Loading person: ${widget.personId}');
    final p = await PersonRepository.getPersonById(widget.personId);
    
    setState(() {
      _person = p;
      _loading = false;
    });

    if (p != null) {
      print('✅ Person loaded: ${p.firstName} ${p.lastName}');
      _firstNameController.text = p.firstName;
      _lastNameController.text = p.lastName;
      _phoneController.text = p.phone ?? '';
      _emailController.text = p.email ?? '';
      _birthDateController.text = _formatDateString(p.birthDate);
      _addressController.text = p.address ?? '';
      _postalCodeController.text = p.postalCode ?? '';
      _cityController.text = p.city ?? '';
      _notesController.text = p.notes ?? '';
      _deathDateController.text = _formatDateString(p.deathDate);
      _selectedGender = p.gender;
      _selectedRelation = p.relation;
    } else {
      print('❌ Person not found');
    }
  }

  String _formatDateString(String? value) {
    if (value == null) return '';
    final trimmed = value.trim();
    if (trimmed.isEmpty) return '';
    final datePart = trimmed.split(' ').first.split('T').first;
    try {
      final d = DateTime.parse(datePart);
      return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return datePart;
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    DateTime initialDate = now;

    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(controller.text);
      } catch (_) {}
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: initialDate,
    );

    if (picked != null) {
      final formatted =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        controller.text = formatted;
      });
    }
  }

  String? _validateName(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Vul $fieldName in.';
    }
    if (value.trim().length < 2) {
      return '$fieldName moet minimaal 2 tekens bevatten.';
    }
    return null;
  }

  String? _validatePhone(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return null;
    final cleaned = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.length < 8) {
      return l10n.personPhoneShort;
    }
    if (!RegExp(r'^[0-9+]{8,}$').hasMatch(cleaned)) {
      return l10n.personPhoneInvalid;
    }
    return null;
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return l10n.validationEmail;
    }
    return null;
  }

  String? _validatePostalCode(String? value, AppLocalizations l10n) {
    if (value == null || value.trim().isEmpty) return null;
    final pc = value.replaceAll(' ', '').toUpperCase();
    if (!RegExp(r'^[0-9]{4}[A-Z]{2}$').hasMatch(pc)) {
      return l10n.personPostalInvalid;
    }
    return null;
  }

  Future<void> _save() async {
    print('🔵 Save START');
    print('🔵 Form validation check...');
    
    // Check each field manually
    print('  - First name: ${_firstNameController.text}');
    print('  - Last name: ${_lastNameController.text}');
    print('  - Relation: $_selectedRelation');
    print('  - Phone: ${_phoneController.text}');
    print('  - Email: ${_emailController.text}');
    
    if (!_formKey.currentState!.validate()) {
      print('❌ Validation failed - checking which field...');
      
      // Manually validate each to find the culprit
      final firstName = _validateName(_firstNameController.text, "voornaam");
      final lastName = _validateName(_lastNameController.text, "achternaam");
      
      if (firstName != null) print('  ❌ First name validation: $firstName');
      if (lastName != null) print('  ❌ Last name validation: $lastName');
      if (_selectedRelation == null || _selectedRelation!.isEmpty) {
        print('  ❌ Relation validation failed: value is null or empty');
      }
      
      return;
    }
    
    if (_person == null) {
      print('❌ Person is null');
      return;
    }

    print('🔵 Creating updated person...');
    final updated = _person!.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      birthDate: _birthDateController.text.trim().isEmpty ? null : _birthDateController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      postalCode: _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim().toUpperCase(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      gender: _selectedGender,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      relation: _selectedRelation,
      deathDate: _deathDateController.text.trim().isEmpty ? null : _deathDateController.text.trim(),
    );

    print('🔵 Updated person: ${updated.firstName} ${updated.lastName}');
    print('🔵 Gender: ${updated.gender}, Relation: ${updated.relation}');
    print('🔵 Saving to database...');
    
    try {
      await PersonRepository.updatePerson(updated);
      print('✅ Save SUCCESS');
      
      if (mounted) {
        print('🔵 Navigating back...');
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      print('❌ Save ERROR: $e');
      print('❌ StackTrace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final genderOptions = [
      l10n.genderMale,
      l10n.genderFemale,
      l10n.genderNonBinary,
      l10n.genderOther,
      l10n.genderUnknown,
    ];

    // TEMP: Hardcoded om te matchen met database values
    // Later: gebruik keys in database en toon vertalingen in UI
    final relationOptions = [
      'Ikzelf',
      'Partner',
      'Kind',
      'Ouder',
      'Familie',
      'Vriend(in)',
      'Overig',
    ];

    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_person == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.personEdit)),
        body: Center(
          child: Text(l10n.personNotFound),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.personEdit),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: l10n.firstName,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => _validateName(value, l10n.firstName.toLowerCase()),
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: l10n.lastName,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => _validateName(value, l10n.lastName.toLowerCase()),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.personRelationToUser,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                value: _selectedRelation,
                items: relationOptions
                    .map((rel) => DropdownMenuItem(value: rel, child: Text(rel)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRelation = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.personChooseRelation;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phone,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) => _validatePhone(value, l10n),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => _validateEmail(value, l10n),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.birthDate,
                  hintText: l10n.personSelectDate,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _pickDate(_birthDateController),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: l10n.address,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _postalCodeController,
                decoration: InputDecoration(
                  labelText: l10n.postalCode,
                  hintText: "1234 AB",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_post_office),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: (value) => _validatePostalCode(value, l10n),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: l10n.city,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: l10n.gender,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.wc),
                ),
                value: _selectedGender,
                items: genderOptions
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _deathDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: l10n.personDeathDate,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _pickDate(_deathDateController),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: l10n.personNotes,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save),
                  label: Text(l10n.personSaveChanges),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}