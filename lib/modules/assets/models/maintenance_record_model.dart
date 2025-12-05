// lib/modules/assets/models/maintenance_record_model.dart
import 'package:uuid/uuid.dart';

/// Model voor onderhoudshistorie van een bezitting
class MaintenanceRecordModel {
  final String id;
  final String assetId;
  final String date;
  final String? performedBy;
  final String description;
  final double? cost;
  final String? documentPath;
  final String? notes;
  final String createdAt;

  MaintenanceRecordModel({
    String? id,
    required this.assetId,
    required this.date,
    this.performedBy,
    required this.description,
    this.cost,
    this.documentPath,
    this.notes,
    String? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'asset_id': assetId,
      'date': date,
      'performed_by': performedBy,
      'description': description,
      'cost': cost,
      'document_path': documentPath,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory MaintenanceRecordModel.fromMap(Map<String, dynamic> map) {
    return MaintenanceRecordModel(
      id: map['id'],
      assetId: map['asset_id'],
      date: map['date'] ?? '',
      performedBy: map['performed_by'],
      description: map['description'] ?? '',
      cost: map['cost']?.toDouble(),
      documentPath: map['document_path'],
      notes: map['notes'],
      createdAt: map['created_at'],
    );
  }

  MaintenanceRecordModel copyWith({
    String? id,
    String? assetId,
    String? date,
    String? performedBy,
    String? description,
    double? cost,
    String? documentPath,
    String? notes,
    String? createdAt,
  }) {
    return MaintenanceRecordModel(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      date: date ?? this.date,
      performedBy: performedBy ?? this.performedBy,
      description: description ?? this.description,
      cost: cost ?? this.cost,
      documentPath: documentPath ?? this.documentPath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

