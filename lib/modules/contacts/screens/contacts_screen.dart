// lib/modules/contacts/screens/contacts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_database.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/dossier_app_bar.dart';
import '../../person/person_model.dart';
import '../models/email_template_model.dart';
import '../repository/email_template_repository.dart';
import '../services/contact_export_service.dart';
import '../services/duplicate_detection_service.dart';
import '../repository/mailing_list_repository.dart';
import '../models/mailing_list_model.dart';
import '../../../core/person_repository.dart';
import 'add_contact_screen.dart';
import 'edit_contact_screen.dart';
import 'email_templates_screen.dart';
import 'import_contacts_screen.dart';

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

/// Hoofdscherm voor Contacten met TabBar
class ContactsScreen extends ConsumerStatefulWidget {
  final String dossierId;

  const ContactsScreen({super.key, required this.dossierId});

  @override
  ConsumerState<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends ConsumerState<ContactsScreen> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentFilter = ref.watch(contactFilterProvider);
    final currentSort = ref.watch(contactSortProvider);

    return Scaffold(
      appBar: const DossierAppBar(
        title: 'Contacten',
      ),
      body: Column(
        children: [
          // Tab buttons als mooie knoppen
          Container(
            padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _TabButton(
                    icon: Icons.people,
                    label: 'Lijst',
                    isSelected: _selectedTabIndex == 0,
                    onTap: () => setState(() => _selectedTabIndex = 0),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _TabButton(
                    icon: Icons.mail,
                    label: 'Communicatie',
                    isSelected: _selectedTabIndex == 1,
                    onTap: () => setState(() => _selectedTabIndex = 1),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _TabButton(
                    icon: Icons.folder_special,
                    label: 'Lijsten',
                    isSelected: _selectedTabIndex == 2,
                    onTap: () => setState(() => _selectedTabIndex = 2),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _TabButton(
                    icon: Icons.settings,
                    label: 'Beheer',
                    isSelected: _selectedTabIndex == 3,
                    onTap: () => setState(() => _selectedTabIndex = 3),
                  ),
                ],
              ),
            ),
          ),
          
          // Filter en sorteer icoontjes - alleen zichtbaar op Contacten tab
          if (_selectedTabIndex == 0)
            Container(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
              child: Row(
                children: [
                  // Filter button
                  _IconFilterButton(
                    icon: Icons.filter_list,
                    label: currentFilter == ContactFilter.all ? 'Filter' : currentFilter.label,
                    isActive: currentFilter != ContactFilter.all,
                    onTap: () => _showFilterMenu(context, theme, currentFilter),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Sorteer button
                  _IconFilterButton(
                    icon: Icons.sort,
                    label: currentSort.label,
                    isActive: false,
                    onTap: () => _showSortMenu(context, theme, currentSort),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          
          // Content per tab
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                _ContactsListTab(dossierId: widget.dossierId),
                _CommunicatieTab(dossierId: widget.dossierId),
                _LijstenTab(dossierId: widget.dossierId),
                _BeheerTab(dossierId: widget.dossierId),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => _addContact(context),
              icon: const Icon(Icons.person_add),
              label: const Text('Contact'),
            )
          : null,
    );
  }

  void _showFilterMenu(BuildContext context, ThemeData theme, ContactFilter currentFilter) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(const Offset(16, 120), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<ContactFilter>(
      context: context,
      position: position,
      items: ContactFilter.values.map((filter) => PopupMenuItem(
        value: filter,
        child: Row(
          children: [
            Icon(filter.icon, size: 20, color: currentFilter == filter ? theme.primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Text(filter.label, style: TextStyle(fontWeight: currentFilter == filter ? FontWeight.bold : FontWeight.normal)),
            if (currentFilter == filter) ...[
              const Spacer(),
              Icon(Icons.check, size: 18, color: theme.primaryColor),
            ],
          ],
        ),
      )).toList(),
    ).then((filter) {
      if (filter != null) {
        ref.read(contactFilterProvider.notifier).state = filter;
      }
    });
  }

  void _showSortMenu(BuildContext context, ThemeData theme, ContactSort currentSort) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(const Offset(100, 120), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<ContactSort>(
      context: context,
      position: position,
      items: ContactSort.values.map((sort) => PopupMenuItem(
        value: sort,
        child: Row(
          children: [
            Icon(sort.icon, size: 20, color: currentSort == sort ? theme.primaryColor : Colors.grey),
            const SizedBox(width: 12),
            Text(sort.label, style: TextStyle(fontWeight: currentSort == sort ? FontWeight.bold : FontWeight.normal)),
            if (currentSort == sort) ...[
              const Spacer(),
              Icon(Icons.check, size: 18, color: theme.primaryColor),
            ],
          ],
        ),
      )).toList(),
    ).then((sort) {
      if (sort != null) {
        ref.read(contactSortProvider.notifier).state = sort;
      }
    });
  }

  void _addContact(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddContactScreen(dossierId: widget.dossierId),
      ),
    );
    
    if (result == true) {
      ref.invalidate(contactsProvider(widget.dossierId));
    }
  }
}

// ===== TAB 1: CONTACTEN LIJST =====

class _ContactsListTab extends ConsumerWidget {
  final String dossierId;

  const _ContactsListTab({required this.dossierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider(dossierId));
    final currentFilter = ref.watch(contactFilterProvider);
    final currentSort = ref.watch(contactSortProvider);
    final theme = Theme.of(context);

    return contactsAsync.when(
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
                    onTap: () => _editContact(context, ref, contact, dossierId),
                    onEdit: () => _editContact(context, ref, contact, dossierId),
                    onDelete: () => _deleteContact(context, ref, contact, dossierId),
                  );
                },
              ),
            ),
          ],
        );
      },
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
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => AddContactScreen(dossierId: dossierId),
                ),
              );
              if (result == true) {
                ref.invalidate(contactsProvider(dossierId));
              }
            },
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
          _buildStatItem(context, ref, count: stats['complete']!, label: 'Compleet', color: Colors.green, filter: ContactFilter.complete),
          _buildStatItem(context, ref, count: stats['partial']!, label: 'Gedeeltelijk', color: Colors.orange, filter: ContactFilter.incomplete),
          _buildStatItem(context, ref, count: stats['incomplete']!, label: 'Onvolledig', color: Colors.red, filter: ContactFilter.incomplete),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, WidgetRef ref, {required int count, required String label, required Color color, required ContactFilter filter}) {
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
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
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

    return {'complete': complete, 'partial': partial, 'incomplete': incomplete};
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
            return bComplete.compareTo(aComplete);
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

  void _editContact(BuildContext context, WidgetRef ref, PersonModel contact, String dossierId) async {
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

  void _deleteContact(BuildContext context, WidgetRef ref, PersonModel contact, String dossierId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Contact verwijderen'),
          content: Text('Weet je zeker dat je ${contact.fullName} wilt verwijderen?'),
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
          SnackBar(content: Text('${contact.fullName} verwijderd'), backgroundColor: Colors.orange),
        );
      }
    }
  }
}

// ===== TAB 2: COMMUNICATIE =====

class _CommunicatieTab extends ConsumerWidget {
  final String dossierId;

