// lib/modules/subscriptions/repositories/subscription_repository.dart
// Repository voor database operaties voor abonnementen

import 'package:uuid/uuid.dart';
import '../../../core/app_database.dart';
import '../models/subscription_model.dart';
import '../models/subscription_enums.dart';

class SubscriptionRepository {
  final AppDatabase _db;
  final _uuid = const Uuid();

  SubscriptionRepository(this._db);

  // ==================== Subscriptions ====================

  Future<List<SubscriptionModel>> getSubscriptionsForDossier(String dossierId) async {
    final results = await _db.query(
      'subscriptions',
      where: 'dossier_id = ?',
      whereArgs: [dossierId],
      orderBy: 'name ASC',
    );
    return results.map((m) => SubscriptionModel.fromMap(m)).toList();
  }

  Future<List<SubscriptionModel>> getSubscriptionsByCategory(
    String dossierId,
    SubscriptionCategory category,
  ) async {
    final results = await _db.query(
      'subscriptions',
      where: 'dossier_id = ? AND category = ?',
      whereArgs: [dossierId, category.name],
      orderBy: 'name ASC',
    );
    return results.map((m) => SubscriptionModel.fromMap(m)).toList();
  }

  Future<List<SubscriptionModel>> getActiveSubscriptions(String dossierId) async {
    final results = await _db.query(
      'subscriptions',
      where: 'dossier_id = ? AND status = ?',
      whereArgs: [dossierId, SubscriptionStatus.active.name],
      orderBy: 'name ASC',
    );
    return results.map((m) => SubscriptionModel.fromMap(m)).toList();
  }

  Future<SubscriptionModel?> getSubscription(String id) async {
    final results = await _db.query(
      'subscriptions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return SubscriptionModel.fromMap(results.first);
  }

  Future<String> createSubscription({
    required String dossierId,
    required String name,
    required SubscriptionCategory category,
    String? personId,
  }) async {
    final id = _uuid.v4();
    final subscription = SubscriptionModel(
      id: id,
      dossierId: dossierId,
      personId: personId,
      name: name,
      category: category,
      createdAt: DateTime.now(),
    );
    await _db.insert('subscriptions', subscription.toMap());
    return id;
  }

  Future<void> updateSubscription(SubscriptionModel subscription) async {
    await _db.update(
      'subscriptions',
      subscription.toMap(),
      where: 'id = ?',
      whereArgs: [subscription.id],
    );
  }

  Future<void> deleteSubscription(String id) async {
    // Eerst documenten verwijderen
    await _db.delete(
      'subscription_documents',
      where: 'subscription_id = ?',
      whereArgs: [id],
    );
    // Dan het abonnement
    await _db.delete(
      'subscriptions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ==================== Statistics ====================

  Future<SubscriptionStats> getStatsForDossier(String dossierId) async {
    final subscriptions = await getSubscriptionsForDossier(dossierId);
    final active = subscriptions.where((s) => s.status == SubscriptionStatus.active).toList();

    // Bereken totale kosten
    double totalMonthly = 0;
    for (final sub in active) {
      totalMonthly += sub.monthlyCost;
    }

    // Bereken kosten per categorie
    final costByCategory = <SubscriptionCategory, double>{};
    for (final sub in active) {
      costByCategory[sub.category] = (costByCategory[sub.category] ?? 0) + sub.monthlyCost;
    }

    // Tel items met naderende einddatum (binnen 30 dagen)
    final now = DateTime.now();
    int expiringCount = 0;
    for (final sub in active) {
      if (sub.contractEndDate != null) {
        try {
          final endDate = DateTime.parse(sub.contractEndDate!);
          if (endDate.difference(now).inDays <= 30) {
            expiringCount++;
          }
        } catch (_) {}
      }
      if (sub.lastCancellationDate != null) {
        try {
          final cancelDate = DateTime.parse(sub.lastCancellationDate!);
          if (cancelDate.difference(now).inDays <= 30) {
            expiringCount++;
          }
        } catch (_) {}
      }
    }

    // Bereken gemiddelde volledigheid
    int totalCompleteness = 0;
    for (final sub in subscriptions) {
      totalCompleteness += sub.completenessPercentage;
    }
    final avgCompleteness = subscriptions.isEmpty ? 0 : totalCompleteness ~/ subscriptions.length;

    return SubscriptionStats(
      totalActive: active.length,
      totalMonthly: totalMonthly,
      totalYearly: totalMonthly * 12,
      expiringCount: expiringCount,
      completenessPercentage: avgCompleteness,
      costByCategory: costByCategory,
    );
  }

  /// Haal abonnementen op die binnenkort verlopen of opgezegd moeten worden
  Future<List<SubscriptionModel>> getExpiringSubscriptions(String dossierId, {int withinDays = 30}) async {
    final active = await getActiveSubscriptions(dossierId);
    final now = DateTime.now();
    final result = <SubscriptionModel>[];

    for (final sub in active) {
      bool isExpiring = false;

      if (sub.contractEndDate != null) {
        try {
          final endDate = DateTime.parse(sub.contractEndDate!);
          if (endDate.difference(now).inDays <= withinDays) {
            isExpiring = true;
          }
        } catch (_) {}
      }

      if (sub.lastCancellationDate != null) {
        try {
          final cancelDate = DateTime.parse(sub.lastCancellationDate!);
          if (cancelDate.difference(now).inDays <= withinDays) {
            isExpiring = true;
          }
        } catch (_) {}
      }

      if (isExpiring) {
        result.add(sub);
      }
    }

    return result;
  }

  /// Haal abonnementen op per prioriteit voor nabestaanden
  Future<Map<CancellationPriority, List<SubscriptionModel>>> getSubscriptionsByPriority(String dossierId) async {
    final active = await getActiveSubscriptions(dossierId);
    final result = <CancellationPriority, List<SubscriptionModel>>{
      CancellationPriority.high: [],
      CancellationPriority.normal: [],
      CancellationPriority.low: [],
    };

    for (final sub in active) {
      result[sub.cancellationPriority]!.add(sub);
    }

    return result;
  }
}






