// lib/modules/money/screens/expenses/expense_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_database.dart';
import '../../../../core/widgets/date_picker_field.dart';
import '../../models/expense_model.dart';
import '../../models/money_item_model.dart';
import '../../models/direct_debit_model.dart';
import '../../repositories/money_repository.dart';

class ExpenseDetailScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final String expenseId;
  final String moneyItemId;
  final bool isNew;

  const ExpenseDetailScreen({super.key, required this.dossierId, required this.expenseId, required this.moneyItemId, this.isNew = false});

  @override
  ConsumerState<ExpenseDetailScreen> createState() => _ExpenseDetailScreenState();
}

class _ExpenseDetailScreenState extends ConsumerState<ExpenseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasChanges = false;
  ExpenseModel? _expense;
  MoneyItemModel? _moneyItem;

  ExpenseType _expenseType = ExpenseType.other;
  final _creditorController = TextEditingController();
  final _amountController = TextEditingController();
  PaymentFrequency _frequency = PaymentFrequency.monthly;
  bool _isDirectDebit = true;
  final _contractNumberController = TextEditingController();
  final _contractDurationController = TextEditingController();
  final _endDateController = TextEditingController();
  final _noticePeriodController = TextEditingController();
  final _cancellationMethodController = TextEditingController();
  bool _mustBeCancelled = true;
  bool _canBeCancelled = true;
  final _priorityController = TextEditingController();
  final _survivorInstructionsController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();
  MoneyItemStatus _status = MoneyItemStatus.notStarted;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _creditorController.dispose();
    _amountController.dispose();
    _contractNumberController.dispose();
    _contractDurationController.dispose();
    _endDateController.dispose();
    _noticePeriodController.dispose();
    _cancellationMethodController.dispose();
    _priorityController.dispose();
    _survivorInstructionsController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _websiteController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = ref.read(appDatabaseProvider);
    final repo = MoneyRepository(db);
    final expense = await repo.getExpense(widget.expenseId);
    final moneyItem = await repo.getMoneyItem(widget.moneyItemId);
    if (expense != null && moneyItem != null) {
      setState(() {
        _expense = expense;
        _moneyItem = moneyItem;
        _expenseType = expense.expenseType;
        _creditorController.text = expense.creditor ?? '';
        _amountController.text = expense.amount?.toStringAsFixed(2) ?? '';
        _frequency = expense.frequency;
        _isDirectDebit = expense.isDirectDebit;
        _contractNumberController.text = expense.contractNumber ?? '';
        _contractDurationController.text = expense.contractDuration ?? '';
        _endDateController.text = expense.endDate ?? '';
        _noticePeriodController.text = expense.noticePeriod ?? '';
        _cancellationMethodController.text = expense.cancellationMethod ?? '';
        _mustBeCancelled = expense.mustBeCancelled;
        _canBeCancelled = expense.canBeCancelled;
        _priorityController.text = expense.priority ?? '';
        _survivorInstructionsController.text = expense.survivorInstructions ?? '';
        _contactPhoneController.text = expense.contactPhone ?? '';
        _contactEmailController.text = expense.contactEmail ?? '';
        _websiteController.text = expense.website ?? '';
        _notesController.text = expense.notes ?? '';
        _status = moneyItem.status;
        _isLoading = false;
      });
    } else { setState(() => _isLoading = false); }
  }

  Future<void> _save() async {
    final db = ref.read(appDatabaseProvider);
    final repo = MoneyRepository(db);
    final updated = ExpenseModel(
      id: widget.expenseId, moneyItemId: widget.moneyItemId, expenseType: _expenseType,
      creditor: _creditorController.text.isNotEmpty ? _creditorController.text : null,
      amount: double.tryParse(_amountController.text),
      frequency: _frequency, isDirectDebit: _isDirectDebit,
      contractNumber: _contractNumberController.text.isNotEmpty ? _contractNumberController.text : null,
      contractDuration: _contractDurationController.text.isNotEmpty ? _contractDurationController.text : null,
      endDate: _endDateController.text.isNotEmpty ? _endDateController.text : null,
      noticePeriod: _noticePeriodController.text.isNotEmpty ? _noticePeriodController.text : null,
      cancellationMethod: _cancellationMethodController.text.isNotEmpty ? _cancellationMethodController.text : null,
      mustBeCancelled: _mustBeCancelled, canBeCancelled: _canBeCancelled,
      priority: _priorityController.text.isNotEmpty ? _priorityController.text : null,
      survivorInstructions: _survivorInstructionsController.text.isNotEmpty ? _survivorInstructionsController.text : null,
      contactPhone: _contactPhoneController.text.isNotEmpty ? _contactPhoneController.text : null,
      contactEmail: _contactEmailController.text.isNotEmpty ? _contactEmailController.text : null,
      website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
    await repo.updateExpense(updated);
    if (_moneyItem != null) {
      final name = _creditorController.text.isNotEmpty ? '${_creditorController.text} - ${_expenseType.label}' : _expenseType.label;
      await repo.updateMoneyItem(MoneyItemModel(id: _moneyItem!.id, dossierId: _moneyItem!.dossierId, personId: _moneyItem!.personId, category: _moneyItem!.category, type: _moneyItem!.type, name: name, status: _status, createdAt: _moneyItem!.createdAt, updatedAt: DateTime.now()));
    }
    setState(() => _hasChanges = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vaste last opgeslagen'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Vaste last verwijderen?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuleren')), FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Verwijderen'))]));
    if (confirmed == true) {
      final db = ref.read(appDatabaseProvider);
      final repo = MoneyRepository(db);
      await repo.deleteExpense(widget.expenseId, widget.moneyItemId);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _markChanged() { if (!_hasChanges) setState(() => _hasChanges = true); }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return Scaffold(appBar: AppBar(title: const Text('Laden...')), body: const Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(
        title: Text(_creditorController.text.isNotEmpty ? _creditorController.text : 'Nieuwe vaste last'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save, tooltip: 'Opslaan'),
          PopupMenuButton<String>(onSelected: (a) { if (a == 'delete') _delete(); }, itemBuilder: (c) => [const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 12), Text('Verwijderen', style: TextStyle(color: Colors.red))]))]),
        ],
        bottom: TabBar(controller: _tabController, isScrollable: true, tabs: const [Tab(text: 'Basis'), Tab(text: 'Contract'), Tab(text: 'Nabestaanden'), Tab(text: 'Notities')]),
      ),
      body: TabBarView(controller: _tabController, children: [_buildBasisTab(), _buildContractTab(), _buildNabestaandenTab(), _buildNotitiesTab()]),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBasisTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DropdownButtonFormField<ExpenseType>(value: _expenseType, decoration: const InputDecoration(labelText: 'Type vaste last', prefixIcon: Icon(Icons.category)), items: ExpenseType.values.map((t) => DropdownMenuItem(value: t, child: Row(children: [Text(t.emoji), const SizedBox(width: 8), Text(t.label)]))).toList(), onChanged: (v) { if (v != null) { setState(() => _expenseType = v); _markChanged(); } }),
      const SizedBox(height: 16),
      TextField(controller: _creditorController, decoration: const InputDecoration(labelText: 'Aan wie', hintText: 'Bedrijfsnaam', prefixIcon: Icon(Icons.business)), onChanged: (_) => _markChanged()),
      const SizedBox(height: 16),
      AmountField(controller: _amountController, labelText: 'Bedrag', onChanged: _markChanged),
      const SizedBox(height: 16),
      DropdownButtonFormField<PaymentFrequency>(value: _frequency, decoration: const InputDecoration(labelText: 'Frequentie', prefixIcon: Icon(Icons.repeat)), items: PaymentFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(f.label))).toList(), onChanged: (v) { if (v != null) { setState(() => _frequency = v); _markChanged(); } }),
      const SizedBox(height: 16),
      SwitchListTile(title: const Text('Automatische incasso'), value: _isDirectDebit, onChanged: (v) { setState(() => _isDirectDebit = v); _markChanged(); }),
      const SizedBox(height: 8),
      TextField(controller: _contractNumberController, decoration: const InputDecoration(labelText: 'Contractnummer / Klantnummer', prefixIcon: Icon(Icons.tag)), onChanged: (_) => _markChanged()),
    ]));
  }

  Widget _buildContractTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(controller: _contractDurationController, decoration: const InputDecoration(labelText: 'Looptijd contract', hintText: 'Bijv. 1 jaar, onbepaald'), onChanged: (_) => _markChanged()),
      const SizedBox(height: 16),
      DatePickerField(controller: _endDateController, labelText: 'Einddatum', onChanged: _markChanged),
      const SizedBox(height: 16),
      TextField(controller: _noticePeriodController, decoration: const InputDecoration(labelText: 'Opzegtermijn', hintText: 'Bijv. 1 maand'), onChanged: (_) => _markChanged()),
      const SizedBox(height: 16),
      TextField(controller: _cancellationMethodController, decoration: const InputDecoration(labelText: 'Hoe opzeggen', hintText: 'Email, brief, telefonisch'), onChanged: (_) => _markChanged()),
      const SizedBox(height: 24),
      Text('Contactgegevens', style: Theme.of(context).textTheme.titleMedium),
      const SizedBox(height: 12),
      PhoneField(controller: _contactPhoneController, labelText: 'Telefoon', onChanged: _markChanged),
      const SizedBox(height: 12),
      EmailField(controller: _contactEmailController, labelText: 'Email', onChanged: _markChanged),
      const SizedBox(height: 12),
      WebsiteField(controller: _websiteController, labelText: 'Website', onChanged: _markChanged),
    ]));
  }

  Widget _buildNabestaandenTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(Icons.info_outline, color: Colors.red[700]), const SizedBox(width: 12), const Expanded(child: Text('Wat moeten nabestaanden doen met deze vaste last?'))])),
      const SizedBox(height: 16),
      SwitchListTile(title: const Text('Moet worden opgezegd'), value: _mustBeCancelled, onChanged: (v) { setState(() => _mustBeCancelled = v); _markChanged(); }),
      SwitchListTile(title: const Text('Kan worden opgezegd'), subtitle: const Text('Bijv. hypotheek kan niet zomaar worden opgezegd'), value: _canBeCancelled, onChanged: (v) { setState(() => _canBeCancelled = v); _markChanged(); }),
      const SizedBox(height: 16),
      DropdownButtonFormField<String>(value: _priorityController.text.isNotEmpty ? _priorityController.text : 'normaal', decoration: const InputDecoration(labelText: 'Prioriteit'), items: const [DropdownMenuItem(value: 'hoog', child: Text('Hoog - Direct actie')), DropdownMenuItem(value: 'normaal', child: Text('Normaal')), DropdownMenuItem(value: 'laag', child: Text('Laag - Kan later'))], onChanged: (v) { if (v != null) { _priorityController.text = v; _markChanged(); } }),
      const SizedBox(height: 16),
      TextField(controller: _survivorInstructionsController, decoration: const InputDecoration(labelText: 'Speciale instructies', prefixIcon: Icon(Icons.notes)), maxLines: 4, onChanged: (_) => _markChanged()),
    ]));
  }

  Widget _buildNotitiesTab() {
    return Padding(padding: const EdgeInsets.all(16), child: TextField(controller: _notesController, decoration: const InputDecoration(labelText: 'Notities', alignLabelWithHint: true, border: OutlineInputBorder()), maxLines: null, expands: true, textAlignVertical: TextAlignVertical.top, onChanged: (_) => _markChanged()));
  }

  Widget _buildBottomBar() {
    return Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2))]),
      child: Row(children: [
        Expanded(child: DropdownButtonFormField<MoneyItemStatus>(value: _status, decoration: const InputDecoration(labelText: 'Status', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)), items: MoneyItemStatus.values.map((s) => DropdownMenuItem(value: s, child: Row(children: [Icon(s == MoneyItemStatus.complete ? Icons.check_circle : s == MoneyItemStatus.partial ? Icons.pending : Icons.circle_outlined, size: 18, color: s == MoneyItemStatus.complete ? Colors.green : s == MoneyItemStatus.partial ? Colors.orange : Colors.grey), const SizedBox(width: 8), Text(s.label)]))).toList(), onChanged: (v) { if (v != null) { setState(() => _status = v); _markChanged(); } })),
        const SizedBox(width: 16),
        FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: const Text('Opslaan')),
      ]),
    );
  }
}

