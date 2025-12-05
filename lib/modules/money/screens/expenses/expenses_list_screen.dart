// lib/modules/money/screens/expenses/expenses_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/app_database.dart';
import '../../../person/person_model.dart';
import '../../models/expense_model.dart';
import '../../models/money_item_model.dart';
import '../../repositories/money_repository.dart';
import 'expense_detail_screen.dart';

final expensesProvider = FutureProvider.family<List<ExpenseWithPerson>, String>((ref, dossierId) async {
  final db = ref.read(appDatabaseProvider);
  final repo = MoneyRepository(db);
  return repo.getExpensesForDossier(dossierId);
});

class ExpensesListScreen extends ConsumerStatefulWidget {
  final String dossierId;
  const ExpensesListScreen({super.key, required this.dossierId});

  @override
  ConsumerState<ExpensesListScreen> createState() => _ExpensesListScreenState();
}

class _ExpensesListScreenState extends ConsumerState<ExpensesListScreen> {
  bool _showSensitiveData = false;

  @override
  Widget build(BuildContext context) {
    final expensesAsync = ref.watch(expensesProvider(widget.dossierId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vaste Lasten'),
        actions: [
          IconButton(icon: Icon(_showSensitiveData ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _showSensitiveData = !_showSensitiveData)),
        ],
      ),
      body: expensesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Fout: $err')),
        data: (expenses) {
          if (expenses.isEmpty) return _buildEmptyState(theme);
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(expensesProvider(widget.dossierId)),
            child: ListView.builder(padding: const EdgeInsets.only(bottom: 80), itemCount: expenses.length, itemBuilder: (context, index) {
              final item = expenses[index];
              return _ExpenseTile(item: item, showSensitiveData: _showSensitiveData, onTap: () => _openExpense(item));
            }),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _addExpense(context, ref), icon: const Icon(Icons.add), label: const Text('Vaste last')),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle), child: const Center(child: Text('📋', style: TextStyle(fontSize: 48)))),
      const SizedBox(height: 24),
      Text('Nog geen vaste lasten', style: theme.textTheme.titleLarge),
      const SizedBox(height: 24),
      FilledButton.icon(onPressed: () => _addExpense(context, ref), icon: const Icon(Icons.add), label: const Text('Eerste vaste last toevoegen')),
    ])));
  }

  void _openExpense(ExpenseWithPerson item) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseDetailScreen(dossierId: widget.dossierId, expenseId: item.expense.id, moneyItemId: item.moneyItem.id)))
        .then((_) => ref.invalidate(expensesProvider(widget.dossierId)));
  }

  Future<void> _addExpense(BuildContext context, WidgetRef ref) async {
    final db = ref.read(appDatabaseProvider);
    final persons = await db.query('persons', where: 'dossier_id = ? AND (is_contact = 0 OR is_contact IS NULL)', whereArgs: [widget.dossierId]);
    if (persons.isEmpty) { if (!context.mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Voeg eerst een persoon toe'), behavior: SnackBarBehavior.floating)); return; }

    PersonModel selectedPerson;
    if (persons.length == 1) { selectedPerson = PersonModel.fromMap(persons.first); }
    else { if (!context.mounted) return; final person = await showDialog<PersonModel>(context: context, builder: (context) => _SelectPersonDialog(persons: persons.map((p) => PersonModel.fromMap(p)).toList())); if (person == null) return; selectedPerson = person; }

    final uuid = const Uuid();
    final moneyItemId = uuid.v4();
    final expenseId = uuid.v4();
    final moneyItem = MoneyItemModel(id: moneyItemId, dossierId: widget.dossierId, personId: selectedPerson.id, category: MoneyCategory.expense, type: 'expense', status: MoneyItemStatus.notStarted, createdAt: DateTime.now());
    final expense = ExpenseModel(id: expenseId, moneyItemId: moneyItemId);

    final repo = MoneyRepository(db);
    await repo.createMoneyItem(moneyItem);
    await repo.createExpense(expense);

    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => ExpenseDetailScreen(dossierId: widget.dossierId, expenseId: expenseId, moneyItemId: moneyItemId, isNew: true)))
        .then((_) => ref.invalidate(expensesProvider(widget.dossierId)));
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseWithPerson item;
  final bool showSensitiveData;
  final VoidCallback onTap;
  const _ExpenseTile({required this.item, required this.showSensitiveData, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final expense = item.expense;
    final completeness = expense.completenessPercentage;
    final progressColor = completeness >= 80 ? Colors.green : completeness >= 50 ? Colors.orange : Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text(expense.expenseType.emoji, style: const TextStyle(fontSize: 24)))),
        title: Text(expense.creditor?.isNotEmpty == true ? expense.creditor! : 'Nieuwe vaste last', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(expense.expenseType.label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          if (expense.amount != null) Text(showSensitiveData ? '€${expense.amount!.toStringAsFixed(0)}' : '€••••', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: progressColor, borderRadius: BorderRadius.circular(12)), child: Text('$completeness%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11))),
          const SizedBox(width: 4),
          Icon(Icons.chevron_right, color: Colors.red[700]),
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
      return ListTile(leading: CircleAvatar(backgroundColor: Colors.red.withOpacity(0.1), child: Text('${person.firstName[0]}${person.lastName[0]}'.toUpperCase())), title: Text(person.fullName), onTap: () => Navigator.pop(context, person));
    })), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuleren'))]);
  }
}

