// lib/modules/money/models/insurance_model.dart

import 'direct_debit_model.dart' show PaymentFrequency;
export 'direct_debit_model.dart' show PaymentFrequency;

/// Types verzekeringen
enum InsuranceType {
  life('life', 'Levensverzekering', '💚'),
  deathRisk('death_risk', 'Overlijdensrisicoverzekering', '⚰️'),
  disability('disability', 'Arbeidsongeschiktheidsverzekering', '🦽'),
  health('health', 'Zorgverzekering', '🏥'),
  car('car', 'Autoverzekering', '🚗'),
  home('home', 'Woonhuisverzekering', '🏠'),
  contents('contents', 'Inboedelverzekering', '🛋️'),
  liability('liability', 'Aansprakelijkheidsverzekering', '⚠️'),
  legal('legal', 'Rechtsbijstandverzekering', '⚖️'),
  travel('travel', 'Reisverzekering', '✈️'),
  other('other', 'Overige verzekering', '📋');

  final String value;
  final String label;
  final String emoji;
  const InsuranceType(this.value, this.label, this.emoji);

  static InsuranceType fromString(String? value) {
    return InsuranceType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => InsuranceType.other,
    );
  }
}

/// Opzegmethode
enum CancellationMethod {
  letter('letter', 'Per brief'),
  email('email', 'Per email'),
  online('online', 'Via online portaal'),
  phone('phone', 'Telefonisch'),
  registered('registered', 'Aangetekend');

  final String value;
  final String label;
  const CancellationMethod(this.value, this.label);

  static CancellationMethod fromString(String? value) {
    return CancellationMethod.values.firstWhere(
      (m) => m.value == value,
      orElse: () => CancellationMethod.letter,
    );
  }
}

/// Actie bij overlijden
enum DeathAction {
  payout('payout', 'Uitkering aan begunstigden'),
  cancel('cancel', 'Opheffen'),
  transfer('transfer', 'Overzetten naar nabestaande'),
  continues('continues', 'Loopt automatisch door'),
  expires('expires', 'Vervalt automatisch'),
  claimRequired('claim_required', 'Claim indienen');

  final String value;
  final String label;
  const DeathAction(this.value, this.label);

  static DeathAction fromString(String? value) {
    return DeathAction.values.firstWhere(
      (a) => a.value == value,
      orElse: () => DeathAction.cancel,
    );
  }
}

/// Model voor een verzekering (passend bij database schema)
class InsuranceModel {
  final String id;
  final String moneyItemId; // Link naar money_items tabel
  
  // Basisgegevens
  final String company; // Verzekeringsmaatschappij
  final InsuranceType insuranceType;
  final String? policyNumber; // Polisnummer
  final String? insuredPersonId; // ID van verzekerde persoon
  final String? coInsured; // Medeverzekerden (comma-separated of tekst)
  final String? startDate; // Ingangsdatum
  final String? endDate; // Einddatum
  final String? duration; // Looptijd
  
  // Financieel
  final double? premium; // Premie bedrag
  final PaymentFrequency paymentFrequency;
  final String? paymentMethod; // Betaalmethode
  final String? linkedBankAccountId; // Link naar bankrekening voor incasso
  final double? coverageAmount; // Verzekerd bedrag
  final double? deductible; // Eigen risico
  final String? additionalCoverage; // Aanvullende dekkingen
  
  // Voorwaarden & Opzegging
  final String? noticePeriod; // Opzegtermijn
  final bool autoRenewal; // Automatische verlenging
  final CancellationMethod cancellationMethod;
  final String? lastCancellationDate; // Laatst mogelijke opzegging
  
  // Contactgegevens
  final String? advisorName; // Adviseur/tussenpersoon
  final String? advisorPhone;
  final String? advisorEmail;
  final String? servicePhone; // Klantenservice
  final String? serviceEmail;
  final String? website;
  final String? claimsUrl; // Schademelding URL
  
  // Voor nabestaanden
  final DeathAction deathAction;
  final String? beneficiaries; // Begunstigden
  final String? actionRequired; // Actie vereist beschrijving
  final String? deathInstructions; // Speciale instructies
  
