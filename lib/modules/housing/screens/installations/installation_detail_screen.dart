// lib/modules/housing/screens/installations/installation_detail_screen.dart
// Detail scherm voor technische installatie met tabs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/date_picker_field.dart';
import '../../models/installation_model.dart';
import '../../models/housing_enums.dart';
import '../../providers/housing_providers.dart';

class InstallationDetailScreen extends ConsumerStatefulWidget {
  final String propertyId;
  final String installationId;
  final bool isNew;

  const InstallationDetailScreen({
    super.key,
    required this.propertyId,
    required this.installationId,
    this.isNew = false,
  });

  @override
  ConsumerState<InstallationDetailScreen> createState() => _InstallationDetailScreenState();
}

class _InstallationDetailScreenState extends ConsumerState<InstallationDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasChanges = false;
  InstallationModel? _installation;

  // Tab 1: Basisgegevens
  InstallationType _type = InstallationType.other;
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _installYearController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _powerController = TextEditingController();
  final _locationController = TextEditingController();

  // Tab 2: Installateur & Garantie
  final _installerCompanyController = TextEditingController();
  final _installerContactController = TextEditingController();
  final _installerPhoneController = TextEditingController();
  final _installerEmailController = TextEditingController();
  final _installationDateController = TextEditingController();
  final _warrantyYearsController = TextEditingController();
  final _warrantyEndDateController = TextEditingController();

  // Tab 3: Onderhoud
  bool _hasMaintenanceContract = false;
  final _maintenanceCompanyController = TextEditingController();
  final _maintenanceCostController = TextEditingController();
  final _lastMaintenanceDateController = TextEditingController();
  final _nextMaintenanceDateController = TextEditingController();
  final _emergencyPhone24hController = TextEditingController();

  // Tab 4: Storing - Wat te doen
  final _troubleshootingController = TextEditingController();

  // Tab 5: Handleiding
  final _manualOnlineUrlController = TextEditingController();
  final _manualPhysicalLocationController = TextEditingController();

  // Tab 6: Nabestaanden
  final _survivorInstructionsController = TextEditingController();

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
    _brandController.dispose();
    _modelController.dispose();
    _installYearController.dispose();
    _serialNumberController.dispose();
    _powerController.dispose();
    _locationController.dispose();
    _installerCompanyController.dispose();
    _installerContactController.dispose();
    _installerPhoneController.dispose();
    _installerEmailController.dispose();
    _installationDateController.dispose();
    _warrantyYearsController.dispose();
    _warrantyEndDateController.dispose();
    _maintenanceCompanyController.dispose();
    _maintenanceCostController.dispose();
    _lastMaintenanceDateController.dispose();
    _nextMaintenanceDateController.dispose();
    _emergencyPhone24hController.dispose();
    _troubleshootingController.dispose();
    _manualOnlineUrlController.dispose();
    _manualPhysicalLocationController.dispose();
    _survivorInstructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(housingRepositoryProvider);
    final installation = await repo.getInstallation(widget.installationId);

    if (installation != null) {
      _installation = installation;
      _populateFields(installation);
    }
    setState(() => _isLoading = false);
  }

  void _populateFields(InstallationModel i) {
    _type = i.installationType;
    _brandController.text = i.brand ?? '';
    _modelController.text = i.model ?? '';
    _installYearController.text = i.installYear?.toString() ?? '';
    _serialNumberController.text = i.serialNumber ?? '';
    _powerController.text = i.power?.toString() ?? '';
    _locationController.text = i.location ?? '';

    _installerCompanyController.text = i.installerCompany ?? '';
    _installerContactController.text = i.installerContact ?? '';
    _installerPhoneController.text = i.installerPhone ?? '';
    _installerEmailController.text = i.installerEmail ?? '';
    _installationDateController.text = i.installationDate ?? '';
    _warrantyYearsController.text = i.warrantyYears?.toString() ?? '';
    _warrantyEndDateController.text = i.warrantyEndDate ?? '';

    _hasMaintenanceContract = i.hasMaintenanceContract;
    _maintenanceCompanyController.text = i.maintenanceCompany ?? '';
    _maintenanceCostController.text = i.maintenanceCostYearly?.toString() ?? '';
    _lastMaintenanceDateController.text = i.lastMaintenanceDate ?? '';
    _nextMaintenanceDateController.text = i.nextMaintenanceDate ?? '';
    _emergencyPhone24hController.text = i.emergencyPhone24h ?? '';

    _troubleshootingController.text = i.troubleshootingSteps ?? '';
    _manualOnlineUrlController.text = i.manualOnlineUrl ?? '';
    _manualPhysicalLocationController.text = i.manualPhysicalLocation ?? '';
    _survivorInstructionsController.text = i.survivorInstructions ?? '';
    _notesController.text = i.notes ?? '';
    _status = i.status;
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _save() async {
    if (_installation == null) return;

    final repo = ref.read(housingRepositoryProvider);
    final updated = InstallationModel(
      id: _installation!.id,
      propertyId: _installation!.propertyId,
      installationType: _type,
      brand: _brandController.text.isNotEmpty ? _brandController.text : null,
      model: _modelController.text.isNotEmpty ? _modelController.text : null,
      installYear: int.tryParse(_installYearController.text),
      serialNumber: _serialNumberController.text.isNotEmpty ? _serialNumberController.text : null,
      power: double.tryParse(_powerController.text),
      location: _locationController.text.isNotEmpty ? _locationController.text : null,
      installerCompany: _installerCompanyController.text.isNotEmpty ? _installerCompanyController.text : null,
      installerContact: _installerContactController.text.isNotEmpty ? _installerContactController.text : null,
      installerPhone: _installerPhoneController.text.isNotEmpty ? _installerPhoneController.text : null,
      installerEmail: _installerEmailController.text.isNotEmpty ? _installerEmailController.text : null,
      installationDate: _installationDateController.text.isNotEmpty ? _installationDateController.text : null,
      warrantyYears: int.tryParse(_warrantyYearsController.text),
      warrantyEndDate: _warrantyEndDateController.text.isNotEmpty ? _warrantyEndDateController.text : null,
      hasMaintenanceContract: _hasMaintenanceContract,
      maintenanceCompany: _maintenanceCompanyController.text.isNotEmpty ? _maintenanceCompanyController.text : null,
      maintenanceCostYearly: double.tryParse(_maintenanceCostController.text),
      lastMaintenanceDate: _lastMaintenanceDateController.text.isNotEmpty ? _lastMaintenanceDateController.text : null,
      nextMaintenanceDate: _nextMaintenanceDateController.text.isNotEmpty ? _nextMaintenanceDateController.text : null,
      emergencyPhone24h: _emergencyPhone24hController.text.isNotEmpty ? _emergencyPhone24hController.text : null,
      troubleshootingSteps: _troubleshootingController.text.isNotEmpty ? _troubleshootingController.text : null,
      manualOnlineUrl: _manualOnlineUrlController.text.isNotEmpty ? _manualOnlineUrlController.text : null,
      manualPhysicalLocation: _manualPhysicalLocationController.text.isNotEmpty ? _manualPhysicalLocationController.text : null,
      survivorInstructions: _survivorInstructionsController.text.isNotEmpty ? _survivorInstructionsController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      status: _status,
      createdAt: _installation!.createdAt,
      updatedAt: DateTime.now(),
    );

    await repo.updateInstallation(updated);
    setState(() {
      _installation = updated;
      _hasChanges = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Installatie opgeslagen'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Installatie verwijderen?'),
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
      await repo.deleteInstallation(widget.installationId);
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  List<String> _getBrandsForType() {
    switch (_type) {
      case InstallationType.cvBoiler:
        return InstallationModel.cvBoilerBrands;
      case InstallationType.solarPanels:
        return InstallationModel.solarPanelBrands;
      case InstallationType.heatPump:
        return InstallationModel.heatPumpBrands;
      default:
        return [];
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
        title: Text(_installation?.displayName ?? _type.label),
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
            Tab(text: 'Basis'),
            Tab(text: 'Installateur'),
            Tab(text: 'Onderhoud'),
            Tab(text: 'Storing'),
            Tab(text: 'Handleiding'),
            Tab(text: 'Nabestaanden'),
            Tab(text: 'Notities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasisTab(theme),
          _buildInstallateurTab(theme),
          _buildOnderhoudTab(theme),
          _buildStoringTab(theme),
          _buildHandleidingTab(theme),
          _buildNabestaandenTab(theme),
          _buildNotitiesTab(theme),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildBasisTab(ThemeData theme) {
    final brands = _getBrandsForType();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(_type.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 16),
                Text(_type.label, style: theme.textTheme.titleLarge),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (brands.isNotEmpty)
            DropdownButtonFormField<String>(
              value: _brandController.text.isNotEmpty ? _brandController.text : null,
              decoration: const InputDecoration(labelText: 'Merk', prefixIcon: Icon(Icons.business)),
              items: brands.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
              onChanged: (v) { if (v != null) { _brandController.text = v; _markChanged(); } },
            )
          else
            TextField(controller: _brandController, decoration: const InputDecoration(labelText: 'Merk'), onChanged: (_) => _markChanged()),
          const SizedBox(height: 12),

          TextField(controller: _modelController, decoration: const InputDecoration(labelText: 'Model'), onChanged: (_) => _markChanged()),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: TextField(controller: _installYearController, decoration: const InputDecoration(labelText: 'Bouwjaar/Installatiejaar'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
            const SizedBox(width: 12),
            Expanded(child: TextField(controller: _powerController, decoration: const InputDecoration(labelText: 'Vermogen (kW)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
          ]),
          const SizedBox(height: 12),

          TextField(controller: _serialNumberController, decoration: const InputDecoration(labelText: 'Serienummer'), onChanged: (_) => _markChanged()),
          const SizedBox(height: 12),

          TextField(controller: _locationController, decoration: const InputDecoration(labelText: 'Locatie in woning', hintText: 'Bijv. meterkast, bijkeuken, zolder'), onChanged: (_) => _markChanged()),
        ],
      ),
    );
  }

  Widget _buildInstallateurTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Geïnstalleerd door', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          TextField(controller: _installerCompanyController, decoration: const InputDecoration(labelText: 'Bedrijfsnaam'), onChanged: (_) => _markChanged()),
          const SizedBox(height: 12),
          TextField(controller: _installerContactController, decoration: const InputDecoration(labelText: 'Contactpersoon'), onChanged: (_) => _markChanged()),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: PhoneField(controller: _installerPhoneController, labelText: 'Telefoon', onChanged: _markChanged)),
            const SizedBox(width: 12),
            Expanded(child: EmailField(controller: _installerEmailController, labelText: 'Email', onChanged: _markChanged)),
          ]),
          const SizedBox(height: 12),

          DatePickerField(controller: _installationDateController, labelText: 'Installatiedatum', onChanged: _markChanged),
          const SizedBox(height: 24),

          Text('Garantie', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: TextField(controller: _warrantyYearsController, decoration: const InputDecoration(labelText: 'Garantieperiode (jaren)'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
            const SizedBox(width: 12),
            Expanded(child: DatePickerField(controller: _warrantyEndDateController, labelText: 'Geldig tot', onChanged: _markChanged)),
          ]),
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
          SwitchListTile(
            title: const Text('Onderhoudscontract'),
            value: _hasMaintenanceContract,
            onChanged: (v) { setState(() => _hasMaintenanceContract = v); _markChanged(); },
          ),

          if (_hasMaintenanceContract) ...[
            const SizedBox(height: 16),
            TextField(controller: _maintenanceCompanyController, decoration: const InputDecoration(labelText: 'Onderhoudsbedrijf'), onChanged: (_) => _markChanged()),
            const SizedBox(height: 12),
            AmountField(controller: _maintenanceCostController, labelText: 'Kosten per jaar', onChanged: _markChanged),
          ],
          const SizedBox(height: 24),

          Text('Onderhoud', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          Row(children: [
            Expanded(child: DatePickerField(controller: _lastMaintenanceDateController, labelText: 'Laatste onderhoud', onChanged: _markChanged)),
            const SizedBox(width: 12),
            Expanded(child: DatePickerField(controller: _nextMaintenanceDateController, labelText: 'Volgend onderhoud', onChanged: _markChanged)),
          ]),
          const SizedBox(height: 24),

          PhoneField(
            controller: _emergencyPhone24hController,
            labelText: '24/7 Storingsdienst',
            onChanged: _markChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStoringTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.red[700]),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Deze informatie is ZEER belangrijk voor nabestaanden!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text('Storing - Wat te doen?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          TextField(
            controller: _troubleshootingController,
            decoration: const InputDecoration(
              labelText: 'Stappen bij storing',
              hintText: 'Stap 1: Controleer of ketel aan staat\nStap 2: Check waterdruk\nStap 3: Probeer reset-knop\nStap 4: Bel storingsdienst',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            maxLines: 10,
            onChanged: (_) => _markChanged(),
          ),
        ],
      ),
    );
  }

  Widget _buildHandleidingTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Handleiding', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          WebsiteField(
            controller: _manualOnlineUrlController,
            labelText: 'Online handleiding (URL)',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _manualPhysicalLocationController,
            decoration: const InputDecoration(
              labelText: 'Fysieke locatie handleiding',
              hintText: 'Bijv. in keukenla, bij ketel, in mapje "Apparaten"',
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('PDF upload wordt binnenkort toegevoegd'), behavior: SnackBarBehavior.floating),
              );
            },
            icon: const Icon(Icons.upload_file),
            label: const Text('Handleiding uploaden'),
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
          TextField(
            controller: _survivorInstructionsController,
            decoration: const InputDecoration(
              labelText: 'Instructies voor nabestaanden',
              hintText: 'Bijv. "Ketel moet jaarlijks onderhouden worden"\n"Onderhoudscontract is overdraagbaar"\n"Garantie loopt tot 2028"',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            maxLines: 10,
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

