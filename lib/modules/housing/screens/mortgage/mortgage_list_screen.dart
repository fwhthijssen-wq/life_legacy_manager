// lib/modules/housing/screens/mortgage/mortgage_list_screen.dart
// Lijst van hypotheken voor een woning

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/mortgage_model.dart';
import '../../providers/housing_providers.dart';
import 'mortgage_detail_screen.dart';

class MortgageListScreen extends ConsumerWidget {
  final String propertyId;

  const MortgageListScreen({
    super.key,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mortgagesAsync = ref.watch(mortgagesProvider(propertyId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hypotheek'),
      ),
      body: mortgagesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Fout: $err')),
        data: (mortgages) {
          if (mortgages.isEmpty) {
            return _buildEmptyState(context, theme, ref);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: mortgages.length,
            itemBuilder: (context, index) {
              final mortgage = mortgages[index];
              return _buildMortgageCard(context, mortgage, ref);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addMortgage(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Hypotheek toevoegen'),
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
            Icon(Icons.account_balance_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Nog geen hypotheek',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Voeg je hypotheekgegevens toe',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _addMortgage(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Hypotheek toevoegen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMortgageCard(BuildContext context, MortgageModel mortgage, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('🏦', style: TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          mortgage.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          mortgage.mortgageNumber ?? 'Hypotheek',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.green),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MortgageDetailScreen(
                propertyId: propertyId,
                mortgageId: mortgage.id,
              ),
            ),
          ).then((_) => ref.invalidate(mortgagesProvider(propertyId)));
        },
      ),
    );
  }

  Future<void> _addMortgage(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(housingRepositoryProvider);
    
    final mortgageId = await repo.createMortgage(
      propertyId: propertyId,
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MortgageDetailScreen(
          propertyId: propertyId,
          mortgageId: mortgageId,
          isNew: true,
        ),
      ),
    ).then((_) => ref.invalidate(mortgagesProvider(propertyId)));
  }
}





