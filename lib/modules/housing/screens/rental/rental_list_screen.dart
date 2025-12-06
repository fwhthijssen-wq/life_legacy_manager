// lib/modules/housing/screens/rental/rental_list_screen.dart
// Lijst van huurcontracten voor een woning

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/rental_contract_model.dart';
import '../../providers/housing_providers.dart';
import 'rental_detail_screen.dart';

class RentalListScreen extends ConsumerWidget {
  final String propertyId;

  const RentalListScreen({
    super.key,
    required this.propertyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractsAsync = ref.watch(rentalContractsProvider(propertyId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Huurcontract'),
      ),
      body: contractsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Fout: $err')),
        data: (contracts) {
          if (contracts.isEmpty) {
            return _buildEmptyState(context, theme, ref);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contracts.length,
            itemBuilder: (context, index) {
              final contract = contracts[index];
              return _buildContractCard(context, contract, ref);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addContract(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Huurcontract toevoegen'),
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
            Icon(Icons.description_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(
              'Nog geen huurcontract',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Voeg je huurcontract toe',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _addContract(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Huurcontract toevoegen'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContractCard(BuildContext context, RentalContractModel contract, WidgetRef ref) {
    final percentage = contract.completenessPercentage;
    final progressColor = percentage >= 80 ? Colors.green : percentage >= 50 ? Colors.orange : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(contract.landlordType.emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        title: Text(
          contract.displayName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '€ ${contract.totalMonthlyRent.toStringAsFixed(0)}/maand • ${contract.contractType.label}',
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
            const Icon(Icons.chevron_right, color: Colors.orange),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => RentalDetailScreen(
                propertyId: propertyId,
                contractId: contract.id,
              ),
            ),
          ).then((_) => ref.invalidate(rentalContractsProvider(propertyId)));
        },
      ),
    );
  }

  Future<void> _addContract(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(housingRepositoryProvider);
    
    final contractId = await repo.createRentalContract(
      propertyId: propertyId,
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RentalDetailScreen(
          propertyId: propertyId,
          contractId: contractId,
          isNew: true,
        ),
      ),
    ).then((_) => ref.invalidate(rentalContractsProvider(propertyId)));
  }
}






