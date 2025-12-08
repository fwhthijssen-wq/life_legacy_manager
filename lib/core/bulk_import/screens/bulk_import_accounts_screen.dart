// lib/core/bulk_import/screens/bulk_import_accounts_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../models/scanned_account.dart';
import '../services/multi_account_scanner.dart';
import '../../app_database.dart';
import '../../../modules/money/models/bank_account_model.dart';
import '../../../modules/money/repositories/money_repository.dart';

class BulkImportAccountsScreen extends ConsumerStatefulWidget {
  final String dossierId;
  
  const BulkImportAccountsScreen({
    super.key,
    required this.dossierId,
  });

  @override
  ConsumerState<BulkImportAccountsScreen> createState() => _BulkImportAccountsScreenState();
}

class _BulkImportAccountsScreenState extends ConsumerState<BulkImportAccountsScreen> {
  final MultiAccountScanner _scanner = MultiAccountScanner();
  
  MultiAccountScanResult? _scanResult;
  List<PersonInfo> _dossierPersons = [];
  
  bool _isScanning = false;
  bool _isImporting = false;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadPersons();
  }
  
  Future<void> _loadPersons() async {
    final db = ref.read(appDatabaseProvider);
    
    // Haal dossierleden op
    final householdMembers = await db.rawQuery('''
      SELECT hm.person_id, p.first_name, p.last_name
      FROM household_members hm
      JOIN persons p ON hm.person_id = p.id
      WHERE hm.dossier_id = ?
      ORDER BY hm.is_primary DESC, p.first_name
    ''', [widget.dossierId]);
    
    print('🔍 Bulk Import: Gevonden ${householdMembers.length} personen voor dossier ${widget.dossierId}');
    
    setState(() {
      _dossierPersons = householdMembers.map((row) {
        final firstName = row['first_name'] as String? ?? '';
        final lastName = row['last_name'] as String? ?? '';
        print('  - Persoon: $firstName $lastName (${row['person_id']})');
        return PersonInfo(
          id: row['person_id'] as String,
          fullName: '$firstName $lastName'.trim(),
          firstName: firstName,
          lastName: lastName,
        );
      }).toList();
    });
  }
  
  Future<void> _selectAndScanDocument() async {
    setState(() {
      _isScanning = true;
      _error = null;
    });
    
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      
      if (result == null || result.files.single.path == null) {
        setState(() => _isScanning = false);
        return;
      }
      
      final file = File(result.files.single.path!);
      final scanResult = await _scanner.scanPdf(file);
      
      if (scanResult == null || !scanResult.hasAccounts) {
        setState(() {
          _error = 'Geen bankrekeningen gevonden in dit document.';
          _isScanning = false;
        });
        return;
      }
      
      // Match met dossierleden
      await _scanner.matchWithPersons(scanResult, _dossierPersons);
      
      setState(() {
        _scanResult = scanResult;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Fout bij scannen: $e';
        _isScanning = false;
      });
    }
  }
  
  Future<void> _importSelectedAccounts() async {
    print('🚀 Import gestart');
    
    if (_scanResult == null) {
      print('❌ Geen scan result');
      return;
    }
    
    final selectedAccounts = _scanResult!.accounts.where((a) => a.isSelected).toList();
    print('📋 ${selectedAccounts.length} rekeningen geselecteerd');
    
    if (selectedAccounts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecteer minimaal één rekening')),
      );
      return;
    }
    
    // Check of alle accounts een persoon hebben
    final unassigned = selectedAccounts.where((a) => a.matchedPersonId == null).toList();
    print('⚠️ ${unassigned.length} rekeningen zonder persoon');
    
    for (final acc in selectedAccounts) {
      print('  - ${acc.iban}: persoon=${acc.matchedPersonId ?? "GEEN"}');
    }
    
    if (unassigned.isNotEmpty) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Rekeningen zonder persoon'),
          content: Text(
            '${unassigned.length} rekening(en) hebben geen persoon toegewezen.\n\n'
            'Wil je toch doorgaan? Deze rekeningen worden overgeslagen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuleren'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Doorgaan'),
            ),
          ],
        ),
      );
      
      print('📝 Dialoog resultaat: $proceed');
      if (proceed != true) return;
    }
    
    setState(() => _isImporting = true);
    print('⏳ Start importeren...');
    
    try {
      int imported = 0;
      int skipped = 0;
      
      for (final account in selectedAccounts) {
        if (account.matchedPersonId == null) {
          print('⏭️ Skip ${account.iban} - geen persoon');
          skipped++;
          continue;
        }
        
        // Check of rekening al bestaat
        final existing = await _checkExistingAccount(account.iban);
        if (existing) {
          print('⏭️ Skip ${account.iban} - bestaat al');
          skipped++;
          continue;
        }
        
        // Maak bankrekening aan
        print('💾 Aanmaken: ${account.iban} voor ${account.matchedPersonId}');
        await _createBankAccount(account);
        imported++;
        print('✅ Aangemaakt: ${account.iban}');
      }
      
      print('🎉 Klaar: $imported geïmporteerd, $skipped overgeslagen');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$imported rekening(en) geïmporteerd${skipped > 0 ? ', $skipped overgeslagen' : ''}'),
          backgroundColor: Colors.green,
        ),
      );
      
      Navigator.pop(context, true);
    } catch (e, stackTrace) {
      print('❌ Fout bij importeren: $e');
      print('Stack: $stackTrace');
      setState(() {
        _error = 'Fout bij importeren: $e';
        _isImporting = false;
      });
    }
  }
  
  Future<bool> _checkExistingAccount(String iban) async {
    final db = ref.read(appDatabaseProvider);
    final result = await db.query(
      'bank_accounts',
      where: 'iban = ?',
      whereArgs: [iban],
    );
    return result.isNotEmpty;
  }
  
  Future<void> _createBankAccount(ScannedAccount account) async {
    // Bepaal account type
    BankAccountType accountType = BankAccountType.checking;
    if (account.accountType?.toLowerCase().contains('spaar') == true) {
      accountType = BankAccountType.savings;
    } else if (account.accountType?.toLowerCase().contains('deposito') == true) {
      accountType = BankAccountType.deposit;
    } else if (account.accountType?.toLowerCase().contains('belegg') == true) {
      accountType = BankAccountType.investment;
    }
    
    await MoneyRepository.createBankAccount(
      dossierId: widget.dossierId,
      personId: account.matchedPersonId!,
      bankName: account.bankName ?? 'Onbekend',
      accountType: accountType,
      iban: account.iban,
      accountHolder: account.accountHolder,
      balance: account.balance,
    );
  }
  
  void _toggleAccount(int index) {
    setState(() {
      final account = _scanResult!.accounts[index];
      _scanResult!.accounts[index] = account.copyWith(
        isSelected: !account.isSelected,
      );
    });
  }
  
  void _assignPerson(int index, String personId, String personName) {
    setState(() {
      final account = _scanResult!.accounts[index];
      _scanResult!.accounts[index] = account.copyWith(
        matchedPersonId: personId,
        matchedPersonName: personName,
        matchConfidence: 1.0,
      );
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bankrekeningen importeren'),
        actions: [
          if (_scanResult != null && _scanResult!.selectedCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton.icon(
                onPressed: _isImporting ? null : _importSelectedAccounts,
                icon: _isImporting 
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check),
                label: Text('${_scanResult!.selectedCount} importeren'),
              ),
            ),
        ],
      ),
      body: _buildBody(theme),
    );
  }
  
  Widget _buildBody(ThemeData theme) {
    if (_isScanning) {
      return _buildScanningState(theme);
    }
    
    if (_scanResult == null) {
      return _buildInitialState(theme);
    }
    
    return _buildResultsState(theme);
  }
  
  Widget _buildInitialState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance,
                size: 60,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bankrekeningen importeren',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload een jaaroverzicht of bankafschrift.\n'
              'Alle rekeningen worden automatisch herkend.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[700]),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _selectAndScanDocument,
              icon: const Icon(Icons.upload_file),
              label: const Text('Selecteer PDF'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ondersteund: PDF bankafschriften',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildScanningState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Document analyseren...',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Bankrekeningen worden herkend',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResultsState(ThemeData theme) {
    final result = _scanResult!;
    
    return Column(
      children: [
        // Header met statistieken
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            border: Border(
              bottom: BorderSide(color: Colors.green[200]!),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.green[700]),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${result.accounts.length} rekening(en) gevonden',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (result.documentName != null)
                      Text(
                        result.documentName!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: _selectAndScanDocument,
                icon: const Icon(Icons.refresh),
                label: const Text('Opnieuw'),
              ),
            ],
          ),
        ),
        
        // Totaal saldo
        if (result.totalSelectedBalance > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Totaal saldo geselecteerd:',
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  '€ ${result.totalSelectedBalance.toStringAsFixed(2)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        
        // Rekeningen lijst
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: result.accounts.length,
            itemBuilder: (context, index) {
              return _buildAccountCard(theme, result.accounts[index], index);
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildAccountCard(ThemeData theme, ScannedAccount account, int index) {
    final isHighConfidence = account.confidence >= 0.8;
    final hasPerson = account.matchedPersonId != null;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: account.isSelected 
              ? Colors.blue 
              : Colors.grey[300]!,
          width: account.isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _toggleAccount(index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Checkbox
                  Checkbox(
                    value: account.isSelected,
                    onChanged: (_) => _toggleAccount(index),
                  ),
                  
                  // Bank logo placeholder
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getBankColor(account.bankName),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        account.bankName?.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Bank info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.bankName ?? 'Onbekende bank',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          account.iban,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontFamily: 'monospace',
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Saldo
                  if (account.balance != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '€ ${account.balance!.toStringAsFixed(2)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: account.balance! >= 0 
                                ? Colors.green[700] 
                                : Colors.red[700],
                          ),
                        ),
                        if (account.accountType != null)
                          Text(
                            account.accountType!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                ],
              ),
              
              const Divider(height: 24),
              
              // Rekeninghouder
              if (account.accountHolder != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        'Gevonden: ${account.accountHolder}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              
              // Persoon toewijzing
              Row(
                children: [
                  Icon(
                    hasPerson ? Icons.person : Icons.person_add,
                    size: 18,
                    color: hasPerson ? Colors.green[600] : Colors.orange[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: hasPerson
                        ? Row(
                            children: [
                              Text(
                                'Koppel aan: ${account.matchedPersonName}',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              if (account.matchConfidence < 1.0)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'auto',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : Text(
                            'Geen persoon gekoppeld',
                            style: TextStyle(
                              color: Colors.orange[700],
                            ),
                          ),
                  ),
                  _dossierPersons.isEmpty
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red[300]!),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.red[50],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.warning, size: 16, color: Colors.red[700]),
                              const SizedBox(width: 4),
                              Text(
                                'Geen dossierleden',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        )
                      : PopupMenuButton<String>(
                          onSelected: (personId) {
                            final person = _dossierPersons.firstWhere(
                              (p) => p.id == personId,
                            );
                            _assignPerson(index, personId, person.fullName);
                          },
                          itemBuilder: (context) => _dossierPersons.map((person) {
                            return PopupMenuItem(
                              value: person.id,
                              child: Row(
                                children: [
                                  Icon(
                                    person.id == account.matchedPersonId
                                        ? Icons.check_circle
                                        : Icons.person_outline,
                                    color: person.id == account.matchedPersonId
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(person.fullName),
                                ],
                              ),
                            );
                          }).toList(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  hasPerson ? 'Wijzig' : 'Kies persoon',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                              ],
                            ),
                          ),
                        ),
                ],
              ),
              
              // Confidence indicator
              if (!isHighConfidence)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.orange[600]),
                      const SizedBox(width: 4),
                      Text(
                        'Lagere zekerheid - controleer de gegevens',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Color _getBankColor(String? bankName) {
    if (bankName == null) return Colors.grey;
    
    final colors = {
      'ING': Colors.orange,
      'ABN AMRO': Colors.green[700]!,
      'Rabobank': Colors.blue[800]!,
      'SNS': Colors.purple,
      'ASN Bank': Colors.green,
      'Triodos Bank': Colors.teal,
      'Knab': Colors.deepPurple,
      'bunq': Colors.blue,
      'RegioBank': Colors.orange[800]!,
    };
    
    return colors[bankName] ?? Colors.blueGrey;
  }
}

