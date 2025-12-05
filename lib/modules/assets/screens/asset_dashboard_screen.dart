// lib/modules/assets/screens/asset_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../models/asset_enums.dart';
import '../providers/asset_providers.dart';
import 'asset_list_screen.dart';

class AssetDashboardScreen extends ConsumerWidget {
  final String dossierId;
  final bool embedded;

  const AssetDashboardScreen({
    super.key,
    required this.dossierId,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryStatsAsync = ref.watch(assetCategoryStatsProvider(dossierId));
    final currencyFormat = NumberFormat.currency(locale: 'nl_NL', symbol: '€');

    final content = categoryStatsAsync.when(
      loading: () => const LoadingState(message: 'Laden...'),
      error: (err, _) => ErrorState(
        message: err.toString(),
        onRetry: () {
          ref.invalidate(assetsForDossierProvider(dossierId));
          ref.invalidate(assetCategoryStatsProvider(dossierId));
        },
      ),
      data: (categoryStats) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(assetsForDossierProvider(dossierId));
          ref.invalidate(assetCategoryStatsProvider(dossierId));
          ref.invalidate(assetValueOverviewProvider(dossierId));
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Categorie tiles
            ...AssetCategory.values.map((category) {
              final stats = categoryStats[category];
              final count = stats?.itemCount ?? 0;
              final completeness = stats?.averageCompleteness.toDouble() ?? 0;
              final totalValue = stats?.totalValue ?? 0;
              
              // Build subtitle with value info
              String? subtitle;
              if (count > 0 && totalValue > 0) {
                subtitle = '$count ${count == 1 ? 'item' : 'items'} • ${currencyFormat.format(totalValue)}';
              }
              
              return CategoryTile(
                item: CategoryItem(
                  label: category.label,
                  emoji: category.emoji,
                  color: Color(category.colorValue),
                  itemCount: count,
                  completenessPercentage: completeness,
                  subtitle: subtitle,
                  onTap: () => _navigateToCategory(context, category),
                ),
              );
            }),

            const SizedBox(height: 80), // Ruimte voor FAB
          ],
        ),
      ),
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bezittingen'),
      ),
      body: content,
    );
  }

  void _navigateToCategory(BuildContext context, AssetCategory category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AssetListScreen(
          dossierId: dossierId,
          category: category,
        ),
      ),
    );
  }
}
