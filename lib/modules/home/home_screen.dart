// lib/modules/home/home_screen.dart
// Hoofdscherm met horizontale module tabs en dossier dropdown

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../dossier/screens/select_dossier_screen.dart';
import '../dossier/screens/create_dossier_screen.dart';
import '../dossier/dossier_providers.dart';
import '../dossier/dossier_model.dart';
import '../personal_data/screens/personal_data_dashboard_screen.dart';
import '../money/screens/money_dashboard_screen.dart';
import '../money/screens/bank_accounts/bank_accounts_list_screen.dart';
import '../money/screens/insurances/insurances_list_screen.dart';
import '../money/screens/pensions/pensions_list_screen.dart';
import '../money/screens/incomes/incomes_list_screen.dart';
import '../money/screens/expenses/expenses_list_screen.dart';
import '../money/screens/debts/debts_list_screen.dart';
import '../housing/screens/housing_dashboard_screen.dart';
import '../assets/screens/asset_dashboard_screen.dart';
import '../subscriptions/screens/subscription_dashboard_screen.dart';
import '../household/screens/household_screen.dart';
import '../household/providers/household_providers.dart';
import '../contacts/screens/contacts_screen.dart';
import '../person/select_person_screen.dart';
import '../../core/person_repository.dart';

/// Definitie van een module tab
class ModuleTab {
  final String id;
  final String label;
  final IconData icon;
  final String emoji;
  final Color color;
  final bool isAvailable;
  final List<CategoryDef> categories;
  
  const ModuleTab({
    required this.id,
    required this.label,
    required this.icon,
    required this.emoji,
    required this.color,
    this.isAvailable = true,
    this.categories = const [],
  });
}

/// Categorie definitie binnen een module
class CategoryDef {
  final String id;
  final String label;
  final String emoji;
  final Color color;
  
  const CategoryDef({
    required this.id,
    required this.label,
    required this.emoji,
    required this.color,
  });
}

