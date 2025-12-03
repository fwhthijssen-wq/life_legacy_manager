// lib/modules/person/person_model.dart

// Sentinel object voor undefined values in copyWith
const _undefined = Object();

/// Contact categorieën (uitgebreid, meerdere mogelijk per contact)
enum ContactCategory {
  family('Familie', 'family', '👨‍👩‍👧'),
  friend('Vrienden', 'friend', '👫'),
  colleague('Collega\'s/Werk', 'colleague', '💼'),
  neighbor('Buren', 'neighbor', '🏠'),
  acquaintance('Kennissen', 'acquaintance', '👋'),
  club('Club/Vereniging', 'club', '🎾'),
  school('School/Kinderen', 'school', '🏫'),
  medical('Zorg/Medisch', 'medical', '⚕️'),
  other('Overig', 'other', '📋');

  final String displayName;
  final String value;
  final String emoji;
  const ContactCategory(this.displayName, this.value, this.emoji);

  String get displayWithEmoji => '$emoji $displayName';

  static ContactCategory? fromValue(String? value) {
    if (value == null || value.isEmpty) return null;
    return ContactCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ContactCategory.other,
    );
  }
  
  /// Parse meerdere categorieën uit comma-separated string
  static Set<ContactCategory> fromValues(String? values) {
    if (values == null || values.isEmpty) return {};
    return values
        .split(',')
        .map((v) => fromValue(v.trim()))
        .whereType<ContactCategory>()
        .toSet();
  }
  
  /// Converteer set naar comma-separated string
  static String toValues(Set<ContactCategory>? categories) {
    if (categories == null || categories.isEmpty) return '';
    return categories.map((c) => c.value).join(',');
  }
}

class PersonModel {
  final String id;
  final String dossierId;
  final String firstName;
  final String? namePrefix;
  final String lastName;

  final String? phone;
  final String? email;
  final String? birthDate;
  final String? address;
  final String? postalCode;
  final String? city;
  final String? gender;
  final String? notes;
  final String? relation;
  final String? deathDate;
  
  // ===== CONTACT-VELDEN =====
  final bool isContact;
  /// Meerdere categorieën mogelijk per contact
  final Set<ContactCategory> categories;

  PersonModel({
    required this.id,
    required this.dossierId,
    required this.firstName,
    this.namePrefix,
    required this.lastName,
    this.phone,
    this.email,
    this.birthDate,
    this.address,
    this.postalCode,
    this.city,
    this.gender,
    this.notes,
    this.relation,
    this.deathDate,
    this.isContact = false,
    Set<ContactCategory>? categories,
  }) : categories = categories ?? {};

  String get fullName {
    if (namePrefix != null && namePrefix!.isNotEmpty) {
      return '$firstName $namePrefix $lastName';
    }
    return '$firstName $lastName';
  }

  String get formalName {
    final firstInitial = firstName.isNotEmpty ? '${firstName[0]}.' : '';
    if (namePrefix != null && namePrefix!.isNotEmpty) {
      return '$lastName, $firstInitial $namePrefix';
    }
    return '$lastName, $firstInitial';
  }
  
  /// Geeft een leesbare string van categorieën
  String get categoriesDisplay {
    if (categories.isEmpty) return 'Geen categorie';
    return categories.map((c) => c.displayName).join(', ');
  }
  
  /// Geeft categorieën met emoji's
  String get categoriesWithEmoji {
    if (categories.isEmpty) return '';
    return categories.map((c) => c.emoji).join(' ');
  }
  
  /// Check of contact in een bepaalde categorie zit
  bool hasCategory(ContactCategory category) => categories.contains(category);
  
  /// Check of contact in een van de gegeven categorieën zit
  bool hasAnyCategory(Set<ContactCategory> cats) => 
      categories.any((c) => cats.contains(c));

  // Legacy getters voor backwards compatibility tijdens migratie
  ContactCategory? get contactCategory => categories.isNotEmpty ? categories.first : null;
  bool get forChristmasCard => false; // Deprecated
  bool get forNewsletter => false; // Deprecated
  bool get forParty => false; // Deprecated
  bool get forFuneral => false; // Deprecated

  PersonModel copyWith({
    String? dossierId,
    String? firstName,
    Object? namePrefix = _undefined,
    String? lastName,
    Object? phone = _undefined,
    Object? email = _undefined,
    Object? birthDate = _undefined,
    Object? address = _undefined,
    Object? postalCode = _undefined,
    Object? city = _undefined,
    Object? gender = _undefined,
    Object? notes = _undefined,
    Object? relation = _undefined,
    Object? deathDate = _undefined,
    bool? isContact,
    Set<ContactCategory>? categories,
  }) {
    return PersonModel(
      id: id,
      dossierId: dossierId ?? this.dossierId,
      firstName: firstName ?? this.firstName,
      namePrefix: namePrefix == _undefined ? this.namePrefix : namePrefix as String?,
      lastName: lastName ?? this.lastName,
      phone: phone == _undefined ? this.phone : phone as String?,
      email: email == _undefined ? this.email : email as String?,
      birthDate: birthDate == _undefined ? this.birthDate : birthDate as String?,
      address: address == _undefined ? this.address : address as String?,
      postalCode: postalCode == _undefined ? this.postalCode : postalCode as String?,
      city: city == _undefined ? this.city : city as String?,
      gender: gender == _undefined ? this.gender : gender as String?,
      notes: notes == _undefined ? this.notes : notes as String?,
      relation: relation == _undefined ? this.relation : relation as String?,
      deathDate: deathDate == _undefined ? this.deathDate : deathDate as String?,
      isContact: isContact ?? this.isContact,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dossier_id': dossierId,
      'first_name': firstName,
      'name_prefix': namePrefix,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'birth_date': birthDate,
      'address': address,
      'postal_code': postalCode,
      'city': city,
      'gender': gender,
      'notes': notes,
      'relation': relation,
      'death_date': deathDate,
      'is_contact': isContact ? 1 : 0,
      'contact_categories': ContactCategory.toValues(categories),
      'created_at': DateTime.now().millisecondsSinceEpoch,
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
    // Parse categorieën - probeer nieuwe veldnaam, dan legacy
    Set<ContactCategory> cats = {};
    
    final categoriesStr = map['contact_categories'] ?? map['categories'];
    if (categoriesStr != null && (categoriesStr as String).isNotEmpty) {
      cats = ContactCategory.fromValues(categoriesStr);
    } else if (map['contact_category'] != null) {
      // Legacy: migreer oude single category
      final oldCat = ContactCategory.fromValue(map['contact_category'] as String?);
      if (oldCat != null) cats = {oldCat};
    }
    
    return PersonModel(
      id: map['id'],
      dossierId: map['dossier_id'],
      firstName: map['first_name'],
      namePrefix: map['name_prefix'],
      lastName: map['last_name'],
      phone: map['phone'],
      email: map['email'],
      birthDate: map['birth_date'],
      address: map['address'],
      postalCode: map['postal_code'],
      city: map['city'],
      gender: map['gender'],
      notes: map['notes'],
      relation: map['relation'],
      deathDate: map['death_date'],
      isContact: map['is_contact'] == 1,
      categories: cats,
    );
  }
}
