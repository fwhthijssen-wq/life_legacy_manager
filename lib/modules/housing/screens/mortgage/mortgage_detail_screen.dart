// lib/modules/housing/screens/mortgage/mortgage_detail_screen.dart
// Detail scherm voor hypotheek met tabs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/date_picker_field.dart';
import '../../models/mortgage_model.dart';
import '../../models/housing_enums.dart';
import '../../models/property_model.dart';
import '../../providers/housing_providers.dart';

class MortgageDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final String mortgageId;
  final bool isNew;

  const MortgageDetailScreen({
    super.key,
    required this.propertyId,
    required this.mortgageId,
    this.isNew = false,
  });

  @override
  ConsumerState<MortgageDetailScreen> createState() => _MortgageDetailScreenState();
}

class _MortgageDetailScreenState extends ConsumerState<MortgageDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasChanges = false;
  MortgageModel? _mortgage;
  List<MortgagePartModel> _parts = [];

  // Tab 1: Basisgegevens
  final _providerController = TextEditingController();
  final _advisorNameController = TextEditingController();
  final _advisorCompanyController = TextEditingController();
  final _advisorPhoneController = TextEditingController();
  final _advisorEmailController = TextEditingController();
  final _notaryNameController = TextEditingController();
  final _notaryOfficeController = TextEditingController();
  final _notaryAddressController = TextEditingController();
  final _notaryPhoneController = TextEditingController();
  final _mortgageNumberController = TextEditingController();
  final _closingDateController = TextEditingController();
  final _deliveryDateController = TextEditingController();

  // Tab 2: Gekoppelde producten
  bool _hasLifeInsurance = false;
  final _lifeInsuranceProviderController = TextEditingController();
  final _lifeInsurancePolicyController = TextEditingController();
  final _lifeInsuranceAmountController = TextEditingController();
  bool _hasDisabilityInsurance = false;
  bool _hasNhg = false;
  final _nhgNumberController = TextEditingController();

  // Tab 3: Betaling & Boetes
  final _paymentDayController = TextEditingController();
  final _earlyRepaymentPenaltyPctController = TextEditingController();
  final _earlyRepaymentPenaltyAmountController = TextEditingController();
  final _maxYearlyRepaymentController = TextEditingController();
  bool _canRenegotiateRate = false;
  final _renegotiationDateController = TextEditingController();
  final _switchConsiderationController = TextEditingController();

  // Tab 4: Voor nabestaanden
  String? _deathCoverage;
  final _deathCoverageAmountController = TextEditingController();
  final _deathContactProviderController = TextEditingController();
  final _deathContactPhoneController = TextEditingController();
  final _deathClaimInsurerController = TextEditingController();
  final _deathClaimPhoneController = TextEditingController();
  final _deathSpecialInstructionsController = TextEditingController();

  // Tab 5: Contact
  final _servicePhoneController = TextEditingController();
  final _serviceEmailController = TextEditingController();
  final _serviceWebsiteController = TextEditingController();
  final _portalUrlController = TextEditingController();

  // Tab 6: Notities
  final _notesController = TextEditingController();

  HousingItemStatus _status = HousingItemStatus.notStarted;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _providerController.dispose();
    _advisorNameController.dispose();
    _advisorCompanyController.dispose();
    _advisorPhoneController.dispose();
    _advisorEmailController.dispose();
    _notaryNameController.dispose();
    _notaryOfficeController.dispose();
    _notaryAddressController.dispose();
    _notaryPhoneController.dispose();
    _mortgageNumberController.dispose();
    _closingDateController.dispose();
    _deliveryDateController.dispose();
    _lifeInsuranceProviderController.dispose();
    _lifeInsurancePolicyController.dispose();
    _lifeInsuranceAmountController.dispose();
    _nhgNumberController.dispose();
    _paymentDayController.dispose();
    _earlyRepaymentPenaltyPctController.dispose();
    _earlyRepaymentPenaltyAmountController.dispose();
    _maxYearlyRepaymentController.dispose();
    _renegotiationDateController.dispose();
    _switchConsiderationController.dispose();
    _deathCoverageAmountController.dispose();
    _deathContactProviderController.dispose();
    _deathContactPhoneController.dispose();
    _deathClaimInsurerController.dispose();
    _deathClaimPhoneController.dispose();
    _deathSpecialInstructionsController.dispose();
    _servicePhoneController.dispose();
    _serviceEmailController.dispose();
    _serviceWebsiteController.dispose();
    _portalUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(housingRepositoryProvider);
    final mortgage = await repo.getMortgage(widget.mortgageId);
    final parts = await repo.getMortgagePartsForMortgage(widget.mortgageId);

    if (mortgage != null) {
      _mortgage = mortgage;
      _parts = parts;
      _populateFields(mortgage);
    }
    setState(() => _isLoading = false);
  }

  void _populateFields(MortgageModel m) {
    _providerController.text = m.provider ?? '';
    _advisorNameController.text = m.advisorName ?? '';
    _advisorCompanyController.text = m.advisorCompany ?? '';
    _advisorPhoneController.text = m.advisorPhone ?? '';
    _advisorEmailController.text = m.advisorEmail ?? '';
    _notaryNameController.text = m.notaryName ?? '';
    _notaryOfficeController.text = m.notaryOffice ?? '';
    _notaryAddressController.text = m.notaryAddress ?? '';
    _notaryPhoneController.text = m.notaryPhone ?? '';
    _mortgageNumberController.text = m.mortgageNumber ?? '';
    _closingDateController.text = m.closingDate ?? '';
    _deliveryDateController.text = m.deliveryDate ?? '';

    _hasLifeInsurance = m.hasLifeInsurance;
    _lifeInsuranceProviderController.text = m.lifeInsuranceProvider ?? '';
    _lifeInsurancePolicyController.text = m.lifeInsurancePolicyNumber ?? '';
    _lifeInsuranceAmountController.text = m.lifeInsuranceAmount?.toStringAsFixed(0) ?? '';
    _hasDisabilityInsurance = m.hasDisabilityInsurance;
    _hasNhg = m.hasNhg;
    _nhgNumberController.text = m.nhgNumber ?? '';

    _paymentDayController.text = m.paymentDay?.toString() ?? '';
    _earlyRepaymentPenaltyPctController.text = m.earlyRepaymentPenaltyPercentage?.toString() ?? '';
    _earlyRepaymentPenaltyAmountController.text = m.earlyRepaymentPenaltyAmount?.toStringAsFixed(0) ?? '';
    _maxYearlyRepaymentController.text = m.maxYearlyRepaymentWithoutPenalty?.toStringAsFixed(0) ?? '';
    _canRenegotiateRate = m.canRenegotiateRate;
    _renegotiationDateController.text = m.renegotiationDate ?? '';
    _switchConsiderationController.text = m.switchConsiderationNote ?? '';

    _deathCoverage = m.deathCoverage;
    _deathCoverageAmountController.text = m.deathCoverageAmount?.toStringAsFixed(0) ?? '';
    _deathContactProviderController.text = m.deathContactProvider ?? '';
    _deathContactPhoneController.text = m.deathContactPhone ?? '';
    _deathClaimInsurerController.text = m.deathClaimInsurer ?? '';
    _deathClaimPhoneController.text = m.deathClaimPhone ?? '';
    _deathSpecialInstructionsController.text = m.deathSpecialInstructions ?? '';

    _servicePhoneController.text = m.servicePhone ?? '';
    _serviceEmailController.text = m.serviceEmail ?? '';
    _serviceWebsiteController.text = m.serviceWebsite ?? '';
    _portalUrlController.text = m.portalUrl ?? '';

    _notesController.text = m.notes ?? '';
    _status = m.status;
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _save() async {
    if (_mortgage == null) return;

    final repo = ref.read(housingRepositoryProvider);
    final updated = MortgageModel(
      id: _mortgage!.id,
      propertyId: _mortgage!.propertyId,
      provider: _providerController.text.isNotEmpty ? _providerController.text : null,
      advisorName: _advisorNameController.text.isNotEmpty ? _advisorNameController.text : null,
      advisorCompany: _advisorCompanyController.text.isNotEmpty ? _advisorCompanyController.text : null,
      advisorPhone: _advisorPhoneController.text.isNotEmpty ? _advisorPhoneController.text : null,
      advisorEmail: _advisorEmailController.text.isNotEmpty ? _advisorEmailController.text : null,
      notaryName: _notaryNameController.text.isNotEmpty ? _notaryNameController.text : null,
      notaryOffice: _notaryOfficeController.text.isNotEmpty ? _notaryOfficeController.text : null,
      notaryAddress: _notaryAddressController.text.isNotEmpty ? _notaryAddressController.text : null,
      notaryPhone: _notaryPhoneController.text.isNotEmpty ? _notaryPhoneController.text : null,
      mortgageNumber: _mortgageNumberController.text.isNotEmpty ? _mortgageNumberController.text : null,
      closingDate: _closingDateController.text.isNotEmpty ? _closingDateController.text : null,
      deliveryDate: _deliveryDateController.text.isNotEmpty ? _deliveryDateController.text : null,
      hasLifeInsurance: _hasLifeInsurance,
      lifeInsuranceProvider: _lifeInsuranceProviderController.text.isNotEmpty ? _lifeInsuranceProviderController.text : null,
      lifeInsurancePolicyNumber: _lifeInsurancePolicyController.text.isNotEmpty ? _lifeInsurancePolicyController.text : null,
      lifeInsuranceAmount: double.tryParse(_lifeInsuranceAmountController.text),
      hasDisabilityInsurance: _hasDisabilityInsurance,
      hasNhg: _hasNhg,
      nhgNumber: _nhgNumberController.text.isNotEmpty ? _nhgNumberController.text : null,
      paymentDay: int.tryParse(_paymentDayController.text),
      earlyRepaymentPenaltyPercentage: double.tryParse(_earlyRepaymentPenaltyPctController.text),
      earlyRepaymentPenaltyAmount: double.tryParse(_earlyRepaymentPenaltyAmountController.text),
      maxYearlyRepaymentWithoutPenalty: double.tryParse(_maxYearlyRepaymentController.text),
      canRenegotiateRate: _canRenegotiateRate,
      renegotiationDate: _renegotiationDateController.text.isNotEmpty ? _renegotiationDateController.text : null,
      switchConsiderationNote: _switchConsiderationController.text.isNotEmpty ? _switchConsiderationController.text : null,
      deathCoverage: _deathCoverage,
      deathCoverageAmount: double.tryParse(_deathCoverageAmountController.text),
      deathContactProvider: _deathContactProviderController.text.isNotEmpty ? _deathContactProviderController.text : null,
      deathContactPhone: _deathContactPhoneController.text.isNotEmpty ? _deathContactPhoneController.text : null,
      deathClaimInsurer: _deathClaimInsurerController.text.isNotEmpty ? _deathClaimInsurerController.text : null,
      deathClaimPhone: _deathClaimPhoneController.text.isNotEmpty ? _deathClaimPhoneController.text : null,
      deathSpecialInstructions: _deathSpecialInstructionsController.text.isNotEmpty ? _deathSpecialInstructionsController.text : null,
      servicePhone: _servicePhoneController.text.isNotEmpty ? _servicePhoneController.text : null,
      serviceEmail: _serviceEmailController.text.isNotEmpty ? _serviceEmailController.text : null,
      serviceWebsite: _serviceWebsiteController.text.isNotEmpty ? _serviceWebsiteController.text : null,
      portalUrl: _portalUrlController.text.isNotEmpty ? _portalUrlController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      status: _status,
      createdAt: _mortgage!.createdAt,
      updatedAt: DateTime.now(),
    );

    await repo.updateMortgage(updated);
    setState(() {
      _mortgage = updated;
      _hasChanges = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hypotheek opgeslagen'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hypotheek verwijderen?'),
        content: const Text('Alle hypotheekgegevens worden verwijderd.'),
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
      final repo = ref.read(housingRepositoryProvider);
      await repo.deleteMortgage(widget.mortgageId);
      if (!mounted) return;
      Navigator.pop(context);
    }
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
        title: Text(_providerController.text.isNotEmpty ? _providerController.text : 'Hypotheek'),
        actions: [
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
            Tab(text: 'Delen'),
            Tab(text: 'Producten'),
            Tab(text: 'Betaling'),
            Tab(text: 'Nabestaanden'),
            Tab(text: 'Contact'),
            Tab(text: 'Notities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasisTab(theme),
          _buildDelenTab(theme),
          _buildProductenTab(theme),
          _buildBetalingTab(theme),
          _buildNabestaandenTab(theme),
          _buildContactTab(theme),
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
          DropdownButtonFormField<String>(
            value: _providerController.text.isNotEmpty ? _providerController.text : null,
            decoration: const InputDecoration(
              labelText: 'Hypotheekverstrekker',
              prefixIcon: Icon(Icons.account_balance),
            ),
            items: PropertyModel.commonMortgageProviders
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _providerController.text = value;
                _markChanged();
              }
            },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _mortgageNumberController,
            decoration: const InputDecoration(
              labelText: 'Hypotheeknummer / Dossiernummer',
              prefixIcon: Icon(Icons.numbers),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 24),

          Text('Adviseur/Tussenpersoon', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _advisorNameController,
                  decoration: const InputDecoration(labelText: 'Naam'),
                  onChanged: (_) => _markChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _advisorCompanyController,
                  decoration: const InputDecoration(labelText: 'Bedrijf'),
                  onChanged: (_) => _markChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: PhoneField(
                  controller: _advisorPhoneController,
                  labelText: 'Telefoon',
                  onChanged: _markChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: EmailField(
                  controller: _advisorEmailController,
                  labelText: 'Email',
                  onChanged: _markChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Notaris', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _notaryNameController,
                  decoration: const InputDecoration(labelText: 'Naam'),
                  onChanged: (_) => _markChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _notaryOfficeController,
                  decoration: const InputDecoration(labelText: 'Kantoor'),
                  onChanged: (_) => _markChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          PhoneField(
            controller: _notaryPhoneController,
            labelText: 'Telefoon notaris',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 24),

          Text('Datums', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: DatePickerField(
                  controller: _closingDateController,
                  labelText: 'Datum afsluiting',
                  onChanged: _markChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DatePickerField(
                  controller: _deliveryDateController,
                  labelText: 'Datum levering woning',
                  onChanged: _markChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDelenTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Een hypotheek kan uit meerdere delen bestaan (bijv. annuïtair + aflossingsvrij).',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (_parts.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 48, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Nog geen hypotheekdelen', style: TextStyle(color: Colors.grey[600])),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _addMortgagePart,
                    icon: const Icon(Icons.add),
                    label: const Text('Hypotheekdeel toevoegen'),
                  ),
                ],
              ),
            )
          else ...[
            ..._parts.map((part) => _buildPartCard(part, theme)),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _addMortgagePart,
              icon: const Icon(Icons.add),
              label: const Text('Nog een deel toevoegen'),
            ),
          ],

          if (_parts.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            _buildTotals(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildPartCard(MortgagePartModel part, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(part.type.emoji),
                      const SizedBox(width: 4),
                      Text(part.type.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit, size: 20),
                  onPressed: () => _editMortgagePart(part),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: () => _deleteMortgagePart(part.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildPartField('Oorspronkelijk', part.originalAmount != null ? '€ ${part.originalAmount!.toStringAsFixed(0)}' : '-'),
                ),
                Expanded(
                  child: _buildPartField('Openstaand', part.currentBalance != null ? '€ ${part.currentBalance!.toStringAsFixed(0)}' : '-'),
                ),
                Expanded(
                  child: _buildPartField('Maandlast', part.monthlyPayment != null ? '€ ${part.monthlyPayment!.toStringAsFixed(0)}' : '-'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildPartField('Rente', part.interestRate != null ? '${part.interestRate}%' : '-'),
                ),
                Expanded(
                  child: _buildPartField('Rentevast tot', part.fixedRateUntil ?? '-'),
                ),
                Expanded(
                  child: _buildPartField('Einddatum', part.endDate ?? '-'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildTotals(ThemeData theme) {
    final totalOriginal = _parts.fold<double>(0, (sum, p) => sum + (p.originalAmount ?? 0));
    final totalCurrent = _parts.fold<double>(0, (sum, p) => sum + (p.currentBalance ?? 0));
    final totalMonthly = _parts.fold<double>(0, (sum, p) => sum + (p.monthlyPayment ?? 0));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Totalen (automatisch berekend)', style: theme.textTheme.titleSmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildPartField('Oorspronkelijk', '€ ${totalOriginal.toStringAsFixed(0)}')),
              Expanded(child: _buildPartField('Openstaand', '€ ${totalCurrent.toStringAsFixed(0)}')),
              Expanded(child: _buildPartField('Maandlast', '€ ${totalMonthly.toStringAsFixed(0)}')),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addMortgagePart() async {
    // Simplified: show dialog to add part
    final repo = ref.read(housingRepositoryProvider);
    await repo.createMortgagePart(
      mortgageId: widget.mortgageId,
      type: MortgageType.annuity,
    );
    await _loadData();
    _markChanged();
  }

  void _editMortgagePart(MortgagePartModel part) {
    // TODO: Show edit dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bewerken wordt binnenkort toegevoegd'), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _deleteMortgagePart(String partId) async {
    final repo = ref.read(housingRepositoryProvider);
    await repo.deleteMortgagePart(partId);
    await _loadData();
    _markChanged();
  }

  Widget _buildProductenTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: const Text('Overlijdensrisicoverzekering'),
            subtitle: const Text('Dekt hypotheek bij overlijden'),
            value: _hasLifeInsurance,
            onChanged: (value) {
              setState(() => _hasLifeInsurance = value);
              _markChanged();
            },
          ),

          if (_hasLifeInsurance) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _lifeInsuranceProviderController,
              decoration: const InputDecoration(labelText: 'Verzekeraar'),
              onChanged: (_) => _markChanged(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _lifeInsurancePolicyController,
                    decoration: const InputDecoration(labelText: 'Polisnummer'),
                    onChanged: (_) => _markChanged(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AmountField(
                    controller: _lifeInsuranceAmountController,
                    labelText: 'Verzekerd bedrag',
                    onChanged: _markChanged,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 32),

          SwitchListTile(
            title: const Text('Arbeidsongeschiktheidsverzekering'),
            subtitle: const Text('WIA-hiaat verzekering'),
            value: _hasDisabilityInsurance,
            onChanged: (value) {
              setState(() => _hasDisabilityInsurance = value);
              _markChanged();
            },
          ),
          const Divider(height: 32),

          SwitchListTile(
            title: const Text('Nationale Hypotheek Garantie (NHG)'),
            value: _hasNhg,
            onChanged: (value) {
              setState(() => _hasNhg = value);
              _markChanged();
            },
          ),

          if (_hasNhg) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _nhgNumberController,
              decoration: const InputDecoration(labelText: 'NHG-nummer'),
              onChanged: (_) => _markChanged(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBetalingTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Betaling', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          TextField(
            controller: _paymentDayController,
            decoration: const InputDecoration(
              labelText: 'Betalingsdatum (dag van de maand)',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 24),

          Text('Boetes & Voorwaarden', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: PercentageField(
                  controller: _earlyRepaymentPenaltyPctController,
                  labelText: 'Boeterente vervroegd aflossen',
                  onChanged: _markChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AmountField(
                  controller: _maxYearlyRepaymentController,
                  labelText: 'Max. aflossen zonder boete/jaar',
                  onChanged: _markChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SwitchListTile(
            title: const Text('Renteherziening mogelijk'),
            value: _canRenegotiateRate,
            onChanged: (value) {
              setState(() => _canRenegotiateRate = value);
              _markChanged();
            },
          ),

          if (_canRenegotiateRate) ...[
            const SizedBox(height: 12),
            DatePickerField(
              controller: _renegotiationDateController,
              labelText: 'Vanaf datum',
              onChanged: _markChanged,
            ),
          ],
          const SizedBox(height: 16),

          TextField(
            controller: _switchConsiderationController,
            decoration: const InputDecoration(
              labelText: 'Notitie oversluiten',
              hintText: 'Bijv. vergelijk tarieven 3 maanden voor einde rentevaste periode',
            ),
            maxLines: 2,
            onChanged: (_) => _markChanged(),
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
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Wat gebeurt er met de hypotheek bij overlijden?',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          DropdownButtonFormField<String>(
            value: _deathCoverage,
            decoration: const InputDecoration(
              labelText: 'Dekking bij overlijden',
              prefixIcon: Icon(Icons.shield),
            ),
            items: const [
              DropdownMenuItem(value: 'full', child: Text('Volledig gedekt door ORV')),
              DropdownMenuItem(value: 'partial', child: Text('Gedeeltelijk gedekt')),
              DropdownMenuItem(value: 'none', child: Text('Niet gedekt - erfgenamen nemen over')),
              DropdownMenuItem(value: 'partner', child: Text('Partner neemt volledig over')),
            ],
            onChanged: (value) {
              setState(() => _deathCoverage = value);
              _markChanged();
            },
          ),

          if (_deathCoverage == 'partial') ...[
            const SizedBox(height: 16),
            AmountField(
              controller: _deathCoverageAmountController,
              labelText: 'Gedekt bedrag',
              onChanged: _markChanged,
            ),
          ],
          const SizedBox(height: 24),

          Text('Actie bij overlijden', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          TextField(
            controller: _deathContactProviderController,
            decoration: const InputDecoration(labelText: 'Contact opnemen met (verstrekker)'),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),

          PhoneField(
            controller: _deathContactPhoneController,
            labelText: 'Telefoon verstrekker',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _deathClaimInsurerController,
            decoration: const InputDecoration(labelText: 'Claim indienen bij (verzekeraar)'),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),

          PhoneField(
            controller: _deathClaimPhoneController,
            labelText: 'Telefoon verzekeraar',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _deathSpecialInstructionsController,
            decoration: const InputDecoration(
              labelText: 'Speciale afspraken',
              hintText: 'Bijv. bij overlijden kan partner 6 maanden hypotheekvrij',
            ),
            maxLines: 3,
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
          Text('Klantenservice hypotheekverstrekker', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          PhoneField(
            controller: _servicePhoneController,
            labelText: 'Telefoon',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 12),

          EmailField(
            controller: _serviceEmailController,
            labelText: 'Email',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 12),

          WebsiteField(
            controller: _serviceWebsiteController,
            labelText: 'Website',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 12),

          WebsiteField(
            controller: _portalUrlController,
            labelText: 'Mijn omgeving (inlog-URL)',
            onChanged: _markChanged,
          ),
        ],
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
          hintText: 'Overige opmerkingen over deze hypotheek...',
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
          Expanded(
            child: DropdownButtonFormField<HousingItemStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: HousingItemStatus.values.map((status) => DropdownMenuItem(
                value: status,
                child: Row(
                  children: [
                    Text(status.emoji),
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
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Opslaan'),
          ),
        ],
      ),
    );
  }
}

