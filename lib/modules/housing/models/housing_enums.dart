// lib/modules/housing/models/housing_enums.dart
// Enums voor de Wonen & Energie module

/// Type woning
enum PropertyType {
  singleFamily('Eengezinswoning', '🏠'),
  apartment('Appartement', '🏢'),
  rowHouse('Rijtjeshuis', '🏘️'),
  semiDetached('Twee-onder-één-kap', '🏡'),
  detached('Vrijstaand', '🏰'),
  bungalow('Bungalow', '🏕️'),
  vacationHome('Vakantiehuis', '🏖️'),
  other('Overig', '🏗️');

  final String label;
  final String emoji;
  const PropertyType(this.label, this.emoji);
}

/// Eigendomssituatie
enum OwnershipType {
  owned('Eigen woning (gekocht)', '🔑'),
  rented('Huurwoning', '📋'),
  leasehold('Erfpacht', '📜'),
  temporary('Tijdelijk', '⏳');

  final String label;
  final String emoji;
  const OwnershipType(this.label, this.emoji);
}

/// Energielabel
enum EnergyLabel {
  aPlusPlusPlus('A++++', 0xFF4CAF50), // green
  aPlusPlus('A+++', 0xFF4CAF50),
  aPlus('A++', 0xFF4CAF50),
  a('A+', 0xFF8BC34A), // lightGreen
  aBasic('A', 0xFF8BC34A),
  b('B', 0xFFCDDC39), // lime
  c('C', 0xFFFFEB3B), // yellow
  d('D', 0xFFFF9800), // orange
  e('E', 0xFFFF5722), // deepOrange
  f('F', 0xFFF44336), // red
  g('G', 0xFFF44336);

  final String label;
  final int colorValue; // Color als int
  const EnergyLabel(this.label, this.colorValue);
}

/// Hypotheekvorm
enum MortgageType {
  annuity('Annuïtair', '📊'),
  linear('Lineair', '📉'),
  interestOnly('Aflossingsvrij', '💰'),
  savings('Spaarhypotheek', '🏦'),
  life('Levenhypotheek', '📈'),
  other('Anders', '📋');

  final String label;
  final String emoji;
  const MortgageType(this.label, this.emoji);
}

/// Verhuurder type
enum LandlordType {
  private('Particulier', '👤'),
  corporation('Woningcorporatie', '🏛️'),
  propertyManager('Vastgoedbeheerder', '🏢');

  final String label;
  final String emoji;
  const LandlordType(this.label, this.emoji);
}

/// Type huurcontract
enum RentalContractType {
  indefinite('Onbepaalde tijd', '∞'),
  fixedTerm('Bepaalde tijd', '📅'),
  temporary('Tijdelijk', '⏳');

  final String label;
  final String emoji;
  const RentalContractType(this.label, this.emoji);
}

/// Type energie
enum EnergyType {
  electricity('Elektriciteit', '⚡'),
  gas('Gas (aardgas)', '🔥'),
  districtHeating('Stadsverwarming', '♨️'),
  combined('Combinatie', '🔌');

  final String label;
  final String emoji;
  const EnergyType(this.label, this.emoji);
}

/// Type energiecontract
enum EnergyContractType {
  fixed('Vast tarief', '🔒'),
  variable('Variabel tarief', '📈'),
  dynamic('Dynamisch tarief', '⚡');

  final String label;
  final String emoji;
  const EnergyContractType(this.label, this.emoji);
}

/// Type nutsvoorziening
enum UtilityType {
  water('Water', '💧'),
  internetTv('Internet & TV', '📡'),
  phoneMobile('Telefonie', '📱'),
  sewage('Riolering', '🚿'),
  waste('Afvalverwerking', '🗑️');

  final String label;
  final String emoji;
  const UtilityType(this.label, this.emoji);
}

/// Type internet aansluiting
enum InternetConnectionType {
  cable('Kabel (Coax)', '📺'),
  fiber('Glasvezel (FTTH)', '💎'),
  dsl('DSL / VDSL', '📞'),
  mobile('Mobiel (4G/5G)', '📱');

  final String label;
  final String emoji;
  const InternetConnectionType(this.label, this.emoji);
}

/// Type installatie
enum InstallationType {
  cvBoiler('CV-ketel', '🔥'),
  heatPump('Warmtepomp', '♻️'),
  solarPanels('Zonnepanelen', '☀️'),
  homeBattery('Thuisbatterij', '🔋'),
  evCharger('Laadpaal', '🔌'),
  airConditioning('Airconditioning', '❄️'),
  ventilation('Mechanische ventilatie', '💨'),
  solarBoiler('Zonneboiler', '🌡️'),
  other('Overig', '🔧');

  final String label;
  final String emoji;
  const InstallationType(this.label, this.emoji);
}

/// Type huishoudelijk apparaat
enum ApplianceType {
  washingMachine('Wasmachine', '🧺'),
  dryer('Wasdroger', '👕'),
  dishwasher('Vaatwasser', '🍽️'),
  refrigerator('Koelkast', '🧊'),
  freezer('Vriezer', '❄️'),
  fridgeFreezer('Koel-vriescombinatie', '🧊'),
  oven('Oven', '🍕'),
  microwave('Magnetron', '📻'),
  cooktop('Kookplaat', '🍳'),
  rangeHood('Afzuigkap', '💨'),
  coffeeMachine('Koffiezetapparaat', '☕'),
  robotVacuum('Stofzuiger (robot)', '🤖'),
  smartHome('Smart home / Domotica', '🏠'),
  alarmSystem('Alarmsysteem', '🚨'),
  nas('NAS / Server', '💾'),
  camera('Camera / Videofoon', '📹'),
  other('Overig', '📦');

  final String label;
  final String emoji;
  const ApplianceType(this.label, this.emoji);
}

/// Type onderhoudsdienst
enum MaintenanceServiceType {
  gardener('Tuinman', '🌳'),
  cleaning('Schoonmaak', '🧹'),
  windowCleaner('Glazenwasser', '🪟'),
  handyman('Klusjesman', '🔨'),
  hvacTechnician('CV-monteur', '🔥'),
  electrician('Elektricien', '⚡'),
  plumber('Loodgieter', '🔧'),
  pestControl('Ongediertebestrijding', '🐛'),
  chimneySweep('Schoorsteenveger', '🧹'),
  other('Overig', '👷');

  final String label;
  final String emoji;
  const MaintenanceServiceType(this.label, this.emoji);
}

/// Frequentie van dienstverlening
enum ServiceFrequency {
  weekly('Wekelijks', '📅'),
  biweekly('2-wekelijks', '📆'),
  monthly('Maandelijks', '🗓️'),
  quarterly('Per kwartaal', '📊'),
  yearly('Jaarlijks', '📈'),
  onCall('Op afroep', '📞');

  final String label;
  final String emoji;
  const ServiceFrequency(this.label, this.emoji);
}

/// Status van een housing item
enum HousingItemStatus {
  notStarted('Niet begonnen', '⭕'),
  partial('Bezig', '🔄'),
  complete('Compleet', '✅');

  final String label;
  final String emoji;
  const HousingItemStatus(this.label, this.emoji);
}

/// Wat gebeurt bij overlijden
enum PropertyDeathAction {
  staysWithPartner('Blijft bij partner', '💑'),
  toHeirs('Gaat naar erfgenamen', '👨‍👩‍👧‍👦'),
  mustBeSold('Moet worden verkocht', '🏷️'),
  seeWill('Testament bepaalt', '📜');

  final String label;
  final String emoji;
  const PropertyDeathAction(this.label, this.emoji);
}


