// lib/modules/household/screens/add_household_member_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/app_database.dart';
import '../models/household_member.dart';
import '../repository/household_repository.dart';

class AddHouseholdMemberScreen extends ConsumerStatefulWidget {
  final String dossierId;

  const AddHouseholdMemberScreen({super.key, required this.dossierId});

  @override
  ConsumerState<AddHouseholdMemberScreen> createState() =>
      _AddHouseholdMemberScreenState();
}

class _AddHouseholdMemberScreenState
    extends ConsumerState<AddHouseholdMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = HouseholdRepository();

  // Form controllers
  final _firstNameController = TextEditingController();
  final _namePrefixController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // State
  List<Map<String, dynamic>> _existingPersons = [];
  String? _selectedPersonId;
  HouseholdRelation _selectedRelation = HouseholdRelation.partner;
  DateTime? _selectedBirthDate;
  String? _selectedGender;
  bool _isNewPerson = true;
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadExistingPersons();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _namePrefixController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingPersons() async {
    final db = await AppDatabase.instance.database;

    // Get all persons that are NOT already in this household
    final allPersons = await db.query('persons',
        where: 'dossier_id = ?', whereArgs: [widget.dossierId]);

    final householdPersonIds = await db.rawQuery('''
      SELECT person_id FROM household_members WHERE dossier_id = ?
    ''', [widget.dossierId]);

    final existingIds =
        householdPersonIds.map((e) => e['person_id'] as String).toSet();

    setState(() {
      _existingPersons =
          allPersons.where((p) => !existingIds.contains(p['id'])).toList();
      _loading = false;
    });
  }

  String _getFullName(Map<String, dynamic> person) {
    final firstName = person['first_name'] as String;
    final namePrefix = person['name_prefix'] as String?;
    final lastName = person['last_name'] as String;

    if (namePrefix != null && namePrefix.isNotEmpty) {
      return '$firstName $namePrefix $lastName';
    }
    return '$firstName $lastName';
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Selecteer geboortedatum',
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (_saving) return;

    // Validate
    if (_isNewPerson) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    } else {
      if (_selectedPersonId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecteer een persoon'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() {
      _saving = true;
    });

    try {
      final db = await AppDatabase.instance.database;
      String personId;

      if (_isNewPerson) {
        // Create new person
        personId = const Uuid().v4();
        await db.insert('persons', {
          'id': personId,
          'dossier_id': widget.dossierId,
          'first_name': _firstNameController.text.trim(),
          'name_prefix': _namePrefixController.text.trim().isNotEmpty
              ? _namePrefixController.text.trim()
              : null,
          'last_name': _lastNameController.text.trim(),
          'email': _emailController.text.trim().isNotEmpty
              ? _emailController.text.trim()
              : null,
          'phone': _phoneController.text.trim().isNotEmpty
              ? _phoneController.text.trim()
              : null,
          'gender': _selectedGender,
          'birth_date': _selectedBirthDate?.toIso8601String().substring(0, 10),
          'relation': null,
        });
      } else {
        personId = _selectedPersonId!;
      }

      // Add to household
      await _repository.addHouseholdMember(
        dossierId: widget.dossierId,
        personId: personId,
        relation: _selectedRelation,
        isPrimary: false,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gezinslid toegevoegd!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() {
        _saving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fout: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gezinslid toevoegen'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Toggle: New or Existing person
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kies een optie',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _OptionButton(
                                  icon: Icons.person_add,
                                  label: 'Nieuwe persoon',
                                  isSelected: _isNewPerson,
                                  onTap: () =>
                                      setState(() => _isNewPerson = true),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _OptionButton(
                                  icon: Icons.person_search,
                                  label: 'Bestaande persoon',
                                  isSelected: !_isNewPerson,
                                  onTap: _existingPersons.isEmpty
                                      ? null
                                      : () =>
                                          setState(() => _isNewPerson = false),
                                  disabled: _existingPersons.isEmpty,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Relation selector
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Relatie',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: HouseholdRelation.values
                                .where(
                                    (r) => r != HouseholdRelation.accountHolder)
                                .map((relation) {
                              final isSelected =
                                  _selectedRelation == relation;
                              return ChoiceChip(
                                label: Text(relation.getDisplayName()),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(
                                        () => _selectedRelation = relation);
                                  }
                                },
                                avatar: Text(_getRelationEmoji(relation)),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Person form or selector
                  if (_isNewPerson)
                    _buildNewPersonForm(theme)
                  else
                    _buildExistingPersonSelector(theme),

                  const SizedBox(height: 24),

                  // Save button
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check),
                    label: Text(_saving ? 'Bezig...' : 'Toevoegen'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildNewPersonForm(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gegevens',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // First name
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(
                  labelText: 'Voornaam *',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Voornaam is verplicht';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Name prefix
              TextFormField(
                controller: _namePrefixController,
                decoration: const InputDecoration(
                  labelText: 'Tussenvoegsel',
                  hintText: 'bijv. van, de, van de',
                  prefixIcon: Icon(Icons.text_fields),
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Last name
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Achternaam *',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Achternaam is verplicht';
                  }
                  return null;
                },
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Birth date
              InkWell(
                onTap: _selectBirthDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Geboortedatum',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _selectedBirthDate == null
                        ? 'Klik om te selecteren'
                        : '${_selectedBirthDate!.day}-${_selectedBirthDate!.month}-${_selectedBirthDate!.year}',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Gender
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Geslacht',
                  prefixIcon: Icon(Icons.wc),
                  border: OutlineInputBorder(),
                ),
                value: _selectedGender,
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('Man')),
                  DropdownMenuItem(value: 'female', child: Text('Vrouw')),
                  DropdownMenuItem(value: 'non-binary', child: Text('Non-binair')),
                  DropdownMenuItem(value: 'other', child: Text('Anders')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'E-mailadres',
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefoonnummer',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExistingPersonSelector(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecteer persoon',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_existingPersons.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Geen beschikbare personen',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              )
            else
              ...(_existingPersons.map((person) {
                final isSelected = _selectedPersonId == person['id'];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isSelected ? theme.primaryColor : Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  title: Text(_getFullName(person)),
                  subtitle: person['email'] != null
                      ? Text(person['email'] as String)
                      : null,
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: theme.primaryColor)
                      : null,
                  selected: isSelected,
                  onTap: () {
                    setState(() {
                      _selectedPersonId = person['id'] as String;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isSelected
                          ? theme.primaryColor
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                );
              })).toList(),
          ],
        ),
      ),
    );
  }

  String _getRelationEmoji(HouseholdRelation relation) {
    switch (relation) {
      case HouseholdRelation.accountHolder:
        return '👤';
      case HouseholdRelation.partner:
        return '💑';
      case HouseholdRelation.child:
        return '👶';
      case HouseholdRelation.parent:
        return '👨‍👩';
      case HouseholdRelation.sibling:
        return '👫';
      case HouseholdRelation.other:
        return '👥';
    }
  }
}

class _OptionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool disabled;

  const _OptionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: disabled ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.1)
              : disabled
                  ? Colors.grey[100]
                  : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : disabled
                    ? Colors.grey[300]!
                    : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected
                  ? theme.primaryColor
                  : disabled
                      ? Colors.grey[400]
                      : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? theme.primaryColor
                    : disabled
                        ? Colors.grey[400]
                        : Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}







