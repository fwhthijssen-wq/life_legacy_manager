// lib/modules/money/models/income_model.dart

import 'direct_debit_model.dart' show PaymentFrequency;

/// Types inkomsten
enum IncomeType {
  salary('salary', 'Salaris', '💼'),
  pensionPayout('pension_payout', 'Pensioenuitkering', '👴'),
  benefit('benefit', 'Uitkering (WW, WIA, etc.)', '🏛️'),
  rental('rental', 'Huurinkomsten', '🏠'),
  dividend('dividend', 'Dividenden/beleggingen', '📈'),
  alimony('alimony', 'Alimentatie (ontvangen)', '💵'),
  other('other', 'Overige inkomsten', '📋');

  final String value;
  final String label;
  final String emoji;
  const IncomeType(this.value, this.label, this.emoji);

  static IncomeType fromString(String? value) {
    return IncomeType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => IncomeType.other,
    );
  }
}

/// Model voor een inkomstenbron
class IncomeModel {
  final String id;
  final String moneyItemId;
  
  // Basisgegevens
  final IncomeType incomeType;
  final String? source; // Bron (werkgever, UWV, SVB, huurder, etc.)
  final double? amountGross; // Bedrag bruto
  final double? amountNet; // Bedrag netto
  final PaymentFrequency frequency;
  final String? startDate; // Ingangsdatum
  final String? endDate; // Einddatum (indien bekend)
  final String? linkedBankAccountId; // Op welke rekening komt het binnen
  
  // Voor nabestaanden
  final bool stopsOnDeath; // Stopt bij overlijden?
  final bool needsCancellation; // Moet worden opgezegd/gemeld?
  final String? cancellationContact; // Contactgegevens voor melding
  final String? cancellationPhone;
  final String? cancellationEmail;
  final String? survivorInstructions; // Speciale instructies
  
  // Notities
  final String? notes;

  IncomeModel({
    required this.id,
    required this.moneyItemId,
    this.incomeType = IncomeType.other,
    this.source,
    this.amountGross,
    this.amountNet,
    this.frequency = PaymentFrequency.monthly,
    this.startDate,
    this.endDate,
    this.linkedBankAccountId,
    this.stopsOnDeath = true,
    this.needsCancellation = true,
    this.cancellationContact,
    this.cancellationPhone,
    this.cancellationEmail,
    this.survivorInstructions,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'money_item_id': moneyItemId,
      'income_type': incomeType.value,
      'source': source,
      'amount_gross': amountGross,
      'amount_net': amountNet,
      'frequency': frequency.value,
      'start_date': startDate,
      'end_date': endDate,
      'linked_bank_account_id': linkedBankAccountId,
      'stops_on_death': stopsOnDeath ? 1 : 0,
      'needs_notification': needsCancellation ? 1 : 0,
      'notification_contact': cancellationContact,
      'notes': notes,
    };
  }

  factory IncomeModel.fromMap(Map<String, dynamic> map) {
    return IncomeModel(
      id: map['id'] as String,
      moneyItemId: map['money_item_id'] as String,
      incomeType: IncomeType.fromString(map['income_type'] as String?),
      source: map['source'] as String?,
      amountGross: map['amount_gross'] as double?,
      amountNet: map['amount_net'] as double?,
      frequency: PaymentFrequency.fromString(map['frequency'] as String?),
      startDate: map['start_date'] as String?,
      endDate: map['end_date'] as String?,
      linkedBankAccountId: map['linked_bank_account_id'] as String?,
      stopsOnDeath: map['stops_on_death'] == 1,
      needsCancellation: map['needs_notification'] == 1,
      cancellationContact: map['notification_contact'] as String?,
      cancellationPhone: null, // Not in DB
      cancellationEmail: null, // Not in DB  
      survivorInstructions: null, // Not in DB
      notes: map['notes'] as String?,
    );
  }

  IncomeModel copyWith({
    IncomeType? incomeType,
    String? source,
    double? amountGross,
    double? amountNet,
    PaymentFrequency? frequency,
    String? startDate,
    String? endDate,
    String? linkedBankAccountId,
    bool? stopsOnDeath,
    bool? needsCancellation,
    String? cancellationContact,
    String? cancellationPhone,
    String? cancellationEmail,
    String? survivorInstructions,
    String? notes,
  }) {
    return IncomeModel(
      id: id,
      moneyItemId: moneyItemId,
      incomeType: incomeType ?? this.incomeType,
      source: source ?? this.source,
      amountGross: amountGross ?? this.amountGross,
      amountNet: amountNet ?? this.amountNet,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      linkedBankAccountId: linkedBankAccountId ?? this.linkedBankAccountId,
      stopsOnDeath: stopsOnDeath ?? this.stopsOnDeath,
      needsCancellation: needsCancellation ?? this.needsCancellation,
      cancellationContact: cancellationContact ?? this.cancellationContact,
      cancellationPhone: cancellationPhone ?? this.cancellationPhone,
      cancellationEmail: cancellationEmail ?? this.cancellationEmail,
      survivorInstructions: survivorInstructions ?? this.survivorInstructions,
      notes: notes ?? this.notes,
    );
  }

  /// Bereken maandelijks bedrag
  double get monthlyAmountNet {
    if (amountNet == null) return 0;
    switch (frequency) {
      case PaymentFrequency.weekly:
        return amountNet! * 4.33;
      case PaymentFrequency.monthly:
        return amountNet!;
      case PaymentFrequency.quarterly:
        return amountNet! / 3;
      case PaymentFrequency.yearly:
        return amountNet! / 12;
      default:
        return amountNet!;
    }
  }

  /// Bereken volledigheidspercentage
  int get completenessPercentage {
    int filled = 0;
    const int total = 8;
    
    if (incomeType != IncomeType.other) filled++;
    if (source?.isNotEmpty == true) filled++;
    if (amountGross != null || amountNet != null) filled++;
    if (startDate?.isNotEmpty == true) filled++;
    if (linkedBankAccountId?.isNotEmpty == true) filled++;
    if (stopsOnDeath || needsCancellation) filled++; // Nagedacht over nabestaanden
    if (survivorInstructions?.isNotEmpty == true) filled++;
    if (notes?.isNotEmpty == true) filled++;
    
    return ((filled / total) * 100).round();
  }
}

