// lib/modules/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../dossier/screens/select_dossier_screen.dart';
import '../dossier/dossier_providers.dart';
import '../person/select_person_screen.dart';
import '../money/screens/money_dashboard_screen.dart';
import '../housing/screens/housing_dashboard_screen.dart';
import '../assets/screens/asset_dashboard_screen.dart';
import '../subscriptions/screens/subscription_dashboard_screen.dart';
import '../contacts/screens/contacts_screen.dart';
import '../household/screens/household_screen.dart';

/// Definitie van alle app modules
class AppModule {
  final String id;
  final String label;
  final String description;
  final IconData icon;
  final String emoji;
  final Color color;
  final bool isAvailable;
  
  const AppModule({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.emoji,
    required this.color,
    this.isAvailable = true,
  });
}

/// Alle beschikbare modules
const List<AppModule> _allModules = [
  AppModule(
    id: 'persons',
    label: 'Personen',
    description: 'Beheer persoonlijke gegevens',
    icon: Icons.people,
    emoji: '👥',
    color: AppColors.modulePersons,
  ),
  AppModule(
    id: 'household',
    label: 'Gezin',
    description: 'Huishoudleden en relaties',
    icon: Icons.family_restroom,
    emoji: '👨‍👩‍👧‍👦',
    color: AppColors.modulePersons,
  ),
  AppModule(
    id: 'money',
    label: 'Geldzaken',
    description: 'Bankrekeningen, verzekeringen, pensioenen',
    icon: Icons.euro,
    emoji: '💰',
    color: AppColors.moduleMoney,
  ),
  AppModule(
    id: 'housing',
    label: 'Wonen & Energie',
    description: 'Woning, hypotheek, energie',
    icon: Icons.home,
    emoji: '🏠',
    color: AppColors.moduleHousing,
  ),
  AppModule(
    id: 'assets',
    label: 'Bezittingen',
    description: 'Voertuigen, elektronica, waardevolle spullen',
    icon: Icons.inventory_2,
    emoji: '📦',
    color: AppColors.moduleAssets,
  ),
  AppModule(
    id: 'subscriptions',
    label: 'Abonnementen',
    description: 'Lidmaatschappen en abonnementen',
    icon: Icons.subscriptions,
    emoji: '📋',
    color: AppColors.moduleSubscriptions,
  ),
  AppModule(
    id: 'contacts',
    label: 'Contacten',
    description: 'Belangrijke contactpersonen',
    icon: Icons.contacts,
    emoji: '📇',
    color: AppColors.moduleContacts,
  ),
  AppModule(
    id: 'documents',
    label: 'Documenten',
    description: 'Belangrijke documenten opslaan',
    icon: Icons.folder,
    emoji: '📁',
    color: AppColors.moduleDocuments,
    isAvailable: false,
  ),
  AppModule(
    id: 'legal',
    label: 'Juridisch',
    description: 'Testamenten, volmachten, notaris',
    icon: Icons.gavel,
    emoji: '⚖️',
    color: AppColors.moduleLegal,
    isAvailable: false,
  ),
  AppModule(
    id: 'wishes',
    label: 'Wensen',
    description: 'Uitvaartwensen en laatste wil',
    icon: Icons.favorite,
    emoji: '💝',
    color: AppColors.moduleWishes,
    isAvailable: false,
  ),
  AppModule(
    id: 'digital',
    label: 'Digitale Erfenis',
    description: 'Online accounts en wachtwoorden',
    icon: Icons.cloud,
    emoji: '☁️',
    color: AppColors.moduleDigital,
    isAvailable: false,
  ),
];

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    
    // Check of er een dossier geselecteerd is
    final selectedDossierId = ref.watch(selectedDossierIdProvider);
    
    if (selectedDossierId == null) {
      // Geen dossier geselecteerd → redirect naar selectie
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SelectDossierScreen()),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Haal huidige dossier op
    final currentDossierAsync = ref.watch(currentDossierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          // Dossier indicator in AppBar
          currentDossierAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (dossier) => dossier != null
                ? Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: DossierIndicator(
                      name: dossier.name,
                      colorName: dossier.color,
                      onTap: () => _showDossierSelector(context),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: currentDossierAsync.when(
        loading: () => const LoadingState(message: 'Dossier laden...'),
        error: (err, stack) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(currentDossierProvider),
        ),
        data: (dossier) {
          if (dossier == null) {
            return const EmptyState(
              icon: Icons.folder_off,
              title: 'Dossier niet gevonden',
              subtitle: 'Selecteer of maak een nieuw dossier',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(currentDossierProvider);
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                // Dossier Header
                DossierHeader(
                  name: dossier.name,
                  description: dossier.description,
                  icon: dossier.icon,
                  colorName: dossier.color,
                  onSwitch: () => _showDossierSelector(context),
                  onEdit: () => _editDossier(context, dossier.id),
                ),
                
                // Hoofdmodules section
                const SectionHeader(title: 'Hoofdmodules'),
                
                // Module cards - eerst de beschikbare modules
                ..._allModules.where((m) => m.isAvailable).map((module) => ModuleCard(
                  module: ModuleInfo(
                    id: module.id,
                    label: module.label,
                    description: module.description,
                    icon: module.icon,
                    emoji: module.emoji,
                    color: module.color,
                    isAvailable: module.isAvailable,
                  ),
                  onTap: () => _navigateToModule(context, ref, module, selectedDossierId),
                )),
                
                // Binnenkort beschikbaar section
                const SectionHeader(title: 'Binnenkort beschikbaar'),
                
                // Locked modules
                ..._allModules.where((m) => !m.isAvailable).map((module) => ModuleCard(
                  module: ModuleInfo(
                    id: module.id,
                    label: module.label,
                    description: module.description,
                    icon: module.icon,
                    emoji: module.emoji,
                    color: module.color,
                    isAvailable: false,
                  ),
                  onTap: () => _showLockedMessage(context, module.label),
                )),
                
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showDossierSelector(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectDossierScreen()),
    );
  }

  void _editDossier(BuildContext context, String dossierId) {
    // TODO: Navigate to edit dossier screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dossier bewerken wordt binnenkort toegevoegd'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _navigateToModule(BuildContext context, WidgetRef ref, AppModule module, String dossierId) {
    Widget? screen;
    
    switch (module.id) {
      case 'persons':
        screen = SelectPersonScreen(dossierId: dossierId);
        break;
      case 'household':
        screen = HouseholdScreen(dossierId: dossierId);
        break;
      case 'money':
        screen = MoneyDashboardScreen(dossierId: dossierId);
        break;
      case 'housing':
        // Housing needs personId - for now use a placeholder
        // In production, you'd select/determine the primary person
        screen = _HousingPersonSelector(dossierId: dossierId);
        break;
      case 'assets':
        screen = AssetDashboardScreen(dossierId: dossierId);
        break;
      case 'subscriptions':
        screen = Scaffold(
          appBar: AppBar(title: const Text('Abonnementen')),
          body: SubscriptionDashboardScreen(dossierId: dossierId),
        );
        break;
      case 'contacts':
        screen = ContactsScreen(dossierId: dossierId);
        break;
    }
    
    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen!),
      );
    }
  }

  void _showLockedMessage(BuildContext context, String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$moduleName is binnenkort beschikbaar!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Helper widget to select person for housing module
class _HousingPersonSelector extends ConsumerWidget {
  final String dossierId;
  
  const _HousingPersonSelector({required this.dossierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // For now, just navigate to housing with a placeholder personId
    // In a full implementation, you'd have the user select a person first
    // or automatically select the primary account holder
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HousingDashboardScreen(
            dossierId: dossierId,
            personId: 'primary', // Placeholder
          ),
        ),
      );
    });
    
    return const Scaffold(
      body: LoadingState(message: 'Laden...'),
    );
  }
}
