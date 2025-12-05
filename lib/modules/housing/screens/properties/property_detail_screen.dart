// lib/modules/housing/screens/properties/property_detail_screen.dart
// Detail scherm voor een woning met tabs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/date_picker_field.dart';
import '../../models/property_model.dart';
import '../../models/housing_enums.dart';
import '../../providers/housing_providers.dart';
import '../../repositories/housing_repository.dart';

class PropertyDetailScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final String propertyId;
  final bool isNew;

  const PropertyDetailScreen({
    super.key,
    required this.dossierId,
    required this.propertyId,
    this.isNew = false,
  });

  @override
  ConsumerState<PropertyDetailScreen> createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends ConsumerState<PropertyDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasChanges = false;
  PropertyModel? _property;

  // Tab 1: Basisgegevens
  final _nameController = TextEditingController();
  final _streetController = TextEditingController();
  final _houseNumberController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _cityController = TextEditingController();
  PropertyType _propertyType = PropertyType.singleFamily;
  OwnershipType _ownershipType = OwnershipType.owned;
  final _buildYearController = TextEditingController();
  final _livingAreaController = TextEditingController();
  final _plotAreaController = TextEditingController();
  final _roomsController = TextEditingController();
  final _bedroomsController = TextEditingController();
  String? _energyLabel;
  bool _isMonument = false;

  // Tab 2: Kadaster & WOZ
  final _cadastralMunicipalityController = TextEditingController();
  final _cadastralSectionController = TextEditingController();
  final _cadastralNumberController = TextEditingController();
  final _wozValueController = TextEditingController();
  final _wozReferenceDateController = TextEditingController();
  final _taxationValueController = TextEditingController();
  final _taxationDateController = TextEditingController();

  // Tab 3: Belastingen & Lasten
  final _ozbAmountController = TextEditingController();
  final _waterBoardNameController = TextEditingController();
  final _waterBoardAmountController = TextEditingController();
  final _leaseholdAmountController = TextEditingController();
  final _leaseholdEndDateController = TextEditingController();
  final _vveNameController = TextEditingController();
  final _vveContributionController = TextEditingController();
  final _vveContactNameController = TextEditingController();
  final _vveContactPhoneController = TextEditingController();
  final _vveContactEmailController = TextEditingController();

  // Tab 4: Voor nabestaanden
  PropertyDeathAction? _deathAction;
  final _deathInstructionsController = TextEditingController();
  final _numberOfKeysController = TextEditingController();
  final _spareKeyLocationController = TextEditingController();
  final _alarmCodeLocationController = TextEditingController();

  // Tab 5: Documenten locaties
  final _mortgageDeedLocationController = TextEditingController();
  final _purchaseDeedLocationController = TextEditingController();
  final _buildingPermitsLocationController = TextEditingController();
  final _blueprintsLocationController = TextEditingController();

  // Tab 6: Notities
  final _notesController = TextEditingController();

  // Status
  HousingItemStatus _status = HousingItemStatus.notStarted;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _streetController.dispose();
    _houseNumberController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _buildYearController.dispose();
    _livingAreaController.dispose();
    _plotAreaController.dispose();
    _roomsController.dispose();
    _bedroomsController.dispose();
    _cadastralMunicipalityController.dispose();
    _cadastralSectionController.dispose();
    _cadastralNumberController.dispose();
    _wozValueController.dispose();
    _wozReferenceDateController.dispose();
    _taxationValueController.dispose();
    _taxationDateController.dispose();
    _ozbAmountController.dispose();
    _waterBoardNameController.dispose();
    _waterBoardAmountController.dispose();
    _leaseholdAmountController.dispose();
    _leaseholdEndDateController.dispose();
    _vveNameController.dispose();
    _vveContributionController.dispose();
    _vveContactNameController.dispose();
    _vveContactPhoneController.dispose();
    _vveContactEmailController.dispose();
    _deathInstructionsController.dispose();
    _numberOfKeysController.dispose();
    _spareKeyLocationController.dispose();
    _alarmCodeLocationController.dispose();
    _mortgageDeedLocationController.dispose();
    _purchaseDeedLocationController.dispose();
    _buildingPermitsLocationController.dispose();
    _blueprintsLocationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(housingRepositoryProvider);
    final property = await repo.getProperty(widget.propertyId);

    if (property != null) {
      _property = property;
      _populateFields(property);
    }
    setState(() => _isLoading = false);
  }

  void _populateFields(PropertyModel p) {
    _nameController.text = p.name ?? '';
    _streetController.text = p.street ?? '';
    _houseNumberController.text = p.houseNumber ?? '';
    _postalCodeController.text = p.postalCode ?? '';
    _cityController.text = p.city ?? '';
    _propertyType = p.propertyType;
    _ownershipType = p.ownershipType;
    _buildYearController.text = p.buildYear?.toString() ?? '';
    _livingAreaController.text = p.livingArea?.toString() ?? '';
    _plotAreaController.text = p.plotArea?.toString() ?? '';
    _roomsController.text = p.rooms?.toString() ?? '';
    _bedroomsController.text = p.bedrooms?.toString() ?? '';
    _energyLabel = p.energyLabel;
    _isMonument = p.isMonument;

    _cadastralMunicipalityController.text = p.cadastralMunicipality ?? '';
    _cadastralSectionController.text = p.cadastralSection ?? '';
    _cadastralNumberController.text = p.cadastralNumber ?? '';
    _wozValueController.text = p.wozValue?.toStringAsFixed(0) ?? '';
    _wozReferenceDateController.text = p.wozReferenceDate ?? '';
    _taxationValueController.text = p.taxationValue?.toStringAsFixed(0) ?? '';
    _taxationDateController.text = p.taxationDate ?? '';

    _ozbAmountController.text = p.ozbAmount?.toStringAsFixed(2) ?? '';
    _waterBoardNameController.text = p.waterBoardName ?? '';
    _waterBoardAmountController.text = p.waterBoardAmount?.toStringAsFixed(2) ?? '';
    _leaseholdAmountController.text = p.leaseholdAmount?.toStringAsFixed(2) ?? '';
    _leaseholdEndDateController.text = p.leaseholdEndDate ?? '';
    _vveNameController.text = p.vveName ?? '';
    _vveContributionController.text = p.vveMonthlyContribution?.toStringAsFixed(2) ?? '';
    _vveContactNameController.text = p.vveContactName ?? '';
    _vveContactPhoneController.text = p.vveContactPhone ?? '';
    _vveContactEmailController.text = p.vveContactEmail ?? '';

    _deathAction = p.deathAction;
    _deathInstructionsController.text = p.deathInstructions ?? '';
    _numberOfKeysController.text = p.numberOfKeys?.toString() ?? '';
    _spareKeyLocationController.text = p.spareKeyLocation ?? '';
    _alarmCodeLocationController.text = p.alarmCodeLocation ?? '';

    _mortgageDeedLocationController.text = p.mortgageDeedLocation ?? '';
    _purchaseDeedLocationController.text = p.purchaseDeedLocation ?? '';
    _buildingPermitsLocationController.text = p.buildingPermitsLocation ?? '';
    _blueprintsLocationController.text = p.blueprintsLocation ?? '';

    _notesController.text = p.notes ?? '';
    _status = p.status;
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _save() async {
    if (_property == null) return;

    final repo = ref.read(housingRepositoryProvider);
    final updated = _property!.copyWith(
      name: _nameController.text.isNotEmpty ? _nameController.text : null,
      street: _streetController.text.isNotEmpty ? _streetController.text : null,
      houseNumber: _houseNumberController.text.isNotEmpty ? _houseNumberController.text : null,
      postalCode: _postalCodeController.text.isNotEmpty ? _postalCodeController.text : null,
      city: _cityController.text.isNotEmpty ? _cityController.text : null,
      propertyType: _propertyType,
      ownershipType: _ownershipType,
      buildYear: int.tryParse(_buildYearController.text),
      livingArea: double.tryParse(_livingAreaController.text),
      plotArea: double.tryParse(_plotAreaController.text),
      rooms: int.tryParse(_roomsController.text),
      bedrooms: int.tryParse(_bedroomsController.text),
      energyLabel: _energyLabel,
      isMonument: _isMonument,
      cadastralMunicipality: _cadastralMunicipalityController.text.isNotEmpty ? _cadastralMunicipalityController.text : null,
      cadastralSection: _cadastralSectionController.text.isNotEmpty ? _cadastralSectionController.text : null,
      cadastralNumber: _cadastralNumberController.text.isNotEmpty ? _cadastralNumberController.text : null,
      wozValue: double.tryParse(_wozValueController.text),
      wozReferenceDate: _wozReferenceDateController.text.isNotEmpty ? _wozReferenceDateController.text : null,
      taxationValue: double.tryParse(_taxationValueController.text),
      taxationDate: _taxationDateController.text.isNotEmpty ? _taxationDateController.text : null,
      ozbAmount: double.tryParse(_ozbAmountController.text),
      waterBoardName: _waterBoardNameController.text.isNotEmpty ? _waterBoardNameController.text : null,
      waterBoardAmount: double.tryParse(_waterBoardAmountController.text),
      leaseholdAmount: double.tryParse(_leaseholdAmountController.text),
      leaseholdEndDate: _leaseholdEndDateController.text.isNotEmpty ? _leaseholdEndDateController.text : null,
      vveName: _vveNameController.text.isNotEmpty ? _vveNameController.text : null,
      vveMonthlyContribution: double.tryParse(_vveContributionController.text),
      vveContactName: _vveContactNameController.text.isNotEmpty ? _vveContactNameController.text : null,
      vveContactPhone: _vveContactPhoneController.text.isNotEmpty ? _vveContactPhoneController.text : null,
      vveContactEmail: _vveContactEmailController.text.isNotEmpty ? _vveContactEmailController.text : null,
      deathAction: _deathAction,
      deathInstructions: _deathInstructionsController.text.isNotEmpty ? _deathInstructionsController.text : null,
      numberOfKeys: int.tryParse(_numberOfKeysController.text),
      spareKeyLocation: _spareKeyLocationController.text.isNotEmpty ? _spareKeyLocationController.text : null,
      alarmCodeLocation: _alarmCodeLocationController.text.isNotEmpty ? _alarmCodeLocationController.text : null,
      mortgageDeedLocation: _mortgageDeedLocationController.text.isNotEmpty ? _mortgageDeedLocationController.text : null,
      purchaseDeedLocation: _purchaseDeedLocationController.text.isNotEmpty ? _purchaseDeedLocationController.text : null,
      buildingPermitsLocation: _buildingPermitsLocationController.text.isNotEmpty ? _buildingPermitsLocationController.text : null,
      blueprintsLocation: _blueprintsLocationController.text.isNotEmpty ? _blueprintsLocationController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      status: _status,
      updatedAt: DateTime.now(),
    );

    await repo.updateProperty(updated);
    setState(() {
      _property = updated;
      _hasChanges = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Woning opgeslagen'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Woning verwijderen?'),
        content: const Text('Alle gekoppelde gegevens worden ook verwijderd.'),
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
      await repo.deleteProperty(widget.propertyId);
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
        title: Text(
          _nameController.text.isNotEmpty
              ? _nameController.text
              : 'Nieuwe woning',
        ),
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
            Tab(text: 'Kadaster'),
            Tab(text: 'Lasten'),
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
          _buildKadasterTab(theme),
          _buildLastenTab(theme),
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
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Naam/Identificatie',
              hintText: 'Bijv. Hoofdwoning, Vakantiewoning',
              prefixIcon: Icon(Icons.label),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          Text('Adres', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _streetController,
                  decoration: const InputDecoration(labelText: 'Straat'),
                  onChanged: (_) => _markChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _houseNumberController,
                  decoration: const InputDecoration(labelText: 'Nr.'),
                  onChanged: (_) => _markChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _postalCodeController,
                  decoration: const InputDecoration(labelText: 'Postcode'),
                  onChanged: (_) => _markChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _cityController,
                  decoration: const InputDecoration(labelText: 'Plaats'),
                  onChanged: (_) => _markChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          DropdownButtonFormField<PropertyType>(
            value: _propertyType,
            decoration: const InputDecoration(
              labelText: 'Type woning',
              prefixIcon: Icon(Icons.home),
            ),
            items: PropertyType.values.map((type) => DropdownMenuItem(
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
                setState(() => _propertyType = value);
                _markChanged();
              }
            },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<OwnershipType>(
            value: _ownershipType,
            decoration: const InputDecoration(
              labelText: 'Eigendom',
              prefixIcon: Icon(Icons.key),
            ),
            items: OwnershipType.values.map((type) => DropdownMenuItem(
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
                setState(() => _ownershipType = value);
                _markChanged();
              }
            },
          ),
          const SizedBox(height: 24),

          Text('Kenmerken', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _buildYearController,
                  decoration: const InputDecoration(labelText: 'Bouwjaar'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _markChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _livingAreaController,
                  decoration: const InputDecoration(labelText: 'Woonoppervlak (m²)'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _markChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _roomsController,
                  decoration: const InputDecoration(labelText: 'Kamers'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _markChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _bedroomsController,
                  decoration: const InputDecoration(labelText: 'Slaapkamers'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _markChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _energyLabel,
            decoration: const InputDecoration(
              labelText: 'Energielabel',
              prefixIcon: Icon(Icons.eco),
            ),
            items: ['A++++', 'A+++', 'A++', 'A+', 'A', 'B', 'C', 'D', 'E', 'F', 'G']
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (value) {
              setState(() => _energyLabel = value);
              _markChanged();
            },
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Monument/Beschermd'),
            value: _isMonument,
            onChanged: (value) {
              setState(() => _isMonument = value);
              _markChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKadasterTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kadastrale gegevens', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          TextField(
            controller: _cadastralMunicipalityController,
            decoration: const InputDecoration(labelText: 'Kadastrale gemeente'),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cadastralSectionController,
                  decoration: const InputDecoration(labelText: 'Sectie'),
                  onChanged: (_) => _markChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _cadastralNumberController,
                  decoration: const InputDecoration(labelText: 'Perceelnummer'),
                  onChanged: (_) => _markChanged(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('WOZ-waarde', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: AmountField(
                  controller: _wozValueController,
                  labelText: 'WOZ-waarde',
                  onChanged: _markChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DatePickerField(
                  controller: _wozReferenceDateController,
                  labelText: 'Peildatum',
                  onChanged: _markChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          Text('Taxatiewaarde', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: AmountField(
                  controller: _taxationValueController,
                  labelText: 'Taxatiewaarde',
                  onChanged: _markChanged,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DatePickerField(
                  controller: _taxationDateController,
                  labelText: 'Taxatiedatum',
                  onChanged: _markChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLastenTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gemeentelijke belastingen', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          AmountField(
            controller: _ozbAmountController,
            labelText: 'OZB per jaar',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 24),

          Text('Waterschap', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _waterBoardNameController.text.isNotEmpty ? _waterBoardNameController.text : null,
            decoration: const InputDecoration(labelText: 'Waterschap'),
            items: PropertyModel.waterCompanies
                .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                _waterBoardNameController.text = value;
                _markChanged();
              }
            },
          ),
          const SizedBox(height: 12),

          AmountField(
            controller: _waterBoardAmountController,
            labelText: 'Waterschapsbelasting per jaar',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 24),

          if (_ownershipType == OwnershipType.leasehold) ...[
            Text('Erfpacht', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: AmountField(
                    controller: _leaseholdAmountController,
                    labelText: 'Erfpachtcanon per jaar',
                    onChanged: _markChanged,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DatePickerField(
                    controller: _leaseholdEndDateController,
                    labelText: 'Einddatum erfpacht',
                    onChanged: _markChanged,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],

          if (_propertyType == PropertyType.apartment) ...[
            Text('VvE-bijdrage', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),

            TextField(
              controller: _vveNameController,
              decoration: const InputDecoration(labelText: 'Naam VvE'),
              onChanged: (_) => _markChanged(),
            ),
            const SizedBox(height: 12),

            AmountField(
              controller: _vveContributionController,
              labelText: 'Maandelijkse bijdrage',
              onChanged: _markChanged,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _vveContactNameController,
              decoration: const InputDecoration(labelText: 'Contactpersoon VvE'),
              onChanged: (_) => _markChanged(),
            ),
            const SizedBox(height: 12),

            PhoneField(
              controller: _vveContactPhoneController,
              labelText: 'Telefoon VvE',
              onChanged: _markChanged,
            ),
            const SizedBox(height: 12),

            EmailField(
              controller: _vveContactEmailController,
              labelText: 'Email VvE',
              onChanged: _markChanged,
            ),
          ],
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
                    'Deze informatie helpt nabestaanden bij het afhandelen van de woning.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          DropdownButtonFormField<PropertyDeathAction>(
            value: _deathAction,
            decoration: const InputDecoration(
              labelText: 'Wat gebeurt met de woning bij overlijden?',
              prefixIcon: Icon(Icons.help_outline),
            ),
            items: PropertyDeathAction.values.map((action) => DropdownMenuItem(
              value: action,
              child: Row(
                children: [
                  Text(action.emoji),
                  const SizedBox(width: 8),
                  Text(action.label),
                ],
              ),
            )).toList(),
            onChanged: (value) {
              setState(() => _deathAction = value);
              _markChanged();
            },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _deathInstructionsController,
            decoration: const InputDecoration(
              labelText: 'Belangrijke informatie',
              hintText: 'Bijv. hypotheek heeft overlijdensrisicoverzekering',
            ),
            maxLines: 3,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 24),

          Text('Sleutels & Toegang', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          TextField(
            controller: _numberOfKeysController,
            decoration: const InputDecoration(labelText: 'Aantal sets sleutels'),
            keyboardType: TextInputType.number,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _spareKeyLocationController,
            decoration: const InputDecoration(
              labelText: 'Locatie reservesleutels',
              hintText: 'Bijv. bij buren op nr. 23',
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _alarmCodeLocationController,
            decoration: const InputDecoration(
              labelText: 'Locatie alarmcode',
              hintText: 'NOOIT code zelf opslaan!',
              helperText: 'Bijv. in kluis, in telefoon onder contacten',
            ),
            onChanged: (_) => _markChanged(),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentenTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Locatie fysieke documenten', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            'Waar liggen de belangrijke papieren?',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          _buildDocumentLocationField(
            'Hypotheekakte',
            _mortgageDeedLocationController,
            Icons.description,
          ),
          const SizedBox(height: 12),

          _buildDocumentLocationField(
            'Koopakte / Leveringsakte',
            _purchaseDeedLocationController,
            Icons.home,
          ),
          const SizedBox(height: 12),

          _buildDocumentLocationField(
            'Bouwvergunningen',
            _buildingPermitsLocationController,
            Icons.engineering,
          ),
          const SizedBox(height: 12),

          _buildDocumentLocationField(
            'Bouwtekeningen',
            _blueprintsLocationController,
            Icons.architecture,
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
            icon: const Icon(Icons.upload_file),
            label: const Text('Document uploaden'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentLocationField(String label, TextEditingController controller, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Bijv. rode map in bureau, la 2',
        prefixIcon: Icon(icon),
      ),
      onChanged: (_) => _markChanged(),
    );
  }

  Widget _buildNotitiesTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _notesController,
        decoration: const InputDecoration(
          labelText: 'Notities',
          hintText: 'Overige opmerkingen over deze woning...',
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

