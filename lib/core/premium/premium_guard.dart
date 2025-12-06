// lib/core/premium/premium_guard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'premium_features.dart';
import 'premium_service.dart';
import 'premium_dialogs.dart';

/// Helper class voor premium checks in de UI
class PremiumGuard {
  /// Voer een actie uit als premium feature beschikbaar is
  /// Toont upgrade dialog als niet beschikbaar
  static Future<bool> executeIfAllowed(
    BuildContext context,
    WidgetRef ref,
    PremiumFeature feature,
    Future<void> Function() action,
  ) async {
    final status = await ref.read(premiumStatusProvider.future);
    
    if (status.hasFeature(feature)) {
      await action();
      return true;
    } else {
      await PremiumDialogs.showFeatureDialog(context, feature);
      return false;
    }
  }

  /// Check of een item kan worden toegevoegd (limiet check)
  static Future<bool> canAddItem(
    BuildContext context,
    WidgetRef ref, {
    required int currentCount,
    required int freeLimit,
    required PremiumFeature unlimitedFeature,
    required String itemType,
  }) async {
    final status = await ref.read(premiumStatusProvider.future);
    
    if (status.hasFeature(unlimitedFeature)) {
      return true; // Premium = geen limiet
    }
    
    if (currentCount < freeLimit) {
      return true; // Nog onder limiet
    }
    
    // Limiet bereikt - toon dialog
    await PremiumDialogs.showLimitDialog(
      context,
      itemType: itemType,
      currentCount: currentCount,
      limit: freeLimit,
    );
    return false;
  }
}

/// Widget die een premium badge toont bij een feature
class PremiumBadge extends StatelessWidget {
  final Widget child;
  final bool showBadge;

  const PremiumBadge({
    super.key,
    required this.child,
    this.showBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!showBadge) return child;
    
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: -4,
          right: -4,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              size: 12,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget voor een premium-only feature button
class PremiumFeatureButton extends ConsumerWidget {
  final PremiumFeature feature;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool showAsPremium;

  const PremiumFeatureButton({
    super.key,
    required this.feature,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.showAsPremium = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumAsync = ref.watch(premiumStatusProvider);

    return premiumAsync.when(
      loading: () => _buildButton(context, ref, isPremium: false, loading: true),
      error: (_, __) => _buildButton(context, ref, isPremium: false),
      data: (status) => _buildButton(context, ref, isPremium: status.hasFeature(feature)),
    );
  }

  Widget _buildButton(BuildContext context, WidgetRef ref, {
    required bool isPremium,
    bool loading = false,
  }) {
    final needsPremium = !isPremium && showAsPremium;

    return ListTile(
      leading: PremiumBadge(
        showBadge: needsPremium,
        child: Icon(icon, color: needsPremium ? Colors.grey : null),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: needsPremium ? Colors.grey : null,
        ),
      ),
      trailing: loading 
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : needsPremium
              ? const Icon(Icons.lock, color: Colors.amber, size: 20)
              : const Icon(Icons.chevron_right),
      onTap: loading ? null : () async {
        if (isPremium) {
          onPressed();
        } else {
          await PremiumDialogs.showFeatureDialog(context, feature);
        }
      },
    );
  }
}

/// Widget om premium status te tonen
class PremiumStatusCard extends ConsumerWidget {
  const PremiumStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumAsync = ref.watch(premiumStatusProvider);
    final theme = Theme.of(context);

    return premiumAsync.when(
      loading: () => const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (status) {
        if (status.isPremium && status.isValid) {
          // Premium actief
          return Card(
            color: Colors.amber.shade50,
            child: ListTile(
              leading: const Icon(Icons.workspace_premium, color: Colors.amber, size: 32),
              title: Text(
                'Premium ${status.plan.displayName}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: status.expiresAt != null
                  ? Text('Geldig tot ${_formatDate(status.expiresAt!)}')
                  : const Text('Levenslang toegang'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
            ),
          );
        } else {
          // Gratis versie
          return Card(
            child: ListTile(
              leading: Icon(Icons.workspace_premium, color: Colors.grey[400], size: 32),
              title: const Text('Gratis versie'),
              subtitle: const Text('Upgrade voor alle functies'),
              trailing: FilledButton(
                onPressed: () => PremiumDialogs.showPremiumPage(context),
                child: const Text('Upgrade'),
              ),
            ),
          );
        }
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }
}






