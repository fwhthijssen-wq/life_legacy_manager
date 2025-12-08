// lib/modules/contacts/models/contact_model.dart

/// Contact categorieën
enum ContactCategory {
  family,       // Familie
  friend,       // Vriend/kennis
  neighbor,     // Buur
  colleague,    // Collega
  club,         // Vereniging/club
  supplier,     // Leverancier/dienstverlener
  medical,      // Medisch (huisarts, specialist)
  financial,    // Financieel (bank, verzekering)
  legal,        // Juridisch (notaris, advocaat)
  other,        // Overig
}

extension ContactCategoryExtension on ContactCategory {
  String get displayName {
    switch (this) {
      case ContactCategory.family:
        return 'Familie';
      case ContactCategory.friend:
        return 'Vriend/Kennis';
      case ContactCategory.neighbor:
        return 'Buur';
      case ContactCategory.colleague:
        return 'Collega';
      case ContactCategory.club:
        return 'Vereniging/Club';
      case ContactCategory.supplier:
        return 'Leverancier';
      case ContactCategory.medical:
        return 'Medisch';
      case ContactCategory.financial:
        return 'Financieel';
      case ContactCategory.legal:
        return 'Juridisch';
      case ContactCategory.other:
        return 'Overig';
    }
  }

  String get emoji {
    switch (this) {
      case ContactCategory.family:
        return '👨‍👩‍👧';
      case ContactCategory.friend:
        return '🤝';
      case ContactCategory.neighbor:
        return '🏠';
      case ContactCategory.colleague:
        return '💼';
      case ContactCategory.club:
        return '⚽';
      case ContactCategory.supplier:
        return '🛠️';
      case ContactCategory.medical:
        return '🏥';
      case ContactCategory.financial:
        return '🏦';
      case ContactCategory.legal:
        return '⚖️';
      case ContactCategory.other:
        return '📋';
    }
  }

  static ContactCategory fromString(String? value) {
    switch (value) {
      case 'family':
        return ContactCategory.family;
      case 'friend':
        return ContactCategory.friend;
      case 'neighbor':
        return ContactCategory.neighbor;
      case 'colleague':
        return ContactCategory.colleague;
      case 'club':
        return ContactCategory.club;
      case 'supplier':
        return ContactCategory.supplier;
      case 'medical':
        return ContactCategory.medical;
      case 'financial':
        return ContactCategory.financial;
      case 'legal':
        return ContactCategory.legal;
      default:
        return ContactCategory.other;
    }
  }
}

/// Contact model
class Contact {
  final String id;
  final String dossierId;
  final String name;
  final String? street;
  final String? houseNumber;
  final String? postalCode;
  final String? city;
  final String? country;
  final String? email;
  final String? phone;
  final String? mobile;
  final ContactCategory category;
  final String? notes;
  final bool forFuneral;      // Voor rouwkaarten
  final bool forNewsletter;   // Voor nieuwsbrief/mailing
  final bool forParty;        // Voor feestjes
  final DateTime createdAt;
  final DateTime? updatedAt;

  Contact({
    required this.id,
    required this.dossierId,
    required this.name,
    this.street,
    this.houseNumber,
    this.postalCode,
    this.city,
    this.country,
    this.email,
    this.phone,
    this.mobile,
    this.category = ContactCategory.other,
    this.notes,
    this.forFuneral = false,
    this.forNewsletter = false,
    this.forParty = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Volledige adres als string
  String get fullAddress {
    final parts = <String>[];
    if (street != null && street!.isNotEmpty) {
      parts.add('$street ${houseNumber ?? ''}');
    }
    if (postalCode != null && postalCode!.isNotEmpty) {
      parts.add(postalCode!);
    }
    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }
    if (country != null && country!.isNotEmpty && country != 'Nederland') {
      parts.add(country!);
    }
    return parts.join(', ');
  }

  /// Heeft dit contact een adres?
  bool get hasAddress => 
      (street != null && street!.isNotEmpty) ||
      (city != null && city!.isNotEmpty);

  /// Heeft dit contact contact info?
  bool get hasContactInfo =>
      (email != null && email!.isNotEmpty) ||
      (phone != null && phone!.isNotEmpty) ||
      (mobile != null && mobile!.isNotEmpty);

  // ----------- COPYWITH -----------
  Contact copyWith({
    String? name,
    String? street,
    String? houseNumber,
    String? postalCode,
    String? city,
    String? country,
    String? email,
    String? phone,
    String? mobile,
    ContactCategory? category,
    String? notes,
    bool? forFuneral,
    bool? forNewsletter,
    bool? forParty,
    DateTime? updatedAt,
  }) {
    return Contact(
      id: id,
      dossierId: dossierId,
      name: name ?? this.name,
      street: street ?? this.street,
      houseNumber: houseNumber ?? this.houseNumber,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      country: country ?? this.country,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      mobile: mobile ?? this.mobile,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      forFuneral: forFuneral ?? this.forFuneral,
      forNewsletter: forNewsletter ?? this.forNewsletter,
      forParty: forParty ?? this.forParty,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ----------- TO MAP -----------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dossier_id': dossierId,
      'name': name,
      'street': street,
      'house_number': houseNumber,
      'postal_code': postalCode,
      'city': city,
      'country': country,
      'email': email,
      'phone': phone,
      'mobile': mobile,
      'category': category.name,
      'notes': notes,
      'for_funeral': forFuneral ? 1 : 0,
      'for_newsletter': forNewsletter ? 1 : 0,
      'for_party': forParty ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // ----------- FROM MAP -----------
  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'] as String,
      dossierId: map['dossier_id'] as String,
      name: map['name'] as String,
      street: map['street'] as String?,
      houseNumber: map['house_number'] as String?,
      postalCode: map['postal_code'] as String?,
      city: map['city'] as String?,
      country: map['country'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      mobile: map['mobile'] as String?,
      category: ContactCategoryExtension.fromString(map['category'] as String?),
      notes: map['notes'] as String?,
      forFuneral: (map['for_funeral'] as int?) == 1,
      forNewsletter: (map['for_newsletter'] as int?) == 1,
      forParty: (map['for_party'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }
}








