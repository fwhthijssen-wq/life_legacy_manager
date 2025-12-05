// lib/modules/assets/screens/asset_detail_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/widgets/date_picker_field.dart'; // Contains all widgets
import '../models/asset_model.dart';
import '../models/asset_enums.dart';
import '../repositories/asset_repository.dart';
import '../providers/asset_providers.dart';

class AssetDetailScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final String? assetId;
  final AssetCategory category;
  final String? personId;

  const AssetDetailScreen({
    super.key,
    required this.dossierId,
    this.assetId,
    required this.category,
    this.personId,
  });

  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isNew = true;

  // Tab 1: Basisgegevens
  final _nameController = TextEditingController();
  String? _selectedSubType;
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _serialNumberController = TextEditingController();
  AssetCondition? _selectedCondition;
  final _colorController = TextEditingController();
  final _materialController = TextEditingController();
  String? _mainPhotoPath;
  List<String> _additionalPhotos = [];

  // Tab 2: Aankoop & Waarde
  final _purchaseDateController = TextEditingController();
  final _purchasedFromController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  String? _purchaseProofPath;
  final _paymentMethodController = TextEditingController();
  AssetOrigin? _selectedOrigin;
  final _originPersonController = TextEditingController();
  final _originDateController = TextEditingController();
  final _currentValueController = TextEditingController();
  ValuationBasis? _selectedValuationBasis;
  final _lastValuationDateController = TextEditingController();
  final _appraiserNameController = TextEditingController();
  final _appraisalDateController = TextEditingController();
  final _appraisedValueController = TextEditingController();
  String? _appraisalReportPath;
  final _appraisalPurposeController = TextEditingController();

  // Tab 3: Verzekering
  bool _isInsured = false;
  InsuranceType? _selectedInsuranceType;
  final _insurerNameController = TextEditingController();
  final _policyNumberController = TextEditingController();
  final _insuredAmountController = TextEditingController();
  String? _linkedInsuranceId;

  // Tab 4: Locatie & Opslag
  AssetLocationType? _selectedLocationType;
  final _locationDetailsController = TextEditingController();
  final _specificLocationController = TextEditingController();
  String? _locationPhotoPath;
  AccessibilityType? _selectedAccessibility;
  final _keyLocationController = TextEditingController();
  final _codeLocationController = TextEditingController();
  final _accessPersonController = TextEditingController();
  final _alternativeLocationsController = TextEditingController();

  // Tab 5: Onderhoud & Garantie
  bool _hasWarranty = false;
  final _warrantyYearsController = TextEditingController();
  final _warrantyExpiryDateController = TextEditingController();
  String? _warrantyProofPath;
  final _warrantyProviderController = TextEditingController();
  final _maintenanceIntervalController = TextEditingController();
  final _lastMaintenanceDateController = TextEditingController();
  final _nextMaintenanceDateController = TextEditingController();
  bool _maintenanceReminder = false;

  // Tab 6: Erfenis
  bool _hasHeir = false;
  InheritanceDestination? _selectedInheritanceDestination;
  String? _heirPersonId;
  final _heirPersonNameController = TextEditingController();
  final _inheritanceReasonController = TextEditingController();
  SentimentalValue? _selectedSentimentalValue;
  bool _mentionedInWill = false;
  final _heirInstructionsController = TextEditingController();
  final _sellingSuggestionsController = TextEditingController();
  final _estimatedSellingPriceController = TextEditingController();
  final _estimatedSellingTimeController = TextEditingController();

  // Tab 7: Authenticiteit
  AuthenticityStatus? _selectedAuthenticity;
  bool _hasCertificate = false;
  String? _certificatePath;
  bool _hasProvenance = false;
  String? _provenancePath;
  final _expertNameController = TextEditingController();
  final _registrationNumberController = TextEditingController();

  // Tab 9: Contactgegevens
  final _maintenanceCompanyController = TextEditingController();
  final _maintenancePhoneController = TextEditingController();
  final _maintenanceEmailController = TextEditingController();
  final _maintenanceWebsiteController = TextEditingController();
  final _maintenanceAddressController = TextEditingController();
  final _dealerCompanyController = TextEditingController();
  final _dealerContactController = TextEditingController();
  final _dealerPhoneController = TextEditingController();
  final _auctionAccountsController = TextEditingController();

  // Tab 11: Verhaal
  final _storyController = TextEditingController();
  final _specialMemoriesController = TextEditingController();
  final _whyValuableController = TextEditingController();

  // Tab 12: Notities
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 12, vsync: this);
    _isNew = widget.assetId == null;
    
    if (!_isNew) {
      _loadAssetData();
    }
  }

  Future<void> _loadAssetData() async {
    setState(() => _isLoading = true);
    try {
      final asset = await ref.read(assetByIdProvider(widget.assetId!).future);
      if (asset != null && mounted) {
        _populateFields(asset);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _populateFields(AssetModel asset) {
    _nameController.text = asset.name;
    _selectedSubType = asset.subType;
    _brandController.text = asset.brand ?? '';
    _modelController.text = asset.model ?? '';
    _yearController.text = asset.year?.toString() ?? '';
    _serialNumberController.text = asset.serialNumber ?? '';
    _selectedCondition = asset.condition;
    _colorController.text = asset.color ?? '';
    _materialController.text = asset.material ?? '';
    _mainPhotoPath = asset.mainPhotoPath;
    // Parse additional photos from JSON string if needed

    _purchaseDateController.text = asset.purchaseDate ?? '';
    _purchasedFromController.text = asset.purchasedFrom ?? '';
    _purchasePriceController.text = asset.purchasePrice?.toStringAsFixed(2) ?? '';
    _purchaseProofPath = asset.purchaseProofPath;
    _paymentMethodController.text = asset.paymentMethod ?? '';
    _selectedOrigin = asset.origin;
    _originPersonController.text = asset.originPersonName ?? '';
    _originDateController.text = asset.originDate ?? '';
    _currentValueController.text = asset.currentValue?.toStringAsFixed(2) ?? '';
    _selectedValuationBasis = asset.valuationBasis;
    _lastValuationDateController.text = asset.lastValuationDate ?? '';
    _appraiserNameController.text = asset.appraiserName ?? '';
    _appraisalDateController.text = asset.appraisalDate ?? '';
    _appraisedValueController.text = asset.appraisedValue?.toStringAsFixed(2) ?? '';
    _appraisalReportPath = asset.appraisalReportPath;
    _appraisalPurposeController.text = asset.appraisalPurpose ?? '';

    _isInsured = asset.isInsured;
    _selectedInsuranceType = asset.insuranceType;
    _insurerNameController.text = asset.insurerName ?? '';
    _policyNumberController.text = asset.policyNumber ?? '';
    _insuredAmountController.text = asset.insuredAmount?.toStringAsFixed(2) ?? '';
    _linkedInsuranceId = asset.linkedInsuranceId;

    _selectedLocationType = asset.locationType;
    _locationDetailsController.text = asset.locationDetails ?? '';
    _specificLocationController.text = asset.specificLocation ?? '';
    _locationPhotoPath = asset.locationPhotoPath;
    _selectedAccessibility = asset.accessibility;
    _keyLocationController.text = asset.keyLocation ?? '';
    _codeLocationController.text = asset.codeLocation ?? '';
    _accessPersonController.text = asset.accessViaPersonName ?? '';
    _alternativeLocationsController.text = asset.alternativeLocations ?? '';

    _hasWarranty = asset.hasWarranty;
    _warrantyYearsController.text = asset.warrantyYears?.toString() ?? '';
    _warrantyExpiryDateController.text = asset.warrantyExpiryDate ?? '';
    _warrantyProofPath = asset.warrantyProofPath;
    _warrantyProviderController.text = asset.warrantyProvider ?? '';
    _maintenanceIntervalController.text = asset.maintenanceIntervalMonths?.toString() ?? '';
    _lastMaintenanceDateController.text = asset.lastMaintenanceDate ?? '';
    _nextMaintenanceDateController.text = asset.nextMaintenanceDate ?? '';
    _maintenanceReminder = asset.maintenanceReminder;

    _hasHeir = asset.hasHeir;
    _selectedInheritanceDestination = asset.inheritanceDestination;
    _heirPersonId = asset.heirPersonId;
    _heirPersonNameController.text = asset.heirPersonName ?? '';
    _inheritanceReasonController.text = asset.inheritanceReason ?? '';
    _selectedSentimentalValue = asset.sentimentalValue;
    _mentionedInWill = asset.mentionedInWill;
    _heirInstructionsController.text = asset.heirInstructions ?? '';
    _sellingSuggestionsController.text = asset.sellingSuggestions ?? '';
    _estimatedSellingPriceController.text = asset.estimatedSellingPrice?.toStringAsFixed(2) ?? '';
    _estimatedSellingTimeController.text = asset.estimatedSellingTime ?? '';

    _selectedAuthenticity = asset.authenticity;
    _hasCertificate = asset.hasCertificateOfAuthenticity;
    _certificatePath = asset.certificatePath;
    _hasProvenance = asset.hasProvenance;
    _provenancePath = asset.provenancePath;
    _expertNameController.text = asset.expertName ?? '';
    _registrationNumberController.text = asset.registrationNumber ?? '';

    _maintenanceCompanyController.text = asset.maintenanceCompany ?? '';
    _maintenancePhoneController.text = asset.maintenancePhone ?? '';
    _maintenanceEmailController.text = asset.maintenanceEmail ?? '';
    _maintenanceWebsiteController.text = asset.maintenanceWebsite ?? '';
    _maintenanceAddressController.text = asset.maintenanceAddress ?? '';
    _dealerCompanyController.text = asset.dealerCompany ?? '';
    _dealerContactController.text = asset.dealerContact ?? '';
    _dealerPhoneController.text = asset.dealerPhone ?? '';
    _auctionAccountsController.text = asset.auctionAccounts ?? '';

    _storyController.text = asset.story ?? '';
    _specialMemoriesController.text = asset.specialMemories ?? '';
    _whyValuableController.text = asset.whyValuable ?? '';

    _notesController.text = asset.notes ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _serialNumberController.dispose();
    _colorController.dispose();
    _materialController.dispose();
    _purchaseDateController.dispose();
    _purchasedFromController.dispose();
    _purchasePriceController.dispose();
    _paymentMethodController.dispose();
    _originPersonController.dispose();
    _originDateController.dispose();
    _currentValueController.dispose();
    _lastValuationDateController.dispose();
    _appraiserNameController.dispose();
    _appraisalDateController.dispose();
    _appraisedValueController.dispose();
    _appraisalPurposeController.dispose();
    _insurerNameController.dispose();
    _policyNumberController.dispose();
    _insuredAmountController.dispose();
    _locationDetailsController.dispose();
    _specificLocationController.dispose();
    _keyLocationController.dispose();
    _codeLocationController.dispose();
    _accessPersonController.dispose();
    _alternativeLocationsController.dispose();
    _warrantyYearsController.dispose();
    _warrantyExpiryDateController.dispose();
    _warrantyProviderController.dispose();
    _maintenanceIntervalController.dispose();
    _lastMaintenanceDateController.dispose();
    _nextMaintenanceDateController.dispose();
    _heirPersonNameController.dispose();
    _inheritanceReasonController.dispose();
    _heirInstructionsController.dispose();
    _sellingSuggestionsController.dispose();
    _estimatedSellingPriceController.dispose();
    _estimatedSellingTimeController.dispose();
    _expertNameController.dispose();
    _registrationNumberController.dispose();
    _maintenanceCompanyController.dispose();
    _maintenancePhoneController.dispose();
    _maintenanceEmailController.dispose();
    _maintenanceWebsiteController.dispose();
    _maintenanceAddressController.dispose();
    _dealerCompanyController.dispose();
    _dealerContactController.dispose();
    _dealerPhoneController.dispose();
    _auctionAccountsController.dispose();
    _storyController.dispose();
    _specialMemoriesController.dispose();
    _whyValuableController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? l10n.addItem : l10n.editItem),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveAsset,
            tooltip: 'Opslaan',
          ),
          if (!_isNew)
            PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'delete') _confirmDelete();
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
          tabs: [
            Tab(text: l10n.basicInfo),
            Tab(text: l10n.purchaseValue),
            Tab(text: l10n.insurance),
            Tab(text: l10n.location),
            Tab(text: l10n.maintenanceWarranty),
            Tab(text: l10n.inheritance),
            Tab(text: l10n.authenticity),
            Tab(text: l10n.specifications),
            Tab(text: l10n.contacts),
            Tab(text: l10n.documents),
            Tab(text: l10n.story),
            Tab(text: l10n.notes),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBasicInfoTab(l10n, theme),
                  _buildPurchaseValueTab(l10n, theme),
                  _buildInsuranceTab(l10n, theme),
                  _buildLocationTab(l10n, theme),
                  _buildMaintenanceTab(l10n, theme),
                  _buildInheritanceTab(l10n, theme),
                  _buildAuthenticityTab(l10n, theme),
                  _buildSpecificationsTab(l10n, theme),
                  _buildContactsTab(l10n, theme),
                  _buildDocumentsTab(l10n, theme),
                  _buildStoryTab(l10n, theme),
                  _buildNotesTab(l10n, theme),
                ],
              ),
            ),
    );
  }

  // ==================== TAB 1: BASISGEGEVENS ====================
  Widget _buildBasicInfoTab(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto sectie
          _buildPhotoSection(l10n, theme),
          const SizedBox(height: 24),

          // Naam
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: requiredLabel(l10n.itemName),
              hintText: l10n.itemNameHint,
              border: const OutlineInputBorder(),
            ),
            validator: (value) =>
                value == null || value.isEmpty ? l10n.fieldRequired : null,
          ),
          const SizedBox(height: 16),

          // Subcategorie
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: l10n.subcategory,
              border: const OutlineInputBorder(),
            ),
            value: _selectedSubType,
            items: _getSubTypeItems(),
            onChanged: (value) => setState(() => _selectedSubType = value),
          ),
          const SizedBox(height: 16),

          // Merk & Model
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _brandController,
                  decoration: InputDecoration(
                    labelText: l10n.brand,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _modelController,
                  decoration: InputDecoration(
                    labelText: l10n.model,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Bouwjaar & Serienummer
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _yearController,
                  decoration: InputDecoration(
                    labelText: l10n.year,
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _serialNumberController,
                  decoration: InputDecoration(
                    labelText: l10n.serialNumber,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Staat
          DropdownButtonFormField<AssetCondition>(
            decoration: InputDecoration(
              labelText: l10n.condition,
              border: const OutlineInputBorder(),
            ),
            value: _selectedCondition,
            items: AssetCondition.values.map((c) {
              return DropdownMenuItem(
                value: c,
                child: Text('${c.emoji} ${c.label}'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedCondition = value),
          ),
          const SizedBox(height: 16),

          // Kleur & Materiaal
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _colorController,
                  decoration: InputDecoration(
                    labelText: l10n.color,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _materialController,
                  decoration: InputDecoration(
                    labelText: l10n.material,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection(AppLocalizations l10n, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.photos, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            // Hoofdfoto
            GestureDetector(
              onTap: () => _pickMainPhoto(),
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _mainPhotoPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_mainPhotoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPhotoPlaceholder(l10n),
                        ),
                      )
                    : _buildPhotoPlaceholder(l10n),
              ),
            ),
            const SizedBox(width: 12),

            // Extra foto's
            Expanded(
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _additionalPhotos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _additionalPhotos.length) {
                      return GestureDetector(
                        onTap: () => _pickAdditionalPhoto(),
                        child: Container(
                          width: 80,
                          height: 120,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_photo_alternate, size: 32),
                        ),
                      );
                    }
                    return Container(
                      width: 80,
                      height: 120,
                      margin: const EdgeInsets.only(right: 8),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_additionalPhotos[index]),
                              fit: BoxFit.cover,
                              width: 80,
                              height: 120,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _additionalPhotos.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoPlaceholder(AppLocalizations l10n) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.camera_alt, size: 32, color: Colors.grey[400]),
        const SizedBox(height: 4),
        Text(
          l10n.addPhoto,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _getSubTypeItems() {
    switch (widget.category) {
      case AssetCategory.vehicles:
        return VehicleType.values.map((t) {
          return DropdownMenuItem(value: t.name, child: Text('${t.emoji} ${t.label}'));
        }).toList();
      case AssetCategory.jewelryWatches:
        return JewelryType.values.map((t) {
          return DropdownMenuItem(value: t.name, child: Text('${t.emoji} ${t.label}'));
        }).toList();
      case AssetCategory.artAntiques:
        return ArtType.values.map((t) {
          return DropdownMenuItem(value: t.name, child: Text('${t.emoji} ${t.label}'));
        }).toList();
      case AssetCategory.collections:
        return CollectionType.values.map((t) {
          return DropdownMenuItem(value: t.name, child: Text('${t.emoji} ${t.label}'));
        }).toList();
      case AssetCategory.electronics:
        return ElectronicsType.values.map((t) {
          return DropdownMenuItem(value: t.name, child: Text('${t.emoji} ${t.label}'));
        }).toList();
      case AssetCategory.fashionAccessories:
        return FashionType.values.map((t) {
          return DropdownMenuItem(value: t.name, child: Text('${t.emoji} ${t.label}'));
        }).toList();
      case AssetCategory.sportsHobby:
        return SportsType.values.map((t) {
          return DropdownMenuItem(value: t.name, child: Text('${t.emoji} ${t.label}'));
        }).toList();
      case AssetCategory.furnitureDecor:
        return FurnitureType.values.map((t) {
          return DropdownMenuItem(value: t.name, child: Text('${t.emoji} ${t.label}'));
        }).toList();
      case AssetCategory.toolsMachinery:
        return ToolsType.values.map((t) {
          return DropdownMenuItem(value: t.name, child: Text('${t.emoji} ${t.label}'));
        }).toList();
      case AssetCategory.other:
        return OtherAssetType.values.map((t) {
          return DropdownMenuItem(value: t.name, child: Text('${t.emoji} ${t.label}'));
        }).toList();
    }
  }

  // ==================== TAB 2: AANKOOP & WAARDE ====================
  Widget _buildPurchaseValueTab(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.purchaseDetails, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          DatePickerField(
            controller: _purchaseDateController,
            labelText: l10n.purchaseDate,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _purchasedFromController,
            decoration: InputDecoration(
              labelText: l10n.purchasedFrom,
              hintText: l10n.purchasedFromHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          AmountField(
            controller: _purchasePriceController,
            labelText: l10n.purchasePrice,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<AssetOrigin>(
            decoration: InputDecoration(
              labelText: l10n.origin,
              border: const OutlineInputBorder(),
            ),
            value: _selectedOrigin,
            items: AssetOrigin.values.map((o) {
              return DropdownMenuItem(
                value: o,
                child: Text('${o.emoji} ${o.label}'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedOrigin = value),
          ),
          const SizedBox(height: 16),

          if (_selectedOrigin == AssetOrigin.inherited || _selectedOrigin == AssetOrigin.gift) ...[
            TextFormField(
              controller: _originPersonController,
              decoration: InputDecoration(
                labelText: _selectedOrigin == AssetOrigin.inherited
                    ? l10n.inheritedFrom
                    : l10n.giftFrom,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DatePickerField(
              controller: _originDateController,
              labelText: l10n.receivedDate,
            ),
            const SizedBox(height: 16),
          ],

          const Divider(height: 32),

          Text(l10n.currentValue, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          AmountField(
            controller: _currentValueController,
            labelText: l10n.estimatedValue,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<ValuationBasis>(
            decoration: InputDecoration(
              labelText: l10n.valuationBasis,
              border: const OutlineInputBorder(),
            ),
            value: _selectedValuationBasis,
            items: ValuationBasis.values.map((v) {
              return DropdownMenuItem(
                value: v,
                child: Text('${v.emoji} ${v.label}'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedValuationBasis = value),
          ),
          const SizedBox(height: 16),

          DatePickerField(
            controller: _lastValuationDateController,
            labelText: l10n.lastValuationDate,
          ),
          const SizedBox(height: 16),

          const Divider(height: 32),

          Text(l10n.appraisal, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          TextFormField(
            controller: _appraiserNameController,
            decoration: InputDecoration(
              labelText: l10n.appraiserName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          DatePickerField(
            controller: _appraisalDateController,
            labelText: l10n.appraisalDate,
          ),
          const SizedBox(height: 16),

          AmountField(
            controller: _appraisedValueController,
            labelText: l10n.appraisedValue,
          ),
        ],
      ),
    );
  }

  // ==================== TAB 3: VERZEKERING ====================
  Widget _buildInsuranceTab(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SwitchListTile(
            title: Text(l10n.isInsured),
            value: _isInsured,
            onChanged: (value) => setState(() => _isInsured = value),
          ),
          const SizedBox(height: 16),

          if (_isInsured) ...[
            DropdownButtonFormField<InsuranceType>(
              decoration: InputDecoration(
                labelText: l10n.insuranceType,
                border: const OutlineInputBorder(),
              ),
              value: _selectedInsuranceType,
              items: InsuranceType.values.map((t) {
                return DropdownMenuItem(
                  value: t,
                  child: Text('${t.emoji} ${t.label}'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedInsuranceType = value),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _insurerNameController,
              decoration: InputDecoration(
                labelText: l10n.insurerName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _policyNumberController,
              decoration: InputDecoration(
                labelText: l10n.policyNumber,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            AmountField(
              controller: _insuredAmountController,
              labelText: l10n.insuredAmount,
            ),
          ],
        ],
      ),
    );
  }

  // ==================== TAB 4: LOCATIE ====================
  Widget _buildLocationTab(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<AssetLocationType>(
            decoration: InputDecoration(
              labelText: l10n.locationType,
              border: const OutlineInputBorder(),
            ),
            value: _selectedLocationType,
            items: AssetLocationType.values.map((t) {
              return DropdownMenuItem(
                value: t,
                child: Text('${t.emoji} ${t.label}'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedLocationType = value),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _locationDetailsController,
            decoration: InputDecoration(
              labelText: l10n.locationDetails,
              hintText: l10n.locationDetailsHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _specificLocationController,
            decoration: InputDecoration(
              labelText: l10n.specificLocation,
              hintText: l10n.specificLocationHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<AccessibilityType>(
            decoration: InputDecoration(
              labelText: l10n.accessibility,
              border: const OutlineInputBorder(),
            ),
            value: _selectedAccessibility,
            items: AccessibilityType.values.map((t) {
              return DropdownMenuItem(
                value: t,
                child: Text('${t.emoji} ${t.label}'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedAccessibility = value),
          ),
          const SizedBox(height: 16),

          if (_selectedAccessibility == AccessibilityType.withKey)
            TextFormField(
              controller: _keyLocationController,
              decoration: InputDecoration(
                labelText: l10n.keyLocation,
                border: const OutlineInputBorder(),
              ),
            ),
          if (_selectedAccessibility == AccessibilityType.withCode)
            TextFormField(
              controller: _codeLocationController,
              decoration: InputDecoration(
                labelText: l10n.codeLocation,
                border: const OutlineInputBorder(),
              ),
            ),
          if (_selectedAccessibility == AccessibilityType.viaPersonOnly)
            TextFormField(
              controller: _accessPersonController,
              decoration: InputDecoration(
                labelText: l10n.accessViaPerson,
                border: const OutlineInputBorder(),
              ),
            ),
        ],
      ),
    );
  }

  // ==================== TAB 5: ONDERHOUD & GARANTIE ====================
  Widget _buildMaintenanceTab(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.warranty, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),

          SwitchListTile(
            title: Text(l10n.hasWarranty),
            value: _hasWarranty,
            onChanged: (value) => setState(() => _hasWarranty = value),
          ),

          if (_hasWarranty) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _warrantyYearsController,
                    decoration: InputDecoration(
                      labelText: l10n.warrantyYears,
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DatePickerField(
                    controller: _warrantyExpiryDateController,
                    labelText: l10n.warrantyExpiry,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _warrantyProviderController,
              decoration: InputDecoration(
                labelText: l10n.warrantyProvider,
                border: const OutlineInputBorder(),
              ),
            ),
          ],

          const SizedBox(height: 24),
          Text(l10n.maintenance, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          TextFormField(
            controller: _maintenanceIntervalController,
            decoration: InputDecoration(
              labelText: l10n.maintenanceInterval,
              hintText: l10n.maintenanceIntervalHint,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DatePickerField(
                  controller: _lastMaintenanceDateController,
                  labelText: l10n.lastMaintenance,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DatePickerField(
                  controller: _nextMaintenanceDateController,
                  labelText: l10n.nextMaintenance,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: Text(l10n.maintenanceReminder),
            value: _maintenanceReminder,
            onChanged: (value) => setState(() => _maintenanceReminder = value),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 6: ERFENIS ====================
  Widget _buildInheritanceTab(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.whoGetsThis, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          SwitchListTile(
            title: Text(l10n.heirAssigned),
            value: _hasHeir,
            onChanged: (value) => setState(() => _hasHeir = value),
          ),

          DropdownButtonFormField<InheritanceDestination>(
            decoration: InputDecoration(
              labelText: l10n.inheritanceDestination,
              border: const OutlineInputBorder(),
            ),
            value: _selectedInheritanceDestination,
            items: InheritanceDestination.values.map((d) {
              return DropdownMenuItem(
                value: d,
                child: Text('${d.emoji} ${d.label}'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedInheritanceDestination = value),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _heirPersonNameController,
            decoration: InputDecoration(
              labelText: l10n.heirName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _inheritanceReasonController,
            decoration: InputDecoration(
              labelText: l10n.inheritanceReason,
              hintText: l10n.inheritanceReasonHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<SentimentalValue>(
            decoration: InputDecoration(
              labelText: l10n.sentimentalValue,
              border: const OutlineInputBorder(),
            ),
            value: _selectedSentimentalValue,
            items: SentimentalValue.values.map((s) {
              return DropdownMenuItem(
                value: s,
                child: Text('${s.emoji} ${s.label}'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedSentimentalValue = value),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: Text(l10n.mentionedInWill),
            value: _mentionedInWill,
            onChanged: (value) => setState(() => _mentionedInWill = value),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _heirInstructionsController,
            decoration: InputDecoration(
              labelText: l10n.survivorInstructions,
              hintText: l10n.survivorInstructionsHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 24),

          Text(l10n.sellingInfo, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          TextFormField(
            controller: _sellingSuggestionsController,
            decoration: InputDecoration(
              labelText: l10n.whereToSell,
              hintText: l10n.whereToSellHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: AmountField(
                  controller: _estimatedSellingPriceController,
                  labelText: l10n.estimatedSellingPrice,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _estimatedSellingTimeController,
                  decoration: InputDecoration(
                    labelText: l10n.estimatedSellingTime,
                    hintText: l10n.estimatedSellingTimeHint,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== TAB 7: AUTHENTICITEIT ====================
  Widget _buildAuthenticityTab(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<AuthenticityStatus>(
            decoration: InputDecoration(
              labelText: l10n.authenticity,
              border: const OutlineInputBorder(),
            ),
            value: _selectedAuthenticity,
            items: AuthenticityStatus.values.map((a) {
              return DropdownMenuItem(
                value: a,
                child: Text('${a.emoji} ${a.label}'),
              );
            }).toList(),
            onChanged: (value) => setState(() => _selectedAuthenticity = value),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: Text(l10n.hasCertificate),
            value: _hasCertificate,
            onChanged: (value) => setState(() => _hasCertificate = value),
          ),

          SwitchListTile(
            title: Text(l10n.hasProvenance),
            value: _hasProvenance,
            onChanged: (value) => setState(() => _hasProvenance = value),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _expertNameController,
            decoration: InputDecoration(
              labelText: l10n.expertName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _registrationNumberController,
            decoration: InputDecoration(
              labelText: l10n.registrationNumber,
              hintText: l10n.registrationNumberHint,
              border: const OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TAB 8: SPECIFICATIES ====================
  Widget _buildSpecificationsTab(AppLocalizations l10n, ThemeData theme) {
    // Dit tabblad toont categorie-specifieke velden
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.specificationsFor} ${widget.category.label}',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.specificationsComingSoon,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          // TODO: Implement category-specific fields
        ],
      ),
    );
  }

  // ==================== TAB 9: CONTACTGEGEVENS ====================
  Widget _buildContactsTab(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.maintenanceContact, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          TextFormField(
            controller: _maintenanceCompanyController,
            decoration: InputDecoration(
              labelText: l10n.company,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          PhoneField(
            controller: _maintenancePhoneController,
            labelText: l10n.phone,
          ),
          const SizedBox(height: 16),

          EmailField(
            controller: _maintenanceEmailController,
            labelText: l10n.email,
          ),
          const SizedBox(height: 16),

          WebsiteField(
            controller: _maintenanceWebsiteController,
            labelText: l10n.website,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _maintenanceAddressController,
            decoration: InputDecoration(
              labelText: l10n.address,
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          Text(l10n.dealerContact, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          TextFormField(
            controller: _dealerCompanyController,
            decoration: InputDecoration(
              labelText: l10n.company,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _dealerContactController,
            decoration: InputDecoration(
              labelText: l10n.contactPerson,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          PhoneField(
            controller: _dealerPhoneController,
            labelText: l10n.phone,
          ),
          const SizedBox(height: 24),

          Text(l10n.auctionAccounts, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          TextFormField(
            controller: _auctionAccountsController,
            decoration: InputDecoration(
              labelText: l10n.auctionAccountsLabel,
              hintText: l10n.auctionAccountsHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  // ==================== TAB 10: DOCUMENTEN ====================
  Widget _buildDocumentsTab(AppLocalizations l10n, ThemeData theme) {
    return Center(
      child: Text(l10n.documentsComingSoon),
    );
  }

  // ==================== TAB 11: VERHAAL ====================
  Widget _buildStoryTab(AppLocalizations l10n, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.storyBehindItem, style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          TextFormField(
            controller: _storyController,
            decoration: InputDecoration(
              labelText: l10n.story,
              hintText: l10n.storyHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 6,
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _specialMemoriesController,
            decoration: InputDecoration(
              labelText: l10n.specialMemories,
              hintText: l10n.specialMemoriesHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _whyValuableController,
            decoration: InputDecoration(
              labelText: l10n.whyValuable,
              hintText: l10n.whyValuableHint,
              border: const OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  // ==================== TAB 12: NOTITIES ====================
  Widget _buildNotesTab(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        controller: _notesController,
        decoration: InputDecoration(
          labelText: l10n.notes,
          hintText: l10n.notesHint,
          border: const OutlineInputBorder(),
          alignLabelWithHint: true,
        ),
        maxLines: null,
        expands: true,
      ),
    );
  }

  // ==================== ACTIONS ====================

  Future<void> _pickMainPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _mainPhotoPath = image.path;
      });
    }
  }

  Future<void> _pickAdditionalPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && _additionalPhotos.length < 10) {
      setState(() {
        _additionalPhotos.add(image.path);
      });
    }
  }

  Future<void> _saveAsset() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseFixErrors)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(assetRepositoryProvider);
      final personId = widget.personId ?? '';

      final asset = AssetModel(
        id: _isNew ? null : widget.assetId,
        dossierId: widget.dossierId,
        personId: personId,
        name: _nameController.text,
        category: widget.category,
        subType: _selectedSubType,
        brand: _brandController.text.isEmpty ? null : _brandController.text,
        model: _modelController.text.isEmpty ? null : _modelController.text,
        year: int.tryParse(_yearController.text),
        serialNumber: _serialNumberController.text.isEmpty ? null : _serialNumberController.text,
        condition: _selectedCondition,
        color: _colorController.text.isEmpty ? null : _colorController.text,
        material: _materialController.text.isEmpty ? null : _materialController.text,
        mainPhotoPath: _mainPhotoPath,
        purchaseDate: _purchaseDateController.text.isEmpty ? null : _purchaseDateController.text,
        purchasedFrom: _purchasedFromController.text.isEmpty ? null : _purchasedFromController.text,
        purchasePrice: double.tryParse(_purchasePriceController.text),
        origin: _selectedOrigin,
        originPersonName: _originPersonController.text.isEmpty ? null : _originPersonController.text,
        originDate: _originDateController.text.isEmpty ? null : _originDateController.text,
        currentValue: double.tryParse(_currentValueController.text),
        valuationBasis: _selectedValuationBasis,
        lastValuationDate: _lastValuationDateController.text.isEmpty ? null : _lastValuationDateController.text,
        appraiserName: _appraiserNameController.text.isEmpty ? null : _appraiserNameController.text,
        appraisalDate: _appraisalDateController.text.isEmpty ? null : _appraisalDateController.text,
        appraisedValue: double.tryParse(_appraisedValueController.text),
        isInsured: _isInsured,
        insuranceType: _selectedInsuranceType,
        insurerName: _insurerNameController.text.isEmpty ? null : _insurerNameController.text,
        policyNumber: _policyNumberController.text.isEmpty ? null : _policyNumberController.text,
        insuredAmount: double.tryParse(_insuredAmountController.text),
        locationType: _selectedLocationType,
        locationDetails: _locationDetailsController.text.isEmpty ? null : _locationDetailsController.text,
        specificLocation: _specificLocationController.text.isEmpty ? null : _specificLocationController.text,
        accessibility: _selectedAccessibility,
        keyLocation: _keyLocationController.text.isEmpty ? null : _keyLocationController.text,
        codeLocation: _codeLocationController.text.isEmpty ? null : _codeLocationController.text,
        accessViaPersonName: _accessPersonController.text.isEmpty ? null : _accessPersonController.text,
        hasWarranty: _hasWarranty,
        warrantyYears: int.tryParse(_warrantyYearsController.text),
        warrantyExpiryDate: _warrantyExpiryDateController.text.isEmpty ? null : _warrantyExpiryDateController.text,
        warrantyProvider: _warrantyProviderController.text.isEmpty ? null : _warrantyProviderController.text,
        maintenanceIntervalMonths: int.tryParse(_maintenanceIntervalController.text),
        lastMaintenanceDate: _lastMaintenanceDateController.text.isEmpty ? null : _lastMaintenanceDateController.text,
        nextMaintenanceDate: _nextMaintenanceDateController.text.isEmpty ? null : _nextMaintenanceDateController.text,
        maintenanceReminder: _maintenanceReminder,
        hasHeir: _hasHeir,
        inheritanceDestination: _selectedInheritanceDestination,
        heirPersonId: _heirPersonId,
        heirPersonName: _heirPersonNameController.text.isEmpty ? null : _heirPersonNameController.text,
        inheritanceReason: _inheritanceReasonController.text.isEmpty ? null : _inheritanceReasonController.text,
        sentimentalValue: _selectedSentimentalValue,
        mentionedInWill: _mentionedInWill,
        heirInstructions: _heirInstructionsController.text.isEmpty ? null : _heirInstructionsController.text,
        sellingSuggestions: _sellingSuggestionsController.text.isEmpty ? null : _sellingSuggestionsController.text,
        estimatedSellingPrice: double.tryParse(_estimatedSellingPriceController.text),
        estimatedSellingTime: _estimatedSellingTimeController.text.isEmpty ? null : _estimatedSellingTimeController.text,
        authenticity: _selectedAuthenticity,
        hasCertificateOfAuthenticity: _hasCertificate,
        hasProvenance: _hasProvenance,
        expertName: _expertNameController.text.isEmpty ? null : _expertNameController.text,
        registrationNumber: _registrationNumberController.text.isEmpty ? null : _registrationNumberController.text,
        maintenanceCompany: _maintenanceCompanyController.text.isEmpty ? null : _maintenanceCompanyController.text,
        maintenancePhone: _maintenancePhoneController.text.isEmpty ? null : _maintenancePhoneController.text,
        maintenanceEmail: _maintenanceEmailController.text.isEmpty ? null : _maintenanceEmailController.text,
        maintenanceWebsite: _maintenanceWebsiteController.text.isEmpty ? null : _maintenanceWebsiteController.text,
        maintenanceAddress: _maintenanceAddressController.text.isEmpty ? null : _maintenanceAddressController.text,
        dealerCompany: _dealerCompanyController.text.isEmpty ? null : _dealerCompanyController.text,
        dealerContact: _dealerContactController.text.isEmpty ? null : _dealerContactController.text,
        dealerPhone: _dealerPhoneController.text.isEmpty ? null : _dealerPhoneController.text,
        auctionAccounts: _auctionAccountsController.text.isEmpty ? null : _auctionAccountsController.text,
        story: _storyController.text.isEmpty ? null : _storyController.text,
        specialMemories: _specialMemoriesController.text.isEmpty ? null : _specialMemoriesController.text,
        whyValuable: _whyValuableController.text.isEmpty ? null : _whyValuableController.text,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      if (_isNew) {
        await repository.createAsset(asset);
      } else {
        await repository.updateAsset(asset);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.savedSuccessfully)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDelete),
        content: Text(l10n.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.assetId != null) {
      await ref.read(assetRepositoryProvider).deleteAsset(widget.assetId!);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
