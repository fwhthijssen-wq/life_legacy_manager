// lib/modules/assets/models/asset_model.dart
import 'package:uuid/uuid.dart';
import 'asset_enums.dart';

/// Model voor een bezitting/eigendom
class AssetModel {
  final String id;
  final String dossierId;
  final String personId;
  
  // Tab 1: Basisgegevens
  final String name;
  final AssetCategory category;
  final String? subType; // Opgeslagen als string, cast naar juiste enum op basis van category
  final String? brand;
  final String? model;
  final int? year;
  final String? serialNumber;
  final AssetCondition? condition;
  final String? color;
  final String? material;
  final String? mainPhotoPath;
  final String? additionalPhotos; // JSON array van paden
  
  // Tab 2: Aankoop & Waarde
  final String? purchaseDate;
  final String? purchasedFrom;
  final double? purchasePrice;
  final String? purchaseProofPath;
  final String? paymentMethod;
  final AssetOrigin? origin;
  final String? originPersonName; // Bij geërfd/gekregen
  final String? originDate;
  final double? currentValue;
  final ValuationBasis? valuationBasis;
  final String? lastValuationDate;
  final String? appraiserName;
  final String? appraisalDate;
  final double? appraisedValue;
  final String? appraisalReportPath;
  final String? appraisalPurpose;
  
  // Tab 3: Verzekering
  final bool isInsured;
  final InsuranceType? insuranceType;
  final String? insurerName;
  final String? policyNumber;
  final double? insuredAmount;
  final String? linkedInsuranceId; // Link naar Geldzaken module
  final String? insurancePhotosPath; // JSON array
  
  // Tab 4: Locatie & Opslag
  final AssetLocationType? locationType;
  final String? locationDetails;
  final String? specificLocation;
  final String? locationPhotoPath;
  final AccessibilityType? accessibility;
  final String? keyLocation;
  final String? codeLocation;
  final String? accessViaPersonName;
  final String? alternativeLocations; // JSON voor meerdere locaties
  
  // Tab 5: Onderhoud & Garantie
  final bool hasWarranty;
  final int? warrantyYears;
  final String? warrantyExpiryDate;
  final String? warrantyProofPath;
  final String? warrantyProvider;
  final String? maintenanceHistory; // JSON array van onderhoudsbeurten
  final int? maintenanceIntervalMonths;
  final String? lastMaintenanceDate;
  final String? nextMaintenanceDate;
  final bool maintenanceReminder;
  
  // Tab 6: Voor nabestaanden - Erfenis
  final bool hasHeir;
  final InheritanceDestination? inheritanceDestination;
  final String? heirPersonId; // Link naar persoon
  final String? heirPersonName;
  final String? inheritanceReason;
  final SentimentalValue? sentimentalValue;
  final bool mentionedInWill;
  final String? heirInstructions;
  final String? sellingSuggestions; // JSON array van verkoopkanalen
  final double? estimatedSellingPrice;
  final String? estimatedSellingTime;
  
  // Tab 7: Authenticiteit & Certificaten
  final AuthenticityStatus? authenticity;
  final bool hasCertificateOfAuthenticity;
  final String? certificatePath;
  final bool hasProvenance;
  final String? provenancePath;
  final String? expertName;
  final String? registrationNumber;
  
  // Tab 8: Specificaties (categorie-afhankelijk, opgeslagen als JSON)
  final String? specificationsJson;
  
  // Tab 9: Contactgegevens
  final String? maintenanceCompany;
  final String? maintenancePhone;
  final String? maintenanceEmail;
  final String? maintenanceWebsite;
  final String? maintenanceAddress;
  final String? dealerCompany;
  final String? dealerContact;
  final String? dealerPhone;
  final String? auctionAccounts; // JSON voor veilingaccounts
  
  // Tab 10: Documenten (opgeslagen in aparte tabel)
  
  // Tab 11: Geschiedenis & Verhaal
  final String? story;
  final String? specialMemories;
  final String? whyValuable;
  
  // Tab 12: Notities
  final String? notes;
  
  // Metadata
  final AssetItemStatus status;
  final String createdAt;
  final String? updatedAt;

