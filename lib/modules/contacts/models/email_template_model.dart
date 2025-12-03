// lib/modules/contacts/models/email_template_model.dart

import '../services/contact_export_service.dart';

/// Email/Brief template model
class EmailTemplateModel {
  final String id;
  final String dossierId;
  final String name;
  final String subject;
  final String body;
  final String? mailingType; // christmas, newsletter, party, funeral
  final bool isDefault;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const EmailTemplateModel({
    required this.id,
    required this.dossierId,
    required this.name,
    required this.subject,
    required this.body,
    this.mailingType,
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Conversie van database map
  factory EmailTemplateModel.fromMap(Map<String, dynamic> map) {
    return EmailTemplateModel(
      id: map['id'] as String,
      dossierId: map['dossier_id'] as String,
      name: map['name'] as String,
      subject: map['subject'] as String? ?? '',
      body: map['body'] as String? ?? '',
      mailingType: map['mailing_type'] as String?,
      isDefault: (map['is_default'] as int?) == 1,
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
      'subject': subject,
      'body': body,
      'mailing_type': mailingType,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  /// Copy with
  EmailTemplateModel copyWith({
    String? name,
    String? subject,
    String? body,
    String? mailingType,
    bool? isDefault,
    DateTime? updatedAt,
  }) {
    return EmailTemplateModel(
      id: id,
      dossierId: dossierId,
      name: name ?? this.name,
      subject: subject ?? this.subject,
      body: body ?? this.body,
      mailingType: mailingType ?? this.mailingType,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Krijg MailingType enum
  MailingType? get mailingTypeEnum {
    switch (mailingType) {
      case 'christmas':
        return MailingType.christmas;
      case 'newsletter':
        return MailingType.newsletter;
      case 'party':
        return MailingType.party;
      case 'funeral':
        return MailingType.funeral;
      default:
        return null;
    }
  }

  /// Emoji voor template type
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
        return '📝';
    }
  }

  /// Vervang placeholders in body met echte waarden
  String formatBody({String? recipientName}) {
    var result = body;
    if (recipientName != null) {
      result = result.replaceAll('{naam}', recipientName);
      result = result.replaceAll('{name}', recipientName);
    }
    return result;
  }

  /// Vervang placeholders in subject
  String formatSubject({String? recipientName}) {
    var result = subject;
    if (recipientName != null) {
      result = result.replaceAll('{naam}', recipientName);
      result = result.replaceAll('{name}', recipientName);
    }
    return result;
  }
}

/// Standaard templates die beschikbaar zijn voor alle gebruikers
class DefaultEmailTemplates {
  static List<EmailTemplateModel> getDefaults(String dossierId) {
    final now = DateTime.now();
    return [
      EmailTemplateModel(
        id: 'default_christmas',
        dossierId: dossierId,
        name: 'Kerstgroet',
        subject: 'Fijne feestdagen!',
        body: '''Beste {naam},

Wij wensen u fijne feestdagen en een gezond en voorspoedig nieuwjaar!

Met vriendelijke groet''',
        mailingType: 'christmas',
        isDefault: true,
        createdAt: now,
      ),
      EmailTemplateModel(
        id: 'default_newyear',
        dossierId: dossierId,
        name: 'Nieuwjaarswens',
        subject: 'Gelukkig Nieuwjaar!',
        body: '''Beste {naam},

Wij wensen u een gezond, gelukkig en voorspoedig nieuw jaar!

Met vriendelijke groet''',
        mailingType: 'christmas',
        isDefault: true,
        createdAt: now,
      ),
      EmailTemplateModel(
        id: 'default_party',
        dossierId: dossierId,
        name: 'Feest uitnodiging',
        subject: 'Uitnodiging',
        body: '''Beste {naam},

Hierbij nodigen wij u van harte uit voor ons feest.

Datum: [vul in]
Tijd: [vul in]
Locatie: [vul in]

Wij hopen u te mogen verwelkomen!

Met vriendelijke groet''',
        mailingType: 'party',
        isDefault: true,
        createdAt: now,
      ),
      EmailTemplateModel(
        id: 'default_birthday',
        dossierId: dossierId,
        name: 'Verjaardag uitnodiging',
        subject: 'Uitnodiging verjaardagsfeest',
        body: '''Beste {naam},

Hierbij nodigen wij u van harte uit voor het verjaardagsfeest.

Datum: [vul in]
Tijd: [vul in]
Locatie: [vul in]

Wij hopen u te mogen verwelkomen!

Met vriendelijke groet''',
        mailingType: 'party',
        isDefault: true,
        createdAt: now,
      ),
      EmailTemplateModel(
        id: 'default_funeral',
        dossierId: dossierId,
        name: 'Rouwbericht',
        subject: 'Overlijdensbericht',
        body: '''Beste {naam},

Met droefheid delen wij u mede dat

[naam overledene]

is overleden.

De uitvaart vindt plaats op:
Datum: [vul in]
Tijd: [vul in]
Locatie: [vul in]

Met vriendelijke groet''',
        mailingType: 'funeral',
        isDefault: true,
        createdAt: now,
      ),
      EmailTemplateModel(
        id: 'default_newsletter',
        dossierId: dossierId,
        name: 'Nieuwsbrief',
        subject: 'Nieuwsbrief',
        body: '''Beste {naam},

Hierbij onze nieuwsbrief.

[Inhoud]

Met vriendelijke groet''',
        mailingType: 'newsletter',
        isDefault: true,
        createdAt: now,
      ),
      EmailTemplateModel(
        id: 'default_general',
        dossierId: dossierId,
        name: 'Algemeen bericht',
        subject: '',
        body: '''Beste {naam},



Met vriendelijke groet''',
        isDefault: true,
        createdAt: now,
      ),
    ];
  }
}



