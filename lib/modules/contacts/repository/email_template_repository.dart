// lib/modules/contacts/repository/email_template_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/app_database.dart';
import '../models/email_template_model.dart';

/// Provider voor EmailTemplateRepository
final emailTemplateRepositoryProvider = Provider<EmailTemplateRepository>((ref) {
  final db = ref.read(appDatabaseProvider);
  return EmailTemplateRepository(db);
});

/// Provider voor templates van een dossier (inclusief defaults)
final emailTemplatesProvider = FutureProvider.family<List<EmailTemplateModel>, String>((ref, dossierId) async {
  final repository = ref.read(emailTemplateRepositoryProvider);
  return repository.getTemplatesForDossier(dossierId);
});

/// Repository voor email templates
class EmailTemplateRepository {
  final AppDatabase _db;
  static const _uuid = Uuid();

  EmailTemplateRepository(this._db);

  /// Haal alle templates op voor een dossier (custom + defaults)
  Future<List<EmailTemplateModel>> getTemplatesForDossier(String dossierId) async {
    // Custom templates uit database
    final results = await _db.query(
      'email_templates',
      where: 'dossier_id = ?',
      whereArgs: [dossierId],
      orderBy: 'name',
    );
    
    final customTemplates = results.map((map) => EmailTemplateModel.fromMap(map)).toList();
    
    // Voeg standaard templates toe die nog niet bestaan
    final defaultTemplates = DefaultEmailTemplates.getDefaults(dossierId);
    final existingIds = customTemplates.map((t) => t.id).toSet();
    
    for (final defaultTemplate in defaultTemplates) {
      if (!existingIds.contains(defaultTemplate.id)) {
        customTemplates.add(defaultTemplate);
      }
    }
    
    // Sorteer op naam
    customTemplates.sort((a, b) => a.name.compareTo(b.name));
    
    return customTemplates;
  }

  /// Haal templates op gefilterd op mailing type
  Future<List<EmailTemplateModel>> getTemplatesByType(String dossierId, String? mailingType) async {
    final allTemplates = await getTemplatesForDossier(dossierId);
    
    if (mailingType == null) {
      return allTemplates;
    }
    
    return allTemplates.where((t) => t.mailingType == mailingType || t.mailingType == null).toList();
  }

  /// Haal een specifieke template op
  Future<EmailTemplateModel?> getTemplate(String templateId) async {
    final results = await _db.query(
      'email_templates',
      where: 'id = ?',
      whereArgs: [templateId],
    );
    
    if (results.isEmpty) {
      // Check of het een default template is
      // Defaults hebben geen dossier_id in de ID, dus we kunnen het niet direct ophalen
      return null;
    }
    
    return EmailTemplateModel.fromMap(results.first);
  }

  /// Maak een nieuwe template aan
  Future<EmailTemplateModel> createTemplate({
    required String dossierId,
    required String name,
    required String subject,
    required String body,
    String? mailingType,
  }) async {
    final now = DateTime.now();
    final template = EmailTemplateModel(
      id: _uuid.v4(),
      dossierId: dossierId,
      name: name,
      subject: subject,
      body: body,
      mailingType: mailingType,
      isDefault: false,
      createdAt: now,
    );
    
    await _db.insert('email_templates', template.toMap());
    
    return template;
  }

  /// Update een bestaande template
  Future<void> updateTemplate(EmailTemplateModel template) async {
    final updated = template.copyWith(updatedAt: DateTime.now());
    
    await _db.update(
      'email_templates',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [template.id],
    );
  }

  /// Verwijder een template
  Future<void> deleteTemplate(String templateId) async {
    await _db.delete(
      'email_templates',
      where: 'id = ?',
      whereArgs: [templateId],
    );
  }

  /// Kopieer een default template naar een custom template
  Future<EmailTemplateModel> copyDefaultTemplate(
    EmailTemplateModel defaultTemplate,
    String newName,
  ) async {
    return createTemplate(
      dossierId: defaultTemplate.dossierId,
      name: newName,
      subject: defaultTemplate.subject,
      body: defaultTemplate.body,
      mailingType: defaultTemplate.mailingType,
    );
  }
}



