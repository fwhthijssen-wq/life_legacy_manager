// lib/widgets/module_card.dart
// Module cards voor het home screen dashboard

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Model voor een module op het home screen
class ModuleInfo {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final String emoji;
  final Color color;
  final bool isAvailable;
  final int? itemCount;
  final double? completeness;
  
  const ModuleInfo({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.emoji,
    required this.color,
    this.isAvailable = true,
    this.itemCount,
    this.completeness,
  });
}

/// Module card voor het home screen - grotere variant
class ModuleCard extends StatelessWidget {
  final ModuleInfo module;
  final VoidCallback? onTap;
  
  const ModuleCard({
    super.key,
    required this.module,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !module.isAvailable;
    
    return Card(
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPadding),
          child: Row(
            children: [
              // Large icon container
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isLocked 
                      ? Colors.grey[200] 
                      : module.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    module.emoji,
                    style: TextStyle(
                      fontSize: 28,
                      color: isLocked ? Colors.grey : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Text(
                          module.label,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isLocked ? AppColors.textHint : null,
                          ),
                        ),
                        if (isLocked) ...[
                          const SizedBox(width: AppSpacing.sm),
                          Icon(Icons.lock, size: 16, color: AppColors.textHint),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    
                    // Description/Status
                    Text(
                      isLocked 
                          ? 'Binnenkort beschikbaar' 
                          : _getStatusText(),
                      style: AppTextStyles.cardSubtitle.copyWith(
                        color: isLocked ? AppColors.textHint : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Progress badge + Chevron
              if (!isLocked && module.completeness != null && (module.itemCount ?? 0) > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: AppDecorations.progressBadge(module.completeness!),
                  child: Text(
                    '${module.completeness!.round()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
              ],
              
              Icon(
                Icons.chevron_right,
                color: isLocked ? AppColors.textHint : module.color,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _getStatusText() {
    if (module.itemCount == null || module.itemCount == 0) {
      return module.description;
    }
    return '${module.itemCount} ${module.itemCount == 1 ? 'item' : 'items'}';
  }
}

/// Compacte module card variant (voor grids)
class ModuleCardCompact extends StatelessWidget {
  final ModuleInfo module;
  final VoidCallback? onTap;
  
  const ModuleCardCompact({
    super.key,
    required this.module,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !module.isAvailable;
    
    return Card(
      child: InkWell(
        onTap: isLocked ? null : onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isLocked 
                      ? Colors.grey[200] 
                      : module.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    module.emoji,
                    style: TextStyle(
                      fontSize: 24,
                      color: isLocked ? Colors.grey : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Label
              Text(
                module.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isLocked ? AppColors.textHint : null,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              // Lock indicator
              if (isLocked) ...[
                const SizedBox(height: AppSpacing.xs),
                Icon(Icons.lock, size: 14, color: AppColors.textHint),
              ],
              
              // Progress indicator
              if (!isLocked && module.completeness != null && (module.itemCount ?? 0) > 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.progressColor(module.completeness!),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${module.completeness!.round()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.progressColor(module.completeness!),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Section header voor groepering
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        right: AppSpacing.xs,
        top: AppSpacing.xl,
        bottom: AppSpacing.md,
      ),
      child: Row(
        children: [
          Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}


