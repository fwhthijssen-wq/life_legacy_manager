// lib/modules/dossier/dossier_model.dart

/// Dossier types - bepaalt het soort huishouden
enum DossierType {
  family,      // Gezin met kinderen
  couple,      // Echtpaar/samenwonend zonder kinderen
  single,      // Alleenstaande
  other,       // Anders
}

extension DossierTypeExtension on DossierType {
  String get displayName {
    switch (this) {
      case DossierType.family:
        return 'Gezin';
      case DossierType.couple:
        return 'Echtpaar/Samenwonend';
      case DossierType.single:
        return 'Alleenstaande';
      case DossierType.other:
        return 'Anders';
    }
  }

  String get description {
    switch (this) {
      case DossierType.family:
        return 'Partner en kinderen';
      case DossierType.couple:
        return 'Samen zonder kinderen';
      case DossierType.single:
        return 'Op jezelf';
      case DossierType.other:
        return 'Overige situatie';
    }
  }

  String get emoji {
    switch (this) {
      case DossierType.family:
        return '👨‍👩‍👧‍👦';
      case DossierType.couple:
        return '👫';
      case DossierType.single:
        return '👤';
      case DossierType.other:
        return '📁';
    }
  }

  String get defaultIcon {
    switch (this) {
      case DossierType.family:
        return 'family';
      case DossierType.couple:
        return 'group';
      case DossierType.single:
        return 'person';
      case DossierType.other:
        return 'folder';
    }
  }

  static DossierType fromString(String? value) {
    switch (value) {
      case 'family':
        return DossierType.family;
      case 'couple':
        return DossierType.couple;
      case 'single':
        return DossierType.single;
      default:
        return DossierType.other;
    }
  }
}

class DossierModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final DossierType type;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DossierModel({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.type = DossierType.family,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  // ----------- COPYWITH -----------
  DossierModel copyWith({
    String? name,
    String? description,
    String? icon,
    String? color,
    DossierType? type,
    bool? isActive,
    DateTime? updatedAt,
  }) {
    return DossierModel(
      id: id,
      userId: userId,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ----------- TO MAP -----------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'type': type.name,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  // ----------- FROM MAP -----------
  factory DossierModel.fromMap(Map<String, dynamic> map) {
    return DossierModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      icon: map['icon'] as String?,
      color: map['color'] as String?,
      type: DossierTypeExtension.fromString(map['type'] as String?),
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }
}
