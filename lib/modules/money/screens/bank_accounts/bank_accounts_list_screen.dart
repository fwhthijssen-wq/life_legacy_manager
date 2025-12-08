// lib/modules/money/screens/bank_accounts/bank_accounts_list_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_database.dart';
import '../../../../core/bulk_import/screens/bulk_import_accounts_screen.dart';
import '../../../person/person_model.dart';
import '../../models/bank_account_model.dart';
import '../../providers/money_providers.dart';
import 'bank_account_detail_screen.dart';

class BankAccountsListScreen extends ConsumerWidget {
  final String dossierId;

  const BankAccountsListScreen({super.key, required this.dossierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountsAsync = ref.watch(bankAccountsProvider(dossierId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bankrekeningen'),
        actions: [
          // Bulk import knop
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: 'Rekeningen importeren uit PDF',
            onPressed: () => _openBulkImport(context, ref),
          ),
          // Toggle voor maskeren bedragen
          IconButton(
            icon: const Icon(Icons.visibility_outlined),
            tooltip: 'Bedragen tonen/verbergen',
            onPressed: () {
              // TODO: Toggle privacy mode
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Privacy mode - binnenkort beschikbaar')),
              );
            },
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Fout: $err')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return _buildEmptyState(context, ref, theme);
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(bankAccountsProvider(dossierId));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: accounts.length,
              itemBuilder: (context, index) {
                final account = accounts[index];
                return _BankAccountCard(
                  account: account,
                  onTap: () => _openAccount(context, account),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addAccount(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Rekening'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Nog geen bankrekeningen',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Voeg je eerste bankrekening toe',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          
          // Bulk import button (prominent)
          FilledButton.icon(
            onPressed: () => _openBulkImport(context, ref),
            icon: const Icon(Icons.upload_file),
            label: const Text('Importeer uit jaaroverzicht'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Alle rekeningen in één keer',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 24),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('of', style: TextStyle(color: Colors.grey)),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 24),
          
          OutlinedButton.icon(
            onPressed: () => _addAccount(context, ref),
            icon: const Icon(Icons.add),
            label: const Text('Handmatig toevoegen'),
          ),
        ],
      ),
    );
  }

  void _openBulkImport(BuildContext context, WidgetRef ref) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BulkImportAccountsScreen(dossierId: dossierId),
      ),
    ).then((result) {
      if (result == true) {
        ref.invalidate(bankAccountsProvider(dossierId));
      }
    });
  }

  void _openAccount(BuildContext context, BankAccountModel account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BankAccountDetailScreen(
          dossierId: dossierId,
          moneyItemId: account.moneyItemId,
        ),
      ),
    );
  }

  Future<void> _addAccount(BuildContext context, WidgetRef ref) async {
    // Haal alleen dossierleden (household members) op voor dit dossier
    final db = ref.read(appDatabaseProvider);
    final persons = await db.rawQuery('''
      SELECT p.* FROM persons p
      INNER JOIN household_members hm ON p.id = hm.person_id
      WHERE hm.dossier_id = ?
      ORDER BY hm.is_primary DESC, p.first_name
    ''', [dossierId]);

    if (persons.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voeg eerst een persoon toe aan dit dossier'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Selecteer persoon
    PersonModel selectedPerson;
    if (persons.length == 1) {
      selectedPerson = PersonModel.fromMap(persons.first);
    } else {
      if (!context.mounted) return;
      final person = await showDialog<PersonModel>(
        context: context,
        builder: (context) => _SelectPersonDialog(
          persons: persons.map((p) => PersonModel.fromMap(p)).toList(),
        ),
      );
      if (person == null) return;
      selectedPerson = person;
    }

    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BankAccountDetailScreen(
          dossierId: dossierId,
          moneyItemId: null,
          personId: selectedPerson.id,
          personName: selectedPerson.fullName,
        ),
      ),
    ).then((_) {
      ref.invalidate(bankAccountsProvider(dossierId));
    });
  }
}

class _SelectPersonDialog extends StatelessWidget {
  final List<PersonModel> persons;

  const _SelectPersonDialog({required this.persons});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selecteer persoon'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: persons.length,
          itemBuilder: (context, index) {
            final person = persons[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Text(
                  '${person.firstName[0]}${person.lastName[0]}'.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(person.fullName),
              subtitle: person.relation != null ? Text(person.relation!) : null,
              onTap: () => Navigator.pop(context, person),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
      ],
    );
  }
}

class _BankAccountCard extends StatelessWidget {
  final BankAccountModel account;
  final VoidCallback onTap;

  const _BankAccountCard({
    required this.account,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Bank logo placeholder
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getBankColor(account.bankName).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _getBankInitials(account.bankName),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _getBankColor(account.bankName),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.bankName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            account.accountType.label,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          account.maskedIban,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    if (account.balance != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '€ ${account.balance!.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: account.balance! >= 0 ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Status & chevron
              Column(
                children: [
                  if (account.isJointAccount)
                    Tooltip(
                      message: 'Gezamenlijke rekening',
                      child: Icon(Icons.people, size: 18, color: Colors.grey[400]),
                    ),
                  const SizedBox(height: 8),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getBankColor(String bankName) {
    final name = bankName.toLowerCase();
    if (name.contains('ing')) return Colors.orange;
    if (name.contains('rabo')) return Colors.blue[800]!;
    if (name.contains('abn')) return Colors.green[700]!;
    if (name.contains('sns')) return Colors.red;
    if (name.contains('triodos')) return Colors.teal;
    if (name.contains('asn')) return Colors.green;
    if (name.contains('bunq')) return Colors.purple;
    if (name.contains('knab')) return Colors.deepPurple;
    return Colors.blueGrey;
  }

  String _getBankInitials(String bankName) {
    final words = bankName.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return bankName.substring(0, 2).toUpperCase();
  }
}


