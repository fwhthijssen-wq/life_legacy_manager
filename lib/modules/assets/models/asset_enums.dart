// lib/modules/assets/models/asset_enums.dart
// Enums voor de Eigendommen/Bezittingen module

/// Hoofdcategorieën voor bezittingen
enum AssetCategory {
  vehicles('Voertuigen', '🚗', 0xFF2196F3),
  jewelryWatches('Sieraden & Horloges', '💎', 0xFFE91E63),
  artAntiques('Kunst & Antiek', '🎨', 0xFF9C27B0),
  collections('Verzamelingen', '📚', 0xFF795548),
  electronics('Elektronica & Apparatuur', '💻', 0xFF607D8B),
  fashionAccessories('Mode & Accessoires', '👜', 0xFFFF9800),
  sportsHobby('Sport & Hobby', '⚽', 0xFF4CAF50),
  furnitureDecor('Woninginrichting & Meubels', '🛋️', 0xFF00BCD4),
  toolsMachinery('Gereedschap & Machines', '🔧', 0xFF8BC34A),
  other('Overige Waardevolle Spullen', '📦', 0xFF9E9E9E);

  final String label;
  final String emoji;
  final int colorValue;
  const AssetCategory(this.label, this.emoji, this.colorValue);
}

/// Subcategorieën per hoofdcategorie
enum VehicleType {
  car('Auto', '🚗'),
  motorcycle('Motor', '🏍️'),
  scooter('Scooter/Bromfiets', '🛵'),
  bicycle('Fiets/E-bike', '🚲'),
  caravan('Caravan/Camper', '🚐'),
  boat('Boot/Jacht', '⛵'),
  classic('Oldtimer/Youngtimer', '🚙'),
  trailer('Aanhangwagen', '🚛'),
  other('Overig', '🚘');

  final String label;
  final String emoji;
  const VehicleType(this.label, this.emoji);
}

enum JewelryType {
  ring('Ring', '💍'),
  necklace('Ketting', '📿'),
  bracelet('Armband', '⌚'),
  earrings('Oorbellen', '✨'),
  watch('Horloge', '⌚'),
  cufflinks('Manchetknopen', '🔘'),
  brooch('Broche', '📍'),
  other('Overig', '💎');

  final String label;
  final String emoji;
  const JewelryType(this.label, this.emoji);
}

enum ArtType {
  painting('Schilderij', '🖼️'),
  sculpture('Sculptuur/Beeld', '🗿'),
  print('Prent/Litho', '🎭'),
  antiqueFurniture('Antiek meubilair', '🪑'),
  porcelain('Porselein/Servies', '🏺'),
  clock('Antieke klok', '🕰️'),
  vintage('Vintage item', '📻'),
  other('Overig', '🎨');

  final String label;
  final String emoji;
  const ArtType(this.label, this.emoji);
}

enum CollectionType {
  stamps('Postzegels', '📬'),
  coins('Munten', '🪙'),
  wine('Wijnen', '🍷'),
  whisky('Whisky/Gedistilleerd', '🥃'),
  books('Boeken (zeldzaam)', '📚'),
  comics('Stripboeken/Comics', '📖'),
  vinyl('Vinyl/Platen', '💿'),
  toys('Speelgoed (Lego, vintage)', '🧸'),
  sportsMemorabilia('Sportmemorabilia', '🏆'),
  militaria('Militaria', '🎖️'),
  other('Overig', '🗃️');

  final String label;
  final String emoji;
  const CollectionType(this.label, this.emoji);
}

enum ElectronicsType {
  computer('Computer/Laptop', '💻'),
  camera('Camera/Fotoapparatuur', '📷'),
  drone('Drone', '🚁'),
  gamingConsole('Gaming console', '🎮'),
  audioEquipment('Audio apparatuur', '🔊'),
  instrument('Muziekinstrument', '🎸'),
  phonesTablets('Telefoons/Tablets', '📱'),
  other('Overig', '🔌');

  final String label;
  final String emoji;
  const ElectronicsType(this.label, this.emoji);
}

enum FashionType {
  designerClothing('Designerkleding', '👔'),
  designerBag('Designertas', '👜'),
  designerShoes('Designerschoenen', '👠'),
  vintageClothing('Vintage kleding', '👗'),
  furCoat('Bontjas', '🧥'),
  sunglasses('Luxe zonnebril', '🕶️'),
  other('Overig', '🎀');

  final String label;
  final String emoji;
  const FashionType(this.label, this.emoji);
}

enum SportsType {
  racingBike('Racefiets', '🚴'),
  mountainBike('Mountainbike', '🚵'),
  golfClubs('Golfclubs', '⛳'),
  surfboard('Surfboard/Kitesurf', '🏄'),
  divingGear('Duikuitrusting', '🤿'),
  campingGear('Kampeeruitrusting', '⛺'),
  skiGear('Skispullen', '⛷️'),
  fitnessEquipment('Fitness apparatuur', '🏋️'),
  other('Overig', '🏅');

  final String label;
  final String emoji;
  const SportsType(this.label, this.emoji);
}

