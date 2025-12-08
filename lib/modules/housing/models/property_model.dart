// lib/modules/housing/models/property_model.dart
// Model voor een woning (Woning - Algemeen)

import 'housing_enums.dart';

class PropertyModel {
  final String id;
  final String dossierId;
  final String personId;
  
  // Basisgegevens (Tab 1)
  final String? name; // bijv. "Hoofdwoning", "Vakantiewoning"
  final String? street;
  final String? houseNumber;
  final String? postalCode;
  final String? city;
  final String? country;
  final PropertyType propertyType;
  final OwnershipType ownershipType;
  final int? buildYear;
  final double? livingArea; // m²
  final double? plotArea; // m²
  final int? rooms;
  final int? bedrooms;
  final String? energyLabel;
  final bool isMonument;
  
  // Kadaster & WOZ (Tab 2)
  final String? cadastralMunicipality;
  final String? cadastralSection;
  final String? cadastralNumber;
  final String? cadastralFullNumber;
  final String? cadastralUrl;
  final double? wozValue;
  final String? wozReferenceDate;
  final double? taxationValue;
  final String? taxationDate;
  
  // Eigendomssituatie (Tab 3)
  final String? ownerIds; // Comma-separated person IDs
  final String? ownershipRatio; // bijv. "50/50"
  final bool hasMarriageContract;
  final bool hasCohabitationContract;
  final String? willReference;
  final String? heirsDescription;
  
  // Belastingen & Lasten (Tab 4)
  final double? ozbAmount;
  final String? ozbPaymentMethod;
  final String? ozbBankAccountId;
  final String? waterBoardName;
  final double? waterBoardAmount;
  final double? leaseholdAmount;
  final String? leaseholdEndDate;
  final String? vveName;
  final double? vveMonthlyContribution;
  final String? vveContactName;
  final String? vveContactPhone;
  final String? vveContactEmail;
  
  // Verzekeringen (Tab 5) - Links naar Geldzaken
  final String? homeInsuranceId;
  final String? contentsInsuranceId;
  final String? buildingInsuranceId;
  final String? liabilityInsuranceId;
  
  // Voor nabestaanden (Tab 6)
  final PropertyDeathAction? deathAction;
  final String? deathInstructions;
  final int? numberOfKeys;
  final String? spareKeyLocation;
  final String? alarmCodeLocation; // NOOIT code zelf opslaan!
  
  // Locatie documenten (Tab 7)
  final String? mortgageDeedLocation;
  final String? purchaseDeedLocation;
  final String? buildingPermitsLocation;
  final String? blueprintsLocation;
  final String? warrantyLocation;
  final String? electricalSchemaLocation;
  final String? plumbingSchemaLocation;
  
  // Notities (Tab 9)
  final String? notes;
  
  // Status
  final HousingItemStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PropertyModel({
    required this.id,
    required this.dossierId,
    required this.personId,
    this.name,
    this.street,
    this.houseNumber,
    this.postalCode,
    this.city,
    this.country = 'Nederland',
    this.propertyType = PropertyType.singleFamily,
    this.ownershipType = OwnershipType.owned,
    this.buildYear,
    this.livingArea,
    this.plotArea,
    this.rooms,
    this.bedrooms,
    this.energyLabel,
    this.isMonument = false,
    this.cadastralMunicipality,
    this.cadastralSection,
    this.cadastralNumber,
    this.cadastralFullNumber,
    this.cadastralUrl,
    this.wozValue,
    this.wozReferenceDate,
    this.taxationValue,
    this.taxationDate,
    this.ownerIds,
    this.ownershipRatio,
    this.hasMarriageContract = false,
    this.hasCohabitationContract = false,
    this.willReference,
    this.heirsDescription,
    this.ozbAmount,
    this.ozbPaymentMethod,
    this.ozbBankAccountId,
    this.waterBoardName,
    this.waterBoardAmount,
    this.leaseholdAmount,
    this.leaseholdEndDate,
    this.vveName,
    this.vveMonthlyContribution,
    this.vveContactName,
    this.vveContactPhone,
    this.vveContactEmail,
    this.homeInsuranceId,
    this.contentsInsuranceId,
    this.buildingInsuranceId,
    this.liabilityInsuranceId,
    this.deathAction,
    this.deathInstructions,
    this.numberOfKeys,
    this.spareKeyLocation,
    this.alarmCodeLocation,
    this.mortgageDeedLocation,
    this.purchaseDeedLocation,
    this.buildingPermitsLocation,
    this.blueprintsLocation,
    this.warrantyLocation,
    this.electricalSchemaLocation,
    this.plumbingSchemaLocation,
    this.notes,
    this.status = HousingItemStatus.notStarted,
    required this.createdAt,
    this.updatedAt,
  });

