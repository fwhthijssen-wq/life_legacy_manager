// lib/modules/money/screens/insurances/insurance_detail_screen.dart

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_database.dart';
import '../../../../core/ocr/document_scanner_widget.dart';
import '../../../../core/ocr/document_patterns.dart';
import '../../../../core/widgets/date_picker_field.dart';
import '../../models/insurance_model.dart';
import '../../models/money_item_model.dart';
import '../../repositories/money_repository.dart';

class InsuranceDetailScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final String insuranceId;
  final String moneyItemId;
  final bool isNew;
  final String? personId;
  final String? personName; // Voor automatisch invullen verzekerde

  const InsuranceDetailScreen({
    super.key,
    required this.dossierId,
    required this.insuranceId,
    required this.moneyItemId,
    this.isNew = false,
    this.personId,
    this.personName,
  });

  @override
  ConsumerState<InsuranceDetailScreen> createState() => _InsuranceDetailScreenState();
}

class _InsuranceDetailScreenState extends ConsumerState<InsuranceDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasChanges = false;

  InsuranceModel? _insurance;
  MoneyItemModel? _moneyItem;

  // Form controllers - Basisgegevens
  final _companyController = TextEditingController();
  InsuranceType _insuranceType = InsuranceType.other;
  final _policyNumberController = TextEditingController();
  final _insuredNameController = TextEditingController();
  final _coInsuredController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _durationController = TextEditingController();

  // Financieel
  final _premiumController = TextEditingController();
  PaymentFrequency _paymentFrequency = PaymentFrequency.monthly;
  final _paymentMethodController = TextEditingController();
  final _coverageAmountController = TextEditingController();
  final _deductibleController = TextEditingController();
  final _additionalCoverageController = TextEditingController();

  // Voorwaarden & Opzegging
  final _noticePeriodController = TextEditingController();
  bool _autoRenewal = true;
  CancellationMethod _cancellationMethod = CancellationMethod.letter;
  final _lastCancellationDateController = TextEditingController();

  // Contactgegevens
  final _advisorNameController = TextEditingController();
  final _advisorPhoneController = TextEditingController();
  final _advisorEmailController = TextEditingController();
  final _servicePhoneController = TextEditingController();
  final _serviceEmailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _claimsUrlController = TextEditingController();

  // Voor nabestaanden
  DeathAction _deathAction = DeathAction.cancel;
  final _beneficiariesController = TextEditingController();
  final _actionRequiredController = TextEditingController();
  final _deathInstructionsController = TextEditingController();

  // Notities
  final _notesController = TextEditingController();

  // Status
  MoneyItemStatus _status = MoneyItemStatus.notStarted;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyController.dispose();
    _policyNumberController.dispose();
    _insuredNameController.dispose();
    _coInsuredController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _durationController.dispose();
    _premiumController.dispose();
    _paymentMethodController.dispose();
    _coverageAmountController.dispose();
    _deductibleController.dispose();
    _additionalCoverageController.dispose();
    _noticePeriodController.dispose();
    _lastCancellationDateController.dispose();
    _advisorNameController.dispose();
    _advisorPhoneController.dispose();
    _advisorEmailController.dispose();
    _servicePhoneController.dispose();
    _serviceEmailController.dispose();
    _websiteController.dispose();
    _claimsUrlController.dispose();
    _beneficiariesController.dispose();
    _actionRequiredController.dispose();
    _deathInstructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = ref.read(appDatabaseProvider);
    final repo = MoneyRepository(db);

    final insurance = await repo.getInsurance(widget.insuranceId);
    final moneyItem = await repo.getMoneyItem(widget.moneyItemId);

    if (insurance != null && moneyItem != null) {
      setState(() {
        _insurance = insurance;
        _moneyItem = moneyItem;
        _populateFields(insurance, moneyItem);
        _isLoading = false;
      });
    } else {
      // Bij nieuwe verzekering: vul automatisch de verzekerde naam in
      if (widget.isNew && widget.personName != null) {
        _insuredNameController.text = widget.personName!;
      }
      setState(() => _isLoading = false);
    }
  }

  void _populateFields(InsuranceModel insurance, MoneyItemModel moneyItem) {
    _companyController.text = insurance.company;
    _insuranceType = insurance.insuranceType;
    _policyNumberController.text = insurance.policyNumber ?? '';
    _insuredNameController.text = insurance.insuredPersonId ?? '';
    _coInsuredController.text = insurance.coInsured ?? '';
    _startDateController.text = insurance.startDate ?? '';
    _endDateController.text = insurance.endDate ?? '';
    _durationController.text = insurance.duration ?? '';

    _premiumController.text = insurance.premium?.toStringAsFixed(2) ?? '';
    _paymentFrequency = insurance.paymentFrequency;
    _paymentMethodController.text = insurance.paymentMethod ?? '';
    _coverageAmountController.text = insurance.coverageAmount?.toStringAsFixed(2) ?? '';
    _deductibleController.text = insurance.deductible?.toStringAsFixed(2) ?? '';
    _additionalCoverageController.text = insurance.additionalCoverage ?? '';

    _noticePeriodController.text = insurance.noticePeriod ?? '';
    _autoRenewal = insurance.autoRenewal;
    _cancellationMethod = insurance.cancellationMethod;
    _lastCancellationDateController.text = insurance.lastCancellationDate ?? '';

    _advisorNameController.text = insurance.advisorName ?? '';
    _advisorPhoneController.text = insurance.advisorPhone ?? '';
    _advisorEmailController.text = insurance.advisorEmail ?? '';
    _servicePhoneController.text = insurance.servicePhone ?? '';
    _serviceEmailController.text = insurance.serviceEmail ?? '';
    _websiteController.text = insurance.website ?? '';
    _claimsUrlController.text = insurance.claimsUrl ?? '';

    _deathAction = insurance.deathAction;
    _beneficiariesController.text = insurance.beneficiaries ?? '';
    _actionRequiredController.text = insurance.actionRequired ?? '';
    _deathInstructionsController.text = insurance.deathInstructions ?? '';

    _notesController.text = insurance.notes ?? '';
    _status = moneyItem.status;
  }

  Future<void> _save() async {
    if (_companyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vul de naam van de verzekeraar in'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final repo = MoneyRepository(db);

    final updatedInsurance = InsuranceModel(
      id: widget.insuranceId,
      moneyItemId: widget.moneyItemId,
      company: _companyController.text,
      insuranceType: _insuranceType,
      policyNumber: _policyNumberController.text.isNotEmpty ? _policyNumberController.text : null,
      insuredPersonId: _insuredNameController.text.isNotEmpty ? _insuredNameController.text : null,
      coInsured: _coInsuredController.text.isNotEmpty ? _coInsuredController.text : null,
      startDate: _startDateController.text.isNotEmpty ? _startDateController.text : null,
      endDate: _endDateController.text.isNotEmpty ? _endDateController.text : null,
      duration: _durationController.text.isNotEmpty ? _durationController.text : null,
      premium: double.tryParse(_premiumController.text),
      paymentFrequency: _paymentFrequency,
      paymentMethod: _paymentMethodController.text.isNotEmpty ? _paymentMethodController.text : null,
      coverageAmount: double.tryParse(_coverageAmountController.text),
      deductible: double.tryParse(_deductibleController.text),
      additionalCoverage: _additionalCoverageController.text.isNotEmpty ? _additionalCoverageController.text : null,
      noticePeriod: _noticePeriodController.text.isNotEmpty ? _noticePeriodController.text : null,
      autoRenewal: _autoRenewal,
      cancellationMethod: _cancellationMethod,
      lastCancellationDate: _lastCancellationDateController.text.isNotEmpty ? _lastCancellationDateController.text : null,
      advisorName: _advisorNameController.text.isNotEmpty ? _advisorNameController.text : null,
      advisorPhone: _advisorPhoneController.text.isNotEmpty ? _advisorPhoneController.text : null,
      advisorEmail: _advisorEmailController.text.isNotEmpty ? _advisorEmailController.text : null,
      servicePhone: _servicePhoneController.text.isNotEmpty ? _servicePhoneController.text : null,
      serviceEmail: _serviceEmailController.text.isNotEmpty ? _serviceEmailController.text : null,
      website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
      claimsUrl: _claimsUrlController.text.isNotEmpty ? _claimsUrlController.text : null,
      deathAction: _deathAction,
      beneficiaries: _beneficiariesController.text.isNotEmpty ? _beneficiariesController.text : null,
      actionRequired: _actionRequiredController.text.isNotEmpty ? _actionRequiredController.text : null,
      deathInstructions: _deathInstructionsController.text.isNotEmpty ? _deathInstructionsController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    await repo.updateInsurance(updatedInsurance);

    // Update status
    if (_moneyItem != null) {
      final updatedMoneyItem = MoneyItemModel(
        id: _moneyItem!.id,
        dossierId: _moneyItem!.dossierId,
        personId: _moneyItem!.personId,
        category: _moneyItem!.category,
        type: _moneyItem!.type,
        name: '${_companyController.text} - ${_insuranceType.label}',
        status: _status,
        createdAt: _moneyItem!.createdAt,
        updatedAt: DateTime.now(),
      );
      await repo.updateMoneyItem(updatedMoneyItem);
    }

    setState(() => _hasChanges = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Verzekering opgeslagen'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verzekering verwijderen?'),
        content: const Text('Deze actie kan niet ongedaan worden gemaakt.'),
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
      await repo.deleteInsurance(widget.insuranceId, widget.moneyItemId);

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Laden...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _companyController.text.isNotEmpty
              ? _companyController.text
              : 'Nieuwe verzekering',
        ),
        actions: [
          // Document scan/import knop
          IconButton(
            icon: const Icon(Icons.document_scanner),
            tooltip: Platform.isAndroid || Platform.isIOS 
                ? 'Scan verzekeringspolis' 
                : 'Import PDF',
            onPressed: _scanDocument,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
            tooltip: 'Opslaan',
          ),
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'delete') _delete();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Verwijderen', style: TextStyle(color: Colors.red)),
                  ],
                ),
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
            Tab(text: 'Opzegging'),
            Tab(text: 'Contact'),
            Tab(text: 'Nabestaanden'),
            Tab(text: 'Documenten'),
            Tab(text: 'Notities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasisTab(theme),
          _buildFinancieelTab(theme),
          _buildOpzeggingTab(theme),
          _buildContactTab(theme),
          _buildNabestaandenTab(theme),
          _buildDocumentenTab(theme),
          _buildNotitiesTab(theme),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildBasisTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verzekeraar
          Autocomplete<String>(
            initialValue: TextEditingValue(text: _companyController.text),
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return InsuranceModel.commonInsurers;
              }
              return InsuranceModel.commonInsurers.where((insurer) =>
                  insurer.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (selection) {
              _companyController.text = selection;
              _markChanged();
            },
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              // Sync met onze controller
              if (controller.text != _companyController.text) {
                controller.text = _companyController.text;
              }
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Verzekeraar *',
                  hintText: 'Bijv. Nationale-Nederlanden',
                  prefixIcon: Icon(Icons.business),
                ),
                onChanged: (value) {
                  _companyController.text = value;
                  _markChanged();
                },
              );
            },
          ),
          const SizedBox(height: 16),

          // Type verzekering
          DropdownButtonFormField<InsuranceType>(
            value: _insuranceType,
            decoration: const InputDecoration(
              labelText: 'Type verzekering *',
              prefixIcon: Icon(Icons.category),
            ),
            items: InsuranceType.values.map((type) => DropdownMenuItem(
              value: type,
              child: Row(
                children: [
                  Text(type.emoji),
                  const SizedBox(width: 8),
                  Text(type.label),
                ],
              ),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _insuranceType = value);
                _markChanged();
              }
            },
          ),
          const SizedBox(height: 16),

          // Polisnummer
          TextField(
            controller: _policyNumberController,
            decoration: const InputDecoration(
              labelText: 'Polisnummer',
              prefixIcon: Icon(Icons.tag),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          // Naam verzekerde
          TextField(
            controller: _insuredNameController,
            decoration: const InputDecoration(
              labelText: 'Naam verzekerde',
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          // Medeverzekerden
          TextField(
            controller: _coInsuredController,
            decoration: const InputDecoration(
              labelText: 'Medeverzekerden',
              hintText: 'Bijv. partner, kinderen',
              prefixIcon: Icon(Icons.people),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          // Ingangsdatum
          DatePickerField(
            controller: _startDateController,
            labelText: 'Ingangsdatum',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          // Einddatum
          DatePickerField(
            controller: _endDateController,
            labelText: 'Einddatum',
            hintText: 'Indien bekend',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          // Looptijd
          TextField(
            controller: _durationController,
            decoration: const InputDecoration(
              labelText: 'Looptijd',
              hintText: 'Bijv. 1 jaar, onbepaald',
              prefixIcon: Icon(Icons.timelapse),
            ),
            onChanged: (_) => _markChanged(),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancieelTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premie
          AmountField(
            controller: _premiumController,
            labelText: 'Premie',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          // Betalingsfrequentie
          DropdownButtonFormField<PaymentFrequency>(
            value: _paymentFrequency,
            decoration: const InputDecoration(
              labelText: 'Betalingsfrequentie',
              prefixIcon: Icon(Icons.repeat),
            ),
            items: PaymentFrequency.values.map((freq) => DropdownMenuItem(
              value: freq,
              child: Text(freq.label),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _paymentFrequency = value);
                _markChanged();
              }
            },
          ),
          const SizedBox(height: 16),

          // Betaalmethode
          TextField(
            controller: _paymentMethodController,
            decoration: const InputDecoration(
              labelText: 'Betaalmethode',
              hintText: 'Bijv. automatische incasso',
              prefixIcon: Icon(Icons.payment),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          // Verzekerd bedrag
          AmountField(
            controller: _coverageAmountController,
            labelText: 'Verzekerd bedrag',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          // Eigen risico
          AmountField(
            controller: _deductibleController,
            labelText: 'Eigen risico',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          // Aanvullende dekkingen
          TextField(
            controller: _additionalCoverageController,
            decoration: const InputDecoration(
              labelText: 'Aanvullende dekkingen/clausules',
              prefixIcon: Icon(Icons.add_circle_outline),
            ),
            maxLines: 3,
            onChanged: (_) => _markChanged(),
          ),
        ],
      ),
    );
  }

  Widget _buildOpzeggingTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Opzegtermijn
          TextField(
            controller: _noticePeriodController,
            decoration: const InputDecoration(
              labelText: 'Opzegtermijn',
              hintText: 'Bijv. 2 maanden voor einddatum',
              prefixIcon: Icon(Icons.timer),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          // Automatische verlenging
          SwitchListTile(
            title: const Text('Automatische verlenging'),
            subtitle: const Text('Wordt de verzekering automatisch verlengd?'),
            value: _autoRenewal,
            onChanged: (value) {
              setState(() => _autoRenewal = value);
              _markChanged();
            },
          ),
          const SizedBox(height: 16),

          // Hoe opzeggen
          DropdownButtonFormField<CancellationMethod>(
            value: _cancellationMethod,
            decoration: const InputDecoration(
              labelText: 'Hoe opzeggen?',
              prefixIcon: Icon(Icons.cancel),
            ),
            items: CancellationMethod.values.map((method) => DropdownMenuItem(
              value: method,
              child: Text(method.label),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _cancellationMethod = value);
                _markChanged();
              }
            },
          ),
          const SizedBox(height: 16),

          // Laatst mogelijke opzegging
          TextField(
            controller: _lastCancellationDateController,
            decoration: const InputDecoration(
              labelText: 'Laatst mogelijke opzegging',
              hintText: 'DD-MM-JJJJ',
              prefixIcon: Icon(Icons.event_busy),
            ),
            onChanged: (_) => _markChanged(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Adviseur/Tussenpersoon', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          TextField(
            controller: _advisorNameController,
            decoration: const InputDecoration(
              labelText: 'Naam adviseur',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),

          PhoneField(
            controller: _advisorPhoneController,
            labelText: 'Telefoon adviseur',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 12),

          EmailField(
            controller: _advisorEmailController,
            labelText: 'Email adviseur',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 24),

          Text('Verzekeraar Klantenservice', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          PhoneField(
            controller: _servicePhoneController,
            labelText: 'Telefoon klantenservice',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 12),

          EmailField(
            controller: _serviceEmailController,
            labelText: 'Email klantenservice',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 12),

          WebsiteField(
            controller: _websiteController,
            labelText: 'Website',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 12),

          WebsiteField(
            controller: _claimsUrlController,
            labelText: 'Schademelding URL',
            onChanged: _markChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNabestaandenTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange[700]),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Deze informatie helpt nabestaanden om te weten wat er moet gebeuren met deze verzekering.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Wat gebeurt bij overlijden
          DropdownButtonFormField<DeathAction>(
            value: _deathAction,
            decoration: const InputDecoration(
              labelText: 'Wat gebeurt bij overlijden?',
              prefixIcon: Icon(Icons.help_outline),
            ),
            items: DeathAction.values.map((action) => DropdownMenuItem(
              value: action,
              child: Text(action.label),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _deathAction = value);
                _markChanged();
              }
            },
          ),
          const SizedBox(height: 16),

          // Begunstigden
          TextField(
            controller: _beneficiariesController,
            decoration: const InputDecoration(
              labelText: 'Begunstigden',
              hintText: 'Namen en percentages',
              prefixIcon: Icon(Icons.people),
            ),
            maxLines: 2,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          // Actie vereist
          TextField(
            controller: _actionRequiredController,
            decoration: const InputDecoration(
              labelText: 'Actie vereist?',
              hintText: 'Wat moeten nabestaanden doen?',
              prefixIcon: Icon(Icons.checklist),
            ),
            maxLines: 2,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          // Speciale instructies
          TextField(
            controller: _deathInstructionsController,
            decoration: const InputDecoration(
              labelText: 'Speciale instructies',
              hintText: 'Overige informatie voor nabestaanden',
              prefixIcon: Icon(Icons.notes),
            ),
            maxLines: 4,
            onChanged: (_) => _markChanged(),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentenTab(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Documenten',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Voeg polissen, voorwaarden en andere\ndocumenten toe aan deze verzekering',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Document upload wordt binnenkort toegevoegd'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Document toevoegen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotitiesTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _notesController,
        decoration: const InputDecoration(
          labelText: 'Notities',
          hintText: 'Overige opmerkingen over deze verzekering...',
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

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status dropdown
          Expanded(
            child: DropdownButtonFormField<MoneyItemStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: MoneyItemStatus.values.map((status) => DropdownMenuItem(
                value: status,
                child: Row(
                  children: [
                    Icon(
                      status == MoneyItemStatus.complete ? Icons.check_circle :
                      status == MoneyItemStatus.partial ? Icons.pending :
                      Icons.circle_outlined,
                      size: 18,
                      color: status == MoneyItemStatus.complete ? Colors.green :
                             status == MoneyItemStatus.partial ? Colors.orange :
                             Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(status.label),
                  ],
                ),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                  _markChanged();
                }
              },
            ),
          ),
          const SizedBox(width: 16),

          // Opslaan knop
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Opslaan'),
          ),
        ],
      ),
    );
  }

  /// Scan een verzekeringspolis en vul velden automatisch in
  Future<void> _scanDocument() async {
    final data = await showDocumentScanner(
      context,
      documentType: DocumentType.insurancePolicy,
    );

    if (data != null && data.hasData) {
      setState(() {
        // Verzekeraar
        if (data.insurerName != null && _companyController.text.isEmpty) {
          _companyController.text = data.insurerName!;
        }
        
        // Polisnummer
        if (data.policyNumber != null && _policyNumberController.text.isEmpty) {
          _policyNumberController.text = data.policyNumber!;
        }
        
        // Premie
        if (data.premium != null && _premiumController.text.isEmpty) {
          _premiumController.text = data.premium!.toStringAsFixed(2);
        }
        
        // Eigen risico
        if (data.deductible != null && _deductibleController.text.isEmpty) {
          _deductibleController.text = data.deductible!.toStringAsFixed(2);
        }
        
        // Dekking
        if (data.coverageAmount != null && _coverageAmountController.text.isEmpty) {
          _coverageAmountController.text = data.coverageAmount!.toStringAsFixed(2);
        }
        
        // Telefoon
        if (data.phone != null && _servicePhoneController.text.isEmpty) {
          _servicePhoneController.text = data.phone!;
        }
        
        // Email
        if (data.email != null && _serviceEmailController.text.isEmpty) {
          _serviceEmailController.text = data.email!;
        }
        
        // Website
        if (data.website != null && _websiteController.text.isEmpty) {
          _websiteController.text = data.website!;
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

