// lib/modules/money/screens/insurances/insurances_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/app_database.dart';
import '../../../person/person_model.dart';
import '../../models/insurance_model.dart';
import '../../models/money_item_model.dart';
import '../../repositories/money_repository.dart';
import 'insurance_detail_screen.dart';

/// Provider voor verzekeringen van een dossier
final insurancesProvider = FutureProvider.family<List<InsuranceWithPerson>, String>((ref, dossierId) async {
  final db = ref.read(appDatabaseProvider);
  final repo = MoneyRepository(db);
  return repo.getInsurancesForDossier(dossierId);
});

class InsurancesListScreen extends ConsumerStatefulWidget {
  final String dossierId;

  const InsurancesListScreen({super.key, required this.dossierId});

  @override
  ConsumerState<InsurancesListScreen> createState() => _InsurancesListScreenState();
}

class _InsurancesListScreenState extends ConsumerState<InsurancesListScreen> {
  bool _showSensitiveData = false;
  InsuranceType? _filterType;

  @override
  Widget build(BuildContext context) {
    final insurancesAsync = ref.watch(insurancesProvider(widget.dossierId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verzekeringen'),
        actions: [
          // Filter
          PopupMenuButton<InsuranceType?>(
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
                child: Text('Alle verzekeringen'),
              ),
              const PopupMenuDivider(),
              ...InsuranceType.values.map((type) => PopupMenuItem(
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
      body: insurancesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Fout: $err')),
        data: (insurances) {
          // Filter op type indien geselecteerd
          final filtered = _filterType != null
              ? insurances.where((i) => i.insurance.insuranceType == _filterType).toList()
              : insurances;

          if (filtered.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(insurancesProvider(widget.dossierId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final item = filtered[index];
                return _InsuranceTile(
                  item: item,
                  showSensitiveData: _showSensitiveData,
                  onTap: () => _openInsurance(item),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addInsurance(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Verzekering'),
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
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('🛡️', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _filterType != null 
                  ? 'Geen ${_filterType!.label.toLowerCase()} gevonden'
                  : 'Nog geen verzekeringen',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Voeg verzekeringen toe om een overzicht\nte hebben voor jezelf en nabestaanden',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (_filterType != null)
              TextButton(
                onPressed: () => setState(() => _filterType = null),
                child: const Text('Toon alle verzekeringen'),
              )
            else
              FilledButton.icon(
                onPressed: () => _addInsurance(context, ref),
                icon: const Icon(Icons.add),
                label: const Text('Eerste verzekering toevoegen'),
              ),
          ],
        ),
      ),
    );
  }

  void _openInsurance(InsuranceWithPerson item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InsuranceDetailScreen(
          dossierId: widget.dossierId,
          insuranceId: item.insurance.id,
          moneyItemId: item.moneyItem.id,
        ),
      ),
    ).then((_) => ref.invalidate(insurancesProvider(widget.dossierId)));
  }

  Future<void> _addInsurance(BuildContext context, WidgetRef ref) async {
    // Haal personen op voor dit dossier
    final db = ref.read(appDatabaseProvider);
    final persons = await db.query(
      'persons',
      where: 'dossier_id = ? AND (is_contact = 0 OR is_contact IS NULL)',
      whereArgs: [widget.dossierId],
    );

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

    // Als er maar 1 persoon is, direct die gebruiken
    PersonModel selectedPerson;
    if (persons.length == 1) {
      selectedPerson = PersonModel.fromMap(persons.first);
    } else {
      // Laat gebruiker kiezen
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

    // Maak nieuwe verzekering aan
    final uuid = const Uuid();
    final moneyItemId = uuid.v4();
    final insuranceId = uuid.v4();

    final moneyItem = MoneyItemModel(
      id: moneyItemId,
      dossierId: widget.dossierId,
      personId: selectedPerson.id,
      category: MoneyCategory.insurance,
      type: 'insurance',
      status: MoneyItemStatus.notStarted,
      createdAt: DateTime.now(),
    );

    final insurance = InsuranceModel(
      id: insuranceId,
      moneyItemId: moneyItemId,
      company: '',
      insuranceType: InsuranceType.other,
    );

    // Opslaan
    final repo = MoneyRepository(db);
    await repo.createMoneyItem(moneyItem);
    await repo.createInsurance(insurance);

    // Open detail scherm
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InsuranceDetailScreen(
          dossierId: widget.dossierId,
          insuranceId: insuranceId,
          moneyItemId: moneyItemId,
          isNew: true,
          personId: selectedPerson.id,
          personName: selectedPerson.fullName, // Auto-fill verzekerde naam
        ),
      ),
    ).then((_) => ref.invalidate(insurancesProvider(widget.dossierId)));
  }
}

/// Tile voor een verzekering in de lijst
class _InsuranceTile extends StatelessWidget {
  final InsuranceWithPerson item;
  final bool showSensitiveData;
  final VoidCallback onTap;

  const _InsuranceTile({
    required this.item,
    required this.showSensitiveData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final insurance = item.insurance;
    final person = item.person;
    final theme = Theme.of(context);

    final completeness = insurance.completenessPercentage;
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
              // Type emoji
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    insurance.insuranceType.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Verzekeraar + type
                    Text(
                      insurance.company.isNotEmpty 
                          ? insurance.company 
                          : 'Nieuwe verzekering',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      insurance.insuranceType.label,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Polisnummer + persoon
                    Row(
                      children: [
                        if (insurance.policyNumber?.isNotEmpty == true) ...[
                          Icon(Icons.tag, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            showSensitiveData
                                ? insurance.policyNumber!
                                : _maskPolicyNumber(insurance.policyNumber!),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                          ),
                          const SizedBox(width: 12),
                        ],
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
                    // Premie
                    if (insurance.premium != null && insurance.premium! > 0) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.euro, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            showSensitiveData
                                ? '€${insurance.premium!.toStringAsFixed(2)} ${insurance.paymentFrequency.label.toLowerCase()}'
                                : '€••••',
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

              // Progress + chevron
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
                  Icon(Icons.chevron_right, color: Colors.orange[700]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _maskPolicyNumber(String policyNumber) {
    if (policyNumber.length <= 4) return '••••';
    return '••••${policyNumber.substring(policyNumber.length - 4)}';
  }
}

/// Dialog om persoon te selecteren
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
                backgroundColor: Colors.orange.withOpacity(0.1),
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

