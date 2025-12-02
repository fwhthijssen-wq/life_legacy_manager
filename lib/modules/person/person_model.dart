// lib/modules/person/person_model.dart

// Sentinel object voor undefined values in copyWith
const _undefined = Object();

/// Contact categorieën
enum ContactCategory {
  family('Familie', 'family'),
  friend('Vriend', 'friend'),
  professional('Beroepsmatig', 'professional'),
  other('Overig', 'other');

  final String displayName;
  final String value;
  const ContactCategory(this.displayName, this.value);

  static ContactCategory? fromValue(String? value) {
    if (value == null) return null;
    return ContactCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ContactCategory.other,
    );
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
  final ContactCategory? contactCategory;
  final bool forChristmasCard;
  final bool forNewsletter;
  final bool forParty;
  final bool forFuneral;

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
    this.contactCategory,
    this.forChristmasCard = false,
    this.forNewsletter = false,
    this.forParty = false,
    this.forFuneral = false,
  });

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
    Object? contactCategory = _undefined,
    bool? forChristmasCard,
    bool? forNewsletter,
    bool? forParty,
    bool? forFuneral,
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
      contactCategory: contactCategory == _undefined ? this.contactCategory : contactCategory as ContactCategory?,
      forChristmasCard: forChristmasCard ?? this.forChristmasCard,
      forNewsletter: forNewsletter ?? this.forNewsletter,
      forParty: forParty ?? this.forParty,
      forFuneral: forFuneral ?? this.forFuneral,
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
      'contact_category': contactCategory?.value,
      'for_christmas_card': forChristmasCard ? 1 : 0,
      'for_newsletter': forNewsletter ? 1 : 0,
      'for_party': forParty ? 1 : 0,
      'for_funeral': forFuneral ? 1 : 0,
    };
  }

  factory PersonModel.fromMap(Map<String, dynamic> map) {
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
      contactCategory: ContactCategory.fromValue(map['contact_category']),
      forChristmasCard: map['for_christmas_card'] == 1,
      forNewsletter: map['for_newsletter'] == 1,
      forParty: map['for_party'] == 1,
      forFuneral: map['for_funeral'] == 1,
    );
  }
}