  const _CommunicatieTab({required this.dossierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider(dossierId));
    final theme = Theme.of(context);

    return contactsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Fout: $err')),
      data: (contacts) {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Sectie header
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'Verstuur berichten naar je contacten',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
            
            // Email versturen
            _ActionCard(
              icon: Icons.email,
              iconColor: Colors.blue,
              title: 'Email versturen',
              subtitle: 'Stuur een email naar geselecteerde contacten',
              onTap: contacts.isEmpty 
                  ? null 
                  : () => _showAdvancedEmailDialog(context, ref, contacts),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Brieven maken
            _ActionCard(
              icon: Icons.mail,
              iconColor: Colors.indigo,
              title: 'Brieven maken',
              subtitle: 'Genereer gepersonaliseerde brieven als PDF',
              onTap: contacts.isEmpty
                  ? null
                  : () => _showPostalLettersDialog(context, ref, contacts),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Adresetiketten
            _ActionCard(
              icon: Icons.label,
              iconColor: Colors.teal,
              title: 'Adresetiketten',
              subtitle: 'Print adresetiketten voor enveloppen',
              onTap: contacts.isEmpty
                  ? null
                  : () => _showAddressLabelsDialog(context, ref, contacts),
            ),
            
            const SizedBox(height: AppSpacing.sm),
            
            // Adreslijst
            _ActionCard(
              icon: Icons.list_alt,
              iconColor: Colors.green,
              title: 'Adreslijst',
              subtitle: 'Genereer een overzicht van alle adressen',
              onTap: contacts.isEmpty
                  ? null
                  : () => _showAddressListDialog(context, ref, contacts),
            ),
            
            // Lege staat
            if (contacts.isEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Column(
                  children: [
                    Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Voeg eerst contacten toe',
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  void _showAdvancedEmailDialog(BuildContext context, WidgetRef ref, List<PersonModel> contacts) {
    showDialog(
      context: context,
      builder: (context) => _AdvancedEmailDialog(contacts: contacts, dossierId: dossierId),
    );
  }

  void _showPostalLettersDialog(BuildContext context, WidgetRef ref, List<PersonModel> contacts) {
    showDialog(
      context: context,
      builder: (context) => _PostalLettersDialog(contacts: contacts, dossierId: dossierId),
    );
  }

  void _showAddressLabelsDialog(BuildContext context, WidgetRef ref, List<PersonModel> contacts) {
    showDialog(
      context: context,
      builder: (context) => _AddressLabelsDialog(contacts: contacts, dossierId: dossierId),
    );
  }

  void _showAddressListDialog(BuildContext context, WidgetRef ref, List<PersonModel> contacts) {
    showDialog(
      context: context,
      builder: (context) => _AddressListDialog(contacts: contacts, dossierId: dossierId),
    );
  }
}

// ===== TAB 3: LIJSTEN =====

class _LijstenTab extends ConsumerWidget {
  final String dossierId;

  const _LijstenTab({required this.dossierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final listsAsync = ref.watch(mailingListsProvider(dossierId));

    return listsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Fout: $err')),
      data: (lists) {
        return ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                'Mijn Lijsten',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Text(
                'Selecteer een lijst om acties uit te voeren',
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
            
            // Opgeslagen lijsten
            if (lists.isEmpty)
              _EmptyListsPlaceholder()
            else
              ...lists.map((list) => _MailingListCard(
                list: list,
                dossierId: dossierId,
                onTap: () => _showListActions(context, ref, list),
              )),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Nieuwe lijst aanmaken
            _ActionCard(
              icon: Icons.add_circle_outline,
              iconColor: AppColors.primary,
              title: 'Nieuwe lijst aanmaken',
              subtitle: 'Maak een selectie van contacten',
              onTap: () => _createNewList(context, ref),
            ),
          ],
        );
      },
    );
  }

  void _showListActions(BuildContext context, WidgetRef ref, MailingListModel list) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _ListActionsSheet(
        list: list,
        dossierId: dossierId,
        onActionComplete: () {
          ref.invalidate(mailingListsProvider(dossierId));
        },
      ),
    );
  }

  void _createNewList(BuildContext context, WidgetRef ref) async {
    // Navigeer naar contacten selectie voor nieuwe lijst
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _CreateMailingListScreen(dossierId: dossierId),
      ),
    );
    if (result == true) {
      ref.invalidate(mailingListsProvider(dossierId));
    }
  }
}

/// Kaart voor een mailing lijst
class _MailingListCard extends StatelessWidget {
  final MailingListModel list;
  final String dossierId;
  final VoidCallback onTap;

  const _MailingListCard({
    required this.list,
    required this.dossierId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(list.emoji, style: const TextStyle(fontSize: 22)),
        ),
        title: Text(
          list.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${list.contactCount} contacten',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

/// Lege staat wanneer er geen lijsten zijn
class _EmptyListsPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.folder_open, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Geen lijsten',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Maak een nieuwe lijst aan om\ncontacten te groeperen',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet met acties voor een lijst
class _ListActionsSheet extends ConsumerWidget {
  final MailingListModel list;
  final String dossierId;
  final VoidCallback onActionComplete;

  const _ListActionsSheet({
    required this.list,
    required this.dossierId,
    required this.onActionComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(list.emoji, style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        list.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${list.contactCount} contacten',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            Text(
            'Wat wil je doen?',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 16),
          
          // Acties
          _ActionTile(
            icon: Icons.email,
            iconColor: Colors.blue,
            title: 'Email versturen',
            subtitle: 'Stuur een email naar alle contacten',
            onTap: () => _sendEmail(context, ref),
          ),
          _ActionTile(
            icon: Icons.description,
            iconColor: Colors.orange,
            title: 'Brieven maken',
            subtitle: 'Genereer brieven voor alle contacten',
            onTap: () => _createLetters(context, ref),
          ),
          _ActionTile(
            icon: Icons.label,
            iconColor: Colors.purple,
            title: 'Etiketten maken',
            subtitle: 'Print adresetiketten',
            onTap: () => _createLabels(context, ref),
          ),
          _ActionTile(
            icon: Icons.list_alt,
            iconColor: Colors.indigo,
            title: 'Adressenlijst',
            subtitle: 'Genereer een overzicht van adressen',
            onTap: () => _createAddressList(context, ref),
          ),
          
          const Divider(height: 32),
          
          _ActionTile(
            icon: Icons.edit,
            iconColor: Colors.grey[700]!,
            title: 'Lijst bewerken',
            subtitle: 'Contacten toevoegen of verwijderen',
            onTap: () => _editList(context, ref),
          ),
          _ActionTile(
            icon: Icons.delete,
            iconColor: Colors.red,
            title: 'Lijst verwijderen',
            subtitle: 'Verwijder deze lijst permanent',
            onTap: () => _deleteList(context, ref),
          ),
          
          const SizedBox(height: 8),
        ],
        ),
      ),
    );
  }

  void _sendEmail(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    // Laad contacten van de lijst en open email dialog
    final contacts = await _loadListContacts(ref);
    if (contacts.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geen contacten in deze lijst')),
        );
      }
      return;
    }
    
    // Filter contacten met email
    final contactsWithEmail = contacts.where((c) => c.email != null && c.email!.isNotEmpty).toList();
    if (contactsWithEmail.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geen contacten met emailadres in deze lijst')),
        );
      }
      return;
    }
    
    // Haal ALLE contacten op voor de "toevoegen" functie
    final allContacts = await ref.read(contactsProvider(dossierId).future);
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => _AdvancedEmailDialog(
          contacts: contactsWithEmail,
          dossierId: dossierId,
          initialStep: 1, // Direct naar preview (stap 2)
          preSelectedContacts: contactsWithEmail, // Contacten zijn al geselecteerd
          allContacts: allContacts, // Alle contacten voor toevoegen
        ),
      );
    }
  }

  void _createLetters(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    final contacts = await _loadListContacts(ref);
    if (contacts.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geen contacten in deze lijst')),
        );
      }
      return;
    }
    
    // Filter contacten met adres
    final contactsWithAddress = contacts.where((c) => 
      c.address != null && c.address!.isNotEmpty &&
      c.city != null && c.city!.isNotEmpty
    ).toList();
    
    if (contactsWithAddress.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geen contacten met volledig adres in deze lijst')),
        );
      }
      return;
    }
    
    // Haal ALLE contacten op voor de "toevoegen" functie
    final allContacts = await ref.read(contactsProvider(dossierId).future);
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => _PostalLettersDialog(
          contacts: contactsWithAddress,
          dossierId: dossierId,
          initialStep: 1, // Direct naar preview
          preSelectedContacts: contactsWithAddress,
          allContacts: allContacts,
        ),
      );
    }
  }

  void _createLabels(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    final contacts = await _loadListContacts(ref);
    if (contacts.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geen contacten in deze lijst')),
        );
      }
      return;
    }
    
    // Filter contacten met adres
    final contactsWithAddress = contacts.where((c) => 
      c.address != null && c.address!.isNotEmpty &&
      c.city != null && c.city!.isNotEmpty
    ).toList();
    
    if (contactsWithAddress.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geen contacten met volledig adres in deze lijst')),
        );
      }
      return;
    }
    
    // Haal ALLE contacten op voor de "toevoegen" functie
    final allContacts = await ref.read(contactsProvider(dossierId).future);
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => _AddressLabelsDialog(
          contacts: contactsWithAddress,
          dossierId: dossierId,
          initialStep: 1, // Direct naar preview
          preSelectedContacts: contactsWithAddress,
          allContacts: allContacts,
        ),
      );
    }
  }

  void _createAddressList(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    final contacts = await _loadListContacts(ref);
    if (contacts.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geen contacten in deze lijst')),
        );
      }
      return;
    }
    
    // Filter contacten met adres
    final contactsWithAddress = contacts.where((c) => 
      c.address != null && c.address!.isNotEmpty &&
      c.city != null && c.city!.isNotEmpty
    ).toList();
    
    if (contactsWithAddress.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Geen contacten met volledig adres in deze lijst')),
        );
      }
      return;
    }
    
    // Haal ALLE contacten op voor de "toevoegen" functie
    final allContacts = await ref.read(contactsProvider(dossierId).future);
    
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => _AddressListDialog(
          contacts: contactsWithAddress,
          dossierId: dossierId,
          initialStep: 1, // Direct naar preview
          preSelectedContacts: contactsWithAddress,
          allContacts: allContacts,
        ),
      );
    }
  }

  void _editList(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _EditMailingListScreen(
          dossierId: dossierId,
          list: list,
        ),
      ),
    );
    if (result == true) {
      onActionComplete();
    }
  }

  void _deleteList(BuildContext context, WidgetRef ref) async {
    Navigator.pop(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lijst verwijderen?'),
        content: Text('Weet je zeker dat je "${list.name}" wilt verwijderen?\n\nDe contacten zelf worden niet verwijderd.'),
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
      ),
    );
    
    if (confirmed == true) {
      final repository = ref.read(mailingListRepositoryProvider);
      await repository.deleteList(list.id);
      onActionComplete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lijst "${list.name}" verwijderd')),
        );
      }
    }
  }

  Future<List<PersonModel>> _loadListContacts(WidgetRef ref) async {
    final repository = ref.read(mailingListRepositoryProvider);
    final contactIds = await repository.getListContacts(list.id);
    
    if (contactIds.isEmpty) return [];
    
    final allContacts = await ref.read(contactsProvider(dossierId).future);
    return allContacts.where((c) => contactIds.contains(c.id)).toList();
  }
}

