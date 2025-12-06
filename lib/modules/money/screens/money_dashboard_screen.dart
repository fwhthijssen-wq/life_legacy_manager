// lib/modules/money/screens/money_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/widgets.dart';
import '../../../widgets/dossier_app_bar.dart';
import '../models/money_item_model.dart';
import '../providers/money_providers.dart';
import 'bank_accounts/bank_accounts_list_screen.dart';
import 'insurances/insurances_list_screen.dart';
import 'pensions/pensions_list_screen.dart';
import 'incomes/incomes_list_screen.dart';
import 'expenses/expenses_list_screen.dart';
import 'debts/debts_list_screen.dart';

class MoneyDashboardScreen extends ConsumerWidget {
  final String dossierId;
  final bool embedded;

  const MoneyDashboardScreen({
    super.key,
    required this.dossierId,
    this.embedded = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(moneyDashboardStatsProvider(dossierId));

    final content = statsAsync.when(
      loading: () => const LoadingState(message: 'Laden...'),
      error: (err, _) => ErrorState(
        message: err.toString(),
        onRetry: () => ref.invalidate(moneyDashboardStatsProvider(dossierId)),
      ),
      data: (stats) => RefreshIndicator(
        onRefresh: () async {
          refreshMoneyData(ref, dossierId);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Categorie tiles
            ...MoneyCategory.values.map((category) => CategoryTile(
              item: CategoryItem(
                label: category.label,
                emoji: category.emoji,
                color: _getCategoryColor(category),
                itemCount: stats.categoryCounts[category] ?? 0,
                completenessPercentage: stats.categoryProgress[category] ?? 0,
                isLocked: _isCategoryLocked(category),
                onTap: () => _navigateToCategory(context, category),
              ),
            )),

            const SizedBox(height: 80), // Ruimte voor FAB
          ],
        ),
      ),
    );

    if (embedded) {
      return content;
    }

    return Scaffold(
      appBar: const DossierAppBar(
        title: 'Geldzaken',
      ),
      body: content,
    );
  }

  Color _getCategoryColor(MoneyCategory category) {
    switch (category) {
      case MoneyCategory.bankAccount:
        return Colors.blue;
      case MoneyCategory.insurance:
        return Colors.orange;
      case MoneyCategory.pension:
        return Colors.purple;
      case MoneyCategory.income:
        return Colors.green;
      case MoneyCategory.expense:
        return Colors.red;
      case MoneyCategory.investment:
        return Colors.teal;
      case MoneyCategory.debt:
        return Colors.brown;
    }
  }

  bool _isCategoryLocked(MoneyCategory category) {
    // Alleen beleggingen zijn nog locked
    return category == MoneyCategory.investment;
  }

  void _navigateToCategory(BuildContext context, MoneyCategory category) {
    if (_isCategoryLocked(category)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${category.label} is binnenkort beschikbaar!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    switch (category) {
      case MoneyCategory.bankAccount:
        Navigator.push(context, MaterialPageRoute(builder: (_) => BankAccountsListScreen(dossierId: dossierId)));
        break;
      case MoneyCategory.insurance:
        Navigator.push(context, MaterialPageRoute(builder: (_) => InsurancesListScreen(dossierId: dossierId)));
        break;
      case MoneyCategory.pension:
        Navigator.push(context, MaterialPageRoute(builder: (_) => PensionsListScreen(dossierId: dossierId)));
        break;
      case MoneyCategory.income:
        Navigator.push(context, MaterialPageRoute(builder: (_) => IncomesListScreen(dossierId: dossierId)));
        break;
      case MoneyCategory.expense:
        Navigator.push(context, MaterialPageRoute(builder: (_) => ExpensesListScreen(dossierId: dossierId)));
        break;
      case MoneyCategory.debt:
        Navigator.push(context, MaterialPageRoute(builder: (_) => DebtsListScreen(dossierId: dossierId)));
        break;
      default:
        break;
    }
  }
}
