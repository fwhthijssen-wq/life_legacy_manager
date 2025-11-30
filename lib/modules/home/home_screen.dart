// lib/modules/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../dossier/screens/select_dossier_screen.dart';
import '../dossier/dossier_providers.dart';
import '../person/select_person_screen.dart';

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
              // ⭐ Dossier Info Card - NIEUW
              Card(
                color: _getColor(dossier.color).withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
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
                      
                      // Wissel knop
                      IconButton(
                        icon: const Icon(Icons.swap_horiz),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SelectDossierScreen(),
                            ),
                          );
                        },
                        tooltip: l10n.dossierSelect,
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),

              // Personen beheren knop
              Card(
                child: ListTile(
                  leading: const Icon(Icons.people, size: 32),
                  title: Text(
                    l10n.personManage,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(l10n.personManageSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelectPersonScreen(dossierId: selectedDossierId),
                      ),
                    );
                  },
                ),
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
