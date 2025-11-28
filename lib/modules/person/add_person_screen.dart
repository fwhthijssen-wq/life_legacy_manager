// lib/modules/person/add_person_screen.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/person_repository.dart';
import 'person_model.dart';

class AddPersonScreen extends StatefulWidget {
  const AddPersonScreen({super.key});

  @override
  State<AddPersonScreen> createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
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

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1900),
      lastDate: now,
      initialDate: now,
    );

    if (picked != null) {
      final formatted =
          '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        controller.text = formatted;
      });
    }
  }


  String? _validateName(String? value, String veldNaam) {
    if (value == null || value.trim().isEmpty) {
      return 'Vul $veldNaam in.';
    }
    if (value.trim().length < 2) {
      return '$veldNaam moet minimaal 2 tekens bevatten.';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final cleaned = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.length < 8) {
      return 'Telefoonnummer lijkt te kort.';
    }
    if (!RegExp(r'^[0-9+]{8,}$').hasMatch(cleaned)) {
      return 'Ongeldig telefoonnummer.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ongeldig e-mailadres.';
    }
    return null;
  }

  String? _validatePostalCode(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    // NL stijl: 1234 AB (spatie optioneel)
    final pc = value.replaceAll(' ', '').toUpperCase();
    if (!RegExp(r'^[0-9]{4}[A-Z]{2}$').hasMatch(pc)) {
      return 'Postcode moet zijn als 1234 AB.';
    }
    return null;
  }

  Future<void> _savePerson() async {
    if (!_formKey.currentState!.validate()) return;

    final id = const Uuid().v4();

    final person = PersonModel(
      id: id,
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

    await PersonRepository.addPerson(person);

    if (mounted) {
      Navigator.pop(context, true); // true => lijst verversen
    }
  }

  @override
  Widget build(BuildContext context) {
    final genderOptions = [
      'Man',
      'Vrouw',
      'Non-binair',
      'Anders',
      'Onbekend',
    ];

    final relationOptions = [
      'Ikzelf',
      'Partner',
      'Kind',
      'Ouder',
      'Familie',
      'Vriend(in)',
      'Overig',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Persoon toevoegen"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: "Voornaam",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => _validateName(value, "voornaam"),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: "Achternaam",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) => _validateName(value, "achternaam"),
              ),
              const SizedBox(height: 12),

              // Relatie dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Relatie tot gebruiker",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.group),
                ),
                value: _selectedRelation,
                items: relationOptions
                    .map((rel) =>
                        DropdownMenuItem(value: rel, child: Text(rel)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRelation = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Kies een relatie";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Telefoonnummer",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "E-mailadres",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 12),

              // Geboortedatum met date picker
              TextFormField(
                controller: _birthDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Geboortedatum",
                  hintText: "Klik om datum te kiezen",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.cake),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                onTap: () => _pickDate(_birthDateController),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Adres",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: "Postcode",
                  hintText: "1234 AB",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.local_post_office),
                ),
                textCapitalization: TextCapitalization.characters,
                validator: _validatePostalCode,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: "Plaats",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_city),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: "Geslacht",
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

              // Overlijdensdatum (optioneel)
              TextFormField(
                controller: _deathDateController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: "Overlijdensdatum (optioneel)",
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
                decoration: const InputDecoration(
                  labelText: "Opmerkingen / notities",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _savePerson,
                  icon: const Icon(Icons.save),
                  label: const Text("Opslaan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
