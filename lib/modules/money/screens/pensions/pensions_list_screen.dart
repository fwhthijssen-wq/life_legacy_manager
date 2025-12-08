// lib/modules/money/screens/pensions/pensions_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/app_database.dart';
import '../../../person/person_model.dart';
import '../../models/pension_model.dart';
import '../../models/money_item_model.dart';
import '../../repositories/money_repository.dart';
import 'pension_detail_screen.dart';

/// Provider voor pensioenen van een dossier
final pensionsProvider = FutureProvider.family<List<PensionWithPerson>, String>((ref, dossierId) async {
  final db = ref.read(appDatabaseProvider);
  final repo = MoneyRepository(db);
  return repo.getPensionsForDossier(dossierId);
});

class PensionsListScreen extends ConsumerStatefulWidget {
  final String dossierId;

  const PensionsListScreen({super.key, required this.dossierId});

  @override
  ConsumerState<PensionsListScreen> createState() => _PensionsListScreenState();
}

class _PensionsListScreenState extends ConsumerState<PensionsListScreen> {
  bool _showSensitiveData = false;
  PensionType? _filterType;

  @override
  Widget build(BuildContext context) {
    final pensionsAsync = ref.watch(pensionsProvider(widget.dossierId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pensioen'),
        actions: [
          // Filter
          PopupMenuButton<PensionType?>(
            icon: Badge(
              isLabelVisible: _filterType != null,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filter op type',
            onSelected: (type) {
              setState(() => _filterType = type);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Alle pensioenen'),
              ),
              const PopupMenuDivider(),
              ...PensionType.values.map((type) => PopupMenuItem(
                value: type,
                child: Row(
                  children: [
                    Text(type.emoji),
                    const SizedBox(width: 8),
                    Text(type.label),
                    if (_filterType == type) ...[
                      const Spacer(),
                      const Icon(Icons.check, size: 18),
                    ],
                  ],
                ),
              )),
            ],
          ),
          // Toon/verberg gevoelige data
          IconButton(
            icon: Icon(_showSensitiveData ? Icons.visibility : Icons.visibility_off),
            tooltip: _showSensitiveData ? 'Verberg gevoelige data' : 'Toon gevoelige data',
            onPressed: () {
              setState(() => _showSensitiveData = !_showSensitiveData);
            },
          ),
        ],
      ),
      body: pensionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Fout: $err')),
        data: (pensions) {
          final filtered = _filterType != null
              ? pensions.where((p) => p.pension.pensionType == _filterType).toList()
              : pensions;

          if (filtered.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pensionsProvider(widget.dossierId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return _PensionTile(
                  item: item,
                  showSensitiveData: _showSensitiveData,
                  onTap: () => _openPension(item),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addPension(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Pensioen'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('👴', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _filterType != null 
                  ? 'Geen ${_filterType!.label.toLowerCase()} gevonden'
                  : 'Nog geen pensioenen',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Voeg pensioenregelingen toe voor een\ncompleet overzicht voor nabestaanden',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_filterType != null)
              TextButton(
                onPressed: () => setState(() => _filterType = null),
                child: const Text('Toon alle pensioenen'),
              )
            else
              FilledButton.icon(
                onPressed: () => _addPension(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Eerste pensioen toevoegen'),
              ),
          ],
        ),
      ),
    );
  }

  void _openPension(PensionWithPerson item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PensionDetailScreen(
          dossierId: widget.dossierId,
          pensionId: item.pension.id,
          moneyItemId: item.moneyItem.id,
        ),
      ),
    ).then((_) => ref.invalidate(pensionsProvider(widget.dossierId)));
  }

  Future<void> _addPension(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final persons = await db.rawQuery('''
      SELECT p.* FROM persons p
      INNER JOIN household_members hm ON p.id = hm.person_id
      WHERE hm.dossier_id = ?
      ORDER BY hm.is_primary DESC, p.first_name
    ''', [widget.dossierId]);

    if (persons.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voeg eerst een persoon toe aan dit dossier'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    PersonModel selectedPerson;
    if (persons.length == 1) {
      selectedPerson = PersonModel.fromMap(persons.first);
    } else {
      if (!context.mounted) return;
      final person = await showDialog<PersonModel>(
        context: context,
        builder: (context) => _SelectPersonDialog(
          persons: persons.map((p) => PersonModel.fromMap(p)).toList(),
        ),
      );
      if (person == null) return;
      selectedPerson = person;
    }

    final uuid = const Uuid();
    final moneyItemId = uuid.v4();
    final pensionId = uuid.v4();

    final moneyItem = MoneyItemModel(
      id: moneyItemId,
      dossierId: widget.dossierId,
      personId: selectedPerson.id,
      category: MoneyCategory.pension,
      type: 'pension',
      status: MoneyItemStatus.notStarted,
      createdAt: DateTime.now(),
    );

    final pension = PensionModel(
      id: pensionId,
      moneyItemId: moneyItemId,
      pensionType: PensionType.other,
    );

    final repo = MoneyRepository(db);
    await repo.createMoneyItem(moneyItem);
    await repo.createPension(pension);

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PensionDetailScreen(
          dossierId: widget.dossierId,
          pensionId: pensionId,
          moneyItemId: moneyItemId,
          isNew: true,
          personId: selectedPerson.id,
          personName: selectedPerson.fullName,
        ),
      ),
    ).then((_) => ref.invalidate(pensionsProvider(widget.dossierId)));
  }
}

class _PensionTile extends StatelessWidget {
  final PensionWithPerson item;
  final bool showSensitiveData;
  final VoidCallback onTap;

  const _PensionTile({
    required this.item,
    required this.showSensitiveData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pension = item.pension;
    final person = item.person;

    final completeness = pension.completenessPercentage;
    final progressColor = completeness >= 80
        ? Colors.green
        : completeness >= 50
            ? Colors.orange
            : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    pension.pensionType.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pension.provider?.isNotEmpty == true 
                          ? pension.provider! 
                          : 'Nieuw pensioen',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      pension.pensionType.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            person.fullName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (pension.expectedMonthlyPayout != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.euro, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            showSensitiveData
                                ? '€${pension.expectedMonthlyPayout!.toStringAsFixed(0)}/maand'
                                : '€••••/maand',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$completeness%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(Icons.chevron_right, color: Colors.purple[700]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectPersonDialog extends StatelessWidget {
  final List<PersonModel> persons;

  const _SelectPersonDialog({required this.persons});

  String _getInitials(PersonModel person) {
    final first = person.firstName.isNotEmpty ? person.firstName[0] : '';
    final last = person.lastName.isNotEmpty ? person.lastName[0] : '';
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecteer persoon'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: persons.length,
          itemBuilder: (context, index) {
            final person = persons[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple.withOpacity(0.1),
                child: Text(
                  _getInitials(person),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(person.fullName),
              subtitle: person.relation != null 
                  ? Text(person.relation!) 
                  : null,
              onTap: () => Navigator.pop(context, person),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
      ],
    );
  }
}