/// Actie tile in de bottom sheet
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: iconColor.withOpacity(0.1),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: onTap,
    );
  }
}

/// Scherm voor nieuwe lijst aanmaken
class _CreateMailingListScreen extends ConsumerStatefulWidget {
  final String dossierId;

  const _CreateMailingListScreen({required this.dossierId});

  @override
  ConsumerState<_CreateMailingListScreen> createState() => _CreateMailingListScreenState();
}

class _CreateMailingListScreenState extends ConsumerState<_CreateMailingListScreen> {
  final _nameController = TextEditingController();
  final Set<String> _selectedContactIds = {};
  String _selectedEmoji = '📋';

  final List<String> _emojiOptions = ['📋', '📧', '🎄', '🎉', '👨‍👩‍👧', '💼', '🏠', '❤️', '⭐', '📝'];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider(widget.dossierId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nieuwe lijst'),
        actions: [
          TextButton(
            onPressed: _selectedContactIds.isNotEmpty && _nameController.text.isNotEmpty
                ? _saveList
                : null,
            child: const Text('Opslaan'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Naam en emoji
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Row(
              children: [
                // Emoji selector
                PopupMenuButton<String>(
                  onSelected: (emoji) => setState(() => _selectedEmoji = emoji),
                  itemBuilder: (context) => _emojiOptions.map((emoji) => PopupMenuItem(
                    value: emoji,
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  )).toList(),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(_selectedEmoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Naam van de lijst',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
          ),
          
          // Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  'Selecteer contacten',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_selectedContactIds.length} geselecteerd',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          
          // Contacten lijst
          Expanded(
            child: contactsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Fout: $err')),
              data: (contacts) {
                if (contacts.isEmpty) {
                  return const Center(child: Text('Geen contacten beschikbaar'));
                }
                
                return ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    final isSelected = _selectedContactIds.contains(contact.id);
                    
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedContactIds.add(contact.id);
                          } else {
                            _selectedContactIds.remove(contact.id);
                          }
                        });
                      },
                      title: Text(contact.fullName),
                      subtitle: Text(contact.email ?? contact.phone ?? 'Geen contactgegevens'),
                      secondary: CircleAvatar(
                        backgroundColor: isSelected ? AppColors.primary : Colors.grey[200],
                        child: Text(
                          contact.firstName.isNotEmpty ? contact.firstName[0].toUpperCase() : '?',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[600],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _saveList() async {
    if (_nameController.text.isEmpty || _selectedContactIds.isEmpty) return;

    final repository = ref.read(mailingListRepositoryProvider);
    await repository.createList(
      dossierId: widget.dossierId,
      name: _nameController.text,
      emoji: _selectedEmoji,
      contactIds: _selectedContactIds.toList(),
    );

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lijst "${_nameController.text}" aangemaakt')),
      );
    }
  }
}

/// Scherm voor lijst bewerken
class _EditMailingListScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final MailingListModel list;

  const _EditMailingListScreen({
    required this.dossierId,
    required this.list,
  });

  @override
  ConsumerState<_EditMailingListScreen> createState() => _EditMailingListScreenState();
}

class _EditMailingListScreenState extends ConsumerState<_EditMailingListScreen> {
  late TextEditingController _nameController;
  late String _selectedEmoji;
  Set<String> _selectedContactIds = {};
  bool _loading = true;

  final List<String> _emojiOptions = ['📋', '📧', '🎄', '🎉', '👨‍👩‍👧', '💼', '🏠', '❤️', '⭐', '📝'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.list.name);
    _selectedEmoji = widget.list.emoji;
    _loadCurrentContacts();
  }

  void _loadCurrentContacts() async {
    final repository = ref.read(mailingListRepositoryProvider);
    final contactIds = await repository.getListContacts(widget.list.id);
    setState(() {
      _selectedContactIds = contactIds.toSet();
      _loading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider(widget.dossierId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lijst bewerken'),
        actions: [
          TextButton(
            onPressed: _selectedContactIds.isNotEmpty && _nameController.text.isNotEmpty
                ? _saveChanges
                : null,
            child: const Text('Opslaan'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Naam en emoji
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: Row(
                    children: [
                      PopupMenuButton<String>(
                        onSelected: (emoji) => setState(() => _selectedEmoji = emoji),
                        itemBuilder: (context) => _emojiOptions.map((emoji) => PopupMenuItem(
                          value: emoji,
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        )).toList(),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(_selectedEmoji, style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            hintText: 'Naam van de lijst',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Contacten in lijst',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${_selectedContactIds.length} geselecteerd',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: contactsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(child: Text('Fout: $err')),
                    data: (contacts) {
                      if (contacts.isEmpty) {
                        return const Center(child: Text('Geen contacten beschikbaar'));
                      }
                      
                      return ListView.builder(
                        itemCount: contacts.length,
                        itemBuilder: (context, index) {
                          final contact = contacts[index];
                          final isSelected = _selectedContactIds.contains(contact.id);
                          
                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedContactIds.add(contact.id);
                                } else {
                                  _selectedContactIds.remove(contact.id);
                                }
                              });
                            },
                            title: Text(contact.fullName),
                            subtitle: Text(contact.email ?? contact.phone ?? 'Geen contactgegevens'),
                            secondary: CircleAvatar(
                              backgroundColor: isSelected ? AppColors.primary : Colors.grey[200],
                              child: Text(
                                contact.firstName.isNotEmpty ? contact.firstName[0].toUpperCase() : '?',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _saveChanges() async {
    if (_nameController.text.isEmpty || _selectedContactIds.isEmpty) return;

    final repository = ref.read(mailingListRepositoryProvider);
    await repository.updateList(
      listId: widget.list.id,
      name: _nameController.text,
      emoji: _selectedEmoji,
      contactIds: _selectedContactIds.toList(),
    );

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lijst bijgewerkt')),
      );
    }
  }
}


// ===== TAB 4: BEHEER =====

class _BeheerTab extends ConsumerWidget {
  final String dossierId;

  const _BeheerTab({required this.dossierId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Text(
            'Import, export en instellingen',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
        ),
        
        // Import contacten
        _ActionCard(
          icon: Icons.file_upload,
          iconColor: Colors.purple,
          title: 'Contacten importeren',
          subtitle: 'Importeer contacten vanuit CSV of vCard',
          onTap: () => _importContacts(context, ref),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Export CSV
        _ActionCard(
          icon: Icons.table_chart,
          iconColor: Colors.green,
          title: 'Exporteer CSV',
          subtitle: 'Download alle contacten als spreadsheet',
          onTap: () => _exportCsv(context, ref),
        ),
        
        const SizedBox(height: AppSpacing.sm),
        
        // Templates beheren
        _ActionCard(
          icon: Icons.description,
          iconColor: Colors.orange,
          title: 'Templates beheren',
          subtitle: 'Email en brief templates aanpassen',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EmailTemplatesScreen(dossierId: dossierId),
            ),
          ),
        ),
      ],
    );
  }

  void _importContacts(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ImportContactsScreen(dossierId: dossierId),
      ),
    );
    if (result == true) {
      ref.invalidate(contactsProvider(dossierId));
    }
  }

  void _exportCsv(BuildContext context, WidgetRef ref) async {
    final contactsAsync = ref.read(contactsProvider(dossierId));
    final contacts = contactsAsync.valueOrNull ?? [];
    
    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geen contacten om te exporteren')),
      );
      return;
    }
    
    await ContactExportService.exportToCsv(context, contacts);
  }
}

// ===== HULP WIDGETS =====

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onTap == null;

    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey[200] : iconColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isDisabled ? Colors.grey : iconColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDisabled ? Colors.grey : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDisabled ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isDisabled ? Colors.grey[300] : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}

class _QuickFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickFilterChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
    );
  }
}

/// Mooie tab button widget
class _TabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TabButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: isSelected ? theme.primaryColor : Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Filter/sorteer button met icoon
class _IconFilterButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _IconFilterButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: isActive ? theme.primaryColor.withOpacity(0.15) : Colors.grey[100],
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isActive ? theme.primaryColor : Colors.grey[600],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? theme.primaryColor : Colors.grey[700],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 16,
                color: isActive ? theme.primaryColor : Colors.grey[500],
              ),
            ],
          ),
        ),
      ),
    );
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

// ===== GEAVANCEERDE EMAIL DIALOOG =====

class _AdvancedEmailDialog extends StatefulWidget {
  final List<PersonModel> contacts;
  final String dossierId;
  final int initialStep; // Start bij deze stap (0 = filter, 1 = preview, 2 = inhoud)
  final List<PersonModel>? preSelectedContacts; // Voorgeselecteerde contacten (skip stap 0)
  final List<PersonModel>? allContacts; // Alle contacten voor toevoegen in preview

  const _AdvancedEmailDialog({
    required this.contacts,
    required this.dossierId,
    this.initialStep = 0,
    this.preSelectedContacts,
    this.allContacts,
  });

  @override
  State<_AdvancedEmailDialog> createState() => _AdvancedEmailDialogState();
}

class _AdvancedEmailDialogState extends State<_AdvancedEmailDialog> {
  // Stap beheer (0 = filter, 1 = preview, 2 = inhoud)
  late int _currentStep;
  
