// lib/modules/money/models/money_document_model.dart

/// Type document voor geldzaken
enum MoneyDocumentType {
  contract('contract', 'Contract/Overeenkomst'),
  policy('policy', 'Polis'),
  overview('overview', 'Jaaroverzicht'),
  specification('specification', 'Specificatie'),
  correspondence('correspondence', 'Correspondentie'),
  statement('statement', 'Afschrift'),
  other('other', 'Overig');

  final String value;
  final String label;
  const MoneyDocumentType(this.value, this.label);

  static MoneyDocumentType fromString(String? value) {
    return MoneyDocumentType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => MoneyDocumentType.other,
    );
  }
}

/// Model voor documenten gekoppeld aan geldzaken
class MoneyDocumentModel {
  final String id;
  final String moneyItemId;
  final String title;
  final MoneyDocumentType documentType;
  final String? filePath;           // Lokaal bestandspad
  final String? physicalLocation;   // Fysieke locatie (bijv. "Bureau lade 2")
  final String? documentDate;
  final String? notes;
  final DateTime createdAt;

  MoneyDocumentModel({
    required this.id,
    required this.moneyItemId,
    required this.title,
    this.documentType = MoneyDocumentType.other,
    this.filePath,
    this.physicalLocation,
    this.documentDate,
    this.notes,
    required this.createdAt,
  });

  /// Check of document digitaal beschikbaar is
  bool get isDigital => filePath != null && filePath!.isNotEmpty;

  /// Check of fysieke locatie bekend is
  bool get hasPhysicalLocation => physicalLocation != null && physicalLocation!.isNotEmpty;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'money_item_id': moneyItemId,
      'title': title,
      'document_type': documentType.value,
      'file_path': filePath,
      'physical_location': physicalLocation,
      'document_date': documentDate,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory MoneyDocumentModel.fromMap(Map<String, dynamic> map) {
    return MoneyDocumentModel(
      id: map['id'] as String,
      moneyItemId: map['money_item_id'] as String,
      title: map['title'] as String,
      documentType: MoneyDocumentType.fromString(map['document_type'] as String?),
      filePath: map['file_path'] as String?,
      physicalLocation: map['physical_location'] as String?,
      documentDate: map['document_date'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  MoneyDocumentModel copyWith({
    String? title,
    MoneyDocumentType? documentType,
    String? filePath,
    String? physicalLocation,
    String? documentDate,
    String? notes,
  }) {
    return MoneyDocumentModel(
      id: id,
      moneyItemId: moneyItemId,
      title: title ?? this.title,
      documentType: documentType ?? this.documentType,
      filePath: filePath ?? this.filePath,
      physicalLocation: physicalLocation ?? this.physicalLocation,
      documentDate: documentDate ?? this.documentDate,
      notes: notes ?? this.notes,
      createdAt: createdAt,
    );
  }
}








