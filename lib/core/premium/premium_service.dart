// lib/core/premium/premium_service.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'premium_features.dart';

/// Premium status van de gebruiker
class PremiumStatus {
  final bool isPremium;
  final PremiumPlan plan;
  final DateTime? expiresAt;
  final Set<PremiumFeature> unlockedFeatures;

  const PremiumStatus({
    required this.isPremium,
    required this.plan,
    this.expiresAt,
    this.unlockedFeatures = const {},
  });

  /// Gratis status
  static const free = PremiumStatus(
    isPremium: false,
    plan: PremiumPlan.free,
  );

  /// Check of een specifieke feature beschikbaar is
  bool hasFeature(PremiumFeature feature) {
    if (isPremium) return true;
    return unlockedFeatures.contains(feature);
  }

  /// Check of premium nog geldig is
  bool get isValid {
    if (!isPremium) return false;
    if (plan == PremiumPlan.lifetime) return true;
    if (expiresAt == null) return false;
    return DateTime.now().isBefore(expiresAt!);
  }

  PremiumStatus copyWith({
    bool? isPremium,
    PremiumPlan? plan,
    DateTime? expiresAt,
    Set<PremiumFeature>? unlockedFeatures,
  }) {
    return PremiumStatus(
      isPremium: isPremium ?? this.isPremium,
      plan: plan ?? this.plan,
      expiresAt: expiresAt ?? this.expiresAt,
      unlockedFeatures: unlockedFeatures ?? this.unlockedFeatures,
    );
  }
}

/// Premium service voor het beheren van premium status
class PremiumService {
  static const _keyIsPremium = 'premium_is_premium';
  static const _keyPlan = 'premium_plan';
  static const _keyExpiresAt = 'premium_expires_at';

  /// Haal huidige premium status op
  static Future<PremiumStatus> getStatus() async {
    final prefs = await SharedPreferences.getInstance();
    
    final isPremium = prefs.getBool(_keyIsPremium) ?? false;
    final planIndex = prefs.getInt(_keyPlan) ?? 0;
    final expiresAtMs = prefs.getInt(_keyExpiresAt);
    
    return PremiumStatus(
      isPremium: isPremium,
      plan: PremiumPlan.values[planIndex],
      expiresAt: expiresAtMs != null 
          ? DateTime.fromMillisecondsSinceEpoch(expiresAtMs) 
          : null,
    );
  }

  /// Activeer premium (wordt later gekoppeld aan in-app purchase)
  static Future<void> activatePremium(PremiumPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool(_keyIsPremium, true);
    await prefs.setInt(_keyPlan, plan.index);
    
    // Bereken vervaldatum
    DateTime? expiresAt;
    if (plan == PremiumPlan.monthly) {
      expiresAt = DateTime.now().add(const Duration(days: 30));
    } else if (plan == PremiumPlan.yearly) {
      expiresAt = DateTime.now().add(const Duration(days: 365));
    }
    // Lifetime heeft geen vervaldatum
    
    if (expiresAt != null) {
      await prefs.setInt(_keyExpiresAt, expiresAt.millisecondsSinceEpoch);
    } else {
      await prefs.remove(_keyExpiresAt);
    }
  }

  /// Deactiveer premium
  static Future<void> deactivatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsPremium, false);
    await prefs.setInt(_keyPlan, 0);
    await prefs.remove(_keyExpiresAt);
  }

  /// Check of een feature beschikbaar is (snelle check)
  static Future<bool> hasFeature(PremiumFeature feature) async {
    final status = await getStatus();
    return status.hasFeature(feature);
  }

  /// Check limiet voor aantal items
  static Future<bool> canAddMore({
    required int currentCount,
    required int freeLimit,
    required PremiumFeature unlimitedFeature,
  }) async {
    final status = await getStatus();
    if (status.hasFeature(unlimitedFeature)) {
      return true; // Premium = onbeperkt
    }
    return currentCount < freeLimit;
  }
}

/// Riverpod provider voor premium status
final premiumStatusProvider = FutureProvider<PremiumStatus>((ref) async {
  return await PremiumService.getStatus();
});

/// Riverpod provider voor snelle premium check
final isPremiumProvider = FutureProvider<bool>((ref) async {
  final status = await ref.watch(premiumStatusProvider.future);
  return status.isPremium && status.isValid;
});

/// Provider om premium status te refreshen
final premiumRefreshProvider = Provider<void Function()>((ref) {
  return () {
    ref.invalidate(premiumStatusProvider);
    ref.invalidate(isPremiumProvider);
  };
});