  // Categorie filters (mailing type filters verwijderd - nu alleen categorieën)
  final Set<ContactCategory> _selectedCategories = {};
  
  // Geselecteerde contacten (na filter en handmatige aanpassingen)
  List<PersonModel> _selectedContacts = [];
  
  // Email inhoud
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController(text: 'Beste allemaal,\n\n');
  
  // Templates
  List<EmailTemplateModel> _templates = [];
  EmailTemplateModel? _selectedTemplate;
  
  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    // Als er voorgeselecteerde contacten zijn, gebruik deze
    if (widget.preSelectedContacts != null && widget.preSelectedContacts!.isNotEmpty) {
      _selectedContacts = List.from(widget.preSelectedContacts!);
    }
    _loadTemplates();
  }
  
  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
  
  void _loadTemplates() {
    final templates = DefaultEmailTemplates.getDefaults(widget.dossierId);
    setState(() {
      _templates = templates;
    });
  }
  
  List<PersonModel> get _filteredContacts {
    var filtered = widget.contacts.where((c) => c.email != null && c.email!.isNotEmpty).toList();
    
    // Filter op categorieën (OR logic)
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((c) => c.hasAnyCategory(_selectedCategories)).toList();
    }
    
    return filtered;
  }
  
  // Contacten die nog toegevoegd kunnen worden (hebben email, niet geselecteerd)
  List<PersonModel> get _availableToAdd {
    final selectedIds = _selectedContacts.map((c) => c.id).toSet();
    // Gebruik allContacts als beschikbaar, anders widget.contacts
    final sourceContacts = widget.allContacts ?? widget.contacts;
    return sourceContacts
        .where((c) => c.email != null && c.email!.isNotEmpty && !selectedIds.contains(c.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 750),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.email, color: theme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Email Versturen',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _getStepTitle(),
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            
            // Stap indicator
            _buildStepIndicator(theme),
            
            // Content per stap
            Expanded(
              child: _buildStepContent(theme),
            ),
            
            // Footer met navigatie
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }
  
  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Stap 1: Selecteer ontvangers';
      case 1: return 'Stap 2: Controleer selectie';
      case 2: return 'Stap 3: Stel bericht op';
      default: return '';
    }
  }
  
  Widget _buildStepIndicator(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _buildStepDot(0, 'Filter', theme),
          Expanded(child: Container(height: 2, color: _currentStep > 0 ? theme.primaryColor : Colors.grey[300])),
          _buildStepDot(1, 'Preview', theme),
          Expanded(child: Container(height: 2, color: _currentStep > 1 ? theme.primaryColor : Colors.grey[300])),
          _buildStepDot(2, 'Bericht', theme),
        ],
      ),
    );
  }
  
  Widget _buildStepDot(int step, String label, ThemeData theme) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;
    
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? theme.primaryColor : Colors.grey[300],
            border: isCurrent ? Border.all(color: theme.primaryColor, width: 3) : null,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? theme.primaryColor : Colors.grey[600],
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStepContent(ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildFilterStep(theme);
      case 1:
        return _buildPreviewStep(theme);
      case 2:
        return _buildContentStep(theme);
      default:
        return const SizedBox();
    }
  }
  
  // === STAP 1: FILTER ===
  Widget _buildFilterStep(ThemeData theme) {
    final filteredContacts = _filteredContacts;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Categorie filters
          Text('Selecteer categorieën:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Kies één of meer categorieën om te filteren', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ContactCategory.values.map((cat) {
              final isSelected = _selectedCategories.contains(cat);
              return FilterChip(
                avatar: Text(cat.emoji, style: const TextStyle(fontSize: 14)),
                label: Text(cat.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(cat);
                    } else {
                      _selectedCategories.remove(cat);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          const SizedBox(height: 24),
          
          // Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: filteredContacts.isEmpty ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: filteredContacts.isEmpty ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  filteredContacts.isEmpty ? Icons.warning : Icons.check_circle,
                  color: filteredContacts.isEmpty ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${filteredContacts.length} contacten gevonden',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: filteredContacts.isEmpty ? Colors.orange[800] : Colors.green[800],
                        ),
                      ),
                      if (filteredContacts.isEmpty)
                        Text(
                          'Pas de filters aan of selecteer handmatig',
                          style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (_selectedCategories.isEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Geen categorie geselecteerd = alle contacten met email',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.blue[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  // === STAP 2: PREVIEW ===
  Widget _buildPreviewStep(ThemeData theme) {
    return Column(
      children: [
        // Acties balk
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Text(
                '${_selectedContacts.length} ontvangers',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Lijst opslaan knop
              TextButton.icon(
                onPressed: _selectedContacts.isEmpty ? null : () => _saveAsList(theme),
                icon: const Icon(Icons.save_alt, size: 18),
                label: const Text('Opslaan'),
              ),
              TextButton.icon(
                onPressed: _availableToAdd.isEmpty ? null : () => _showAddContactDialog(theme),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Toevoegen'),
              ),
            ],
          ),
        ),
        
        // Contacten lijst
        Expanded(
          child: _selectedContacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Geen ontvangers geselecteerd',
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _showAddContactDialog(theme),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Contacten toevoegen'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _selectedContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _selectedContacts[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.primaryColor.withOpacity(0.1),
                        child: Text(
                          contact.firstName.isNotEmpty ? contact.firstName[0].toUpperCase() : '?',
                          style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(contact.fullName),
                      subtitle: Text(
                        contact.email ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedContacts.removeAt(index);
                          });
                        },
                        tooltip: 'Verwijderen',
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  void _showAddContactDialog(ThemeData theme) {
    final available = _availableToAdd;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact toevoegen'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: available.isEmpty
              ? const Center(child: Text('Alle contacten met email zijn al geselecteerd'))
              : ListView.builder(
                  itemCount: available.length,
                  itemBuilder: (context, index) {
                    final contact = available[index];
                    return ListTile(
                      dense: true,
                      title: Text(contact.fullName),
                      subtitle: Text(contact.email ?? '', style: const TextStyle(fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            _selectedContacts.add(contact);
                          });
                          Navigator.pop(context);
                          // Reopen to add more
                          if (_availableToAdd.isNotEmpty) {
                            _showAddContactDialog(theme);
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sluiten'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveAsList(ThemeData theme) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SaveMailingListDialog(
        dossierId: widget.dossierId,
        contactIds: _selectedContacts.map((c) => c.id).toList(),
        suggestedType: _getSelectedMailingType(),
      ),
    );
    
    if (result != null && mounted) {
      await _saveOrUpdateList(
        context: context,
        dossierId: widget.dossierId,
        name: result['name'] as String,
        description: result['description'] as String?,
        contactIds: _selectedContacts.map((c) => c.id).toList(),
        mailingType: result['type'] as String?,
      );
    }
  }
  
  String? _getSelectedMailingType() {
    // Mailing type filters zijn verwijderd - nu alleen categorieën
    return null;
  }
  
  // === STAP 3: CONTENT ===
  Widget _buildContentStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Template selectie
          Text('Template:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<EmailTemplateModel>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: const Text('Selecteer template (optioneel)'),
            value: _selectedTemplate,
            items: _templates.map((template) {
              return DropdownMenuItem(
                value: template,
                child: Text('${template.emoji} ${template.name}'),
              );
            }).toList(),
            onChanged: (template) {
              setState(() {
                _selectedTemplate = template;
                if (template != null) {
                  _subjectController.text = template.subject;
                  _bodyController.text = template.body;
                }
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Onderwerp
          Text('Onderwerp:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _subjectController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Bijv. "Uitnodiging"',
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Body
          Text('Bericht:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _bodyController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              hintText: 'Beste {naam},\n\n...',
            ),
            maxLines: 8,
          ),
          
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Let op: Bij bulk email opent je email-app met één bericht voor alle ontvangers. '
                    'De {naam} placeholder werkt alleen bij individuele emails.',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.amber[900]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              onPressed: () => setState(() => _currentStep--),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Terug'),
            ),
          const Spacer(),
          if (_currentStep < 2)
            ElevatedButton.icon(
              onPressed: _canProceed() ? _nextStep : null,
              icon: const Icon(Icons.arrow_forward),
              label: Text(_currentStep == 0 ? 'Volgende' : 'Naar bericht'),
            )
          else
            ElevatedButton.icon(
              onPressed: _selectedContacts.isNotEmpty ? _sendEmail : null,
              icon: const Icon(Icons.send),
              label: Text('Verstuur (${_selectedContacts.length})'),
            ),
        ],
      ),
    );
  }
  
  bool _canProceed() {
    if (_currentStep == 0) {
      return _filteredContacts.isNotEmpty;
    } else if (_currentStep == 1) {
      return _selectedContacts.isNotEmpty;
    }
    return true;
  }
  
  void _nextStep() {
    if (_currentStep == 0) {
      // Ga naar preview, kopieer gefilterde contacten naar selectie
      setState(() {
        _selectedContacts = List.from(_filteredContacts);
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    }
  }
  
  Widget _buildFilterChip(String label, bool selected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
  
  Future<void> _sendEmail() async {
    Navigator.pop(context);
    
    final subject = _subjectController.text;
    final body = _bodyController.text;
    
    await ContactExportService.sendBulkEmail(
      _selectedContacts,
      subject: subject.isNotEmpty ? subject : null,
      body: body.isNotEmpty ? body : null,
    );
  }
}

// ===== POST/BRIEF DIALOOG =====

class _PostalLettersDialog extends StatefulWidget {
  final List<PersonModel> contacts;
  final String dossierId;
  final int initialStep;
  final List<PersonModel>? preSelectedContacts;
  final List<PersonModel>? allContacts;

  const _PostalLettersDialog({
    required this.contacts,
    required this.dossierId,
    this.initialStep = 0,
    this.preSelectedContacts,
    this.allContacts,
  });

  @override
  State<_PostalLettersDialog> createState() => _PostalLettersDialogState();
}

class _PostalLettersDialogState extends State<_PostalLettersDialog> {
  // Stap beheer (0 = filter, 1 = preview, 2 = inhoud)
  late int _currentStep;
  
  // Categorie filters (mailing type filters verwijderd)
  final Set<ContactCategory> _selectedCategories = {};
  
  // Geselecteerde contacten
  List<PersonModel> _selectedContacts = [];
  
  // Brief inhoud
  final _bodyController = TextEditingController(text: 'Beste,\n\n');
  final _senderNameController = TextEditingController();
  final _senderAddressController = TextEditingController();
  
  // Templates
  List<EmailTemplateModel> _templates = [];
  EmailTemplateModel? _selectedTemplate;
  
  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    if (widget.preSelectedContacts != null && widget.preSelectedContacts!.isNotEmpty) {
      _selectedContacts = List.from(widget.preSelectedContacts!);
    }
    _loadTemplates();
  }
  
  @override
  void dispose() {
    _bodyController.dispose();
    _senderNameController.dispose();
    _senderAddressController.dispose();
    super.dispose();
  }
  
  void _loadTemplates() {
    final templates = DefaultEmailTemplates.getDefaults(widget.dossierId);
    setState(() {
      _templates = templates;
    });
  }
  
  List<PersonModel> get _filteredContacts {
    var filtered = ContactExportService.filterWithAddress(widget.contacts);
    
    // Filter op categorieën (OR logic)
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((c) => c.hasAnyCategory(_selectedCategories)).toList();
    }
    
    return filtered;
  }
  
  // Contacten die nog toegevoegd kunnen worden (hebben adres, niet geselecteerd)
  List<PersonModel> get _availableToAdd {
    final selectedIds = _selectedContacts.map((c) => c.id).toSet();
    final sourceContacts = widget.allContacts ?? widget.contacts;
    return ContactExportService.filterWithAddress(sourceContacts)
        .where((c) => !selectedIds.contains(c.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 750),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.brown.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mail, color: Colors.brown),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Brieven Maken',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _getStepTitle(),
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            
            // Stap indicator
            _buildStepIndicator(theme),
            
            // Content per stap
            Expanded(
              child: _buildStepContent(theme),
            ),
            
            // Footer met navigatie
            _buildFooter(theme),
          ],
        ),
      ),
    );
  }
  
  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return 'Stap 1: Selecteer ontvangers';
      case 1: return 'Stap 2: Controleer selectie';
      case 2: return 'Stap 3: Stel brief op';
      default: return '';
    }
  }
  
  Widget _buildStepIndicator(ThemeData theme) {
    const brown = Colors.brown;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          _buildStepDot(0, 'Filter', theme, brown),
          Expanded(child: Container(height: 2, color: _currentStep > 0 ? brown : Colors.grey[300])),
          _buildStepDot(1, 'Preview', theme, brown),
          Expanded(child: Container(height: 2, color: _currentStep > 1 ? brown : Colors.grey[300])),
          _buildStepDot(2, 'Brief', theme, brown),
        ],
      ),
    );
  }
  
  Widget _buildStepDot(int step, String label, ThemeData theme, Color color) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;
    
    return Column(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? color : Colors.grey[300],
            border: isCurrent ? Border.all(color: color, width: 3) : null,
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isActive ? color : Colors.grey[600],
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStepContent(ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildFilterStep(theme);
      case 1:
        return _buildPreviewStep(theme);
      case 2:
        return _buildContentStep(theme);
      default:
        return const SizedBox();
    }
  }
  
  // === STAP 1: FILTER ===
  Widget _buildFilterStep(ThemeData theme) {
    final filteredContacts = _filteredContacts;
    final totalWithAddress = ContactExportService.filterWithAddress(widget.contacts).length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '$totalWithAddress van ${widget.contacts.length} contacten hebben een volledig adres',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // Categorie filters (EERST)
          Text('Categorie:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ContactCategory.values.map((cat) {
              final isSelected = _selectedCategories.contains(cat);
              return FilterChip(
                label: Text(cat.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedCategories.add(cat);
                    } else {
                      _selectedCategories.remove(cat);
                    }
                  });
                },
              );
            }).toList(),
          ),
          
          
          const SizedBox(height: 24),
          
          // Preview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: filteredContacts.isEmpty ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: filteredContacts.isEmpty ? Colors.orange.withOpacity(0.3) : Colors.green.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  filteredContacts.isEmpty ? Icons.warning : Icons.check_circle,
                  color: filteredContacts.isEmpty ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${filteredContacts.length} contacten gevonden',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: filteredContacts.isEmpty ? Colors.orange[800] : Colors.green[800],
                        ),
                      ),
                      if (filteredContacts.isEmpty)
                        Text(
                          'Pas de filters aan of selecteer handmatig',
                          style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // === STAP 2: PREVIEW ===
  Widget _buildPreviewStep(ThemeData theme) {
    return Column(
      children: [
        // Acties balk
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              Text(
                '${_selectedContacts.length} brieven',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // Lijst opslaan knop
              TextButton.icon(
                onPressed: _selectedContacts.isEmpty ? null : () => _saveAsList(theme),
                icon: const Icon(Icons.save_alt, size: 18),
                label: const Text('Opslaan'),
              ),
              TextButton.icon(
                onPressed: _availableToAdd.isEmpty ? null : () => _showAddContactDialog(theme),
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('Toevoegen'),
              ),
            ],
          ),
        ),
        
        // Contacten lijst
        Expanded(
          child: _selectedContacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline, size: 60, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Geen ontvangers geselecteerd',
                        style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () => _showAddContactDialog(theme),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Contacten toevoegen'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _selectedContacts.length,
                  itemBuilder: (context, index) {
                    final contact = _selectedContacts[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.brown.withOpacity(0.1),
                        child: Text(
                          contact.firstName.isNotEmpty ? contact.firstName[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(contact.fullName),
                      subtitle: Text(
                        '${contact.address ?? ''}, ${contact.city ?? ''}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedContacts.removeAt(index);
                          });
                        },
                        tooltip: 'Verwijderen',
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  void _showAddContactDialog(ThemeData theme) {
    final available = _availableToAdd;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact toevoegen'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: available.isEmpty
              ? const Center(child: Text('Alle contacten met adres zijn al geselecteerd'))
              : ListView.builder(
                  itemCount: available.length,
                  itemBuilder: (context, index) {
                    final contact = available[index];
                    return ListTile(
                      dense: true,
                      title: Text(contact.fullName),
                      subtitle: Text('${contact.city ?? ''}', style: const TextStyle(fontSize: 12)),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            _selectedContacts.add(contact);
                          });
                          Navigator.pop(context);
                          if (_availableToAdd.isNotEmpty) {
                            _showAddContactDialog(theme);
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sluiten'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _saveAsList(ThemeData theme) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SaveMailingListDialog(
        dossierId: widget.dossierId,
        contactIds: _selectedContacts.map((c) => c.id).toList(),
        suggestedType: _getSelectedMailingType(),
      ),
    );
    
    if (result != null && mounted) {
      await _saveOrUpdateList(
        context: context,
        dossierId: widget.dossierId,
        name: result['name'] as String,
        description: result['description'] as String?,
        contactIds: _selectedContacts.map((c) => c.id).toList(),
        mailingType: result['type'] as String?,
      );
    }
  }
  
  String? _getSelectedMailingType() {
    // Mailing type filters zijn verwijderd - nu alleen categorieën
    return null;
  }
  
  // === STAP 3: CONTENT ===
  Widget _buildContentStep(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Afzender sectie
          Text('Afzender (optioneel):', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _senderNameController,
            decoration: const InputDecoration(
              labelText: 'Naam afzender',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _senderAddressController,
            decoration: const InputDecoration(
              labelText: 'Adres afzender',
              hintText: 'Straat 123\n1234 AB Plaats',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            maxLines: 2,
            minLines: 2,
          ),
          
          const SizedBox(height: 24),
          
          // Template selectie
          Text('Template:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<EmailTemplateModel>(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            hint: const Text('Selecteer template (optioneel)'),
            value: _selectedTemplate,
            items: _templates.map((template) {
              return DropdownMenuItem(
                value: template,
                child: Text('${template.emoji} ${template.name}'),
              );
            }).toList(),
            onChanged: (template) {
              setState(() {
                _selectedTemplate = template;
                if (template != null) {
                  _bodyController.text = template.body;
                }
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Body
          Text('Inhoud brief:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _bodyController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
              hintText: 'Beste {naam},\n\n...',
            ),
            maxLines: 10,
          ),
          
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Placeholders: {naam} = volledige naam, {voornaam}, {achternaam}\n'
                    'Deze worden automatisch vervangen per ontvanger.',
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.amber[900]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFooter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              onPressed: () => setState(() => _currentStep--),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Terug'),
            ),
          const Spacer(),
          if (_currentStep < 2)
            ElevatedButton.icon(
              onPressed: _canProceed() ? _nextStep : null,
              icon: const Icon(Icons.arrow_forward),
              label: Text(_currentStep == 0 ? 'Volgende' : 'Naar brief'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: _selectedContacts.isNotEmpty && _bodyController.text.isNotEmpty 
                  ? _exportLetters 
                  : null,
              icon: const Icon(Icons.file_download),
              label: Text('Exporteer (${_selectedContacts.length})'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
  
  bool _canProceed() {
    if (_currentStep == 0) {
      return _filteredContacts.isNotEmpty;
    } else if (_currentStep == 1) {
      return _selectedContacts.isNotEmpty;
    }
    return true;
  }
  
  void _nextStep() {
    if (_currentStep == 0) {
      setState(() {
        _selectedContacts = List.from(_filteredContacts);
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      setState(() => _currentStep = 2);
    }
  }
  
  Widget _buildFilterChip(String label, bool selected, Function(bool) onSelected) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
  
  Future<void> _exportLetters() async {
    // Toon export opties dialoog
    final result = await showDialog<ExportDialogResult>(
      context: context,
      builder: (context) => _ExportOptionsDialog(
        title: 'Brieven exporteren',
        count: _selectedContacts.length,
      ),
    );
    
    if (result == null) return;
    Navigator.pop(context);
    
    if (result.action == 'print') {
      await ContactExportService.printLetters(
        context,
        _selectedContacts,
        body: _bodyController.text,
        senderName: _senderNameController.text.isNotEmpty ? _senderNameController.text : null,
        senderAddress: _senderAddressController.text.isNotEmpty ? _senderAddressController.text : null,
      );
    } else {
      await ContactExportService.exportLetters(
        context,
        _selectedContacts,
        body: _bodyController.text,
        senderName: _senderNameController.text.isNotEmpty ? _senderNameController.text : null,
        senderAddress: _senderAddressController.text.isNotEmpty ? _senderAddressController.text : null,
        format: result.format,
      );
    }
  }
}

// ===== ADRESETIKETTEN DIALOOG =====

class _AddressLabelsDialog extends StatefulWidget {
  final List<PersonModel> contacts;
  final String dossierId;
  final int initialStep;
  final List<PersonModel>? preSelectedContacts;
  final List<PersonModel>? allContacts;

  const _AddressLabelsDialog({
    required this.contacts,
    required this.dossierId,
    this.initialStep = 0,
    this.preSelectedContacts,
    this.allContacts,
  });

  @override
  State<_AddressLabelsDialog> createState() => _AddressLabelsDialogState();
}

class _AddressLabelsDialogState extends State<_AddressLabelsDialog> {
  late int _currentStep;
  
  final Set<ContactCategory> _selectedCategories = {};
  List<PersonModel> _selectedContacts = [];
  
  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    if (widget.preSelectedContacts != null && widget.preSelectedContacts!.isNotEmpty) {
      _selectedContacts = List.from(widget.preSelectedContacts!);
    }
  }
  
  List<PersonModel> get _filteredContacts {
    var filtered = ContactExportService.filterWithAddress(widget.contacts);
    
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((c) => c.hasAnyCategory(_selectedCategories)).toList();
    }
    
    return filtered;
  }
  
  List<PersonModel> get _availableToAdd {
    final selectedIds = _selectedContacts.map((c) => c.id).toSet();
    final sourceContacts = widget.allContacts ?? widget.contacts;
    return ContactExportService.filterWithAddress(sourceContacts)
        .where((c) => !selectedIds.contains(c.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accentColor = Colors.teal;
    
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.label, color: accentColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Adresetiketten',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _currentStep == 0 ? 'Stap 1: Selecteer' : 'Stap 2: Controleer',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Step indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  _buildDot(0, 'Filter', accentColor),
                  Expanded(child: Container(height: 2, color: _currentStep > 0 ? accentColor : Colors.grey[300])),
                  _buildDot(1, 'Preview', accentColor),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _currentStep == 0 ? _buildFilterStep(theme) : _buildPreviewStep(theme),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    TextButton.icon(
                      onPressed: () => setState(() => _currentStep--),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Terug'),
                    ),
                  const Spacer(),
                  if (_currentStep == 0)
                    ElevatedButton.icon(
                      onPressed: _filteredContacts.isNotEmpty ? () {
                        setState(() {
                          _selectedContacts = List.from(_filteredContacts);
                          _currentStep = 1;
                        });
                      } : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Volgende'),
                      style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _selectedContacts.isNotEmpty ? _export : null,
                      icon: const Icon(Icons.file_download),
                      label: Text('Exporteer (${_selectedContacts.length})'),
                      style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDot(int step, String label, Color color) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? color : Colors.grey[300]),
          child: Center(child: Text('${step + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: isActive ? color : Colors.grey[600])),
      ],
    );
  }
  
  Widget _buildFilterStep(ThemeData theme) {
    final filtered = _filteredContacts;
    final total = ContactExportService.filterWithAddress(widget.contacts).length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.info_outline, color: Colors.amber, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('$total van ${widget.contacts.length} contacten hebben een adres', style: theme.textTheme.bodySmall)),
            ]),
          ),
          const SizedBox(height: 20),
          Text('Categorie:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ContactCategory.values.map((cat) {
              return FilterChip(
                label: Text(cat.displayName),
                selected: _selectedCategories.contains(cat),
                onSelected: (s) => setState(() => s ? _selectedCategories.add(cat) : _selectedCategories.remove(cat)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: filtered.isEmpty ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              Icon(filtered.isEmpty ? Icons.warning : Icons.check_circle, color: filtered.isEmpty ? Colors.orange : Colors.green),
              const SizedBox(width: 12),
              Text('${filtered.length} etiketten', style: TextStyle(fontWeight: FontWeight.bold, color: filtered.isEmpty ? Colors.orange[800] : Colors.green[800])),
            ]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreviewStep(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.grey[100], border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
          child: Row(children: [
            Text('${_selectedContacts.length} etiketten', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: _selectedContacts.isEmpty ? null : () => _saveAsList(theme),
              icon: const Icon(Icons.save_alt, size: 18),
              label: const Text('Opslaan'),
            ),
            TextButton.icon(
              onPressed: _availableToAdd.isEmpty ? null : () => _showAddDialog(theme),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Toevoegen'),
            ),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _selectedContacts.length,
            itemBuilder: (context, index) {
              final c = _selectedContacts[index];
              return ListTile(
                dense: true,
                leading: CircleAvatar(radius: 18, backgroundColor: Colors.teal.withOpacity(0.1), child: Text(c.firstName.isNotEmpty ? c.firstName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold))),
                title: Text(c.fullName),
                subtitle: Text('${c.address ?? ''}, ${c.city ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => setState(() => _selectedContacts.removeAt(index))),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Future<void> _saveAsList(ThemeData theme) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SaveMailingListDialog(
        dossierId: widget.dossierId,
        contactIds: _selectedContacts.map((c) => c.id).toList(),
        suggestedType: null,
      ),
    );
    
    if (result != null && mounted) {
      await _saveOrUpdateList(
        context: context,
        dossierId: widget.dossierId,
        name: result['name'] as String,
        description: result['description'] as String?,
        contactIds: _selectedContacts.map((c) => c.id).toList(),
        mailingType: result['type'] as String?,
      );
    }
  }
  
  void _showAddDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact toevoegen'),
        content: SizedBox(
          width: 300, height: 400,
          child: ListView.builder(
            itemCount: _availableToAdd.length,
            itemBuilder: (_, i) {
              final c = _availableToAdd[i];
              return ListTile(
                dense: true,
                title: Text(c.fullName),
                subtitle: Text(c.city ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                  onPressed: () {
                    setState(() => _selectedContacts.add(c));
                    Navigator.pop(ctx);
                    if (_availableToAdd.isNotEmpty) _showAddDialog(theme);
                  },
                ),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Sluiten'))],
      ),
    );
  }
  
  Future<void> _export() async {
    final result = await showDialog<ExportDialogResult>(
      context: context,
      builder: (context) => _ExportOptionsDialog(title: 'Etiketten exporteren', count: _selectedContacts.length),
    );
    if (result == null) return;
    Navigator.pop(context);
    
    if (result.action == 'print') {
      await ContactExportService.printAddressLabels(context, _selectedContacts);
    } else {
      await ContactExportService.exportAddressLabels(context, _selectedContacts, format: result.format);
    }
  }
}

// ===== ADRESLIJST DIALOOG =====

class _AddressListDialog extends StatefulWidget {
  final List<PersonModel> contacts;
  final String dossierId;
  final int initialStep;
  final List<PersonModel>? preSelectedContacts;
  final List<PersonModel>? allContacts;

  const _AddressListDialog({
    required this.contacts,
    required this.dossierId,
    this.initialStep = 0,
    this.preSelectedContacts,
    this.allContacts,
  });

  @override
  State<_AddressListDialog> createState() => _AddressListDialogState();
}

class _AddressListDialogState extends State<_AddressListDialog> {
  late int _currentStep;
  
  final Set<ContactCategory> _selectedCategories = {};
  List<PersonModel> _selectedContacts = [];
  
  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep;
    if (widget.preSelectedContacts != null && widget.preSelectedContacts!.isNotEmpty) {
      _selectedContacts = List.from(widget.preSelectedContacts!);
    }
  }
  
  List<PersonModel> get _filteredContacts {
    var filtered = ContactExportService.filterWithAddress(widget.contacts);
    
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((c) => c.hasAnyCategory(_selectedCategories)).toList();
    }
    
    return filtered;
  }
  
  List<PersonModel> get _availableToAdd {
    final selectedIds = _selectedContacts.map((c) => c.id).toSet();
    final sourceContacts = widget.allContacts ?? widget.contacts;
    return ContactExportService.filterWithAddress(sourceContacts)
        .where((c) => !selectedIds.contains(c.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accentColor = Colors.indigo;
    
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 550, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.list_alt, color: accentColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Adreslijst',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _currentStep == 0 ? 'Stap 1: Selecteer' : 'Stap 2: Controleer',
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            
            // Step indicator
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  _buildDot(0, 'Filter', accentColor),
                  Expanded(child: Container(height: 2, color: _currentStep > 0 ? accentColor : Colors.grey[300])),
                  _buildDot(1, 'Preview', accentColor),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: _currentStep == 0 ? _buildFilterStep(theme) : _buildPreviewStep(theme),
            ),
            
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey[300]!))),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    TextButton.icon(onPressed: () => setState(() => _currentStep--), icon: const Icon(Icons.arrow_back), label: const Text('Terug')),
                  const Spacer(),
                  if (_currentStep == 0)
                    ElevatedButton.icon(
                      onPressed: _filteredContacts.isNotEmpty ? () {
                        setState(() {
                          _selectedContacts = List.from(_filteredContacts);
                          _currentStep = 1;
                        });
                      } : null,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Volgende'),
                      style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _selectedContacts.isNotEmpty ? _export : null,
                      icon: const Icon(Icons.file_download),
                      label: Text('Exporteer (${_selectedContacts.length})'),
                      style: ElevatedButton.styleFrom(backgroundColor: accentColor, foregroundColor: Colors.white),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDot(int step, String label, Color color) {
    final isActive = _currentStep >= step;
    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(shape: BoxShape.circle, color: isActive ? color : Colors.grey[300]),
          child: Center(child: Text('${step + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 12))),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 11, color: isActive ? color : Colors.grey[600])),
      ],
    );
  }
  
  Widget _buildFilterStep(ThemeData theme) {
    final filtered = _filteredContacts;
    final total = ContactExportService.filterWithAddress(widget.contacts).length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.info_outline, color: Colors.amber, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text('$total van ${widget.contacts.length} contacten hebben een adres', style: theme.textTheme.bodySmall)),
            ]),
          ),
          const SizedBox(height: 20),
          Text('Categorie:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: ContactCategory.values.map((cat) {
              return FilterChip(
                label: Text(cat.displayName),
                selected: _selectedCategories.contains(cat),
                onSelected: (s) => setState(() => s ? _selectedCategories.add(cat) : _selectedCategories.remove(cat)),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: filtered.isEmpty ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(children: [
              Icon(filtered.isEmpty ? Icons.warning : Icons.check_circle, color: filtered.isEmpty ? Colors.orange : Colors.green),
              const SizedBox(width: 12),
              Text('${filtered.length} adressen', style: TextStyle(fontWeight: FontWeight.bold, color: filtered.isEmpty ? Colors.orange[800] : Colors.green[800])),
            ]),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPreviewStep(ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Colors.grey[100], border: Border(bottom: BorderSide(color: Colors.grey[300]!))),
          child: Row(children: [
            Text('${_selectedContacts.length} adressen', style: const TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            TextButton.icon(
              onPressed: _selectedContacts.isEmpty ? null : () => _saveAsList(theme),
              icon: const Icon(Icons.save_alt, size: 18),
              label: const Text('Opslaan'),
            ),
            TextButton.icon(
              onPressed: _availableToAdd.isEmpty ? null : () => _showAddDialog(theme),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Toevoegen'),
            ),
          ]),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _selectedContacts.length,
            itemBuilder: (context, index) {
              final c = _selectedContacts[index];
              return ListTile(
                dense: true,
                leading: CircleAvatar(radius: 18, backgroundColor: Colors.indigo.withOpacity(0.1), child: Text(c.firstName.isNotEmpty ? c.firstName[0].toUpperCase() : '?', style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold))),
                title: Text(c.fullName),
                subtitle: Text('${c.address ?? ''}, ${c.city ?? ''}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                trailing: IconButton(icon: const Icon(Icons.remove_circle_outline, color: Colors.red), onPressed: () => setState(() => _selectedContacts.removeAt(index))),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Future<void> _saveAsList(ThemeData theme) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SaveMailingListDialog(
        dossierId: widget.dossierId,
        contactIds: _selectedContacts.map((c) => c.id).toList(),
        suggestedType: null,
      ),
    );
    
    if (result != null && mounted) {
      await _saveOrUpdateList(
        context: context,
        dossierId: widget.dossierId,
        name: result['name'] as String,
        description: result['description'] as String?,
        contactIds: _selectedContacts.map((c) => c.id).toList(),
        mailingType: result['type'] as String?,
      );
    }
  }
  
  void _showAddDialog(ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact toevoegen'),
        content: SizedBox(
          width: 300, height: 400,
          child: ListView.builder(
            itemCount: _availableToAdd.length,
            itemBuilder: (_, i) {
              final c = _availableToAdd[i];
              return ListTile(
                dense: true,
                title: Text(c.fullName),
                subtitle: Text(c.city ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                  onPressed: () {
                    setState(() => _selectedContacts.add(c));
                    Navigator.pop(ctx);
                    if (_availableToAdd.isNotEmpty) _showAddDialog(theme);
                  },
                ),
              );
            },
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Sluiten'))],
      ),
    );
  }
  
  Future<void> _export() async {
    final result = await showDialog<ExportDialogResult>(
      context: context,
      builder: (context) => _ExportOptionsDialog(title: 'Adreslijst exporteren', count: _selectedContacts.length),
    );
    if (result == null) return;
    Navigator.pop(context);
    
    if (result.action == 'print') {
      await ContactExportService.printAddressList(context, _selectedContacts);
    } else {
      await ContactExportService.shareAddressList(context, _selectedContacts, format: result.format);
    }
  }
}

// ===== EXPORT OPTIES DIALOOG =====

/// Resultaat van de export opties dialoog
class ExportDialogResult {
  final String action; // 'file' or 'print'
  final ExportFormat? format; // alleen voor 'file'

  ExportDialogResult({required this.action, this.format});
}

class _ExportOptionsDialog extends StatefulWidget {
  final String title;
  final int count;

  const _ExportOptionsDialog({
    required this.title,
    required this.count,
  });

  @override
  State<_ExportOptionsDialog> createState() => _ExportOptionsDialogState();
}

class _ExportOptionsDialogState extends State<_ExportOptionsDialog> {
  ExportFormat _selectedFormat = ExportFormat.pdf;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.count} items klaar voor export'),
          const SizedBox(height: 20),
          
          // Formaat selectie
          const Text('Bestandsformaat:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ExportFormat.values.map((format) => ChoiceChip(
              avatar: Icon(format.icon, size: 18),
              label: Text(format.label),
              selected: _selectedFormat == format,
              onSelected: (selected) {
                if (selected) setState(() => _selectedFormat = format);
              },
            )).toList(),
          ),
          const SizedBox(height: 24),
          
          // Exporteer naar bestand
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.file_download, color: Colors.white),
            ),
            title: const Text('Opslaan als bestand'),
            subtitle: Text('Exporteer als ${_selectedFormat.label}'),
            onTap: () => Navigator.pop(context, ExportDialogResult(
              action: 'file',
              format: _selectedFormat,
            )),
          ),
          const Divider(),
          
          // Direct printen
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.print, color: Colors.white),
            ),
            title: const Text('Direct printen'),
            subtitle: const Text('Open printdialoog'),
            onTap: () => Navigator.pop(context, ExportDialogResult(action: 'print')),
          ),
        ],
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

// ===== MAILING LIJSTEN DIALOOG =====

class _MailingListsDialog extends ConsumerStatefulWidget {
  final String dossierId;

  const _MailingListsDialog({required this.dossierId});

  @override
  ConsumerState<_MailingListsDialog> createState() => _MailingListsDialogState();
}

class _MailingListsDialogState extends ConsumerState<_MailingListsDialog> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listsAsync = ref.watch(mailingListsProvider(widget.dossierId));

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.7,
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Icon(Icons.folder_special, color: theme.primaryColor),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Opgeslagen Mailing Lijsten',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: listsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Fout: $err')),
                data: (lists) {
                  if (lists.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open, size: 60, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Geen opgeslagen lijsten',
                            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sla een selectie op vanuit\n"Email versturen" of "Brieven maken"',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: lists.length,
                    itemBuilder: (context, index) {
                      final list = lists[index];
                      return Card(
                        child: ListTile(
                          onTap: () => _viewList(list),
                          leading: CircleAvatar(
                            backgroundColor: theme.primaryColor.withOpacity(0.1),
                            child: Text(list.emoji, style: const TextStyle(fontSize: 20)),
                          ),
                          title: Text(list.name),
                          subtitle: Text(
                            '${list.contactCount} contacten • ${list.typeLabel}',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                onPressed: () => _viewList(list),
                                tooltip: 'Bekijken/bewerken',
                              ),
                              IconButton(
                                icon: const Icon(Icons.email, size: 20),
                                onPressed: () => _useList(list, 'email'),
                                tooltip: 'Email versturen',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                onPressed: () => _deleteList(list),
                                tooltip: 'Verwijderen',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Sluiten'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _viewList(MailingListModel list) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _EditMailingListDialog(
        mailingList: list,
        dossierId: widget.dossierId,
      ),
    );
    
    if (result == true) {
      ref.invalidate(mailingListsProvider(widget.dossierId));
    }
  }

  void _useList(MailingListModel list, String action) async {
    Navigator.pop(context);
    // TODO: Implementeer gebruik van opgeslagen lijst
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lijst "${list.name}" geladen met ${list.contactCount} contacten')),
    );
  }

  void _deleteList(MailingListModel list) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Lijst verwijderen'),
        content: Text('Weet je zeker dat je "${list.name}" wilt verwijderen?'),
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
      ),
    );

    if (confirm == true) {
      final repository = ref.read(mailingListRepositoryProvider);
      await repository.deleteList(list.id);
      ref.invalidate(mailingListsProvider(widget.dossierId));
    }
  }
}

