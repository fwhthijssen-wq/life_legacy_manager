// lib/widgets/dossier_header.dart
// Dossier info header widget

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Dossier header card voor bovenkant van screens
class DossierHeader extends StatelessWidget {
  final String name;
  final String? description;
  final String? icon;
  final String? colorName;
  final VoidCallback? onSwitch;
  final VoidCallback? onEdit;
  
  const DossierHeader({
    super.key,
    required this.name,
    this.description,
    this.icon,
    this.colorName,
    this.onSwitch,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(colorName);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Icon container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getIcon(icon),
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    description!,
                    style: AppTextStyles.cardSubtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Actions
          if (onEdit != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: onEdit,
              tooltip: 'Bewerken',
            ),
          if (onSwitch != null)
            IconButton(
              icon: const Icon(Icons.swap_horiz),
              onPressed: onSwitch,
              tooltip: 'Wissel dossier',
            ),
        ],
      ),
    );
  }
  
  IconData _getIcon(String? icon) {
    switch (icon) {
      case 'family':
        return Icons.family_restroom;
      case 'elderly':
        return Icons.elderly;
      case 'person':
        return Icons.person;
      case 'group':
        return Icons.group;
      case 'business':
        return Icons.business;
      case 'home':
        return Icons.home;
      default:
        return Icons.folder;
    }
  }

  Color _getColor(String? color) {
    switch (color) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      default:
        return AppColors.primary;
    }
  }
}

/// Kleine dossier indicator voor AppBar
class DossierIndicator extends StatelessWidget {
  final String name;
  final String? colorName;
  final VoidCallback? onTap;
  
  const DossierIndicator({
    super.key,
    required this.name,
    this.colorName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(colorName);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              name,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.unfold_more, size: 16, color: color),
          ],
        ),
      ),
    );
  }
  
  Color _getColor(String? color) {
    switch (color) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      default:
        return AppColors.primary;
    }
  }
}


