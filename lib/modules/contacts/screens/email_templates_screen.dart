// lib/modules/contacts/screens/email_templates_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/email_template_model.dart';
import '../repository/email_template_repository.dart';

/// Scherm voor het beheren van email/brief templates
class EmailTemplatesScreen extends ConsumerStatefulWidget {
  final String dossierId;

  const EmailTemplatesScreen({super.key, required this.dossierId});

  @override
  ConsumerState<EmailTemplatesScreen> createState() => _EmailTemplatesScreenState();
}

class _EmailTemplatesScreenState extends ConsumerState<EmailTemplatesScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final templatesAsync = ref.watch(emailTemplatesProvider(widget.dossierId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Email Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
            tooltip: 'Help',
          ),
        ],
      ),
      body: templatesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Fout: $err')),
        data: (templates) {
          if (templates.isEmpty) {
            return _buildEmptyState(context);
          }

          // Groepeer templates op type
          final grouped = _groupTemplates(templates);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Info kaart
              Card(
                color: theme.primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.primaryColor),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Maak en beheer templates voor emails en brieven. '
                          'Gebruik {naam} als placeholder voor de naam van de ontvanger.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Gegroepeerde templates
              ...grouped.entries.map((entry) {
                return _buildTemplateGroup(context, entry.key, entry.value);
              }),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addTemplate(context),
        icon: const Icon(Icons.add),
        label: const Text('Nieuwe Template'),
      ),
    );
  }

  Map<String, List<EmailTemplateModel>> _groupTemplates(List<EmailTemplateModel> templates) {
    final grouped = <String, List<EmailTemplateModel>>{};
    
    for (final template in templates) {
      final type = _getTypeLabel(template.mailingType);
      grouped.putIfAbsent(type, () => []);
      grouped[type]!.add(template);
    }
    
    // Sorteer de groepen
    final sortOrder = ['🎄 Kerstkaarten', '📧 Nieuwsbrief', '🎉 Feesten', '🕯️ Rouwkaarten', '📝 Algemeen'];
    final sortedGrouped = <String, List<EmailTemplateModel>>{};
    
    for (final key in sortOrder) {
      if (grouped.containsKey(key)) {
        sortedGrouped[key] = grouped[key]!;
      }
    }
    
    // Voeg eventuele overige groepen toe
    for (final entry in grouped.entries) {
      if (!sortedGrouped.containsKey(entry.key)) {
        sortedGrouped[entry.key] = entry.value;
      }
    }
    
    return sortedGrouped;
  }

  String _getTypeLabel(String? mailingType) {
    switch (mailingType) {
      case 'christmas':
        return '🎄 Kerstkaarten';
      case 'newsletter':
        return '📧 Nieuwsbrief';
      case 'party':
        return '🎉 Feesten';
      case 'funeral':
        return '🕯️ Rouwkaarten';
      default:
        return '📝 Algemeen';
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mail_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Geen templates',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Maak je eerste template aan',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _addTemplate(context),
            icon: const Icon(Icons.add),
            label: const Text('Template maken'),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateGroup(BuildContext context, String title, List<EmailTemplateModel> templates) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...templates.map((template) => _buildTemplateCard(context, template)),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildTemplateCard(BuildContext context, EmailTemplateModel template) {
    final theme = Theme.of(context);
    final isDefault = template.isDefault;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _viewTemplate(context, template),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    template.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                template.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Standaard',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        if (template.subject.isNotEmpty)
                          Text(
                            template.subject,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  // Acties
                  if (!isDefault) ...[
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _editTemplate(context, template),
                      tooltip: 'Bewerken',
                      visualDensity: VisualDensity.compact,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                      onPressed: () => _deleteTemplate(context, template),
                      tooltip: 'Verwijderen',
                      visualDensity: VisualDensity.compact,
                    ),
                  ] else ...[
                    IconButton(
                      icon: const Icon(Icons.copy, size: 20),
                      onPressed: () => _copyTemplate(context, template),
                      tooltip: 'Kopiëren',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  template.body,
                  style: theme.textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline),
            SizedBox(width: 12),
            Text('Templates Help'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Wat zijn templates?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Templates zijn vooraf opgestelde berichten die je kunt gebruiken '
                'voor emails en brieven. Ze besparen tijd bij het versturen van '
                'berichten naar meerdere contacten.',
              ),
              SizedBox(height: 16),
              Text(
                'Placeholders',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Gebruik {naam} in je template om automatisch de naam van de '
                'ontvanger in te vullen.',
              ),
              SizedBox(height: 16),
              Text(
                'Standaard vs Eigen',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                '• Standaard templates kun je niet wijzigen, maar wel kopiëren\n'
                '• Eigen templates kun je volledig aanpassen en verwijderen',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sluiten'),
          ),
        ],
      ),
    );
  }

  void _viewTemplate(BuildContext context, EmailTemplateModel template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(template.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Text(template.name)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (template.subject.isNotEmpty) ...[
                const Text(
                  'Onderwerp:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(template.subject),
                const SizedBox(height: 16),
              ],
              const Text(
                'Bericht:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(template.body),
              ),
            ],
          ),
        ),
        actions: [
          if (template.isDefault)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _copyTemplate(context, template);
              },
              icon: const Icon(Icons.copy),
              label: const Text('Kopiëren'),
            )
          else
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _editTemplate(context, template);
              },
              icon: const Icon(Icons.edit),
              label: const Text('Bewerken'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Sluiten'),
          ),
        ],
      ),
    );
  }

  void _addTemplate(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditEmailTemplateScreen(
          dossierId: widget.dossierId,
        ),
      ),
    );
    
    if (result == true) {
      ref.invalidate(emailTemplatesProvider(widget.dossierId));
    }
  }

  void _editTemplate(BuildContext context, EmailTemplateModel template) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditEmailTemplateScreen(
          dossierId: widget.dossierId,
          template: template,
        ),
      ),
    );
    
    if (result == true) {
      ref.invalidate(emailTemplatesProvider(widget.dossierId));
    }
  }

  void _copyTemplate(BuildContext context, EmailTemplateModel template) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditEmailTemplateScreen(
          dossierId: widget.dossierId,
          template: template,
          isCopy: true,
        ),
      ),
    );
    
    if (result == true) {
      ref.invalidate(emailTemplatesProvider(widget.dossierId));
    }
  }

  void _deleteTemplate(BuildContext context, EmailTemplateModel template) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Template verwijderen'),
        content: Text('Weet je zeker dat je "${template.name}" wilt verwijderen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuleren'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
    
    if (confirm == true) {
      final repository = ref.read(emailTemplateRepositoryProvider);
      await repository.deleteTemplate(template.id);
      ref.invalidate(emailTemplatesProvider(widget.dossierId));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${template.name} verwijderd'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }
}

// ===== EDIT TEMPLATE SCREEN =====

class EditEmailTemplateScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final EmailTemplateModel? template;
  final bool isCopy;

  const EditEmailTemplateScreen({
    super.key,
    required this.dossierId,
    this.template,
    this.isCopy = false,
  });

  @override
  ConsumerState<EditEmailTemplateScreen> createState() => _EditEmailTemplateScreenState();
}

