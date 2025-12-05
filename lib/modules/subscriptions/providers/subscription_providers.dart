// lib/modules/subscriptions/providers/subscription_providers.dart
// Riverpod providers voor de Subscriptions module

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_database.dart';
import '../models/subscription_model.dart';
import '../models/subscription_enums.dart';
import '../repositories/subscription_repository.dart';

/// Repository provider
final subscriptionRepositoryProvider = Provider<SubscriptionRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return SubscriptionRepository(db);
});

/// Alle abonnementen voor een dossier
final subscriptionsProvider = FutureProvider.family<List<SubscriptionModel>, String>((ref, dossierId) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getSubscriptionsForDossier(dossierId);
});

/// Abonnementen per categorie
final subscriptionsByCategoryProvider = FutureProvider.family<List<SubscriptionModel>, ({String dossierId, SubscriptionCategory category})>((ref, params) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getSubscriptionsByCategory(params.dossierId, params.category);
});

/// Actieve abonnementen
final activeSubscriptionsProvider = FutureProvider.family<List<SubscriptionModel>, String>((ref, dossierId) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getActiveSubscriptions(dossierId);
});

/// Enkel abonnement ophalen
final subscriptionByIdProvider = FutureProvider.family<SubscriptionModel?, String>((ref, subscriptionId) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getSubscription(subscriptionId);
});

/// Statistieken voor dashboard
final subscriptionStatsProvider = FutureProvider.family<SubscriptionStats, String>((ref, dossierId) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getStatsForDossier(dossierId);
});

/// Verlopende abonnementen
final expiringSubscriptionsProvider = FutureProvider.family<List<SubscriptionModel>, String>((ref, dossierId) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getExpiringSubscriptions(dossierId);
});

/// Abonnementen per prioriteit (voor nabestaanden)
final subscriptionsByPriorityProvider = FutureProvider.family<Map<CancellationPriority, List<SubscriptionModel>>, String>((ref, dossierId) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  return repo.getSubscriptionsByPriority(dossierId);
});

/// Dashboard statistieken provider voor home screen
final subscriptionDashboardStatsProvider = FutureProvider.family<({int count, double monthlyCost, int percentage})?, String>((ref, dossierId) async {
  final repo = ref.watch(subscriptionRepositoryProvider);
  final stats = await repo.getStatsForDossier(dossierId);
  
  return (
    count: stats.totalActive,
    monthlyCost: stats.totalMonthly,
    percentage: stats.completenessPercentage,
  );
});





