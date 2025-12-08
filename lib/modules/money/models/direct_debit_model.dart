// lib/modules/money/models/direct_debit_model.dart

/// Frequentie van automatische incasso
enum PaymentFrequency {
  weekly('weekly', 'Wekelijks'),
  monthly('monthly', 'Maandelijks'),
  quarterly('quarterly', 'Per kwartaal'),
  yearly('yearly', 'Jaarlijks'),
  once('once', 'Eenmalig'),
  irregular('irregular', 'Onregelmatig');

  final String value;
  final String label;
  const PaymentFrequency(this.value, this.label);

  static PaymentFrequency fromString(String? value) {
    return PaymentFrequency.values.firstWhere(
      (f) => f.value == value,
      orElse: () => PaymentFrequency.monthly,
    );
  }

  /// Bereken maandelijks equivalent
  double toMonthlyAmount(double amount) {
    switch (this) {
      case PaymentFrequency.weekly:
        return amount * 4.33;
      case PaymentFrequency.monthly:
        return amount;
      case PaymentFrequency.quarterly:
        return amount / 3;
      case PaymentFrequency.yearly:
        return amount / 12;
      case PaymentFrequency.once:
      case PaymentFrequency.irregular:
        return 0;
    }
  }
}

/// Model voor automatische incasso's
class DirectDebitModel {
  final String id;
  final String bankAccountId;
  final String description;
  final double? amount;
  final PaymentFrequency frequency;
  final String? beneficiary;
  final DateTime createdAt;

  DirectDebitModel({
    required this.id,
    required this.bankAccountId,
    required this.description,
    this.amount,
    this.frequency = PaymentFrequency.monthly,
    this.beneficiary,
    required this.createdAt,
  });

  /// Bereken maandelijks bedrag
  double get monthlyAmount {
    if (amount == null) return 0;
    return frequency.toMonthlyAmount(amount!);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bank_account_id': bankAccountId,
      'description': description,
      'amount': amount,
      'frequency': frequency.value,
      'beneficiary': beneficiary,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory DirectDebitModel.fromMap(Map<String, dynamic> map) {
    return DirectDebitModel(
      id: map['id'] as String,
      bankAccountId: map['bank_account_id'] as String,
      description: map['description'] as String,
      amount: map['amount'] as double?,
      frequency: PaymentFrequency.fromString(map['frequency'] as String?),
      beneficiary: map['beneficiary'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  DirectDebitModel copyWith({
    String? description,
    double? amount,
    PaymentFrequency? frequency,
    String? beneficiary,
  }) {
    return DirectDebitModel(
      id: id,
      bankAccountId: bankAccountId,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      frequency: frequency ?? this.frequency,
      beneficiary: beneficiary ?? this.beneficiary,
      createdAt: createdAt,
    );
  }
}








