// lib/widgets/dossier_app_bar.dart
// Custom AppBar met dossier indicator linksboven

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../modules/dossier/dossier_providers.dart';
import '../modules/dossier/screens/select_dossier_screen.dart';

/// Custom AppBar die het actieve dossier linksboven toont
/// Gebruik deze in plaats van standaard AppBar voor consistente dossier weergave
class DossierAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final PreferredSizeWidget? bottom;
  final double? bottomHeight;
  
  const DossierAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.bottom,
    this.bottomHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom != null ? (bottomHeight ?? kTextTabBarHeight) : 0),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDossierAsync = ref.watch(currentDossierProvider);
    final theme = Theme.of(context);
    
    return AppBar(
      automaticallyImplyLeading: showBackButton,
      title: Row(
        children: [
          // Dossier indicator linksboven (na de back button)
          currentDossierAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (dossier) => dossier != null
                ? _DossierChip(
                    name: dossier.name,
                    colorName: dossier.color,
                    onTap: () => _showDossierSelector(context),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(width: AppSpacing.md),
          // Titel
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  void _showDossierSelector(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectDossierScreen()),
    );
  }
}

/// Compacte dossier chip voor in de AppBar
class _DossierChip extends StatelessWidget {
  final String name;
  final String? colorName;
  final VoidCallback? onTap;
  
  const _DossierChip({
    required this.name,
    this.colorName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(colorName);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.3), width: 1),
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
              const SizedBox(width: 6),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  name,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.unfold_more, size: 14, color: color),
            ],
          ),
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
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      default:
        return AppColors.primary;
    }
  }
}


