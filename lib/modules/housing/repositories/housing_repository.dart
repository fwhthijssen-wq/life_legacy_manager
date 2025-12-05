// lib/modules/housing/repositories/housing_repository.dart
// Repository voor Wonen & Energie module

import 'package:uuid/uuid.dart';
import '../../../core/app_database.dart';
import '../models/property_model.dart';
import '../models/mortgage_model.dart';
import '../models/energy_contract_model.dart';
import '../models/installation_model.dart';
import '../models/rental_contract_model.dart';
import '../models/housing_enums.dart';

class HousingRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  HousingRepository(this._db);

  // ==================== Properties ====================

  Future<List<PropertyModel>> getPropertiesForDossier(String dossierId) async {
    final results = await _db.query(
      'properties',
      where: 'dossier_id = ?',
      whereArgs: [dossierId],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => PropertyModel.fromMap(m)).toList();
  }

  Future<PropertyModel?> getProperty(String id) async {
    final results = await _db.query(
      'properties',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return PropertyModel.fromMap(results.first);
  }

  Future<String> createProperty({
    required String dossierId,
    required String personId,
    String? name,
    PropertyType propertyType = PropertyType.singleFamily,
    OwnershipType ownershipType = OwnershipType.owned,
  }) async {
    final id = _uuid.v4();
    final property = PropertyModel(
      id: id,
      dossierId: dossierId,
      personId: personId,
      name: name,
      propertyType: propertyType,
      ownershipType: ownershipType,
      createdAt: DateTime.now(),
    );
    await _db.insert('properties', property.toMap());
    return id;
  }

  Future<void> updateProperty(PropertyModel property) async {
    await _db.update(
      'properties',
      property.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [property.id],
    );
  }

  Future<void> deleteProperty(String id) async {
    await _db.delete('properties', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Mortgages ====================

  Future<List<MortgageModel>> getMortgagesForProperty(String propertyId) async {
    final results = await _db.query(
      'mortgages',
      where: 'property_id = ?',
      whereArgs: [propertyId],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => MortgageModel.fromMap(m)).toList();
  }

  Future<MortgageModel?> getMortgage(String id) async {
    final results = await _db.query(
      'mortgages',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return MortgageModel.fromMap(results.first);
  }

  Future<String> createMortgage({
    required String propertyId,
    String? provider,
  }) async {
    final id = _uuid.v4();
    final map = {
      'id': id,
      'property_id': propertyId,
      'provider': provider,
      'status': HousingItemStatus.notStarted.name,
      'created_at': DateTime.now().toIso8601String(),
    };
    await _db.insert('mortgages', map);
    return id;
  }

  Future<void> updateMortgage(MortgageModel mortgage) async {
    await _db.update(
      'mortgages',
      mortgage.toMap(),
      where: 'id = ?',
      whereArgs: [mortgage.id],
    );
  }

  Future<void> deleteMortgage(String id) async {
    await _db.delete('mortgages', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Mortgage Parts ====================

  Future<List<MortgagePartModel>> getMortgagePartsForMortgage(String mortgageId) async {
    final results = await _db.query(
      'mortgage_parts',
      where: 'mortgage_id = ?',
      whereArgs: [mortgageId],
    );
    return results.map((m) => MortgagePartModel.fromMap(m)).toList();
  }

  Future<String> createMortgagePart({
    required String mortgageId,
    MortgageType type = MortgageType.annuity,
    double? originalAmount,
    double? currentBalance,
    double? interestRate,
  }) async {
    final id = _uuid.v4();
    final part = MortgagePartModel(
      id: id,
      mortgageId: mortgageId,
      type: type,
      originalAmount: originalAmount,
      currentBalance: currentBalance,
      interestRate: interestRate,
    );
    await _db.insert('mortgage_parts', part.toMap());
    return id;
  }

  Future<void> updateMortgagePart(MortgagePartModel part) async {
    await _db.update(
      'mortgage_parts',
      part.toMap(),
      where: 'id = ?',
      whereArgs: [part.id],
    );
  }

  Future<void> deleteMortgagePart(String id) async {
    await _db.delete('mortgage_parts', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Energy Contracts ====================

  Future<List<EnergyContractModel>> getEnergyContractsForProperty(String propertyId) async {
    final results = await _db.query(
      'energy_contracts',
      where: 'property_id = ?',
      whereArgs: [propertyId],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => EnergyContractModel.fromMap(m)).toList();
  }

  Future<EnergyContractModel?> getEnergyContract(String id) async {
    final results = await _db.query(
      'energy_contracts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return EnergyContractModel.fromMap(results.first);
  }

  Future<String> createEnergyContract({
    required String propertyId,
    EnergyType energyType = EnergyType.combined,
    String? provider,
  }) async {
    final id = _uuid.v4();
    final contract = EnergyContractModel(
      id: id,
      propertyId: propertyId,
      energyType: energyType,
      provider: provider,
      createdAt: DateTime.now(),
    );
    await _db.insert('energy_contracts', contract.toMap());
    return id;
  }

  Future<void> updateEnergyContract(EnergyContractModel contract) async {
    await _db.update(
      'energy_contracts',
      contract.toMap(),
      where: 'id = ?',
      whereArgs: [contract.id],
    );
  }

  Future<void> deleteEnergyContract(String id) async {
    await _db.delete('energy_contracts', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Installations ====================

  Future<List<InstallationModel>> getInstallationsForProperty(String propertyId) async {
    final results = await _db.query(
      'installations',
      where: 'property_id = ?',
      whereArgs: [propertyId],
      orderBy: 'installation_type, created_at DESC',
    );
    return results.map((m) => InstallationModel.fromMap(m)).toList();
  }

  Future<InstallationModel?> getInstallation(String id) async {
    final results = await _db.query(
      'installations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return InstallationModel.fromMap(results.first);
  }

  Future<String> createInstallation({
    required String propertyId,
    InstallationType installationType = InstallationType.other,
    String? brand,
    String? model,
  }) async {
    final id = _uuid.v4();
    final installation = InstallationModel(
      id: id,
      propertyId: propertyId,
      installationType: installationType,
      brand: brand,
      model: model,
      createdAt: DateTime.now(),
    );
    await _db.insert('installations', installation.toMap());
    return id;
  }

  Future<void> updateInstallation(InstallationModel installation) async {
    await _db.update(
      'installations',
      installation.toMap(),
      where: 'id = ?',
      whereArgs: [installation.id],
    );
  }

  Future<void> deleteInstallation(String id) async {
    await _db.delete('installations', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Rental Contracts ====================

  Future<List<RentalContractModel>> getRentalContractsForProperty(String propertyId) async {
    final results = await _db.query(
      'rental_contracts',
      where: 'property_id = ?',
      whereArgs: [propertyId],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => RentalContractModel.fromMap(m)).toList();
  }

  Future<RentalContractModel?> getRentalContract(String id) async {
    final results = await _db.query(
      'rental_contracts',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return RentalContractModel.fromMap(results.first);
  }

  Future<String> createRentalContract({
    required String propertyId,
    LandlordType landlordType = LandlordType.private,
    String? landlordName,
  }) async {
    final id = _uuid.v4();
    final contract = RentalContractModel(
      id: id,
      propertyId: propertyId,
      landlordType: landlordType,
      landlordName: landlordName,
      createdAt: DateTime.now(),
    );
    await _db.insert('rental_contracts', contract.toMap());
    return id;
  }

  Future<void> updateRentalContract(RentalContractModel contract) async {
    await _db.update(
      'rental_contracts',
      contract.toMap(),
      where: 'id = ?',
      whereArgs: [contract.id],
    );
  }

  Future<void> deleteRentalContract(String id) async {
    await _db.delete('rental_contracts', where: 'id = ?', whereArgs: [id]);
  }

  // ==================== Statistics ====================

  Future<HousingStats> getStatsForDossier(String dossierId) async {
    final properties = await getPropertiesForDossier(dossierId);
    
    int totalMortgages = 0;
    int totalEnergyContracts = 0;
    int totalInstallations = 0;
    int completedItems = 0;
    int totalItems = 0;

    for (final property in properties) {
      totalItems++;
      if (property.status == HousingItemStatus.complete) completedItems++;

      final mortgages = await getMortgagesForProperty(property.id);
      totalMortgages += mortgages.length;
      totalItems += mortgages.length;
      completedItems += mortgages.where((m) => m.status == HousingItemStatus.complete).length;

      final energyContracts = await getEnergyContractsForProperty(property.id);
      totalEnergyContracts += energyContracts.length;
      totalItems += energyContracts.length;
      completedItems += energyContracts.where((e) => e.status == HousingItemStatus.complete).length;

      final installations = await getInstallationsForProperty(property.id);
      totalInstallations += installations.length;
      totalItems += installations.length;
      completedItems += installations.where((i) => i.status == HousingItemStatus.complete).length;
    }

    return HousingStats(
      propertyCount: properties.length,
      mortgageCount: totalMortgages,
      energyContractCount: totalEnergyContracts,
      installationCount: totalInstallations,
      completenessPercentage: totalItems > 0 ? ((completedItems / totalItems) * 100).round() : 0,
    );
  }
}

/// Statistieken voor de Housing module
class HousingStats {
  final int propertyCount;
  final int mortgageCount;
  final int energyContractCount;
  final int installationCount;
  final int completenessPercentage;

  HousingStats({
    required this.propertyCount,
    required this.mortgageCount,
    required this.energyContractCount,
    required this.installationCount,
    required this.completenessPercentage,
  });

  int get totalItems => propertyCount + mortgageCount + energyContractCount + installationCount;
}

