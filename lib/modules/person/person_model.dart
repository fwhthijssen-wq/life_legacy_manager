// lib/modules/person/person_model.dart

class PersonModel {
  final String id;
  final String firstName;
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
    required this.firstName,
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

  // ----------- COPYWITH -----------
  PersonModel copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? email,
    String? birthDate,
    String? address,
    String? postalCode,
    String? city,
    String? gender,
    String? notes,
    String? relation,
    String? deathDate,
  }) {
    return PersonModel(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      postalCode: postalCode ?? this.postalCode,
      city: city ?? this.city,
      gender: gender ?? this.gender,
      notes: notes ?? this.notes,
      relation: relation ?? this.relation,
      deathDate: deathDate ?? this.deathDate,
    );
  }

  // ----------- TO MAP -----------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
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
      firstName: map['first_name'],
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