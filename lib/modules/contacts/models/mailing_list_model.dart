// lib/modules/contacts/models/mailing_list_model.dart

/// Model voor opgeslagen mailing lijsten
class MailingListModel {
  final String id;
  final String dossierId;
  final String name;
  final String? description;
  final List<String> contactIds; // IDs van contacten in de lijst
  final String? mailingType; // christmas, newsletter, party, funeral
  final DateTime createdAt;
  final DateTime? updatedAt;

  const MailingListModel({
    required this.id,
    required this.dossierId,
    required this.name,
    this.description,
    required this.contactIds,
    this.mailingType,
    required this.createdAt,
    this.updatedAt,
  });

  /// Aantal contacten in de lijst
  int get contactCount => contactIds.length;

  /// Emoji voor lijst type
  String get emoji {
    switch (mailingType) {
      case 'christmas':
        return '🎄';
      case 'newsletter':
        return '📧';
      case 'party':
        return '🎉';
      case 'funeral':
        return '🕯️';
      default:
        return '📋';
    }
  }

  /// Type label
  String get typeLabel {
    switch (mailingType) {
      case 'christmas':
        return 'Kerstkaarten';
      case 'newsletter':
        return 'Nieuwsbrief';
      case 'party':
        return 'Feesten';
      case 'funeral':
        return 'Rouwkaarten';
      default:
        return 'Algemeen';
    }
  }

  /// Conversie van database map
  factory MailingListModel.fromMap(Map<String, dynamic> map) {
    // Contact IDs zijn opgeslagen als comma-separated string
    final contactIdsString = map['contact_ids'] as String? ?? '';
    final contactIds = contactIdsString.isEmpty 
        ? <String>[] 
        : contactIdsString.split(',');
    
    return MailingListModel(
      id: map['id'] as String,
      dossierId: map['dossier_id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      contactIds: contactIds,
      mailingType: map['mailing_type'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  /// Conversie naar database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dossier_id': dossierId,
      'name': name,
      'description': description,
      'contact_ids': contactIds.join(','),
      'mailing_type': mailingType,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Copy with
  MailingListModel copyWith({
    String? name,
    String? description,
    List<String>? contactIds,
    String? mailingType,
    DateTime? updatedAt,
  }) {
    return MailingListModel(
      id: id,
      dossierId: dossierId,
      name: name ?? this.name,
      description: description ?? this.description,
      contactIds: contactIds ?? this.contactIds,
      mailingType: mailingType ?? this.mailingType,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}