  AssetModel({
    String? id,
    required this.dossierId,
    required this.personId,
    required this.name,
    required this.category,
    this.subType,
    this.brand,
    this.model,
    this.year,
    this.serialNumber,
    this.condition,
    this.color,
    this.material,
    this.mainPhotoPath,
    this.additionalPhotos,
    this.purchaseDate,
    this.purchasedFrom,
    this.purchasePrice,
    this.purchaseProofPath,
    this.paymentMethod,
    this.origin,
    this.originPersonName,
    this.originDate,
    this.currentValue,
    this.valuationBasis,
    this.lastValuationDate,
    this.appraiserName,
    this.appraisalDate,
    this.appraisedValue,
    this.appraisalReportPath,
    this.appraisalPurpose,
    this.isInsured = false,
    this.insuranceType,
    this.insurerName,
    this.policyNumber,
    this.insuredAmount,
    this.linkedInsuranceId,
    this.insurancePhotosPath,
    this.locationType,
    this.locationDetails,
    this.specificLocation,
    this.locationPhotoPath,
    this.accessibility,
    this.keyLocation,
    this.codeLocation,
    this.accessViaPersonName,
    this.alternativeLocations,
    this.hasWarranty = false,
    this.warrantyYears,
    this.warrantyExpiryDate,
    this.warrantyProofPath,
    this.warrantyProvider,
    this.maintenanceHistory,
    this.maintenanceIntervalMonths,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.maintenanceReminder = false,
    this.hasHeir = false,
    this.inheritanceDestination,
    this.heirPersonId,
    this.heirPersonName,
    this.inheritanceReason,
    this.sentimentalValue,
    this.mentionedInWill = false,
    this.heirInstructions,
    this.sellingSuggestions,
    this.estimatedSellingPrice,
    this.estimatedSellingTime,
    this.authenticity,
    this.hasCertificateOfAuthenticity = false,
    this.certificatePath,
    this.hasProvenance = false,
    this.provenancePath,
    this.expertName,
    this.registrationNumber,
    this.specificationsJson,
    this.maintenanceCompany,
    this.maintenancePhone,
    this.maintenanceEmail,
    this.maintenanceWebsite,
    this.maintenanceAddress,
    this.dealerCompany,
    this.dealerContact,
    this.dealerPhone,
    this.auctionAccounts,
    this.story,
    this.specialMemories,
    this.whyValuable,
    this.notes,
    this.status = AssetItemStatus.notStarted,
    String? createdAt,
    this.updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dossier_id': dossierId,
      'person_id': personId,
      'name': name,
      'category': category.name,
      'sub_type': subType,
      'brand': brand,
      'model': model,
      'year': year,
      'serial_number': serialNumber,
      'condition': condition?.name,
      'color': color,
      'material': material,
      'main_photo_path': mainPhotoPath,
      'additional_photos': additionalPhotos,
      'purchase_date': purchaseDate,
      'purchased_from': purchasedFrom,
      'purchase_price': purchasePrice,
      'purchase_proof_path': purchaseProofPath,
      'payment_method': paymentMethod,
      'origin': origin?.name,
      'origin_person_name': originPersonName,
      'origin_date': originDate,
      'current_value': currentValue,
      'valuation_basis': valuationBasis?.name,
      'last_valuation_date': lastValuationDate,
      'appraiser_name': appraiserName,
      'appraisal_date': appraisalDate,
      'appraised_value': appraisedValue,
      'appraisal_report_path': appraisalReportPath,
      'appraisal_purpose': appraisalPurpose,
      'is_insured': isInsured ? 1 : 0,
      'insurance_type': insuranceType?.name,
      'insurer_name': insurerName,
      'policy_number': policyNumber,
      'insured_amount': insuredAmount,
      'linked_insurance_id': linkedInsuranceId,
      'insurance_photos_path': insurancePhotosPath,
      'location_type': locationType?.name,
      'location_details': locationDetails,
      'specific_location': specificLocation,
      'location_photo_path': locationPhotoPath,
      'accessibility': accessibility?.name,
      'key_location': keyLocation,
      'code_location': codeLocation,
      'access_via_person_name': accessViaPersonName,
      'alternative_locations': alternativeLocations,
      'has_warranty': hasWarranty ? 1 : 0,
      'warranty_years': warrantyYears,
      'warranty_expiry_date': warrantyExpiryDate,
      'warranty_proof_path': warrantyProofPath,
      'warranty_provider': warrantyProvider,
      'maintenance_history': maintenanceHistory,
      'maintenance_interval_months': maintenanceIntervalMonths,
      'last_maintenance_date': lastMaintenanceDate,
      'next_maintenance_date': nextMaintenanceDate,
      'maintenance_reminder': maintenanceReminder ? 1 : 0,
      'has_heir': hasHeir ? 1 : 0,
      'inheritance_destination': inheritanceDestination?.name,
      'heir_person_id': heirPersonId,
      'heir_person_name': heirPersonName,
      'inheritance_reason': inheritanceReason,
      'sentimental_value': sentimentalValue?.name,
      'mentioned_in_will': mentionedInWill ? 1 : 0,
      'heir_instructions': heirInstructions,
      'selling_suggestions': sellingSuggestions,
      'estimated_selling_price': estimatedSellingPrice,
      'estimated_selling_time': estimatedSellingTime,
      'authenticity': authenticity?.name,
      'has_certificate_of_authenticity': hasCertificateOfAuthenticity ? 1 : 0,
      'certificate_path': certificatePath,
      'has_provenance': hasProvenance ? 1 : 0,
      'provenance_path': provenancePath,
      'expert_name': expertName,
      'registration_number': registrationNumber,
      'specifications_json': specificationsJson,
      'maintenance_company': maintenanceCompany,
      'maintenance_phone': maintenancePhone,
      'maintenance_email': maintenanceEmail,
      'maintenance_website': maintenanceWebsite,
      'maintenance_address': maintenanceAddress,
      'dealer_company': dealerCompany,
      'dealer_contact': dealerContact,
      'dealer_phone': dealerPhone,
      'auction_accounts': auctionAccounts,
      'story': story,
      'special_memories': specialMemories,
      'why_valuable': whyValuable,
      'notes': notes,
      'status': status.name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  factory AssetModel.fromMap(Map<String, dynamic> map) {
    return AssetModel(
      id: map['id'],
      dossierId: map['dossier_id'],
      personId: map['person_id'],
      name: map['name'],
      category: AssetCategory.values.firstWhere((e) => e.name == map['category']),
      subType: map['sub_type'],
      brand: map['brand'],
      model: map['model'],
      year: map['year'],
      serialNumber: map['serial_number'],
      condition: map['condition'] != null
          ? AssetCondition.values.firstWhere((e) => e.name == map['condition'])
          : null,
      color: map['color'],
      material: map['material'],
      mainPhotoPath: map['main_photo_path'],
      additionalPhotos: map['additional_photos'],
      purchaseDate: map['purchase_date'],
      purchasedFrom: map['purchased_from'],
      purchasePrice: map['purchase_price']?.toDouble(),
      purchaseProofPath: map['purchase_proof_path'],
      paymentMethod: map['payment_method'],
      origin: map['origin'] != null
          ? AssetOrigin.values.firstWhere((e) => e.name == map['origin'])
          : null,
      originPersonName: map['origin_person_name'],
      originDate: map['origin_date'],
      currentValue: map['current_value']?.toDouble(),
      valuationBasis: map['valuation_basis'] != null
          ? ValuationBasis.values.firstWhere((e) => e.name == map['valuation_basis'])
          : null,
      lastValuationDate: map['last_valuation_date'],
      appraiserName: map['appraiser_name'],
      appraisalDate: map['appraisal_date'],
      appraisedValue: map['appraised_value']?.toDouble(),
      appraisalReportPath: map['appraisal_report_path'],
      appraisalPurpose: map['appraisal_purpose'],
      isInsured: map['is_insured'] == 1,
      insuranceType: map['insurance_type'] != null
          ? InsuranceType.values.firstWhere((e) => e.name == map['insurance_type'])
          : null,
      insurerName: map['insurer_name'],
      policyNumber: map['policy_number'],
      insuredAmount: map['insured_amount']?.toDouble(),
      linkedInsuranceId: map['linked_insurance_id'],
      insurancePhotosPath: map['insurance_photos_path'],
      locationType: map['location_type'] != null
          ? AssetLocationType.values.firstWhere((e) => e.name == map['location_type'])
          : null,
      locationDetails: map['location_details'],
      specificLocation: map['specific_location'],
      locationPhotoPath: map['location_photo_path'],
      accessibility: map['accessibility'] != null
          ? AccessibilityType.values.firstWhere((e) => e.name == map['accessibility'])
          : null,
      keyLocation: map['key_location'],
      codeLocation: map['code_location'],
      accessViaPersonName: map['access_via_person_name'],
      alternativeLocations: map['alternative_locations'],
      hasWarranty: map['has_warranty'] == 1,
      warrantyYears: map['warranty_years'],
      warrantyExpiryDate: map['warranty_expiry_date'],
      warrantyProofPath: map['warranty_proof_path'],
      warrantyProvider: map['warranty_provider'],
      maintenanceHistory: map['maintenance_history'],
      maintenanceIntervalMonths: map['maintenance_interval_months'],
      lastMaintenanceDate: map['last_maintenance_date'],
      nextMaintenanceDate: map['next_maintenance_date'],
      maintenanceReminder: map['maintenance_reminder'] == 1,
      hasHeir: map['has_heir'] == 1,
      inheritanceDestination: map['inheritance_destination'] != null
          ? InheritanceDestination.values.firstWhere((e) => e.name == map['inheritance_destination'])
          : null,
      heirPersonId: map['heir_person_id'],
      heirPersonName: map['heir_person_name'],
      inheritanceReason: map['inheritance_reason'],
      sentimentalValue: map['sentimental_value'] != null
          ? SentimentalValue.values.firstWhere((e) => e.name == map['sentimental_value'])
          : null,
      mentionedInWill: map['mentioned_in_will'] == 1,
      heirInstructions: map['heir_instructions'],
      sellingSuggestions: map['selling_suggestions'],
      estimatedSellingPrice: map['estimated_selling_price']?.toDouble(),
      estimatedSellingTime: map['estimated_selling_time'],
      authenticity: map['authenticity'] != null
          ? AuthenticityStatus.values.firstWhere((e) => e.name == map['authenticity'])
          : null,
      hasCertificateOfAuthenticity: map['has_certificate_of_authenticity'] == 1,
      certificatePath: map['certificate_path'],
      hasProvenance: map['has_provenance'] == 1,
      provenancePath: map['provenance_path'],
      expertName: map['expert_name'],
      registrationNumber: map['registration_number'],
      specificationsJson: map['specifications_json'],
      maintenanceCompany: map['maintenance_company'],
      maintenancePhone: map['maintenance_phone'],
      maintenanceEmail: map['maintenance_email'],
      maintenanceWebsite: map['maintenance_website'],
      maintenanceAddress: map['maintenance_address'],
      dealerCompany: map['dealer_company'],
      dealerContact: map['dealer_contact'],
      dealerPhone: map['dealer_phone'],
      auctionAccounts: map['auction_accounts'],
      story: map['story'],
      specialMemories: map['special_memories'],
      whyValuable: map['why_valuable'],
      notes: map['notes'],
      status: map['status'] != null
          ? AssetItemStatus.values.firstWhere((e) => e.name == map['status'])
          : AssetItemStatus.notStarted,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  AssetModel copyWith({
    String? id,
    String? dossierId,
    String? personId,
    String? name,
    AssetCategory? category,
    String? subType,
    String? brand,
    String? model,
    int? year,
    String? serialNumber,
    AssetCondition? condition,
    String? color,
    String? material,
    String? mainPhotoPath,
    String? additionalPhotos,
    String? purchaseDate,
    String? purchasedFrom,
    double? purchasePrice,
    String? purchaseProofPath,
    String? paymentMethod,
    AssetOrigin? origin,
    String? originPersonName,
    String? originDate,
    double? currentValue,
    ValuationBasis? valuationBasis,
    String? lastValuationDate,
    String? appraiserName,
    String? appraisalDate,
    double? appraisedValue,
    String? appraisalReportPath,
    String? appraisalPurpose,
    bool? isInsured,
    InsuranceType? insuranceType,
    String? insurerName,
    String? policyNumber,
    double? insuredAmount,
    String? linkedInsuranceId,
    String? insurancePhotosPath,
    AssetLocationType? locationType,
    String? locationDetails,
    String? specificLocation,
    String? locationPhotoPath,
    AccessibilityType? accessibility,
    String? keyLocation,
    String? codeLocation,
    String? accessViaPersonName,
    String? alternativeLocations,
    bool? hasWarranty,
    int? warrantyYears,
    String? warrantyExpiryDate,
    String? warrantyProofPath,
    String? warrantyProvider,
    String? maintenanceHistory,
    int? maintenanceIntervalMonths,
    String? lastMaintenanceDate,
    String? nextMaintenanceDate,
    bool? maintenanceReminder,
    bool? hasHeir,
    InheritanceDestination? inheritanceDestination,
    String? heirPersonId,
    String? heirPersonName,
    String? inheritanceReason,
    SentimentalValue? sentimentalValue,
    bool? mentionedInWill,
    String? heirInstructions,
    String? sellingSuggestions,
    double? estimatedSellingPrice,
    String? estimatedSellingTime,
    AuthenticityStatus? authenticity,
    bool? hasCertificateOfAuthenticity,
    String? certificatePath,
    bool? hasProvenance,
    String? provenancePath,
    String? expertName,
    String? registrationNumber,
    String? specificationsJson,
    String? maintenanceCompany,
    String? maintenancePhone,
    String? maintenanceEmail,
    String? maintenanceWebsite,
    String? maintenanceAddress,
    String? dealerCompany,
    String? dealerContact,
    String? dealerPhone,
    String? auctionAccounts,
    String? story,
    String? specialMemories,
    String? whyValuable,
    String? notes,
    AssetItemStatus? status,
    String? createdAt,
    String? updatedAt,
  }) {
    return AssetModel(
      id: id ?? this.id,
      dossierId: dossierId ?? this.dossierId,
      personId: personId ?? this.personId,
      name: name ?? this.name,
      category: category ?? this.category,
      subType: subType ?? this.subType,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      serialNumber: serialNumber ?? this.serialNumber,
      condition: condition ?? this.condition,
      color: color ?? this.color,
      material: material ?? this.material,
      mainPhotoPath: mainPhotoPath ?? this.mainPhotoPath,
      additionalPhotos: additionalPhotos ?? this.additionalPhotos,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      purchasedFrom: purchasedFrom ?? this.purchasedFrom,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseProofPath: purchaseProofPath ?? this.purchaseProofPath,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      origin: origin ?? this.origin,
      originPersonName: originPersonName ?? this.originPersonName,
      originDate: originDate ?? this.originDate,
      currentValue: currentValue ?? this.currentValue,
      valuationBasis: valuationBasis ?? this.valuationBasis,
      lastValuationDate: lastValuationDate ?? this.lastValuationDate,
      appraiserName: appraiserName ?? this.appraiserName,
      appraisalDate: appraisalDate ?? this.appraisalDate,
      appraisedValue: appraisedValue ?? this.appraisedValue,
      appraisalReportPath: appraisalReportPath ?? this.appraisalReportPath,
      appraisalPurpose: appraisalPurpose ?? this.appraisalPurpose,
      isInsured: isInsured ?? this.isInsured,
      insuranceType: insuranceType ?? this.insuranceType,
      insurerName: insurerName ?? this.insurerName,
      policyNumber: policyNumber ?? this.policyNumber,
      insuredAmount: insuredAmount ?? this.insuredAmount,
      linkedInsuranceId: linkedInsuranceId ?? this.linkedInsuranceId,
      insurancePhotosPath: insurancePhotosPath ?? this.insurancePhotosPath,
      locationType: locationType ?? this.locationType,
      locationDetails: locationDetails ?? this.locationDetails,
      specificLocation: specificLocation ?? this.specificLocation,
      locationPhotoPath: locationPhotoPath ?? this.locationPhotoPath,
      accessibility: accessibility ?? this.accessibility,
      keyLocation: keyLocation ?? this.keyLocation,
      codeLocation: codeLocation ?? this.codeLocation,
      accessViaPersonName: accessViaPersonName ?? this.accessViaPersonName,
      alternativeLocations: alternativeLocations ?? this.alternativeLocations,
      hasWarranty: hasWarranty ?? this.hasWarranty,
      warrantyYears: warrantyYears ?? this.warrantyYears,
      warrantyExpiryDate: warrantyExpiryDate ?? this.warrantyExpiryDate,
      warrantyProofPath: warrantyProofPath ?? this.warrantyProofPath,
      warrantyProvider: warrantyProvider ?? this.warrantyProvider,
      maintenanceHistory: maintenanceHistory ?? this.maintenanceHistory,
      maintenanceIntervalMonths: maintenanceIntervalMonths ?? this.maintenanceIntervalMonths,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      maintenanceReminder: maintenanceReminder ?? this.maintenanceReminder,
      hasHeir: hasHeir ?? this.hasHeir,
      inheritanceDestination: inheritanceDestination ?? this.inheritanceDestination,
      heirPersonId: heirPersonId ?? this.heirPersonId,
      heirPersonName: heirPersonName ?? this.heirPersonName,
      inheritanceReason: inheritanceReason ?? this.inheritanceReason,
      sentimentalValue: sentimentalValue ?? this.sentimentalValue,
      mentionedInWill: mentionedInWill ?? this.mentionedInWill,
      heirInstructions: heirInstructions ?? this.heirInstructions,
      sellingSuggestions: sellingSuggestions ?? this.sellingSuggestions,
      estimatedSellingPrice: estimatedSellingPrice ?? this.estimatedSellingPrice,
      estimatedSellingTime: estimatedSellingTime ?? this.estimatedSellingTime,
      authenticity: authenticity ?? this.authenticity,
      hasCertificateOfAuthenticity: hasCertificateOfAuthenticity ?? this.hasCertificateOfAuthenticity,
      certificatePath: certificatePath ?? this.certificatePath,
      hasProvenance: hasProvenance ?? this.hasProvenance,
      provenancePath: provenancePath ?? this.provenancePath,
      expertName: expertName ?? this.expertName,
      registrationNumber: registrationNumber ?? this.registrationNumber,
      specificationsJson: specificationsJson ?? this.specificationsJson,
      maintenanceCompany: maintenanceCompany ?? this.maintenanceCompany,
      maintenancePhone: maintenancePhone ?? this.maintenancePhone,
      maintenanceEmail: maintenanceEmail ?? this.maintenanceEmail,
      maintenanceWebsite: maintenanceWebsite ?? this.maintenanceWebsite,
      maintenanceAddress: maintenanceAddress ?? this.maintenanceAddress,
      dealerCompany: dealerCompany ?? this.dealerCompany,
      dealerContact: dealerContact ?? this.dealerContact,
      dealerPhone: dealerPhone ?? this.dealerPhone,
      auctionAccounts: auctionAccounts ?? this.auctionAccounts,
      story: story ?? this.story,
      specialMemories: specialMemories ?? this.specialMemories,
      whyValuable: whyValuable ?? this.whyValuable,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Berekent het volledigheidspercentage
  int get completenessPercentage {
    int filledFields = 0;
    int totalFields = 15; // Belangrijkste velden

    if (name.isNotEmpty) filledFields++;
    if (mainPhotoPath != null && mainPhotoPath!.isNotEmpty) filledFields++;
    if (currentValue != null && currentValue! > 0) filledFields++;
    if (purchasePrice != null && purchasePrice! > 0) filledFields++;
    if (locationType != null) filledFields++;
    if (specificLocation != null && specificLocation!.isNotEmpty) filledFields++;
    if (hasHeir || inheritanceDestination != null) filledFields++;
    if (isInsured) filledFields++;
    if (condition != null) filledFields++;
    if (brand != null && brand!.isNotEmpty) filledFields++;
    if (serialNumber != null && serialNumber!.isNotEmpty) filledFields++;
    if (purchaseDate != null && purchaseDate!.isNotEmpty) filledFields++;
    if (sentimentalValue != null) filledFields++;
    if (story != null && story!.isNotEmpty) filledFields++;
    if (heirInstructions != null && heirInstructions!.isNotEmpty) filledFields++;

    return ((filledFields / totalFields) * 100).toInt().clamp(0, 100);
  }

  /// Berekent de waarde-ontwikkeling als percentage
  double? get valueGrowthPercentage {
    if (purchasePrice == null || purchasePrice == 0 || currentValue == null) {
      return null;
    }
    return ((currentValue! - purchasePrice!) / purchasePrice!) * 100;
  }

  /// Geeft de effectieve waarde terug (currentValue of purchasePrice)
  double get effectiveValue => currentValue ?? purchasePrice ?? 0;
}
