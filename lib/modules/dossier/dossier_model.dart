// lib/modules/dossier/dossier_model.dart

class DossierModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
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
      isActive: (map['is_active'] as int?) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }
}
