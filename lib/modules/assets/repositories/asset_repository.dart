// lib/modules/assets/repositories/asset_repository.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/app_database.dart';
import '../../../core/models/module_stats.dart';
import '../models/asset_model.dart';
import '../models/asset_document_model.dart';
import '../models/asset_enums.dart';

final assetRepositoryProvider = Provider<AssetRepository>((ref) {
  return AssetRepository(ref.read(appDatabaseProvider));
});

class AssetRepository {
  final AppDatabase _appDatabase;

  AssetRepository(this._appDatabase);

  Future<Database> get _db async => _appDatabase.database;

  // ==================== ASSETS ====================

  /// Haal alle bezittingen op voor een dossier
  Future<List<AssetModel>> getAssetsForDossier(String dossierId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'dossier_id = ?',
      whereArgs: [dossierId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => _mapToAssetModel(map)).toList();
  }

  /// Haal bezittingen op per categorie
  Future<List<AssetModel>> getAssetsForCategory(
    String dossierId,
    AssetCategory category,
  ) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'dossier_id = ? AND category = ?',
      whereArgs: [dossierId, category.name],
      orderBy: 'name ASC',
    );
    return maps.map((map) => _mapToAssetModel(map)).toList();
  }

  /// Haal bezittingen op voor een persoon
  Future<List<AssetModel>> getAssetsForPerson(
    String dossierId,
    String personId,
  ) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'dossier_id = ? AND person_id = ?',
      whereArgs: [dossierId, personId],
      orderBy: 'name ASC',
    );
    return maps.map((map) => _mapToAssetModel(map)).toList();
  }

  /// Haal een specifieke bezitting op
  Future<AssetModel?> getAsset(String id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return _mapToAssetModel(maps.first);
    }
    return null;
  }

  /// Maak een nieuwe bezitting aan
  Future<AssetModel> createAsset(AssetModel asset) async {
    final db = await _db;
    final map = _assetModelToMap(asset);
    map['created_at'] = DateTime.now().toIso8601String();
    await db.insert('assets', map, conflictAlgorithm: ConflictAlgorithm.replace);
    return asset;
  }

  /// Update een bezitting
  Future<void> updateAsset(AssetModel asset) async {
    final db = await _db;
    final map = _assetModelToMap(asset);
    map['updated_at'] = DateTime.now().toIso8601String();
    await db.update(
      'assets',
      map,
      where: 'id = ?',
      whereArgs: [asset.id],
    );
  }

  /// Verwijder een bezitting
  Future<void> deleteAsset(String id) async {
    final db = await _db;
    await db.delete(
      'assets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== DOCUMENTEN ====================

  /// Haal documenten op voor een bezitting
  Future<List<AssetDocumentModel>> getDocumentsForAsset(String assetId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'asset_documents',
      where: 'asset_id = ?',
      whereArgs: [assetId],
      orderBy: 'created_at DESC',
    );
    return maps.map((map) => AssetDocumentModel.fromMap(map)).toList();
  }

  /// Voeg document toe
  Future<AssetDocumentModel> createDocument(AssetDocumentModel doc) async {
    final db = await _db;
    await db.insert('asset_documents', doc.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return doc;
  }

  /// Verwijder document
  Future<void> deleteDocument(String id) async {
    final db = await _db;
    await db.delete(
      'asset_documents',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== STATISTIEKEN ====================

  /// Haal statistieken op voor dashboard
  Future<ModuleStats> getAssetStats(String dossierId) async {
    final assets = await getAssetsForDossier(dossierId);
    
    if (assets.isEmpty) {
      return ModuleStats(totalItems: 0, completedItems: 0, averagePercentage: 0);
    }

    int totalPercentage = 0;
    int completedCount = 0;

    for (final asset in assets) {
      final percentage = asset.completenessPercentage;
      totalPercentage += percentage;
      if (percentage >= 80) {
        completedCount++;
      }
    }

    return ModuleStats(
      totalItems: assets.length,
      completedItems: completedCount,
      averagePercentage: (totalPercentage / assets.length).round(),
    );
  }

  /// Haal statistieken per categorie
  Future<Map<AssetCategory, CategoryStats>> getCategoryStats(
    String dossierId,
  ) async {
    final assets = await getAssetsForDossier(dossierId);
    final Map<AssetCategory, CategoryStats> stats = {};

    for (final category in AssetCategory.values) {
      final categoryAssets =
          assets.where((a) => a.category == category).toList();
      
      double totalValue = 0;
      int totalPercentage = 0;
      int heirAssignedCount = 0;
      int insuredCount = 0;

      for (final asset in categoryAssets) {
        totalValue += asset.effectiveValue;
        totalPercentage += asset.completenessPercentage;
        if (asset.hasHeir || asset.inheritanceDestination != null) {
          heirAssignedCount++;
        }
        if (asset.isInsured) {
          insuredCount++;
        }
      }

      stats[category] = CategoryStats(
        itemCount: categoryAssets.length,
        totalValue: totalValue,
        averageCompleteness: categoryAssets.isNotEmpty
            ? (totalPercentage / categoryAssets.length).round()
            : 0,
        heirAssignedCount: heirAssignedCount,
        insuredCount: insuredCount,
      );
    }

    return stats;
  }

  /// Haal totale waarde overzicht
  Future<ValueOverview> getValueOverview(String dossierId) async {
    final assets = await getAssetsForDossier(dossierId);
    
    double totalCurrentValue = 0;
    double totalPurchaseValue = 0;
    int heirAssignedCount = 0;
    int insuredCount = 0;

    for (final asset in assets) {
      totalCurrentValue += asset.currentValue ?? 0;
      totalPurchaseValue += asset.purchasePrice ?? 0;
      if (asset.hasHeir || asset.inheritanceDestination != null) {
        heirAssignedCount++;
      }
      if (asset.isInsured) {
        insuredCount++;
      }
    }

    return ValueOverview(
      totalItems: assets.length,
      totalCurrentValue: totalCurrentValue,
      totalPurchaseValue: totalPurchaseValue,
      heirAssignedCount: heirAssignedCount,
      insuredCount: insuredCount,
    );
  }

  /// Haal top waardevolle items
  Future<List<AssetModel>> getTopValueAssets(
    String dossierId, {
    int limit = 10,
  }) async {
    final assets = await getAssetsForDossier(dossierId);
    assets.sort((a, b) => b.effectiveValue.compareTo(a.effectiveValue));
    return assets.take(limit).toList();
  }

  /// Haal items zonder erfgenaam
  Future<List<AssetModel>> getAssetsWithoutHeir(String dossierId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'dossier_id = ? AND heir_assigned = 0 AND inheritance_destination IS NULL',
      whereArgs: [dossierId],
      orderBy: 'current_value DESC',
    );
    return maps.map((map) => _mapToAssetModel(map)).toList();
  }

  /// Haal niet-verzekerde items
  Future<List<AssetModel>> getUninsuredAssets(String dossierId) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'assets',
      where: 'dossier_id = ? AND is_insured = 0',
      whereArgs: [dossierId],
      orderBy: 'current_value DESC',
    );
    return maps.map((map) => _mapToAssetModel(map)).toList();
  }

  // ==================== HELPERS ====================

  AssetModel _mapToAssetModel(Map<String, dynamic> map) {
    return AssetModel(
      id: map['id'],
      dossierId: map['dossier_id'],
      personId: map['person_id'],
      name: map['name'],
      category: AssetCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AssetCategory.other,
      ),
      subType: map['sub_category'],
      brand: map['brand'],
      model: map['model'],
      year: map['year'],
      serialNumber: map['serial_number'],
      condition: map['condition'] != null
          ? AssetCondition.values.firstWhere(
              (e) => e.name == map['condition'],
              orElse: () => AssetCondition.good,
            )
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
          ? AssetOrigin.values.firstWhere(
              (e) => e.name == map['origin'],
              orElse: () => AssetOrigin.boughtNew,
            )
          : null,
      originPersonName: map['inherited_from'] ?? map['gift_from'],
      originDate: map['gift_date'],
      currentValue: map['current_value']?.toDouble(),
      valuationBasis: map['valuation_basis'] != null
          ? ValuationBasis.values.firstWhere(
              (e) => e.name == map['valuation_basis'],
              orElse: () => ValuationBasis.ownerEstimate,
            )
          : null,
      lastValuationDate: map['valuation_date'],
      appraiserName: map['appraiser_name'],
      appraisalDate: map['appraisal_date'],
      appraisedValue: map['appraised_value']?.toDouble(),
      appraisalReportPath: map['appraisal_report_path'],
      appraisalPurpose: map['appraisal_purpose'],
      isInsured: map['is_insured'] == 1,
      insuranceType: map['insurance_type'] != null
          ? InsuranceType.values.firstWhere(
              (e) => e.name == map['insurance_type'],
              orElse: () => InsuranceType.notInsured,
            )
          : null,
      insurerName: map['insurer_name'],
      policyNumber: map['policy_number'],
      insuredAmount: map['insured_amount']?.toDouble(),
      linkedInsuranceId: map['linked_insurance_id'],
      locationType: map['location_type'] != null
          ? AssetLocationType.values.firstWhere(
              (e) => e.name == map['location_type'],
              orElse: () => AssetLocationType.home,
            )
          : null,
      locationDetails: map['location_details'],
      specificLocation: map['location_photo_path'],
      accessibility: map['accessibility'] != null
          ? AccessibilityType.values.firstWhere(
              (e) => e.name == map['accessibility'],
              orElse: () => AccessibilityType.directAccess,
            )
          : null,
      keyLocation: map['key_location'],
      codeLocation: map['access_code'],
      accessViaPersonName: map['access_contact_person'],
      alternativeLocations: map['secondary_location'],
      hasWarranty: map['has_warranty'] == 1,
      warrantyYears: map['warranty_years'],
      warrantyExpiryDate: map['warranty_end_date'],
      warrantyProofPath: map['warranty_proof_path'],
      warrantyProvider: map['warranty_provider'],
      maintenanceIntervalMonths: map['maintenance_interval'] != null
          ? int.tryParse(map['maintenance_interval'].toString())
          : null,
      lastMaintenanceDate: map['last_maintenance_date'],
      nextMaintenanceDate: map['next_maintenance_date'],
      maintenanceReminder: map['maintenance_reminder'] == 1,
      hasHeir: map['heir_assigned'] == 1,
      inheritanceDestination: map['inheritance_destination'] != null
          ? InheritanceDestination.values.firstWhere(
              (e) => e.name == map['inheritance_destination'],
              orElse: () => InheritanceDestination.undecided,
            )
          : null,
      heirPersonId: map['heir_person_id'],
      inheritanceReason: map['inheritance_reason'],
      sentimentalValue: map['sentimental_value'] != null
          ? SentimentalValue.values.firstWhere(
              (e) => e.name == map['sentimental_value'],
              orElse: () => SentimentalValue.medium,
            )
          : null,
      mentionedInWill: map['mentioned_in_will'] == 1,
      heirInstructions: map['survivor_instructions'],
      sellingSuggestions: map['where_to_sell'],
      estimatedSellingPrice: map['estimated_sale_value']?.toDouble(),
      estimatedSellingTime: map['estimated_sale_time'],
      authenticity: map['authenticity'] != null
          ? AuthenticityStatus.values.firstWhere(
              (e) => e.name == map['authenticity'],
              orElse: () => AuthenticityStatus.unknown,
            )
          : null,
      hasCertificateOfAuthenticity: map['has_certificate_of_authenticity'] == 1,
      certificatePath: map['certificate_path'],
      hasProvenance: map['has_provenance'] == 1,
      provenancePath: map['provenance_path'],
      expertName: map['expert_name'],
      registrationNumber: map['registration_number'],
      specificationsJson: map['category_specific_data'],
      maintenanceCompany: map['maintenance_company'],
      maintenancePhone: map['maintenance_phone'],
      maintenanceEmail: map['maintenance_email'],
      maintenanceWebsite: map['maintenance_website'],
      maintenanceAddress: map['maintenance_address'],
      dealerCompany: map['dealer_company'],
      dealerContact: map['dealer_contact_person'],
      dealerPhone: map['dealer_phone'],
      auctionAccounts: map['auction_account'],
      story: map['story'],
      specialMemories: map['special_memories'],
      whyValuable: map['why_valuable'],
      notes: map['notes'],
      status: map['status'] != null
          ? AssetItemStatus.values.firstWhere(
              (e) => e.name == map['status'],
              orElse: () => AssetItemStatus.notStarted,
            )
          : AssetItemStatus.notStarted,
      createdAt: map['created_at'],
      updatedAt: map['updated_at'],
    );
  }

  Map<String, dynamic> _assetModelToMap(AssetModel asset) {
    return {
      'id': asset.id,
      'dossier_id': asset.dossierId,
      'person_id': asset.personId,
      'name': asset.name,
      'category': asset.category.name,
      'sub_category': asset.subType,
      'brand': asset.brand,
      'model': asset.model,
      'year': asset.year,
      'serial_number': asset.serialNumber,
      'condition': asset.condition?.name,
      'color': asset.color,
      'material': asset.material,
      'main_photo_path': asset.mainPhotoPath,
      'additional_photos': asset.additionalPhotos,
      'purchase_date': asset.purchaseDate,
      'purchased_from': asset.purchasedFrom,
      'purchase_price': asset.purchasePrice,
      'purchase_proof_path': asset.purchaseProofPath,
      'payment_method': asset.paymentMethod,
      'origin': asset.origin?.name,
      'inherited_from': asset.origin == AssetOrigin.inherited ? asset.originPersonName : null,
      'gift_from': asset.origin == AssetOrigin.gift ? asset.originPersonName : null,
      'gift_date': asset.originDate,
      'current_value': asset.currentValue,
      'valuation_basis': asset.valuationBasis?.name,
      'valuation_date': asset.lastValuationDate,
      'appraiser_name': asset.appraiserName,
      'appraisal_date': asset.appraisalDate,
      'appraised_value': asset.appraisedValue,
      'appraisal_report_path': asset.appraisalReportPath,
      'appraisal_purpose': asset.appraisalPurpose,
      'is_insured': asset.isInsured ? 1 : 0,
      'insurance_type': asset.insuranceType?.name,
      'insurer_name': asset.insurerName,
      'policy_number': asset.policyNumber,
      'insured_amount': asset.insuredAmount,
      'linked_insurance_id': asset.linkedInsuranceId,
      'location_type': asset.locationType?.name,
      'location_details': asset.locationDetails,
      'location_photo_path': asset.specificLocation,
      'accessibility': asset.accessibility?.name,
      'key_location': asset.keyLocation,
      'access_code': asset.codeLocation,
      'access_contact_person': asset.accessViaPersonName,
      'secondary_location': asset.alternativeLocations,
      'secondary_location_notes': null,
      'has_warranty': asset.hasWarranty ? 1 : 0,
      'warranty_years': asset.warrantyYears,
      'warranty_end_date': asset.warrantyExpiryDate,
      'warranty_proof_path': asset.warrantyProofPath,
      'warranty_provider': asset.warrantyProvider,
      'maintenance_interval': asset.maintenanceIntervalMonths?.toString(),
      'last_maintenance_date': asset.lastMaintenanceDate,
      'next_maintenance_date': asset.nextMaintenanceDate,
      'maintenance_reminder': asset.maintenanceReminder ? 1 : 0,
      'heir_assigned': asset.hasHeir ? 1 : 0,
      'heir_person_id': asset.heirPersonId,
      'inheritance_destination': asset.inheritanceDestination?.name,
      'charity_name': null,
      'inheritance_reason': asset.inheritanceReason,
      'sentimental_value': asset.sentimentalValue?.name,
      'mentioned_in_will': asset.mentionedInWill ? 1 : 0,
      'survivor_instructions': asset.heirInstructions,
      'where_to_sell': asset.sellingSuggestions,
      'dealer_contact': asset.dealerContact,
      'estimated_sale_value': asset.estimatedSellingPrice,
      'estimated_sale_time': asset.estimatedSellingTime,
      'authenticity': asset.authenticity?.name,
      'has_certificate_of_authenticity': asset.hasCertificateOfAuthenticity ? 1 : 0,
      'certificate_path': asset.certificatePath,
      'has_provenance': asset.hasProvenance ? 1 : 0,
      'provenance_path': asset.provenancePath,
      'expert_name': asset.expertName,
      'registration_number': asset.registrationNumber,
      'category_specific_data': asset.specificationsJson,
      'maintenance_company': asset.maintenanceCompany,
      'maintenance_phone': asset.maintenancePhone,
      'maintenance_email': asset.maintenanceEmail,
      'maintenance_website': asset.maintenanceWebsite,
      'maintenance_address': asset.maintenanceAddress,
      'dealer_company': asset.dealerCompany,
      'dealer_contact_person': asset.dealerContact,
      'dealer_phone': asset.dealerPhone,
      'auction_account': asset.auctionAccounts,
      'auction_username': null,
      'story': asset.story,
      'special_memories': asset.specialMemories,
      'why_valuable': asset.whyValuable,
      'notes': asset.notes,
      'status': asset.status.name,
      'created_at': asset.createdAt,
      'updated_at': asset.updatedAt,
    };
  }
}

/// Statistieken per categorie
class CategoryStats {
  final int itemCount;
  final double totalValue;
  final int averageCompleteness;
  final int heirAssignedCount;
  final int insuredCount;

  CategoryStats({
    required this.itemCount,
    required this.totalValue,
    required this.averageCompleteness,
    required this.heirAssignedCount,
    required this.insuredCount,
  });
}

/// Waarde overzicht
class ValueOverview {
  final int totalItems;
  final double totalCurrentValue;
  final double totalPurchaseValue;
  final int heirAssignedCount;
  final int insuredCount;

  ValueOverview({
    required this.totalItems,
    required this.totalCurrentValue,
    required this.totalPurchaseValue,
    required this.heirAssignedCount,
    required this.insuredCount,
  });

  double get valueGrowthPercentage {
    if (totalPurchaseValue == 0) return 0;
    return ((totalCurrentValue - totalPurchaseValue) / totalPurchaseValue) * 100;
  }
}
