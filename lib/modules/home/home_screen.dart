// lib/modules/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/app_database.dart';
import '../../l10n/app_localizations.dart';
import '../dossier/screens/select_dossier_screen.dart';
import '../dossier/dossier_providers.dart';
import '../person/select_person_screen.dart';
import '../person/person_model.dart';
import '../household/screens/household_screen.dart';
import '../contacts/screens/contacts_screen.dart';

/// Statistieken voor een module
class ModuleStats {
  final int totalItems;
  final int completedItems;
  final int averagePercentage;

  ModuleStats({
    required this.totalItems,
    required this.completedItems,
    required this.averagePercentage,
  });
}

/// Provider voor contacten statistieken
final contactsStatsProvider = FutureProvider.family<ModuleStats, String>((ref, dossierId) async {
  final db = ref.read(appDatabaseProvider);
  final results = await db.query(
    'persons',
    where: 'dossier_id = ? AND is_contact = 1',
    whereArgs: [dossierId],
  );
  
  if (results.isEmpty) {
    return ModuleStats(totalItems: 0, completedItems: 0, averagePercentage: 0);
  }

  final contacts = results.map((map) => PersonModel.fromMap(map)).toList();
  
  int totalPercentage = 0;
  int completedCount = 0;
  
  for (final contact in contacts) {
    final percentage = _calculateContactCompleteness(contact);
    totalPercentage += percentage;
    if (percentage >= 80) completedCount++;
  }
  
  return ModuleStats(
    totalItems: contacts.length,
    completedItems: completedCount,
    averagePercentage: contacts.isNotEmpty ? (totalPercentage / contacts.length).round() : 0,
  );
});

/// Provider voor personen statistieken (niet-contacten)
final personsStatsProvider = FutureProvider.family<ModuleStats, String>((ref, dossierId) async {
  final db = ref.read(appDatabaseProvider);
  final results = await db.query(
    'persons',
    where: 'dossier_id = ? AND (is_contact = 0 OR is_contact IS NULL)',
    whereArgs: [dossierId],
  );
  
  if (results.isEmpty) {
    return ModuleStats(totalItems: 0, completedItems: 0, averagePercentage: 0);
  }

  final persons = results.map((map) => PersonModel.fromMap(map)).toList();
  
  int totalPercentage = 0;
  int completedCount = 0;
  
  for (final person in persons) {
    final percentage = _calculatePersonCompleteness(person);
    totalPercentage += percentage;
    if (percentage >= 80) completedCount++;
  }
  
  return ModuleStats(
    totalItems: persons.length,
    completedItems: completedCount,
    averagePercentage: persons.isNotEmpty ? (totalPercentage / persons.length).round() : 0,
  );
});

/// Provider voor gezin/huishouden statistieken
final householdStatsProvider = FutureProvider.family<ModuleStats, String>((ref, dossierId) async {
  final db = ref.read(appDatabaseProvider);
  final results = await db.query(
    'household_members',
    where: 'dossier_id = ?',
    whereArgs: [dossierId],
  );
  
  if (results.isEmpty) {
    return ModuleStats(totalItems: 0, completedItems: 0, averagePercentage: 0);
  }

  // Haal de gekoppelde personen op voor elke household member
  int totalPercentage = 0;
  int completedCount = 0;
  
  for (final member in results) {
    final personId = member['person_id'] as String?;
    if (personId != null) {
      final personResults = await db.query(
        'persons',
        where: 'id = ?',
        whereArgs: [personId],
      );
      if (personResults.isNotEmpty) {
        final person = PersonModel.fromMap(personResults.first);
        final percentage = _calculatePersonCompleteness(person);
        totalPercentage += percentage;
        if (percentage >= 80) completedCount++;
      }
    }
  }
  
  return ModuleStats(
    totalItems: results.length,
    completedItems: completedCount,
    averagePercentage: results.isNotEmpty ? (totalPercentage / results.length).round() : 0,
  );
});

/// Bereken percentage voor een contact
int _calculateContactCompleteness(PersonModel contact) {
  int filled = 0;
  const int total = 10;
  
  filled += 2; // firstName, lastName (altijd ingevuld)
  if (contact.email != null && contact.email!.isNotEmpty) filled++;
  if (contact.phone != null && contact.phone!.isNotEmpty) filled++;
  if (contact.address != null && contact.address!.isNotEmpty) filled++;
  if (contact.city != null && contact.city!.isNotEmpty) filled++;
  if (contact.postalCode != null && contact.postalCode!.isNotEmpty) filled++;
  if (contact.contactCategory != null) filled++;
  if (contact.forChristmasCard || contact.forNewsletter || 
      contact.forParty || contact.forFuneral) filled++;
  if (contact.notes != null && contact.notes!.isNotEmpty) filled++;
  
  return ((filled / total) * 100).round();
}