  /// Volledig adres
  String get fullAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) {
      parts.add('$street ${houseNumber ?? ''}');
    }
    if (postalCode != null && city != null) {
      parts.add('$postalCode $city');
    }
    return parts.join(', ').trim();
  }

  /// Display naam
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (street != null && street!.isNotEmpty) return '$street ${houseNumber ?? ''}'.trim();
    return 'Nieuwe woning';
  }

  /// Completeness percentage
  int get completenessPercentage {
    int filled = 0;
    int total = 15; // Belangrijkste velden

    if (street?.isNotEmpty == true) filled++;
    if (postalCode?.isNotEmpty == true) filled++;
    if (city?.isNotEmpty == true) filled++;
    if (buildYear != null) filled++;
    if (livingArea != null) filled++;
    if (energyLabel?.isNotEmpty == true) filled++;
    if (wozValue != null) filled++;
    if (ozbAmount != null) filled++;
    if (numberOfKeys != null) filled++;
    if (spareKeyLocation?.isNotEmpty == true) filled++;
    if (deathAction != null) filled++;
    if (mortgageDeedLocation?.isNotEmpty == true || purchaseDeedLocation?.isNotEmpty == true) filled++;
    if (homeInsuranceId?.isNotEmpty == true || contentsInsuranceId?.isNotEmpty == true) filled++;
    if (notes?.isNotEmpty == true) filled++;
    if (status == HousingItemStatus.complete) filled++;

    return ((filled / total) * 100).round();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dossier_id': dossierId,
      'person_id': personId,
      'name': name,
      'street': street,
      'house_number': houseNumber,
      'postal_code': postalCode,
      'city': city,
      'country': country,
      'property_type': propertyType.name,
      'ownership_type': ownershipType.name,
      'build_year': buildYear,
      'living_area': livingArea,
      'plot_area': plotArea,
      'rooms': rooms,
      'bedrooms': bedrooms,
      'energy_label': energyLabel,
      'is_monument': isMonument ? 1 : 0,
      'cadastral_municipality': cadastralMunicipality,
      'cadastral_section': cadastralSection,
      'cadastral_number': cadastralNumber,
      'cadastral_full_number': cadastralFullNumber,
      'cadastral_url': cadastralUrl,
      'woz_value': wozValue,
      'woz_reference_date': wozReferenceDate,
      'taxation_value': taxationValue,
      'taxation_date': taxationDate,
      'owner_ids': ownerIds,
      'ownership_ratio': ownershipRatio,
      'has_marriage_contract': hasMarriageContract ? 1 : 0,
      'has_cohabitation_contract': hasCohabitationContract ? 1 : 0,
      'will_reference': willReference,
      'heirs_description': heirsDescription,
      'ozb_amount': ozbAmount,
      'ozb_payment_method': ozbPaymentMethod,
      'ozb_bank_account_id': ozbBankAccountId,
      'water_board_name': waterBoardName,
      'water_board_amount': waterBoardAmount,
      'leasehold_amount': leaseholdAmount,
      'leasehold_end_date': leaseholdEndDate,
      'vve_name': vveName,
      'vve_monthly_contribution': vveMonthlyContribution,
      'vve_contact_name': vveContactName,
      'vve_contact_phone': vveContactPhone,
      'vve_contact_email': vveContactEmail,
      'home_insurance_id': homeInsuranceId,
      'contents_insurance_id': contentsInsuranceId,
      'building_insurance_id': buildingInsuranceId,
      'liability_insurance_id': liabilityInsuranceId,
      'death_action': deathAction?.name,
      'death_instructions': deathInstructions,
      'number_of_keys': numberOfKeys,
      'spare_key_location': spareKeyLocation,
      'alarm_code_location': alarmCodeLocation,
      'mortgage_deed_location': mortgageDeedLocation,
      'purchase_deed_location': purchaseDeedLocation,
      'building_permits_location': buildingPermitsLocation,
      'blueprints_location': blueprintsLocation,
      'warranty_location': warrantyLocation,
      'electrical_schema_location': electricalSchemaLocation,
      'plumbing_schema_location': plumbingSchemaLocation,
      'notes': notes,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory PropertyModel.fromMap(Map<String, dynamic> map) {
    return PropertyModel(
      id: map['id'] as String,
      dossierId: map['dossier_id'] as String,
      personId: map['person_id'] as String,
      name: map['name'] as String?,
      street: map['street'] as String?,
      houseNumber: map['house_number'] as String?,
      postalCode: map['postal_code'] as String?,
      city: map['city'] as String?,
      country: map['country'] as String? ?? 'Nederland',
      propertyType: PropertyType.values.firstWhere(
        (e) => e.name == map['property_type'],
        orElse: () => PropertyType.singleFamily,
      ),
      ownershipType: OwnershipType.values.firstWhere(
        (e) => e.name == map['ownership_type'],
        orElse: () => OwnershipType.owned,
      ),
      buildYear: map['build_year'] as int?,
      livingArea: map['living_area'] as double?,
      plotArea: map['plot_area'] as double?,
      rooms: map['rooms'] as int?,
      bedrooms: map['bedrooms'] as int?,
      energyLabel: map['energy_label'] as String?,
      isMonument: map['is_monument'] == 1,
      cadastralMunicipality: map['cadastral_municipality'] as String?,
      cadastralSection: map['cadastral_section'] as String?,
      cadastralNumber: map['cadastral_number'] as String?,
      cadastralFullNumber: map['cadastral_full_number'] as String?,
      cadastralUrl: map['cadastral_url'] as String?,
      wozValue: map['woz_value'] as double?,
      wozReferenceDate: map['woz_reference_date'] as String?,
      taxationValue: map['taxation_value'] as double?,
      taxationDate: map['taxation_date'] as String?,
      ownerIds: map['owner_ids'] as String?,
      ownershipRatio: map['ownership_ratio'] as String?,
      hasMarriageContract: map['has_marriage_contract'] == 1,
      hasCohabitationContract: map['has_cohabitation_contract'] == 1,
      willReference: map['will_reference'] as String?,
      heirsDescription: map['heirs_description'] as String?,
      ozbAmount: map['ozb_amount'] as double?,
      ozbPaymentMethod: map['ozb_payment_method'] as String?,
      ozbBankAccountId: map['ozb_bank_account_id'] as String?,
      waterBoardName: map['water_board_name'] as String?,
      waterBoardAmount: map['water_board_amount'] as double?,
      leaseholdAmount: map['leasehold_amount'] as double?,
      leaseholdEndDate: map['leasehold_end_date'] as String?,
      vveName: map['vve_name'] as String?,
      vveMonthlyContribution: map['vve_monthly_contribution'] as double?,
      vveContactName: map['vve_contact_name'] as String?,
      vveContactPhone: map['vve_contact_phone'] as String?,
      vveContactEmail: map['vve_contact_email'] as String?,
      homeInsuranceId: map['home_insurance_id'] as String?,
      contentsInsuranceId: map['contents_insurance_id'] as String?,
      buildingInsuranceId: map['building_insurance_id'] as String?,
      liabilityInsuranceId: map['liability_insurance_id'] as String?,
      deathAction: map['death_action'] != null
          ? PropertyDeathAction.values.firstWhere(
              (e) => e.name == map['death_action'],
              orElse: () => PropertyDeathAction.staysWithPartner,
            )
          : null,
      deathInstructions: map['death_instructions'] as String?,
      numberOfKeys: map['number_of_keys'] as int?,
      spareKeyLocation: map['spare_key_location'] as String?,
      alarmCodeLocation: map['alarm_code_location'] as String?,
      mortgageDeedLocation: map['mortgage_deed_location'] as String?,
      purchaseDeedLocation: map['purchase_deed_location'] as String?,
      buildingPermitsLocation: map['building_permits_location'] as String?,
      blueprintsLocation: map['blueprints_location'] as String?,
      warrantyLocation: map['warranty_location'] as String?,
      electricalSchemaLocation: map['electrical_schema_location'] as String?,
      plumbingSchemaLocation: map['plumbing_schema_location'] as String?,
      notes: map['notes'] as String?,
      status: HousingItemStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => HousingItemStatus.notStarted,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  PropertyModel copyWith({
    String? id,
    String? dossierId,
    String? personId,
    String? name,
    String? street,
    String? houseNumber,
    String? postalCode,
    String? city,
    String? country,
    PropertyType? propertyType,
    OwnershipType? ownershipType,
    int? buildYear,
    double? livingArea,
    double? plotArea,
    int? rooms,
    int? bedrooms,
    String? energyLabel,
    bool? isMonument,
    String? cadastralMunicipality,
    String? cadastralSection,
    String? cadastralNumber,
    String? cadastralFullNumber,
    String? cadastralUrl,
    double? wozValue,
    String? wozReferenceDate,
    double? taxationValue,
    String? taxationDate,
    String? ownerIds,
    String? ownershipRatio,
    bool? hasMarriageContract,
    bool? hasCohabitationContract,
    String? willReference,
    String? heirsDescription,
    double? ozbAmount,
    String? ozbPaymentMethod,
    String? ozbBankAccountId,
    String? waterBoardName,
    double? waterBoardAmount,
    double? leaseholdAmount,
    String? leaseholdEndDate,
    String? vveName,
    double? vveMonthlyContribution,
    String? vveContactName,
    String? vveContactPhone,
    String? vveContactEmail,
    String? homeInsuranceId,
    String? contentsInsuranceId,
    String? buildingInsuranceId,
    String? liabilityInsuranceId,
    PropertyDeathAction? deathAction,
    String? deathInstructions,
    int? numberOfKeys,
    String? spareKeyLocation,
    String? alarmCodeLocation,
    String? mortgageDeedLocation,
    String? purchaseDeedLocation,
    String? buildingPermitsLocation,
    String? blueprintsLocation,
    String? warrantyLocation,
    String? electricalSchemaLocation,
    String? plumbingSchemaLocation,
    String? notes,
    HousingItemStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PropertyModel(
      id: id ?? this.id,
      dossierId: dossierId ?? this.dossierId,
      personId: personId ?? this.personId,
      name: name ?? this.name,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      country: country ?? this.country,
      propertyType: propertyType ?? this.propertyType,
      ownershipType: ownershipType ?? this.ownershipType,
      buildYear: buildYear ?? this.buildYear,
      livingArea: livingArea ?? this.livingArea,
      plotArea: plotArea ?? this.plotArea,
      rooms: rooms ?? this.rooms,
      bedrooms: bedrooms ?? this.bedrooms,
      energyLabel: energyLabel ?? this.energyLabel,
      isMonument: isMonument ?? this.isMonument,
      cadastralMunicipality: cadastralMunicipality ?? this.cadastralMunicipality,
      cadastralSection: cadastralSection ?? this.cadastralSection,
      cadastralNumber: cadastralNumber ?? this.cadastralNumber,
      cadastralFullNumber: cadastralFullNumber ?? this.cadastralFullNumber,
      cadastralUrl: cadastralUrl ?? this.cadastralUrl,
      wozValue: wozValue ?? this.wozValue,
      wozReferenceDate: wozReferenceDate ?? this.wozReferenceDate,
      taxationValue: taxationValue ?? this.taxationValue,
      taxationDate: taxationDate ?? this.taxationDate,
      ownerIds: ownerIds ?? this.ownerIds,
      ownershipRatio: ownershipRatio ?? this.ownershipRatio,
      hasMarriageContract: hasMarriageContract ?? this.hasMarriageContract,
      hasCohabitationContract: hasCohabitationContract ?? this.hasCohabitationContract,
      willReference: willReference ?? this.willReference,
      heirsDescription: heirsDescription ?? this.heirsDescription,
      ozbAmount: ozbAmount ?? this.ozbAmount,
      ozbPaymentMethod: ozbPaymentMethod ?? this.ozbPaymentMethod,
      ozbBankAccountId: ozbBankAccountId ?? this.ozbBankAccountId,
      waterBoardName: waterBoardName ?? this.waterBoardName,
      waterBoardAmount: waterBoardAmount ?? this.waterBoardAmount,
      leaseholdAmount: leaseholdAmount ?? this.leaseholdAmount,
      leaseholdEndDate: leaseholdEndDate ?? this.leaseholdEndDate,
      vveName: vveName ?? this.vveName,
      vveMonthlyContribution: vveMonthlyContribution ?? this.vveMonthlyContribution,
      vveContactName: vveContactName ?? this.vveContactName,
      vveContactPhone: vveContactPhone ?? this.vveContactPhone,
      vveContactEmail: vveContactEmail ?? this.vveContactEmail,
      homeInsuranceId: homeInsuranceId ?? this.homeInsuranceId,
      contentsInsuranceId: contentsInsuranceId ?? this.contentsInsuranceId,
      buildingInsuranceId: buildingInsuranceId ?? this.buildingInsuranceId,
      liabilityInsuranceId: liabilityInsuranceId ?? this.liabilityInsuranceId,
      deathAction: deathAction ?? this.deathAction,
      deathInstructions: deathInstructions ?? this.deathInstructions,
      numberOfKeys: numberOfKeys ?? this.numberOfKeys,
      spareKeyLocation: spareKeyLocation ?? this.spareKeyLocation,
      alarmCodeLocation: alarmCodeLocation ?? this.alarmCodeLocation,
      mortgageDeedLocation: mortgageDeedLocation ?? this.mortgageDeedLocation,
      purchaseDeedLocation: purchaseDeedLocation ?? this.purchaseDeedLocation,
      buildingPermitsLocation: buildingPermitsLocation ?? this.buildingPermitsLocation,
      blueprintsLocation: blueprintsLocation ?? this.blueprintsLocation,
      warrantyLocation: warrantyLocation ?? this.warrantyLocation,
      electricalSchemaLocation: electricalSchemaLocation ?? this.electricalSchemaLocation,
      plumbingSchemaLocation: plumbingSchemaLocation ?? this.plumbingSchemaLocation,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Bekende hypotheekverstrekkers
  static const List<String> commonMortgageProviders = [
    'ING',
    'Rabobank',
    'ABN AMRO',
    'SNS',
    'Obvion',
    'Florius',
    'BLG Wonen',
    'Nationale-Nederlanden',
    'Aegon',
    'a.s.r.',
    'Anders',
  ];

  /// Bekende waterleidingbedrijven
  static const List<String> waterCompanies = [
    'Vitens',
    'Evides',
    'Waternet',
    'PWN',
    'Dunea',
    'WML',
    'Brabant Water',
    'Oasen',
    'Anders',
  ];
}







