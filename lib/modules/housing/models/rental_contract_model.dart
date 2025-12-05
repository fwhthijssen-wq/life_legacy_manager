// lib/modules/housing/models/rental_contract_model.dart
// Model voor huurcontracten

import 'housing_enums.dart';

class RentalContractModel {
  final String id;
  final String propertyId;
  
  // Basisgegevens (Tab 1)
  final LandlordType landlordType;
  final String? landlordName;
  final String? landlordAddress;
  final String? landlordPhone;
  final String? landlordEmail;
  final String? landlordWebsite;
  final String? contactName;
  final String? contactFunction;
  final String? contactPhone;
  final String? contactEmail;
  final String? contractNumber;
  final String? startDate;
  final RentalContractType contractType;
  final String? endDate;
  
  // Huurprijs & Kosten (Tab 2)
  final double? baseRent;
  final double? serviceCosts;
  final int? paymentDay;
  final bool isDirectDebit;
  final String? paymentBankAccountId;
  final double? depositAmount;
  final String? depositPaidDate;
  final String? depositLocation;
  final String? depositAccount;
  final bool rentIncreaseCpi;
  final double? rentIncreasePercentage;
  final String? lastIncreaseDate;
  
  // Opzegging (Tab 3)
  final int? noticePeriodTenant;
  final int? noticePeriodLandlord;
  final String? cancellationMethod;
  final String? cancellationAddress;
  final int? minRentalTerm;
  final bool isSocialHousing;
  
  // Wat is inbegrepen (Tab 4)
  final bool energyIncluded;
  final bool waterIncluded;
  final bool internetIncluded;
  final bool tvIncluded;
  final bool parkingIncluded;
  final int? parkingCount;
  final String? parkingLocation;
  final bool storageIncluded;
  final bool gardenIncluded;
  final String? gardenMaintenance;
  
  // Onderhoud (Tab 5)
  final String? smallMaintenance;
  final String? largeMaintenance;
  final String? painting;
  final String? gardenCare;
  final String? cvMaintenance;
  final String? repairReportPhone;
  final String? repairReportEmail;
  final String? repairReportUrl;
  
  // Voor nabestaanden (Tab 6)
  final String? deathAction;
  final String? deathInstructions;
  final String? depositReturnInstructions;
  
  // Notities
  final String? notes;
  
  // Status
  final HousingItemStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  RentalContractModel({
    required this.id,
    required this.propertyId,
    this.landlordType = LandlordType.private,
    this.landlordName,
    this.landlordAddress,
    this.landlordPhone,
    this.landlordEmail,
    this.landlordWebsite,
    this.contactName,
    this.contactFunction,
    this.contactPhone,
    this.contactEmail,
    this.contractNumber,
    this.startDate,
    this.contractType = RentalContractType.indefinite,
    this.endDate,
    this.baseRent,
    this.serviceCosts,
    this.paymentDay,
    this.isDirectDebit = true,
    this.paymentBankAccountId,
    this.depositAmount,
    this.depositPaidDate,
    this.depositLocation,
    this.depositAccount,
    this.rentIncreaseCpi = true,
    this.rentIncreasePercentage,
    this.lastIncreaseDate,
    this.noticePeriodTenant,
    this.noticePeriodLandlord,
    this.cancellationMethod,
    this.cancellationAddress,
    this.minRentalTerm,
    this.isSocialHousing = false,
    this.energyIncluded = false,
    this.waterIncluded = false,
    this.internetIncluded = false,
    this.tvIncluded = false,
    this.parkingIncluded = false,
    this.parkingCount,
    this.parkingLocation,
    this.storageIncluded = false,
    this.gardenIncluded = false,
    this.gardenMaintenance,
    this.smallMaintenance,
    this.largeMaintenance,
    this.painting,
    this.gardenCare,
    this.cvMaintenance,
    this.repairReportPhone,
    this.repairReportEmail,
    this.repairReportUrl,
    this.deathAction,
    this.deathInstructions,
    this.depositReturnInstructions,
    this.notes,
    this.status = HousingItemStatus.notStarted,
    required this.createdAt,
    this.updatedAt,
  });

  String get displayName => landlordName ?? 'Huurcontract';

  double get totalMonthlyRent => (baseRent ?? 0) + (serviceCosts ?? 0);

