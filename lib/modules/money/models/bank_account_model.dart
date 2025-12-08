// lib/modules/money/models/bank_account_model.dart

/// Type bankrekening
enum BankAccountType {
  checking('checking', 'Betaalrekening'),
  savings('savings', 'Spaarrekening'),
  deposit('deposit', 'Deposito'),
  investment('investment', 'Beleggingsrekening');

  final String value;
  final String label;
  const BankAccountType(this.value, this.label);

  static BankAccountType fromString(String? value) {
    return BankAccountType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => BankAccountType.checking,
    );
  }
}

/// Locatie van inloggegevens
enum CredentialsLocation {
  passwordManager('password_manager', 'In wachtwoordmanager'),
  paper('paper', 'Op papier'),
  notary('notary', 'Bij notaris'),
  other('other', 'Anders');

  final String value;
  final String label;
  const CredentialsLocation(this.value, this.label);

  static CredentialsLocation? fromString(String? value) {
    if (value == null) return null;
    return CredentialsLocation.values.firstWhere(
      (l) => l.value == value,
      orElse: () => CredentialsLocation.other,
    );
  }
}

/// Actie bij overlijden
enum DeathAction {
  close('close', 'Rekening opheffen'),
  transfer('transfer', 'Overzetten naar erfgenamen'),
  maintain('maintain', 'Aanhouden (voor afwikkeling)');

  final String value;
  final String label;
  const DeathAction(this.value, this.label);

  static DeathAction? fromString(String? value) {
    if (value == null) return null;
    return DeathAction.values.firstWhere(
      (a) => a.value == value,
      orElse: () => DeathAction.close,
    );
  }
}

/// Bekende Nederlandse banken
class KnownBanks {
  static const List<String> banks = [
    'ING Bank',
    'Rabobank',
    'ABN AMRO',
    'SNS Bank',
    'Triodos Bank',
    'ASN Bank',
    'Bunq',
    'Knab',
    'RegioBank',
    'Nationale-Nederlanden',
    'NIBC Direct',
    'Openbank',
    'N26',
    'Revolut',
    'Anders',
  ];
}

/// Model voor bankrekening
class BankAccountModel {
  final String id;
  final String moneyItemId;
  // Basisgegevens
  final String bankName;
  final BankAccountType accountType;
  final String? iban;
  final String? bicSwift;
  final String? accountHolder;
  final bool isJointAccount;
  final String? jointHolderName;
  final String? jointHolderId;
  final double? balance;
  final String currency;
  // Contact & toegang
  final String? servicePhone;
  final String? serviceEmail;
  final String? website;
  final String? loginUrl;
  final CredentialsLocation? credentialsLocation;
  final String? credentialsLocationDetail;
  final bool hasCard;
  final String? cardLocation;
  // Nabestaanden
  final DeathAction? deathAction;
  final String? deathInstructions;
  final List<String> beneficiaries;
  // Notities
  final String? notes;

  BankAccountModel({
    required this.id,
    required this.moneyItemId,
    required this.bankName,
    required this.accountType,
    this.iban,
    this.bicSwift,
    this.accountHolder,
    this.isJointAccount = false,
    this.jointHolderName,
    this.jointHolderId,
    this.balance,
    this.currency = 'EUR',
    this.servicePhone,
    this.serviceEmail,
    this.website,
    this.loginUrl,
    this.credentialsLocation,
    this.credentialsLocationDetail,
    this.hasCard = false,
    this.cardLocation,
    this.deathAction,
    this.deathInstructions,
    this.beneficiaries = const [],
    this.notes,
  });

  /// Geeft alleen laatste 4 cijfers van IBAN (voor privacy)
  String get maskedIban {
    if (iban == null || iban!.length < 4) return '••••';
    return '•••• ${iban!.substring(iban!.length - 4)}';
  }

