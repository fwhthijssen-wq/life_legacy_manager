// lib/modules/housing/screens/installations/installation_list_screen.dart
// Lijst van technische installaties voor een woning

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/installation_model.dart';
import '../../models/housing_enums.dart';
import '../../providers/housing_providers.dart';
import 'installation_detail_screen.dart';

class InstallationListScreen extends ConsumerWidget {
  final String propertyId;

  const InstallationListScreen({
    super.key,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final installationsAsync = ref.watch(installationsProvider(propertyId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Technische Installaties'),
      ),
      body: installationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Fout: $err')),
        data: (installations) {
          if (installations.isEmpty) {
            return _buildEmptyState(context, theme, ref);
          }
          
          // Groepeer per type
          final grouped = <InstallationType, List<InstallationModel>>{};
          for (final inst in installations) {
            grouped.putIfAbsent(inst.installationType, () => []).add(inst);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (final type in grouped.keys) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Text(type.emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(width: 8),
                      Text(type.label, style: theme.textTheme.titleMedium),
                    ],
                  ),
                ),
                ...grouped[type]!.map((inst) => _buildInstallationCard(context, inst, ref)),
                const SizedBox(height: 16),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Installatie toevoegen'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.build_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Nog geen installaties',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Voeg CV-ketel, zonnepanelen, etc. toe',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _showAddDialog(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Installatie toevoegen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallationCard(BuildContext context, InstallationModel installation, WidgetRef ref) {
    final percentage = installation.completenessPercentage;
    final progressColor = percentage >= 80 ? Colors.green : percentage >= 50 ? Colors.orange : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.deepOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(installation.installationType.emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          installation.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          installation.location ?? installation.installationType.label,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: progressColor,
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
            const Icon(Icons.chevron_right, color: Colors.deepOrange),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => InstallationDetailScreen(
                propertyId: propertyId,
                installationId: installation.id,
              ),
            ),
          ).then((_) => ref.invalidate(installationsProvider(propertyId)));
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type installatie', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: InstallationType.values.map((type) => ActionChip(
                avatar: Text(type.emoji),
                label: Text(type.label),
                onPressed: () {
                  Navigator.pop(context);
                  _addInstallation(context, ref, type);
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addInstallation(BuildContext context, WidgetRef ref, InstallationType type) async {
    final repo = ref.read(housingRepositoryProvider);
    
    final installationId = await repo.createInstallation(
      propertyId: propertyId,
      installationType: type,
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InstallationDetailScreen(
          propertyId: propertyId,
          installationId: installationId,
          isNew: true,
        ),
      ),
    ).then((_) => ref.invalidate(installationsProvider(propertyId)));
  }
}





