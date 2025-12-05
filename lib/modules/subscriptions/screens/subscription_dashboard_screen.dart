// lib/modules/subscriptions/screens/subscription_dashboard_screen.dart
// Dashboard voor Lidmaatschappen & Abonnementen module

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../models/subscription_enums.dart';
import '../providers/subscription_providers.dart';
import 'subscription_list_screen.dart';

class SubscriptionDashboardScreen extends ConsumerStatefulWidget {
  final String dossierId;

  const SubscriptionDashboardScreen({
    super.key,
    required this.dossierId,
  });

  @override
  ConsumerState<SubscriptionDashboardScreen> createState() => _SubscriptionDashboardScreenState();
}

class _SubscriptionDashboardScreenState extends ConsumerState<SubscriptionDashboardScreen> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(subscriptionStatsProvider(widget.dossierId));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overzicht header
          statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Text('Fout: $err'),
            data: (stats) => _buildStatsHeader(stats, theme),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Quick actions
          _buildQuickActions(theme),
          
          // Section header
          const SectionHeader(title: 'Categorieën'),
          
          // Categorieën
          ...SubscriptionCategory.values.map(
            (category) => _buildCategoryTile(category),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(stats, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.moduleSubscriptions, AppColors.moduleSubscriptions.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Actief', '${stats.totalActive}', '📋'),
              _buildStatItem('Per maand', '€ ${stats.totalMonthly.toStringAsFixed(0)}', '💰'),
              _buildStatItem('Per jaar', '€ ${stats.totalYearly.toStringAsFixed(0)}', '📅'),
            ],
          ),
          if (stats.expiringCount > 0) ...[
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber, color: Colors.white, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${stats.expiringCount} verlopen binnenkort',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String emoji) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showCostOverview(),
            icon: const Icon(Icons.pie_chart),
            label: const Text('Kostenoverzicht'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showSurvivorList(),
            icon: const Icon(Icons.list_alt),
            label: const Text('Opzeglijst'),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryTile(SubscriptionCategory category) {
    final subscriptionsAsync = ref.watch(
      subscriptionsByCategoryProvider((dossierId: widget.dossierId, category: category)),
    );

    return subscriptionsAsync.when(
      loading: () => CategoryTile(
        item: CategoryItem(
          label: category.label,
          emoji: category.emoji,
          color: Color(category.colorValue),
          subtitle: 'Laden...',
          onTap: () => _navigateToCategory(category),
        ),
      ),
      error: (err, stack) => const SizedBox.shrink(),
      data: (subscriptions) {
        final activeCount = subscriptions.where((s) => s.status == SubscriptionStatus.active).length;
        final monthlyCost = subscriptions
            .where((s) => s.status == SubscriptionStatus.active)
            .fold<double>(0, (sum, s) => sum + s.monthlyCost);
        
        final completeness = subscriptions.isEmpty
            ? 0.0
            : subscriptions.map((s) => s.completenessPercentage).reduce((a, b) => a + b) / subscriptions.length;

        // Build subtitle with cost info
        String subtitle = '$activeCount actief';
        if (monthlyCost > 0) {
          subtitle += ' • € ${monthlyCost.toStringAsFixed(0)}/mnd';
        }

        return CategoryTile(
          item: CategoryItem(
            label: category.label,
            emoji: category.emoji,
            color: Color(category.colorValue),
            itemCount: subscriptions.length,
            completenessPercentage: completeness,
            subtitle: subscriptions.isEmpty ? null : subtitle,
            onTap: () => _navigateToCategory(category),
          ),
        );
      },
    );
  }

  void _navigateToCategory(SubscriptionCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubscriptionListScreen(
          dossierId: widget.dossierId,
          category: category,
        ),
      ),
    ).then((_) {
      ref.invalidate(subscriptionsProvider(widget.dossierId));
      ref.invalidate(subscriptionStatsProvider(widget.dossierId));
    });
  }

  void _showCostOverview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Kostenoverzicht wordt binnenkort toegevoegd'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSurvivorList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opzeglijst voor nabestaanden wordt binnenkort toegevoegd'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
