// lib/modules/subscriptions/models/subscription_model.dart
// Model voor abonnementen en lidmaatschappen

import 'subscription_enums.dart';

class SubscriptionModel {
  final String id;
  final String dossierId;
  final String? personId;

  // Tab 1: Basisgegevens
  final String name;
  final String? provider;
  final SubscriptionCategory category;
  final SubscriptionType subscriptionType;
  final String? accountNumber;
  final String? startDate;
  final SubscriptionStatus status;

  // Tab 2: Financieel
  final double? cost;
  final PaymentFrequency paymentFrequency;
  final PaymentMethod paymentMethod;
  final String? linkedBankAccountId;
  final String? creditCardLast4;
  final int? paymentDay;
  final String? lastPaymentDate;
  final String? nextPaymentDate;

  // Tab 3: Contract & Looptijd
  final ContractType contractType;
  final int? minTermMonths;
  final String? minTermEndDate;
  final String? contractEndDate;
  final bool autoRenewal;
  final int? renewalMonths;
  final bool hadTrialPeriod;
  final String? trialEndDate;

  // Tab 4: Opzegging
  final int? noticePeriodDays;
  final String? lastCancellationDate;
  final CancellationMethod? cancellationMethod;
  final String? cancellationEmail;
  final String? cancellationUrl;
  final String? cancellationAddress;
  final String? cancellationPhone;
  final bool cancellationConfirmationRequired;
  final double? earlyCancellationFee;
  final String? cancellationConditions;

  // Tab 5: Inloggegevens & Toegang
  final String? websiteUrl;
  final CredentialsLocation? credentialsLocation;
  final String? credentialsLocationDetail;
  final String? username;
  final String? accountType;
  final String? sharedWith;
  final bool has2FA;
  final String? twoFactorMethod;

  // Tab 6: Details (type-specifiek)
  final String? packageName;
  final int? maxScreens;
  final String? maxResolution;
  final int? maxProfiles;
  final String? locationName;
  final String? locationAddress;
  final String? openingHours;
  final String? memberNumber;
  final String? membershipType;
  final String? benefits;

  // Tab 7: Voor nabestaanden
  final DeathAction deathAction;
  final CancellationPriority cancellationPriority;
  final bool refundPossible;
  final String? survivorInstructions;

  // Tab 8: Contactgegevens
  final String? servicePhone;
  final String? serviceEmail;
  final String? serviceWebsite;
  final String? serviceHours;
  final String? accountUrl;
  final String? cancellationPageUrl;

  // Tab 9: Kortingen
  final bool hasDiscount;
  final String? discountType;
  final double? discountPercentage;
  final double? normalPrice;
  final double? discountPrice;
  final String? discountEndDate;
  final String? promoCode;

  // Tab 10: Notities
  final String? notes;

  // Status
  final ItemStatus itemStatus;
  final DateTime createdAt;
  final DateTime? updatedAt;

  SubscriptionModel({
    required this.id,
    required this.dossierId,
    this.personId,
    required this.name,
    this.provider,
    required this.category,
    this.subscriptionType = SubscriptionType.digitalService,
    this.accountNumber,
    this.startDate,
    this.status = SubscriptionStatus.active,
    this.cost,
    this.paymentFrequency = PaymentFrequency.monthly,
    this.paymentMethod = PaymentMethod.directDebit,
    this.linkedBankAccountId,
    this.creditCardLast4,
    this.paymentDay,
    this.lastPaymentDate,
    this.nextPaymentDate,
    this.contractType = ContractType.ongoing,
    this.minTermMonths,
    this.minTermEndDate,
    this.contractEndDate,
    this.autoRenewal = true,
    this.renewalMonths,
    this.hadTrialPeriod = false,
    this.trialEndDate,
    this.noticePeriodDays,
    this.lastCancellationDate,
    this.cancellationMethod,
    this.cancellationEmail,
    this.cancellationUrl,
    this.cancellationAddress,
    this.cancellationPhone,
    this.cancellationConfirmationRequired = false,
    this.earlyCancellationFee,
    this.cancellationConditions,
    this.websiteUrl,
    this.credentialsLocation,
    this.credentialsLocationDetail,
    this.username,
    this.accountType,
    this.sharedWith,
    this.has2FA = false,
    this.twoFactorMethod,
    this.packageName,
    this.maxScreens,
    this.maxResolution,
    this.maxProfiles,
    this.locationName,
    this.locationAddress,
    this.openingHours,
    this.memberNumber,
    this.membershipType,
    this.benefits,
    this.deathAction = DeathAction.cancelImmediately,
    this.cancellationPriority = CancellationPriority.normal,
    this.refundPossible = false,
    this.survivorInstructions,
    this.servicePhone,
    this.serviceEmail,
    this.serviceWebsite,
    this.serviceHours,
    this.accountUrl,
    this.cancellationPageUrl,
    this.hasDiscount = false,
    this.discountType,
    this.discountPercentage,
    this.normalPrice,
    this.discountPrice,
    this.discountEndDate,
    this.promoCode,
    this.notes,
    this.itemStatus = ItemStatus.notStarted,
    required this.createdAt,
    this.updatedAt,
  });

