// lib/modules/money/models/pension_model.dart

import 'direct_debit_model.dart' show PaymentFrequency;

/// Types pensioen
enum PensionType {
  aow('aow', 'AOW (staatspensioen)', '🏛️'),
  employer('employer', 'Werkgeverspensioen', '🏢'),
  annuity('annuity', 'Lijfrente', '📜'),
  private('private', 'Particulier pensioen', '💼'),
  foreign('foreign', 'Buitenlands pensioen', '🌍'),
  other('other', 'Overig pensioen', '📋');

  final String value;
  final String label;
  final String emoji;
  const PensionType(this.value, this.label, this.emoji);

  static PensionType fromString(String? value) {
    return PensionType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => PensionType.other,
    );
  }
}

/// Model voor een pensioenregeling
class PensionModel {
  final String id;
  final String moneyItemId;
  
  // Basisgegevens
  final PensionType pensionType;
  final String? provider; // Pensioenuitvoerder (ABP, PFZW, etc.)
  final String? participantNumber; // Deelnemersnummer
  final String? participantName; // Naam deelnemer
  final String? employer; // Werkgever (indien van toepassing)
  final String? accrualPeriodStart; // Opbouwperiode van
  final String? accrualPeriodEnd; // Opbouwperiode tot
  
  // Pensioenopbouw
  final double? currentCapital; // Huidig opgebouwd kapitaal
  final double? expectedMonthlyPayout; // Verwachte uitkering per maand (bruto)
  final String? pensionStartDate; // Pensioeningangsdatum
  final bool hasPartnerPension; // Partnerpensioen inbegrepen?
  final int? partnerPensionPercentage; // Percentage partnerpensioen
  final String? partnerName; // Partner naam
  final bool hasOrphanPension; // Wezenpensioen inbegrepen?
  final bool hasDisabilityPension; // Arbeidsongeschiktheidspensioen?
  
  // Financieel
  final double? monthlyContribution; // Maandelijkse inleg
  final String? paidBy; // Betaald door (werkgever/zelf)
  final String? taxTreatment; // Fiscale behandeling
  final bool allowsExtraContributions; // Vrijwillige extra stortingen mogelijk?
  
  // Voor nabestaanden
  final bool hasSurvivorPension; // Nabestaandenpensioen (ja/nee)
  final double? survivorPayoutAmount; // Hoogte uitkering partner
  final String? survivorConditions; // Voorwaarden
  final double? surrenderValue; // Afkoopwaarde bij overlijden
  final String? claimContactPerson; // Contact persoon voor claim
  final String? claimContactPhone;
  final String? claimContactEmail;
  final String? survivorInstructions; // Speciale instructies
  
  // Contactgegevens
  final String? servicePhone;
  final String? serviceEmail;
  final String? website;
  final String? portalUrl; // Mijn Pensioen portaal URL
  
  // Notities
  final String? notes;

