// lib/modules/housing/models/energy_contract_model.dart
// Model voor energiecontracten (elektriciteit, gas, stadsverwarming)

import 'housing_enums.dart';

class EnergyContractModel {
  final String id;
  final String propertyId;
  
  // Contract Algemeen (Tab 1)
  final EnergyType energyType;
  final String? provider; // Energieleverancier
  final String? customerNumber;
  final String? contractNumber;
  final String? eanElectricity; // 18 cijfers
  final String? eanGas; // 18 cijfers
  final String? startDate;
  final String? endDate; // null = onbepaald
  final EnergyContractType contractType;
  final int? fixedTermYears;
  
  // Tarieven & Kosten (Tab 2)
  final double? electricityRateNormal; // per kWh
  final double? electricityRateLow; // dal tarief
  final double? electricityFeedInRate; // teruglever tarief
  final double? electricityFixedCost; // vastrecht per maand
  final double? gasRate; // per m³
  final double? gasFixedCost;
  final int? estimatedYearlyElectricity; // kWh
  final int? estimatedYearlyGas; // m³
  final double? monthlyAdvance; // voorschotbedrag
  final String? paymentBankAccountId;
  final int? paymentDay;
  
  // Meterstanden (Tab 3)
  final bool hasSmartMeter;
  final String? meterLocationElectricity;
  final String? meterLocationGas;
  final int? lastMeterNormal; // 181
  final int? lastMeterLow; // 182
  final String? lastMeterNormalDate;
  final int? lastFeedInNormal; // 281
  final int? lastFeedInLow; // 282
  final int? lastMeterGas;
  final String? lastMeterGasDate;
  final bool hasSolarPanelSaldering; // salderingsregeling
  
  // Slimme Meter (Tab 4)
  final bool hasP1Port;
  final String? portalUrl;
  final String? credentialsLocation;
  final String? appName;
  
  // Opzegging (Tab 5)
  final int? noticePeriodMonths;
  final String? cancellationMethod; // Auto/Email/Tel/Portal
  final String? cancellationEmail;
  final String? cancellationPhone;
  final String? lastCancellationDate;
  final double? earlyCancellationPenalty;
  
  // Voor nabestaanden (Tab 6)
  final String? deathAction; // Doorlopen/Opzeggen/Koper regelt
  final String? deathInstructions;
  
  // Contact (Tab 7)
  final String? servicePhone;
  final String? serviceEmail;
  final String? serviceWebsite;
  final String? emergencyPhone; // Storingsnummer
  final String? gridOperator; // Netbeheerder
  final String? gridOperatorPhone;
  final String? gridOperatorWebsite;
  
  // Notities
  final String? notes;
  
  // Status
  final HousingItemStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EnergyContractModel({
    required this.id,
    required this.propertyId,
    this.energyType = EnergyType.combined,
    this.provider,
    this.customerNumber,
    this.contractNumber,
    this.eanElectricity,
    this.eanGas,
    this.startDate,
    this.endDate,
    this.contractType = EnergyContractType.variable,
    this.fixedTermYears,
    this.electricityRateNormal,
    this.electricityRateLow,
    this.electricityFeedInRate,
    this.electricityFixedCost,
    this.gasRate,
    this.gasFixedCost,
    this.estimatedYearlyElectricity,
    this.estimatedYearlyGas,
    this.monthlyAdvance,
    this.paymentBankAccountId,
    this.paymentDay,
    this.hasSmartMeter = true,
    this.meterLocationElectricity,
    this.meterLocationGas,
    this.lastMeterNormal,
    this.lastMeterLow,
    this.lastMeterNormalDate,
    this.lastFeedInNormal,
    this.lastFeedInLow,
    this.lastMeterGas,
    this.lastMeterGasDate,
    this.hasSolarPanelSaldering = false,
    this.hasP1Port = false,
    this.portalUrl,
    this.credentialsLocation,
    this.appName,
    this.noticePeriodMonths,
    this.cancellationMethod,
    this.cancellationEmail,
    this.cancellationPhone,
    this.lastCancellationDate,
    this.earlyCancellationPenalty,
    this.deathAction,
    this.deathInstructions,
    this.servicePhone,
    this.serviceEmail,
    this.serviceWebsite,
    this.emergencyPhone,
    this.gridOperator,
    this.gridOperatorPhone,
    this.gridOperatorWebsite,
    this.notes,
    this.status = HousingItemStatus.notStarted,
    required this.createdAt,
    this.updatedAt,
  });

