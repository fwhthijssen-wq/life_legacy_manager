// lib/modules/contacts/screens/contacts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_database.dart';
import '../../person/person_model.dart';
import 'add_contact_screen.dart';
import 'edit_contact_screen.dart';

/// Volledigheids-status voor een contact
enum ContactCompleteness {
  complete,   // Email + Adres
  partial,    // Email OF Adres
  incomplete, // Geen van beide
}

/// Filter opties
enum ContactFilter {
  all('Alle contacten', Icons.people),
  complete('Compleet', Icons.check_circle),
  incomplete('Onvolledig', Icons.warning),
  hasEmail('Heeft email', Icons.email),
  hasAddress('Heeft adres', Icons.home);

  final String label;
  final IconData icon;
  const ContactFilter(this.label, this.icon);
}

/// Provider voor huidige filter
final contactFilterProvider = StateProvider<ContactFilter>((ref) => ContactFilter.all);

/// Sorteer opties
enum ContactSort {
  nameAsc('Naam A-Z', Icons.sort_by_alpha),
  nameDesc('Naam Z-A', Icons.sort_by_alpha),
  completeness('Volledigheid', Icons.check_circle_outline),
  category('Categorie', Icons.category);

  final String label;
  final IconData icon;
  const ContactSort(this.label, this.icon);
}

/// Provider voor huidige sortering
final contactSortProvider = StateProvider<ContactSort>((ref) => ContactSort.nameAsc);

/// Provider voor contacten (personen met is_contact = 1)
final contactsProvider = FutureProvider.family<List<PersonModel>, String>((ref, dossierId) async {
  final db = ref.read(appDatabaseProvider);
  final results = await db.query(
    'persons',
    where: 'dossier_id = ? AND is_contact = 1',
    whereArgs: [dossierId],
    orderBy: 'last_name, first_name',
  );
  return results.map((map) => PersonModel.fromMap(map)).toList();
});

class ContactsScreen extends ConsumerWidget {
  final String dossierId;