/// Alle module tabs
final List<ModuleTab> _moduleTabs = [
  ModuleTab(
    id: 'personal_data',
    label: 'Persoonlijke gegevens',
    icon: Icons.person,
    emoji: '👤',
    color: AppColors.primary,
    categories: [
      CategoryDef(id: 'gezin', label: 'Dossierleden', emoji: '👨‍👩‍👧', color: AppColors.primary),
      CategoryDef(id: 'contacten', label: 'Contacten', emoji: '📇', color: AppColors.moduleContacts),
      CategoryDef(id: 'personen', label: 'Personen', emoji: '👥', color: AppColors.modulePersons),
    ],
  ),
  ModuleTab(
    id: 'money',
    label: 'Geldzaken',
    icon: Icons.euro,
    emoji: '€',
    color: AppColors.moduleMoney,
    categories: [
      CategoryDef(id: 'bankrekeningen', label: 'Bankrekeningen', emoji: '🏦', color: Colors.blue),
      CategoryDef(id: 'verzekeringen', label: 'Verzekeringen', emoji: '🛡️', color: Colors.orange),
      CategoryDef(id: 'pensioenen', label: 'Pensioenen', emoji: '👴', color: Colors.purple),
      CategoryDef(id: 'inkomsten', label: 'Inkomsten', emoji: '💵', color: Colors.green),
      CategoryDef(id: 'vaste_lasten', label: 'Vaste lasten', emoji: '📋', color: Colors.red),
      CategoryDef(id: 'schulden', label: 'Schulden & Leningen', emoji: '💳', color: Colors.brown),
      CategoryDef(id: 'beleggingen', label: 'Beleggingen', emoji: '📈', color: Colors.teal),
    ],
  ),
  ModuleTab(
    id: 'housing',
    label: 'Wonen',
    icon: Icons.home,
    emoji: '🏠',
    color: AppColors.moduleHousing,
    isAvailable: true,
  ),
  ModuleTab(
    id: 'assets',
    label: 'Bezittingen',
    icon: Icons.inventory_2,
    emoji: '📦',
    color: AppColors.moduleAssets,
  ),
  ModuleTab(
    id: 'subscriptions',
    label: 'Abonnementen',
    icon: Icons.subscriptions,
    emoji: '📋',
    color: AppColors.moduleSubscriptions,
  ),
  ModuleTab(
    id: 'documents',
    label: 'Documenten',
    icon: Icons.folder,
    emoji: '📁',
    color: AppColors.moduleDocuments,
    isAvailable: false,
  ),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _moduleTabs.length,
      vsync: this,
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    // Check of er een dossier geselecteerd is
    final selectedDossierId = ref.watch(selectedDossierIdProvider);
    
    if (selectedDossierId == null) {
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

    final currentDossierAsync = ref.watch(currentDossierProvider);
    final dossiersAsync = ref.watch(dossiersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Lichtgroene achtergrond
      body: SafeArea(
        child: Column(
          children: [
            // === TOP BAR: Dossier selector + Taal ===
            _buildTopBar(currentDossierAsync, dossiersAsync),
            
            // === MODULE TABS ===
            _buildModuleTabs(),
            
            // === CONTENT ===
            Expanded(
              child: _buildContent(selectedDossierId),
            ),
          ],
        ),
      ),
    );
  }

  /// Top bar met dossier button links en taal selector rechts
  Widget _buildTopBar(
    AsyncValue<DossierModel?> currentDossierAsync,
    AsyncValue<List<DossierModel>> dossiersAsync,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          // Dossier selector button
          currentDossierAsync.when(
            loading: () => const SizedBox(width: 150, height: 50),
            error: (_, __) => const SizedBox.shrink(),
            data: (dossier) => _DossierButton(
              dossier: dossier,
              allDossiers: dossiersAsync.valueOrNull ?? [],
              onDossierSelected: (id) {
                ref.read(selectedDossierIdProvider.notifier).state = id;
              },
              onManageDossiers: () => _showDossierManagement(context),
              onNewDossier: () => _createNewDossier(context),
            ),
          ),
          
          const Spacer(),
          
          // Taal selector
          _LanguageSelector(),
        ],
      ),
    );
  }

  /// Horizontale module tabs
  Widget _buildModuleTabs() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: _moduleTabs.length,
              itemBuilder: (context, index) {
                final tab = _moduleTabs[index];
                final isSelected = _tabController.index == index;
                
                return _ModuleTabButton(
                  label: tab.label,
                  icon: tab.icon,
                  badge: 0, // TODO: Calculate actual count
                  isSelected: isSelected,
                  isAvailable: tab.isAvailable,
                  onTap: tab.isAvailable 
                    ? () {
                        _tabController.animateTo(index);
                        setState(() {});
                      }
                    : null,
                );
              },
            ),
          ),
          // Groene indicator lijn onder actieve tab
          Container(
            height: 3,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  /// Content gebaseerd op actieve tab
  Widget _buildContent(String dossierId) {
    final currentTab = _moduleTabs[_tabController.index];
    
    // Voor Persoonlijke gegevens tab - met echte counts
    if (currentTab.id == 'personal_data') {
      return _PersonalDataContent(
        dossierId: dossierId,
        categories: currentTab.categories,
        onCategoryTap: (categoryId) => _navigateToCategory(context, dossierId, currentTab.id, categoryId),
      );
    }
    
    // Voor andere tabs met categorieën
    if (currentTab.categories.isNotEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: currentTab.categories.length,
        itemBuilder: (context, index) {
          final category = currentTab.categories[index];
          return _CategoryCard(
            label: category.label,
            emoji: category.emoji,
            itemCount: 0,
            onTap: () => _navigateToCategory(context, dossierId, currentTab.id, category.id),
          );
        },
      );
    }
    
    // Voor andere modules, navigeer direct
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => _navigateToModule(context, dossierId, currentTab),
        icon: Icon(currentTab.icon),
        label: Text('Open ${currentTab.label}'),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String dossierId, String moduleId, String categoryId) {
    Widget? screen;
    
    switch (categoryId) {
      // Personal data categorieën
      case 'gezin':
        screen = HouseholdScreen(dossierId: dossierId);
        break;
      case 'contacten':
        screen = ContactsScreen(dossierId: dossierId);
        break;
      case 'personen':
        screen = SelectPersonScreen(dossierId: dossierId);
        break;
      
      // Money categorieën - navigeer direct naar de juiste lijst
      case 'bankrekeningen':
        screen = BankAccountsListScreen(dossierId: dossierId);
        break;
      case 'verzekeringen':
        screen = InsurancesListScreen(dossierId: dossierId);
        break;
      case 'pensioenen':
        screen = PensionsListScreen(dossierId: dossierId);
        break;
      case 'inkomsten':
        screen = IncomesListScreen(dossierId: dossierId);
        break;
      case 'vaste_lasten':
        screen = ExpensesListScreen(dossierId: dossierId);
        break;
      case 'schulden':
        screen = DebtsListScreen(dossierId: dossierId);
        break;
      case 'beleggingen':
        // Beleggingen is nog niet geïmplementeerd
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Beleggingen is binnenkort beschikbaar!')),
        );
        return;
    }
    
    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    }
  }

  void _navigateToModule(BuildContext context, String dossierId, ModuleTab tab) {
    Widget? screen;
    
    switch (tab.id) {
      case 'personal_data':
        screen = PersonalDataDashboardScreen(dossierId: dossierId);
        break;
      case 'money':
        screen = MoneyDashboardScreen(dossierId: dossierId);
        break;
      case 'housing':
        screen = HousingDashboardScreen(dossierId: dossierId, personId: 'primary');
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
    }
    
    if (screen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => screen!));
    }
  }

  void _showDossierManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SelectDossierScreen(manageMode: true)),
    );
  }

  void _createNewDossier(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateDossierScreen()),
    );
    
    if (result == true) {
      // Refresh dossiers after creation
      ref.invalidate(dossiersProvider);
    }
  }
}

