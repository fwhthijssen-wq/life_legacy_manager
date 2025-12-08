// lib/widgets/category_tile.dart
// Herbruikbare category tile widget voor dashboards

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Model voor een categorie item
class CategoryItem {
  final String label;
  final String emoji;
  final Color color;
  final int itemCount;
  final double completenessPercentage;
  final String? subtitle;
  final bool isLocked;
  final VoidCallback? onTap;
  
  const CategoryItem({
    required this.label,
    required this.emoji,
    required this.color,
    this.itemCount = 0,
    this.completenessPercentage = 0,
    this.subtitle,
    this.isLocked = false,
    this.onTap,
  });
}

/// Herbruikbare category tile voor alle dashboard screens
class CategoryTile extends StatelessWidget {
  final CategoryItem item;
  
  const CategoryTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: item.isLocked ? null : item.onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              // Emoji icon container
              _IconContainer(
                emoji: item.emoji,
                color: item.color,
                isLocked: item.isLocked,
              ),
              const SizedBox(width: AppSpacing.lg),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row
                    Row(
                      children: [
                        Text(
                          item.label,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: item.isLocked ? AppColors.textHint : null,
                          ),
                        ),
                        if (item.isLocked) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.lock, size: 14, color: AppColors.textHint),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    
                    // Subtitle
                    Text(
                      _getSubtitle(),
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: item.isLocked ? AppColors.textHint : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Progress badge + Chevron
              if (!item.isLocked && item.itemCount > 0) ...[
                ProgressBadge(percentage: item.completenessPercentage),
                const SizedBox(width: AppSpacing.sm),
              ],
              
              Icon(
                item.isLocked ? Icons.lock : Icons.chevron_right,
                color: item.isLocked ? AppColors.textHint : item.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getSubtitle() {
    if (item.isLocked) return 'Binnenkort beschikbaar';
    if (item.subtitle != null) return item.subtitle!;
    if (item.itemCount == 0) return 'Nog geen items toegevoegd';
    return '${item.itemCount} ${item.itemCount == 1 ? 'item' : 'items'}';
  }
}

/// Icon container met emoji
class _IconContainer extends StatelessWidget {
  final String emoji;
  final Color color;
  final bool isLocked;
  
  const _IconContainer({
    required this.emoji,
    required this.color,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.iconContainerSize,
      height: AppSpacing.iconContainerSize,
      decoration: AppDecorations.iconContainer(color, isLocked: isLocked),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: AppSpacing.iconSize,
            color: isLocked ? AppColors.textHint : null,
          ),
        ),
      ),
    );
  }
}

/// Progress badge widget
class ProgressBadge extends StatelessWidget {
  final double percentage;
  final bool compact;
  
  const ProgressBadge({
    super.key,
    required this.percentage,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: AppDecorations.progressBadge(percentage),
      child: Text(
        '${percentage.round()}%',
        style: AppTextStyles.badgeText.copyWith(
          fontSize: compact ? 10 : 12,
        ),
      ),
    );
  }
}

/// Simpele variant voor list items met IconData in plaats van emoji
class CategoryTileSimple extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final int? count;
  final double? completeness;
  final bool isLocked;
  final VoidCallback? onTap;
  
  const CategoryTileSimple({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.subtitle,
    this.count,
    this.completeness,
    this.isLocked = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              // Icon container
              Container(
                width: AppSpacing.iconContainerSize,
                height: AppSpacing.iconContainerSize,
                decoration: AppDecorations.iconContainer(color, isLocked: isLocked),
                child: Icon(
                  icon,
                  color: isLocked ? AppColors.textHint : color,
                  size: AppSpacing.iconSize,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          label,
                          style: AppTextStyles.cardTitle.copyWith(
                            color: isLocked ? AppColors.textHint : null,
                          ),
                        ),
                        if (isLocked) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.lock, size: 14, color: AppColors.textHint),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      _getSubtitle(),
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: isLocked ? AppColors.textHint : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Progress + Chevron
              if (!isLocked && completeness != null && (count ?? 0) > 0) ...[
                ProgressBadge(percentage: completeness!),
                const SizedBox(width: AppSpacing.sm),
              ],
              
              Icon(
                isLocked ? Icons.lock : Icons.chevron_right,
                color: isLocked ? AppColors.textHint : color,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getSubtitle() {
    if (isLocked) return 'Binnenkort beschikbaar';
    if (subtitle != null) return subtitle!;
    if (count == null || count == 0) return 'Nog geen items toegevoegd';
    return '$count ${count == 1 ? 'item' : 'items'}';
  }
}




