// lib/modules/household/screens/household_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:life_legacy_manager/l10n/app_localizations.dart';
import '../../../core/app_database.dart';

class HouseholdScreen extends ConsumerStatefulWidget {
  final String dossierId;

  const HouseholdScreen({super.key, required this.dossierId});

  @override
  ConsumerState<HouseholdScreen> createState() => _HouseholdScreenState();
}

class _HouseholdScreenState extends ConsumerState<HouseholdScreen> {
  List<Map<String, dynamic>> _householdMembers = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHouseholdMembers();
  }

  Future<void> _loadHouseholdMembers() async {
    final db = await AppDatabase.instance.database;
    
    // Join household_members with persons to get full details
    final result = await db.rawQuery('''
      SELECT 
        hm.*,
        p.first_name,
        p.name_prefix,
        p.last_name,
        p.gender,
        p.birth_date,
        p.email,
        p.phone
      FROM household_members hm
      INNER JOIN persons p ON hm.person_id = p.id
      WHERE hm.dossier_id = ?
      ORDER BY hm.is_primary DESC, p.birth_date ASC
    ''', [widget.dossierId]);
    
    if (mounted) {
      setState(() {
        _householdMembers = result;
        _loading = false;
      });
    }
  }

  String _getFullName(Map<String, dynamic> member) {
    final firstName = member['first_name'] as String;
    final namePrefix = member['name_prefix'] as String?;
    final lastName = member['last_name'] as String;
    
    if (namePrefix != null && namePrefix.isNotEmpty) {
      return '$firstName $namePrefix $lastName';
    }
    return '$firstName $lastName';
  }

  String _getRelationIcon(String relation) {
    switch (relation) {
      case 'accounthouder':
        return '👤';
      case 'partner':
        return '💑';
      case 'kind':
        return '👶';
      case 'ouder':
        return '👨‍👩';
      case 'broer_zus':
        return '👫';
      default:
        return '👥';
    }
  }

  String _getRelationText(String relation) {
    switch (relation) {
      case 'accounthouder':
        return 'Accounthouder';
      case 'partner':
        return 'Partner';
      case 'kind':
        return 'Kind';
      case 'ouder':
        return 'Ouder';
      case 'broer_zus':
        return 'Broer/Zus';
      default:
        return 'Overig';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gezin'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _householdMembers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.family_restroom,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Nog geen gezinsleden',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Voeg gezinsleden toe om te beginnen',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadHouseholdMembers,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _householdMembers.length,
                    itemBuilder: (context, index) {
                      final member = _householdMembers[index];
                      final isPrimary = (member['is_primary'] as int) == 1;
                      final relation = member['relation'] as String;
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: isPrimary
                                ? theme.primaryColor
                                : Colors.blue[100],
                            child: Text(
                              _getRelationIcon(relation),
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _getFullName(member),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isPrimary)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'Primair',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                _getRelationText(relation),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (member['birth_date'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '🎂 ${member['birth_date']}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                              if (member['email'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '📧 ${member['email']}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                              if (member['phone'] != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '📱 ${member['phone']}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Navigate to person detail
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Details van ${_getFullName(member)}'),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Add household member
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gezinslid toevoegen - komt binnenkort!'),
            ),
          );
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Toevoegen'),
      ),
    );
  }
}
