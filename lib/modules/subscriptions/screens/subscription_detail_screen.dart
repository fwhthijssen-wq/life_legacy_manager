// lib/modules/subscriptions/screens/subscription_detail_screen.dart
// Detail scherm voor abonnement met tabs

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/date_picker_field.dart';
import '../models/subscription_model.dart';
import '../models/subscription_enums.dart';
import '../providers/subscription_providers.dart';

class SubscriptionDetailScreen extends ConsumerStatefulWidget {
  final String dossierId;
  final String subscriptionId;
  final bool isNew;

  const SubscriptionDetailScreen({
    super.key,
    required this.dossierId,
    required this.subscriptionId,
    this.isNew = false,
  });

  @override
  ConsumerState<SubscriptionDetailScreen> createState() => _SubscriptionDetailScreenState();
}

class _SubscriptionDetailScreenState extends ConsumerState<SubscriptionDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _hasChanges = false;
  SubscriptionModel? _subscription;

  // Tab 1: Basisgegevens
  final _nameController = TextEditingController();
  final _providerController = TextEditingController();
  SubscriptionCategory _category = SubscriptionCategory.other;
  SubscriptionType _subscriptionType = SubscriptionType.digitalService;
  final _accountNumberController = TextEditingController();
  final _startDateController = TextEditingController();
  SubscriptionStatus _status = SubscriptionStatus.active;

  // Tab 2: Financieel
  final _costController = TextEditingController();
  PaymentFrequency _paymentFrequency = PaymentFrequency.monthly;
  PaymentMethod _paymentMethod = PaymentMethod.directDebit;
  final _paymentDayController = TextEditingController();
  final _lastPaymentDateController = TextEditingController();
  final _nextPaymentDateController = TextEditingController();

  // Tab 3: Contract
  ContractType _contractType = ContractType.ongoing;
  final _minTermMonthsController = TextEditingController();
  final _contractEndDateController = TextEditingController();
  bool _autoRenewal = true;
  final _renewalMonthsController = TextEditingController();
  bool _hadTrialPeriod = false;
  final _trialEndDateController = TextEditingController();

  // Tab 4: Opzegging
  final _noticePeriodDaysController = TextEditingController();
  final _lastCancellationDateController = TextEditingController();
  CancellationMethod? _cancellationMethod;
  final _cancellationEmailController = TextEditingController();
  final _cancellationUrlController = TextEditingController();
  final _cancellationAddressController = TextEditingController();
  final _cancellationPhoneController = TextEditingController();
  bool _cancellationConfirmationRequired = false;
  final _earlyCancellationFeeController = TextEditingController();
  final _cancellationConditionsController = TextEditingController();

  // Tab 5: Toegang
  final _websiteUrlController = TextEditingController();
  CredentialsLocation? _credentialsLocation;
  final _credentialsLocationDetailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _accountTypeController = TextEditingController();
  final _sharedWithController = TextEditingController();
  bool _has2FA = false;
  final _twoFactorMethodController = TextEditingController();

  // Tab 6: Details
  final _packageNameController = TextEditingController();
  final _maxScreensController = TextEditingController();
  final _maxResolutionController = TextEditingController();
  final _locationNameController = TextEditingController();
  final _locationAddressController = TextEditingController();
  final _memberNumberController = TextEditingController();
  final _benefitsController = TextEditingController();

  // Tab 7: Nabestaanden
  DeathAction _deathAction = DeathAction.cancelImmediately;
  CancellationPriority _cancellationPriority = CancellationPriority.normal;
  bool _refundPossible = false;
  final _survivorInstructionsController = TextEditingController();

  // Tab 8: Contact
  final _servicePhoneController = TextEditingController();
  final _serviceEmailController = TextEditingController();
  final _serviceWebsiteController = TextEditingController();
  final _serviceHoursController = TextEditingController();
  final _accountUrlController = TextEditingController();

  // Tab 9: Notities
  final _notesController = TextEditingController();

  ItemStatus _itemStatus = ItemStatus.notStarted;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _providerController.dispose();
    _accountNumberController.dispose();
    _startDateController.dispose();
    _costController.dispose();
    _paymentDayController.dispose();
    _lastPaymentDateController.dispose();
    _nextPaymentDateController.dispose();
    _minTermMonthsController.dispose();
    _contractEndDateController.dispose();
    _renewalMonthsController.dispose();
    _trialEndDateController.dispose();
    _noticePeriodDaysController.dispose();
    _lastCancellationDateController.dispose();
    _cancellationEmailController.dispose();
    _cancellationUrlController.dispose();
    _cancellationAddressController.dispose();
    _cancellationPhoneController.dispose();
    _earlyCancellationFeeController.dispose();
    _cancellationConditionsController.dispose();
    _websiteUrlController.dispose();
    _credentialsLocationDetailController.dispose();
    _usernameController.dispose();
    _accountTypeController.dispose();
    _sharedWithController.dispose();
    _twoFactorMethodController.dispose();
    _packageNameController.dispose();
    _maxScreensController.dispose();
    _maxResolutionController.dispose();
    _locationNameController.dispose();
    _locationAddressController.dispose();
    _memberNumberController.dispose();
    _benefitsController.dispose();
    _survivorInstructionsController.dispose();
    _servicePhoneController.dispose();
    _serviceEmailController.dispose();
    _serviceWebsiteController.dispose();
    _serviceHoursController.dispose();
    _accountUrlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(subscriptionRepositoryProvider);
    final subscription = await repo.getSubscription(widget.subscriptionId);

    if (subscription != null) {
      _subscription = subscription;
      _populateFields(subscription);
    }
    setState(() => _isLoading = false);
  }

  void _populateFields(SubscriptionModel s) {
    _nameController.text = s.name;
    _providerController.text = s.provider ?? '';
    _category = s.category;
    _subscriptionType = s.subscriptionType;
    _accountNumberController.text = s.accountNumber ?? '';
    _startDateController.text = s.startDate ?? '';
    _status = s.status;

    _costController.text = s.cost?.toString() ?? '';
    _paymentFrequency = s.paymentFrequency;
    _paymentMethod = s.paymentMethod;
    _paymentDayController.text = s.paymentDay?.toString() ?? '';
    _lastPaymentDateController.text = s.lastPaymentDate ?? '';
    _nextPaymentDateController.text = s.nextPaymentDate ?? '';

    _contractType = s.contractType;
    _minTermMonthsController.text = s.minTermMonths?.toString() ?? '';
    _contractEndDateController.text = s.contractEndDate ?? '';
    _autoRenewal = s.autoRenewal;
    _renewalMonthsController.text = s.renewalMonths?.toString() ?? '';
    _hadTrialPeriod = s.hadTrialPeriod;
    _trialEndDateController.text = s.trialEndDate ?? '';

    _noticePeriodDaysController.text = s.noticePeriodDays?.toString() ?? '';
    _lastCancellationDateController.text = s.lastCancellationDate ?? '';
    _cancellationMethod = s.cancellationMethod;
    _cancellationEmailController.text = s.cancellationEmail ?? '';
    _cancellationUrlController.text = s.cancellationUrl ?? '';
    _cancellationAddressController.text = s.cancellationAddress ?? '';
    _cancellationPhoneController.text = s.cancellationPhone ?? '';
    _cancellationConfirmationRequired = s.cancellationConfirmationRequired;
    _earlyCancellationFeeController.text = s.earlyCancellationFee?.toString() ?? '';
    _cancellationConditionsController.text = s.cancellationConditions ?? '';

    _websiteUrlController.text = s.websiteUrl ?? '';
    _credentialsLocation = s.credentialsLocation;
    _credentialsLocationDetailController.text = s.credentialsLocationDetail ?? '';
    _usernameController.text = s.username ?? '';
    _accountTypeController.text = s.accountType ?? '';
    _sharedWithController.text = s.sharedWith ?? '';
    _has2FA = s.has2FA;
    _twoFactorMethodController.text = s.twoFactorMethod ?? '';

    _packageNameController.text = s.packageName ?? '';
    _maxScreensController.text = s.maxScreens?.toString() ?? '';
    _maxResolutionController.text = s.maxResolution ?? '';
    _locationNameController.text = s.locationName ?? '';
    _locationAddressController.text = s.locationAddress ?? '';
    _memberNumberController.text = s.memberNumber ?? '';
    _benefitsController.text = s.benefits ?? '';

    _deathAction = s.deathAction;
    _cancellationPriority = s.cancellationPriority;
    _refundPossible = s.refundPossible;
    _survivorInstructionsController.text = s.survivorInstructions ?? '';

    _servicePhoneController.text = s.servicePhone ?? '';
    _serviceEmailController.text = s.serviceEmail ?? '';
    _serviceWebsiteController.text = s.serviceWebsite ?? '';
    _serviceHoursController.text = s.serviceHours ?? '';
    _accountUrlController.text = s.accountUrl ?? '';

    _notesController.text = s.notes ?? '';
    _itemStatus = s.itemStatus;
  }

  void _markChanged() {
    if (!_hasChanges) setState(() => _hasChanges = true);
  }

  Future<void> _save() async {
    if (_subscription == null) return;

    final repo = ref.read(subscriptionRepositoryProvider);
    final updated = SubscriptionModel(
      id: _subscription!.id,
      dossierId: _subscription!.dossierId,
      personId: _subscription!.personId,
      name: _nameController.text,
      provider: _providerController.text.isNotEmpty ? _providerController.text : null,
      category: _category,
      subscriptionType: _subscriptionType,
      accountNumber: _accountNumberController.text.isNotEmpty ? _accountNumberController.text : null,
      startDate: _startDateController.text.isNotEmpty ? _startDateController.text : null,
      status: _status,
      cost: double.tryParse(_costController.text),
      paymentFrequency: _paymentFrequency,
      paymentMethod: _paymentMethod,
      paymentDay: int.tryParse(_paymentDayController.text),
      lastPaymentDate: _lastPaymentDateController.text.isNotEmpty ? _lastPaymentDateController.text : null,
      nextPaymentDate: _nextPaymentDateController.text.isNotEmpty ? _nextPaymentDateController.text : null,
      contractType: _contractType,
      minTermMonths: int.tryParse(_minTermMonthsController.text),
      contractEndDate: _contractEndDateController.text.isNotEmpty ? _contractEndDateController.text : null,
      autoRenewal: _autoRenewal,
      renewalMonths: int.tryParse(_renewalMonthsController.text),
      hadTrialPeriod: _hadTrialPeriod,
      trialEndDate: _trialEndDateController.text.isNotEmpty ? _trialEndDateController.text : null,
      noticePeriodDays: int.tryParse(_noticePeriodDaysController.text),
      lastCancellationDate: _lastCancellationDateController.text.isNotEmpty ? _lastCancellationDateController.text : null,
      cancellationMethod: _cancellationMethod,
      cancellationEmail: _cancellationEmailController.text.isNotEmpty ? _cancellationEmailController.text : null,
      cancellationUrl: _cancellationUrlController.text.isNotEmpty ? _cancellationUrlController.text : null,
      cancellationAddress: _cancellationAddressController.text.isNotEmpty ? _cancellationAddressController.text : null,
      cancellationPhone: _cancellationPhoneController.text.isNotEmpty ? _cancellationPhoneController.text : null,
      cancellationConfirmationRequired: _cancellationConfirmationRequired,
      earlyCancellationFee: double.tryParse(_earlyCancellationFeeController.text),
      cancellationConditions: _cancellationConditionsController.text.isNotEmpty ? _cancellationConditionsController.text : null,
      websiteUrl: _websiteUrlController.text.isNotEmpty ? _websiteUrlController.text : null,
      credentialsLocation: _credentialsLocation,
      credentialsLocationDetail: _credentialsLocationDetailController.text.isNotEmpty ? _credentialsLocationDetailController.text : null,
      username: _usernameController.text.isNotEmpty ? _usernameController.text : null,
      accountType: _accountTypeController.text.isNotEmpty ? _accountTypeController.text : null,
      sharedWith: _sharedWithController.text.isNotEmpty ? _sharedWithController.text : null,
      has2FA: _has2FA,
      twoFactorMethod: _twoFactorMethodController.text.isNotEmpty ? _twoFactorMethodController.text : null,
      packageName: _packageNameController.text.isNotEmpty ? _packageNameController.text : null,
      maxScreens: int.tryParse(_maxScreensController.text),
      maxResolution: _maxResolutionController.text.isNotEmpty ? _maxResolutionController.text : null,
      locationName: _locationNameController.text.isNotEmpty ? _locationNameController.text : null,
      locationAddress: _locationAddressController.text.isNotEmpty ? _locationAddressController.text : null,
      memberNumber: _memberNumberController.text.isNotEmpty ? _memberNumberController.text : null,
      benefits: _benefitsController.text.isNotEmpty ? _benefitsController.text : null,
      deathAction: _deathAction,
      cancellationPriority: _cancellationPriority,
      refundPossible: _refundPossible,
      survivorInstructions: _survivorInstructionsController.text.isNotEmpty ? _survivorInstructionsController.text : null,
      servicePhone: _servicePhoneController.text.isNotEmpty ? _servicePhoneController.text : null,
      serviceEmail: _serviceEmailController.text.isNotEmpty ? _serviceEmailController.text : null,
      serviceWebsite: _serviceWebsiteController.text.isNotEmpty ? _serviceWebsiteController.text : null,
      serviceHours: _serviceHoursController.text.isNotEmpty ? _serviceHoursController.text : null,
      accountUrl: _accountUrlController.text.isNotEmpty ? _accountUrlController.text : null,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      itemStatus: _itemStatus,
      createdAt: _subscription!.createdAt,
      updatedAt: DateTime.now(),
    );

    await repo.updateSubscription(updated);
    setState(() {
      _subscription = updated;
      _hasChanges = false;
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abonnement opgeslagen'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Abonnement verwijderen?'),
        content: const Text('Dit kan niet ongedaan worden gemaakt.'),
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
      final repo = ref.read(subscriptionRepositoryProvider);
      await repo.deleteSubscription(widget.subscriptionId);
      if (!mounted) return;
      Navigator.pop(context);
    }
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
        title: Text(_nameController.text.isNotEmpty ? _nameController.text : 'Abonnement'),
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
            Tab(text: 'Financieel'),
            Tab(text: 'Contract'),
            Tab(text: 'Opzegging'),
            Tab(text: 'Toegang'),
            Tab(text: 'Details'),
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
          _buildFinancieelTab(theme),
          _buildContractTab(theme),
          _buildOpzeggingTab(theme),
          _buildToegangTab(theme),
          _buildDetailsTab(theme),
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
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Naam abonnement *',
              prefixIcon: Icon(Icons.label, color: Color(_category.colorValue)),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _providerController,
            decoration: const InputDecoration(
              labelText: 'Aanbieder/Provider',
              prefixIcon: Icon(Icons.business),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<SubscriptionCategory>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Categorie'),
            items: SubscriptionCategory.values.map((c) => DropdownMenuItem(
              value: c,
              child: Row(children: [Text(c.emoji), const SizedBox(width: 8), Text(c.label)]),
            )).toList(),
            onChanged: (v) { if (v != null) { setState(() => _category = v); _markChanged(); } },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<SubscriptionType>(
            value: _subscriptionType,
            decoration: const InputDecoration(labelText: 'Type'),
            items: SubscriptionType.values.map((t) => DropdownMenuItem(
              value: t,
              child: Row(children: [Text(t.emoji), const SizedBox(width: 8), Text(t.label)]),
            )).toList(),
            onChanged: (v) { if (v != null) { setState(() => _subscriptionType = v); _markChanged(); } },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _accountNumberController,
            decoration: const InputDecoration(
              labelText: 'Account/Klantnummer',
              prefixIcon: Icon(Icons.numbers),
            ),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          DatePickerField(
            controller: _startDateController,
            labelText: 'Ingangsdatum',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<SubscriptionStatus>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: SubscriptionStatus.values.map((s) => DropdownMenuItem(
              value: s,
              child: Row(children: [Text(s.emoji), const SizedBox(width: 8), Text(s.label)]),
            )).toList(),
            onChanged: (v) { if (v != null) { setState(() => _status = v); _markChanged(); } },
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
            controller: _costController,
            labelText: 'Kosten',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<PaymentFrequency>(
            value: _paymentFrequency,
            decoration: const InputDecoration(labelText: 'Betalingsfrequentie'),
            items: PaymentFrequency.values.map((f) => DropdownMenuItem(
              value: f, child: Text(f.label),
            )).toList(),
            onChanged: (v) { if (v != null) { setState(() => _paymentFrequency = v); _markChanged(); } },
          ),
          const SizedBox(height: 16),

          // Toon berekende maandkosten
          if (_costController.text.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Maandelijkse kosten:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                    '€ ${((double.tryParse(_costController.text) ?? 0) / (_paymentFrequency.months == 0 ? 1 : _paymentFrequency.months)).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          DropdownButtonFormField<PaymentMethod>(
            value: _paymentMethod,
            decoration: const InputDecoration(labelText: 'Betaalmethode'),
            items: PaymentMethod.values.map((m) => DropdownMenuItem(
              value: m,
              child: Row(children: [Text(m.emoji), const SizedBox(width: 8), Text(m.label)]),
            )).toList(),
            onChanged: (v) { if (v != null) { setState(() => _paymentMethod = v); _markChanged(); } },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _paymentDayController,
            decoration: const InputDecoration(
              labelText: 'Betalingsdag (dag van de maand)',
              prefixIcon: Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: DatePickerField(controller: _lastPaymentDateController, labelText: 'Laatste betaling', onChanged: _markChanged)),
            const SizedBox(width: 12),
            Expanded(child: DatePickerField(controller: _nextPaymentDateController, labelText: 'Volgende betaling', onChanged: _markChanged)),
          ]),
        ],
      ),
    );
  }

  Widget _buildContractTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<ContractType>(
            value: _contractType,
            decoration: const InputDecoration(labelText: 'Type contract'),
            items: ContractType.values.map((c) => DropdownMenuItem(
              value: c,
              child: Row(children: [Text(c.emoji), const SizedBox(width: 8), Text(c.label)]),
            )).toList(),
            onChanged: (v) { if (v != null) { setState(() => _contractType = v); _markChanged(); } },
          ),
          const SizedBox(height: 16),

          if (_contractType == ContractType.fixedTerm) ...[
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _minTermMonthsController,
                  decoration: const InputDecoration(labelText: 'Minimale looptijd (maanden)'),
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _markChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: DatePickerField(controller: _contractEndDateController, labelText: 'Einddatum', onChanged: _markChanged)),
            ]),
            const SizedBox(height: 16),
          ],

          SwitchListTile(
            title: const Text('Automatische verlenging'),
            value: _autoRenewal,
            onChanged: (v) { setState(() => _autoRenewal = v); _markChanged(); },
          ),

          if (_autoRenewal)
            TextField(
              controller: _renewalMonthsController,
              decoration: const InputDecoration(labelText: 'Verlenging met (maanden)'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _markChanged(),
            ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Proefperiode gehad'),
            value: _hadTrialPeriod,
            onChanged: (v) { setState(() => _hadTrialPeriod = v); _markChanged(); },
          ),

          if (_hadTrialPeriod)
            DatePickerField(controller: _trialEndDateController, labelText: 'Einddatum proefperiode', onChanged: _markChanged),
        ],
      ),
    );
  }

  Widget _buildOpzeggingTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber, color: Colors.orange[700]),
                const SizedBox(width: 12),
                const Expanded(child: Text('Deze informatie is cruciaal voor nabestaanden!')),
              ],
            ),
          ),
          const SizedBox(height: 24),

          TextField(
            controller: _noticePeriodDaysController,
            decoration: const InputDecoration(
              labelText: 'Opzegtermijn (dagen)',
              prefixIcon: Icon(Icons.timer),
            ),
            keyboardType: TextInputType.number,
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          DatePickerField(
            controller: _lastCancellationDateController,
            labelText: 'Laatste opzegdatum',
            onChanged: _markChanged,
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<CancellationMethod>(
            value: _cancellationMethod,
            decoration: const InputDecoration(labelText: 'Hoe opzeggen?'),
            items: CancellationMethod.values.map((m) => DropdownMenuItem(
              value: m,
              child: Row(children: [Text(m.emoji), const SizedBox(width: 8), Text(m.label)]),
            )).toList(),
            onChanged: (v) { setState(() => _cancellationMethod = v); _markChanged(); },
          ),
          const SizedBox(height: 16),

          if (_cancellationMethod == CancellationMethod.email)
            EmailField(controller: _cancellationEmailController, labelText: 'Opzeg email', onChanged: _markChanged),
          if (_cancellationMethod == CancellationMethod.online)
            WebsiteField(controller: _cancellationUrlController, labelText: 'Opzeg URL', onChanged: _markChanged),
          if (_cancellationMethod == CancellationMethod.mail)
            TextField(controller: _cancellationAddressController, decoration: const InputDecoration(labelText: 'Opzegadres'), onChanged: (_) => _markChanged()),
          if (_cancellationMethod == CancellationMethod.phone)
            PhoneField(controller: _cancellationPhoneController, labelText: 'Opzeg telefoon', onChanged: _markChanged),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Bevestiging opzegging vereist'),
            value: _cancellationConfirmationRequired,
            onChanged: (v) { setState(() => _cancellationConfirmationRequired = v); _markChanged(); },
          ),

          AmountField(controller: _earlyCancellationFeeController, labelText: 'Boete bij vervroegd opzeggen', onChanged: _markChanged),
          const SizedBox(height: 16),

          TextField(
            controller: _cancellationConditionsController,
            decoration: const InputDecoration(labelText: 'Speciale voorwaarden'),
            maxLines: 3,
            onChanged: (_) => _markChanged(),
          ),
        ],
      ),
    );
  }

  Widget _buildToegangTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WebsiteField(controller: _websiteUrlController, labelText: 'Website/App URL', onChanged: _markChanged),
          const SizedBox(height: 16),

          DropdownButtonFormField<CredentialsLocation>(
            value: _credentialsLocation,
            decoration: const InputDecoration(labelText: 'Locatie inloggegevens'),
            items: CredentialsLocation.values.map((l) => DropdownMenuItem(
              value: l,
              child: Row(children: [Text(l.emoji), const SizedBox(width: 8), Text(l.label)]),
            )).toList(),
            onChanged: (v) { setState(() => _credentialsLocation = v); _markChanged(); },
          ),
          const SizedBox(height: 16),

          if (_credentialsLocation != null)
            TextField(
              controller: _credentialsLocationDetailController,
              decoration: InputDecoration(
                labelText: _credentialsLocation == CredentialsLocation.passwordManager
                    ? 'Welke wachtwoordmanager?'
                    : 'Details locatie',
              ),
              onChanged: (_) => _markChanged(),
            ),
          const SizedBox(height: 16),

          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(labelText: 'Gebruikersnaam/Email (optioneel)'),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _accountTypeController,
            decoration: const InputDecoration(labelText: 'Account type (Individueel, Gezin, etc.)'),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _sharedWithController,
            decoration: const InputDecoration(labelText: 'Gedeeld met'),
            onChanged: (_) => _markChanged(),
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('2-Factor authenticatie (2FA)'),
            value: _has2FA,
            onChanged: (v) { setState(() => _has2FA = v); _markChanged(); },
          ),

          if (_has2FA)
            TextField(
              controller: _twoFactorMethodController,
              decoration: const InputDecoration(labelText: '2FA methode (App, SMS, etc.)'),
              onChanged: (_) => _markChanged(),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Specifieke details voor ${_category.label}', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          // Streaming/Software
          if (_category == SubscriptionCategory.streamingMedia || _category == SubscriptionCategory.softwareApps) ...[
            TextField(controller: _packageNameController, decoration: const InputDecoration(labelText: 'Pakket (Basis/Premium/etc.)'), onChanged: (_) => _markChanged()),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: _maxScreensController, decoration: const InputDecoration(labelText: 'Max schermen'), keyboardType: TextInputType.number, onChanged: (_) => _markChanged())),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _maxResolutionController, decoration: const InputDecoration(labelText: 'Max resolutie'), onChanged: (_) => _markChanged())),
            ]),
          ],

          // Sport/Fitness
          if (_category == SubscriptionCategory.sportFitness) ...[
            TextField(controller: _locationNameController, decoration: const InputDecoration(labelText: 'Vestiging/Locatie'), onChanged: (_) => _markChanged()),
            const SizedBox(height: 12),
            TextField(controller: _locationAddressController, decoration: const InputDecoration(labelText: 'Adres'), onChanged: (_) => _markChanged()),
          ],

          // Verenigingen
          if (_category == SubscriptionCategory.associations) ...[
            TextField(controller: _memberNumberController, decoration: const InputDecoration(labelText: 'Lidnummer'), onChanged: (_) => _markChanged()),
            const SizedBox(height: 12),
            TextField(controller: _benefitsController, decoration: const InputDecoration(labelText: 'Voordelen'), maxLines: 3, onChanged: (_) => _markChanged()),
          ],

          // Algemeen
          const SizedBox(height: 16),
          TextField(controller: _benefitsController, decoration: const InputDecoration(labelText: 'Extra info/voordelen'), maxLines: 3, onChanged: (_) => _markChanged()),
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
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 12),
                const Expanded(child: Text('Wat moet er gebeuren met dit abonnement bij overlijden?')),
              ],
            ),
          ),
          const SizedBox(height: 24),

          DropdownButtonFormField<DeathAction>(
            value: _deathAction,
            decoration: const InputDecoration(labelText: 'Actie bij overlijden'),
            items: DeathAction.values.map((a) => DropdownMenuItem(
              value: a,
              child: Row(children: [Text(a.emoji), const SizedBox(width: 8), Text(a.label)]),
            )).toList(),
            onChanged: (v) { if (v != null) { setState(() => _deathAction = v); _markChanged(); } },
          ),
          const SizedBox(height: 16),

          DropdownButtonFormField<CancellationPriority>(
            value: _cancellationPriority,
            decoration: const InputDecoration(labelText: 'Prioriteit opzegging'),
            items: CancellationPriority.values.map((p) => DropdownMenuItem(
              value: p,
              child: Row(children: [Text(p.emoji), const SizedBox(width: 8), Text(p.label)]),
            )).toList(),
            onChanged: (v) { if (v != null) { setState(() => _cancellationPriority = v); _markChanged(); } },
          ),
          const SizedBox(height: 16),

          SwitchListTile(
            title: const Text('Restitutie mogelijk'),
            subtitle: const Text('Bij vooruitbetaald abonnement'),
            value: _refundPossible,
            onChanged: (v) { setState(() => _refundPossible = v); _markChanged(); },
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _survivorInstructionsController,
            decoration: const InputDecoration(
              labelText: 'Instructies voor nabestaanden',
              hintText: 'Bijv. "Sportschool vraagt overlijdensakte voor opzegging zonder boete"',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            maxLines: 5,
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
          Text('Klantenservice', style: theme.textTheme.titleMedium),
          const SizedBox(height: 16),

          PhoneField(controller: _servicePhoneController, labelText: 'Telefoon', onChanged: _markChanged),
          const SizedBox(height: 12),
          EmailField(controller: _serviceEmailController, labelText: 'Email', onChanged: _markChanged),
          const SizedBox(height: 12),
          WebsiteField(controller: _serviceWebsiteController, labelText: 'Website', onChanged: _markChanged),
          const SizedBox(height: 12),
          TextField(controller: _serviceHoursController, decoration: const InputDecoration(labelText: 'Openingstijden'), onChanged: (_) => _markChanged()),
          const SizedBox(height: 16),

          WebsiteField(controller: _accountUrlController, labelText: 'Mijn account URL', onChanged: _markChanged),
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
            child: DropdownButtonFormField<ItemStatus>(
              value: _itemStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: ItemStatus.values.map((status) => DropdownMenuItem(
                value: status,
                child: Row(
                  children: [
                    Text(status.emoji),
                    const SizedBox(width: 8),
                    Text(status.label),
                  ],
                ),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _itemStatus = value);
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

