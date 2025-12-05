// lib/modules/assets/screens/asset_list_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../l10n/app_localizations.dart';
import '../models/asset_model.dart';
import '../models/asset_enums.dart';
import '../providers/asset_providers.dart';
import 'asset_detail_screen.dart';

class AssetListScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final AssetCategory category;
  final String? personId;

  const AssetListScreen({
    super.key,
    required this.dossierId,
    required this.category,
    this.personId,
  });

  @override
  ConsumerState<AssetListScreen> createState() => _AssetListScreenState();
}

class _AssetListScreenState extends ConsumerState<AssetListScreen> {
  final _currencyFormat = NumberFormat.currency(locale: 'nl_NL', symbol: '€');
  String _sortBy = 'name';
  bool _sortAscending = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final assetsAsync = ref.watch(
      assetsForCategoryProvider((
        dossierId: widget.dossierId,
        category: widget.category,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.category.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(widget.category.label),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                if (_sortBy == value) {
                  _sortAscending = !_sortAscending;
                } else {
                  _sortBy = value;
                  _sortAscending = true;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'name',
                child: Row(
                  children: [
                    if (_sortBy == 'name')
                      Icon(
                        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                    const SizedBox(width: 8),
                    Text(l10n.sortByName),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'value',
                child: Row(
                  children: [
                    if (_sortBy == 'value')
                      Icon(
                        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                    const SizedBox(width: 8),
                    Text(l10n.sortByValue),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'date',
                child: Row(
                  children: [
                    if (_sortBy == 'date')
                      Icon(
                        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 16,
                      ),
                    const SizedBox(width: 8),
                    Text(l10n.sortByDate),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(assetsForCategoryProvider((
            dossierId: widget.dossierId,
            category: widget.category,
          )));
        },
        child: assetsAsync.when(
          data: (assets) {
            if (assets.isEmpty) {
              return _buildEmptyState(theme, l10n);
            }
            return _buildAssetsList(assets, theme, l10n);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addAsset(),
        icon: const Icon(Icons.add),
        label: Text(l10n.addItem),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.category.emoji,
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noItemsInCategory,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.addFirstItemHint,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _addAsset(),
              icon: const Icon(Icons.add),
              label: Text(l10n.addItem),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsList(List<AssetModel> assets, ThemeData theme, AppLocalizations l10n) {
    // Sorteer assets
    final sortedAssets = List<AssetModel>.from(assets);
    switch (_sortBy) {
      case 'name':
        sortedAssets.sort((a, b) => _sortAscending
            ? a.name.compareTo(b.name)
            : b.name.compareTo(a.name));
        break;
      case 'value':
        sortedAssets.sort((a, b) => _sortAscending
            ? a.effectiveValue.compareTo(b.effectiveValue)
            : b.effectiveValue.compareTo(a.effectiveValue));
        break;
      case 'date':
        sortedAssets.sort((a, b) {
          final dateA = a.purchaseDate ?? a.createdAt;
          final dateB = b.purchaseDate ?? b.createdAt;
          return _sortAscending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
        });
        break;
    }

    // Bereken totalen
    final totalValue = assets.fold<double>(0, (sum, a) => sum + a.effectiveValue);

    return Column(
      children: [
        // Header met totalen
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                icon: Icons.category,
                value: '${assets.length}',
                label: l10n.items,
              ),
              _buildSummaryItem(
                icon: Icons.euro,
                value: _currencyFormat.format(totalValue),
                label: l10n.totalValue,
              ),
            ],
          ),
        ),

        // Assets lijst
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedAssets.length,
            itemBuilder: (context, index) {
              final asset = sortedAssets[index];
              return _buildAssetCard(asset, theme, l10n);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildAssetCard(AssetModel asset, ThemeData theme, AppLocalizations l10n) {
    final hasPhoto = asset.mainPhotoPath != null && asset.mainPhotoPath!.isNotEmpty;
    final completeness = asset.completenessPercentage;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openAssetDetail(asset),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Foto of placeholder
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                clipBehavior: Clip.antiAlias,
                child: hasPhoto
                    ? Image.file(
                        File(asset.mainPhotoPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (asset.brand != null || asset.model != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        [asset.brand, asset.model].whereType<String>().join(' '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (asset.effectiveValue > 0) ...[
                          Text(
                            _currencyFormat.format(asset.effectiveValue),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (asset.hasHeir || asset.inheritanceDestination != null)
                          const Icon(Icons.person, size: 16, color: Colors.green),
                        if (asset.isInsured)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(Icons.shield, size: 16, color: Colors.blue),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Completeness badge en arrow
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: completeness >= 80
                          ? Colors.green
                          : completeness >= 50
                              ? Colors.orange
                              : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$completeness%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Text(
        widget.category.emoji,
        style: const TextStyle(fontSize: 32),
      ),
    );
  }

  void _addAsset() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetDetailScreen(
          dossierId: widget.dossierId,
          category: widget.category,
          personId: widget.personId,
        ),
      ),
    ).then((_) {
      ref.invalidate(assetsForCategoryProvider((
        dossierId: widget.dossierId,
        category: widget.category,
      )));
    });
  }

  void _openAssetDetail(AssetModel asset) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssetDetailScreen(
          dossierId: widget.dossierId,
          assetId: asset.id,
          category: widget.category,
          personId: widget.personId,
        ),
      ),
    ).then((_) {
      ref.invalidate(assetsForCategoryProvider((
        dossierId: widget.dossierId,
        category: widget.category,
      )));
    });
  }

  void _showSearchDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Zoeken - binnenkort beschikbaar')),
    );
  }
}
