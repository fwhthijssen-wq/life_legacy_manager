// lib/modules/contacts/screens/edit_contact_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_database.dart';
import '../../person/person_model.dart';

class EditContactScreen extends ConsumerStatefulWidget {
  final String contactId;

  const EditContactScreen({super.key, required this.contactId});

  @override
  ConsumerState<EditContactScreen> createState() => _EditContactScreenState();
}

class _EditContactScreenState extends ConsumerState<EditContactScreen> {
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
  bool _loading = true;
  bool _isSaving = false;
  PersonModel? _contact;

  @override
  void initState() {
    super.initState();
    _loadContact();
  }

  Future<void> _loadContact() async {
    final db = ref.read(appDatabaseProvider);
    final results = await db.query(
      'persons',
      where: 'id = ?',
      whereArgs: [widget.contactId],
    );
    
    if (results.isNotEmpty && mounted) {
      final contact = PersonModel.fromMap(results.first);
      setState(() {
        _contact = contact;
        _firstNameController.text = contact.firstName;
        _namePrefixController.text = contact.namePrefix ?? '';
        _lastNameController.text = contact.lastName;
        _phoneController.text = contact.phone ?? '';
        _emailController.text = contact.email ?? '';
        _addressController.text = contact.address ?? '';
        _postalCodeController.text = contact.postalCode ?? '';
        _cityController.text = contact.city ?? '';
        _notesController.text = contact.notes ?? '';
        _selectedCategories.clear();
        _selectedCategories.addAll(contact.categories);
        _loading = false;
      });
    }
  }

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

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;
    if (_contact == null) return;

    setState(() => _isSaving = true);

    try {
      final db = ref.read(appDatabaseProvider);
      
      final updatedContact = _contact!.copyWith(
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
        categories: _selectedCategories,
      );

      await db.update(
        'persons',
        updatedContact.toMap(),
        where: 'id = ?',
        whereArgs: [widget.contactId],
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${updatedContact.fullName} bijgewerkt'),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact bewerken'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isSaving ? null : _saveContact,
            tooltip: 'Opslaan',
          ),
        ],
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
                border: OutlineInputBorder(),
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
                  width: 120,
                  child: TextFormField(
                    controller: _namePrefixController,
                    decoration: const InputDecoration(
                      labelText: 'Tussen',
                      hintText: 'van, de',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Achternaam *',
                      border: OutlineInputBorder(),
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
                border: OutlineInputBorder(),
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
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 24),
            
            // Adres sectie
            Text(
              'Adres',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Straat en huisnummer',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
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
                      border: OutlineInputBorder(),
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
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Notities
            Text(
              'Notities',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notities',
                hintText: 'Extra informatie over dit contact...',
                border: OutlineInputBorder(),
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
              label: Text(_isSaving ? 'Opslaan...' : 'Wijzigingen opslaan'),
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
}
