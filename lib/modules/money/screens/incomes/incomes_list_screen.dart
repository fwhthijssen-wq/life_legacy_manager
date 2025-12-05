// lib/modules/money/screens/incomes/incomes_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/app_database.dart';
import '../../../person/person_model.dart';
import '../../models/income_model.dart';
import '../../models/money_item_model.dart';
import '../../repositories/money_repository.dart';
import 'income_detail_screen.dart';

final incomesProvider = FutureProvider.family<List<IncomeWithPerson>, String>((ref, dossierId) async {
  final db = ref.read(appDatabaseProvider);
  final repo = MoneyRepository(db);
  return repo.getIncomesForDossier(dossierId);
});

class IncomesListScreen extends ConsumerStatefulWidget {
  final String dossierId;
  const IncomesListScreen({super.key, required this.dossierId});

  @override
  ConsumerState<IncomesListScreen> createState() => _IncomesListScreenState();
}

class _IncomesListScreenState extends ConsumerState<IncomesListScreen> {
  bool _showSensitiveData = false;

  @override
  Widget build(BuildContext context) {
    final incomesAsync = ref.watch(incomesProvider(widget.dossierId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inkomsten'),
        actions: [
          IconButton(
            icon: Icon(_showSensitiveData ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showSensitiveData = !_showSensitiveData),
          ),
        ],
      ),
      body: incomesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Fout: $err')),
        data: (incomes) {
          if (incomes.isEmpty) {
            return _buildEmptyState(theme);
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(incomesProvider(widget.dossierId)),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: incomes.length,
              itemBuilder: (context, index) {
                final item = incomes[index];
                return _IncomeTile(
                  item: item,
                  showSensitiveData: _showSensitiveData,
                  onTap: () => _openIncome(item),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addIncome(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Inkomen'),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
              child: const Center(child: Text('💵', style: TextStyle(fontSize: 48))),
            ),
            const SizedBox(height: 24),
            Text('Nog geen inkomsten', style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Voeg inkomstenbronnen toe', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(onPressed: () => _addIncome(context, ref), icon: const Icon(Icons.add), label: const Text('Eerste inkomen toevoegen')),
          ],
        ),
      ),
    );
  }

  void _openIncome(IncomeWithPerson item) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => IncomeDetailScreen(dossierId: widget.dossierId, incomeId: item.income.id, moneyItemId: item.moneyItem.id)))
        .then((_) => ref.invalidate(incomesProvider(widget.dossierId)));
  }

  Future<void> _addIncome(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final persons = await db.query('persons', where: 'dossier_id = ? AND (is_contact = 0 OR is_contact IS NULL)', whereArgs: [widget.dossierId]);
    if (persons.isEmpty) { if (!context.mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voeg eerst een persoon toe'), behavior: SnackBarBehavior.floating)); return; }

    PersonModel selectedPerson;
    if (persons.length == 1) { selectedPerson = PersonModel.fromMap(persons.first); }
    else { if (!context.mounted) return; final person = await showDialog<PersonModel>(context: context, builder: (context) => _SelectPersonDialog(persons: persons.map((p) => PersonModel.fromMap(p)).toList())); if (person == null) return; selectedPerson = person; }

    final uuid = const Uuid();
    final moneyItemId = uuid.v4();
    final incomeId = uuid.v4();
    final moneyItem = MoneyItemModel(id: moneyItemId, dossierId: widget.dossierId, personId: selectedPerson.id, category: MoneyCategory.income, type: 'income', status: MoneyItemStatus.notStarted, createdAt: DateTime.now());
    final income = IncomeModel(id: incomeId, moneyItemId: moneyItemId);

    final repo = MoneyRepository(db);
    await repo.createMoneyItem(moneyItem);
    await repo.createIncome(income);

    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => IncomeDetailScreen(dossierId: widget.dossierId, incomeId: incomeId, moneyItemId: moneyItemId, isNew: true)))
        .then((_) => ref.invalidate(incomesProvider(widget.dossierId)));
  }
}

class _IncomeTile extends StatelessWidget {
  final IncomeWithPerson item;
  final bool showSensitiveData;
  final VoidCallback onTap;
  const _IncomeTile({required this.item, required this.showSensitiveData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final income = item.income;
    final completeness = income.completenessPercentage;
    final progressColor = completeness >= 80 ? Colors.green : completeness >= 50 ? Colors.orange : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(income.incomeType.emoji, style: const TextStyle(fontSize: 24)))),
        title: Text(income.source?.isNotEmpty == true ? income.source! : 'Nieuw inkomen', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(income.incomeType.label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          if (income.amountNet != null) Text(showSensitiveData ? '€${income.amountNet!.toStringAsFixed(0)} netto' : '€••••', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ]),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: progressColor, borderRadius: BorderRadius.circular(12)), child: Text('$completeness%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
          const SizedBox(height: 4),
          Icon(Icons.chevron_right, color: Colors.green[700]),
        ]),
        onTap: onTap,
      ),
    );
  }
}

class _SelectPersonDialog extends StatelessWidget {
  final List<PersonModel> persons;
  const _SelectPersonDialog({required this.persons});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecteer persoon'),
      content: SizedBox(width: double.maxFinite, child: ListView.builder(shrinkWrap: true, itemCount: persons.length, itemBuilder: (context, index) {
        final person = persons[index];
        return ListTile(leading: CircleAvatar(backgroundColor: Colors.green.withOpacity(0.1), child: Text('${person.firstName[0]}${person.lastName[0]}'.toUpperCase())), title: Text(person.fullName), onTap: () => Navigator.pop(context, person));
      })),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuleren'))],
    );
  }
}





