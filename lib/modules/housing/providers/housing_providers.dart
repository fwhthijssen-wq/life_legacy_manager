// lib/modules/housing/providers/housing_providers.dart
// Riverpod providers voor Wonen & Energie module

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_database.dart';
import '../repositories/housing_repository.dart';
import '../models/property_model.dart';
import '../models/mortgage_model.dart';
import '../models/energy_contract_model.dart';
import '../models/installation_model.dart';
import '../models/rental_contract_model.dart';

/// Provider voor HousingRepository
final housingRepositoryProvider = Provider<HousingRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return HousingRepository(db);
});

/// Properties voor een dossier
final propertiesProvider = FutureProvider.family<List<PropertyModel>, String>((ref, dossierId) async {
  final repo = ref.watch(housingRepositoryProvider);
  return repo.getPropertiesForDossier(dossierId);
});

/// Enkele property ophalen
final propertyByIdProvider = FutureProvider.family<PropertyModel?, String>((ref, propertyId) async {
  final repo = ref.watch(housingRepositoryProvider);
  return repo.getProperty(propertyId);
});

/// Hypotheken voor een property
final mortgagesProvider = FutureProvider.family<List<MortgageModel>, String>((ref, propertyId) async {
  final repo = ref.watch(housingRepositoryProvider);
  return repo.getMortgagesForProperty(propertyId);
});

/// Enkele hypotheek ophalen
final mortgageByIdProvider = FutureProvider.family<MortgageModel?, String>((ref, mortgageId) async {
  final repo = ref.watch(housingRepositoryProvider);
  return repo.getMortgage(mortgageId);
});

/// Hypotheekdelen voor een hypotheek
final mortgagePartsProvider = FutureProvider.family<List<MortgagePartModel>, String>((ref, mortgageId) async {
  final repo = ref.watch(housingRepositoryProvider);
  return repo.getMortgagePartsForMortgage(mortgageId);
});

/// Energiecontracten voor een property
final energyContractsProvider = FutureProvider.family<List<EnergyContractModel>, String>((ref, propertyId) async {
  final repo = ref.watch(housingRepositoryProvider);
  return repo.getEnergyContractsForProperty(propertyId);
});

/// Enkel energiecontract ophalen
final energyContractByIdProvider = FutureProvider.family<EnergyContractModel?, String>((ref, contractId) async {
  final repo = ref.watch(housingRepositoryProvider);
  return repo.getEnergyContract(contractId);
});

/// Installaties voor een property
final installationsProvider = FutureProvider.family<List<InstallationModel>, String>((ref, propertyId) async {
  final repo = ref.watch(housingRepositoryProvider);
  return repo.getInstallationsForProperty(propertyId);
});

/// Enkele installatie ophalen
final installationByIdProvider = FutureProvider.family<InstallationModel?, String>((ref, installationId) async {
  final repo = ref.watch(housingRepositoryProvider);
  return repo.getInstallation(installationId);
});

/// Huurcontracten voor een property
final rentalContractsProvider = FutureProvider.family<List<RentalContractModel>, String>((ref, propertyId) async {
  final repo = ref.watch(housingRepositoryProvider);
  return repo.getRentalContractsForProperty(propertyId);
});

/// Enkel huurcontract ophalen
final rentalContractByIdProvider = FutureProvider.family<RentalContractModel?, String>((ref, contractId) async {
  final repo = ref.watch(housingRepositoryProvider);
  return repo.getRentalContract(contractId);
});

/// Statistieken voor een dossier
final housingStatsProvider = FutureProvider.family<HousingStats, String>((ref, dossierId) async {
  final repo = ref.watch(housingRepositoryProvider);
  return repo.getStatsForDossier(dossierId);
});

/// Geselecteerde property (voor navigatie binnen module)
final selectedPropertyIdProvider = StateProvider<String?>((ref) => null);

