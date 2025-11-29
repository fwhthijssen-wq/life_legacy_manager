// lib/modules/person/select_person_screen.dart

import 'package:flutter/material.dart';
import '../../core/person_repository.dart';
import '../../l10n/app_localizations.dart';
import 'add_person_screen.dart';
import 'edit_person_screen.dart';
import 'person_detail_screen.dart';
import 'person_model.dart';

class SelectPersonScreen extends StatefulWidget {
  final String dossierId;

  const SelectPersonScreen({super.key, required this.dossierId});

  @override
  State<SelectPersonScreen> createState() => _SelectPersonScreenState();
}

class _SelectPersonScreenState extends State<SelectPersonScreen> {
  List<PersonModel> _persons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPersons();
  }

  Future<void> _loadPersons() async {
    setState(() => _loading = true);
    final persons = await PersonRepository.getPersonsForDossier(widget.dossierId);
    setState(() {
      _persons = persons;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.personManage),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _persons.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline,
                          size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        l10n.personNoPersons,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.personAddFirst,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => _addPerson(),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.personAdd),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _persons.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final person = _persons[index];
                    return _PersonCard(
                      person: person,
                      onTap: () => _viewPerson(person),
                      onEdit: () => _editPerson(person),
                      onDelete: () => _deletePerson(person),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPerson,
        icon: const Icon(Icons.add),
        label: Text(l10n.personAdd),
      ),
    );
  }

  Future<void> _addPerson() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddPersonScreen(dossierId: widget.dossierId),
      ),
    );
    if (result == true) _loadPersons();
  }

  Future<void> _viewPerson(PersonModel person) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PersonDetailScreen(personId: person.id),
      ),
    );
  }

  Future<void> _editPerson(PersonModel person) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditPersonScreen(personId: person.id),
      ),
    );
    if (result == true) _loadPersons();
  }

  Future<void> _deletePerson(PersonModel person) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.personDeleteTitle),
        content: Text(
          // ✅ AANGEPAST: Gebruik string interpolation in plaats van replaceAll
          'Weet u zeker dat u ${person.fullName} wilt verwijderen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PersonRepository.deletePerson(person.id);
      _loadPersons();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.personDeleted)),
        );
      }
    }
  }
}

class _PersonCard extends StatelessWidget {
  final PersonModel person;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PersonCard({
    required this.person,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            person.firstName.isNotEmpty ? person.firstName[0].toUpperCase() : '?',
          ),
        ),
        title: Text(person.fullName),
        subtitle: Text(person.relation ?? l10n.personRelationOther),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
