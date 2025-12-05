// lib/modules/money/screens/pensions/pension_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_database.dart';
import '../../../../core/widgets/date_picker_field.dart';
import '../../models/pension_model.dart';
import '../../models/money_item_model.dart';
import '../../repositories/money_repository.dart';

class PensionDetailScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final String pensionId;
  final String moneyItemId;
  final bool isNew;
  final String? personId;
  final String? personName;

  const PensionDetailScreen({
    super.key,
    required this.dossierId,
    required this.pensionId,
    required this.moneyItemId,
    this.isNew = false,
    this.personId,
    this.personName,
  });

  @override
  ConsumerState<PensionDetailScreen> createState() => _PensionDetailScreenState();
}

class _PensionDetailScreenState extends ConsumerState<PensionDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasChanges = false;

  PensionModel? _pension;
  MoneyItemModel? _moneyItem;

  // Basisgegevens
  PensionType _pensionType = PensionType.other;
  final _providerController = TextEditingController();
  final _participantNumberController = TextEditingController();
  final _participantNameController = TextEditingController();
  final _employerController = TextEditingController();
  final _accrualStartController = TextEditingController();
  final _accrualEndController = TextEditingController();

  // Pensioenopbouw
  final _currentCapitalController = TextEditingController();
  final _expectedPayoutController = TextEditingController();
  final _pensionStartDateController = TextEditingController();
  bool _hasPartnerPension = false;
  final _partnerPercentageController = TextEditingController();
  final _partnerNameController = TextEditingController();
  bool _hasOrphanPension = false;
  bool _hasDisabilityPension = false;

  // Financieel
  final _monthlyContributionController = TextEditingController();
  final _paidByController = TextEditingController();
  final _taxTreatmentController = TextEditingController();
  bool _allowsExtraContributions = false;

  // Nabestaanden
  bool _hasSurvivorPension = false;
  final _survivorPayoutController = TextEditingController();
  final _survivorConditionsController = TextEditingController();
  final _surrenderValueController = TextEditingController();
  final _claimContactPersonController = TextEditingController();
  final _claimContactPhoneController = TextEditingController();
  final _claimContactEmailController = TextEditingController();
  final _survivorInstructionsController = TextEditingController();

  // Contact
  final _servicePhoneController = TextEditingController();
  final _serviceEmailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _portalUrlController = TextEditingController();

  // Notities
  final _notesController = TextEditingController();

  // Status
  MoneyItemStatus _status = MoneyItemStatus.notStarted;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _providerController.dispose();
    _participantNumberController.dispose();
    _participantNameController.dispose();
    _employerController.dispose();
    _accrualStartController.dispose();
    _accrualEndController.dispose();
    _currentCapitalController.dispose();
    _expectedPayoutController.dispose();
    _pensionStartDateController.dispose();
    _partnerPercentageController.dispose();
    _partnerNameController.dispose();
    _monthlyContributionController.dispose();
    _paidByController.dispose();
    _taxTreatmentController.dispose();
    _survivorPayoutController.dispose();
    _survivorConditionsController.dispose();
    _surrenderValueController.dispose();
    _claimContactPersonController.dispose();
    _claimContactPhoneController.dispose();
    _claimContactEmailController.dispose();
    _survivorInstructionsController.dispose();
    _servicePhoneController.dispose();
    _serviceEmailController.dispose();
    _websiteController.dispose();
    _portalUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = ref.read(appDatabaseProvider);
    final repo = MoneyRepository(db);

    final pension = await repo.getPension(widget.pensionId);
    final moneyItem = await repo.getMoneyItem(widget.moneyItemId);

    if (pension != null && moneyItem != null) {
      setState(() {
        _pension = pension;
        _moneyItem = moneyItem;
        _populateFields(pension, moneyItem);
        _isLoading = false;
      });
    } else {
      // Bij nieuw pensioen: vul automatisch de naam deelnemer in
      if (widget.isNew && widget.personName != null) {
        _participantNameController.text = widget.personName!;
      }
      setState(() => _isLoading = false);
    }
  }

  void _populateFields(PensionModel pension, MoneyItemModel moneyItem) {
    _pensionType = pension.pensionType;
    _providerController.text = pension.provider ?? '';
    _participantNumberController.text = pension.participantNumber ?? '';
    _participantNameController.text = pension.participantName ?? '';
    _employerController.text = pension.employer ?? '';
    _accrualStartController.text = pension.accrualPeriodStart ?? '';
    _accrualEndController.text = pension.accrualPeriodEnd ?? '';

    _currentCapitalController.text = pension.currentCapital?.toStringAsFixed(2) ?? '';
    _expectedPayoutController.text = pension.expectedMonthlyPayout?.toStringAsFixed(2) ?? '';
    _pensionStartDateController.text = pension.pensionStartDate ?? '';
    _hasPartnerPension = pension.hasPartnerPension;
    _partnerPercentageController.text = pension.partnerPensionPercentage?.toString() ?? '';
    _partnerNameController.text = pension.partnerName ?? '';
    _hasOrphanPension = pension.hasOrphanPension;
    _hasDisabilityPension = pension.hasDisabilityPension;

    _monthlyContributionController.text = pension.monthlyContribution?.toStringAsFixed(2) ?? '';
    _paidByController.text = pension.paidBy ?? '';
    _taxTreatmentController.text = pension.taxTreatment ?? '';
    _allowsExtraContributions = pension.allowsExtraContributions;

    _hasSurvivorPension = pension.hasSurvivorPension;
    _survivorPayoutController.text = pension.survivorPayoutAmount?.toStringAsFixed(2) ?? '';
    _survivorConditionsController.text = pension.survivorConditions ?? '';
    _surrenderValueController.text = pension.surrenderValue?.toStringAsFixed(2) ?? '';
    _claimContactPersonController.text = pension.claimContactPerson ?? '';
    _claimContactPhoneController.text = pension.claimContactPhone ?? '';
    _claimContactEmailController.text = pension.claimContactEmail ?? '';
    _survivorInstructionsController.text = pension.survivorInstructions ?? '';

    _servicePhoneController.text = pension.servicePhone ?? '';
    _serviceEmailController.text = pension.serviceEmail ?? '';
    _websiteController.text = pension.website ?? '';
    _portalUrlController.text = pension.portalUrl ?? '';

    _notesController.text = pension.notes ?? '';
    _status = moneyItem.status;
  }

  Future<void> _save() async {
    if (_providerController.text.isEmpty && _pensionType == PensionType.other) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vul de pensioenuitvoerder in of selecteer een type'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final db = ref.read(appDatabaseProvider);
    final repo = MoneyRepository(db);

    final updatedPension = PensionModel(
      id: widget.pensionId,
      moneyItemId: widget.moneyItemId,
      pensionType: _pensionType,
      provider: _providerController.text.isNotEmpty ? _providerController.text : null,
      participantNumber: _participantNumberController.text.isNotEmpty ? _participantNumberController.text : null,
      participantName: _participantNameController.text.isNotEmpty ? _participantNameController.text : null,
      employer: _employerController.text.isNotEmpty ? _employerController.text : null,
      accrualPeriodStart: _accrualStartController.text.isNotEmpty ? _accrualStartController.text : null,
      accrualPeriodEnd: _accrualEndController.text.isNotEmpty ? _accrualEndController.text : null,
      currentCapital: double.tryParse(_currentCapitalController.text),
      expectedMonthlyPayout: double.tryParse(_expectedPayoutController.text),
      pensionStartDate: _pensionStartDateController.text.isNotEmpty ? _pensionStartDateController.text : null,
      hasPartnerPension: _hasPartnerPension,
      partnerPensionPercentage: int.tryParse(_partnerPercentageController.text),
      partnerName: _partnerNameController.text.isNotEmpty ? _partnerNameController.text : null,
      hasOrphanPension: _hasOrphanPension,
      hasDisabilityPension: _hasDisabilityPension,
      monthlyContribution: double.tryParse(_monthlyContributionController.text),
      paidBy: _paidByController.text.isNotEmpty ? _paidByController.text : null,
      taxTreatment: _taxTreatmentController.text.isNotEmpty ? _taxTreatmentController.text : null,
      allowsExtraContributions: _allowsExtraContributions,
      hasSurvivorPension: _hasSurvivorPension,
      survivorPayoutAmount: double.tryParse(_survivorPayoutController.text),
      survivorConditions: _survivorConditionsController.text.isNotEmpty ? _survivorConditionsController.text : null,
      surrenderValue: double.tryParse(_surrenderValueController.text),
      claimContactPerson: _claimContactPersonController.text.isNotEmpty ? _claimContactPersonController.text : null,
      claimContactPhone: _claimContactPhoneController.text.isNotEmpty ? _claimContactPhoneController.text : null,
      claimContactEmail: _claimContactEmailController.text.isNotEmpty ? _claimContactEmailController.text : null,
      survivorInstructions: _survivorInstructionsController.text.isNotEmpty ? _survivorInstructionsController.text : null,
      servicePhone: _servicePhoneController.text.isNotEmpty ? _servicePhoneController.text : null,
      serviceEmail: _serviceEmailController.text.isNotEmpty ? _serviceEmailController.text : null,
      website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
      portalUrl: _portalUrlController.text.isNotEmpty ? _portalUrlController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    await repo.updatePension(updatedPension);

    if (_moneyItem != null) {
      final name = _providerController.text.isNotEmpty 
          ? '${_providerController.text} - ${_pensionType.label}'
          : _pensionType.label;
      final updatedMoneyItem = MoneyItemModel(
        id: _moneyItem!.id,
        dossierId: _moneyItem!.dossierId,
        personId: _moneyItem!.personId,
        category: _moneyItem!.category,
        type: _moneyItem!.type,
        name: name,
        status: _status,
        createdAt: _moneyItem!.createdAt,
        updatedAt: DateTime.now(),
      );
      await repo.updateMoneyItem(updatedMoneyItem);
    }

    setState(() => _hasChanges = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pensioen opgeslagen'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pensioen verwijderen?'),
        content: const Text('Deze actie kan niet ongedaan worden gemaakt.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(appDatabaseProvider);
      final repo = MoneyRepository(db);
      await repo.deletePension(widget.pensionId, widget.moneyItemId);

      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Laden...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _providerController.text.isNotEmpty
              ? _providerController.text
              : 'Nieuw pensioen',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _save,
            tooltip: 'Opslaan',
          ),
          PopupMenuButton<String>(
            onSelected: (action) {
              if (action == 'delete') _delete();
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
            Tab(text: 'Opbouw'),
            Tab(text: 'Financieel'),
            Tab(text: 'Nabestaanden'),
            Tab(text: 'Contact'),
            Tab(text: 'Notities'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBasisTab(theme),
          _buildOpbouwTab(theme),
          _buildFinancieelTab(theme),
          _buildNabestaandenTab(theme),
          _buildContactTab(theme),
          _buildNotitiesTab(theme),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildBasisTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<PensionType>(
            value: _pensionType,
            decoration: const InputDecoration(
              labelText: 'Type pensioen *',
              prefixIcon: Icon(Icons.category),
            ),
            items: PensionType.values.map((type) => DropdownMenuItem(
              value: type,
              child: Row(
                children: [
                  Text(type.emoji),
                  const SizedBox(width: 8),
                  Text(type.label),
                ],
              ),
            )).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _pensionType = value);
                _markChanged();
              }
            },
          ),
          const SizedBox(height: 16),

          Autocomplete<String>(
            initialValue: TextEditingValue(text: _providerController.text),
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return PensionModel.commonProviders;
              }
              return PensionModel.commonProviders.where((p) =>
                  p.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (selection) {
              _providerController.text = selection;
              _markChanged();
            },
            fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
              if (controller.text != _providerController.text) {
                controller.text = _providerController.text;
              }
              return TextField(
                controller: controller,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: 'Pensioenuitvoerder',
                  hintText: 'Bijv. ABP, PFZW',
                  prefixIcon: Icon(Icons.business),
                ),
                onChanged: (value) {
                  _providerController.text = value;
                  _markChanged();
                },
              );
            },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _participantNumberController,
            decoration: const InputDecoration(
              labelText: 'Deelnemersnummer',
              prefixIcon: Icon(Icons.tag),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _participantNameController,
            decoration: const InputDecoration(
              labelText: 'Naam deelnemer',
              prefixIcon: Icon(Icons.person),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _employerController,
            decoration: const InputDecoration(
              labelText: 'Werkgever',
              hintText: 'Indien van toepassing',
              prefixIcon: Icon(Icons.work),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: DatePickerField(
                  controller: _accrualStartController,
                  labelText: 'Opbouw vanaf',
                  onChanged: _markChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DatePickerField(
                  controller: _accrualEndController,
                  labelText: 'Opbouw tot',
                  onChanged: _markChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOpbouwTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AmountField(
            controller: _currentCapitalController,
            labelText: 'Huidig opgebouwd kapitaal',
            hintText: 'Schatting',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          AmountField(
            controller: _expectedPayoutController,
            labelText: 'Verwachte uitkering per maand',
            hintText: 'Bruto',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          DatePickerField(
            controller: _pensionStartDateController,
            labelText: 'Pensioeningangsdatum',
            prefixIcon: Icons.cake,
            onChanged: _markChanged,
          ),
          const SizedBox(height: 24),

          Text('Dekkingen', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text('Partnerpensioen inbegrepen'),
            value: _hasPartnerPension,
            onChanged: (value) {
              setState(() => _hasPartnerPension = value);
              _markChanged();
            },
          ),
          if (_hasPartnerPension) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: PercentageField(
                      controller: _partnerPercentageController,
                      labelText: 'Percentage',
                      max: 100,
                      onChanged: _markChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _partnerNameController,
                      decoration: const InputDecoration(
                        labelText: 'Partner naam',
                      ),
                      onChanged: (_) => _markChanged(),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SwitchListTile(
            title: const Text('Wezenpensioen inbegrepen'),
            value: _hasOrphanPension,
            onChanged: (value) {
              setState(() => _hasOrphanPension = value);
              _markChanged();
            },
          ),

          SwitchListTile(
            title: const Text('Arbeidsongeschiktheidspensioen'),
            value: _hasDisabilityPension,
            onChanged: (value) {
              setState(() => _hasDisabilityPension = value);
              _markChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFinancieelTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AmountField(
            controller: _monthlyContributionController,
            labelText: 'Maandelijkse inleg',
            hintText: 'Indien nog opbouwend',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _paidByController,
            decoration: const InputDecoration(
              labelText: 'Betaald door',
              hintText: 'Werkgever / Zelf / Gedeeld',
              prefixIcon: Icon(Icons.payment),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _taxTreatmentController,
            decoration: const InputDecoration(
              labelText: 'Fiscale behandeling',
              hintText: 'Bijv. Box 1, vrijgesteld',
              prefixIcon: Icon(Icons.receipt_long),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Vrijwillige extra stortingen mogelijk'),
            value: _allowsExtraContributions,
            onChanged: (value) {
              setState(() => _allowsExtraContributions = value);
              _markChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNabestaandenTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.purple[700]),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Deze informatie helpt nabestaanden om te weten welke rechten zij hebben.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          SwitchListTile(
            title: const Text('Nabestaandenpensioen'),
            subtitle: const Text('Is er een uitkering voor nabestaanden?'),
            value: _hasSurvivorPension,
            onChanged: (value) {
              setState(() => _hasSurvivorPension = value);
              _markChanged();
            },
          ),

          if (_hasSurvivorPension) ...[
            const SizedBox(height: 16),
            AmountField(
              controller: _survivorPayoutController,
              labelText: 'Hoogte uitkering partner (€/maand)',
              onChanged: _markChanged,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _survivorConditionsController,
              decoration: const InputDecoration(
                labelText: 'Voorwaarden',
                hintText: 'Bijv. alleen bij huwelijk/geregistreerd partnerschap',
                prefixIcon: Icon(Icons.rule),
              ),
              maxLines: 2,
              onChanged: (_) => _markChanged(),
            ),
          ],

          const SizedBox(height: 16),
          AmountField(
            controller: _surrenderValueController,
            labelText: 'Afkoopwaarde bij overlijden',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 24),

          Text('Contactpersoon voor claim', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),

          TextField(
            controller: _claimContactPersonController,
            decoration: const InputDecoration(
              labelText: 'Naam contactpersoon',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 12),
          PhoneField(
            controller: _claimContactPhoneController,
            labelText: 'Telefoon',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 12),
          EmailField(
            controller: _claimContactEmailController,
            labelText: 'Email',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _survivorInstructionsController,
            decoration: const InputDecoration(
              labelText: 'Speciale instructies',
              hintText: 'Wat moeten nabestaanden doen?',
              prefixIcon: Icon(Icons.notes),
            ),
            maxLines: 4,
            onChanged: (_) => _markChanged(),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PhoneField(
            controller: _servicePhoneController,
            labelText: 'Telefoon klantenservice',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          EmailField(
            controller: _serviceEmailController,
            labelText: 'Email klantenservice',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          WebsiteField(
            controller: _websiteController,
            labelText: 'Website',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          WebsiteField(
            controller: _portalUrlController,
            labelText: 'Mijn Pensioen portaal URL',
            onChanged: _markChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNotitiesTab(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _notesController,
        decoration: const InputDecoration(
          labelText: 'Notities',
          hintText: 'Overige opmerkingen...',
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
        ),
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        onChanged: (_) => _markChanged(),
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
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
          Expanded(
            child: DropdownButtonFormField<MoneyItemStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: MoneyItemStatus.values.map((status) => DropdownMenuItem(
                value: status,
                child: Row(
                  children: [
                    Icon(
                      status == MoneyItemStatus.complete ? Icons.check_circle :
                      status == MoneyItemStatus.partial ? Icons.pending :
                      Icons.circle_outlined,
                      size: 18,
                      color: status == MoneyItemStatus.complete ? Colors.green :
                             status == MoneyItemStatus.partial ? Colors.orange :
                             Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(status.label),
                  ],
                ),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                  _markChanged();
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check),
            label: const Text('Opslaan'),
          ),
        ],
      ),
    );
  }
}

