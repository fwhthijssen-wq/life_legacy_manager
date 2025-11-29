// lib/modules/dossier/screens/select_dossier_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../dossier_model.dart';
import '../dossier_providers.dart';
import '../dossier_repository.dart';
import 'create_dossier_screen.dart';
import '../../home/home_screen.dart';

class SelectDossierScreen extends ConsumerWidget {
  const SelectDossierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dossiersAsync = ref.watch(dossiersProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dossierSelect),
        automaticallyImplyLeading: false,
      ),
      body: dossiersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('${l10n.error}: $err')),
        data: (dossiers) {
          if (dossiers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.folder_open, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n.dossierNoDossiers,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.dossierCreateFirst,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _createDossier(context, ref),
                    icon: const Icon(Icons.add),
                    label: Text(l10n.dossierCreate),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.dossierSelectSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: dossiers.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final dossier = dossiers[index];
                    return _DossierCard(
                      dossier: dossier,
                      onTap: () => _selectDossier(context, ref, dossier),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createDossier(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l10n.dossierCreate),
      ),
    );
  }

  Future<void> _createDossier(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateDossierScreen()),
    );

    if (result == true) {
      refreshDossiers(ref);
    }
  }

  void _selectDossier(BuildContext context, WidgetRef ref, DossierModel dossier) {
    ref.read(selectedDossierIdProvider.notifier).state = dossier.id;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}

class _DossierCard extends ConsumerWidget {
  final DossierModel dossier;
  final VoidCallback onTap;

  const _DossierCard({required this.dossier, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(),
                  color: _getColor(),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dossier.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    if (dossier.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        dossier.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    FutureBuilder<int>(
                      future: DossierRepository.getPersonCountInDossier(dossier.id),
                      builder: (context, snapshot) {
                        final count = snapshot.data ?? 0;
                        // ✅ AANGEPAST: Gebruik string interpolation in plaats van replaceAll
                        return Text(
                          '$count ${count == 1 ? "persoon" : "personen"}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (dossier.icon) {
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

  Color _getColor() {
    switch (dossier.color) {
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