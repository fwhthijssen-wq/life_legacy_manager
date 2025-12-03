// lib/modules/contacts/screens/add_contact_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/app_database.dart';
import '../../person/person_model.dart';

class AddContactScreen extends ConsumerStatefulWidget {
  final String dossierId;

  const AddContactScreen({super.key, required this.dossierId});

  @override
  ConsumerState<AddContactScreen> createState() => _AddContactScreenState();
}

class _AddContactScreenState extends ConsumerState<AddContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _namePrefixController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _notesController = TextEditingController();

  final Set<ContactCategory> _selectedCategories = {};
  bool _isSaving = false;

  @override
  void dispose() {
    _firstNameController.dispose();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact toevoegen'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Naam sectie
            Text(
              'Naam',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Voornaam *',
                prefixIcon: Icon(Icons.person),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Voornaam is verplicht';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: _namePrefixController,
                    decoration: const InputDecoration(
                      labelText: 'Tussen',
                      hintText: 'van, de',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Achternaam *',
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Achternaam is verplicht';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Categorieën sectie (meerdere selecteerbaar)
            Text(
              'Categorieën',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Selecteer één of meerdere categorieën',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ContactCategory.values.map((category) {
                final isSelected = _selectedCategories.contains(category);
                return FilterChip(
                  avatar: Text(category.emoji, style: const TextStyle(fontSize: 16)),
                  label: Text(category.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategories.add(category);
                      } else {
                        _selectedCategories.remove(category);
                      }
                    });
                  },
                  selectedColor: theme.primaryColor.withOpacity(0.2),
                  checkmarkColor: theme.primaryColor,
                );
              }).toList(),
            ),
            
            const SizedBox(height: 24),
            
            // Contactgegevens sectie
            Text(
              'Contactgegevens',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Telefoonnummer',
                prefixIcon: Icon(Icons.phone),
                hintText: '06-12345678',
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'E-mailadres',
                prefixIcon: Icon(Icons.email),
                hintText: 'naam@voorbeeld.nl',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 24),
            
            // Adres sectie (optioneel, inklapbaar)
            ExpansionTile(
              title: Text(
                'Adres (optioneel)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Straat en huisnummer',
                          prefixIcon: Icon(Icons.home),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              controller: _postalCodeController,
                              decoration: const InputDecoration(
                                labelText: 'Postcode',
                              ),
                              textCapitalization: TextCapitalization.characters,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              decoration: const InputDecoration(
                                labelText: 'Plaats',
                              ),
                              textCapitalization: TextCapitalization.words,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notities
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notities',
                prefixIcon: Icon(Icons.note),
                hintText: 'Extra informatie over dit contact...',
              ),
              maxLines: 3,
            ),
            
            const SizedBox(height: 32),
            
            // Opslaan knop
            FilledButton.icon(
              onPressed: _isSaving ? null : _saveContact,
              icon: _isSaving 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Opslaan...' : 'Contact opslaan'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final db = ref.read(appDatabaseProvider);
      
      final person = PersonModel(
        id: const Uuid().v4(),
        dossierId: widget.dossierId,
        firstName: _firstNameController.text.trim(),
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
        isContact: true,
        categories: _selectedCategories,
      );

      await db.insert('persons', person.toMap());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${person.fullName} toegevoegd als contact'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fout bij opslaan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
