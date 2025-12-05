// lib/core/models/module_stats.dart
// Statistieken model voor modules

/// Statistieken voor een module op het dashboard
class ModuleStats {
  final int totalItems;
  final int completedItems;
  final int averagePercentage;

  const ModuleStats({
    required this.totalItems,
    required this.completedItems,
    required this.averagePercentage,
  });

  /// Percentage items dat volledig is ingevuld (>=80%)
  double get completionRate => 
      totalItems > 0 ? (completedItems / totalItems) * 100 : 0;
  
  /// Is de module leeg?
  bool get isEmpty => totalItems == 0;
}