  const ContactsScreen({super.key, required this.dossierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider(dossierId));
    final currentFilter = ref.watch(contactFilterProvider);
    final currentSort = ref.watch(contactSortProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacten'),
        actions: [
          // Filter dropdown
          PopupMenuButton<ContactFilter>(
            icon: Badge(
              isLabelVisible: currentFilter != ContactFilter.all,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filter contacten',
            onSelected: (filter) {
              ref.read(contactFilterProvider.notifier).state = filter;
            },
            itemBuilder: (context) => ContactFilter.values.map((filter) => PopupMenuItem(
              value: filter,
              child: Row(
                children: [
                  Icon(
                    filter.icon,
                    size: 20,
                    color: currentFilter == filter ? theme.primaryColor : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    filter.label,
                    style: TextStyle(
                      fontWeight: currentFilter == filter ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (currentFilter == filter) ...[
                    const Spacer(),
                    Icon(Icons.check, size: 18, color: theme.primaryColor),
                  ],
                ],
              ),
            )).toList(),
          ),
          // Sortering dropdown
          PopupMenuButton<ContactSort>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sorteer contacten',
            onSelected: (sort) {
              ref.read(contactSortProvider.notifier).state = sort;
            },
            itemBuilder: (context) => ContactSort.values.map((sort) => PopupMenuItem(
              value: sort,
              child: Row(
                children: [
                  Icon(
                    sort.icon,
                    size: 20,
                    color: currentSort == sort ? theme.primaryColor : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    sort.label,
                    style: TextStyle(
                      fontWeight: currentSort == sort ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  if (currentSort == sort) ...[
                    const Spacer(),
                    Icon(Icons.check, size: 18, color: theme.primaryColor),
                  ],
                ],
              ),
            )).toList(),
          ),
        ],
      ),
      body: contactsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Fout: $err')),
        data: (contacts) {
          if (contacts.isEmpty) {
            return _buildEmptyState(context, ref, theme);
          }

          // Filter contacten
          final filteredContacts = _filterContacts(contacts, currentFilter);
          
          // Sorteer volgens gekozen optie
          _sortContacts(filteredContacts, currentSort);

          if (filteredContacts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_list_off, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Geen contacten gevonden',
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => ref.read(contactFilterProvider.notifier).state = ContactFilter.all,
                    icon: const Icon(Icons.clear),
                    label: const Text('Filter wissen'),
                  ),
                ],
              ),
            );
          }

          // Toon statistieken bovenaan
          final stats = _calculateStats(contacts);

          return Column(
            children: [
              // Statistieken balk
              _buildStatsBar(context, ref, stats, theme),
              
              // Contacten lijst
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return _ContactTile(
                      contact: contact,
                      onTap: () => _editContact(context, ref, contact),
                      onEdit: () => _editContact(context, ref, contact),
                      onDelete: () => _deleteContact(context, ref, contact),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addContact(context, ref),
        icon: const Icon(Icons.person_add),
        label: const Text('Contact'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.contacts_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Nog geen contacten',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Voeg contactpersonen toe voor\nuitnodigingen en nieuwsbrieven',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addContact(context, ref),
            icon: const Icon(Icons.person_add),
            label: const Text('Contact toevoegen'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(BuildContext context, WidgetRef ref, Map<String, int> stats, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context, ref,
            count: stats['complete']!,
            label: 'Compleet',
            color: Colors.green,
            filter: ContactFilter.complete,
          ),
          _buildStatItem(
            context, ref,
            count: stats['partial']!,
            label: 'Gedeeltelijk',
            color: Colors.orange,
            filter: ContactFilter.incomplete,
          ),
          _buildStatItem(
            context, ref,
            count: stats['incomplete']!,
            label: 'Onvolledig',
            color: Colors.red,
            filter: ContactFilter.incomplete,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    WidgetRef ref, {
    required int count,
    required String label,
    required Color color,
    required ContactFilter filter,
  }) {
    return InkWell(
      onTap: () => ref.read(contactFilterProvider.notifier).state = filter,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, int> _calculateStats(List<PersonModel> contacts) {
    int complete = 0;
    int partial = 0;
    int incomplete = 0;

    for (final contact in contacts) {
      switch (_getCompleteness(contact)) {
        case ContactCompleteness.complete:
          complete++;
          break;
        case ContactCompleteness.partial:
          partial++;
          break;
        case ContactCompleteness.incomplete:
          incomplete++;
          break;
      }
    }

    return {
      'complete': complete,
      'partial': partial,
      'incomplete': incomplete,
    };
  }

  List<PersonModel> _filterContacts(List<PersonModel> contacts, ContactFilter filter) {
    switch (filter) {
      case ContactFilter.all:
        return List.from(contacts);
      case ContactFilter.complete:
        return contacts.where((c) => _getCompleteness(c) == ContactCompleteness.complete).toList();
      case ContactFilter.incomplete:
        return contacts.where((c) => _getCompleteness(c) != ContactCompleteness.complete).toList();
      case ContactFilter.hasEmail:
        return contacts.where((c) => _hasEmail(c)).toList();
      case ContactFilter.hasAddress:
        return contacts.where((c) => _hasAddress(c)).toList();
    }
  }

  void _sortContacts(List<PersonModel> contacts, ContactSort sort) {
    switch (sort) {
      case ContactSort.nameAsc:
        contacts.sort((a, b) {
          final lastNameCompare = a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
          if (lastNameCompare != 0) return lastNameCompare;
          return a.firstName.toLowerCase().compareTo(b.firstName.toLowerCase());
        });
        break;
      case ContactSort.nameDesc:
        contacts.sort((a, b) {
          final lastNameCompare = b.lastName.toLowerCase().compareTo(a.lastName.toLowerCase());
          if (lastNameCompare != 0) return lastNameCompare;
          return b.firstName.toLowerCase().compareTo(a.firstName.toLowerCase());
        });
        break;
      case ContactSort.completeness:
        contacts.sort((a, b) {
          final aComplete = _getCompleteness(a).index;
          final bComplete = _getCompleteness(b).index;
          if (aComplete != bComplete) {
            return bComplete.compareTo(aComplete); // Onvolledig eerst
          }
          return a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
        });
        break;
      case ContactSort.category:
        contacts.sort((a, b) {
          final aCat = a.contactCategory?.index ?? 99;
          final bCat = b.contactCategory?.index ?? 99;
          if (aCat != bCat) return aCat.compareTo(bCat);
          return a.lastName.toLowerCase().compareTo(b.lastName.toLowerCase());
        });
        break;
    }
  }

  void _addContact(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddContactScreen(dossierId: dossierId),
      ),
    );
    
    if (result == true) {
      ref.invalidate(contactsProvider(dossierId));
    }
  }

  void _editContact(BuildContext context, WidgetRef ref, PersonModel contact) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditContactScreen(contactId: contact.id),
      ),
    );
    
    if (changed == true) {
      ref.invalidate(contactsProvider(dossierId));
    }
  }

  void _deleteContact(BuildContext context, WidgetRef ref, PersonModel contact) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Contact verwijderen'),
          content: Text(
            'Weet je zeker dat je ${contact.fullName} wilt verwijderen?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuleren'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Verwijderen'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final db = ref.read(appDatabaseProvider);
      await db.delete('persons', where: 'id = ?', whereArgs: [contact.id]);
      ref.invalidate(contactsProvider(dossierId));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${contact.fullName} verwijderd'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

// ===== HELPER FUNCTIONS =====

ContactCompleteness _getCompleteness(PersonModel contact) {
  final hasEmail = _hasEmail(contact);
  final hasAddress = _hasAddress(contact);
  
  if (hasEmail && hasAddress) {
    return ContactCompleteness.complete;
  } else if (hasEmail || hasAddress) {
    return ContactCompleteness.partial;
  } else {
    return ContactCompleteness.incomplete;
  }
}

bool _hasEmail(PersonModel contact) {
  return contact.email != null && contact.email!.isNotEmpty;
}

bool _hasAddress(PersonModel contact) {
  // Check of er voldoende adresgegevens zijn voor een label
  final hasStreet = contact.address != null && contact.address!.isNotEmpty;
  final hasCity = contact.city != null && contact.city!.isNotEmpty;
  return hasStreet && hasCity;
}

Color _getCompletenessColor(ContactCompleteness completeness) {
  switch (completeness) {
    case ContactCompleteness.complete:
      return Colors.green;
    case ContactCompleteness.partial:
      return Colors.orange;
    case ContactCompleteness.incomplete:
      return Colors.red;
  }
}

// ===== CONTACT TILE WIDGET =====

class _ContactTile extends StatelessWidget {
  final PersonModel contact;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ContactTile({
    required this.contact,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  /// Bereken percentage ingevulde velden voor contact
  int _calculateCompleteness(PersonModel contact) {
    int filled = 0;
    const int total = 10; // Totaal aantal relevante velden
    
    // Verplichte velden (altijd gevuld)
    filled += 2; // firstName, lastName
    
    // Optionele velden
    if (contact.email != null && contact.email!.isNotEmpty) filled++;
    if (contact.phone != null && contact.phone!.isNotEmpty) filled++;
    if (contact.address != null && contact.address!.isNotEmpty) filled++;
    if (contact.city != null && contact.city!.isNotEmpty) filled++;
    if (contact.postalCode != null && contact.postalCode!.isNotEmpty) filled++;
    if (contact.contactCategory != null) filled++;
    
    // Mailing opties (telt als 1 als er minstens 1 is geselecteerd)
    if (contact.forChristmasCard || contact.forNewsletter || 
        contact.forParty || contact.forFuneral) filled++;
    
    // Notes
    if (contact.notes != null && contact.notes!.isNotEmpty) filled++;
    
    return ((filled / total) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completeness = _getCompleteness(contact);
    final completenessColor = _getCompletenessColor(completeness);
    final hasEmail = _hasEmail(contact);
    final hasAddress = _hasAddress(contact);
    final percentage = _calculateCompleteness(contact);
    
    // Badges voor mailing opties (volgorde: kerst, nieuwsbrief, feesten, rouw)
    final mailingBadges = <Widget>[];
    if (contact.forChristmasCard) {
      mailingBadges.add(_buildMailingBadge('🎄', 'Kerstkaarten'));
    }
    if (contact.forNewsletter) {
      mailingBadges.add(_buildMailingBadge('📧', 'Nieuwsbrief'));
    }
    if (contact.forParty) {
      mailingBadges.add(_buildMailingBadge('🎉', 'Feesten'));
    }
    if (contact.forFuneral) {
      mailingBadges.add(_buildMailingBadge('🕯️', 'Rouwkaarten'));
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar met volledigheidskleur
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: completenessColor.withOpacity(0.15),
                        child: Text(
                          contact.firstName.isNotEmpty ? contact.firstName[0].toUpperCase() : '?',
                          style: TextStyle(
                            fontSize: 20,
                            color: completenessColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Status indicator (kleine cirkel rechtsonder)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: completenessColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: completeness == ContactCompleteness.complete
                              ? const Icon(Icons.check, size: 8, color: Colors.white)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  
                  // Naam en contact info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                contact.fullName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Email/Adres indicatoren
                            if (hasEmail)
                              Tooltip(
                                message: contact.email!,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.email, size: 14, color: Colors.blue),
                                ),
                              ),
                            if (hasAddress)
                              Tooltip(
                                message: '${contact.address}, ${contact.city}',
                                child: Container(
                                  margin: const EdgeInsets.only(left: 4),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.home, size: 14, color: Colors.green),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Toon wat er ontbreekt
                        if (completeness != ContactCompleteness.complete)
                          Text(
                            _getMissingText(hasEmail, hasAddress),
                            style: TextStyle(
                              fontSize: 12,
                              color: completenessColor,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else if (contact.phone != null || contact.email != null)
                          Text(
                            contact.phone ?? contact.email ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                  
                  // Edit en Delete knoppen
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: onEdit,
                    tooltip: 'Bewerken',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                    onPressed: onDelete,
                    tooltip: 'Verwijderen',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              
              // Mailing badges
              if (mailingBadges.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: mailingBadges,
                ),
              ],
              
              // Percentage balk
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: Colors.grey[200],
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage >= 80 ? Colors.green : 
                        percentage >= 50 ? Colors.orange : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$percentage%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: percentage >= 80 ? Colors.green : 
                             percentage >= 50 ? Colors.orange : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMissingText(bool hasEmail, bool hasAddress) {
    if (!hasEmail && !hasAddress) {
      return 'Email en adres ontbreken';
    } else if (!hasEmail) {
      return 'Email ontbreekt';
    } else {
      return 'Adres ontbreekt';
    }
  }

  Widget _buildMailingBadge(String emoji, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
