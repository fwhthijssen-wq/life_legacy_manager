// lib/modules/housing/models/installation_model.dart
// Model voor technische installaties (CV-ketel, warmtepomp, zonnepanelen, etc.)

import 'housing_enums.dart';

class InstallationModel {
  final String id;
  final String propertyId;
  
  // Basisgegevens (Tab 1)
  final InstallationType installationType;
  final String? brand;
  final String? model;
  final int? installYear;
  final String? serialNumber;
  final double? power; // kW
  final String? energyLabel;
  final String? location; // locatie in woning
  final String? photoPath;
  
  // Installateur & Garantie (Tab 2)
  final String? installerCompany;
  final String? installerContact;
  final String? installerPhone;
  final String? installerEmail;
  final String? installationDate;
  final int? warrantyYears;
  final String? warrantyEndDate;
  final bool hasManufacturerWarranty;
  final bool hasInstallerWarranty;
  
  // Onderhoud (Tab 3)
  final bool hasMaintenanceContract;
  final String? maintenanceCompany;
  final String? maintenanceContractNumber;
  final double? maintenanceCostYearly;
  final String? maintenanceIncludes; // Wat is inbegrepen
  final String? maintenanceBankAccountId;
  final String? lastMaintenanceDate;
  final String? nextMaintenanceDate;
  final String? maintenancePhone;
  final String? maintenanceEmail;
  final String? emergencyPhone24h;
  
  // Bediening & Thermostaat (Tab 4) - specifiek voor CV
  final String? thermostatType; // Handmatig/Digitaal/Smart
  final String? thermostatBrand; // Nest/Tado/Honeywell
  final String? thermostatLocation;
  final String? thermostatAppName;
  final String? thermostatCredentialsLocation;
  final String? controlOnOffLocation;
  final String? controlResetLocation;
  final String? pressureGaugeInfo; // Normaal 1-2 bar
  
  // Storing - Wat te doen (Tab 5) - BELANGRIJK!
  final String? troubleshootingSteps; // JSON array of steps
  final String? errorCodes; // JSON object of codes with meanings
  
  // Handleiding (Tab 6)
  final String? manualDigitalPath;
  final String? manualPhysicalLocation;
  final String? manualOnlineUrl;
  final String? videoInstructions; // JSON array of video links
  
  // Voor nabestaanden (Tab 7)
  final String? survivorInstructions;
  final String? sellHouseInstructions;
  final bool maintenanceContractTransferable;
  
  // Kosten & Verbruik (Tab 8)
  final double? purchasePrice;
  final String? purchaseDate;
  final double? installationCost;
  final int? estimatedYearlyConsumption; // m³ gas of kWh
  final String? linkedEnergyContractId;
  
  // Specifiek voor zonnepanelen
  final int? numberOfPanels;
  final int? panelWattPeak; // Wp per paneel
  final String? inverterBrand;
  final String? inverterModel;
  final String? inverterLocation;
  final String? inverterSerialNumber;
  final int? inverterWarrantyYears;
  final String? monitoringSystem;
  final String? monitoringAppName;
  final String? monitoringPortalUrl;
  final String? monitoringCredentialsLocation;
  final int? estimatedYearlyProduction; // kWh
  final double? subsidyReceived; // ISDE
  
  // Specifiek voor warmtepomp
  final String? heatPumpType; // lucht/water, bodem, hybride
  final double? cop; // Coefficient of Performance
  final String? outdoorUnitLocation;
  final String? indoorUnitLocation;
  
  // Specifiek voor laadpaal
  final double? chargingPower; // kW
  final bool hasSmartCharging;
  final String? chargerAppName;
  
  // Notities
  final String? notes;
  