  int get completenessPercentage {
    int filled = 0;
    int total = 12;

    if (landlordName?.isNotEmpty == true) filled++;
    if (startDate?.isNotEmpty == true) filled++;
    if (baseRent != null) filled++;
    if (depositAmount != null) filled++;
    if (noticePeriodTenant != null) filled++;
    if (cancellationMethod?.isNotEmpty == true) filled++;
    if (repairReportPhone?.isNotEmpty == true) filled++;
    if (deathAction?.isNotEmpty == true) filled++;
    if (depositReturnInstructions?.isNotEmpty == true) filled++;
    if (landlordPhone?.isNotEmpty == true) filled++;
    if (contractNumber?.isNotEmpty == true) filled++;
    if (notes?.isNotEmpty == true) filled++;

    return ((filled / total) * 100).round();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'property_id': propertyId,
      'landlord_type': landlordType.name,
      'landlord_name': landlordName,
      'landlord_address': landlordAddress,
      'landlord_phone': landlordPhone,
      'landlord_email': landlordEmail,
      'landlord_website': landlordWebsite,
      'contact_name': contactName,
      'contact_function': contactFunction,
      'contact_phone': contactPhone,
      'contact_email': contactEmail,
      'contract_number': contractNumber,
      'start_date': startDate,
      'contract_type': contractType.name,
      'end_date': endDate,
      'base_rent': baseRent,
      'service_costs': serviceCosts,
      'payment_day': paymentDay,
      'is_direct_debit': isDirectDebit ? 1 : 0,
      'payment_bank_account_id': paymentBankAccountId,
      'deposit_amount': depositAmount,
      'deposit_paid_date': depositPaidDate,
      'deposit_location': depositLocation,
      'deposit_account': depositAccount,
      'rent_increase_cpi': rentIncreaseCpi ? 1 : 0,
      'rent_increase_percentage': rentIncreasePercentage,
      'last_increase_date': lastIncreaseDate,
      'notice_period_tenant': noticePeriodTenant,
      'notice_period_landlord': noticePeriodLandlord,
      'cancellation_method': cancellationMethod,
      'cancellation_address': cancellationAddress,
      'min_rental_term': minRentalTerm,
      'is_social_housing': isSocialHousing ? 1 : 0,
      'energy_included': energyIncluded ? 1 : 0,
      'water_included': waterIncluded ? 1 : 0,
      'internet_included': internetIncluded ? 1 : 0,
      'tv_included': tvIncluded ? 1 : 0,
      'parking_included': parkingIncluded ? 1 : 0,
      'parking_count': parkingCount,
      'parking_location': parkingLocation,
      'storage_included': storageIncluded ? 1 : 0,
      'garden_included': gardenIncluded ? 1 : 0,
      'garden_maintenance': gardenMaintenance,
      'small_maintenance': smallMaintenance,
      'large_maintenance': largeMaintenance,
      'painting': painting,
      'garden_care': gardenCare,
      'cv_maintenance': cvMaintenance,
      'repair_report_phone': repairReportPhone,
      'repair_report_email': repairReportEmail,
      'repair_report_url': repairReportUrl,
      'death_action': deathAction,
      'death_instructions': deathInstructions,
      'deposit_return_instructions': depositReturnInstructions,
      'notes': notes,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory RentalContractModel.fromMap(Map<String, dynamic> map) {
    return RentalContractModel(
      id: map['id'] as String,
      propertyId: map['property_id'] as String,
      landlordType: LandlordType.values.firstWhere(
        (e) => e.name == map['landlord_type'],
        orElse: () => LandlordType.private,
      ),
      landlordName: map['landlord_name'] as String?,
      landlordAddress: map['landlord_address'] as String?,
      landlordPhone: map['landlord_phone'] as String?,
      landlordEmail: map['landlord_email'] as String?,
      landlordWebsite: map['landlord_website'] as String?,
      contactName: map['contact_name'] as String?,
      contactFunction: map['contact_function'] as String?,
      contactPhone: map['contact_phone'] as String?,
      contactEmail: map['contact_email'] as String?,
      contractNumber: map['contract_number'] as String?,
      startDate: map['start_date'] as String?,
      contractType: RentalContractType.values.firstWhere(
        (e) => e.name == map['contract_type'],
        orElse: () => RentalContractType.indefinite,
      ),
      endDate: map['end_date'] as String?,
      baseRent: map['base_rent'] as double?,
      serviceCosts: map['service_costs'] as double?,
      paymentDay: map['payment_day'] as int?,
      isDirectDebit: map['is_direct_debit'] == 1,
      paymentBankAccountId: map['payment_bank_account_id'] as String?,
      depositAmount: map['deposit_amount'] as double?,
      depositPaidDate: map['deposit_paid_date'] as String?,
      depositLocation: map['deposit_location'] as String?,
      depositAccount: map['deposit_account'] as String?,
      rentIncreaseCpi: map['rent_increase_cpi'] == 1,
      rentIncreasePercentage: map['rent_increase_percentage'] as double?,
      lastIncreaseDate: map['last_increase_date'] as String?,
      noticePeriodTenant: map['notice_period_tenant'] as int?,
      noticePeriodLandlord: map['notice_period_landlord'] as int?,
      cancellationMethod: map['cancellation_method'] as String?,
      cancellationAddress: map['cancellation_address'] as String?,
      minRentalTerm: map['min_rental_term'] as int?,
      isSocialHousing: map['is_social_housing'] == 1,
      energyIncluded: map['energy_included'] == 1,
      waterIncluded: map['water_included'] == 1,
      internetIncluded: map['internet_included'] == 1,
      tvIncluded: map['tv_included'] == 1,
      parkingIncluded: map['parking_included'] == 1,
      parkingCount: map['parking_count'] as int?,
      parkingLocation: map['parking_location'] as String?,
      storageIncluded: map['storage_included'] == 1,
      gardenIncluded: map['garden_included'] == 1,
      gardenMaintenance: map['garden_maintenance'] as String?,
      smallMaintenance: map['small_maintenance'] as String?,
      largeMaintenance: map['large_maintenance'] as String?,
      painting: map['painting'] as String?,
      gardenCare: map['garden_care'] as String?,
      cvMaintenance: map['cv_maintenance'] as String?,
      repairReportPhone: map['repair_report_phone'] as String?,
      repairReportEmail: map['repair_report_email'] as String?,
      repairReportUrl: map['repair_report_url'] as String?,
      deathAction: map['death_action'] as String?,
      deathInstructions: map['death_instructions'] as String?,
      depositReturnInstructions: map['deposit_return_instructions'] as String?,
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
}





