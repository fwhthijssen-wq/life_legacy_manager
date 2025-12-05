// lib/modules/housing/screens/rental/rental_detail_screen.dart
// Detail scherm voor huurcontract met tabs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/date_picker_field.dart';
import '../../models/rental_contract_model.dart';
import '../../models/housing_enums.dart';
import '../../providers/housing_providers.dart';

class RentalDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final String contractId;
  final bool isNew;

  const RentalDetailScreen({
    super.key,
    required this.propertyId,
    required this.contractId,
    this.isNew = false,
  });

  @override
  ConsumerState<RentalDetailScreen> createState() => _RentalDetailScreenState();
}

class _RentalDetailScreenState extends ConsumerState<RentalDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasChanges = false;
  RentalContractModel? _contract;

  // Tab 1: Basisgegevens
  LandlordType _landlordType = LandlordType.private;
  final _landlordNameController = TextEditingController();
  final _landlordAddressController = TextEditingController();
  final _landlordPhoneController = TextEditingController();
  final _landlordEmailController = TextEditingController();
  final _landlordWebsiteController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactFunctionController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contractNumberController = TextEditingController();
  final _startDateController = TextEditingController();
  RentalContractType _contractType = RentalContractType.indefinite;
  final _endDateController = TextEditingController();

  // Tab 2: Huurprijs & Kosten
  final _baseRentController = TextEditingController();
  final _serviceCostsController = TextEditingController();
  final _paymentDayController = TextEditingController();
  bool _isDirectDebit = true;
  final _depositAmountController = TextEditingController();
  final _depositPaidDateController = TextEditingController();
  final _depositLocationController = TextEditingController();
  bool _rentIncreaseCpi = true;
  final _rentIncreasePercentageController = TextEditingController();
  final _lastIncreaseDateController = TextEditingController();

  // Tab 3: Opzegging
  final _noticePeriodTenantController = TextEditingController();
  final _noticePeriodLandlordController = TextEditingController();
  String? _cancellationMethod;
  final _cancellationAddressController = TextEditingController();
  final _minRentalTermController = TextEditingController();
  bool _isSocialHousing = false;

  // Tab 4: Inbegrepen
  bool _energyIncluded = false;
  bool _waterIncluded = false;
  bool _internetIncluded = false;
  bool _tvIncluded = false;
  bool _parkingIncluded = false;
  final _parkingCountController = TextEditingController();
  final _parkingLocationController = TextEditingController();
  bool _storageIncluded = false;
  bool _gardenIncluded = false;
  String? _gardenMaintenance;

  // Tab 5: Onderhoud
  String? _smallMaintenance;
  String? _largeMaintenance;
  String? _painting;
  String? _cvMaintenance;
  final _repairReportPhoneController = TextEditingController();
  final _repairReportEmailController = TextEditingController();
  final _repairReportUrlController = TextEditingController();

  // Tab 6: Nabestaanden
  String? _deathAction;
  final _deathInstructionsController = TextEditingController();
  final _depositReturnInstructionsController = TextEditingController();

  // Tab 7: Notities
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
    _landlordNameController.dispose();
    _landlordAddressController.dispose();
    _landlordPhoneController.dispose();
    _landlordEmailController.dispose();
    _landlordWebsiteController.dispose();
    _contactNameController.dispose();
    _contactFunctionController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _contractNumberController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _baseRentController.dispose();
    _serviceCostsController.dispose();
    _paymentDayController.dispose();
    _depositAmountController.dispose();
    _depositPaidDateController.dispose();
    _depositLocationController.dispose();
    _rentIncreasePercentageController.dispose();
    _lastIncreaseDateController.dispose();
    _noticePeriodTenantController.dispose();
    _noticePeriodLandlordController.dispose();
    _cancellationAddressController.dispose();
    _minRentalTermController.dispose();
    _parkingCountController.dispose();
    _parkingLocationController.dispose();
    _repairReportPhoneController.dispose();
    _repairReportEmailController.dispose();
    _repairReportUrlController.dispose();
    _deathInstructionsController.dispose();
    _depositReturnInstructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(housingRepositoryProvider);
    final contract = await repo.getRentalContract(widget.contractId);

    if (contract != null) {
      _contract = contract;
      _populateFields(contract);
    }
    setState(() => _isLoading = false);
  }

  void _populateFields(RentalContractModel c) {
    _landlordType = c.landlordType;
    _landlordNameController.text = c.landlordName ?? '';
    _landlordAddressController.text = c.landlordAddress ?? '';
    _landlordPhoneController.text = c.landlordPhone ?? '';
    _landlordEmailController.text = c.landlordEmail ?? '';
    _landlordWebsiteController.text = c.landlordWebsite ?? '';
    _contactNameController.text = c.contactName ?? '';
    _contactFunctionController.text = c.contactFunction ?? '';
    _contactPhoneController.text = c.contactPhone ?? '';
    _contactEmailController.text = c.contactEmail ?? '';
    _contractNumberController.text = c.contractNumber ?? '';
    _startDateController.text = c.startDate ?? '';
    _contractType = c.contractType;
    _endDateController.text = c.endDate ?? '';

    _baseRentController.text = c.baseRent?.toString() ?? '';
    _serviceCostsController.text = c.serviceCosts?.toString() ?? '';
    _paymentDayController.text = c.paymentDay?.toString() ?? '';
    _isDirectDebit = c.isDirectDebit;
    _depositAmountController.text = c.depositAmount?.toString() ?? '';
    _depositPaidDateController.text = c.depositPaidDate ?? '';
    _depositLocationController.text = c.depositLocation ?? '';
    _rentIncreaseCpi = c.rentIncreaseCpi;
    _rentIncreasePercentageController.text = c.rentIncreasePercentage?.toString() ?? '';
    _lastIncreaseDateController.text = c.lastIncreaseDate ?? '';

    _noticePeriodTenantController.text = c.noticePeriodTenant?.toString() ?? '';
    _noticePeriodLandlordController.text = c.noticePeriodLandlord?.toString() ?? '';
    _cancellationMethod = c.cancellationMethod;
    _cancellationAddressController.text = c.cancellationAddress ?? '';
    _minRentalTermController.text = c.minRentalTerm?.toString() ?? '';
    _isSocialHousing = c.isSocialHousing;

    _energyIncluded = c.energyIncluded;
    _waterIncluded = c.waterIncluded;
    _internetIncluded = c.internetIncluded;
    _tvIncluded = c.tvIncluded;
    _parkingIncluded = c.parkingIncluded;
    _parkingCountController.text = c.parkingCount?.toString() ?? '';
    _parkingLocationController.text = c.parkingLocation ?? '';
    _storageIncluded = c.storageIncluded;
    _gardenIncluded = c.gardenIncluded;
    _gardenMaintenance = c.gardenMaintenance;

    _smallMaintenance = c.smallMaintenance;
    _largeMaintenance = c.largeMaintenance;
    _painting = c.painting;
    _cvMaintenance = c.cvMaintenance;
    _repairReportPhoneController.text = c.repairReportPhone ?? '';
    _repairReportEmailController.text = c.repairReportEmail ?? '';
    _repairReportUrlController.text = c.repairReportUrl ?? '';

    _deathAction = c.deathAction;
    _deathInstructionsController.text = c.deathInstructions ?? '';
    _depositReturnInstructionsController.text = c.depositReturnInstructions ?? '';

    _notesController.text = c.notes ?? '';
    _status = c.status;
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _save() async {
    if (_contract == null) return;

    final repo = ref.read(housingRepositoryProvider);
    final updated = RentalContractModel(
      id: _contract!.id,
      propertyId: _contract!.propertyId,
      landlordType: _landlordType,
      landlordName: _landlordNameController.text.isNotEmpty ? _landlordNameController.text : null,
      landlordAddress: _landlordAddressController.text.isNotEmpty ? _landlordAddressController.text : null,
      landlordPhone: _landlordPhoneController.text.isNotEmpty ? _landlordPhoneController.text : null,
      landlordEmail: _landlordEmailController.text.isNotEmpty ? _landlordEmailController.text : null,
      landlordWebsite: _landlordWebsiteController.text.isNotEmpty ? _landlordWebsiteController.text : null,
      contactName: _contactNameController.text.isNotEmpty ? _contactNameController.text : null,
      contactFunction: _contactFunctionController.text.isNotEmpty ? _contactFunctionController.text : null,
      contactPhone: _contactPhoneController.text.isNotEmpty ? _contactPhoneController.text : null,
      contactEmail: _contactEmailController.text.isNotEmpty ? _contactEmailController.text : null,
      contractNumber: _contractNumberController.text.isNotEmpty ? _contractNumberController.text : null,
      startDate: _startDateController.text.isNotEmpty ? _startDateController.text : null,
      contractType: _contractType,
      endDate: _endDateController.text.isNotEmpty ? _endDateController.text : null,
      baseRent: double.tryParse(_baseRentController.text),
      serviceCosts: double.tryParse(_serviceCostsController.text),
      paymentDay: int.tryParse(_paymentDayController.text),
      isDirectDebit: _isDirectDebit,
      depositAmount: double.tryParse(_depositAmountController.text),
      depositPaidDate: _depositPaidDateController.text.isNotEmpty ? _depositPaidDateController.text : null,
      depositLocation: _depositLocationController.text.isNotEmpty ? _depositLocationController.text : null,
      rentIncreaseCpi: _rentIncreaseCpi,
      rentIncreasePercentage: double.tryParse(_rentIncreasePercentageController.text),
      lastIncreaseDate: _lastIncreaseDateController.text.isNotEmpty ? _lastIncreaseDateController.text : null,
      noticePeriodTenant: int.tryParse(_noticePeriodTenantController.text),
      noticePeriodLandlord: int.tryParse(_noticePeriodLandlordController.text),
      cancellationMethod: _cancellationMethod,
      cancellationAddress: _cancellationAddressController.text.isNotEmpty ? _cancellationAddressController.text : null,
      minRentalTerm: int.tryParse(_minRentalTermController.text),
      isSocialHousing: _isSocialHousing,
      energyIncluded: _energyIncluded,
      waterIncluded: _waterIncluded,
      internetIncluded: _internetIncluded,
      tvIncluded: _tvIncluded,
      parkingIncluded: _parkingIncluded,
      parkingCount: int.tryParse(_parkingCountController.text),
      parkingLocation: _parkingLocationController.text.isNotEmpty ? _parkingLocationController.text : null,
      storageIncluded: _storageIncluded,
      gardenIncluded: _gardenIncluded,
      gardenMaintenance: _gardenMaintenance,
      smallMaintenance: _smallMaintenance,
      largeMaintenance: _largeMaintenance,
      painting: _painting,
      cvMaintenance: _cvMaintenance,
      repairReportPhone: _repairReportPhoneController.text.isNotEmpty ? _repairReportPhoneController.text : null,
      repairReportEmail: _repairReportEmailController.text.isNotEmpty ? _repairReportEmailController.text : null,
      repairReportUrl: _repairReportUrlController.text.isNotEmpty ? _repairReportUrlController.text : null,
      deathAction: _deathAction,
      deathInstructions: _deathInstructionsController.text.isNotEmpty ? _deathInstructionsController.text : null,
      depositReturnInstructions: _depositReturnInstructionsController.text.isNotEmpty ? _depositReturnInstructionsController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      status: _status,
      createdAt: _contract!.createdAt,
      updatedAt: DateTime.now(),
    );

    await repo.updateRentalContract(updated);
    setState(() {
      _contract = updated;
      _hasChanges = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Huurcontract opgeslagen'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Huurcontract verwijderen?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuleren')),
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
      await repo.deleteRentalContract(widget.contractId);
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
        title: Text(_landlordNameController.text.isNotEmpty ? _landlordNameController.text : 'Huurcontract'),
        actions: [
          IconButton(icon: const Icon(Icons.check), onPressed: _save, tooltip: 'Opslaan'),
          PopupMenuButton<String>(
            onSelected: (action) { if (action == 'delete') _delete(); },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 12), Text('Verwijderen', style: TextStyle(color: Colors.red))])),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Verhuurder'),
            Tab(text: 'Huurprijs'),
            Tab(text: 'Opzegging'),
            Tab(text: 'Inbegrepen'),
            Tab(text: 'Onderhoud'),
            Tab(text: 'Nabestaanden'),
            Tab(text: 'Notities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVerhuurderTab(theme),
          _buildHuurprijsTab(theme),
          _buildOpzeggingTab(theme),
          _buildInbegrepenTab(theme),
          _buildOnderhoudTab(theme),
          _buildNabestaandenTab(theme),
          _buildNotitiesTab(theme),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildVerhuurderTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<LandlordType>(
            value: _landlordType,
            decoration: const InputDecoration(labelText: 'Type verhuurder'),
            items: LandlordType.values.map((t) => DropdownMenuItem(value: t, child: Row(children: [Text(t.emoji), const SizedBox(width: 8), Text(t.label)]))).toList(),
            onChanged: (v) { if (v != null) { setState(() => _landlordType = v); _markChanged(); } },
          ),
          const SizedBox(height: 16),

          TextField(controller: _landlordNameController, decoration: const InputDecoration(labelText: 'Naam verhuurder / organisatie'), onChanged: (_) => _markChanged()),
          const SizedBox(height: 12),
          TextField(controller: _landlordAddressController, decoration: const InputDecoration(labelText: 'Adres verhuurder'), onChanged: (_) => _markChanged()),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: PhoneField(controller: _landlordPhoneController, labelText: 'Telefoon', onChanged: _markChanged)),
            const SizedBox(width: 12),
            Expanded(child: EmailField(controller: _landlordEmailController, labelText: 'Email', onChanged: _markChanged)),
          ]),
          const SizedBox(height: 12),
          WebsiteField(controller: _landlordWebsiteController, labelText: 'Website', onChanged: _markChanged),
          const SizedBox(height: 24),

          if (_landlordType != LandlordType.private) ...[
            Text('Contactpersoon', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _contactNameController, decoration: const InputDecoration(labelText: 'Naam'), onChanged: (_) => _markChanged())),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _contactFunctionController, decoration: const InputDecoration(labelText: 'Functie'), onChanged: (_) => _markChanged())),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: PhoneField(controller: _contactPhoneController, labelText: 'Telefoon', onChanged: _markChanged)),
              const SizedBox(width: 12),
              Expanded(child: EmailField(controller: _contactEmailController, labelText: 'Email', onChanged: _markChanged)),
            ]),
            const SizedBox(height: 24),
          ],

          Text('Contract', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          TextField(controller: _contractNumberController, decoration: const InputDecoration(labelText: 'Huurcontract nummer'), onChanged: (_) => _markChanged()),
          const SizedBox(height: 12),
          
          DropdownButtonFormField<RentalContractType>(
            value: _contractType,
            decoration: const InputDecoration(labelText: 'Type contract'),
            items: RentalContractType.values.map((t) => DropdownMenuItem(value: t, child: Row(children: [Text(t.emoji), const SizedBox(width: 8), Text(t.label)]))).toList(),
            onChanged: (v) { if (v != null) { setState(() => _contractType = v); _markChanged(); } },
          ),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: DatePickerField(controller: _startDateController, labelText: 'Ingangsdatum', onChanged: _markChanged)),
            const SizedBox(width: 12),
            if (_contractType == RentalContractType.fixedTerm)
              Expanded(child: DatePickerField(controller: _endDateController, labelText: 'Einddatum', onChanged: _markChanged)),
          ]),
        ],
      ),
    );
  }

  Widget _buildHuurprijsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: AmountField(controller: _baseRentController, labelText: 'Kale huur/maand', onChanged: _markChanged)),
            const SizedBox(width: 12),
            Expanded(child: AmountField(controller: _serviceCostsController, labelText: 'Servicekosten/maand', onChanged: _markChanged)),
          ]),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Totale maandlast:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('€ ${((double.tryParse(_baseRentController.text) ?? 0) + (double.tryParse(_serviceCostsController.text) ?? 0)).toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Betaling', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          TextField(controller: _paymentDayController, decoration: const InputDecoration(labelText: 'Betalingsdatum (dag)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged()),
          const SizedBox(height: 12),
          SwitchListTile(title: const Text('Automatische incasso'), value: _isDirectDebit, onChanged: (v) { setState(() => _isDirectDebit = v); _markChanged(); }),
          const SizedBox(height: 24),

          Text('Borg / Waarborgsom', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: AmountField(controller: _depositAmountController, labelText: 'Borgbedrag', onChanged: _markChanged)),
            const SizedBox(width: 12),
            Expanded(child: DatePickerField(controller: _depositPaidDateController, labelText: 'Betaald op', onChanged: _markChanged)),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _depositLocationController, decoration: const InputDecoration(labelText: 'Gestort bij', hintText: 'Verhuurder / Derdengeldrekening'), onChanged: (_) => _markChanged()),
          const SizedBox(height: 24),

          Text('Jaarlijkse huurverhoging', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          SwitchListTile(title: const Text('Gekoppeld aan inflatie (CPI)'), value: _rentIncreaseCpi, onChanged: (v) { setState(() => _rentIncreaseCpi = v); _markChanged(); }),

          if (!_rentIncreaseCpi)
            PercentageField(controller: _rentIncreasePercentageController, labelText: 'Vast percentage', onChanged: _markChanged),
          const SizedBox(height: 12),
          DatePickerField(controller: _lastIncreaseDateController, labelText: 'Laatste verhoging', onChanged: _markChanged),
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
          Row(children: [
            Expanded(child: TextField(controller: _noticePeriodTenantController, decoration: const InputDecoration(labelText: 'Opzegtermijn huurder (maanden)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _noticePeriodLandlordController, decoration: const InputDecoration(labelText: 'Opzegtermijn verhuurder (maanden)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
          ]),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _cancellationMethod,
            decoration: const InputDecoration(labelText: 'Hoe opzeggen?'),
            items: const [
              DropdownMenuItem(value: 'registered_mail', child: Text('Aangetekend per post')),
              DropdownMenuItem(value: 'email', child: Text('Per email')),
              DropdownMenuItem(value: 'portal', child: Text('Via online portaal')),
            ],
            onChanged: (v) { setState(() => _cancellationMethod = v); _markChanged(); },
          ),
          const SizedBox(height: 12),

          TextField(controller: _cancellationAddressController, decoration: const InputDecoration(labelText: 'Opzegadres'), onChanged: (_) => _markChanged()),
          const SizedBox(height: 12),

          TextField(controller: _minRentalTermController, decoration: const InputDecoration(labelText: 'Minimale huurtermijn (maanden)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged()),
          const SizedBox(height: 16),

          SwitchListTile(title: const Text('Sociale huur (gereguleerd)'), subtitle: const Text('Heeft huurbescherming'), value: _isSocialHousing, onChanged: (v) { setState(() => _isSocialHousing = v); _markChanged(); }),
        ],
      ),
    );
  }

  Widget _buildInbegrepenTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Wat is inbegrepen in de huur?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          SwitchListTile(title: const Text('Energie (gas/elektra)'), value: _energyIncluded, onChanged: (v) { setState(() => _energyIncluded = v); _markChanged(); }),
          SwitchListTile(title: const Text('Water'), value: _waterIncluded, onChanged: (v) { setState(() => _waterIncluded = v); _markChanged(); }),
          SwitchListTile(title: const Text('Internet'), value: _internetIncluded, onChanged: (v) { setState(() => _internetIncluded = v); _markChanged(); }),
          SwitchListTile(title: const Text('TV-pakket'), value: _tvIncluded, onChanged: (v) { setState(() => _tvIncluded = v); _markChanged(); }),
          SwitchListTile(title: const Text('Berging'), value: _storageIncluded, onChanged: (v) { setState(() => _storageIncluded = v); _markChanged(); }),

          SwitchListTile(title: const Text('Parkeerplaats'), value: _parkingIncluded, onChanged: (v) { setState(() => _parkingIncluded = v); _markChanged(); }),
          if (_parkingIncluded) ...[
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Row(children: [
                Expanded(child: TextField(controller: _parkingCountController, decoration: const InputDecoration(labelText: 'Aantal'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
                const SizedBox(width: 12),
                Expanded(child: TextField(controller: _parkingLocationController, decoration: const InputDecoration(labelText: 'Locatie'), onChanged: (_) => _markChanged())),
              ]),
            ),
          ],

          SwitchListTile(title: const Text('Tuin'), value: _gardenIncluded, onChanged: (v) { setState(() => _gardenIncluded = v); _markChanged(); }),
          if (_gardenIncluded)
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: DropdownButtonFormField<String>(
                value: _gardenMaintenance,
                decoration: const InputDecoration(labelText: 'Tuinonderhoud door'),
                items: const [
                  DropdownMenuItem(value: 'tenant', child: Text('Huurder')),
                  DropdownMenuItem(value: 'landlord', child: Text('Verhuurder')),
                ],
                onChanged: (v) { setState(() => _gardenMaintenance = v); _markChanged(); },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOnderhoudTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verantwoordelijkheden', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          _buildMaintenanceDropdown('Klein onderhoud', _smallMaintenance, (v) => setState(() { _smallMaintenance = v; _markChanged(); })),
          const SizedBox(height: 12),
          _buildMaintenanceDropdown('Groot onderhoud', _largeMaintenance, (v) => setState(() { _largeMaintenance = v; _markChanged(); })),
          const SizedBox(height: 12),
          _buildMaintenanceDropdown('Schilderwerk', _painting, (v) => setState(() { _painting = v; _markChanged(); })),
          const SizedBox(height: 12),
          _buildMaintenanceDropdown('CV-onderhoud', _cvMaintenance, (v) => setState(() { _cvMaintenance = v; _markChanged(); })),
          const SizedBox(height: 24),

          Text('Storing/reparatie melden', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          PhoneField(controller: _repairReportPhoneController, labelText: 'Telefoon', onChanged: _markChanged),
          const SizedBox(height: 12),
          EmailField(controller: _repairReportEmailController, labelText: 'Email', onChanged: _markChanged),
          const SizedBox(height: 12),
          WebsiteField(controller: _repairReportUrlController, labelText: 'Online melden', onChanged: _markChanged),
        ],
      ),
    );
  }

  Widget _buildMaintenanceDropdown(String label, String? value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: const [
        DropdownMenuItem(value: 'tenant', child: Text('Door huurder')),
        DropdownMenuItem(value: 'landlord', child: Text('Door verhuurder')),
      ],
      onChanged: onChanged,
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
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Icon(Icons.info_outline, color: Colors.blue[700]),
              const SizedBox(width: 12),
              const Expanded(child: Text('Wat gebeurt er met het huurcontract bij overlijden?')),
            ]),
          ),
          const SizedBox(height: 24),

          DropdownButtonFormField<String>(
            value: _deathAction,
            decoration: const InputDecoration(labelText: 'Bij overlijden huurder'),
            items: const [
              DropdownMenuItem(value: 'transfer', child: Text('Contract gaat over op partner/medebewoner')),
              DropdownMenuItem(value: 'cancel', child: Text('Contract moet worden opgezegd')),
              DropdownMenuItem(value: 'notify', child: Text('Verhuurder moet worden geïnformeerd')),
            ],
            onChanged: (v) { setState(() => _deathAction = v); _markChanged(); },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _deathInstructionsController,
            decoration: const InputDecoration(labelText: 'Opzegprocedure / instructies', hintText: 'Contactgegevens, opzegtermijn, etc.'),
            maxLines: 3,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 24),

          Text('Borgsom terugvraag', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          TextField(
            controller: _depositReturnInstructionsController,
            decoration: const InputDecoration(labelText: 'Instructies voor borg terug', hintText: 'Bijv. na oplevering, binnen 2 maanden terug'),
            maxLines: 3,
            onChanged: (_) => _markChanged(),
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
        decoration: const InputDecoration(labelText: 'Notities', alignLabelWithHint: true, border: OutlineInputBorder()),
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
      decoration: BoxDecoration(color: theme.colorScheme.surface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, -2))]),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<HousingItemStatus>(
              value: _status,
              decoration: const InputDecoration(labelText: 'Status', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              items: HousingItemStatus.values.map((s) => DropdownMenuItem(value: s, child: Row(children: [Text(s.emoji), const SizedBox(width: 8), Text(s.label)]))).toList(),
              onChanged: (v) { if (v != null) { setState(() => _status = v); _markChanged(); } },
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.check), label: const Text('Opslaan')),
        ],
      ),
    );
  }
}