  // Status
  final HousingItemStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  InstallationModel({
    required this.id,
    required this.propertyId,
    this.installationType = InstallationType.other,
    this.brand,
    this.model,
    this.installYear,
    this.serialNumber,
    this.power,
    this.energyLabel,
    this.location,
    this.photoPath,
    this.installerCompany,
    this.installerContact,
    this.installerPhone,
    this.installerEmail,
    this.installationDate,
    this.warrantyYears,
    this.warrantyEndDate,
    this.hasManufacturerWarranty = false,
    this.hasInstallerWarranty = false,
    this.hasMaintenanceContract = false,
    this.maintenanceCompany,
    this.maintenanceContractNumber,
    this.maintenanceCostYearly,
    this.maintenanceIncludes,
    this.maintenanceBankAccountId,
    this.lastMaintenanceDate,
    this.nextMaintenanceDate,
    this.maintenancePhone,
    this.maintenanceEmail,
    this.emergencyPhone24h,
    this.thermostatType,
    this.thermostatBrand,
    this.thermostatLocation,
    this.thermostatAppName,
    this.thermostatCredentialsLocation,
    this.controlOnOffLocation,
    this.controlResetLocation,
    this.pressureGaugeInfo,
    this.troubleshootingSteps,
    this.errorCodes,
    this.manualDigitalPath,
    this.manualPhysicalLocation,
    this.manualOnlineUrl,
    this.videoInstructions,
    this.survivorInstructions,
    this.sellHouseInstructions,
    this.maintenanceContractTransferable = false,
    this.purchasePrice,
    this.purchaseDate,
    this.installationCost,
    this.estimatedYearlyConsumption,
    this.linkedEnergyContractId,
    this.numberOfPanels,
    this.panelWattPeak,
    this.inverterBrand,
    this.inverterModel,
    this.inverterLocation,
    this.inverterSerialNumber,
    this.inverterWarrantyYears,
    this.monitoringSystem,
    this.monitoringAppName,
    this.monitoringPortalUrl,
    this.monitoringCredentialsLocation,
    this.estimatedYearlyProduction,
    this.subsidyReceived,
    this.heatPumpType,
    this.cop,
    this.outdoorUnitLocation,
    this.indoorUnitLocation,
    this.chargingPower,
    this.hasSmartCharging = false,
    this.chargerAppName,
    this.notes,
    this.status = HousingItemStatus.notStarted,
    required this.createdAt,
    this.updatedAt,
  });

  String get displayName {
    final parts = <String>[];
    if (brand?.isNotEmpty == true) parts.add(brand!);
    if (model?.isNotEmpty == true) parts.add(model!);
    if (parts.isEmpty) return installationType.label;
    return parts.join(' ');
  }

  /// Totaal piekvermogen voor zonnepanelen
  int? get totalPeakPower {
    if (numberOfPanels == null || panelWattPeak == null) return null;
    return numberOfPanels! * panelWattPeak!;
  }