/// Dossier selector button (oranje, linksboven)
class _DossierButton extends StatelessWidget {
  final DossierModel? dossier;
  final List<DossierModel> allDossiers;
  final Function(String) onDossierSelected;
  final VoidCallback onManageDossiers;
  final VoidCallback onNewDossier;
  
  const _DossierButton({
    required this.dossier,
    required this.allDossiers,
    required this.onDossierSelected,
    required this.onManageDossiers,
    required this.onNewDossier,
  });

  @override
  Widget build(BuildContext context) {
    if (dossier == null) return const SizedBox.shrink();
    
    return InkWell(
      onTap: () => _showDossierDropdown(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF3E0), // Licht oranje achtergrond
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Persoon icoon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            
            // Naam en subtitle
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      dossier!.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey.shade600,
                      size: 20,
                    ),
                  ],
                ),
                Text(
                  'Tik om te wisselen',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDossierDropdown(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _DossierDropdownDialog(
        currentDossier: dossier,
        allDossiers: allDossiers,
        onDossierSelected: (id) {
          Navigator.pop(context);
          onDossierSelected(id);
        },
        onManageDossiers: () {
          Navigator.pop(context);
          onManageDossiers();
        },
        onNewDossier: () {
          Navigator.pop(context);
          onNewDossier();
        },
      ),
    );
  }
}

/// Dossier dropdown dialog
class _DossierDropdownDialog extends StatelessWidget {
  final DossierModel? currentDossier;
  final List<DossierModel> allDossiers;
  final Function(String) onDossierSelected;
  final VoidCallback onManageDossiers;
  final VoidCallback onNewDossier;
  