// ===== HELPER: SAVE OR UPDATE MAILING LIST =====

/// Helper functie om een mailing lijst op te slaan of bij te werken
/// Als een lijst met dezelfde naam bestaat, vraagt om bevestiging voor overschrijven
Future<void> _saveOrUpdateList({
  required BuildContext context,
  required String dossierId,
  required String name,
  String? description,
  required List<String> contactIds,
  String? mailingType,
  String? emoji,
}) async {
  try {
    final repository = MailingListRepository(AppDatabase.instance);
    
    // Check of een lijst met deze naam al bestaat
    final existingLists = await repository.getListsForDossier(dossierId);
    final existingList = existingLists.where((l) => l.name.toLowerCase() == name.toLowerCase()).toList();
    
    if (existingList.isNotEmpty && context.mounted) {
      // Vraag of gebruiker wil overschrijven
      final overwrite = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Lijst bestaat al'),
          content: Text('Er bestaat al een lijst met de naam "$name".\n\nWil je deze overschrijven met de huidige selectie?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuleren'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Overschrijven'),
            ),
          ],
        ),
      );
      
      if (overwrite == true && context.mounted) {
        await repository.updateList(
          listId: existingList.first.id,
          name: name,
          emoji: emoji ?? existingList.first.emoji,
          contactIds: contactIds,
          description: description,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lijst "$name" bijgewerkt'), backgroundColor: Colors.green),
        );
      }
    } else {
      await repository.createList(
        dossierId: dossierId,
        name: name,
        description: description,
        contactIds: contactIds,
        mailingType: mailingType,
        emoji: emoji ?? '📋',
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lijst "$name" opgeslagen'), backgroundColor: Colors.green),
        );
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Fout bij opslaan: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

// ===== SAVE MAILING LIST DIALOOG =====

class SaveMailingListDialog extends StatefulWidget {
  final String dossierId;
  final List<String> contactIds;
  final String? suggestedType;

  const SaveMailingListDialog({
    super.key,
    required this.dossierId,
    required this.contactIds,
    this.suggestedType,
  });

  @override
  State<SaveMailingListDialog> createState() => _SaveMailingListDialogState();
}

class _SaveMailingListDialogState extends State<SaveMailingListDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.suggestedType;
    
    // Suggestie voor naam
    final now = DateTime.now();
    final typeLabel = _getTypeLabel(widget.suggestedType);
    _nameController.text = '$typeLabel ${now.day}-${now.month}-${now.year}';
  }

  String _getTypeLabel(String? type) {
    switch (type) {
      case 'christmas': return 'Kerstlijst';
      case 'newsletter': return 'Nieuwsbrieflijst';
      case 'party': return 'Feestlijst';
      case 'funeral': return 'Rouwlijst';
      default: return 'Mailing';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Selectie opslaan'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.contactIds.length} contacten opslaan als mailing lijst',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Naam *',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 12),
            
            DropdownButtonFormField<String?>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Algemeen')),
                DropdownMenuItem(value: 'christmas', child: Text('🎄 Kerstkaarten')),
                DropdownMenuItem(value: 'newsletter', child: Text('📧 Nieuwsbrief')),
                DropdownMenuItem(value: 'party', child: Text('🎉 Feesten')),
                DropdownMenuItem(value: 'funeral', child: Text('🕯️ Rouwkaarten')),
              ],
              onChanged: (v) => setState(() => _selectedType = v),
            ),
            const SizedBox(height: 12),
            
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Beschrijving (optioneel)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
        ElevatedButton(
          onPressed: _nameController.text.trim().isNotEmpty ? _save : null,
          child: const Text('Opslaan'),
        ),
      ],
    );
  }

  void _save() {
    Navigator.pop(context, {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim(),
      'type': _selectedType,
    });
  }
}

