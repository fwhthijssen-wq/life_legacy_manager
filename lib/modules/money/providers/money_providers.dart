// lib/modules/money/providers/money_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/money_item_model.dart';
import '../models/bank_account_model.dart';
import '../models/money_document_model.dart';
import '../models/direct_debit_model.dart';
import '../repositories/money_repository.dart';

/// Provider voor items per categorie
final moneyItemsByCategoryProvider = FutureProvider.family<List<MoneyItemModel>, ({String dossierId, MoneyCategory category})>((ref, params) async {
  return await MoneyRepository.getItemsByCategory(params.dossierId, params.category);
});

/// Provider voor aantal items per categorie
final moneyCategoryCountsProvider = FutureProvider.family<Map<MoneyCategory, int>, String>((ref, dossierId) async {
  return await MoneyRepository.countByCategory(dossierId);
});

/// Provider voor voortgang per categorie (0-100%)
final moneyCategoryProgressProvider = FutureProvider.family<Map<MoneyCategory, double>, String>((ref, dossierId) async {
  return await MoneyRepository.progressByCategory(dossierId);
});

/// Provider voor alle bankrekeningen van een dossier
final bankAccountsProvider = FutureProvider.family<List<BankAccountModel>, String>((ref, dossierId) async {
  return await MoneyRepository.getBankAccountsForDossier(dossierId);
});

/// Provider voor één bankrekening (via money_item_id)
final bankAccountProvider = FutureProvider.family<BankAccountModel?, String>((ref, moneyItemId) async {
  return await MoneyRepository.getBankAccount(moneyItemId);
});

/// Provider voor documenten van een money item
final moneyDocumentsProvider = FutureProvider.family<List<MoneyDocumentModel>, String>((ref, moneyItemId) async {
  return await MoneyRepository.getDocuments(moneyItemId);
});

/// Provider voor automatische incasso's van een bankrekening
final directDebitsProvider = FutureProvider.family<List<DirectDebitModel>, String>((ref, bankAccountId) async {
  return await MoneyRepository.getDirectDebits(bankAccountId);
});

/// Provider voor totaal saldo
final totalBankBalanceProvider = FutureProvider.family<double, String>((ref, dossierId) async {
  return await MoneyRepository.getTotalBankBalance(dossierId);
});

/// Provider voor totaal maandelijkse incasso's
final totalMonthlyDirectDebitsProvider = FutureProvider.family<double, String>((ref, dossierId) async {
  return await MoneyRepository.getTotalMonthlyDirectDebits(dossierId);
});

/// Refresh provider voor geldzaken data
final moneyRefreshProvider = StateProvider<int>((ref) => 0);

/// Helper om alle geldzaken data te refreshen
void refreshMoneyData(WidgetRef ref, String dossierId) {
  ref.read(moneyRefreshProvider.notifier).state++;
  ref.invalidate(moneyCategoryCountsProvider(dossierId));
  ref.invalidate(moneyCategoryProgressProvider(dossierId));
  ref.invalidate(bankAccountsProvider(dossierId));
  ref.invalidate(totalBankBalanceProvider(dossierId));
  ref.invalidate(totalMonthlyDirectDebitsProvider(dossierId));
}

/// Statistieken model voor geldzaken dashboard
class MoneyDashboardStats {
  final int totalItems;
  final int completeItems;
  final double overallProgress;
  final Map<MoneyCategory, int> categoryCounts;
  final Map<MoneyCategory, double> categoryProgress;

  MoneyDashboardStats({
    required this.totalItems,
    required this.completeItems,
    required this.overallProgress,
    required this.categoryCounts,
    required this.categoryProgress,
  });
}

/// Provider voor dashboard statistieken
final moneyDashboardStatsProvider = FutureProvider.family<MoneyDashboardStats, String>((ref, dossierId) async {
  final counts = await MoneyRepository.countByCategory(dossierId);
  final progress = await MoneyRepository.progressByCategory(dossierId);

  int totalItems = 0;
  double totalProgress = 0;
  int categoriesWithItems = 0;

  for (final cat in MoneyCategory.values) {
    final count = counts[cat] ?? 0;
    totalItems += count;
    if (count > 0) {
      totalProgress += progress[cat] ?? 0;
      categoriesWithItems++;
    }
  }

  final overallProgress = categoriesWithItems > 0 ? totalProgress / categoriesWithItems : 0.0;
  final completeItems = (totalItems * (overallProgress / 100)).round();

  return MoneyDashboardStats(
    totalItems: totalItems,
    completeItems: completeItems,
    overallProgress: overallProgress,
    categoryCounts: counts,
    categoryProgress: progress,
  );
});








