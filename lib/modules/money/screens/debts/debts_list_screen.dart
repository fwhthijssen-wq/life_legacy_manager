// lib/modules/money/screens/debts/debts_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/app_database.dart';
import '../../../person/person_model.dart';
import '../../models/debt_model.dart';
import '../../models/money_item_model.dart';
import '../../repositories/money_repository.dart';
import 'debt_detail_screen.dart';

final debtsProvider = FutureProvider.family<List<DebtWithPerson>, String>((ref, dossierId) async {
  final db = ref.read(appDatabaseProvider);
  final repo = MoneyRepository(db);
  return repo.getDebtsForDossier(dossierId);
});

class DebtsListScreen extends ConsumerStatefulWidget {
  final String dossierId;
  const DebtsListScreen({super.key, required this.dossierId});

  @override
  ConsumerState<DebtsListScreen> createState() => _DebtsListScreenState();
}

class _DebtsListScreenState extends ConsumerState<DebtsListScreen> {
  bool _showSensitiveData = false;

  @override
  Widget build(BuildContext context) {
    final debtsAsync = ref.watch(debtsProvider(widget.dossierId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schulden & Leningen'),
        actions: [
          IconButton(icon: Icon(_showSensitiveData ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _showSensitiveData = !_showSensitiveData)),
        ],
      ),
      body: debtsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Fout: $err')),
        data: (debts) {
          if (debts.isEmpty) return _buildEmptyState(theme);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(debtsProvider(widget.dossierId)),
            child: ListView.builder(padding: const EdgeInsets.only(bottom: 80), itemCount: debts.length, itemBuilder: (context, index) {
              final item = debts[index];
              return _DebtTile(item: item, showSensitiveData: _showSensitiveData, onTap: () => _openDebt(item));
            }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _addDebt(context, ref), icon: const Icon(Icons.add), label: const Text('Schuld/Lening')),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.brown.withOpacity(0.1), shape: BoxShape.circle), child: const Center(child: Text('💳', style: TextStyle(fontSize: 48)))),
      const SizedBox(height: 24),
      Text('Geen schulden of leningen', style: theme.textTheme.titleLarge),
      const SizedBox(height: 12),
      Text('Voeg hypotheek, leningen of andere\nschulden toe voor een compleet overzicht', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]), textAlign: TextAlign.center),
      const SizedBox(height: 24),
      FilledButton.icon(onPressed: () => _addDebt(context, ref), icon: const Icon(Icons.add), label: const Text('Eerste schuld/lening toevoegen')),
    ])));
  }

  void _openDebt(DebtWithPerson item) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => DebtDetailScreen(dossierId: widget.dossierId, debtId: item.debt.id, moneyItemId: item.moneyItem.id)))
        .then((_) => ref.invalidate(debtsProvider(widget.dossierId)));
  }

  Future<void> _addDebt(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final persons = await db.query('persons', where: 'dossier_id = ? AND (is_contact = 0 OR is_contact IS NULL)', whereArgs: [widget.dossierId]);
    if (persons.isEmpty) { if (!context.mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voeg eerst een persoon toe'), behavior: SnackBarBehavior.floating)); return; }

    PersonModel selectedPerson;
    if (persons.length == 1) { selectedPerson = PersonModel.fromMap(persons.first); }
    else { if (!context.mounted) return; final person = await showDialog<PersonModel>(context: context, builder: (context) => _SelectPersonDialog(persons: persons.map((p) => PersonModel.fromMap(p)).toList())); if (person == null) return; selectedPerson = person; }

    final uuid = const Uuid();
    final moneyItemId = uuid.v4();
    final debtId = uuid.v4();
    final moneyItem = MoneyItemModel(id: moneyItemId, dossierId: widget.dossierId, personId: selectedPerson.id, category: MoneyCategory.debt, type: 'debt', status: MoneyItemStatus.notStarted, createdAt: DateTime.now());
    final debt = DebtModel(id: debtId, moneyItemId: moneyItemId);

    final repo = MoneyRepository(db);
    await repo.createMoneyItem(moneyItem);
    await repo.createDebt(debt);

    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => DebtDetailScreen(dossierId: widget.dossierId, debtId: debtId, moneyItemId: moneyItemId, isNew: true)))
        .then((_) => ref.invalidate(debtsProvider(widget.dossierId)));
  }
}

class _DebtTile extends StatelessWidget {
  final DebtWithPerson item;
  final bool showSensitiveData;
  final VoidCallback onTap;
  const _DebtTile({required this.item, required this.showSensitiveData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final debt = item.debt;
    final completeness = debt.completenessPercentage;
    final progressColor = completeness >= 80 ? Colors.green : completeness >= 50 ? Colors.orange : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.brown.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(debt.debtType.emoji, style: const TextStyle(fontSize: 24)))),
        title: Text(debt.creditor?.isNotEmpty == true ? debt.creditor! : 'Nieuwe schuld/lening', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(debt.debtType.label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          if (debt.currentBalance != null) Text(showSensitiveData ? '€${debt.currentBalance!.toStringAsFixed(0)} openstaand' : '€••••', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ]),
        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: progressColor, borderRadius: BorderRadius.circular(12)), child: Text('$completeness%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
          const SizedBox(height: 4),
          Icon(Icons.chevron_right, color: Colors.brown[700]),
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
    return AlertDialog(title: const Text('Selecteer persoon'), content: SizedBox(width: double.maxFinite, child: ListView.builder(shrinkWrap: true, itemCount: persons.length, itemBuilder: (context, index) {
      final person = persons[index];
      return ListTile(leading: CircleAvatar(backgroundColor: Colors.brown.withOpacity(0.1), child: Text('${person.firstName[0]}${person.lastName[0]}'.toUpperCase())), title: Text(person.fullName), onTap: () => Navigator.pop(context, person));
    })), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuleren'))]);
  }
}