  // Notities
  final String? notes;

  InsuranceModel({
    required this.id,
    required this.moneyItemId,
    required this.company,
    this.insuranceType = InsuranceType.other,
    this.policyNumber,
    this.insuredPersonId,
    this.coInsured,
    this.startDate,
    this.endDate,
    this.duration,
    this.premium,
    this.paymentFrequency = PaymentFrequency.monthly,
    this.paymentMethod,
    this.linkedBankAccountId,
    this.coverageAmount,
    this.deductible,
    this.additionalCoverage,
    this.noticePeriod,
    this.autoRenewal = true,
    this.cancellationMethod = CancellationMethod.letter,
    this.lastCancellationDate,
    this.advisorName,
    this.advisorPhone,
    this.advisorEmail,
    this.servicePhone,
    this.serviceEmail,
    this.website,
    this.claimsUrl,
    this.deathAction = DeathAction.cancel,
    this.beneficiaries,
    this.actionRequired,
    this.deathInstructions,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'money_item_id': moneyItemId,
      'company': company,
      'insurance_type': insuranceType.value,
      'policy_number': policyNumber,
      'insured_person_id': insuredPersonId,
      'co_insured': coInsured,
      'start_date': startDate,
      'end_date': endDate,
      'duration': duration,
      'premium': premium,
      'payment_frequency': paymentFrequency.value,
      'payment_method': paymentMethod,
      'linked_bank_account_id': linkedBankAccountId,
      'coverage_amount': coverageAmount,
      'deductible': deductible,
      'additional_coverage': additionalCoverage,
      'notice_period': noticePeriod,
      'auto_renewal': autoRenewal ? 1 : 0,
      'cancellation_method': cancellationMethod.value,
      'last_cancellation_date': lastCancellationDate,
      'advisor_name': advisorName,
      'advisor_phone': advisorPhone,
      'advisor_email': advisorEmail,
      'service_phone': servicePhone,
      'service_email': serviceEmail,
      'website': website,
      'claims_url': claimsUrl,
      'death_action': deathAction.value,
      'beneficiaries': beneficiaries,
      'action_required': actionRequired,
      'death_instructions': deathInstructions,
      'notes': notes,
    };
  }

  factory InsuranceModel.fromMap(Map<String, dynamic> map) {
    return InsuranceModel(
      id: map['id'] as String,
      moneyItemId: map['money_item_id'] as String,
      company: map['company'] as String? ?? '',
      insuranceType: InsuranceType.fromString(map['insurance_type'] as String?),
      policyNumber: map['policy_number'] as String?,
      insuredPersonId: map['insured_person_id'] as String?,
      coInsured: map['co_insured'] as String?,
      startDate: map['start_date'] as String?,
      endDate: map['end_date'] as String?,
      duration: map['duration'] as String?,
      premium: map['premium'] as double?,
      paymentFrequency: PaymentFrequency.fromString(map['payment_frequency'] as String?),
      paymentMethod: map['payment_method'] as String?,
      linkedBankAccountId: map['linked_bank_account_id'] as String?,
      coverageAmount: map['coverage_amount'] as double?,
      deductible: map['deductible'] as double?,
      additionalCoverage: map['additional_coverage'] as String?,
      noticePeriod: map['notice_period'] as String?,
      autoRenewal: map['auto_renewal'] == 1,
      cancellationMethod: CancellationMethod.fromString(map['cancellation_method'] as String?),
      lastCancellationDate: map['last_cancellation_date'] as String?,
      advisorName: map['advisor_name'] as String?,
      advisorPhone: map['advisor_phone'] as String?,
      advisorEmail: map['advisor_email'] as String?,
      servicePhone: map['service_phone'] as String?,
      serviceEmail: map['service_email'] as String?,
      website: map['website'] as String?,
      claimsUrl: map['claims_url'] as String?,
      deathAction: DeathAction.fromString(map['death_action'] as String?),
      beneficiaries: map['beneficiaries'] as String?,
      actionRequired: map['action_required'] as String?,
      deathInstructions: map['death_instructions'] as String?,
      notes: map['notes'] as String?,
    );
  }

