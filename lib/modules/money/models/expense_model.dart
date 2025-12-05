// lib/modules/money/models/expense_model.dart

import 'direct_debit_model.dart' show PaymentFrequency;

/// Types vaste lasten
enum ExpenseType {
  mortgage('mortgage', 'Hypotheek', '🏡'),
  rent('rent', 'Huur', '🏠'),
  energy('energy', 'Energie (gas/elektra)', '⚡'),
  water('water', 'Water', '💧'),
  municipalTax('municipal_tax', 'Gemeentelijke belastingen', '🏛️'),
  waterAuthority('water_authority', 'Waterschapsbelasting', '🌊'),
  insurancePremium('insurance_premium', 'Verzekeringspremies', '🛡️'),
  subscription('subscription', 'Abonnementen', '📱'),
  alimonyPaid('alimony_paid', 'Alimentatie (betaald)', '💸'),
  other('other', 'Overige vaste lasten', '📋');

  final String value;
  final String label;
  final String emoji;
  const ExpenseType(this.value, this.label, this.emoji);

  static ExpenseType fromString(String? value) {
    return ExpenseType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => ExpenseType.other,
    );
  }
}

/// Model voor een vaste last/uitgave
class ExpenseModel {
  final String id;
  final String moneyItemId;
  
  // Basisgegevens
  final ExpenseType expenseType;
  final String? creditor; // Aan wie wordt betaald (bedrijfsnaam)
  final double? amount; // Bedrag
  final PaymentFrequency frequency;
  final String? linkedBankAccountId; // Vanaf welke rekening
  final bool isDirectDebit; // Automatische incasso?
  final String? contractNumber; // Contractnummer / klantnummer
  
  // Contract
  final String? contractDuration; // Looptijd contract
  final String? endDate; // Einddatum
  final String? noticePeriod; // Opzegtermijn
  final String? cancellationMethod; // Hoe opzeggen
  
  // Voor nabestaanden
  final bool mustBeCancelled; // Moet worden opgezegd?
  final bool canBeCancelled; // Kan worden opgezegd? (bijv. niet bij hypotheek)
  final String? priority; // Priority (hoog/normaal/laag)
  final String? survivorInstructions;
  
  // Contact
  final String? contactPhone;
  final String? contactEmail;
  final String? website;
  
  // Notities
  final String? notes;

  ExpenseModel({
    required this.id,
    required this.moneyItemId,
    this.expenseType = ExpenseType.other,
    this.creditor,
    this.amount,
    this.frequency = PaymentFrequency.monthly,
    this.linkedBankAccountId,
    this.isDirectDebit = true,
    this.contractNumber,
    this.contractDuration,
    this.endDate,
    this.noticePeriod,
    this.cancellationMethod,
    this.mustBeCancelled = true,
    this.canBeCancelled = true,
    this.priority,
    this.survivorInstructions,
    this.contactPhone,
    this.contactEmail,
    this.website,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'money_item_id': moneyItemId,
      'expense_type': expenseType.value,
      'payee': creditor,
      'amount': amount,
      'frequency': frequency.value,
      'linked_bank_account_id': linkedBankAccountId,
      'is_direct_debit': isDirectDebit ? 1 : 0,
      'contract_number': contractNumber,
      'contract_duration': contractDuration,
      'contract_end_date': endDate,
      'notice_period': noticePeriod,
      'cancellation_method': cancellationMethod,
      'needs_cancellation': mustBeCancelled ? 1 : 0,
      'can_cancel': canBeCancelled ? 1 : 0,
      'priority': priority,
      'notes': notes,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as String,
      moneyItemId: map['money_item_id'] as String,
      expenseType: ExpenseType.fromString(map['expense_type'] as String?),
      creditor: map['payee'] as String?,
      amount: map['amount'] as double?,
      frequency: PaymentFrequency.fromString(map['frequency'] as String?),
      linkedBankAccountId: map['linked_bank_account_id'] as String?,
      isDirectDebit: map['is_direct_debit'] == 1,
      contractNumber: map['contract_number'] as String?,
      contractDuration: map['contract_duration'] as String?,
      endDate: map['contract_end_date'] as String?,
      noticePeriod: map['notice_period'] as String?,
      cancellationMethod: map['cancellation_method'] as String?,
      mustBeCancelled: map['needs_cancellation'] == 1,
      canBeCancelled: map['can_cancel'] == 1,
      priority: map['priority'] as String?,
      survivorInstructions: null, // Not in DB
      contactPhone: null, // Not in DB
      contactEmail: null, // Not in DB
      website: null, // Not in DB
      notes: map['notes'] as String?,
    );
  }

  /// Bereken maandelijks bedrag
  double get monthlyAmount {
    if (amount == null) return 0;
    switch (frequency) {
      case PaymentFrequency.weekly:
        return amount! * 4.33;
      case PaymentFrequency.monthly:
        return amount!;
      case PaymentFrequency.quarterly:
        return amount! / 3;
      case PaymentFrequency.yearly:
        return amount! / 12;
      default:
        return amount!;
    }
  }

  /// Bereken volledigheidspercentage
  int get completenessPercentage {
    int filled = 0;
    const int total = 8;
    
    if (expenseType != ExpenseType.other) filled++;
    if (creditor?.isNotEmpty == true) filled++;
    if (amount != null && amount! > 0) filled++;
    if (linkedBankAccountId?.isNotEmpty == true) filled++;
    if (noticePeriod?.isNotEmpty == true || cancellationMethod?.isNotEmpty == true) filled++;
    if (mustBeCancelled || !canBeCancelled) filled++; // Nagedacht over nabestaanden
    if (survivorInstructions?.isNotEmpty == true) filled++;
    if (notes?.isNotEmpty == true) filled++;
    
    return ((filled / total) * 100).round();
  }
}

