// lib/modules/person/add_person_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';
import '../../core/person_repository.dart';
import '../../core/utils/text_formatters.dart';
import '../../l10n/app_localizations.dart';
import 'person_model.dart';

class AddPersonScreen extends StatefulWidget {
  final String dossierId;  // ← NIEUW: Verplicht dossierId

  const AddPersonScreen({super.key, required this.dossierId});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _initialsController = TextEditingController();  // Voorletters
  final _namePrefixController = TextEditingController();  // Tussenvoegsel
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedGender;
  String? _selectedRelation;

  @override
  void dispose() {
    _firstNameController.dispose();
    _initialsController.dispose();
    _namePrefixController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthDateController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialDate: DateTime.now(),
    );
    if (picked != null) {
      _birthDateController.text = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final newPerson = PersonModel(
      id: const Uuid().v4(),
      dossierId: widget.dossierId,
      firstName: _firstNameController.text.trim(),
      initials: _initialsController.text.trim().isEmpty
          ? null
          : _initialsController.text.trim().toUpperCase(),
      namePrefix: _namePrefixController.text.trim().isEmpty
          ? null
          : _namePrefixController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      birthDate: _birthDateController.text.trim().isEmpty ? null : _birthDateController.text.trim(),
      address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
      postalCode: _postalCodeController.text.trim().isEmpty ? null : _postalCodeController.text.trim(),
      city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
      gender: _selectedGender,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      relation: _selectedRelation,
    );

    await PersonRepository.addPerson(newPerson);
    
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.personAdd),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: l10n.firstName,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [CapitalizeWordsFormatter()],
              validator: (v) => v == null || v.trim().isEmpty ? l10n.validationRequired : null,
            ),
            const SizedBox(height: 12),
            
            // Voorletters veld
            TextFormField(
              controller: _initialsController,
              decoration: const InputDecoration(
                labelText: 'Voorletters (optioneel)',
                hintText: 'bijv. J.P. of A.B.C.',
                helperText: 'Voor officiële documenten',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
            ),
            const SizedBox(height: 12),
            
            // Tussenvoegsel veld
            TextFormField(
              controller: _namePrefixController,
              decoration: InputDecoration(
                labelText: '${l10n.namePrefix} (optioneel)',
                hintText: 'bijv. van, van der, de',
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.none,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: l10n.lastName,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [CapitalizeWordsFormatter()],
              validator: (v) => v == null || v.trim().isEmpty ? l10n.validationRequired : null,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.personRelationToUser,
                border: const OutlineInputBorder(),
              ),
              value: _selectedRelation,
              items: [
                l10n.personRelationSelf,
                l10n.personRelationPartner,
                l10n.personRelationChild,
                l10n.personRelationParent,
                l10n.personRelationFamily,
                l10n.personRelationFriend,
                l10n.personRelationOther,
              ].map((rel) => DropdownMenuItem(value: rel, child: Text(rel))).toList(),
              onChanged: (value) => setState(() => _selectedRelation = value),
              validator: (v) => v == null ? l10n.personChooseRelation : null,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.phone,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.email,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _birthDateController,
              decoration: InputDecoration(
                labelText: l10n.birthDate,
                hintText: l10n.personSelectDate,
                border: const OutlineInputBorder(),
                suffixIcon: const Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _pickDate,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: l10n.address,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [CapitalizeFirstFormatter()],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _postalCodeController,
              decoration: InputDecoration(
                labelText: l10n.postalCode,
                hintText: '1234 AB',
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                DutchPostalCodeFormatter(),
                LengthLimitingTextInputFormatter(7),
              ],
              validator: validateDutchPostalCode,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: l10n.city,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [CapitalizeWordsFormatter()],
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.gender,
                border: const OutlineInputBorder(),
              ),
              value: _selectedGender,
              items: [
                l10n.genderMale,
                l10n.genderFemale,
                l10n.genderNonBinary,
                l10n.genderOther,
              ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.personNotes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _save,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