// ===== EDIT MAILING LIST DIALOOG =====

class _EditMailingListDialog extends ConsumerStatefulWidget {
  final MailingListModel mailingList;
  final String dossierId;

  const _EditMailingListDialog({
    required this.mailingList,
    required this.dossierId,
  });

  @override
  ConsumerState<_EditMailingListDialog> createState() => _EditMailingListDialogState();
}

class _EditMailingListDialogState extends ConsumerState<_EditMailingListDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late List<String> _contactIds;
  List<PersonModel> _contacts = [];
  List<PersonModel> _allContacts = [];
  bool _isLoading = true;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.mailingList.name);
    _descriptionController = TextEditingController(text: widget.mailingList.description ?? '');
    _contactIds = List.from(widget.mailingList.contactIds);
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final allContacts = await PersonRepository.getPersonsForDossier(widget.dossierId);
    
    setState(() {
      _allContacts = allContacts;
      _contacts = allContacts.where((c) => _contactIds.contains(c.id)).toList();
      _isLoading = false;
    });
  }

  List<PersonModel> get _availableToAdd {
    return _allContacts.where((c) => !_contactIds.contains(c.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Row(
                children: [
                  Text(widget.mailingList.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Mailing Lijst Bewerken',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.mailingList.typeLabel,
                          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context, _hasChanges),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Naam en beschrijving
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Naam',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() => _hasChanges = true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Beschrijving (optioneel)',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() => _hasChanges = true),
                  ),
                ],
              ),
            ),

            // Contacten header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${_contacts.length} contacten',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: _availableToAdd.isEmpty ? null : _showAddContactDialog,
                    icon: const Icon(Icons.person_add, size: 18),
                    label: const Text('Toevoegen'),
                  ),
                ],
              ),
            ),

            // Contacten lijst
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _contacts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 12),
                              Text(
                                'Geen contacten in deze lijst',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          itemCount: _contacts.length,
                          itemBuilder: (context, index) {
                            final contact = _contacts[index];
                            return Card(
                              child: ListTile(
                                dense: true,
                                leading: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                                  child: Text(
                                    contact.firstName.isNotEmpty ? contact.firstName[0].toUpperCase() : '?',
                                    style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(contact.fullName),
                                subtitle: Text(
                                  contact.email ?? contact.city ?? '',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                  onPressed: () => _removeContact(contact),
                                  tooltip: 'Verwijderen uit lijst',
                                ),
                              ),
                            );
                          },
                        ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Row(
                children: [
                  Text(
                    _hasChanges ? 'Wijzigingen niet opgeslagen' : '',
                    style: TextStyle(color: Colors.orange[700], fontSize: 12),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context, _hasChanges),
                    child: const Text('Sluiten'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _hasChanges ? _saveChanges : null,
                    icon: const Icon(Icons.save),
                    label: const Text('Opslaan'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeContact(PersonModel contact) {
    setState(() {
      _contactIds.remove(contact.id);
      _contacts.removeWhere((c) => c.id == contact.id);
      _hasChanges = true;
    });
  }

  void _showAddContactDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact toevoegen'),
        content: SizedBox(
          width: 350,
          height: 400,
          child: _availableToAdd.isEmpty
              ? const Center(child: Text('Alle contacten zijn al toegevoegd'))
              : ListView.builder(
                  itemCount: _availableToAdd.length,
                  itemBuilder: (_, index) {
                    final contact = _availableToAdd[index];
                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        child: Text(contact.firstName.isNotEmpty ? contact.firstName[0] : '?'),
                      ),
                      title: Text(contact.fullName),
                      subtitle: Text(contact.email ?? contact.city ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                        onPressed: () {
                          setState(() {
                            _contactIds.add(contact.id);
                            _contacts.add(contact);
                            _hasChanges = true;
                          });
                          Navigator.pop(ctx);
                          if (_availableToAdd.isNotEmpty) {
                            _showAddContactDialog();
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Sluiten'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Naam is verplicht'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final repository = ref.read(mailingListRepositoryProvider);
      final updated = widget.mailingList.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        contactIds: _contactIds,
        updatedAt: DateTime.now(),
      );
      
      await repository.updateListModel(updated);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lijst "${updated.name}" opgeslagen'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij opslaan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
