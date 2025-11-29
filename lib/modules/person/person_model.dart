// lib/modules/person/person_model.dart

// Sentinel object voor undefined values in copyWith
const _undefined = Object();

class PersonModel {
  final String id;
  final String dossierId;  // ← NIEUW: Koppeling met dossier
  final String firstName;
  final String? namePrefix;  // ← NIEUW: Tussenvoegsel
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

  PersonModel({
    required this.id,
    required this.dossierId,  // ← NIEUW
    required this.firstName,
    this.namePrefix,  // ← NIEUW
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
  });

  // ← NIEUW: Helper voor volledige naam
  String get fullName {
    if (namePrefix != null && namePrefix!.isNotEmpty) {
      return '$firstName $namePrefix $lastName';
    }
    return '$firstName $lastName';
  }

  // ← NIEUW: Helper voor formele naam (achternaam, voorletters + tussenvoegsel)
  String get formalName {
    final firstInitial = firstName.isNotEmpty ? '${firstName[0]}.' : '';
    if (namePrefix != null && namePrefix!.isNotEmpty) {
      return '$lastName, $firstInitial $namePrefix';
    }
    return '$lastName, $firstInitial';
  }

  // ----------- COPYWITH (FIXED) -----------
  PersonModel copyWith({
    String? dossierId,
    String? firstName,
    Object? namePrefix = _undefined,  // ← NIEUW
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
  }) {
    return PersonModel(
      id: id,
      dossierId: dossierId ?? this.dossierId,
      firstName: firstName ?? this.firstName,
      namePrefix: namePrefix == _undefined ? this.namePrefix : namePrefix as String?,  // ← NIEUW
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
    );
  }

  // ----------- TO MAP -----------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dossier_id': dossierId,  // ← NIEUW
      'first_name': firstName,
      'name_prefix': namePrefix,  // ← NIEUW
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
    };
  }

  // ----------- FROM MAP -----------
  factory PersonModel.fromMap(Map<String, dynamic> map) {
    return PersonModel(
      id: map['id'],
      dossierId: map['dossier_id'],  // ← NIEUW
      firstName: map['first_name'],
      namePrefix: map['name_prefix'],  // ← NIEUW
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
    );
  }
}