  const _DossierDropdownDialog({
    required this.currentDossier,
    required this.allDossiers,
    required this.onDossierSelected,
    required this.onManageDossiers,
    required this.onNewDossier,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: Alignment.topLeft,
      insetPadding: const EdgeInsets.only(left: 12, top: 70, right: 100),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Kies een dossier',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            
            // Dossier lijst
            ...allDossiers.map((d) => _DossierListTile(
              dossier: d,
              isSelected: d.id == currentDossier?.id,
              onTap: () => onDossierSelected(d.id),
            )),
            
            const Divider(height: 1),
            
            // Beheren optie
            ListTile(
              leading: Icon(Icons.settings, color: Colors.grey.shade700),
              title: const Text('Dossiers beheren'),
              onTap: onManageDossiers,
            ),
            
            // Nieuw dossier optie
            ListTile(
              leading: const Icon(Icons.add_circle_outline, color: AppColors.primary),
              title: Text(
                'Nieuw dossier',
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500),
              ),
              onTap: onNewDossier,
            ),
            
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Dossier list tile in dropdown
class _DossierListTile extends StatelessWidget {
  final DossierModel dossier;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _DossierListTile({
    required this.dossier,
    required this.isSelected,
    required this.onTap,
  });

  Color _getColor() {
    switch (dossier.color) {
      case 'orange': return Colors.orange;
      case 'teal': return Colors.teal;
      case 'blue': return Colors.blue;
      case 'green': return Colors.green;
      case 'purple': return Colors.purple;
      default: return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          dossier.icon == 'folder' ? Icons.folder : Icons.person,
          color: color,
        ),
      ),
      title: Text(
        dossier.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        dossier.type.displayName,
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: isSelected 
        ? const Icon(Icons.check_circle, color: Colors.green)
        : null,
      onTap: onTap,
    );
  }
}

/// Taal selector (vlag dropdown)
class _LanguageSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nederlandse vlag
            Container(
              width: 28,
              height: 20,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  Expanded(child: Container(color: Colors.red)),
                  Expanded(child: Container(color: Colors.white)),
                  Expanded(child: Container(color: Colors.blue)),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'nl',
          child: Row(
            children: [
              _buildFlag('nl'),
              const SizedBox(width: 8),
              const Text('Nederlands'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'en',
          child: Row(
            children: [
              _buildFlag('en'),
              const SizedBox(width: 8),
              const Text('English'),
            ],
          ),
        ),
      ],
      onSelected: (lang) {
        // TODO: Change language
      },
    );
  }

  Widget _buildFlag(String lang) {
    if (lang == 'nl') {
      return Container(
        width: 24,
        height: 16,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          children: [
            Expanded(child: Container(color: Colors.red)),
            Expanded(child: Container(color: Colors.white)),
            Expanded(child: Container(color: Colors.blue)),
          ],
        ),
      );
    } else {
      // UK flag simplified
      return Container(
        width: 24,
        height: 16,
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.circular(2),
        ),
        child: const Center(
          child: Text('🇬🇧', style: TextStyle(fontSize: 12)),
        ),
      );
    }
  }
}

