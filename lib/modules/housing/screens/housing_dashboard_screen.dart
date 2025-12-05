// lib/modules/housing/screens/housing_dashboard_screen.dart
// Dashboard voor Wonen & Energie module

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../models/property_model.dart';
import '../models/housing_enums.dart';
import '../providers/housing_providers.dart';
import '../repositories/housing_repository.dart';
import 'properties/property_list_screen.dart';
import 'properties/property_detail_screen.dart';
import 'mortgage/mortgage_list_screen.dart';
import 'rental/rental_list_screen.dart';
import 'energy/energy_list_screen.dart';
import 'installations/installation_list_screen.dart';

/// Categorieën in het Wonen & Energie dashboard
enum HousingCategory {
  property('Woning - Algemeen', Icons.home, '🏠', Colors.blue),
  mortgage('Hypotheek', Icons.account_balance, '🏦', Colors.green),
  rental('Huurcontract', Icons.description, '📋', Colors.orange),
  energy('Energie', Icons.bolt, '⚡', Colors.amber),
  utilities('Nutsvoorzieningen', Icons.water_drop, '💧', Colors.cyan),
  installations('Technische Installaties', Icons.build, '🔧', Colors.deepOrange),
  appliances('Apparaten & Systemen', Icons.kitchen, '🏠', Colors.purple),
  maintenance('Onderhoud & Diensten', Icons.engineering, '👷', Colors.teal);

  final String label;
  final IconData icon;
  final String emoji;
  final Color color;
  const HousingCategory(this.label, this.icon, this.emoji, this.color);
}

class HousingDashboardScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final String personId;
  final String? personName;

  const HousingDashboardScreen({
    super.key,
    required this.dossierId,
    required this.personId,
    this.personName,
  });

  @override
  ConsumerState<HousingDashboardScreen> createState() => _HousingDashboardScreenState();
}

class _HousingDashboardScreenState extends ConsumerState<HousingDashboardScreen> {
  PropertyModel? _selectedProperty;

  @override
  Widget build(BuildContext context) {
    final propertiesAsync = ref.watch(propertiesProvider(widget.dossierId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wonen & Energie'),
        actions: [
          // Quick access buttons
          IconButton(
            icon: const Icon(Icons.warning_amber),
            tooltip: 'Storing? Klik hier',
            onPressed: _showEmergencyContacts,
          ),
          IconButton(
            icon: const Icon(Icons.contacts),
            tooltip: 'Belangrijke contacten',
            onPressed: _showImportantContacts,
          ),
        ],
      ),
      body: propertiesAsync.when(
        loading: () => const LoadingState(message: 'Woningen laden...'),
        error: (err, stack) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(propertiesProvider(widget.dossierId)),
        ),
        data: (properties) {
          if (properties.isEmpty) {
            return EmptyState(
              icon: Icons.home_outlined,
              title: 'Nog geen woning toegevoegd',
              subtitle: 'Voeg je eerste woning toe om alle\nwoning-gerelateerde zaken vast te leggen.',
              buttonLabel: 'Woning toevoegen',
              onButtonPressed: _addProperty,
              iconColor: AppColors.moduleHousing,
            );
          }

          // Auto-select eerste property als er nog geen geselecteerd is
          _selectedProperty ??= properties.first;

          return Column(
            children: [
              // Property selector (indien meerdere woningen)
              if (properties.length > 1) _buildPropertySelector(properties),
              
              // Categorieën list
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  children: [
                    ..._getVisibleCategories().map((category) => CategoryTile(
                      item: CategoryItem(
                        label: category.label,
                        emoji: category.emoji,
                        color: category.color,
                        itemCount: _getCategoryStats(category).count,
                        completenessPercentage: _getCategoryStats(category).percentage.toDouble(),
                        subtitle: _getCategoryStats(category).subtitle,
                        isLocked: _isCategoryLocked(category),
                        onTap: () => _navigateToCategory(category),
                      ),
                    )),
                    const SizedBox(height: 80), // Ruimte voor FAB
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addProperty,
        icon: const Icon(Icons.add),
        label: const Text('Woning toevoegen'),
      ),
    );
  }

  Widget _buildPropertySelector(List<PropertyModel> properties) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(bottom: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          const Icon(Icons.home, size: 20),
          const SizedBox(width: AppSpacing.md),
          Text('Woning:', style: theme.textTheme.bodyMedium),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: DropdownButton<PropertyModel>(
              value: _selectedProperty,
              isExpanded: true,
              underline: const SizedBox(),
              items: properties.map((p) => DropdownMenuItem(
                value: p,
                child: Text(p.displayName, overflow: TextOverflow.ellipsis),
              )).toList(),
              onChanged: (property) {
                if (property != null) {
                  setState(() => _selectedProperty = property);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Bepaal welke categorieën zichtbaar zijn op basis van eigendomssituatie
  List<HousingCategory> _getVisibleCategories() {
    final isOwned = _selectedProperty?.ownershipType == OwnershipType.owned;
    final isRented = _selectedProperty?.ownershipType == OwnershipType.rented;

    return HousingCategory.values.where((cat) {
      // Hypotheek alleen bij eigen woning
      if (cat == HousingCategory.mortgage && !isOwned) return false;
      // Huurcontract alleen bij huur
      if (cat == HousingCategory.rental && !isRented) return false;
      return true;
    }).toList();
  }

  bool _isCategoryLocked(HousingCategory category) {
    // Voorlopig zijn utilities, appliances en maintenance nog locked
    return category == HousingCategory.utilities ||
           category == HousingCategory.appliances ||
           category == HousingCategory.maintenance;
  }

  _CategoryStats _getCategoryStats(HousingCategory category) {
    if (_selectedProperty == null) {
      return _CategoryStats(0, '', 0);
    }

    switch (category) {
      case HousingCategory.property:
        return _CategoryStats(
          1,
          _selectedProperty!.fullAddress.isNotEmpty ? _selectedProperty!.fullAddress : '1 woning',
          _selectedProperty!.completenessPercentage,
        );
      case HousingCategory.mortgage:
        return _CategoryStats(0, 'Hypotheekgegevens', 0);
      case HousingCategory.rental:
        return _CategoryStats(0, 'Huurcontract', 0);
      case HousingCategory.energy:
        return _CategoryStats(0, 'Energiecontracten', 0);
      case HousingCategory.installations:
        return _CategoryStats(0, 'CV-ketel, zonnepanelen, etc.', 0);
      default:
        return _CategoryStats(0, '', 0);
    }
  }

  void _navigateToCategory(HousingCategory category) {
    if (_selectedProperty == null) return;

    switch (category) {
      case HousingCategory.property:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PropertyDetailScreen(
              dossierId: widget.dossierId,
              propertyId: _selectedProperty!.id,
            ),
          ),
        ).then((_) => ref.invalidate(propertiesProvider(widget.dossierId)));
        break;
      case HousingCategory.mortgage:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MortgageListScreen(
              propertyId: _selectedProperty!.id,
            ),
          ),
        );
        break;
      case HousingCategory.rental:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RentalListScreen(
              propertyId: _selectedProperty!.id,
            ),
          ),
        );
        break;
      case HousingCategory.energy:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EnergyListScreen(
              propertyId: _selectedProperty!.id,
            ),
          ),
        );
        break;
      case HousingCategory.installations:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => InstallationListScreen(
              propertyId: _selectedProperty!.id,
            ),
          ),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${category.label} wordt binnenkort toegevoegd'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }

