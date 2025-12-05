// lib/modules/housing/screens/energy/energy_detail_screen.dart
// Detail scherm voor energiecontract met tabs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/date_picker_field.dart';
import '../../models/energy_contract_model.dart';
import '../../models/housing_enums.dart';
import '../../providers/housing_providers.dart';

class EnergyDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final String contractId;
  final bool isNew;

  const EnergyDetailScreen({
    super.key,
    required this.propertyId,
    required this.contractId,
    this.isNew = false,
  });

  @override
  ConsumerState<EnergyDetailScreen> createState() => _EnergyDetailScreenState();
}

class _EnergyDetailScreenState extends ConsumerState<EnergyDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasChanges = false;
  EnergyContractModel? _contract;

  // Tab 1: Contract Algemeen
  EnergyType _energyType = EnergyType.combined;
  final _providerController = TextEditingController();
  final _customerNumberController = TextEditingController();
  final _contractNumberController = TextEditingController();
  final _eanElectricityController = TextEditingController();
  final _eanGasController = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  EnergyContractType _contractType = EnergyContractType.variable;

  // Tab 2: Tarieven
  final _electricityRateNormalController = TextEditingController();
  final _electricityRateLowController = TextEditingController();
  final _electricityFeedInController = TextEditingController();
  final _electricityFixedController = TextEditingController();
  final _gasRateController = TextEditingController();
  final _gasFixedController = TextEditingController();
  final _yearlyElectricityController = TextEditingController();
  final _yearlyGasController = TextEditingController();
  final _monthlyAdvanceController = TextEditingController();

  // Tab 3: Meterstanden
  bool _hasSmartMeter = true;
  final _meterLocationElectricityController = TextEditingController();
  final _meterLocationGasController = TextEditingController();
  final _lastMeterNormalController = TextEditingController();
  final _lastMeterLowController = TextEditingController();
  final _lastMeterGasController = TextEditingController();

  // Tab 4: Opzegging
  final _noticePeriodController = TextEditingController();
  final _cancellationEmailController = TextEditingController();
  final _cancellationPhoneController = TextEditingController();
  final _earlyCancellationPenaltyController = TextEditingController();

  // Tab 5: Voor nabestaanden
  String? _deathAction;
  final _deathInstructionsController = TextEditingController();

  // Tab 6: Contact
  final _servicePhoneController = TextEditingController();
  final _serviceEmailController = TextEditingController();
  final _serviceWebsiteController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _gridOperatorController = TextEditingController();
  final _gridOperatorPhoneController = TextEditingController();

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
    _providerController.dispose();
    _customerNumberController.dispose();
    _contractNumberController.dispose();
    _eanElectricityController.dispose();
    _eanGasController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _electricityRateNormalController.dispose();
    _electricityRateLowController.dispose();
    _electricityFeedInController.dispose();
    _electricityFixedController.dispose();
    _gasRateController.dispose();
    _gasFixedController.dispose();
    _yearlyElectricityController.dispose();
    _yearlyGasController.dispose();
    _monthlyAdvanceController.dispose();
    _meterLocationElectricityController.dispose();
    _meterLocationGasController.dispose();
    _lastMeterNormalController.dispose();
    _lastMeterLowController.dispose();
    _lastMeterGasController.dispose();
    _noticePeriodController.dispose();
    _cancellationEmailController.dispose();
    _cancellationPhoneController.dispose();
    _earlyCancellationPenaltyController.dispose();
    _deathInstructionsController.dispose();
    _servicePhoneController.dispose();
    _serviceEmailController.dispose();
    _serviceWebsiteController.dispose();
    _emergencyPhoneController.dispose();
    _gridOperatorController.dispose();
    _gridOperatorPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(housingRepositoryProvider);
    final contract = await repo.getEnergyContract(widget.contractId);

    if (contract != null) {
      _contract = contract;
      _populateFields(contract);
    }
    setState(() => _isLoading = false);
  }

  void _populateFields(EnergyContractModel c) {
    _energyType = c.energyType;
    _providerController.text = c.provider ?? '';
    _customerNumberController.text = c.customerNumber ?? '';
    _contractNumberController.text = c.contractNumber ?? '';
    _eanElectricityController.text = c.eanElectricity ?? '';
    _eanGasController.text = c.eanGas ?? '';
    _startDateController.text = c.startDate ?? '';
    _endDateController.text = c.endDate ?? '';
    _contractType = c.contractType;

    _electricityRateNormalController.text = c.electricityRateNormal?.toString() ?? '';
    _electricityRateLowController.text = c.electricityRateLow?.toString() ?? '';
    _electricityFeedInController.text = c.electricityFeedInRate?.toString() ?? '';
    _electricityFixedController.text = c.electricityFixedCost?.toString() ?? '';
    _gasRateController.text = c.gasRate?.toString() ?? '';
    _gasFixedController.text = c.gasFixedCost?.toString() ?? '';
    _yearlyElectricityController.text = c.estimatedYearlyElectricity?.toString() ?? '';
    _yearlyGasController.text = c.estimatedYearlyGas?.toString() ?? '';
    _monthlyAdvanceController.text = c.monthlyAdvance?.toString() ?? '';

    _hasSmartMeter = c.hasSmartMeter;
    _meterLocationElectricityController.text = c.meterLocationElectricity ?? '';
    _meterLocationGasController.text = c.meterLocationGas ?? '';
    _lastMeterNormalController.text = c.lastMeterNormal?.toString() ?? '';
    _lastMeterLowController.text = c.lastMeterLow?.toString() ?? '';
    _lastMeterGasController.text = c.lastMeterGas?.toString() ?? '';

    _noticePeriodController.text = c.noticePeriodMonths?.toString() ?? '';
    _cancellationEmailController.text = c.cancellationEmail ?? '';
    _cancellationPhoneController.text = c.cancellationPhone ?? '';
    _earlyCancellationPenaltyController.text = c.earlyCancellationPenalty?.toString() ?? '';

    _deathAction = c.deathAction;
    _deathInstructionsController.text = c.deathInstructions ?? '';

    _servicePhoneController.text = c.servicePhone ?? '';
    _serviceEmailController.text = c.serviceEmail ?? '';
    _serviceWebsiteController.text = c.serviceWebsite ?? '';
    _emergencyPhoneController.text = c.emergencyPhone ?? '';
    _gridOperatorController.text = c.gridOperator ?? '';
    _gridOperatorPhoneController.text = c.gridOperatorPhone ?? '';

    _notesController.text = c.notes ?? '';
    _status = c.status;
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _save() async {
    if (_contract == null) return;

    final repo = ref.read(housingRepositoryProvider);
    final updated = EnergyContractModel(
      id: _contract!.id,
      propertyId: _contract!.propertyId,
      energyType: _energyType,
      provider: _providerController.text.isNotEmpty ? _providerController.text : null,
      customerNumber: _customerNumberController.text.isNotEmpty ? _customerNumberController.text : null,
      contractNumber: _contractNumberController.text.isNotEmpty ? _contractNumberController.text : null,
      eanElectricity: _eanElectricityController.text.isNotEmpty ? _eanElectricityController.text : null,
      eanGas: _eanGasController.text.isNotEmpty ? _eanGasController.text : null,
      startDate: _startDateController.text.isNotEmpty ? _startDateController.text : null,
      endDate: _endDateController.text.isNotEmpty ? _endDateController.text : null,
      contractType: _contractType,
      electricityRateNormal: double.tryParse(_electricityRateNormalController.text),
      electricityRateLow: double.tryParse(_electricityRateLowController.text),
      electricityFeedInRate: double.tryParse(_electricityFeedInController.text),
      electricityFixedCost: double.tryParse(_electricityFixedController.text),
      gasRate: double.tryParse(_gasRateController.text),
      gasFixedCost: double.tryParse(_gasFixedController.text),
      estimatedYearlyElectricity: int.tryParse(_yearlyElectricityController.text),
      estimatedYearlyGas: int.tryParse(_yearlyGasController.text),
      monthlyAdvance: double.tryParse(_monthlyAdvanceController.text),
      hasSmartMeter: _hasSmartMeter,
      meterLocationElectricity: _meterLocationElectricityController.text.isNotEmpty ? _meterLocationElectricityController.text : null,
      meterLocationGas: _meterLocationGasController.text.isNotEmpty ? _meterLocationGasController.text : null,
      lastMeterNormal: int.tryParse(_lastMeterNormalController.text),
      lastMeterLow: int.tryParse(_lastMeterLowController.text),
      lastMeterGas: int.tryParse(_lastMeterGasController.text),
      noticePeriodMonths: int.tryParse(_noticePeriodController.text),
      cancellationEmail: _cancellationEmailController.text.isNotEmpty ? _cancellationEmailController.text : null,
      cancellationPhone: _cancellationPhoneController.text.isNotEmpty ? _cancellationPhoneController.text : null,
      earlyCancellationPenalty: double.tryParse(_earlyCancellationPenaltyController.text),
      deathAction: _deathAction,
      deathInstructions: _deathInstructionsController.text.isNotEmpty ? _deathInstructionsController.text : null,
      servicePhone: _servicePhoneController.text.isNotEmpty ? _servicePhoneController.text : null,
      serviceEmail: _serviceEmailController.text.isNotEmpty ? _serviceEmailController.text : null,
      serviceWebsite: _serviceWebsiteController.text.isNotEmpty ? _serviceWebsiteController.text : null,
      emergencyPhone: _emergencyPhoneController.text.isNotEmpty ? _emergencyPhoneController.text : null,
      gridOperator: _gridOperatorController.text.isNotEmpty ? _gridOperatorController.text : null,
      gridOperatorPhone: _gridOperatorPhoneController.text.isNotEmpty ? _gridOperatorPhoneController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      status: _status,
      createdAt: _contract!.createdAt,
      updatedAt: DateTime.now(),
    );

    await repo.updateEnergyContract(updated);
    setState(() {
      _contract = updated;
      _hasChanges = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Energiecontract opgeslagen'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contract verwijderen?'),
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
      await repo.deleteEnergyContract(widget.contractId);
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
        title: Text(_providerController.text.isNotEmpty ? _providerController.text : 'Energiecontract'),
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
            Tab(text: 'Contract'),
            Tab(text: 'Tarieven'),
            Tab(text: 'Meters'),
            Tab(text: 'Opzegging'),
            Tab(text: 'Nabestaanden'),
            Tab(text: 'Contact'),
            Tab(text: 'Notities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildContractTab(theme),
          _buildTarievenTab(theme),
          _buildMetersTab(theme),
          _buildOpzeggingTab(theme),
          _buildNabestaandenTab(theme),
          _buildContactTab(theme),
          _buildNotitiesTab(theme),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildContractTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<EnergyType>(
            value: _energyType,
            decoration: const InputDecoration(labelText: 'Type energie', prefixIcon: Icon(Icons.bolt)),
            items: EnergyType.values.map((t) => DropdownMenuItem(value: t, child: Row(children: [Text(t.emoji), const SizedBox(width: 8), Text(t.label)]))).toList(),
            onChanged: (v) { if (v != null) { setState(() => _energyType = v); _markChanged(); } },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _providerController.text.isNotEmpty ? _providerController.text : null,
            decoration: const InputDecoration(labelText: 'Energieleverancier', prefixIcon: Icon(Icons.business)),
            items: EnergyContractModel.commonProviders.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            onChanged: (v) { if (v != null) { _providerController.text = v; _markChanged(); } },
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: TextField(controller: _customerNumberController, decoration: const InputDecoration(labelText: 'Klantnummer'), onChanged: (_) => _markChanged())),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _contractNumberController, decoration: const InputDecoration(labelText: 'Contractnummer'), onChanged: (_) => _markChanged())),
          ]),
          const SizedBox(height: 16),

          TextField(controller: _eanElectricityController, decoration: const InputDecoration(labelText: 'EAN-code elektriciteit (18 cijfers)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged()),
          const SizedBox(height: 12),

          if (_energyType == EnergyType.gas || _energyType == EnergyType.combined)
            TextField(controller: _eanGasController, decoration: const InputDecoration(labelText: 'EAN-code gas (18 cijfers)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged()),
          const SizedBox(height: 16),

          DropdownButtonFormField<EnergyContractType>(
            value: _contractType,
            decoration: const InputDecoration(labelText: 'Type contract'),
            items: EnergyContractType.values.map((t) => DropdownMenuItem(value: t, child: Row(children: [Text(t.emoji), const SizedBox(width: 8), Text(t.label)]))).toList(),
            onChanged: (v) { if (v != null) { setState(() => _contractType = v); _markChanged(); } },
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: DatePickerField(controller: _startDateController, labelText: 'Ingangsdatum', onChanged: _markChanged)),
            const SizedBox(width: 12),
            Expanded(child: DatePickerField(controller: _endDateController, labelText: 'Einddatum (leeg = onbepaald)', onChanged: _markChanged)),
          ]),
        ],
      ),
    );
  }

  Widget _buildTarievenTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_energyType == EnergyType.electricity || _energyType == EnergyType.combined) ...[
            Text('Elektriciteit', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _electricityRateNormalController, decoration: const InputDecoration(labelText: 'Tarief normaal (€/kWh)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _electricityRateLowController, decoration: const InputDecoration(labelText: 'Tarief dal (€/kWh)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _electricityFeedInController, decoration: const InputDecoration(labelText: 'Teruglevertarief (€/kWh)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
              const SizedBox(width: 12),
              Expanded(child: AmountField(controller: _electricityFixedController, labelText: 'Vastrecht/maand', onChanged: _markChanged)),
            ]),
            const SizedBox(height: 24),
          ],

          if (_energyType == EnergyType.gas || _energyType == EnergyType.combined) ...[
            Text('Gas', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _gasRateController, decoration: const InputDecoration(labelText: 'Tarief gas (€/m³)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
              const SizedBox(width: 12),
              Expanded(child: AmountField(controller: _gasFixedController, labelText: 'Vastrecht/maand', onChanged: _markChanged)),
            ]),
            const SizedBox(height: 24),
          ],

          Text('Verbruik', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(controller: _yearlyElectricityController, decoration: const InputDecoration(labelText: 'Geschat jaarverbruik (kWh)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _yearlyGasController, decoration: const InputDecoration(labelText: 'Geschat jaarverbruik (m³)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
          ]),
          const SizedBox(height: 16),

          AmountField(controller: _monthlyAdvanceController, labelText: 'Maandelijks voorschot', onChanged: _markChanged),
        ],
      ),
    );
  }

  Widget _buildMetersTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(title: const Text('Slimme meter'), value: _hasSmartMeter, onChanged: (v) { setState(() => _hasSmartMeter = v); _markChanged(); }),
          const SizedBox(height: 16),

          TextField(controller: _meterLocationElectricityController, decoration: const InputDecoration(labelText: 'Locatie elektriciteitsmeter', hintText: 'Bijv. meterkast in gang'), onChanged: (_) => _markChanged()),
          const SizedBox(height: 12),
          TextField(controller: _meterLocationGasController, decoration: const InputDecoration(labelText: 'Locatie gasmeter'), onChanged: (_) => _markChanged()),
          const SizedBox(height: 24),

          Text('Laatste meterstanden', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: TextField(controller: _lastMeterNormalController, decoration: const InputDecoration(labelText: 'Normaal (181) kWh'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _lastMeterLowController, decoration: const InputDecoration(labelText: 'Dal (182) kWh'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
          ]),
          const SizedBox(height: 12),
          TextField(controller: _lastMeterGasController, decoration: const InputDecoration(labelText: 'Gas (m³)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged()),
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
          TextField(controller: _noticePeriodController, decoration: const InputDecoration(labelText: 'Opzegtermijn (maanden)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged()),
          const SizedBox(height: 16),

          EmailField(controller: _cancellationEmailController, labelText: 'Opzeg email', onChanged: _markChanged),
          const SizedBox(height: 12),
          PhoneField(controller: _cancellationPhoneController, labelText: 'Opzeg telefoon', onChanged: _markChanged),
          const SizedBox(height: 16),

          AmountField(controller: _earlyCancellationPenaltyController, labelText: 'Boete bij vervroegd opzeggen', onChanged: _markChanged),
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
          DropdownButtonFormField<String>(
            value: _deathAction,
            decoration: const InputDecoration(labelText: 'Wat gebeurt bij overlijden?'),
            items: const [
              DropdownMenuItem(value: 'continue', child: Text('Contract loopt door')),
              DropdownMenuItem(value: 'cancel', child: Text('Contract opzeggen')),
              DropdownMenuItem(value: 'buyer', child: Text('Nieuwe bewoner regelt zelf')),
            ],
            onChanged: (v) { setState(() => _deathAction = v); _markChanged(); },
          ),
          const SizedBox(height: 16),

          TextField(controller: _deathInstructionsController, decoration: const InputDecoration(labelText: 'Instructies', hintText: 'Doorgeven meterstand op datum overlijden'), maxLines: 3, onChanged: (_) => _markChanged()),
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
          Text('Klantenservice', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          PhoneField(controller: _servicePhoneController, labelText: 'Telefoon', onChanged: _markChanged),
          const SizedBox(height: 12),
          EmailField(controller: _serviceEmailController, labelText: 'Email', onChanged: _markChanged),
          const SizedBox(height: 12),
          WebsiteField(controller: _serviceWebsiteController, labelText: 'Website', onChanged: _markChanged),
          const SizedBox(height: 16),

          PhoneField(controller: _emergencyPhoneController, labelText: 'Storingsnummer', onChanged: _markChanged),
          const SizedBox(height: 24),

          Text('Netbeheerder', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: _gridOperatorController.text.isNotEmpty ? _gridOperatorController.text : null,
            decoration: const InputDecoration(labelText: 'Netbeheerder'),
            items: EnergyContractModel.gridOperators.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
            onChanged: (v) { if (v != null) { _gridOperatorController.text = v; _markChanged(); } },
          ),
          const SizedBox(height: 12),
          PhoneField(controller: _gridOperatorPhoneController, labelText: 'Storingsnummer netbeheerder', onChanged: _markChanged),
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

