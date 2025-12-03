// lib/modules/contacts/screens/import_contacts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_database.dart';
import '../../person/person_model.dart';
import '../services/contact_import_service.dart';
import '../services/duplicate_detection_service.dart';
import '../screens/contacts_screen.dart';

/// Scherm voor het importeren van contacten
class ImportContactsScreen extends ConsumerStatefulWidget {
  final String dossierId;

  const ImportContactsScreen({super.key, required this.dossierId});

  @override
  ConsumerState<ImportContactsScreen> createState() => _ImportContactsScreenState();
}

class _ImportContactsScreenState extends ConsumerState<ImportContactsScreen> {
  int _currentStep = 0;
  
  // Stap 1: Bestand
  CsvParseResult? _parseResult;
  List<VCardContact>? _vcardContacts;
  ImportFileType? _fileType;
  bool _isLoading = false;
  
  // Stap 2: Mapping
  Map<String, int> _columnMapping = {};
  
  // Stap 3: Preview
  List<PersonModel> _previewContacts = [];
  List<ImportDuplicateResult> _duplicateResults = [];
  Set<int> _selectedForImport = {};
  
  // Stap 4: Import
  bool _isImporting = false;
  int _importedCount = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacten Importeren'),
      ),
      body: Column(
        children: [
          // Stepper header
          _buildStepperHeader(theme),
          
          // Content
          Expanded(
            child: _buildStepContent(theme),
          ),
          
          // Footer
          _buildFooter(theme),
        ],
      ),
    );
  }

  Widget _buildStepperHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          _buildStepIndicator(0, 'Bestand', Icons.file_upload, theme),
          Expanded(child: Container(height: 2, color: _currentStep > 0 ? theme.primaryColor : Colors.grey[300])),
          _buildStepIndicator(1, 'Kolommen', Icons.table_chart, theme),
          Expanded(child: Container(height: 2, color: _currentStep > 1 ? theme.primaryColor : Colors.grey[300])),
          _buildStepIndicator(2, 'Preview', Icons.preview, theme),
          Expanded(child: Container(height: 2, color: _currentStep > 2 ? theme.primaryColor : Colors.grey[300])),
          _buildStepIndicator(3, 'Klaar', Icons.check_circle, theme),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, IconData icon, ThemeData theme) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;
    
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? theme.primaryColor : Colors.grey[300],
            border: isCurrent ? Border.all(color: theme.primaryColor, width: 3) : null,
          ),
          child: Icon(icon, size: 18, color: isActive ? Colors.white : Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isActive ? theme.primaryColor : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent(ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildFileStep(theme);
      case 1:
        return _buildMappingStep(theme);
      case 2:
        return _buildPreviewStep(theme);
      case 3:
        return _buildCompleteStep(theme);
      default:
        return const SizedBox();
    }
  }

  // === STAP 1: BESTAND KIEZEN ===
  Widget _buildFileStep(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.upload_file, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 24),
            Text(
              'Kies een bestand',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Ondersteunde formaten:\n'
              '• CSV/TXT - spreadsheet export\n'
              '• VCF - vCard (Outlook, Gmail, Apple)',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            
            if (_isLoading)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('Bestand kiezen'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            
            if (_parseResult != null && !_parseResult!.success) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Text(_parseResult!.errorMessage ?? 'Onbekende fout', style: const TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 48),
            
            // Outlook instructies
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text('Outlook contacten exporteren:', 
                        style: theme.textTheme.titleSmall?.copyWith(color: Colors.blue[800])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '1. Open Outlook → Personen\n'
                    '2. Selecteer contacten → Acties → Exporteren\n'
                    '3. Kies "vCard" of "CSV" formaat\n'
                    '4. Importeer het bestand hier',
                    textAlign: TextAlign.left,
                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.blue[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);
    
    try {
      final fileResult = await ContactImportService.pickImportFile();
      if (fileResult == null) {
        setState(() => _isLoading = false);
        return;
      }
      
      _fileType = fileResult.type;
      
      if (fileResult.type == ImportFileType.vcard) {
        // vCard bestand - ga direct naar preview
        final vcards = await ContactImportService.parseVCardFile(fileResult.path);
        
        if (vcards.isEmpty) {
          setState(() {
            _isLoading = false;
            _parseResult = CsvParseResult(
              success: false,
              errorMessage: 'Geen contacten gevonden in vCard bestand',
              headers: [],
              rows: [],
            );
          });
          return;
        }
        
        // Converteer naar PersonModels
        final contacts = ContactImportService.vCardsToContacts(vcards, widget.dossierId);
        
        // Check for duplicates against existing contacts
        final contactsAsync = ref.read(contactsProvider(widget.dossierId));
        final existingContacts = contactsAsync.valueOrNull ?? [];
        
        final duplicateResults = DuplicateDetectionService.findImportDuplicates(
          contacts,
          existingContacts,
        );
        
        // Select all non-duplicates by default
        final selectedSet = <int>{};
        for (int i = 0; i < duplicateResults.length; i++) {
          if (!duplicateResults[i].hasDuplicates) {
            selectedSet.add(i);
          }
        }
        
        setState(() {
          _vcardContacts = vcards;
          _previewContacts = contacts;
          _duplicateResults = duplicateResults;
          _selectedForImport = selectedSet;
          _isLoading = false;
          _currentStep = 2; // Spring naar preview (skip mapping voor vCard)
        });
      } else {
        // CSV bestand
        final result = await ContactImportService.parseCsvFile(fileResult.path);
        
        setState(() {
          _parseResult = result;
          _isLoading = false;
          
          if (result.success) {
            _columnMapping = ContactImportService.autoMapColumns(result.headers);
            _currentStep = 1;
          }
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _parseResult = CsvParseResult(
          success: false,
          errorMessage: 'Fout: $e',
          headers: [],
          rows: [],
        );
      });
    }
  }

  // === STAP 2: KOLOMMEN MAPPING ===
  Widget _buildMappingStep(ThemeData theme) {
    if (_parseResult == null) return const SizedBox();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${_parseResult!.rowCount} rijen gevonden met ${_parseResult!.columnCount} kolommen',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Koppel de kolommen aan de juiste velden:',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Mapping form
          ...ImportFieldOption.allOptions.map((field) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      '${field.label}${field.required ? ' *' : ''}',
                      style: TextStyle(
                        fontWeight: field.required ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int?>(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                      ),
                      value: _columnMapping[field.id],
                      items: [
                        const DropdownMenuItem<int?>(
                          value: null,
                          child: Text('-- Niet importeren --', style: TextStyle(color: Colors.grey)),
                        ),
                        ..._parseResult!.headers.asMap().entries.map((entry) {
                          return DropdownMenuItem<int>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          if (value == null) {
                            _columnMapping.remove(field.id);
                          } else {
                            _columnMapping[field.id] = value;
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
          
          const SizedBox(height: 24),
          
          // Preview van eerste rij
          Text('Voorbeeld eerste rij:', style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          if (_parseResult!.rows.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_columnMapping['firstName'] != null)
                    Text('Voornaam: ${_parseResult!.rows.first[_columnMapping['firstName']!]}'),
                  if (_columnMapping['lastName'] != null)
                    Text('Achternaam: ${_parseResult!.rows.first[_columnMapping['lastName']!]}'),
                  if (_columnMapping['email'] != null)
                    Text('Email: ${_parseResult!.rows.first[_columnMapping['email']!]}'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // === STAP 3: PREVIEW & DUPLICATEN ===
  Widget _buildPreviewStep(ThemeData theme) {
    return Column(
      children: [
        // Stats bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Row(
            children: [
              _buildStatChip('${_previewContacts.length}', 'Totaal', Colors.blue),
              const SizedBox(width: 16),
              _buildStatChip(
                '${_duplicateResults.where((r) => r.hasDuplicates).length}', 
                'Duplicaten', 
                Colors.orange,
              ),
              const SizedBox(width: 16),
              _buildStatChip('${_selectedForImport.length}', 'Geselecteerd', Colors.green),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedForImport = Set.from(List.generate(_previewContacts.length, (i) => i));
                  });
                },
                child: const Text('Alles selecteren'),
              ),
              TextButton(
                onPressed: () {
                  setState(() => _selectedForImport.clear());
                },
                child: const Text('Niets selecteren'),
              ),
            ],
          ),
        ),
        
        // Contact list
        Expanded(
          child: ListView.builder(
            itemCount: _previewContacts.length,
            itemBuilder: (context, index) {
              final contact = _previewContacts[index];
              final duplicateResult = _duplicateResults[index];
              final isSelected = _selectedForImport.contains(index);
              
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                color: duplicateResult.hasDuplicates ? Colors.orange.withOpacity(0.05) : null,
                child: CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        _selectedForImport.add(index);
                      } else {
                        _selectedForImport.remove(index);
                      }
                    });
                  },
                  title: Text(contact.fullName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (contact.email != null) Text(contact.email!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      if (duplicateResult.hasDuplicates) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning, size: 14, color: Colors.orange),
                              const SizedBox(width: 4),
                              Text(
                                'Mogelijk duplicaat: ${duplicateResult.bestMatch!.existingContact.fullName} (${duplicateResult.bestMatch!.matchPercentage}%)',
                                style: const TextStyle(fontSize: 11, color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  secondary: CircleAvatar(
                    backgroundColor: duplicateResult.hasDuplicates 
                        ? Colors.orange.withOpacity(0.2) 
                        : theme.primaryColor.withOpacity(0.1),
                    child: Text(
                      contact.firstName.isNotEmpty ? contact.firstName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: duplicateResult.hasDuplicates ? Colors.orange : theme.primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  // === STAP 4: KLAAR ===
  Widget _buildCompleteStep(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 100, color: Colors.green[400]),
          const SizedBox(height: 24),
          Text(
            'Import voltooid!',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            '$_importedCount contacten geïmporteerd',
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.done),
            label: const Text('Terug naar contacten'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    if (_currentStep == 3) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            TextButton.icon(
              onPressed: () => setState(() => _currentStep--),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Terug'),
            ),
          const Spacer(),
          if (_currentStep == 1)
            ElevatedButton.icon(
              onPressed: _canProceedFromMapping() ? _processPreview : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Preview'),
            ),
          if (_currentStep == 2)
            ElevatedButton.icon(
              onPressed: _selectedForImport.isNotEmpty && !_isImporting 
                  ? _performImport 
                  : null,
              icon: _isImporting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.file_download),
              label: Text(_isImporting ? 'Importeren...' : 'Importeer (${_selectedForImport.length})'),
            ),
        ],
      ),
    );
  }

  bool _canProceedFromMapping() {
    return _columnMapping.containsKey('firstName') || _columnMapping.containsKey('lastName');
  }

  Future<void> _processPreview() async {
    if (_parseResult == null) return;
    
    // Convert to contacts
    _previewContacts = ContactImportService.convertToContacts(
      dossierId: widget.dossierId,
      headers: _parseResult!.headers,
      rows: _parseResult!.rows,
      columnMapping: _columnMapping,
    );
    
    // Check for duplicates
    final contactsAsync = ref.read(contactsProvider(widget.dossierId));
    final existingContacts = contactsAsync.valueOrNull ?? [];
    
    _duplicateResults = DuplicateDetectionService.findImportDuplicates(
      _previewContacts,
      existingContacts,
    );
    
    // Select all non-duplicates by default
    _selectedForImport = {};
    for (int i = 0; i < _duplicateResults.length; i++) {
      if (!_duplicateResults[i].hasDuplicates) {
        _selectedForImport.add(i);
      }
    }
    
    setState(() => _currentStep = 2);
  }

  Future<void> _performImport() async {
    setState(() => _isImporting = true);
    
    try {
      final db = ref.read(appDatabaseProvider);
      int count = 0;
      
      for (final index in _selectedForImport) {
        final contact = _previewContacts[index];
        await db.insert('persons', contact.toMap());
        count++;
      }
      
      _importedCount = count;
      ref.invalidate(contactsProvider(widget.dossierId));
      
      setState(() {
        _isImporting = false;
        _currentStep = 3;
      });
    } catch (e) {
      setState(() => _isImporting = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Import mislukt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