  /// Geeft IBAN in leesbaar formaat (NL99 BANK 0123 4567 89)
  String get formattedIban {
    if (iban == null) return '';
    final clean = iban!.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(clean[i]);
    }
    return buffer.toString();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'money_item_id': moneyItemId,
      'bank_name': bankName,
      'account_type': accountType.value,
      'iban': iban,
      'bic_swift': bicSwift,
      'account_holder': accountHolder,
      'is_joint_account': isJointAccount ? 1 : 0,
      'joint_holder_name': jointHolderName,
      'joint_holder_id': jointHolderId,
      'balance': balance,
      'currency': currency,
      'service_phone': servicePhone,
      'service_email': serviceEmail,
      'website': website,
      'login_url': loginUrl,
      'credentials_location': credentialsLocation?.value,
      'credentials_location_detail': credentialsLocationDetail,
      'has_card': hasCard ? 1 : 0,
      'card_location': cardLocation,
      'death_action': deathAction?.value,
      'death_instructions': deathInstructions,
      'beneficiaries': beneficiaries.join(','),
      'notes': notes,
    };
  }

  factory BankAccountModel.fromMap(Map<String, dynamic> map) {
    return BankAccountModel(
      id: map['id'] as String,
      moneyItemId: map['money_item_id'] as String,
      bankName: map['bank_name'] as String,
      accountType: BankAccountType.fromString(map['account_type'] as String?),
      iban: map['iban'] as String?,
      bicSwift: map['bic_swift'] as String?,
      accountHolder: map['account_holder'] as String?,
      isJointAccount: (map['is_joint_account'] as int?) == 1,
      jointHolderName: map['joint_holder_name'] as String?,
      jointHolderId: map['joint_holder_id'] as String?,
      balance: map['balance'] as double?,
      currency: (map['currency'] as String?) ?? 'EUR',
      servicePhone: map['service_phone'] as String?,
      serviceEmail: map['service_email'] as String?,
      website: map['website'] as String?,
      loginUrl: map['login_url'] as String?,
      credentialsLocation: CredentialsLocation.fromString(map['credentials_location'] as String?),
      credentialsLocationDetail: map['credentials_location_detail'] as String?,
      hasCard: (map['has_card'] as int?) == 1,
      cardLocation: map['card_location'] as String?,
      deathAction: DeathAction.fromString(map['death_action'] as String?),
      deathInstructions: map['death_instructions'] as String?,
      beneficiaries: (map['beneficiaries'] as String?)?.split(',').where((s) => s.isNotEmpty).toList() ?? [],
      notes: map['notes'] as String?,
    );
  }

  BankAccountModel copyWith({
    String? bankName,
    BankAccountType? accountType,
    String? iban,
    String? bicSwift,
    String? accountHolder,
    bool? isJointAccount,
    String? jointHolderName,
    String? jointHolderId,
    double? balance,
    String? currency,
    String? servicePhone,
    String? serviceEmail,
    String? website,
    String? loginUrl,
    CredentialsLocation? credentialsLocation,
    String? credentialsLocationDetail,
    bool? hasCard,
    String? cardLocation,
    DeathAction? deathAction,
    String? deathInstructions,
    List<String>? beneficiaries,
    String? notes,
  }) {
    return BankAccountModel(
      id: id,
      moneyItemId: moneyItemId,
      bankName: bankName ?? this.bankName,
      accountType: accountType ?? this.accountType,
      iban: iban ?? this.iban,
      bicSwift: bicSwift ?? this.bicSwift,
      accountHolder: accountHolder ?? this.accountHolder,
      isJointAccount: isJointAccount ?? this.isJointAccount,
      jointHolderName: jointHolderName ?? this.jointHolderName,
      jointHolderId: jointHolderId ?? this.jointHolderId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      servicePhone: servicePhone ?? this.servicePhone,
      serviceEmail: serviceEmail ?? this.serviceEmail,
      website: website ?? this.website,
      loginUrl: loginUrl ?? this.loginUrl,
      credentialsLocation: credentialsLocation ?? this.credentialsLocation,
      credentialsLocationDetail: credentialsLocationDetail ?? this.credentialsLocationDetail,
      hasCard: hasCard ?? this.hasCard,
      cardLocation: cardLocation ?? this.cardLocation,
      deathAction: deathAction ?? this.deathAction,
      deathInstructions: deathInstructions ?? this.deathInstructions,
      beneficiaries: beneficiaries ?? this.beneficiaries,
      notes: notes ?? this.notes,
    );
  }
}








