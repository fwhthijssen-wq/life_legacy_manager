// lib/core/premium/premium_dialogs.dart

import 'package:flutter/material.dart';
import 'premium_features.dart';
import 'premium_service.dart';

/// Toon een upgrade dialog wanneer een premium feature wordt geblokkeerd
class PremiumDialogs {
  /// Toon feature-specifieke upgrade dialog
  static Future<bool?> showFeatureDialog(
    BuildContext context,
    PremiumFeature feature,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (context) => _FeatureUpgradeDialog(feature: feature),
    );
  }

  /// Toon limiet bereikt dialog
  static Future<bool?> showLimitDialog(
    BuildContext context, {
    required String itemType,
    required int currentCount,
    required int limit,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => _LimitUpgradeDialog(
        itemType: itemType,
        currentCount: currentCount,
        limit: limit,
      ),
    );
  }

  /// Toon volledige premium pagina
  static Future<bool?> showPremiumPage(BuildContext context) {
    return Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const PremiumUpgradeScreen(),
      ),
    );
  }
}

/// Dialog voor een specifieke feature
class _FeatureUpgradeDialog extends StatelessWidget {
  final PremiumFeature feature;

  const _FeatureUpgradeDialog({required this.feature});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.workspace_premium, size: 48, color: Colors.amber),
      title: const Text('Premium functie'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            feature.displayName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            feature.description,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Upgrade naar Premium om deze functie te gebruiken',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Later'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context, true);
            PremiumDialogs.showPremiumPage(context);
          },
          icon: const Icon(Icons.star),
          label: const Text('Bekijk Premium'),
        ),
      ],
    );
  }
}

/// Dialog voor limiet bereikt
class _LimitUpgradeDialog extends StatelessWidget {
  final String itemType;
  final int currentCount;
  final int limit;

  const _LimitUpgradeDialog({
    required this.itemType,
    required this.currentCount,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.block, size: 48, color: Colors.orange),
      title: const Text('Limiet bereikt'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Je hebt het maximum aantal $itemType bereikt',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          // Progress indicator
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$currentCount van $limit'),
                  const Text('100%', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 1.0,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.orange),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.all_inclusive, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Met Premium: onbeperkt $itemType',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Sluiten'),
        ),
        FilledButton.icon(
          onPressed: () {
            Navigator.pop(context, true);
            PremiumDialogs.showPremiumPage(context);
          },
          icon: const Icon(Icons.star),
          label: const Text('Upgrade'),
        ),
      ],
    );
  }
}

/// Volledige Premium upgrade pagina
class PremiumUpgradeScreen extends StatelessWidget {
  const PremiumUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium'),
        backgroundColor: Colors.amber.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.amber.shade700, Colors.amber.shade500],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.workspace_premium,
                    size: 80,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Levenskompas Premium',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ontgrendel alle functies',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            // Features lijst
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wat krijg je met Premium?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildFeatureItem(Icons.all_inclusive, 'Onbeperkt contacten, personen en dossiers'),
                  _buildFeatureItem(Icons.email, 'Bulk email versturen'),
                  _buildFeatureItem(Icons.picture_as_pdf, 'PDF adreslijsten genereren'),
                  _buildFeatureItem(Icons.print, 'Adresstickers printen'),
                  _buildFeatureItem(Icons.download, 'Import van Google, Outlook, CSV'),
                  _buildFeatureItem(Icons.upload, 'Export naar CSV en vCard'),
                  _buildFeatureItem(Icons.article, 'Email templates'),
                  _buildFeatureItem(Icons.cloud_upload, 'Cloud backup'),
                  _buildFeatureItem(Icons.support_agent, 'Prioriteit support'),
                  
                  const SizedBox(height: 32),
                  
                  // Prijzen
                  Text(
                    'Kies je plan',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _PlanCard(
                    plan: PremiumPlan.monthly,
                    isPopular: false,
                    onTap: () => _handlePurchase(context, PremiumPlan.monthly),
                  ),
                  const SizedBox(height: 12),
                  _PlanCard(
                    plan: PremiumPlan.yearly,
                    isPopular: true,
                    onTap: () => _handlePurchase(context, PremiumPlan.yearly),
                  ),
                  const SizedBox(height: 12),
                  _PlanCard(
                    plan: PremiumPlan.lifetime,
                    isPopular: false,
                    onTap: () => _handlePurchase(context, PremiumPlan.lifetime),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Disclaimer
                  Text(
                    'Abonnementen worden automatisch verlengd tenzij je opzegt. '
                    'Je kunt op elk moment opzeggen in je app store instellingen.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  void _handlePurchase(BuildContext context, PremiumPlan plan) async {
    // TODO: Koppel aan echte in-app purchase
    // Voor nu: toon bevestiging en activeer lokaal
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${plan.displayName} activeren'),
        content: Text(
          'Dit is een demo. In de echte app wordt je doorgestuurd naar de app store.\n\n'
          'Prijs: €${plan.price.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Activeren (demo)'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await PremiumService.activatePremium(plan);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Premium ${plan.displayName} geactiveerd!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    }
  }
}

/// Plan kaart widget
class _PlanCard extends StatelessWidget {
  final PremiumPlan plan;
  final bool isPopular;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isPopular,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: isPopular ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPopular 
            ? const BorderSide(color: Colors.amber, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Plan info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'POPULAIR',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (plan == PremiumPlan.yearly)
                      Text(
                        'Bespaar ${plan.yearlySavings.toInt()}%!',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Prijs
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '€${plan.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade700,
                    ),
                  ),
                  Text(
                    plan == PremiumPlan.monthly ? '/maand' :
                    plan == PremiumPlan.yearly ? '/jaar' : 'eenmalig',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}







