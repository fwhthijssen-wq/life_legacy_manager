// lib/modules/money/models/debt_model.dart

import 'direct_debit_model.dart' show PaymentFrequency;

/// Types schulden/leningen
enum DebtType {
  mortgage('mortgage', 'Hypotheek', '🏡'),
  personalLoan('personal_loan', 'Persoonlijke lening', '💰'),
  revolvingCredit('revolving_credit', 'Doorlopend krediet', '🔄'),
  creditCard('credit_card', 'Creditcard', '💳'),
  studentLoan('student_loan', 'Studieschuld', '🎓'),
  privateLoan('private_loan', 'Lening van particulier', '🤝'),
  other('other', 'Overige schulden', '📋');

  final String value;
  final String label;
  final String emoji;
  const DebtType(this.value, this.label, this.emoji);

  static DebtType fromString(String? value) {
    return DebtType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => DebtType.other,
    );
  }
}

/// Aflossingsschema
enum RepaymentType {
  annuity('annuity', 'Annuïteit'),
  linear('linear', 'Lineair'),
  interestOnly('interest_only', 'Aflossingsvrij'),
  bullet('bullet', 'Aflossing aan einde looptijd');

  final String value;
  final String label;
  const RepaymentType(this.value, this.label);

  static RepaymentType fromString(String? value) {
    return RepaymentType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => RepaymentType.annuity,
    );
  }
}

/// Model voor een schuld/lening
class DebtModel {
  final String id;
  final String moneyItemId;
  
  // Basisgegevens
  final DebtType debtType;
  final String? creditor; // Schuldeiser (naam instelling/persoon)
  final String? contractNumber; // Contractnummer / dossiernummer
  final double? originalAmount; // Oorspronkelijk bedrag
  final double? currentBalance; // Huidig openstaand bedrag
  final RepaymentType repaymentType; // Aflossingsschema
  final String? duration; // Looptijd
  final String? startDate; // Ingangsdatum
  final String? endDate; // Aflosdatum
  
  // Financieel
  final double? monthlyPayment; // Maandelijkse termijn
  final double? interestRate; // Rentepercentage
  final String? fixedRateUntil; // Rentevaste periode (tot datum)
  final double? earlyRepaymentPenalty; // Boeterente bij vervroegd aflossen
  final String? linkedBankAccountId; // Betaald vanaf rekening
  
  // Onderpand
  final bool hasCollateral; // Is er onderpand?
  final String? collateralDescription; // Omschrijving onderpand
  
  // Voor nabestaanden
  final String? deathAction; // Wat gebeurt bij overlijden?
  final bool hasLinkedInsurance; // Is er een gekoppelde verzekering?
  final String? linkedInsuranceId; // Link naar verzekering (overlijdensrisico)
  final String? survivorInstructions; // Speciale afspraken
  
  // Contact
  final String? contactPhone;
  final String? contactEmail;
  final String? website;
  
  // Notities
  final String? notes;

  DebtModel({
    required this.id,
    required this.moneyItemId,
    this.debtType = DebtType.other,
    this.creditor,
    this.contractNumber,
    this.originalAmount,
    this.currentBalance,
    this.repaymentType = RepaymentType.annuity,
    this.duration,
    this.startDate,
    this.endDate,
    this.monthlyPayment,
    this.interestRate,
    this.fixedRateUntil,
    this.earlyRepaymentPenalty,
    this.linkedBankAccountId,
    this.hasCollateral = false,
    this.collateralDescription,
    this.deathAction,
    this.hasLinkedInsurance = false,
    this.linkedInsuranceId,
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
      'debt_type': debtType.value,
      'creditor': creditor,
      'contract_number': contractNumber,
      'original_amount': originalAmount,
      'current_amount': currentBalance,
      'repayment_type': repaymentType.value,
      'duration': duration,
      'start_date': startDate,
      'end_date': endDate,
      'monthly_payment': monthlyPayment,
      'interest_rate': interestRate,
      'fixed_rate_until': fixedRateUntil,
      'early_repayment_penalty': earlyRepaymentPenalty,
      'linked_bank_account_id': linkedBankAccountId,
      'has_collateral': hasCollateral ? 1 : 0,
      'collateral_description': collateralDescription,
      'death_action': deathAction,
      'linked_insurance_id': linkedInsuranceId,
      'special_arrangements': survivorInstructions,
      'notes': notes,
    };
  }

  factory DebtModel.fromMap(Map<String, dynamic> map) {
    return DebtModel(
      id: map['id'] as String,
      moneyItemId: map['money_item_id'] as String,
      debtType: DebtType.fromString(map['debt_type'] as String?),
      creditor: map['creditor'] as String?,
      contractNumber: map['contract_number'] as String?,
      originalAmount: map['original_amount'] as double?,
      currentBalance: map['current_amount'] as double?,
      repaymentType: RepaymentType.fromString(map['repayment_type'] as String?),
      duration: map['duration'] as String?,
      startDate: map['start_date'] as String?,
      endDate: map['end_date'] as String?,
      monthlyPayment: map['monthly_payment'] as double?,
      interestRate: map['interest_rate'] as double?,
      fixedRateUntil: map['fixed_rate_until'] as String?,
      earlyRepaymentPenalty: map['early_repayment_penalty'] as double?,
      linkedBankAccountId: map['linked_bank_account_id'] as String?,
      hasCollateral: map['has_collateral'] == 1,
      collateralDescription: map['collateral_description'] as String?,
      deathAction: map['death_action'] as String?,
      hasLinkedInsurance: map['linked_insurance_id'] != null,
      linkedInsuranceId: map['linked_insurance_id'] as String?,
      survivorInstructions: map['special_arrangements'] as String?,
      contactPhone: null, // Not in DB
      contactEmail: null, // Not in DB
      website: null, // Not in DB
      notes: map['notes'] as String?,
    );
  }

  /// Bereken volledigheidspercentage
  int get completenessPercentage {
    int filled = 0;
    const int total = 10;
    
    if (debtType != DebtType.other) filled++;
    if (creditor?.isNotEmpty == true) filled++;
    if (originalAmount != null || currentBalance != null) filled++;
    if (monthlyPayment != null) filled++;
    if (interestRate != null) filled++;
    if (startDate?.isNotEmpty == true) filled++;
    if (linkedBankAccountId?.isNotEmpty == true) filled++;
    if (deathAction?.isNotEmpty == true) filled++; // Nagedacht over nabestaanden
    if (survivorInstructions?.isNotEmpty == true) filled++;
    if (notes?.isNotEmpty == true) filled++;
    
    return ((filled / total) * 100).round();
  }
}