/// Bereken percentage voor een persoon
int _calculatePersonCompleteness(PersonModel person) {
  int filled = 0;
  const int total = 10;
  
  filled += 2; // firstName, lastName (altijd ingevuld)
  if (person.phone != null && person.phone!.isNotEmpty) filled++;
  if (person.email != null && person.email!.isNotEmpty) filled++;
  if (person.birthDate != null && person.birthDate!.isNotEmpty) filled++;
  if (person.address != null && person.address!.isNotEmpty) filled++;
  if (person.postalCode != null && person.postalCode!.isNotEmpty) filled++;
  if (person.city != null && person.city!.isNotEmpty) filled++;
  if (person.gender != null && person.gender!.isNotEmpty) filled++;
  if (person.relation != null && person.relation!.isNotEmpty) filled++;
  
  return ((filled / total) * 100).round();
}

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
          // Folder icoon om dossier te wisselen
          IconButton(
            icon: const Icon(Icons.folder),
            tooltip: l10n.dossierSelect,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SelectDossierScreen()),
              );
            },
          ),
        ],
      ),
      body: currentDossierAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (dossier) {
          if (dossier == null) {
            return const Center(child: Text('Dossier niet gevonden'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ⭐ Dossier Info Card - Klikbaar om te wisselen
              Card(
                color: _getColor(dossier.color).withOpacity(0.1),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SelectDossierScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Icoon
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: _getColor(dossier.color).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getIcon(dossier.icon),
                                color: _getColor(dossier.color),
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dossier.name,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (dossier.description != null) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      dossier.description!,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            // Pijl icoon
                            Icon(
                              Icons.chevron_right,
                              color: _getColor(dossier.color),
                            ),
                          ],
                        ),
                        
                        // Duidelijke "Wissel dossier" tekst
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: _getColor(dossier.color).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.swap_horiz,
                                size: 18,
                                color: _getColor(dossier.color),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Tik hier om van dossier te wisselen',
                                style: TextStyle(
                                  color: _getColor(dossier.color),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Gezin/Huishouden - MET PERCENTAGE BALK
              _ModuleCard(
                icon: Icons.family_restroom,
                iconColor: Colors.blue,
                title: 'Gezin',
                subtitle: 'Beheer gezinsleden voor dit dossier',
                statsProvider: householdStatsProvider(selectedDossierId),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HouseholdScreen(dossierId: selectedDossierId),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 8),

              // Contacten knop - MET PERCENTAGE BALK
              _ModuleCard(
                icon: Icons.contacts,
                iconColor: Colors.green,
                title: 'Contacten',
                subtitle: 'Adresboek voor rouwkaarten, mailings',
                statsProvider: contactsStatsProvider(selectedDossierId),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ContactsScreen(dossierId: selectedDossierId),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 8),

              // Personen beheren - MET PERCENTAGE BALK
              _ModuleCard(
                icon: Icons.people,
                iconColor: Colors.deepPurple,
                title: l10n.personManage,
                subtitle: l10n.personManageSubtitle,
                statsProvider: personsStatsProvider(selectedDossierId),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SelectPersonScreen(dossierId: selectedDossierId),
                    ),
                  );
                },
              ),
              
              const SizedBox(height: 16),

              // Placeholder voor toekomstige modules
              Card(
                color: Colors.grey[100],
                child: ListTile(
                  leading: Icon(Icons.euro, size: 32, color: Colors.grey[400]),
                  title: Text(
                    l10n.moneyMatters,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  subtitle: Text(
                    'Binnenkort beschikbaar',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  trailing: Icon(Icons.lock, color: Colors.grey[400]),
                ),
              ),
              
              const SizedBox(height: 8),
              
              Card(
                color: Colors.grey[100],
                child: ListTile(
                  leading: Icon(Icons.home, size: 32, color: Colors.grey[400]),
                  title: Text(
                    l10n.houseEnergy,
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  subtitle: Text(
                    'Binnenkort beschikbaar',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                  trailing: Icon(Icons.lock, color: Colors.grey[400]),
                ),
              ),
            ],
          );
        },
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
      default:
        return Colors.teal;
    }
  }
}

/// Module kaart met percentage balk
class _ModuleCard extends ConsumerWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final FutureProvider<ModuleStats> statsProvider;
  final VoidCallback onTap;

  const _ModuleCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.statsProvider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Icoon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 28, color: iconColor),
                  ),
                  const SizedBox(width: 16),
                  
                  // Titel en subtitel
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Chevron
                  const Icon(Icons.chevron_right),
                ],
              ),
              
              // Statistieken en percentage balk
              statsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: LinearProgressIndicator(),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (stats) {
                  if (stats.totalItems == 0) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.grey[500]),
                            const SizedBox(width: 8),
                            Text(
                              'Nog geen items toegevoegd',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  final percentage = stats.averagePercentage;
                  final progressColor = percentage >= 80 ? Colors.green :
                                        percentage >= 50 ? Colors.orange : Colors.red;
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children: [
                        // Stats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${stats.totalItems} ${stats.totalItems == 1 ? 'item' : 'items'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  percentage >= 80 ? Icons.check_circle :
                                  percentage >= 50 ? Icons.warning : Icons.error,
                                  size: 14,
                                  color: progressColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${stats.completedItems}/${stats.totalItems} compleet',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Progress bar
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: percentage / 100,
                                backgroundColor: Colors.grey[200],
                                minHeight: 8,
                                borderRadius: BorderRadius.circular(4),
                                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '$percentage%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: progressColor,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
