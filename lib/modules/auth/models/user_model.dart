import 'package:flutter/foundation.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? gender;
  final DateTime? birthDate;
  final String email;

  final String passwordHash;
  final String? pinHash;
  final bool isPinEnabled;
  final bool isBiometricEnabled;

  final DateTime createdAt;
  final DateTime? lastLogin;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.gender,
    this.birthDate,
    required this.email,
    required this.passwordHash,
    this.pinHash,
    this.isPinEnabled = false,
    this.isBiometricEnabled = false,
    required this.createdAt,
    this.lastLogin,
  });

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? gender,
    DateTime? birthDate,
    String? email,
    String? passwordHash,
    String? pinHash,
    bool? isPinEnabled,
    bool? isBiometricEnabled,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      pinHash: pinHash ?? this.pinHash,
      isPinEnabled: isPinEnabled ?? this.isPinEnabled,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'gender': gender,
      'birth_date': birthDate?.millisecondsSinceEpoch,
      'email': email,
      'password_hash': passwordHash,
      'pin_hash': pinHash,
      'is_pin_enabled': isPinEnabled ? 1 : 0,
      'is_biometric_enabled': isBiometricEnabled ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'last_login': lastLogin?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      gender: map['gender'],
      birthDate: map['birth_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['birth_date'])
          : null,
      email: map['email'],
      passwordHash: map['password_hash'],
      pinHash: map['pin_hash'],
      isPinEnabled: map['is_pin_enabled'] == 1,
      isBiometricEnabled: map['is_biometric_enabled'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      lastLogin: map['last_login'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_login'])
          : null,
    );
  }
}
