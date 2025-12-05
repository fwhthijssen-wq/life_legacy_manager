// lib/modules/subscriptions/screens/subscription_list_screen.dart
// Lijst van abonnementen per categorie

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_model.dart';
import '../models/subscription_enums.dart';
import '../providers/subscription_providers.dart';
import 'subscription_detail_screen.dart';

/// Sorteer opties voor abonnementen
enum SubscriptionSort {
  nameAsc('Naam A-Z'),
  nameDesc('Naam Z-A'),
  priceAsc('Prijs laag-hoog'),
  priceDesc('Prijs hoog-laag'),
  status('Status');

  final String label;
  const SubscriptionSort(this.label);
}

/// Filter opties voor abonnementen
enum SubscriptionFilter {
  all('Alle'),
  active('Actief'),
  cancelled('Opgezegd'),
  ended('Beëindigd'),
  paused('Gepauzeerd');

  final String label;
  const SubscriptionFilter(this.label);
}

class SubscriptionListScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final SubscriptionCategory category;

  const SubscriptionListScreen({
    super.key,
    required this.dossierId,
    required this.category,
  });

  @override
  ConsumerState<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends ConsumerState<SubscriptionListScreen> {
  SubscriptionSort _sortBy = SubscriptionSort.nameAsc;
  SubscriptionFilter _filterBy = SubscriptionFilter.all;

  @override
  Widget build(BuildContext context) {
    final subscriptionsAsync = ref.watch(
      subscriptionsByCategoryProvider((dossierId: widget.dossierId, category: widget.category)),
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.category.emoji),
            const SizedBox(width: 8),
            Text(widget.category.label),
          ],
        ),
        actions: [
          // Filter
          PopupMenuButton<SubscriptionFilter>(
            icon: Badge(
              isLabelVisible: _filterBy != SubscriptionFilter.all,
              child: const Icon(Icons.filter_list),
            ),
            tooltip: 'Filter',
            onSelected: (filter) => setState(() => _filterBy = filter),
            itemBuilder: (context) => SubscriptionFilter.values.map((filter) => PopupMenuItem(
              value: filter,
              child: Row(
                children: [
                  Text(filter.label),
                  if (_filterBy == filter) ...[
                    const Spacer(),
                    Icon(Icons.check, size: 18, color: theme.primaryColor),
                  ],
                ],
              ),
            )).toList(),
          ),
          // Sorteer
          PopupMenuButton<SubscriptionSort>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sorteer',
            onSelected: (sort) => setState(() => _sortBy = sort),
            itemBuilder: (context) => SubscriptionSort.values.map((sort) => PopupMenuItem(
              value: sort,
              child: Row(
                children: [
                  Text(sort.label),
                  if (_sortBy == sort) ...[
                    const Spacer(),
                    Icon(Icons.check, size: 18, color: theme.primaryColor),
                  ],
                ],
              ),
            )).toList(),
          ),
        ],
      ),
      body: subscriptionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Fout: $err')),
        data: (subscriptions) {
          if (subscriptions.isEmpty) {
            return _buildEmptyState(context, theme);
          }

          // Filter
          var filtered = subscriptions.where((s) {
            switch (_filterBy) {
              case SubscriptionFilter.all:
                return true;
              case SubscriptionFilter.active:
                return s.status == SubscriptionStatus.active;
              case SubscriptionFilter.cancelled:
                return s.status == SubscriptionStatus.cancelled;
              case SubscriptionFilter.ended:
                return s.status == SubscriptionStatus.ended;
              case SubscriptionFilter.paused:
                return s.status == SubscriptionStatus.paused;
            }
          }).toList();

          // Sorteer
          switch (_sortBy) {
            case SubscriptionSort.nameAsc:
              filtered.sort((a, b) => a.name.compareTo(b.name));
              break;
            case SubscriptionSort.nameDesc:
              filtered.sort((a, b) => b.name.compareTo(a.name));
              break;
            case SubscriptionSort.priceAsc:
              filtered.sort((a, b) => a.monthlyCost.compareTo(b.monthlyCost));
              break;
            case SubscriptionSort.priceDesc:
              filtered.sort((a, b) => b.monthlyCost.compareTo(a.monthlyCost));
              break;
            case SubscriptionSort.status:
              filtered.sort((a, b) => a.status.index.compareTo(b.status.index));
              break;
          }

          // Bereken totalen
          final active = subscriptions.where((s) => s.status == SubscriptionStatus.active);
          final totalMonthly = active.fold<double>(0, (sum, s) => sum + s.monthlyCost);

          return Column(
            children: [
              // Header met totalen
              Container(
                padding: const EdgeInsets.all(16),
                color: Color(widget.category.colorValue).withOpacity(0.1),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${active.length} actief',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '€ ${totalMonthly.toStringAsFixed(2)}/maand',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(widget.category.colorValue),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Lijst
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_list_off, size: 48, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('Geen resultaten', style: TextStyle(color: Colors.grey[600])),
                            TextButton(
                              onPressed: () => setState(() => _filterBy = SubscriptionFilter.all),
                              child: const Text('Filter wissen'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final subscription = filtered[index];
                          return _buildSubscriptionCard(context, subscription);
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSubscription(context),
        icon: const Icon(Icons.add),
        label: const Text('Toevoegen'),
        backgroundColor: Color(widget.category.colorValue),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.category.emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 24),
            Text(
              'Nog geen ${widget.category.label.toLowerCase()}',
              style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Voeg je eerste abonnement toe',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => _addSubscription(context),
              icon: const Icon(Icons.add),
              label: const Text('Abonnement toevoegen'),
              style: FilledButton.styleFrom(
                backgroundColor: Color(widget.category.colorValue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, SubscriptionModel subscription) {
    final percentage = subscription.completenessPercentage;
    final progressColor = percentage >= 80 ? Colors.green : percentage >= 50 ? Colors.orange : Colors.red;
    final statusColor = _getStatusColor(subscription.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Color(widget.category.colorValue).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              subscription.subscriptionType.emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                subscription.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                subscription.status.label,
                style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subscription.provider != null)
              Text(
                subscription.provider!,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            Row(
              children: [
                if (subscription.cost != null) ...[
                  Text(
                    '€ ${subscription.monthlyCost.toStringAsFixed(2)}/mnd',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(widget.category.colorValue),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(' • ', style: TextStyle(color: Colors.grey)),
                ],
                Text(
                  subscription.paymentFrequency.label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ],
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
            Icon(Icons.chevron_right, color: Color(widget.category.colorValue)),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SubscriptionDetailScreen(
                dossierId: widget.dossierId,
                subscriptionId: subscription.id,
              ),
            ),
          ).then((_) {
            ref.invalidate(subscriptionsByCategoryProvider((dossierId: widget.dossierId, category: widget.category)));
          });
        },
      ),
    );
  }

  Color _getStatusColor(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.active:
        return Colors.green;
      case SubscriptionStatus.paused:
        return Colors.orange;
      case SubscriptionStatus.cancelled:
        return Colors.blue;
      case SubscriptionStatus.ended:
        return Colors.grey;
      case SubscriptionStatus.trial:
        return Colors.purple;
    }
  }

  Future<void> _addSubscription(BuildContext context) async {
    // Toon dialog voor naam
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nieuw ${widget.category.label.toLowerCase()}'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Naam',
            hintText: 'Bijv. Netflix, Sportschool, etc.',
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Toevoegen'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    final repo = ref.read(subscriptionRepositoryProvider);
    final subscriptionId = await repo.createSubscription(
      dossierId: widget.dossierId,
      name: name,
      category: widget.category,
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubscriptionDetailScreen(
          dossierId: widget.dossierId,
          subscriptionId: subscriptionId,
          isNew: true,
        ),
      ),
    ).then((_) {
      ref.invalidate(subscriptionsByCategoryProvider((dossierId: widget.dossierId, category: widget.category)));
    });
  }
}