enum FurnitureType {
  designerFurniture('Designmeubels', '🛋️'),
  designerLamp('Designlampen', '💡'),
  carpet('Tapijt (Perzisch, antiek)', '🪢'),
  crystal('Kristal/Glas', '🔮'),
  silverware('Zilverwerk', '🥄'),
  vase('Vazen', '🏺'),
  other('Overig', '🪴');

  final String label;
  final String emoji;
  const FurnitureType(this.label, this.emoji);
}

enum ToolsType {
  professionalTools('Professioneel gereedschap', '🛠️'),
  powerTools('Elektrisch gereedschap', '🔌'),
  gardenMachinery('Tuinmachines', '🌿'),
  constructionMachinery('Bouwmachines', '🏗️'),
  other('Overig', '🔧');

  final String label;
  final String emoji;
  const ToolsType(this.label, this.emoji);
}

enum OtherAssetType {
  diplomas('Diploma\'s/Certificaten', '📜'),
  autographs('Handtekeningen beroemdheden', '✍️'),
  heirlooms('Erfstukken', '👑'),
  gemstones('Edelstenen (los)', '💠'),
  preciousMetals('Goud/Zilver (baren, munten)', '🥇'),
  cryptoWallet('Crypto hardware wallets', '₿'),
  domainNames('Domeinnamen (waardevolle)', '🌐'),
  other('Overig', '📦');

  final String label;
  final String emoji;
  const OtherAssetType(this.label, this.emoji);
}

/// Staat van het item
enum AssetCondition {
  asNew('Nieuw', '✨'),
  likeNew('Als nieuw', '⭐'),
  good('Goed', '👍'),
  fair('Redelijk', '👌'),
  poor('Matig', '⚠️'),
  forParts('Voor onderdelen', '🔧');

  final String label;
  final String emoji;
  const AssetCondition(this.label, this.emoji);
}

/// Herkomst van het item
enum AssetOrigin {
  boughtNew('Gekocht nieuw', '🛒'),
  boughtUsed('Gekocht tweedehands', '🔄'),
  inherited('Geërfd', '👨‍👩‍👧'),
  gift('Gekregen als cadeau', '🎁'),
  selfMade('Zelf gemaakt', '✋'),
  found('Gevonden', '🔍'),
  other('Anders', '📋');

  final String label;
  final String emoji;
  const AssetOrigin(this.label, this.emoji);
}

/// Basis voor waardering
enum ValuationBasis {
  purchasePrice('Aankoopprijs', '🧾'),
  onlineMarket('Online marktplaatsen', '🌐'),
  appraisal('Taxatie door specialist', '📊'),
  ownerEstimate('Schatting eigenaar', '🤔'),
  insuredValue('Verzekerde waarde', '🛡️');

  final String label;
  final String emoji;
  const ValuationBasis(this.label, this.emoji);
}

/// Type verzekering
enum InsuranceType {
  homeContents('Inboedelverzekering (onderdeel van)', '🏠'),
  separateValuables('Apart verzekerd (kostbaarheden)', '💎'),
  notInsured('Niet verzekerd', '❌');

  final String label;
  final String emoji;
  const InsuranceType(this.label, this.emoji);
}

/// Locatie van het item
enum AssetLocationType {
  home('Thuis', '🏠'),
  homeSafe('In kluis (thuis)', '🔐'),
  bankSafe('Bij bank (kluisje)', '🏦'),
  family('Bij familie', '👨‍👩‍👧'),
  storage('Opslag/opslagbedrijf', '📦'),
  garageSheShed('Garage/schuur/zolder', '🏚️'),
  other('Anders', '📍');

  final String label;
  final String emoji;
  const AssetLocationType(this.label, this.emoji);
}

/// Toegankelijkheid
enum AccessibilityType {
  directAccess('Direct toegankelijk', '🚪'),
  withKey('Met sleutel', '🔑'),
  withCode('Met code', '🔢'),
  viaPersonOnly('Alleen via persoon', '👤');

  final String label;
  final String emoji;
  const AccessibilityType(this.label, this.emoji);
}

/// Sentimentele waarde
enum SentimentalValue {
  veryHigh('Zeer hoog (erfstuk)', '💖'),
  high('Hoog', '❤️'),
  medium('Gemiddeld', '💛'),
  low('Laag (alleen financieel)', '💰');

  final String label;
  final String emoji;
  const SentimentalValue(this.label, this.emoji);
}

/// Bestemming na overlijden
enum InheritanceDestination {
  heir('Naar erfgenaam', '👤'),
  sellAndDivide('Verkopen en verdelen', '💰'),
  donate('Doneren aan goed doel', '❤️'),
  undecided('Nog niet beslist', '❓');

  final String label;
  final String emoji;
  const InheritanceDestination(this.label, this.emoji);
}

/// Authenticiteit
enum AuthenticityStatus {
  authentic('Echt / authentiek', '✅'),
  replica('Replica', '🔄'),
  unknown('Onbekend', '❓');

  final String label;
  final String emoji;
  const AuthenticityStatus(this.label, this.emoji);
}

/// Item status (volledigheid)
enum AssetItemStatus {
  notStarted('Niet begonnen', '⭕'),
  partial('Bezig', '🔄'),
  complete('Compleet', '✅');

  final String label;
  final String emoji;
  const AssetItemStatus(this.label, this.emoji);
}