  InsuranceModel copyWith({
    String? company,
    InsuranceType? insuranceType,
    String? policyNumber,
    String? insuredPersonId,
    String? coInsured,
    String? startDate,
    String? endDate,
    String? duration,
    double? premium,
    PaymentFrequency? paymentFrequency,
    String? paymentMethod,
    String? linkedBankAccountId,
    double? coverageAmount,
    double? deductible,
    String? additionalCoverage,
    String? noticePeriod,
    bool? autoRenewal,
    CancellationMethod? cancellationMethod,
    String? lastCancellationDate,
    String? advisorName,
    String? advisorPhone,
    String? advisorEmail,
    String? servicePhone,
    String? serviceEmail,
    String? website,
    String? claimsUrl,
    DeathAction? deathAction,
    String? beneficiaries,
    String? actionRequired,
    String? deathInstructions,
    String? notes,
  }) {
    return InsuranceModel(
      id: id,
      moneyItemId: moneyItemId,
      company: company ?? this.company,
      insuranceType: insuranceType ?? this.insuranceType,
      policyNumber: policyNumber ?? this.policyNumber,
      insuredPersonId: insuredPersonId ?? this.insuredPersonId,
      coInsured: coInsured ?? this.coInsured,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      duration: duration ?? this.duration,
      premium: premium ?? this.premium,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      linkedBankAccountId: linkedBankAccountId ?? this.linkedBankAccountId,
      coverageAmount: coverageAmount ?? this.coverageAmount,
      deductible: deductible ?? this.deductible,
      additionalCoverage: additionalCoverage ?? this.additionalCoverage,
      noticePeriod: noticePeriod ?? this.noticePeriod,
      autoRenewal: autoRenewal ?? this.autoRenewal,
      cancellationMethod: cancellationMethod ?? this.cancellationMethod,
      lastCancellationDate: lastCancellationDate ?? this.lastCancellationDate,
      advisorName: advisorName ?? this.advisorName,
      advisorPhone: advisorPhone ?? this.advisorPhone,
      advisorEmail: advisorEmail ?? this.advisorEmail,
      servicePhone: servicePhone ?? this.servicePhone,
      serviceEmail: serviceEmail ?? this.serviceEmail,
      website: website ?? this.website,
      claimsUrl: claimsUrl ?? this.claimsUrl,
      deathAction: deathAction ?? this.deathAction,
      beneficiaries: beneficiaries ?? this.beneficiaries,
      actionRequired: actionRequired ?? this.actionRequired,
      deathInstructions: deathInstructions ?? this.deathInstructions,
      notes: notes ?? this.notes,
    );
  }

  /// Bekende verzekeraars voor autocomplete
  static const List<String> commonInsurers = [
    'Nationale-Nederlanden',
    'Aegon',
    'Centraal Beheer',
    'OHRA',
    'FBTO',
    'Interpolis',
    'Delta Lloyd',
    'ASR',
    'Achmea',
    'Zilveren Kruis',
    'CZ',
    'VGZ',
    'Menzis',
    'ONVZ',
    'Univé',
    'ANWB',
    'Allianz',
    'AXA',
    'Generali',
    'NN',
    'Reaal',
    'Brand New Day',
    'InShared',
    'Ditzo',
    'Promovendum',
  ];

  /// Bereken volledigheidspercentage
  int get completenessPercentage {
    int filled = 0;
    const int total = 10;
    
    if (company.isNotEmpty) filled++;
    if (insuranceType != InsuranceType.other) filled++;
    if (policyNumber?.isNotEmpty == true) filled++;
    if (startDate?.isNotEmpty == true) filled++;
    if (premium != null && premium! > 0) filled++;
    if (servicePhone?.isNotEmpty == true || serviceEmail?.isNotEmpty == true) filled++;
    if (noticePeriod?.isNotEmpty == true) filled++;
    if (deathAction != DeathAction.cancel) filled++; // Bewust nagedacht over nabestaanden
    if (deathInstructions?.isNotEmpty == true) filled++;
    if (notes?.isNotEmpty == true) filled++;
    
    return ((filled / total) * 100).round();
  }
}
