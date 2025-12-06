// lib/modules/housing/models/mortgage_model.dart
// Model voor hypotheek

import 'housing_enums.dart';

class MortgageModel {
  final String id;
  final String propertyId;
  
  // Basisgegevens (Tab 1)
  final String? provider; // Hypotheekverstrekker
  final String? advisorName;
  final String? advisorCompany;
  final String? advisorPhone;
  final String? advisorEmail;
  final String? notaryName;
  final String? notaryOffice;
  final String? notaryAddress;
  final String? notaryPhone;
  final String? mortgageNumber;
  final String? closingDate; // Datum afsluiting
  final String? deliveryDate; // Datum levering woning
  
  // Gekoppelde producten (Tab 3)
  final bool hasLifeInsurance; // Overlijdensrisicoverzekering
  final String? lifeInsuranceProvider;
  final String? lifeInsurancePolicyNumber;
  final double? lifeInsuranceAmount;
  final String? lifeInsuranceLinkId; // Link naar Geldzaken
  final bool hasDisabilityInsurance;
  final String? disabilityInsuranceLinkId;
  final bool hasNhg; // Nationale Hypotheek Garantie
  final String? nhgNumber;
  
  // Betaling (Tab 4)
  final String? paymentBankAccountId; // Link naar bankrekening
  final int? paymentDay; // Dag van de maand
  
  // Boetes & Voorwaarden (Tab 5)
  final double? earlyRepaymentPenaltyPercentage;
  final double? earlyRepaymentPenaltyAmount;
  final double? maxYearlyRepaymentWithoutPenalty;
  final bool canRenegotiateRate;
  final String? renegotiationDate;
  final String? switchConsiderationNote;
  
  // Voor nabestaanden (Tab 6)
  final String? deathCoverage; // Volledig/Gedeeltelijk/Niet gedekt
  final double? deathCoverageAmount;
  final String? deathContactProvider;
  final String? deathContactPhone;
  final String? deathClaimInsurer;
  final String? deathClaimPhone;
  final String? deathSpecialInstructions;
  
  // Contact (Tab 7)
  final String? servicePhone;
  final String? serviceEmail;
  final String? serviceWebsite;
  final String? portalUrl;
  
  // Notities
  final String? notes;
  
  // Status & timestamps
  final HousingItemStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MortgageModel({
    required this.id,
    required this.propertyId,
    this.provider,
    this.advisorName,
    this.advisorCompany,
    this.advisorPhone,
    this.advisorEmail,
    this.notaryName,
    this.notaryOffice,
    this.notaryAddress,
    this.notaryPhone,
    this.mortgageNumber,
    this.closingDate,
    this.deliveryDate,
    this.hasLifeInsurance = false,
    this.lifeInsuranceProvider,
    this.lifeInsurancePolicyNumber,
    this.lifeInsuranceAmount,
    this.lifeInsuranceLinkId,
    this.hasDisabilityInsurance = false,
    this.disabilityInsuranceLinkId,
    this.hasNhg = false,
    this.nhgNumber,
    this.paymentBankAccountId,
    this.paymentDay,
    this.earlyRepaymentPenaltyPercentage,
    this.earlyRepaymentPenaltyAmount,
    this.maxYearlyRepaymentWithoutPenalty,
    this.canRenegotiateRate = false,
    this.renegotiationDate,
    this.switchConsiderationNote,
    this.deathCoverage,
    this.deathCoverageAmount,
    this.deathContactProvider,
    this.deathContactPhone,
    this.deathClaimInsurer,
    this.deathClaimPhone,
    this.deathSpecialInstructions,
    this.servicePhone,
    this.serviceEmail,
    this.serviceWebsite,
    this.portalUrl,
    this.notes,
    this.status = HousingItemStatus.notStarted,
    required this.createdAt,
    this.updatedAt,
  });

