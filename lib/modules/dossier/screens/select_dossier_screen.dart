// lib/modules/dossier/screens/select_dossier_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../dossier_model.dart';
import '../dossier_providers.dart';
import '../dossier_repository.dart';
import 'create_dossier_screen.dart';
import 'edit_dossier_screen.dart';
import '../../home/home_screen.dart';

class SelectDossierScreen extends ConsumerWidget {
  /// Als true, wordt "Beheren" mode getoond (edit icons zichtbaar)
  final bool manageMode;
  
  const SelectDossierScreen({
    super.key, 
    this.manageMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final dossiersAsync = ref.watch(dossiersProvider);
    final currentDossierId = ref.watch(selectedDossierIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(manageMode ? 'Dossiers beheren' : l10n.dossierSelect),
        leading: manageMode ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ) : null,
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
                  manageMode 
                    ? 'Tik op een dossier om te bewerken'
                    : l10n.dossierSelectSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: dossiers.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final dossier = dossiers[index];
                    final isSelected = dossier.id == currentDossierId;
                    return _DossierCard(
                      dossier: dossier,
                      isSelected: isSelected,
                      showEditButton: manageMode,
                      onTap: manageMode 
                        ? () => _editDossier(context, ref, dossier)
                        : () => _selectDossier(context, ref, dossier),
                      onEdit: () => _editDossier(context, ref, dossier),
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

  Future<void> _editDossier(BuildContext context, WidgetRef ref, DossierModel dossier) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditDossierScreen(dossier: dossier)),
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
  final bool isSelected;
  final bool showEditButton;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const _DossierCard({
    required this.dossier, 
    required this.onTap,
    this.isSelected = false,
    this.showEditButton = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _getColor();
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected 
          ? BorderSide(color: Colors.green, width: 2)
          : BorderSide.none,
      ),
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
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIcon(),
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dossier.name,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Actief',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (dossier.description != null && dossier.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        dossier.description!,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            dossier.type.displayName,
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FutureBuilder<int>(
                          future: DossierRepository.getPersonCountInDossier(dossier.id),
                          builder: (context, snapshot) {
                            final count = snapshot.data ?? 0;
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
                  ],
                ),
              ),
              
              // Edit button of chevron
              if (showEditButton)
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: color),
                  onPressed: onEdit,
                  tooltip: 'Bewerken',
                )
              else
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
