// lib/modules/money/models/money_item_model.dart

/// Status van een geldzaken item
enum MoneyItemStatus {
  notStarted('not_started', 'Niet begonnen'),
  partial('partial', 'Bezig'),
  complete('complete', 'Compleet');

  final String value;
  final String label;
  const MoneyItemStatus(this.value, this.label);

  static MoneyItemStatus fromString(String? value) {
    return MoneyItemStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => MoneyItemStatus.notStarted,
    );
  }
}

/// Categorieën binnen Geldzaken
enum MoneyCategory {
  bankAccount('bank_account', 'Bankrekeningen', '🏦'),
  insurance('insurance', 'Verzekeringen', '🛡️'),
  pension('pension', 'Pensioen', '👴'),
  income('income', 'Inkomsten', '💵'),
  expense('expense', 'Vaste lasten', '📋'),
  investment('investment', 'Beleggingen', '📈'),
  debt('debt', 'Schulden & Leningen', '💳');

  final String value;
  final String label;
  final String emoji;
  const MoneyCategory(this.value, this.label, this.emoji);

  static MoneyCategory fromString(String? value) {
    return MoneyCategory.values.firstWhere(
      (c) => c.value == value,
      orElse: () => MoneyCategory.bankAccount,
    );
  }
}

/// Basis model voor alle geldzaken items
class MoneyItemModel {
  final String id;
  final String dossierId;
  final String personId;
  final MoneyCategory category;
  final String type;
  final String? name;
  final MoneyItemStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MoneyItemModel({
    required this.id,
    required this.dossierId,
    required this.personId,
    required this.category,
    required this.type,
    this.name,
    this.status = MoneyItemStatus.notStarted,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dossier_id': dossierId,
      'person_id': personId,
      'category': category.value,
      'type': type,
      'name': name,
      'status': status.value,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory MoneyItemModel.fromMap(Map<String, dynamic> map) {
    return MoneyItemModel(
      id: map['id'] as String,
      dossierId: map['dossier_id'] as String,
      personId: map['person_id'] as String,
      category: MoneyCategory.fromString(map['category'] as String?),
      type: map['type'] as String,
      name: map['name'] as String?,
      status: MoneyItemStatus.fromString(map['status'] as String?),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  MoneyItemModel copyWith({
    String? name,
    MoneyItemStatus? status,
    DateTime? updatedAt,
  }) {
    return MoneyItemModel(
      id: id,
      dossierId: dossierId,
      personId: personId,
      category: category,
      type: type,
      name: name ?? this.name,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