  Future<void> _addProperty() async {
    final repo = ref.read(housingRepositoryProvider);
    
    final propertyId = await repo.createProperty(
      dossierId: widget.dossierId,
      personId: widget.personId,
      name: 'Nieuwe woning',
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PropertyDetailScreen(
          dossierId: widget.dossierId,
          propertyId: propertyId,
          isNew: true,
        ),
      ),
    ).then((_) {
      ref.invalidate(propertiesProvider(widget.dossierId));
    });
  }

  void _showEmergencyContacts() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _EmergencyContactsSheet(property: _selectedProperty),
    );
  }

  void _showImportantContacts() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ImportantContactsSheet(property: _selectedProperty),
    );
  }
}

class _CategoryStats {
  final int count;
  final String subtitle;
  final int percentage;

  _CategoryStats(this.count, this.subtitle, this.percentage);
}

/// Sheet met storingsnummers
class _EmergencyContactsSheet extends StatelessWidget {
  final PropertyModel? property;

  const _EmergencyContactsSheet({this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: AppColors.warning),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Storing? Direct contact',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _buildEmergencyItem(context, '⚡', 'Elektriciteit / Gas', 'Netbeheerder', '0800-0520'),
          _buildEmergencyItem(context, '🔥', 'CV-ketel', 'Zie installatie details', null),
          _buildEmergencyItem(context, '💧', 'Water', 'Waterleidingbedrijf', '0800-0200'),
          _buildEmergencyItem(context, '📡', 'Internet / TV', 'Provider', null),
          _buildEmergencyItem(context, '🚨', 'Alarm', 'Alarmcentrale', null),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Tip: Vul de contactgegevens in bij elke categorie voor directe toegang.',
            style: AppTextStyles.cardSubtitle,
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyItem(BuildContext context, String emoji, String title, String subtitle, String? phone) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Text(emoji, style: const TextStyle(fontSize: 28)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: phone != null
          ? TextButton(
              onPressed: () {
                // TODO: Tel nummer bellen
              },
              child: Text(phone),
            )
          : null,
    );
  }
}

/// Sheet met belangrijke contacten
class _ImportantContactsSheet extends StatelessWidget {
  final PropertyModel? property;

  const _ImportantContactsSheet({this.property});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contacts, color: AppColors.info),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Belangrijke contacten',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Vul eerst de woninggegevens in om contacten te zien.',
            style: AppTextStyles.cardSubtitle,
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