/// Module tab button
class _ModuleTabButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final int badge;
  final bool isSelected;
  final bool isAvailable;
  final VoidCallback? onTap;
  
  const _ModuleTabButton({
    required this.label,
    required this.icon,
    required this.badge,
    required this.isSelected,
    required this.isAvailable,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected 
        ? AppColors.primary 
        : (isAvailable ? Colors.grey.shade700 : Colors.grey.shade400);
    
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
            if (badge > 0 || isSelected) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$badge',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Content voor Persoonlijke gegevens tab met echte counts
class _PersonalDataContent extends ConsumerWidget {
  final String dossierId;
  final List<CategoryDef> categories;
  final Function(String) onCategoryTap;

  const _PersonalDataContent({
    required this.dossierId,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Haal household members op
    final householdAsync = ref.watch(householdMembersProvider(dossierId));
    // Haal contacten op
    final contactsAsync = ref.watch(contactsProvider(dossierId));

    return FutureBuilder<List<dynamic>>(
      future: PersonRepository.getPersonsForDossier(dossierId),
      builder: (context, personsSnapshot) {
        final persons = personsSnapshot.data ?? [];
        final personsCount = persons.length;
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: categories.map((category) {
            int itemCount = 0;
            int? percentage;
            
            switch (category.id) {
              case 'gezin':
                final members = householdAsync.valueOrNull ?? [];
                itemCount = members.length;
                percentage = _calculateHouseholdCompleteness(members);
                break;
              case 'contacten':
                final contacts = contactsAsync.valueOrNull ?? [];
                itemCount = contacts.length;
                percentage = _calculateContactsCompleteness(contacts);
                break;
              case 'personen':
                itemCount = personsCount;
                percentage = _calculatePersonsCompleteness(persons);
                break;
            }
            
            return _CategoryCard(
              label: category.label,
              emoji: category.emoji,
              itemCount: itemCount,
              percentage: itemCount > 0 ? percentage : null,
              onTap: () => onCategoryTap(category.id),
            );
          }).toList(),
        );
      },
    );
  }
  
  /// Bereken completeness voor household members (gemiddelde per lid)
  int _calculateHouseholdCompleteness(List<Map<String, dynamic>> members) {
    if (members.isEmpty) return 0;
    
    int totalPercentage = 0;
    
    for (final member in members) {
      int filled = 0;
      const int total = 5; // name, relation, birthdate, phone, email
      
      if (member['name']?.toString().isNotEmpty == true) filled++;
      if (member['relation']?.toString().isNotEmpty == true) filled++;
      if (member['birth_date']?.toString().isNotEmpty == true) filled++;
      if (member['phone']?.toString().isNotEmpty == true) filled++;
      if (member['email']?.toString().isNotEmpty == true) filled++;
      
      totalPercentage += ((filled / total) * 100).round();
    }
    
    // Gemiddelde percentage over alle leden
    return (totalPercentage / members.length).round();
  }
  
  /// Bereken completeness voor contacten (gemiddelde per contact)
  int _calculateContactsCompleteness(List<dynamic> contacts) {
    if (contacts.isEmpty) return 0;
    
    int totalPercentage = 0;
    
    for (final contact in contacts) {
      int filled = 0;
      const int total = 4; // naam, phone, email, address
      
      // Naam is ingevuld als firstName of lastName niet leeg is
      if ((contact.firstName?.isNotEmpty == true) || 
          (contact.lastName?.isNotEmpty == true)) filled++;
      if (contact.phone?.isNotEmpty == true) filled++;
      if (contact.email?.isNotEmpty == true) filled++;
      if (contact.address?.isNotEmpty == true) filled++;
      
      totalPercentage += ((filled / total) * 100).round();
    }
    
    // Gemiddelde percentage over alle contacten
    return (totalPercentage / contacts.length).round();
  }
  
  /// Bereken completeness voor personen (gemiddelde per persoon)
  int _calculatePersonsCompleteness(List<dynamic> persons) {
    if (persons.isEmpty) return 0;
    
    int totalPercentage = 0;
    
    for (final person in persons) {
      int filled = 0;
      const int total = 4; // firstName, lastName, birthDate, contactinfo
      
      if (person.firstName?.isNotEmpty == true) filled++;
      if (person.lastName?.isNotEmpty == true) filled++;
      if (person.birthDate?.isNotEmpty == true) filled++;
      // Contactbaarheid: telefoon of email
      if ((person.phone?.isNotEmpty == true) || 
          (person.email?.isNotEmpty == true)) filled++;
      
      totalPercentage += ((filled / total) * 100).round();
    }
    
    // Gemiddelde percentage over alle personen
    return (totalPercentage / persons.length).round();
  }
}

/// Categorie kaart (zoals in screenshot)
class _CategoryCard extends StatelessWidget {
  final String label;
  final String emoji;
  final int itemCount;
  final int? percentage;
  final VoidCallback? onTap;
  
  const _CategoryCard({
    required this.label,
    required this.emoji,
    required this.itemCount,
    this.percentage,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9), // Zeer licht groen
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Emoji container
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Label en subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      itemCount == 0 
                        ? 'Nog geen items toegevoegd'
                        : '$itemCount ${itemCount == 1 ? "item" : "items"}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Percentage badge (als er items zijn)
              if (itemCount > 0 && percentage != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getProgressColor(percentage!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$percentage%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              
              // Groene chevron
              Icon(
                Icons.chevron_right,
                color: AppColors.primary,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getProgressColor(int percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }
}
