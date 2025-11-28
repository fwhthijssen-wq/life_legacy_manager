// lib/modules/person/person_detail_screen.dart

import 'package:flutter/material.dart';

import '../../core/person_repository.dart';
import '../../core/app_routes.dart';
import 'person_model.dart';

class PersonDetailScreen extends StatefulWidget {
  final String personId;

  const PersonDetailScreen({super.key, required this.personId});

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  late Future<PersonModel?> _futurePerson;
  bool _hasChanged = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _futurePerson = PersonRepository.getPersonById(widget.personId);
  }

  Future<void> _deletePerson(PersonModel person) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Persoon verwijderen"),
        content: Text(
          "Weet je zeker dat je ${person.firstName} ${person.lastName} wilt verwijderen?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Annuleren"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Verwijderen"),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await PersonRepository.deletePerson(person.id);

    if (mounted) {
      Navigator.pop(context, true); // true => lijst verversen
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

  Future<void> _editPerson(PersonModel person) async {
    final changed = await Navigator.pushNamed(
      context,
      AppRoutes.editPerson,
      arguments: person.id,
    );

    if (changed == true && mounted) {
      _hasChanged = true;
      setState(() {
        _reload();
      });
    }
  }

  IconData? _iconForLabel(String label) {
    switch (label) {
      case "Telefoonnummer":
        return Icons.phone;
      case "E-mail":
        return Icons.email;
      case "Adres":
        return Icons.home;
      case "Postcode":
        return Icons.local_post_office;
      case "Plaats":
        return Icons.location_city;
      case "Geboortedatum":
        return Icons.cake;
      case "Overlijdensdatum":
        return Icons.event;
      case "Geslacht":
        return Icons.wc;
      case "Relatie":
        return Icons.group;
      case "Opmerkingen":
      case "Notities":
        return Icons.notes;
      default:
        return null;
    }
  }

  Widget _buildRow(String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    String display = value;
    if (label == "Geboortedatum" || label == "Overlijdensdatum") {
      display = _formatDateString(value);
    }

    final iconData = _iconForLabel(label);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (iconData != null) ...[
            Icon(iconData, size: 18),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$label: ",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Flexible(
                  child: Text(display),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _hasChanged);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Persoonsdetails"),
        ),
        body: FutureBuilder<PersonModel?>(
        future: _futurePerson,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text("Persoon niet gevonden."),
            );
          }

          final person = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${person.firstName} ${person.lastName}",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                _buildRow("Relatie", person.relation),
                _buildRow("Telefoon", person.phone),
                _buildRow("E-mail", person.email),
                _buildRow("Geboortedatum", person.birthDate),
                _buildRow("Adres", person.address),
                _buildRow("Postcode", person.postalCode),
                _buildRow("Plaats", person.city),
                _buildRow("Geslacht", person.gender),
                _buildRow("Overlijdensdatum", person.deathDate),
                _buildRow("Opmerkingen", person.notes),

                const Spacer(),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _editPerson(person),
                        icon: const Icon(Icons.edit),
                        label: const Text("Wijzigen"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _deletePerson(person),
                        icon: const Icon(Icons.delete),
                        label: const Text("Verwijderen"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  flu);
}