  int get completenessPercentage {
    int filled = 0;
    int total = 12;

    if (brand?.isNotEmpty == true) filled++;
    if (model?.isNotEmpty == true) filled++;
    if (location?.isNotEmpty == true) filled++;
    if (installYear != null) filled++;
    if (installerCompany?.isNotEmpty == true) filled++;
    if (warrantyEndDate?.isNotEmpty == true) filled++;
    if (emergencyPhone24h?.isNotEmpty == true) filled++;
    if (troubleshootingSteps?.isNotEmpty == true) filled++;
    if (manualDigitalPath?.isNotEmpty == true || manualOnlineUrl?.isNotEmpty == true) filled++;
    if (survivorInstructions?.isNotEmpty == true) filled++;
    if (lastMaintenanceDate?.isNotEmpty == true) filled++;
    if (notes?.isNotEmpty == true) filled++;

    return ((filled / total) * 100).round();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'installation_type': installationType.name,
      'brand': brand,
      'model': model,
      'install_year': installYear,
      'serial_number': serialNumber,
      'power': power,
      'energy_label': energyLabel,
      'location': location,
      'photo_path': photoPath,
      'installer_company': installerCompany,
      'installer_contact': installerContact,
      'installer_phone': installerPhone,
      'installer_email': installerEmail,
      'installation_date': installationDate,
      'warranty_years': warrantyYears,
      'warranty_end_date': warrantyEndDate,
      'has_manufacturer_warranty': hasManufacturerWarranty ? 1 : 0,
      'has_installer_warranty': hasInstallerWarranty ? 1 : 0,
      'has_maintenance_contract': hasMaintenanceContract ? 1 : 0,
      'maintenance_company': maintenanceCompany,
      'maintenance_contract_number': maintenanceContractNumber,
      'maintenance_cost_yearly': maintenanceCostYearly,
      'maintenance_includes': maintenanceIncludes,
      'maintenance_bank_account_id': maintenanceBankAccountId,
      'last_maintenance_date': lastMaintenanceDate,
      'next_maintenance_date': nextMaintenanceDate,
      'maintenance_phone': maintenancePhone,
      'maintenance_email': maintenanceEmail,
      'emergency_phone_24h': emergencyPhone24h,
      'thermostat_type': thermostatType,
      'thermostat_brand': thermostatBrand,
      'thermostat_location': thermostatLocation,
      'thermostat_app_name': thermostatAppName,
      'thermostat_credentials_location': thermostatCredentialsLocation,
      'control_on_off_location': controlOnOffLocation,
      'control_reset_location': controlResetLocation,
      'pressure_gauge_info': pressureGaugeInfo,
      'troubleshooting_steps': troubleshootingSteps,
      'error_codes': errorCodes,
      'manual_digital_path': manualDigitalPath,
      'manual_physical_location': manualPhysicalLocation,
      'manual_online_url': manualOnlineUrl,
      'video_instructions': videoInstructions,
      'survivor_instructions': survivorInstructions,
      'sell_house_instructions': sellHouseInstructions,
      'maintenance_contract_transferable': maintenanceContractTransferable ? 1 : 0,
      'purchase_price': purchasePrice,
      'purchase_date': purchaseDate,
      'installation_cost': installationCost,
      'estimated_yearly_consumption': estimatedYearlyConsumption,
      'linked_energy_contract_id': linkedEnergyContractId,
      'number_of_panels': numberOfPanels,
      'panel_watt_peak': panelWattPeak,
      'inverter_brand': inverterBrand,
      'inverter_model': inverterModel,
      'inverter_location': inverterLocation,
      'inverter_serial_number': inverterSerialNumber,
      'inverter_warranty_years': inverterWarrantyYears,
      'monitoring_system': monitoringSystem,
      'monitoring_app_name': monitoringAppName,
      'monitoring_portal_url': monitoringPortalUrl,
      'monitoring_credentials_location': monitoringCredentialsLocation,
      'estimated_yearly_production': estimatedYearlyProduction,
      'subsidy_received': subsidyReceived,
      'heat_pump_type': heatPumpType,
      'cop': cop,
      'outdoor_unit_location': outdoorUnitLocation,
      'indoor_unit_location': indoorUnitLocation,
      'charging_power': chargingPower,
      'has_smart_charging': hasSmartCharging ? 1 : 0,
      'charger_app_name': chargerAppName,
      'notes': notes,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory InstallationModel.fromMap(Map<String, dynamic> map) {
    return InstallationModel(
      id: map['id'] as String,
      propertyId: map['property_id'] as String,
      installationType: InstallationType.values.firstWhere(
        (e) => e.name == map['installation_type'],
        orElse: () => InstallationType.other,
      ),
      brand: map['brand'] as String?,
      model: map['model'] as String?,
      installYear: map['install_year'] as int?,
      serialNumber: map['serial_number'] as String?,
      power: map['power'] as double?,
      energyLabel: map['energy_label'] as String?,
      location: map['location'] as String?,
      photoPath: map['photo_path'] as String?,
      installerCompany: map['installer_company'] as String?,
      installerContact: map['installer_contact'] as String?,
      installerPhone: map['installer_phone'] as String?,
      installerEmail: map['installer_email'] as String?,
      installationDate: map['installation_date'] as String?,
      warrantyYears: map['warranty_years'] as int?,
      warrantyEndDate: map['warranty_end_date'] as String?,
      hasManufacturerWarranty: map['has_manufacturer_warranty'] == 1,
      hasInstallerWarranty: map['has_installer_warranty'] == 1,
      hasMaintenanceContract: map['has_maintenance_contract'] == 1,
      maintenanceCompany: map['maintenance_company'] as String?,
      maintenanceContractNumber: map['maintenance_contract_number'] as String?,
      maintenanceCostYearly: map['maintenance_cost_yearly'] as double?,
      maintenanceIncludes: map['maintenance_includes'] as String?,
      maintenanceBankAccountId: map['maintenance_bank_account_id'] as String?,
      lastMaintenanceDate: map['last_maintenance_date'] as String?,
      nextMaintenanceDate: map['next_maintenance_date'] as String?,
      maintenancePhone: map['maintenance_phone'] as String?,
      maintenanceEmail: map['maintenance_email'] as String?,
      emergencyPhone24h: map['emergency_phone_24h'] as String?,
      thermostatType: map['thermostat_type'] as String?,
      thermostatBrand: map['thermostat_brand'] as String?,
      thermostatLocation: map['thermostat_location'] as String?,
      thermostatAppName: map['thermostat_app_name'] as String?,
      thermostatCredentialsLocation: map['thermostat_credentials_location'] as String?,
      controlOnOffLocation: map['control_on_off_location'] as String?,
      controlResetLocation: map['control_reset_location'] as String?,
      pressureGaugeInfo: map['pressure_gauge_info'] as String?,
      troubleshootingSteps: map['troubleshooting_steps'] as String?,
      errorCodes: map['error_codes'] as String?,
      manualDigitalPath: map['manual_digital_path'] as String?,
      manualPhysicalLocation: map['manual_physical_location'] as String?,
      manualOnlineUrl: map['manual_online_url'] as String?,
      videoInstructions: map['video_instructions'] as String?,
      survivorInstructions: map['survivor_instructions'] as String?,
      sellHouseInstructions: map['sell_house_instructions'] as String?,
      maintenanceContractTransferable: map['maintenance_contract_transferable'] == 1,
      purchasePrice: map['purchase_price'] as double?,
      purchaseDate: map['purchase_date'] as String?,
      installationCost: map['installation_cost'] as double?,
      estimatedYearlyConsumption: map['estimated_yearly_consumption'] as int?,
      linkedEnergyContractId: map['linked_energy_contract_id'] as String?,
      numberOfPanels: map['number_of_panels'] as int?,
      panelWattPeak: map['panel_watt_peak'] as int?,
      inverterBrand: map['inverter_brand'] as String?,
      inverterModel: map['inverter_model'] as String?,
      inverterLocation: map['inverter_location'] as String?,
      inverterSerialNumber: map['inverter_serial_number'] as String?,
      inverterWarrantyYears: map['inverter_warranty_years'] as int?,
      monitoringSystem: map['monitoring_system'] as String?,
      monitoringAppName: map['monitoring_app_name'] as String?,
      monitoringPortalUrl: map['monitoring_portal_url'] as String?,
      monitoringCredentialsLocation: map['monitoring_credentials_location'] as String?,
      estimatedYearlyProduction: map['estimated_yearly_production'] as int?,
      subsidyReceived: map['subsidy_received'] as double?,
      heatPumpType: map['heat_pump_type'] as String?,
      cop: map['cop'] as double?,
      outdoorUnitLocation: map['outdoor_unit_location'] as String?,
      indoorUnitLocation: map['indoor_unit_location'] as String?,
      chargingPower: map['charging_power'] as double?,
      hasSmartCharging: map['has_smart_charging'] == 1,
      chargerAppName: map['charger_app_name'] as String?,
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

  /// Bekende CV-ketel merken
  static const List<String> cvBoilerBrands = [
    'Nefit',
    'Remeha',
    'Intergas',
    'Vaillant',
    'Atag',
    'Bosch',
    'Daalderop',
    'AWB',
    'Anders',
  ];

  /// Bekende zonnepaneel merken
  static const List<String> solarPanelBrands = [
    'SunPower',
    'LG',
    'Panasonic',
    'JA Solar',
    'Longi',
    'Trina Solar',
    'Canadian Solar',
    'Q Cells',
    'Anders',
  ];

  /// Bekende omvormer merken
  static const List<String> inverterBrands = [
    'Enphase',
    'SolarEdge',
    'Growatt',
    'SMA',
    'Fronius',
    'Huawei',
    'GoodWe',
    'Anders',
  ];

  /// Bekende warmtepomp merken
  static const List<String> heatPumpBrands = [
    'Daikin',
    'Mitsubishi',
    'Panasonic',
    'Bosch',
    'Vaillant',
    'Nibe',
    'Atlantic',
    'Toshiba',
    'Anders',
  ];

  /// Bekende thermostaat merken
  static const List<String> thermostatBrands = [
    'Nest',
    'Tado',
    'Honeywell',
    'Netatmo',
    'Ecobee',
    'Homey',
    'Anders',
  ];
}