  String get displayName => name;

  /// Bereken maandelijkse kosten
  double get monthlyCost {
    if (cost == null) return 0;
    if (paymentFrequency.months == 0) return 0; // Eenmalig
    return cost! / paymentFrequency.months;
  }

  /// Bereken jaarlijkse kosten
  double get yearlyCost => monthlyCost * 12;

  int get completenessPercentage {
    int filled = 0;
    int total = 12;

    if (name.isNotEmpty) filled++;
    if (provider?.isNotEmpty == true) filled++;
    if (cost != null) filled++;
    if (startDate?.isNotEmpty == true) filled++;
    if (noticePeriodDays != null) filled++;
    if (cancellationMethod != null) filled++;
    if (websiteUrl?.isNotEmpty == true) filled++;
    if (servicePhone?.isNotEmpty == true || serviceEmail?.isNotEmpty == true) filled++;
    if (deathAction != DeathAction.cancelImmediately || survivorInstructions?.isNotEmpty == true) filled++;
    if (accountNumber?.isNotEmpty == true) filled++;
    if (contractType != ContractType.ongoing || contractEndDate?.isNotEmpty == true) filled++;
    if (notes?.isNotEmpty == true) filled++;

    return ((filled / total) * 100).round();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dossier_id': dossierId,
      'person_id': personId,
      'name': name,
      'provider': provider,
      'category': category.name,
      'subscription_type': subscriptionType.name,
      'account_number': accountNumber,
      'start_date': startDate,
      'status': status.name,
      'cost': cost,
      'payment_frequency': paymentFrequency.name,
      'payment_method': paymentMethod.name,
      'linked_bank_account_id': linkedBankAccountId,
      'credit_card_last4': creditCardLast4,
      'payment_day': paymentDay,
      'last_payment_date': lastPaymentDate,
      'next_payment_date': nextPaymentDate,
      'contract_type': contractType.name,
      'min_term_months': minTermMonths,
      'min_term_end_date': minTermEndDate,
      'contract_end_date': contractEndDate,
      'auto_renewal': autoRenewal ? 1 : 0,
      'renewal_months': renewalMonths,
      'had_trial_period': hadTrialPeriod ? 1 : 0,
      'trial_end_date': trialEndDate,
      'notice_period_days': noticePeriodDays,
      'last_cancellation_date': lastCancellationDate,
      'cancellation_method': cancellationMethod?.name,
      'cancellation_email': cancellationEmail,
      'cancellation_url': cancellationUrl,
      'cancellation_address': cancellationAddress,
      'cancellation_phone': cancellationPhone,
      'cancellation_confirmation_required': cancellationConfirmationRequired ? 1 : 0,
      'early_cancellation_fee': earlyCancellationFee,
      'cancellation_conditions': cancellationConditions,
      'website_url': websiteUrl,
      'credentials_location': credentialsLocation?.name,
      'credentials_location_detail': credentialsLocationDetail,
      'username': username,
      'account_type': accountType,
      'shared_with': sharedWith,
      'has_2fa': has2FA ? 1 : 0,
      'two_factor_method': twoFactorMethod,
      'package_name': packageName,
      'max_screens': maxScreens,
      'max_resolution': maxResolution,
      'max_profiles': maxProfiles,
      'location_name': locationName,
      'location_address': locationAddress,
      'opening_hours': openingHours,
      'member_number': memberNumber,
      'membership_type': membershipType,
      'benefits': benefits,
      'death_action': deathAction.name,
      'cancellation_priority': cancellationPriority.name,
      'refund_possible': refundPossible ? 1 : 0,
      'survivor_instructions': survivorInstructions,
      'service_phone': servicePhone,
      'service_email': serviceEmail,
      'service_website': serviceWebsite,
      'service_hours': serviceHours,
      'account_url': accountUrl,
      'cancellation_page_url': cancellationPageUrl,
      'has_discount': hasDiscount ? 1 : 0,
      'discount_type': discountType,
      'discount_percentage': discountPercentage,
      'normal_price': normalPrice,
      'discount_price': discountPrice,
      'discount_end_date': discountEndDate,
      'promo_code': promoCode,
      'notes': notes,
      'item_status': itemStatus.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      dossierId: map['dossier_id'] as String,
      personId: map['person_id'] as String?,
      name: map['name'] as String,
      provider: map['provider'] as String?,
      category: SubscriptionCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => SubscriptionCategory.other,
      ),
      subscriptionType: SubscriptionType.values.firstWhere(
        (e) => e.name == map['subscription_type'],
        orElse: () => SubscriptionType.digitalService,
      ),
      accountNumber: map['account_number'] as String?,
      startDate: map['start_date'] as String?,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SubscriptionStatus.active,
      ),
      cost: map['cost'] as double?,
      paymentFrequency: PaymentFrequency.values.firstWhere(
        (e) => e.name == map['payment_frequency'],
        orElse: () => PaymentFrequency.monthly,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == map['payment_method'],
        orElse: () => PaymentMethod.directDebit,
      ),
      linkedBankAccountId: map['linked_bank_account_id'] as String?,
      creditCardLast4: map['credit_card_last4'] as String?,
      paymentDay: map['payment_day'] as int?,
      lastPaymentDate: map['last_payment_date'] as String?,
      nextPaymentDate: map['next_payment_date'] as String?,
      contractType: ContractType.values.firstWhere(
        (e) => e.name == map['contract_type'],
        orElse: () => ContractType.ongoing,
      ),
      minTermMonths: map['min_term_months'] as int?,
      minTermEndDate: map['min_term_end_date'] as String?,
      contractEndDate: map['contract_end_date'] as String?,
      autoRenewal: map['auto_renewal'] == 1,
      renewalMonths: map['renewal_months'] as int?,
      hadTrialPeriod: map['had_trial_period'] == 1,
      trialEndDate: map['trial_end_date'] as String?,
      noticePeriodDays: map['notice_period_days'] as int?,
      lastCancellationDate: map['last_cancellation_date'] as String?,
      cancellationMethod: map['cancellation_method'] != null
          ? CancellationMethod.values.firstWhere(
              (e) => e.name == map['cancellation_method'],
              orElse: () => CancellationMethod.email,
            )
          : null,
      cancellationEmail: map['cancellation_email'] as String?,
      cancellationUrl: map['cancellation_url'] as String?,
      cancellationAddress: map['cancellation_address'] as String?,
      cancellationPhone: map['cancellation_phone'] as String?,
      cancellationConfirmationRequired: map['cancellation_confirmation_required'] == 1,
      earlyCancellationFee: map['early_cancellation_fee'] as double?,
      cancellationConditions: map['cancellation_conditions'] as String?,
      websiteUrl: map['website_url'] as String?,
      credentialsLocation: map['credentials_location'] != null
          ? CredentialsLocation.values.firstWhere(
              (e) => e.name == map['credentials_location'],
              orElse: () => CredentialsLocation.other,
            )
          : null,
      credentialsLocationDetail: map['credentials_location_detail'] as String?,
      username: map['username'] as String?,
      accountType: map['account_type'] as String?,
      sharedWith: map['shared_with'] as String?,
      has2FA: map['has_2fa'] == 1,
      twoFactorMethod: map['two_factor_method'] as String?,
      packageName: map['package_name'] as String?,
      maxScreens: map['max_screens'] as int?,
      maxResolution: map['max_resolution'] as String?,
      maxProfiles: map['max_profiles'] as int?,
      locationName: map['location_name'] as String?,
      locationAddress: map['location_address'] as String?,
      openingHours: map['opening_hours'] as String?,
      memberNumber: map['member_number'] as String?,
      membershipType: map['membership_type'] as String?,
      benefits: map['benefits'] as String?,
      deathAction: DeathAction.values.firstWhere(
        (e) => e.name == map['death_action'],
        orElse: () => DeathAction.cancelImmediately,
      ),
      cancellationPriority: CancellationPriority.values.firstWhere(
        (e) => e.name == map['cancellation_priority'],
        orElse: () => CancellationPriority.normal,
      ),
      refundPossible: map['refund_possible'] == 1,
      survivorInstructions: map['survivor_instructions'] as String?,
      servicePhone: map['service_phone'] as String?,
      serviceEmail: map['service_email'] as String?,
      serviceWebsite: map['service_website'] as String?,
      serviceHours: map['service_hours'] as String?,
      accountUrl: map['account_url'] as String?,
      cancellationPageUrl: map['cancellation_page_url'] as String?,
      hasDiscount: map['has_discount'] == 1,
      discountType: map['discount_type'] as String?,
      discountPercentage: map['discount_percentage'] as double?,
      normalPrice: map['normal_price'] as double?,
      discountPrice: map['discount_price'] as double?,
      discountEndDate: map['discount_end_date'] as String?,
      promoCode: map['promo_code'] as String?,
      notes: map['notes'] as String?,
      itemStatus: ItemStatus.values.firstWhere(
        (e) => e.name == map['item_status'],
        orElse: () => ItemStatus.notStarted,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Bekende streaming diensten
  static const List<String> streamingProviders = [
    'Netflix', 'Disney+', 'Amazon Prime Video', 'Videoland', 'HBO Max',
    'Apple TV+', 'Paramount+', 'Discovery+', 'Viaplay', 'NPO Start Plus',
    'Spotify', 'Apple Music', 'YouTube Premium', 'Deezer', 'Tidal',
    'Amazon Music', 'SoundCloud Go',
  ];

  /// Bekende sportscholen
  static const List<String> fitnessProviders = [
    'Basic-Fit', 'Fit For Free', 'Anytime Fitness', 'SportCity',
    'David Lloyd', 'TrainMore', 'HealthCity', 'Pure Gym', 'Curves',
  ];

  /// Bekende verenigingen
  static const List<String> associationProviders = [
    'ANWB', 'Consumentenbond', 'FNV', 'CNV', 'VNO-NCW', 'MKB-Nederland',
    'KNVB', 'KNLTB', 'Golfvereniging', 'Rotary', 'Lions Club',
  ];

  /// Bekende software
  static const List<String> softwareProviders = [
    'Microsoft 365', 'Adobe Creative Cloud', 'Google One', 'iCloud+',
    'Dropbox', 'OneDrive', 'Norton', 'McAfee', 'Kaspersky',
    '1Password', 'LastPass', 'Dashlane', 'NordVPN', 'ExpressVPN',
    'Notion', 'Evernote', 'Todoist',
  ];

  /// Bekende maaltijdboxen
  static const List<String> mealProviders = [
    'HelloFresh', 'Marley Spoon', 'Dinnerly', 'Albert Heijn Allerhande',
    'Jumbo Foodcoach', 'De Krat', 'Ekomenu',
  ];
}

/// Statistieken voor subscriptions dashboard
class SubscriptionStats {
  final int totalActive;
  final double totalMonthly;
  final double totalYearly;
  final int expiringCount;
  final int completenessPercentage;
  final Map<SubscriptionCategory, double> costByCategory;

  SubscriptionStats({
    required this.totalActive,
    required this.totalMonthly,
    required this.totalYearly,
    required this.expiringCount,
    required this.completenessPercentage,
    required this.costByCategory,
  });
}






