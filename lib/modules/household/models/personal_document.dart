// lib/modules/household/models/personal_document.dart

class PersonalDocument {
  final String id;
  final String personId;
  final DocumentType documentType;
  final String? documentNumber;
  final DateTime? issueDate;
  final DateTime? expiryDate;
  final String? issuingAuthority;
  final String? documentFilePath;
  final String? physicalLocation;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PersonalDocument({
    required this.id,
    required this.personId,
    required this.documentType,
    this.documentNumber,
    this.issueDate,
    this.expiryDate,
    this.issuingAuthority,
    this.documentFilePath,
    this.physicalLocation,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory PersonalDocument.fromMap(Map<String, dynamic> map) {
    return PersonalDocument(
      id: map['id'] as String,
      personId: map['person_id'] as String,
      documentType: DocumentType.fromString(map['document_type'] as String),
      documentNumber: map['document_number'] as String?,
      issueDate: map['issue_date'] != null 
          ? DateTime.parse(map['issue_date'] as String) 
          : null,
      expiryDate: map['expiry_date'] != null 
          ? DateTime.parse(map['expiry_date'] as String) 
          : null,
      issuingAuthority: map['issuing_authority'] as String?,
      documentFilePath: map['document_file_path'] as String?,
      physicalLocation: map['physical_location'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'person_id': personId,
      'document_type': documentType.value,
      'document_number': documentNumber,
      'issue_date': issueDate?.toIso8601String(),
      'expiry_date': expiryDate?.toIso8601String(),
      'issuing_authority': issuingAuthority,
      'document_file_path': documentFilePath,
      'physical_location': physicalLocation,
      'notes': notes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  PersonalDocument copyWith({
    String? id,
    String? personId,
    DocumentType? documentType,
    String? documentNumber,
    DateTime? issueDate,
    DateTime? expiryDate,
    String? issuingAuthority,
    String? documentFilePath,
    String? physicalLocation,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PersonalDocument(
      id: id ?? this.id,
      personId: personId ?? this.personId,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      issueDate: issueDate ?? this.issueDate,
      expiryDate: expiryDate ?? this.expiryDate,
      issuingAuthority: issuingAuthority ?? this.issuingAuthority,
      documentFilePath: documentFilePath ?? this.documentFilePath,
      physicalLocation: physicalLocation ?? this.physicalLocation,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final now = DateTime.now();
    final difference = expiryDate!.difference(now).inDays;
    return difference <= 90 && difference > 0; // Binnen 3 maanden
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
}

enum DocumentType {
  passport('paspoort'),
  idCard('id_kaart'),
  driversLicense('rijbewijs'),
  birthCertificate('geboorteakte'),
  marriageCertificate('trouwboekje'),
  divorceCertificate('scheidingsbewijs'),
  deathCertificate('overlijdensakte'),
  other('overig');

  final String value;
  const DocumentType(this.value);

  static DocumentType fromString(String value) {
    return DocumentType.values.firstWhere(
      (d) => d.value == value,
      orElse: () => DocumentType.other,
    );
  }

  String getDisplayName() {
    switch (this) {
      case DocumentType.passport:
        return 'Paspoort';
      case DocumentType.idCard:
        return 'ID-kaart';
      case DocumentType.driversLicense:
        return 'Rijbewijs';
      case DocumentType.birthCertificate:
        return 'Geboorteakte';
      case DocumentType.marriageCertificate:
        return 'Trouwboekje';
      case DocumentType.divorceCertificate:
        return 'Scheidingsbewijs';
      case DocumentType.deathCertificate:
        return 'Overlijdensakte';
      case DocumentType.other:
        return 'Overig';
    }
  }

  String getIcon() {
    switch (this) {
      case DocumentType.passport:
        return '🛂';
      case DocumentType.idCard:
        return '🪪';
      case DocumentType.driversLicense:
        return '🚗';
      case DocumentType.birthCertificate:
        return '👶';
      case DocumentType.marriageCertificate:
        return '💍';
      case DocumentType.divorceCertificate:
        return '📜';
      case DocumentType.deathCertificate:
        return '🕊️';
      case DocumentType.other:
        return '📄';
    }
  }
}
