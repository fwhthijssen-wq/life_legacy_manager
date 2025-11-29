// lib/modules/home/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../person/select_person_screen.dart';
import '../dossier/dossier_providers.dart';
import '../dossier/screens/select_dossier_screen.dart';
import '../../l10n/app_localizations.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedDossierId = ref.watch(selectedDossierIdProvider);
    final currentDossierAsync = ref.watch(currentDossierProvider);

    // Als geen dossier geselecteerd, ga naar select screen
    if (selectedDossierId == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const SelectDossierScreen(),
          ),
        );
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: currentDossierAsync.when(
          data: (dossier) => Text(dossier?.name ?? l10n.appTitle),
          loading: () => Text(l10n.appTitle),
          error: (_, __) => Text(l10n.appTitle),
        ),
        actions: [
          // Dossier wissel knop
          IconButton(
            icon: const Icon(Icons.folder_open),
            tooltip: l10n.dossierSelect,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SelectDossierScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Huidige dossier info
            currentDossierAsync.when(
              data: (dossier) {
                if (dossier == null) return const SizedBox.shrink();
                return Card(
                  margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          dossier.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (dossier.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            dossier.description!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              child: Text(l10n.personManage),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SelectPersonScreen(dossierId: selectedDossierId),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