  String get displayName => provider ?? energyType.label;

  int get completenessPercentage {
    int filled = 0;
    int total = 12;

    if (provider?.isNotEmpty == true) filled++;
    if (customerNumber?.isNotEmpty == true) filled++;
    if (eanElectricity?.isNotEmpty == true || eanGas?.isNotEmpty == true) filled++;
    if (startDate?.isNotEmpty == true) filled++;
    if (electricityRateNormal != null || gasRate != null) filled++;
    if (monthlyAdvance != null) filled++;
    if (meterLocationElectricity?.isNotEmpty == true) filled++;
    if (servicePhone?.isNotEmpty == true) filled++;
    if (emergencyPhone?.isNotEmpty == true) filled++;
    if (gridOperator?.isNotEmpty == true) filled++;
    if (noticePeriodMonths != null) filled++;
    if (deathAction?.isNotEmpty == true) filled++;

    return ((filled / total) * 100).round();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'energy_type': energyType.name,
      'provider': provider,
      'customer_number': customerNumber,
      'contract_number': contractNumber,
      'ean_electricity': eanElectricity,
      'ean_gas': eanGas,
      'start_date': startDate,
      'end_date': endDate,
      'contract_type': contractType.name,
      'fixed_term_years': fixedTermYears,
      'electricity_rate_normal': electricityRateNormal,
      'electricity_rate_low': electricityRateLow,
      'electricity_feed_in_rate': electricityFeedInRate,
      'electricity_fixed_cost': electricityFixedCost,
      'gas_rate': gasRate,
      'gas_fixed_cost': gasFixedCost,
      'estimated_yearly_electricity': estimatedYearlyElectricity,
      'estimated_yearly_gas': estimatedYearlyGas,
      'monthly_advance': monthlyAdvance,
      'payment_bank_account_id': paymentBankAccountId,
      'payment_day': paymentDay,
      'has_smart_meter': hasSmartMeter ? 1 : 0,
      'meter_location_electricity': meterLocationElectricity,
      'meter_location_gas': meterLocationGas,
      'last_meter_normal': lastMeterNormal,
      'last_meter_low': lastMeterLow,
      'last_meter_normal_date': lastMeterNormalDate,
      'last_feed_in_normal': lastFeedInNormal,
      'last_feed_in_low': lastFeedInLow,
      'last_meter_gas': lastMeterGas,
      'last_meter_gas_date': lastMeterGasDate,
      'has_solar_panel_saldering': hasSolarPanelSaldering ? 1 : 0,
      'has_p1_port': hasP1Port ? 1 : 0,
      'portal_url': portalUrl,
      'credentials_location': credentialsLocation,
      'app_name': appName,
      'notice_period_months': noticePeriodMonths,
      'cancellation_method': cancellationMethod,
      'cancellation_email': cancellationEmail,
      'cancellation_phone': cancellationPhone,
      'last_cancellation_date': lastCancellationDate,
      'early_cancellation_penalty': earlyCancellationPenalty,
      'death_action': deathAction,
      'death_instructions': deathInstructions,
      'service_phone': servicePhone,
      'service_email': serviceEmail,
      'service_website': serviceWebsite,
      'emergency_phone': emergencyPhone,
      'grid_operator': gridOperator,
      'grid_operator_phone': gridOperatorPhone,
      'grid_operator_website': gridOperatorWebsite,
      'notes': notes,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory EnergyContractModel.fromMap(Map<String, dynamic> map) {
    return EnergyContractModel(
      id: map['id'] as String,
      propertyId: map['property_id'] as String,
      energyType: EnergyType.values.firstWhere(
        (e) => e.name == map['energy_type'],
        orElse: () => EnergyType.combined,
      ),
      provider: map['provider'] as String?,
      customerNumber: map['customer_number'] as String?,
      contractNumber: map['contract_number'] as String?,
      eanElectricity: map['ean_electricity'] as String?,
      eanGas: map['ean_gas'] as String?,
      startDate: map['start_date'] as String?,
      endDate: map['end_date'] as String?,
      contractType: EnergyContractType.values.firstWhere(
        (e) => e.name == map['contract_type'],
        orElse: () => EnergyContractType.variable,
      ),
      fixedTermYears: map['fixed_term_years'] as int?,
      electricityRateNormal: map['electricity_rate_normal'] as double?,
      electricityRateLow: map['electricity_rate_low'] as double?,
      electricityFeedInRate: map['electricity_feed_in_rate'] as double?,
      electricityFixedCost: map['electricity_fixed_cost'] as double?,
      gasRate: map['gas_rate'] as double?,
      gasFixedCost: map['gas_fixed_cost'] as double?,
      estimatedYearlyElectricity: map['estimated_yearly_electricity'] as int?,
      estimatedYearlyGas: map['estimated_yearly_gas'] as int?,
      monthlyAdvance: map['monthly_advance'] as double?,
      paymentBankAccountId: map['payment_bank_account_id'] as String?,
      paymentDay: map['payment_day'] as int?,
      hasSmartMeter: map['has_smart_meter'] == 1,
      meterLocationElectricity: map['meter_location_electricity'] as String?,
      meterLocationGas: map['meter_location_gas'] as String?,
      lastMeterNormal: map['last_meter_normal'] as int?,
      lastMeterLow: map['last_meter_low'] as int?,
      lastMeterNormalDate: map['last_meter_normal_date'] as String?,
      lastFeedInNormal: map['last_feed_in_normal'] as int?,
      lastFeedInLow: map['last_feed_in_low'] as int?,
      lastMeterGas: map['last_meter_gas'] as int?,
      lastMeterGasDate: map['last_meter_gas_date'] as String?,
      hasSolarPanelSaldering: map['has_solar_panel_saldering'] == 1,
      hasP1Port: map['has_p1_port'] == 1,
      portalUrl: map['portal_url'] as String?,
      credentialsLocation: map['credentials_location'] as String?,
      appName: map['app_name'] as String?,
      noticePeriodMonths: map['notice_period_months'] as int?,
      cancellationMethod: map['cancellation_method'] as String?,
      cancellationEmail: map['cancellation_email'] as String?,
      cancellationPhone: map['cancellation_phone'] as String?,
      lastCancellationDate: map['last_cancellation_date'] as String?,
      earlyCancellationPenalty: map['early_cancellation_penalty'] as double?,
      deathAction: map['death_action'] as String?,
      deathInstructions: map['death_instructions'] as String?,
      servicePhone: map['service_phone'] as String?,
      serviceEmail: map['service_email'] as String?,
      serviceWebsite: map['service_website'] as String?,
      emergencyPhone: map['emergency_phone'] as String?,
      gridOperator: map['grid_operator'] as String?,
      gridOperatorPhone: map['grid_operator_phone'] as String?,
      gridOperatorWebsite: map['grid_operator_website'] as String?,
      notes: map['notes'] as String?,
      status: HousingItemStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => HousingItemStatus.notStarted,
      ),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  /// Bekende energieleveranciers
  static const List<String> commonProviders = [
    'Vattenfall',
    'Essent',
    'Eneco',
    'Greenchoice',
    'Engie',
    'Pure Energie',
    'Budget Energie',
    'Vandebron',
    'Tibber',
    'Frank Energie',
    'Anders',
  ];

  /// Bekende netbeheerders
  static const List<String> gridOperators = [
    'Liander',
    'Enexis',
    'Stedin',
    'Westland Infra',
    'Coteq',
    'Rendo',
  ];
}