  PensionModel({
    required this.id,
    required this.moneyItemId,
    this.pensionType = PensionType.other,
    this.provider,
    this.participantNumber,
    this.participantName,
    this.employer,
    this.accrualPeriodStart,
    this.accrualPeriodEnd,
    this.currentCapital,
    this.expectedMonthlyPayout,
    this.pensionStartDate,
    this.hasPartnerPension = false,
    this.partnerPensionPercentage,
    this.partnerName,
    this.hasOrphanPension = false,
    this.hasDisabilityPension = false,
    this.monthlyContribution,
    this.paidBy,
    this.taxTreatment,
    this.allowsExtraContributions = false,
    this.hasSurvivorPension = false,
    this.survivorPayoutAmount,
    this.survivorConditions,
    this.surrenderValue,
    this.claimContactPerson,
    this.claimContactPhone,
    this.claimContactEmail,
    this.survivorInstructions,
    this.servicePhone,
    this.serviceEmail,
    this.website,
    this.portalUrl,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'money_item_id': moneyItemId,
      'pension_type': pensionType.value,
      'provider': provider,
      'participant_number': participantNumber,
      'participant_name': participantName,
      'employer': employer,
      'accrual_period_start': accrualPeriodStart,
      'accrual_period_end': accrualPeriodEnd,
      'current_capital': currentCapital,
      'expected_monthly_benefit': expectedMonthlyPayout,
      'pension_start_date': pensionStartDate,
      'partner_pension': hasPartnerPension ? 1 : 0,
      'partner_pension_percentage': partnerPensionPercentage,
      'partner_id': partnerName,
      'orphan_pension': hasOrphanPension ? 1 : 0,
      'disability_pension': hasDisabilityPension ? 1 : 0,
      'monthly_contribution': monthlyContribution,
      'paid_by': paidBy,
      'voluntary_extra': allowsExtraContributions ? 1 : 0,
      'survivor_pension': hasSurvivorPension ? 1 : 0,
      'survivor_benefit': survivorPayoutAmount,
      'surrender_value': surrenderValue,
      'claim_contact': claimContactPerson,
      'notes': notes,
    };
  }

  factory PensionModel.fromMap(Map<String, dynamic> map) {
    return PensionModel(
      id: map['id'] as String,
      moneyItemId: map['money_item_id'] as String,
      pensionType: PensionType.fromString(map['pension_type'] as String?),
      provider: map['provider'] as String?,
      participantNumber: map['participant_number'] as String?,
      participantName: map['participant_name'] as String?,
      employer: map['employer'] as String?,
      accrualPeriodStart: map['accrual_period_start'] as String?,
      accrualPeriodEnd: map['accrual_period_end'] as String?,
      currentCapital: map['current_capital'] as double?,
      expectedMonthlyPayout: map['expected_monthly_benefit'] as double?,
      pensionStartDate: map['pension_start_date'] as String?,
      hasPartnerPension: map['partner_pension'] == 1,
      partnerPensionPercentage: (map['partner_pension_percentage'] as num?)?.toInt(),
      partnerName: map['partner_id'] as String?,
      hasOrphanPension: map['orphan_pension'] == 1,
      hasDisabilityPension: map['disability_pension'] == 1,
      monthlyContribution: map['monthly_contribution'] as double?,
      paidBy: map['paid_by'] as String?,
      taxTreatment: null, // Not in DB
      allowsExtraContributions: map['voluntary_extra'] == 1,
      hasSurvivorPension: map['survivor_pension'] == 1,
      survivorPayoutAmount: map['survivor_benefit'] as double?,
      survivorConditions: null, // Not in DB
      surrenderValue: map['surrender_value'] as double?,
      claimContactPerson: map['claim_contact'] as String?,
      claimContactPhone: null, // Not in DB
      claimContactEmail: null, // Not in DB
      survivorInstructions: null, // Not in DB
      servicePhone: null, // Not in DB
      serviceEmail: null, // Not in DB
      website: null, // Not in DB
      portalUrl: null, // Not in DB
      notes: map['notes'] as String?,
    );
  }

