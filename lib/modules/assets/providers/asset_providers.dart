// lib/modules/assets/providers/asset_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/module_stats.dart';
import '../models/asset_model.dart';
import '../models/asset_document_model.dart';
import '../models/asset_enums.dart';
import '../repositories/asset_repository.dart';

/// Provider voor alle bezittingen in een dossier
final assetsForDossierProvider = FutureProvider.family<List<AssetModel>, String>((ref, dossierId) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAssetsForDossier(dossierId);
});

/// Provider voor bezittingen per categorie
final assetsForCategoryProvider = FutureProvider.family<List<AssetModel>, ({String dossierId, AssetCategory category})>((ref, params) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAssetsForCategory(params.dossierId, params.category);
});

/// Provider voor bezittingen van een specifieke persoon
final assetsForPersonProvider = FutureProvider.family<List<AssetModel>, ({String dossierId, String personId})>((ref, params) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAssetsForPerson(params.dossierId, params.personId);
});

/// Provider voor een specifieke bezitting
final assetByIdProvider = FutureProvider.family<AssetModel?, String>((ref, id) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAsset(id);
});

/// Provider voor documenten van een bezitting
final assetDocumentsProvider = FutureProvider.family<List<AssetDocumentModel>, String>((ref, assetId) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getDocumentsForAsset(assetId);
});

/// Provider voor module statistieken
final assetStatsProvider = FutureProvider.family<ModuleStats, String>((ref, dossierId) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAssetStats(dossierId);
});

/// Provider voor categorie statistieken
final assetCategoryStatsProvider = FutureProvider.family<Map<AssetCategory, CategoryStats>, String>((ref, dossierId) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getCategoryStats(dossierId);
});

/// Provider voor waarde overzicht
final assetValueOverviewProvider = FutureProvider.family<ValueOverview, String>((ref, dossierId) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getValueOverview(dossierId);
});

/// Provider voor top waardevolle items
final topValueAssetsProvider = FutureProvider.family<List<AssetModel>, String>((ref, dossierId) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getTopValueAssets(dossierId);
});

/// Provider voor items zonder erfgenaam
final assetsWithoutHeirProvider = FutureProvider.family<List<AssetModel>, String>((ref, dossierId) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getAssetsWithoutHeir(dossierId);
});

/// Provider voor niet-verzekerde items
final uninsuredAssetsProvider = FutureProvider.family<List<AssetModel>, String>((ref, dossierId) async {
  final repository = ref.watch(assetRepositoryProvider);
  return repository.getUninsuredAssets(dossierId);
});
