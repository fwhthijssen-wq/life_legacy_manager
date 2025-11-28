// lib/modules/person/select_person_screen.dart

import 'package:flutter/material.dart';

import '../../core/person_repository.dart';
import '../../core/app_routes.dart';
import 'person_model.dart';

class SelectPersonScreen extends StatefulWidget {
  const SelectPersonScreen({super.key});

  @override
  State<SelectPersonScreen> createState() => _SelectPersonScreenState();
}

class _SelectPersonScreenState extends State<SelectPersonScreen> {
  late Future<List<PersonModel>> _futurePersons;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortKey = 'nameAsc';

  @override
  void initState() {
    super.initState();
    _reloadPersons();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadPersons() {
    setState(() {
      _futurePersons = PersonRepository.getAllPersons();
    });
  }

  Future<void> _openAddPerson() async {
    final changed = await Navigator.pushNamed(context, AppRoutes.addPerson);
    if (changed == true) {
      _reloadPersons();
    }
  }

  Future<void> _openDetail(PersonModel person) async {
    final changed = await Navigator.pushNamed(
      context,
      AppRoutes.personDetail,
      arguments: person.id,
    );
    if (changed == true) {
      _reloadPersons();
    }
  }

  String _initialsFor(PersonModel p) {
    final first = p.firstName.isNotEmpty ? p.firstName[0] : '';
    final last = p.lastName.isNotEmpty ? p.lastName[0] : '';
    final combined = (first + last).toUpperCase();
    if (combined.trim().isEmpty) return '?';
    return combined;
  }

  int _completionPercentage(PersonModel p) {
    // Velden die meetellen voor 'compleetheid'
    final fields = <String?>[
      p.phone,
      p.email,
      p.birthDate,
      p.address,
      p.postalCode,
      p.city,
      p.gender,
      p.notes,
      p.relation,
      // p.deathDate telt bewust NIET mee
    ];
    if (fields.isEmpty) return 0;
    final filled =
        fields.where((v) => v != null && v!.trim().isNotEmpty).length;
    return ((filled / fields.length) * 100).round();
  }

  Color _completionColor(int percent) {
    if (percent >= 70) {
      return Colors.green;
    } else if (percent >= 30) {
      return Colors.amber;
    } else {
      return Colors.redAccent;
    }
  }

  List<PersonModel> _filterAndSortPersons(List<PersonModel> persons) {
    final query = _searchQuery.trim().toLowerCase();

    var filtered = persons.where((p) {
      if (query.isEmpty) return true;
      final name = ('${p.firstName} ${p.lastName}').toLowerCase();
      final phone = (p.phone ?? '').toLowerCase();
      final email = (p.email ?? '').toLowerCase();
      return name.contains(query) ||
          phone.contains(query) ||
          email.contains(query);
    }).toList();

    int compareByName(PersonModel a, PersonModel b) {
      final ln = a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
      if (ln != 0) return ln;
      return a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
    }

    DateTime? parseDate(String? value) {
      if (value == null || value.trim().isEmpty) return null;
      final datePart = value.split(' ').first.split('T').first;
      try {
        return DateTime.parse(datePart);
      } catch (_) {
        return null;
      }
    }

    switch (_sortKey) {
      case 'nameDesc':
        filtered.sort((a, b) => compareByName(b, a));
        break;
      case 'birthAsc':
        filtered.sort((a, b) {
          final da = parseDate(a.birthDate);
          final db = parseDate(b.birthDate);
          if (da == null && db == null) return compareByName(a, b);
          if (da == null) return 1;
          if (db == null) return -1;
          final cmp = da.compareTo(db);
          return cmp != 0 ? cmp : compareByName(a, b);
        });
        break;
      case 'birthDesc':
        filtered.sort((a, b) {
          final da = parseDate(a.birthDate);
          final db = parseDate(b.birthDate);
          if (da == null && db == null) return compareByName(a, b);
          if (da == null) return 1;
          if (db == null) return -1;
          final cmp = db.compareTo(da);
          return cmp != 0 ? cmp : compareByName(a, b);
        });
        break;
      case 'nameAsc':
      default:
        filtered.sort(compareByName);
        break;
    }

    return filtered;
  }

  Widget _buildPersonCard(PersonModel p) {
    final subtitleParts = <String>[];
    if (p.relation != null && p.relation!.trim().isNotEmpty) {
      subtitleParts.add(p.relation!.trim());
    }
    if (p.city != null && p.city!.trim().isNotEmpty) {
      subtitleParts.add(p.city!.trim());
    }

    final percent = _completionPercentage(p);
    final color = _completionColor(percent);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _openDetail(p),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    child: Text(
                      _initialsFor(p),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${p.firstName} ${p.lastName}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (subtitleParts.isNotEmpty)
                          Text(
                            subtitleParts.join(" • "),
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "$percent%",
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Compleet",
                        style: TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: percent / 100.0,
                  minHeight: 4,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Personen"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddPerson,
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: "Zoeken",
                hintText: "Zoek op naam, telefoon of e-mail",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Sorteren",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                DropdownButton<String>(
                  value: _sortKey,
                  items: const [
                    DropdownMenuItem(
                      value: 'nameAsc',
                      child: Text("Naam A → Z"),
                    ),
                    DropdownMenuItem(
                      value: 'nameDesc',
                      child: Text("Naam Z → A"),
                    ),
                    DropdownMenuItem(
                      value: 'birthAsc',
                      child: Text("Leeftijd oplopend"),
                    ),
                    DropdownMenuItem(
                      value: 'birthDesc',
                      child: Text("Leeftijd aflopend"),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _sortKey = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: FutureBuilder<List<PersonModel>>(
                future: _futurePersons,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final persons =
                      _filterAndSortPersons(snapshot.data ?? []);

                  if (persons.isEmpty) {
                    return const Center(
                      child: Text("Nog geen personen toegevoegd."),
                    );
                  }

                  return ListView.builder(
                    itemCount: persons.length,
                    itemBuilder: (context, index) {
                      final p = persons[index];
                      return _buildPersonCard(p);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
