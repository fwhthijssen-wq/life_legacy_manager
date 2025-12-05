// lib/modules/money/screens/bank_accounts/bank_account_detail_screen.dart

import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/ocr/document_scanner_widget.dart';
import '../../../../core/ocr/document_patterns.dart';
import '../../../../core/widgets/date_picker_field.dart';
import '../../models/bank_account_model.dart';
import '../../models/money_item_model.dart';
import '../../providers/money_providers.dart';
import '../../repositories/money_repository.dart';

class BankAccountDetailScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final String? moneyItemId; // null = nieuwe rekening
  final String? personId; // Voor nieuwe rekening
  final String? personName; // Voor automatisch invullen rekeninghouder

  const BankAccountDetailScreen({
    super.key,
    required this.dossierId,
    this.moneyItemId,
    this.personId,
    this.personName,
  });

  @override
  ConsumerState<BankAccountDetailScreen> createState() => _BankAccountDetailScreenState();
}

class _BankAccountDetailScreenState extends ConsumerState<BankAccountDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _bankNameController = TextEditingController();
  final _ibanController = TextEditingController();
  final _bicController = TextEditingController();
  final _accountHolderController = TextEditingController();
  final _jointHolderController = TextEditingController();
  final _balanceController = TextEditingController();
  final _servicePhoneController = TextEditingController();
  final _serviceEmailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _loginUrlController = TextEditingController();
  final _credentialsDetailController = TextEditingController();
  final _cardLocationController = TextEditingController();
  final _deathInstructionsController = TextEditingController();
  final _notesController = TextEditingController();

  BankAccountType _accountType = BankAccountType.checking;
  bool _isJointAccount = false;
  bool _hasCard = false;
  CredentialsLocation? _credentialsLocation;
  DeathAction? _deathAction;
  MoneyItemStatus _status = MoneyItemStatus.notStarted;

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isNew = true;
  BankAccountModel? _existingAccount;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.moneyItemId != null) {
      final account = await MoneyRepository.getBankAccount(widget.moneyItemId!);
      if (account != null) {
        _existingAccount = account;
        _isNew = false;
        _populateForm(account);
      }
    } else if (widget.personName != null) {
      // Bij nieuwe rekening: vul automatisch de rekeninghouder in
      _accountHolderController.text = widget.personName!;
    }
    setState(() => _isLoading = false);
  }

  void _populateForm(BankAccountModel account) {
    _bankNameController.text = account.bankName;
    _ibanController.text = account.iban ?? '';
    _bicController.text = account.bicSwift ?? '';
    _accountHolderController.text = account.accountHolder ?? '';
    _jointHolderController.text = account.jointHolderName ?? '';
    _balanceController.text = account.balance?.toString() ?? '';
    _servicePhoneController.text = account.servicePhone ?? '';
    _serviceEmailController.text = account.serviceEmail ?? '';
    _websiteController.text = account.website ?? '';
    _loginUrlController.text = account.loginUrl ?? '';
    _credentialsDetailController.text = account.credentialsLocationDetail ?? '';
    _cardLocationController.text = account.cardLocation ?? '';
    _deathInstructionsController.text = account.deathInstructions ?? '';
    _notesController.text = account.notes ?? '';

    _accountType = account.accountType;
    _isJointAccount = account.isJointAccount;
    _hasCard = account.hasCard;
    _credentialsLocation = account.credentialsLocation;
    _deathAction = account.deathAction;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bankNameController.dispose();
    _ibanController.dispose();
    _bicController.dispose();
    _accountHolderController.dispose();
    _jointHolderController.dispose();
    _balanceController.dispose();
    _servicePhoneController.dispose();
    _serviceEmailController.dispose();
    _websiteController.dispose();
    _loginUrlController.dispose();
    _credentialsDetailController.dispose();
    _cardLocationController.dispose();
    _deathInstructionsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Bankrekening')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isNew ? 'Nieuwe bankrekening' : _bankNameController.text),
        actions: [
          // Document scan/import knop
          IconButton(
            icon: const Icon(Icons.document_scanner),
            tooltip: Platform.isAndroid || Platform.isIOS 
                ? 'Scan bankafschrift' 
                : 'Import PDF',
            onPressed: _scanDocument,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
            tooltip: 'Opslaan',
          ),
          if (!_isNew)
            PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'delete') _confirmDelete();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Verwijderen', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Basis'),
            Tab(text: 'Contact'),
            Tab(text: "Incasso's"),
            Tab(text: 'Nabestaanden'),
            Tab(text: 'Documenten'),
            Tab(text: 'Notities'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildBasicTab(theme),
            _buildContactTab(theme),
            _buildDirectDebitsTab(theme),
            _buildSurvivorsTab(theme),
            _buildDocumentsTab(theme),
            _buildNotesTab(theme),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildBasicTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Banknaam
        DropdownButtonFormField<String>(
          value: KnownBanks.banks.contains(_bankNameController.text)
              ? _bankNameController.text
              : (_bankNameController.text.isNotEmpty ? 'Anders' : null),
          decoration: const InputDecoration(
            labelText: 'Bank *',
            prefixIcon: Icon(Icons.account_balance),
          ),
          items: KnownBanks.banks
              .map((bank) => DropdownMenuItem(value: bank, child: Text(bank)))
              .toList(),
          onChanged: (value) {
            if (value == 'Anders') {
              _showCustomBankDialog();
            } else if (value != null) {
              _bankNameController.text = value;
            }
          },
          validator: (value) {
            if (_bankNameController.text.isEmpty) {
              return 'Selecteer een bank';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Type rekening
        DropdownButtonFormField<BankAccountType>(
          value: _accountType,
          decoration: const InputDecoration(
            labelText: 'Type rekening *',
            prefixIcon: Icon(Icons.credit_card),
          ),
          items: BankAccountType.values
              .map((type) => DropdownMenuItem(value: type, child: Text(type.label)))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _accountType = value);
          },
        ),
        const SizedBox(height: 16),

        // IBAN
        IbanField(
          controller: _ibanController,
          labelText: 'IBAN',
        ),
        const SizedBox(height: 16),

        // BIC/SWIFT
        TextFormField(
          controller: _bicController,
          decoration: const InputDecoration(
            labelText: 'BIC/SWIFT (optioneel)',
            prefixIcon: Icon(Icons.language),
          ),
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),

        // Rekeninghouder
        TextFormField(
          controller: _accountHolderController,
          decoration: const InputDecoration(
            labelText: 'Rekeninghouder',
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),

        // Gezamenlijke rekening
        SwitchListTile(
          title: const Text('Gezamenlijke rekening'),
          subtitle: const Text('Rekening met partner of ander persoon'),
          value: _isJointAccount,
          onChanged: (value) => setState(() => _isJointAccount = value),
        ),

        if (_isJointAccount) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _jointHolderController,
            decoration: const InputDecoration(
              labelText: 'Naam tweede rekeninghouder',
              prefixIcon: Icon(Icons.person_add),
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Saldo
        AmountField(
          controller: _balanceController,
          labelText: 'Huidig saldo (optioneel)',
          hintText: 'Dit wordt niet automatisch bijgewerkt',
          allowNegative: true,
        ),
      ],
    );
  }

  Widget _buildContactTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Klantenservice',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        PhoneField(
          controller: _servicePhoneController,
          labelText: 'Telefoonnummer',
        ),
        const SizedBox(height: 16),

        EmailField(
          controller: _serviceEmailController,
          labelText: 'E-mail',
        ),
        const SizedBox(height: 16),

        WebsiteField(
          controller: _websiteController,
          labelText: 'Website',
        ),
        const SizedBox(height: 24),

        Text(
          'Toegang internetbankieren',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        WebsiteField(
          controller: _loginUrlController,
          labelText: 'Login URL',
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<CredentialsLocation>(
          value: _credentialsLocation,
          decoration: const InputDecoration(
            labelText: 'Locatie inloggegevens',
            prefixIcon: Icon(Icons.vpn_key),
          ),
          items: CredentialsLocation.values
              .map((loc) => DropdownMenuItem(value: loc, child: Text(loc.label)))
              .toList(),
          onChanged: (value) => setState(() => _credentialsLocation = value),
        ),
        const SizedBox(height: 16),

        if (_credentialsLocation != null)
          TextFormField(
            controller: _credentialsDetailController,
            decoration: InputDecoration(
              labelText: _getCredentialsDetailLabel(),
              prefixIcon: const Icon(Icons.info_outline),
            ),
          ),
        const SizedBox(height: 24),

        Text(
          'Bankpas',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        SwitchListTile(
          title: const Text('Bankpas aanwezig'),
          value: _hasCard,
          onChanged: (value) => setState(() => _hasCard = value),
        ),

        if (_hasCard) ...[
          const SizedBox(height: 8),
          TextFormField(
            controller: _cardLocationController,
            decoration: const InputDecoration(
              labelText: 'Locatie bankpas',
              prefixIcon: Icon(Icons.credit_card),
              helperText: 'LET OP: Sla NOOIT pincodes op!',
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDirectDebitsTab(ThemeData theme) {
    // TODO: Implementeer automatische incasso's lijst
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Automatische incasso\'s',
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Sla eerst de basisgegevens op',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          if (!_isNew) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Add direct debit dialog
              },
              icon: const Icon(Icons.add),
              label: const Text('Incasso toevoegen'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSurvivorsTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.amber[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[800]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Deze informatie helpt nabestaanden bij het afhandelen van financiële zaken.',
                    style: TextStyle(color: Colors.amber[900]),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Wat moet er gebeuren bij overlijden?',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<DeathAction>(
          value: _deathAction,
          decoration: const InputDecoration(
            labelText: 'Actie bij overlijden',
            prefixIcon: Icon(Icons.assignment),
          ),
          items: DeathAction.values
              .map((action) => DropdownMenuItem(value: action, child: Text(action.label)))
              .toList(),
          onChanged: (value) => setState(() => _deathAction = value),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _deathInstructionsController,
          decoration: const InputDecoration(
            labelText: 'Speciale instructies',
            prefixIcon: Icon(Icons.note),
            alignLabelWithHint: true,
          ),
          maxLines: 4,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 24),

        // TODO: Begunstigden selector
        Text(
          'Begunstigden / Erfgenamen',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Koppel personen die toegang moeten krijgen tot deze rekening.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            // TODO: Open person selector
          },
          icon: const Icon(Icons.person_add),
          label: const Text('Persoon toevoegen'),
        ),
      ],
    );
  }

  Widget _buildDocumentsTab(ThemeData theme) {
    // TODO: Implementeer documenten lijst
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Documenten',
            style: theme.textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Voeg rekeningovereenkomsten, afschriften toe',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          if (!_isNew) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Add document dialog
              },
              icon: const Icon(Icons.upload_file),
              label: const Text('Document toevoegen'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextFormField(
        controller: _notesController,
        decoration: const InputDecoration(
          labelText: 'Notities',
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Status dropdown
          Expanded(
            child: DropdownButtonFormField<MoneyItemStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: MoneyItemStatus.values
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.label)))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _status = value);
              },
            ),
          ),
          const SizedBox(width: 16),
          // Opslaan knop
          ElevatedButton.icon(
            onPressed: _isSaving ? null : _save,
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: const Text('Opslaan'),
          ),
        ],
      ),
    );
  }

  String _getCredentialsDetailLabel() {
    switch (_credentialsLocation) {
      case CredentialsLocation.passwordManager:
        return 'Welke wachtwoordmanager?';
      case CredentialsLocation.paper:
        return 'Waar bewaard?';
      case CredentialsLocation.notary:
        return 'Naam notaris';
      case CredentialsLocation.other:
      default:
        return 'Toelichting';
    }
  }

  Future<void> _showCustomBankDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Andere bank'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Naam bank',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      setState(() {
        _bankNameController.text = result;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vul de verplichte velden in')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (_isNew) {
        // Nieuwe rekening aanmaken
        // TODO: Get actual person ID from household
        await MoneyRepository.createBankAccount(
          dossierId: widget.dossierId,
          personId: 'temp_person_id', // Dit moet de echte persoon zijn
          bankName: _bankNameController.text,
          accountType: _accountType,
          iban: _ibanController.text.isNotEmpty ? _ibanController.text : null,
          accountHolder: _accountHolderController.text.isNotEmpty
              ? _accountHolderController.text
              : null,
        );
      } else if (_existingAccount != null) {
        // Bestaande rekening updaten
        final updated = _existingAccount!.copyWith(
          bankName: _bankNameController.text,
          accountType: _accountType,
          iban: _ibanController.text.isNotEmpty ? _ibanController.text : null,
          bicSwift: _bicController.text.isNotEmpty ? _bicController.text : null,
          accountHolder: _accountHolderController.text.isNotEmpty
              ? _accountHolderController.text
              : null,
          isJointAccount: _isJointAccount,
          jointHolderName: _jointHolderController.text.isNotEmpty
              ? _jointHolderController.text
              : null,
          balance: _balanceController.text.isNotEmpty
              ? double.tryParse(_balanceController.text)
              : null,
          servicePhone: _servicePhoneController.text.isNotEmpty
              ? _servicePhoneController.text
              : null,
          serviceEmail: _serviceEmailController.text.isNotEmpty
              ? _serviceEmailController.text
              : null,
          website: _websiteController.text.isNotEmpty
              ? _websiteController.text
              : null,
          loginUrl: _loginUrlController.text.isNotEmpty
              ? _loginUrlController.text
              : null,
          credentialsLocation: _credentialsLocation,
          credentialsLocationDetail: _credentialsDetailController.text.isNotEmpty
              ? _credentialsDetailController.text
              : null,
          hasCard: _hasCard,
          cardLocation: _cardLocationController.text.isNotEmpty
              ? _cardLocationController.text
              : null,
          deathAction: _deathAction,
          deathInstructions: _deathInstructionsController.text.isNotEmpty
              ? _deathInstructionsController.text
              : null,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );
        await MoneyRepository.updateBankAccount(updated);
        await MoneyRepository.updateItemStatus(_existingAccount!.moneyItemId, _status);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bankrekening opgeslagen')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fout bij opslaan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bankrekening verwijderen'),
        content: const Text(
          'Weet je zeker dat je deze bankrekening wilt verwijderen? '
          'Alle gekoppelde documenten en incasso\'s worden ook verwijderd.',
        ),
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

    if (confirmed == true && widget.moneyItemId != null) {
      await MoneyRepository.deleteItem(widget.moneyItemId!);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  /// Scan een bankafschrift en vul velden automatisch in
  Future<void> _scanDocument() async {
    final data = await showDocumentScanner(
      context,
      documentType: DocumentType.bankStatement,
    );

    if (data != null && data.hasData) {
      setState(() {
        // IBAN
        if (data.iban != null && _ibanController.text.isEmpty) {
          _ibanController.text = data.iban!;
        }
        
        // BIC
        if (data.bic != null && _bicController.text.isEmpty) {
          _bicController.text = data.bic!;
        }
        
        // Bank naam
        if (data.bankName != null && _bankNameController.text.isEmpty) {
          _bankNameController.text = data.bankName!;
        }
        
        // Saldo
        if (data.balance != null && _balanceController.text.isEmpty) {
          _balanceController.text = data.balance!.toStringAsFixed(2);
        }
        
        // Telefoon
        if (data.phone != null && _servicePhoneController.text.isEmpty) {
          _servicePhoneController.text = data.phone!;
        }
        
        // Email
        if (data.email != null && _serviceEmailController.text.isEmpty) {
          _serviceEmailController.text = data.email!;
        }
        
        // Website
        if (data.website != null && _websiteController.text.isEmpty) {
          _websiteController.text = data.website!;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Gegevens overgenomen van scan'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    }
  }
}


