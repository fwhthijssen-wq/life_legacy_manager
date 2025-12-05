// lib/modules/assets/models/asset_document_model.dart
import 'package:uuid/uuid.dart';

/// Type document bij bezitting
enum AssetDocumentType {
  purchaseProof('Aankoopbewijs / Factuur', '🧾'),
  warranty('Garantiebewijs', '📋'),
  certificate('Certificaat van echtheid', '🏅'),
  appraisal('Taxatierapport', '📊'),
  maintenanceBook('Onderhoudsboekje', '📒'),
  manual('Handleiding', '📖'),
  insurance('Verzekeringsdocumenten', '🛡️'),
  registration('Kentekenbewijs (voertuigen)', '🚗'),
  photo('Foto', '📷'),
  other('Overig', '📄');

  final String label;
  final String emoji;
  const AssetDocumentType(this.label, this.emoji);
}

/// Model voor documenten bij bezittingen
class AssetDocumentModel {
  final String id;
  final String assetId;
  final String title;
  final AssetDocumentType documentType;
  final String? filePath;
  final String? physicalLocation;
  final String? documentDate;
  final String? notes;
  final String createdAt;

  AssetDocumentModel({
    String? id,
    required this.assetId,
    required this.title,
    required this.documentType,
    this.filePath,
    this.physicalLocation,
    this.documentDate,
    this.notes,
    String? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'asset_id': assetId,
      'title': title,
      'document_type': documentType.name,
      'file_path': filePath,
      'physical_location': physicalLocation,
      'document_date': documentDate,
      'notes': notes,
      'created_at': createdAt,
    };
  }

  factory AssetDocumentModel.fromMap(Map<String, dynamic> map) {
    return AssetDocumentModel(
      id: map['id'],
      assetId: map['asset_id'],
      title: map['title'],
      documentType: AssetDocumentType.values.firstWhere(
        (e) => e.name == map['document_type'],
        orElse: () => AssetDocumentType.other,
      ),
      filePath: map['file_path'],
      physicalLocation: map['physical_location'],
      documentDate: map['document_date'],
      notes: map['notes'],
      createdAt: map['created_at'],
    );
  }

  AssetDocumentModel copyWith({
    String? id,
    String? assetId,
    String? title,
    AssetDocumentType? documentType,
    String? filePath,
    String? physicalLocation,
    String? documentDate,
    String? notes,
    String? createdAt,
  }) {
    return AssetDocumentModel(
      id: id ?? this.id,
      assetId: assetId ?? this.assetId,
      title: title ?? this.title,
      documentType: documentType ?? this.documentType,
      filePath: filePath ?? this.filePath,
      physicalLocation: physicalLocation ?? this.physicalLocation,
      documentDate: documentDate ?? this.documentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