  PensionModel copyWith({
    PensionType? pensionType,
    String? provider,
    String? participantNumber,
    String? participantName,
    String? employer,
    String? accrualPeriodStart,
    String? accrualPeriodEnd,
    double? currentCapital,
    double? expectedMonthlyPayout,
    String? pensionStartDate,
    bool? hasPartnerPension,
    int? partnerPensionPercentage,
    String? partnerName,
    bool? hasOrphanPension,
    bool? hasDisabilityPension,
    double? monthlyContribution,
    String? paidBy,
    String? taxTreatment,
    bool? allowsExtraContributions,
    bool? hasSurvivorPension,
    double? survivorPayoutAmount,
    String? survivorConditions,
    double? surrenderValue,
    String? claimContactPerson,
    String? claimContactPhone,
    String? claimContactEmail,
    String? survivorInstructions,
    String? servicePhone,
    String? serviceEmail,
    String? website,
    String? portalUrl,
    String? notes,
  }) {
    return PensionModel(
      id: id,
      moneyItemId: moneyItemId,
      pensionType: pensionType ?? this.pensionType,
      provider: provider ?? this.provider,
      participantNumber: participantNumber ?? this.participantNumber,
      participantName: participantName ?? this.participantName,
      employer: employer ?? this.employer,
      accrualPeriodStart: accrualPeriodStart ?? this.accrualPeriodStart,
      accrualPeriodEnd: accrualPeriodEnd ?? this.accrualPeriodEnd,
      currentCapital: currentCapital ?? this.currentCapital,
      expectedMonthlyPayout: expectedMonthlyPayout ?? this.expectedMonthlyPayout,
      pensionStartDate: pensionStartDate ?? this.pensionStartDate,
      hasPartnerPension: hasPartnerPension ?? this.hasPartnerPension,
      partnerPensionPercentage: partnerPensionPercentage ?? this.partnerPensionPercentage,
      partnerName: partnerName ?? this.partnerName,
      hasOrphanPension: hasOrphanPension ?? this.hasOrphanPension,
      hasDisabilityPension: hasDisabilityPension ?? this.hasDisabilityPension,
      monthlyContribution: monthlyContribution ?? this.monthlyContribution,
      paidBy: paidBy ?? this.paidBy,
      taxTreatment: taxTreatment ?? this.taxTreatment,
      allowsExtraContributions: allowsExtraContributions ?? this.allowsExtraContributions,
      hasSurvivorPension: hasSurvivorPension ?? this.hasSurvivorPension,
      survivorPayoutAmount: survivorPayoutAmount ?? this.survivorPayoutAmount,
      survivorConditions: survivorConditions ?? this.survivorConditions,
      surrenderValue: surrenderValue ?? this.surrenderValue,
      claimContactPerson: claimContactPerson ?? this.claimContactPerson,
      claimContactPhone: claimContactPhone ?? this.claimContactPhone,
      claimContactEmail: claimContactEmail ?? this.claimContactEmail,
      survivorInstructions: survivorInstructions ?? this.survivorInstructions,
      servicePhone: servicePhone ?? this.servicePhone,
      serviceEmail: serviceEmail ?? this.serviceEmail,
      website: website ?? this.website,
      portalUrl: portalUrl ?? this.portalUrl,
      notes: notes ?? this.notes,
    );
  }

  /// Bekende pensioenuitvoerders voor autocomplete
  static const List<String> commonProviders = [
    'ABP',
    'PFZW',
    'PMT',
    'PME',
    'bpfBOUW',
    'Pensioenfonds Metaal en Techniek',
    'Pensioenfonds Zorg en Welzijn',
    'Pensioenfonds Horeca & Catering',
    'Nationale-Nederlanden',
    'Aegon',
    'ASR',
    'Achmea',
    'Delta Lloyd',
    'Zwitserleven',
    'Brand New Day',
    'BeFrank',
    'Centraal Beheer',
    'SVB (AOW)',
  ];

  /// Bereken volledigheidspercentage
  int get completenessPercentage {
    int filled = 0;
    const int total = 10;
    
    if (pensionType != PensionType.other) filled++;
    if (provider?.isNotEmpty == true) filled++;
    if (participantNumber?.isNotEmpty == true) filled++;
    if (participantName?.isNotEmpty == true) filled++;
    if (expectedMonthlyPayout != null) filled++;
    if (pensionStartDate?.isNotEmpty == true) filled++;
    if (hasPartnerPension || hasSurvivorPension) filled++; // Nagedacht over nabestaanden
    if (survivorInstructions?.isNotEmpty == true) filled++;
    if (servicePhone?.isNotEmpty == true || website?.isNotEmpty == true) filled++;
    if (notes?.isNotEmpty == true) filled++;
    
    return ((filled / total) * 100).round();
  }
}

