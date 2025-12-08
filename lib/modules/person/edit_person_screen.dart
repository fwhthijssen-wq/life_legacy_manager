// lib/modules/person/edit_person_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/person_repository.dart';
import '../../core/utils/text_formatters.dart';
import '../../l10n/app_localizations.dart';
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
  final _initialsController = TextEditingController();  // Voorletters
  final _namePrefixController = TextEditingController();  // Tussenvoegsel
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _selectedBirthDate;
  DateTime? _selectedDeathDate;
  String? _selectedGender;
  String? _selectedRelation;
  bool _loading = true;
  PersonModel? _person;

  /// Normaliseert gender waarden naar standaard codes
  String? _normalizeGender(String? gender) {
    if (gender == null) return null;
    final lower = gender.toLowerCase();
    if (lower == 'male' || lower == 'man' || lower == 'm') return 'male';
    if (lower == 'female' || lower == 'vrouw' || lower == 'v') return 'female';
    if (lower == 'non-binary' || lower == 'non binary' || lower == 'nb') return 'non-binary';
    if (lower == 'other' || lower == 'anders' || lower == 'overig') return 'other';
    // Als het al een geldige waarde is, geef die terug
    if (['male', 'female', 'non-binary', 'other'].contains(lower)) return lower;
    return null; // Onbekende waarde -> null
  }

  @override
  void initState() {
    super.initState();
    _loadPerson();
  }

  Future<void> _loadPerson() async {
    final person = await PersonRepository.getPersonById(widget.personId);
    if (person != null && mounted) {
      setState(() {
        _person = person;
        _firstNameController.text = person.firstName;
        _initialsController.text = person.initials ?? '';
        _namePrefixController.text = person.namePrefix ?? '';
        _lastNameController.text = person.lastName;
        _phoneController.text = person.phone ?? '';
        _emailController.text = person.email ?? '';
        _addressController.text = person.address ?? '';
        _postalCodeController.text = person.postalCode ?? '';
        _cityController.text = person.city ?? '';
        _notesController.text = person.notes ?? '';
        _selectedGender = _normalizeGender(person.gender);
        _selectedRelation = person.relation;
        
        if (person.birthDate != null) {
          try {
            _selectedBirthDate = DateTime.parse(person.birthDate!);
          } catch (_) {}
        }
        
        if (person.deathDate != null) {
          try {
            _selectedDeathDate = DateTime.parse(person.deathDate!);
          } catch (_) {}
        }
        
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _initialsController.dispose();
    _namePrefixController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isBirthDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isBirthDate
          ? (_selectedBirthDate ?? DateTime(2000, 1, 1))
          : (_selectedDeathDate ?? DateTime.now()),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        if (isBirthDate) {
          _selectedBirthDate = picked;
        } else {
          _selectedDeathDate = picked;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_person == null) return;

    final updatedPerson = _person!.copyWith(
      firstName: _firstNameController.text.trim(),
      initials: _initialsController.text.trim().isEmpty
          ? null
          : _initialsController.text.trim().toUpperCase(),
      namePrefix: _namePrefixController.text.trim().isEmpty
          ? null
          : _namePrefixController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      postalCode: _postalCodeController.text.trim().isEmpty
          ? null
          : _postalCodeController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      gender: _selectedGender,
      relation: _selectedRelation,
      birthDate: _selectedBirthDate?.toIso8601String(),
      deathDate: _selectedDeathDate?.toIso8601String(),
    );

    await PersonRepository.updatePerson(updatedPerson);

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.personEdit),
        // ⭐ KEEP: Check icon in AppBar (snel opslaan)
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
            tooltip: l10n.save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Voornaam
            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: l10n.firstName,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [CapitalizeWordsFormatter()],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validationRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Voorletters
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
            const SizedBox(height: 16),

            // Tussenvoegsel
            TextFormField(
              controller: _namePrefixController,
              decoration: InputDecoration(
                labelText: '${l10n.namePrefix} (optioneel)',
                hintText: 'bijv. van, van der, de',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Achternaam
            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: l10n.lastName,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [CapitalizeWordsFormatter()],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validationRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Relatie (optioneel voor household members)
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: '${l10n.relation} (optioneel)',
                border: const OutlineInputBorder(),
                helperText: 'Voor gezinsleden wordt relatie automatisch beheerd',
              ),
              value: _selectedRelation,
              items: [
                const DropdownMenuItem(value: null, child: Text('Geen relatie')),
                DropdownMenuItem(value: 'Partner', child: Text(l10n.relationPartner)),
                DropdownMenuItem(value: 'Kind', child: Text(l10n.relationChild)),
                DropdownMenuItem(value: 'Ouder', child: Text(l10n.relationParent)),
                DropdownMenuItem(value: 'Familie', child: Text(l10n.relationFamily)),
                DropdownMenuItem(value: 'Vriend', child: Text(l10n.relationFriend)),
                const DropdownMenuItem(value: 'Notaris', child: Text('Notaris')),
                const DropdownMenuItem(value: 'Huisarts', child: Text('Huisarts')),
                const DropdownMenuItem(value: 'Leverancier', child: Text('Leverancier')),
                DropdownMenuItem(value: 'Overig', child: Text(l10n.relationOther)),
              ],
              onChanged: (value) => setState(() => _selectedRelation = value),
            ),
            const SizedBox(height: 16),

            // Telefoon
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.phone,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.email,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            // Geboortedatum
            InkWell(
              onTap: () => _selectDate(context, true),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.birthDate,
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

            // Overlijdensdatum
            InkWell(
              onTap: () => _selectDate(context, false),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '${l10n.deathDate} (optioneel)',
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _selectedDeathDate == null
                      ? 'Niet overleden'
                      : '${_selectedDeathDate!.day}-${_selectedDeathDate!.month}-${_selectedDeathDate!.year}',
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Geslacht
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: l10n.gender,
                border: const OutlineInputBorder(),
              ),
              value: _selectedGender,
              items: [
                DropdownMenuItem(value: 'male', child: Text(l10n.genderMale)),
                DropdownMenuItem(value: 'female', child: Text(l10n.genderFemale)),
                DropdownMenuItem(value: 'non-binary', child: Text(l10n.genderNonBinary)),
                DropdownMenuItem(value: 'other', child: Text(l10n.genderOther)),
              ],
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
            const SizedBox(height: 16),

            // Adres
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: l10n.address,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [CapitalizeFirstFormatter()],
            ),
            const SizedBox(height: 16),

            // Postcode
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
            const SizedBox(height: 16),

            // Stad
            TextFormField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: l10n.city,
                border: const OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              inputFormatters: [CapitalizeWordsFormatter()],
            ),
            const SizedBox(height: 16),

            // Notities
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: l10n.notes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            // ⭐ FIX: Add prominent save button (consistency with detail screen)
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check),
              label: Text(l10n.save),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