  String get displayName => provider ?? 'Hypotheek';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'provider': provider,
      'advisor_name': advisorName,
      'advisor_company': advisorCompany,
      'advisor_phone': advisorPhone,
      'advisor_email': advisorEmail,
      'notary_name': notaryName,
      'notary_office': notaryOffice,
      'notary_address': notaryAddress,
      'notary_phone': notaryPhone,
      'mortgage_number': mortgageNumber,
      'closing_date': closingDate,
      'delivery_date': deliveryDate,
      'has_life_insurance': hasLifeInsurance ? 1 : 0,
      'life_insurance_provider': lifeInsuranceProvider,
      'life_insurance_policy_number': lifeInsurancePolicyNumber,
      'life_insurance_amount': lifeInsuranceAmount,
      'life_insurance_link_id': lifeInsuranceLinkId,
      'has_disability_insurance': hasDisabilityInsurance ? 1 : 0,
      'disability_insurance_link_id': disabilityInsuranceLinkId,
      'has_nhg': hasNhg ? 1 : 0,
      'nhg_number': nhgNumber,
      'payment_bank_account_id': paymentBankAccountId,
      'payment_day': paymentDay,
      'early_repayment_penalty_pct': earlyRepaymentPenaltyPercentage,
      'early_repayment_penalty_amount': earlyRepaymentPenaltyAmount,
      'max_yearly_repayment_no_penalty': maxYearlyRepaymentWithoutPenalty,
      'can_renegotiate_rate': canRenegotiateRate ? 1 : 0,
      'renegotiation_date': renegotiationDate,
      'switch_consideration_note': switchConsiderationNote,
      'death_coverage': deathCoverage,
      'death_coverage_amount': deathCoverageAmount,
      'death_contact_provider': deathContactProvider,
      'death_contact_phone': deathContactPhone,
      'death_claim_insurer': deathClaimInsurer,
      'death_claim_phone': deathClaimPhone,
      'death_special_instructions': deathSpecialInstructions,
      'service_phone': servicePhone,
      'service_email': serviceEmail,
      'service_website': serviceWebsite,
      'portal_url': portalUrl,
      'notes': notes,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory MortgageModel.fromMap(Map<String, dynamic> map) {
    return MortgageModel(
      id: map['id'] as String,
      propertyId: map['property_id'] as String,
      provider: map['provider'] as String?,
      advisorName: map['advisor_name'] as String?,
      advisorCompany: map['advisor_company'] as String?,
      advisorPhone: map['advisor_phone'] as String?,
      advisorEmail: map['advisor_email'] as String?,
      notaryName: map['notary_name'] as String?,
      notaryOffice: map['notary_office'] as String?,
      notaryAddress: map['notary_address'] as String?,
      notaryPhone: map['notary_phone'] as String?,
      mortgageNumber: map['mortgage_number'] as String?,
      closingDate: map['closing_date'] as String?,
      deliveryDate: map['delivery_date'] as String?,
      hasLifeInsurance: map['has_life_insurance'] == 1,
      lifeInsuranceProvider: map['life_insurance_provider'] as String?,
      lifeInsurancePolicyNumber: map['life_insurance_policy_number'] as String?,
      lifeInsuranceAmount: map['life_insurance_amount'] as double?,
      lifeInsuranceLinkId: map['life_insurance_link_id'] as String?,
      hasDisabilityInsurance: map['has_disability_insurance'] == 1,
      disabilityInsuranceLinkId: map['disability_insurance_link_id'] as String?,
      hasNhg: map['has_nhg'] == 1,
      nhgNumber: map['nhg_number'] as String?,
      paymentBankAccountId: map['payment_bank_account_id'] as String?,
      paymentDay: map['payment_day'] as int?,
      earlyRepaymentPenaltyPercentage: map['early_repayment_penalty_pct'] as double?,
      earlyRepaymentPenaltyAmount: map['early_repayment_penalty_amount'] as double?,
      maxYearlyRepaymentWithoutPenalty: map['max_yearly_repayment_no_penalty'] as double?,
      canRenegotiateRate: map['can_renegotiate_rate'] == 1,
      renegotiationDate: map['renegotiation_date'] as String?,
      switchConsiderationNote: map['switch_consideration_note'] as String?,
      deathCoverage: map['death_coverage'] as String?,
      deathCoverageAmount: map['death_coverage_amount'] as double?,
      deathContactProvider: map['death_contact_provider'] as String?,
      deathContactPhone: map['death_contact_phone'] as String?,
      deathClaimInsurer: map['death_claim_insurer'] as String?,
      deathClaimPhone: map['death_claim_phone'] as String?,
      deathSpecialInstructions: map['death_special_instructions'] as String?,
      servicePhone: map['service_phone'] as String?,
      serviceEmail: map['service_email'] as String?,
      serviceWebsite: map['service_website'] as String?,
      portalUrl: map['portal_url'] as String?,
      notes: map['notes'] as String?,
      status: HousingItemStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => HousingItemStatus.notStarted,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }
}

/// Hypotheekdeel (een hypotheek kan meerdere delen hebben)
class MortgagePartModel {
  final String id;
  final String mortgageId;
  final MortgageType type;
  final double? originalAmount;
  final double? currentBalance;
  final double? monthlyPayment;
  final double? interestRate;
  final String? fixedRateUntil;
  final String? endDate;
  final int? durationYears;

  MortgagePartModel({
    required this.id,
    required this.mortgageId,
    this.type = MortgageType.annuity,
    this.originalAmount,
    this.currentBalance,
    this.monthlyPayment,
    this.interestRate,
    this.fixedRateUntil,
    this.endDate,
    this.durationYears,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mortgage_id': mortgageId,
      'type': type.name,
      'original_amount': originalAmount,
      'current_balance': currentBalance,
      'monthly_payment': monthlyPayment,
      'interest_rate': interestRate,
      'fixed_rate_until': fixedRateUntil,
      'end_date': endDate,
      'duration_years': durationYears,
    };
  }

  factory MortgagePartModel.fromMap(Map<String, dynamic> map) {
    return MortgagePartModel(
      id: map['id'] as String,
      mortgageId: map['mortgage_id'] as String,
      type: MortgageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MortgageType.annuity,
      ),
      originalAmount: map['original_amount'] as double?,
      currentBalance: map['current_balance'] as double?,
      monthlyPayment: map['monthly_payment'] as double?,
      interestRate: map['interest_rate'] as double?,
      fixedRateUntil: map['fixed_rate_until'] as String?,
      endDate: map['end_date'] as String?,
      durationYears: map['duration_years'] as int?,
    );
  }
}






