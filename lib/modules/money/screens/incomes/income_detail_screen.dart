// lib/modules/money/screens/incomes/income_detail_screen.dart

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_database.dart';
import '../../../../core/ocr/document_scanner_widget.dart';
import '../../../../core/widgets/date_picker_field.dart';
import '../../models/income_model.dart';
import '../../models/money_item_model.dart';
import '../../models/direct_debit_model.dart';
import '../../repositories/money_repository.dart';

class IncomeDetailScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final String incomeId;
  final String moneyItemId;
  final bool isNew;

  const IncomeDetailScreen({super.key, required this.dossierId, required this.incomeId, required this.moneyItemId, this.isNew = false});

  @override
  ConsumerState<IncomeDetailScreen> createState() => _IncomeDetailScreenState();
}

class _IncomeDetailScreenState extends ConsumerState<IncomeDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasChanges = false;
  IncomeModel? _income;
  MoneyItemModel? _moneyItem;

  IncomeType _incomeType = IncomeType.other;
  final _sourceController = TextEditingController();
  final _amountGrossController = TextEditingController();
  final _amountNetController = TextEditingController();
  PaymentFrequency _frequency = PaymentFrequency.monthly;
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  bool _stopsOnDeath = true;
  bool _needsCancellation = true;
  final _cancellationContactController = TextEditingController();
  final _cancellationPhoneController = TextEditingController();
  final _cancellationEmailController = TextEditingController();
  final _survivorInstructionsController = TextEditingController();
  final _notesController = TextEditingController();
  MoneyItemStatus _status = MoneyItemStatus.notStarted;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sourceController.dispose();
    _amountGrossController.dispose();
    _amountNetController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _cancellationContactController.dispose();
    _cancellationPhoneController.dispose();
    _cancellationEmailController.dispose();
    _survivorInstructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = ref.read(appDatabaseProvider);
    final repo = MoneyRepository(db);
    final income = await repo.getIncome(widget.incomeId);
    final moneyItem = await repo.getMoneyItem(widget.moneyItemId);
    if (income != null && moneyItem != null) {
      setState(() {
        _income = income;
        _moneyItem = moneyItem;
        _incomeType = income.incomeType;
        _sourceController.text = income.source ?? '';
        _amountGrossController.text = income.amountGross?.toStringAsFixed(2) ?? '';
        _amountNetController.text = income.amountNet?.toStringAsFixed(2) ?? '';
        _frequency = income.frequency;
        _startDateController.text = income.startDate ?? '';
        _endDateController.text = income.endDate ?? '';
        _stopsOnDeath = income.stopsOnDeath;
        _needsCancellation = income.needsCancellation;
        _cancellationContactController.text = income.cancellationContact ?? '';
        _cancellationPhoneController.text = income.cancellationPhone ?? '';
        _cancellationEmailController.text = income.cancellationEmail ?? '';
        _survivorInstructionsController.text = income.survivorInstructions ?? '';
        _notesController.text = income.notes ?? '';
        _status = moneyItem.status;
        _isLoading = false;
      });
    } else { setState(() => _isLoading = false); }
  }

  Future<void> _save() async {
    final db = ref.read(appDatabaseProvider);
    final repo = MoneyRepository(db);
    final updated = IncomeModel(
      id: widget.incomeId, moneyItemId: widget.moneyItemId, incomeType: _incomeType,
      source: _sourceController.text.isNotEmpty ? _sourceController.text : null,
      amountGross: double.tryParse(_amountGrossController.text),
      amountNet: double.tryParse(_amountNetController.text),
      frequency: _frequency,
      startDate: _startDateController.text.isNotEmpty ? _startDateController.text : null,
      endDate: _endDateController.text.isNotEmpty ? _endDateController.text : null,
      stopsOnDeath: _stopsOnDeath, needsCancellation: _needsCancellation,
      cancellationContact: _cancellationContactController.text.isNotEmpty ? _cancellationContactController.text : null,
      cancellationPhone: _cancellationPhoneController.text.isNotEmpty ? _cancellationPhoneController.text : null,
      cancellationEmail: _cancellationEmailController.text.isNotEmpty ? _cancellationEmailController.text : null,
      survivorInstructions: _survivorInstructionsController.text.isNotEmpty ? _survivorInstructionsController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );
    await repo.updateIncome(updated);
    if (_moneyItem != null) {
      final name = _sourceController.text.isNotEmpty ? '${_sourceController.text} - ${_incomeType.label}' : _incomeType.label;
      await repo.updateMoneyItem(MoneyItemModel(id: _moneyItem!.id, dossierId: _moneyItem!.dossierId, personId: _moneyItem!.personId, category: _moneyItem!.category, type: _moneyItem!.type, name: name, status: _status, createdAt: _moneyItem!.createdAt, updatedAt: DateTime.now()));
    }
    setState(() => _hasChanges = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inkomen opgeslagen'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Inkomen verwijderen?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuleren')), FilledButton(onPressed: () => Navigator.pop(context, true), style: FilledButton.styleFrom(backgroundColor: Colors.red), child: const Text('Verwijderen'))]));
    if (confirmed == true) {
      final db = ref.read(appDatabaseProvider);
      final repo = MoneyRepository(db);
      await repo.deleteIncome(widget.incomeId, widget.moneyItemId);
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
        title: Text(_sourceController.text.isNotEmpty ? _sourceController.text : 'Nieuw inkomen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner),
            tooltip: Platform.isAndroid || Platform.isIOS ? 'Scan loonstrook' : 'Import PDF',
            onPressed: _scanDocument,
          ),
          IconButton(icon: const Icon(Icons.check), onPressed: _save, tooltip: 'Opslaan'),
          PopupMenuButton<String>(onSelected: (a) { if (a == 'delete') _delete(); }, itemBuilder: (c) => [const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 12), Text('Verwijderen', style: TextStyle(color: Colors.red))]))]),
        ],
        bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Basis'), Tab(text: 'Nabestaanden'), Tab(text: 'Notities')]),
      ),
      body: TabBarView(controller: _tabController, children: [_buildBasisTab(), _buildNabestaandenTab(), _buildNotitiesTab()]),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBasisTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      DropdownButtonFormField<IncomeType>(value: _incomeType, decoration: const InputDecoration(labelText: 'Type inkomen', prefixIcon: Icon(Icons.category)), items: IncomeType.values.map((t) => DropdownMenuItem(value: t, child: Row(children: [Text(t.emoji), const SizedBox(width: 8), Text(t.label)]))).toList(), onChanged: (v) { if (v != null) { setState(() => _incomeType = v); _markChanged(); } }),
      const SizedBox(height: 16),
      TextField(controller: _sourceController, decoration: const InputDecoration(labelText: 'Bron', hintText: 'Bijv. werkgever, UWV', prefixIcon: Icon(Icons.business)), onChanged: (_) => _markChanged()),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: AmountField(controller: _amountGrossController, labelText: 'Bruto', onChanged: _markChanged)),
        const SizedBox(width: 16),
        Expanded(child: AmountField(controller: _amountNetController, labelText: 'Netto', onChanged: _markChanged)),
      ]),
      const SizedBox(height: 16),
      DropdownButtonFormField<PaymentFrequency>(value: _frequency, decoration: const InputDecoration(labelText: 'Frequentie', prefixIcon: Icon(Icons.repeat)), items: PaymentFrequency.values.map((f) => DropdownMenuItem(value: f, child: Text(f.label))).toList(), onChanged: (v) { if (v != null) { setState(() => _frequency = v); _markChanged(); } }),
      const SizedBox(height: 16),
      Row(children: [
        Expanded(child: DatePickerField(controller: _startDateController, labelText: 'Ingangsdatum', onChanged: _markChanged)),
        const SizedBox(width: 16),
        Expanded(child: DatePickerField(controller: _endDateController, labelText: 'Einddatum', onChanged: _markChanged)),
      ]),
    ]));
  }

  Widget _buildNabestaandenTab() {
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(Icons.info_outline, color: Colors.green[700]), const SizedBox(width: 12), const Expanded(child: Text('Wat moeten nabestaanden weten over dit inkomen?'))])),
      const SizedBox(height: 16),
      SwitchListTile(title: const Text('Stopt bij overlijden'), value: _stopsOnDeath, onChanged: (v) { setState(() => _stopsOnDeath = v); _markChanged(); }),
      SwitchListTile(title: const Text('Moet worden gemeld/opgezegd'), value: _needsCancellation, onChanged: (v) { setState(() => _needsCancellation = v); _markChanged(); }),
      if (_needsCancellation) ...[
        const SizedBox(height: 16),
        TextField(controller: _cancellationContactController, decoration: const InputDecoration(labelText: 'Contactpersoon voor melding'), onChanged: (_) => _markChanged()),
        const SizedBox(height: 12),
        PhoneField(controller: _cancellationPhoneController, labelText: 'Telefoon', onChanged: _markChanged),
        const SizedBox(height: 12),
        EmailField(controller: _cancellationEmailController, labelText: 'Email', onChanged: _markChanged),
      ],
      const SizedBox(height: 16),
      TextField(controller: _survivorInstructionsController, decoration: const InputDecoration(labelText: 'Speciale instructies', prefixIcon: Icon(Icons.notes)), maxLines: 3, onChanged: (_) => _markChanged()),
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

  /// Scan een loonstrook/jaaropgaaf en vul velden automatisch in
  Future<void> _scanDocument() async {
    final data = await showDocumentScanner(
      context,
      documentType: DocumentType.payslip,
    );

    if (data != null && data.hasData) {
      setState(() {
        // Werkgever/Bron
        if (data.employer != null && _sourceController.text.isEmpty) {
          _sourceController.text = data.employer!;
        }
        
        // Bruto inkomen
        if (data.grossIncome != null && _amountGrossController.text.isEmpty) {
          _amountGrossController.text = data.grossIncome!.toStringAsFixed(2);
        }
        
        // Netto inkomen
        if (data.netIncome != null && _amountNetController.text.isEmpty) {
          _amountNetController.text = data.netIncome!.toStringAsFixed(2);
        }
        
        // Periode
        if (data.incomePeriod != null && _startDateController.text.isEmpty) {
          _startDateController.text = data.incomePeriod!;
        }
        
        // Datums
        if (data.dates.isNotEmpty && _startDateController.text.isEmpty) {
          _startDateController.text = data.dates.first;
        }
      });
      
      _markChanged();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gegevens overgenomen van scan'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}

