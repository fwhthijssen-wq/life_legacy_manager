// lib/modules/money/screens/debts/debt_detail_screen.dart

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_database.dart';
import '../../../../core/ocr/document_scanner_widget.dart';
import '../../../../core/widgets/date_picker_field.dart';
import '../../models/debt_model.dart';
import '../../models/money_item_model.dart';
import '../../repositories/money_repository.dart';

class DebtDetailScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final String debtId;
  final String moneyItemId;
  final bool isNew;

  const DebtDetailScreen({
    super.key,
    required this.dossierId,
    required this.debtId,
    required this.moneyItemId,
    this.isNew = false,
  });

  @override
  ConsumerState<DebtDetailScreen> createState() => _DebtDetailScreenState();
}

class _DebtDetailScreenState extends ConsumerState<DebtDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasChanges = false;
  DebtModel? _debt;
  MoneyItemModel? _moneyItem;

  DebtType _debtType = DebtType.other;
  RepaymentType _repaymentType = RepaymentType.annuity;
  final _creditorController = TextEditingController();
  final _contractNumberController = TextEditingController();
  final _originalAmountController = TextEditingController();
  final _currentBalanceController = TextEditingController();
  final _durationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _monthlyPaymentController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _fixedRateUntilController = TextEditingController();
  final _earlyRepaymentPenaltyController = TextEditingController();
  bool _hasCollateral = false;
  final _collateralDescriptionController = TextEditingController();
  final _deathActionController = TextEditingController();
  bool _hasLinkedInsurance = false;
  final _survivorInstructionsController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _notesController = TextEditingController();
  MoneyItemStatus _status = MoneyItemStatus.notStarted;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _creditorController.dispose();
    _contractNumberController.dispose();
    _originalAmountController.dispose();
    _currentBalanceController.dispose();
    _durationController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _monthlyPaymentController.dispose();
    _interestRateController.dispose();
    _fixedRateUntilController.dispose();
    _earlyRepaymentPenaltyController.dispose();
    _collateralDescriptionController.dispose();
    _deathActionController.dispose();
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
    final debt = await repo.getDebt(widget.debtId);
    final moneyItem = await repo.getMoneyItem(widget.moneyItemId);

    if (debt != null && moneyItem != null) {
      setState(() {
        _debt = debt;
        _moneyItem = moneyItem;
        _debtType = debt.debtType;
        _repaymentType = debt.repaymentType;
        _creditorController.text = debt.creditor ?? '';
        _contractNumberController.text = debt.contractNumber ?? '';
        _originalAmountController.text =
            debt.originalAmount?.toStringAsFixed(2) ?? '';
        _currentBalanceController.text =
            debt.currentBalance?.toStringAsFixed(2) ?? '';
        _durationController.text = debt.duration ?? '';
        _startDateController.text = debt.startDate ?? '';
        _endDateController.text = debt.endDate ?? '';
        _monthlyPaymentController.text =
            debt.monthlyPayment?.toStringAsFixed(2) ?? '';
        _interestRateController.text =
            debt.interestRate?.toStringAsFixed(2) ?? '';
        _fixedRateUntilController.text = debt.fixedRateUntil ?? '';
        _earlyRepaymentPenaltyController.text =
            debt.earlyRepaymentPenalty?.toStringAsFixed(2) ?? '';
        _hasCollateral = debt.hasCollateral;
        _collateralDescriptionController.text = debt.collateralDescription ?? '';
        _deathActionController.text = debt.deathAction ?? '';
        _hasLinkedInsurance = debt.hasLinkedInsurance;
        _survivorInstructionsController.text = debt.survivorInstructions ?? '';
        _contactPhoneController.text = debt.contactPhone ?? '';
        _contactEmailController.text = debt.contactEmail ?? '';
        _websiteController.text = debt.website ?? '';
        _notesController.text = debt.notes ?? '';
        _status = moneyItem.status;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _save() async {
    final db = ref.read(appDatabaseProvider);
    final repo = MoneyRepository(db);
    final updated = DebtModel(
      id: widget.debtId,
      moneyItemId: widget.moneyItemId,
      debtType: _debtType,
      repaymentType: _repaymentType,
      creditor: _creditorController.text.isNotEmpty
          ? _creditorController.text
          : null,
      contractNumber: _contractNumberController.text.isNotEmpty
          ? _contractNumberController.text
          : null,
      originalAmount: double.tryParse(_originalAmountController.text),
      currentBalance: double.tryParse(_currentBalanceController.text),
      duration:
          _durationController.text.isNotEmpty ? _durationController.text : null,
      startDate: _startDateController.text.isNotEmpty
          ? _startDateController.text
          : null,
      endDate:
          _endDateController.text.isNotEmpty ? _endDateController.text : null,
      monthlyPayment: double.tryParse(_monthlyPaymentController.text),
      interestRate: double.tryParse(_interestRateController.text),
      fixedRateUntil: _fixedRateUntilController.text.isNotEmpty
          ? _fixedRateUntilController.text
          : null,
      earlyRepaymentPenalty:
          double.tryParse(_earlyRepaymentPenaltyController.text),
      hasCollateral: _hasCollateral,
      collateralDescription: _collateralDescriptionController.text.isNotEmpty
          ? _collateralDescriptionController.text
          : null,
      deathAction: _deathActionController.text.isNotEmpty
          ? _deathActionController.text
          : null,
      hasLinkedInsurance: _hasLinkedInsurance,
      survivorInstructions: _survivorInstructionsController.text.isNotEmpty
          ? _survivorInstructionsController.text
          : null,
      contactPhone: _contactPhoneController.text.isNotEmpty
          ? _contactPhoneController.text
          : null,
      contactEmail: _contactEmailController.text.isNotEmpty
          ? _contactEmailController.text
          : null,
      website:
          _websiteController.text.isNotEmpty ? _websiteController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    await repo.updateDebt(updated);

    if (_moneyItem != null) {
      final name = _creditorController.text.isNotEmpty
          ? '${_creditorController.text} - ${_debtType.label}'
          : _debtType.label;
      await repo.updateMoneyItem(MoneyItemModel(
        id: _moneyItem!.id,
        dossierId: _moneyItem!.dossierId,
        personId: _moneyItem!.personId,
        category: _moneyItem!.category,
        type: _moneyItem!.type,
        name: name,
        status: _status,
        createdAt: _moneyItem!.createdAt,
        updatedAt: DateTime.now(),
      ));
    }

    setState(() => _hasChanges = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Schuld/lening opgeslagen'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schuld/lening verwijderen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      final db = ref.read(appDatabaseProvider);
      final repo = MoneyRepository(db);
      await repo.deleteDebt(widget.debtId, widget.moneyItemId);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Laden...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(_creditorController.text.isNotEmpty
            ? _creditorController.text
            : 'Nieuwe schuld/lening'),
        actions: [
          // Document scan/import knop
          IconButton(
            icon: const Icon(Icons.document_scanner),
            tooltip: Platform.isAndroid || Platform.isIOS 
                ? 'Scan leningscontract' 
                : 'Import PDF',
            onPressed: _scanDocument,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
            tooltip: 'Opslaan',
          ),
          PopupMenuButton<String>(
            onSelected: (a) {
              if (a == 'delete') _delete();
            },
            itemBuilder: (c) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 12),
                  Text('Verwijderen', style: TextStyle(color: Colors.red)),
                ]),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Basis'),
            Tab(text: 'Financieel'),
            Tab(text: 'Onderpand'),
            Tab(text: 'Nabestaanden'),
            Tab(text: 'Notities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasisTab(),
          _buildFinancieelTab(),
          _buildOnderpandTab(),
          _buildNabestaandenTab(),
          _buildNotitiesTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildBasisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<DebtType>(
            value: _debtType,
            decoration: const InputDecoration(
              labelText: 'Type schuld/lening',
              prefixIcon: Icon(Icons.category),
            ),
            items: DebtType.values
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Row(children: [
                        Text(t.emoji),
                        const SizedBox(width: 8),
                        Text(t.label),
                      ]),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _debtType = v);
                _markChanged();
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _creditorController,
            decoration: const InputDecoration(
              labelText: 'Schuldeiser',
              hintText: 'Bijv. bank, particulier',
              prefixIcon: Icon(Icons.business),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contractNumberController,
            decoration: const InputDecoration(
              labelText: 'Contractnummer',
              prefixIcon: Icon(Icons.tag),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: AmountField(
                controller: _originalAmountController,
                labelText: 'Oorspronkelijk',
                onChanged: _markChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AmountField(
                controller: _currentBalanceController,
                labelText: 'Openstaand',
                onChanged: _markChanged,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          DropdownButtonFormField<RepaymentType>(
            value: _repaymentType,
            decoration: const InputDecoration(
              labelText: 'Aflossingsvorm',
              prefixIcon: Icon(Icons.trending_down),
            ),
            items: RepaymentType.values
                .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _repaymentType = v);
                _markChanged();
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _durationController,
            decoration: const InputDecoration(
              labelText: 'Looptijd',
              hintText: 'Bijv. 30 jaar',
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: DatePickerField(
                controller: _startDateController,
                labelText: 'Ingangsdatum',
                onChanged: _markChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: DatePickerField(
                controller: _endDateController,
                labelText: 'Aflosdatum',
                onChanged: _markChanged,
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildFinancieelTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AmountField(
            controller: _monthlyPaymentController,
            labelText: 'Maandelijkse termijn',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),
          PercentageField(
            controller: _interestRateController,
            labelText: 'Rentepercentage',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),
          DatePickerField(
            controller: _fixedRateUntilController,
            labelText: 'Rentevast tot',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),
          PercentageField(
            controller: _earlyRepaymentPenaltyController,
            labelText: 'Boeterente vervroegd aflossen',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 24),
          Text('Contact', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          PhoneField(
            controller: _contactPhoneController,
            labelText: 'Telefoon',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 12),
          EmailField(
            controller: _contactEmailController,
            labelText: 'Email',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 12),
          WebsiteField(
            controller: _websiteController,
            labelText: 'Website',
            onChanged: _markChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildOnderpandTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Er is onderpand'),
            subtitle: const Text('Bijv. woning bij hypotheek'),
            value: _hasCollateral,
            onChanged: (v) {
              setState(() => _hasCollateral = v);
              _markChanged();
            },
          ),
          if (_hasCollateral) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _collateralDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Omschrijving onderpand',
                hintText: 'Bijv. woning aan Hoofdstraat 1',
              ),
              maxLines: 3,
              onChanged: (_) => _markChanged(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNabestaandenTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.brown.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Icon(Icons.info_outline, color: Colors.brown[700]),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Wat gebeurt er met deze schuld bij overlijden?'),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _deathActionController,
            decoration: const InputDecoration(
              labelText: 'Actie bij overlijden',
              hintText: 'Bijv. schuld wordt afgelost door ORV',
            ),
            maxLines: 2,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Er is een gekoppelde verzekering'),
            subtitle: const Text('Bijv. overlijdensrisicoverzekering'),
            value: _hasLinkedInsurance,
            onChanged: (v) {
              setState(() => _hasLinkedInsurance = v);
              _markChanged();
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _survivorInstructionsController,
            decoration: const InputDecoration(
              labelText: 'Speciale instructies',
              prefixIcon: Icon(Icons.notes),
            ),
            maxLines: 4,
            onChanged: (_) => _markChanged(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotitiesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _notesController,
        decoration: const InputDecoration(
          labelText: 'Notities',
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        onChanged: (_) => _markChanged(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(children: [
        Expanded(
          child: DropdownButtonFormField<MoneyItemStatus>(
            value: _status,
            decoration: const InputDecoration(
              labelText: 'Status',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: MoneyItemStatus.values
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Row(children: [
                        Icon(
                          s == MoneyItemStatus.complete
                              ? Icons.check_circle
                              : s == MoneyItemStatus.partial
                                  ? Icons.pending
                                  : Icons.circle_outlined,
                          size: 18,
                          color: s == MoneyItemStatus.complete
                              ? Colors.green
                              : s == MoneyItemStatus.partial
                                  ? Colors.orange
                                  : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(s.label),
                      ]),
                    ))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _status = v);
                _markChanged();
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.check),
          label: const Text('Opslaan'),
        ),
      ]),
    );
  }

  /// Scan een leningscontract/hypotheekakte en vul velden automatisch in
  Future<void> _scanDocument() async {
    final data = await showDocumentScanner(
      context,
      documentType: DocumentType.loanContract,
    );

    if (data != null && data.hasData) {
      setState(() {
        // Schuldeiser / Geldverstrekker
        if (data.mortgageProvider != null && _creditorController.text.isEmpty) {
          _creditorController.text = data.mortgageProvider!;
        } else if (data.bankName != null && _creditorController.text.isEmpty) {
          _creditorController.text = data.bankName!;
        }
        
        // Contractnummer
        if (data.contractNumber != null && _contractNumberController.text.isEmpty) {
          _contractNumberController.text = data.contractNumber!;
        }
        
        // Hoofdsom / Oorspronkelijk bedrag
        if (data.principalAmount != null && _originalAmountController.text.isEmpty) {
          _originalAmountController.text = data.principalAmount!.toStringAsFixed(2);
        }
        
        // Openstaand / Restschuld
        if (data.outstandingAmount != null && _currentBalanceController.text.isEmpty) {
          _currentBalanceController.text = data.outstandingAmount!.toStringAsFixed(2);
        }
        
        // Maandtermijn
        if (data.monthlyPayment != null && _monthlyPaymentController.text.isEmpty) {
          _monthlyPaymentController.text = data.monthlyPayment!.toStringAsFixed(2);
        }
        
        // Rente percentage
        if (data.interestRate != null && _interestRateController.text.isEmpty) {
          _interestRateController.text = data.interestRate!.toStringAsFixed(2);
        }
        
        // Rentevast tot
        if (data.fixedRatePeriod != null && _fixedRateUntilController.text.isEmpty) {
          _fixedRateUntilController.text = data.fixedRatePeriod!;
        }
        
        // Looptijd
        if (data.duration != null && _durationController.text.isEmpty) {
          _durationController.text = data.duration!;
        }
        
        // Datums
        if (data.dates.isNotEmpty) {
          if (_startDateController.text.isEmpty) {
            _startDateController.text = data.dates.first;
          }
          if (data.dates.length >= 2 && _endDateController.text.isEmpty) {
            _endDateController.text = data.dates.last;
          }
        }
        
        // Telefoon
        if (data.phone != null && _contactPhoneController.text.isEmpty) {
          _contactPhoneController.text = data.phone!;
        }
        
        // Email
        if (data.email != null && _contactEmailController.text.isEmpty) {
          _contactEmailController.text = data.email!;
        }
        
        // Website
        if (data.website != null && _websiteController.text.isEmpty) {
          _websiteController.text = data.website!;
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

