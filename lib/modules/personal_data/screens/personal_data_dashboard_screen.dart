// lib/modules/personal_data/screens/personal_data_dashboard_screen.dart
// Dashboard voor Persoonsgegevens module - REFERENTIE STANDAARD VOOR UI/UX

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../../dossier/dossier_providers.dart';
import '../../dossier/screens/select_dossier_screen.dart';
import '../../household/screens/household_screen.dart';
import '../../person/select_person_screen.dart';
import '../../contacts/screens/contacts_screen.dart';

/// Categorieën in het Persoonsgegevens dashboard
enum PersonalDataCategory {
  household('Gezin', Icons.family_restroom, '👨‍👩‍👧‍👦', Color(0xFF4CAF50)),
  contacts('Contacten', Icons.contacts, '📇', Color(0xFF2196F3)),
  persons('Personen', Icons.person, '👤', Color(0xFF9C27B0));

  final String label;
  final IconData icon;
  final String emoji;
  final Color color;
  
  const PersonalDataCategory(this.label, this.icon, this.emoji, this.color);
}

class PersonalDataDashboardScreen extends ConsumerStatefulWidget {
  final String dossierId;

  const PersonalDataDashboardScreen({
    super.key,
    required this.dossierId,
  });

  @override
  ConsumerState<PersonalDataDashboardScreen> createState() => _PersonalDataDashboardScreenState();
}

class _PersonalDataDashboardScreenState extends ConsumerState<PersonalDataDashboardScreen> {
  
  @override
  Widget build(BuildContext context) {
    final currentDossierAsync = ref.watch(currentDossierProvider);
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // ========== DOSSIER BAR BOVENAAN ==========
            currentDossierAsync.when(
              loading: () => const SizedBox(height: 56),
              error: (_, __) => const SizedBox(height: 56),
              data: (dossier) => _DossierBar(
                name: dossier?.name ?? 'Geen dossier',
                colorName: dossier?.color,
                onTap: () => _showDossierSelector(context),
              ),
            ),
            
            // ========== MODULE HEADER MET TITEL EN PERCENTAGE ==========
            _ModuleHeader(
              title: 'Persoonlijke gegevens',
              percentage: _calculateTotalPercentage(),
              onBack: () => Navigator.pop(context),
            ),
            
            // ========== CATEGORIEËN ==========
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  children: [
                    ...PersonalDataCategory.values.map((category) => 
                      _CategoryCard(
                        category: category,
                        stats: _getCategoryStats(category),
                        onTap: () => _navigateToCategory(context, category),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDossierSelector(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectDossierScreen()),
    );
  }

  int _calculateTotalPercentage() {
    // TODO: Bereken gemiddelde van alle categorieën
    return 93; // Placeholder
  }

  _CategoryStats _getCategoryStats(PersonalDataCategory category) {
    // TODO: Implementeer echte stats ophalen uit database
    switch (category) {
      case PersonalDataCategory.household:
        return _CategoryStats(4, 4, 4, 100);
      case PersonalDataCategory.contacts:
        return _CategoryStats(2, 2, 2, 80);
      case PersonalDataCategory.persons:
        return _CategoryStats(4, 4, 4, 100);
    }
  }

  void _navigateToCategory(BuildContext context, PersonalDataCategory category) {
    Widget screen;
    
    switch (category) {
      case PersonalDataCategory.household:
        screen = HouseholdScreen(dossierId: widget.dossierId);
        break;
      case PersonalDataCategory.persons:
        screen = SelectPersonScreen(dossierId: widget.dossierId);
        break;
      case PersonalDataCategory.contacts:
        screen = ContactsScreen(dossierId: widget.dossierId);
        break;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

// ========== DOSSIER BAR WIDGET ==========
class _DossierBar extends StatelessWidget {
  final String name;
  final String? colorName;
  final VoidCallback onTap;

  const _DossierBar({
    required this.name,
    this.colorName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor(colorName);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color,
      child: Row(
        children: [
          // Dossier chip
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.folder, size: 16, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
                ],
              ),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Color _getColor(String? color) {
    switch (color) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return const Color(0xFF4CAF50);
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      case 'teal':
        return Colors.teal;
      default:
        return const Color(0xFF4CAF50); // Default groen
    }
  }
}

// ========== MODULE HEADER WIDGET ==========
class _ModuleHeader extends StatelessWidget {
  final String title;
  final int percentage;
  final VoidCallback onBack;

  const _ModuleHeader({
    required this.title,
    required this.percentage,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          
          // Title with percentage
          Expanded(
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                // Percentage badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getPercentageColor(percentage).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getPercentageColor(percentage),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}

// ========== CATEGORY CARD WIDGET ==========
class _CategoryCard extends StatelessWidget {
  final PersonalDataCategory category;
  final _CategoryStats stats;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.stats,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Emoji icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: category.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    category.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${stats.itemCount} items  •  ${stats.completedCount}/${stats.totalCount} compleet',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Percentage badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getPercentageColor(stats.percentage).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${stats.percentage}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _getPercentageColor(stats.percentage),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              
              // Chevron
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPercentageColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}

/// Helper class voor categorie statistieken
class _CategoryStats {
  final int itemCount;
  final int completedCount;
  final int totalCount;
  final int percentage;

  _CategoryStats(this.itemCount, this.completedCount, this.totalCount, this.percentage);
}