class _EditEmailTemplateScreenState extends ConsumerState<EditEmailTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _subjectController;
  late final TextEditingController _bodyController;
  String? _mailingType;
  bool _isSaving = false;

  bool get _isEditing => widget.template != null && !widget.isCopy;

  @override
  void initState() {
    super.initState();
    final template = widget.template;
    _nameController = TextEditingController(
      text: widget.isCopy ? '${template?.name ?? ''} (kopie)' : template?.name ?? '',
    );
    _subjectController = TextEditingController(text: template?.subject ?? '');
    _bodyController = TextEditingController(text: template?.body ?? '');
    _mailingType = template?.mailingType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Template bewerken' : 'Nieuwe template'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Naam
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Naam *',
                hintText: 'Bijv. "Verjaardagsuitnodiging"',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vul een naam in';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Type
            DropdownButtonFormField<String?>(
              value: _mailingType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: null, child: Text('Algemeen')),
                DropdownMenuItem(value: 'christmas', child: Text('🎄 Kerstkaarten')),
                DropdownMenuItem(value: 'newsletter', child: Text('📧 Nieuwsbrief')),
                DropdownMenuItem(value: 'party', child: Text('🎉 Feesten')),
                DropdownMenuItem(value: 'funeral', child: Text('🕯️ Rouwkaarten')),
              ],
              onChanged: (value) => setState(() => _mailingType = value),
            ),
            const SizedBox(height: 16),
            
            // Onderwerp
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Onderwerp',
                hintText: 'Bijv. "Uitnodiging verjaardagsfeest"',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            // Body
            TextFormField(
              controller: _bodyController,
              decoration: const InputDecoration(
                labelText: 'Bericht *',
                hintText: 'Beste {naam},\n\n...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 12,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vul een bericht in';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            
            // Placeholder tip
            Card(
              color: Colors.amber.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tip: Gebruik {naam} om automatisch de naam van de ontvanger in te vullen.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.amber[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Preview
            Text(
              'Voorbeeld',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_subjectController.text.isNotEmpty) ...[
                    Text(
                      'Onderwerp: ${_subjectController.text.replaceAll('{naam}', 'Jan Jansen')}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                  ],
                  Text(
                    _bodyController.text.replaceAll('{naam}', 'Jan Jansen'),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 100), // Ruimte voor FAB
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _save,
        icon: _isSaving 
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.save),
        label: Text(_isSaving ? 'Opslaan...' : 'Opslaan'),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    try {
      final repository = ref.read(emailTemplateRepositoryProvider);
      
      if (_isEditing) {
        // Update bestaande template
        final updated = widget.template!.copyWith(
          name: _nameController.text,
          subject: _subjectController.text,
          body: _bodyController.text,
          mailingType: _mailingType,
          updatedAt: DateTime.now(),
        );
        await repository.updateTemplate(updated);
      } else {
        // Maak nieuwe template
        await repository.createTemplate(
          dossierId: widget.dossierId,
          name: _nameController.text,
          subject: _subjectController.text,
          body: _bodyController.text,
          mailingType: _mailingType,
        );
      }
      
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fout bij opslaan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}



