// lib/modules/subscriptions/models/subscription_enums.dart
// Enums voor de Lidmaatschappen & Abonnementen module

/// Categorieën voor abonnementen
enum SubscriptionCategory {
  streamingMedia('Streaming & Media', '📺', 0xFF9C27B0),
  newspapersMagazines('Kranten & Tijdschriften', '📰', 0xFF795548),
  sportFitness('Sport & Fitness', '🏋️', 0xFF4CAF50),
  associations('Verenigingen & Organisaties', '🏛️', 0xFF2196F3),
  insurance('Verzekeringen', '🛡️', 0xFF009688),
  softwareApps('Software & Apps', '💻', 0xFF3F51B5),
  gaming('Gaming', '🎮', 0xFFE91E63),
  shoppingServices('Winkels & Services', '🛒', 0xFFFF9800),
  mealDelivery('Maaltijd & Kook', '🍽️', 0xFFF44336),
  education('Educatie & Ontwikkeling', '📚', 0xFF00BCD4),
  mobility('Mobiliteit', '🚗', 0xFF607D8B),
  other('Overige', '📦', 0xFF9E9E9E);

  final String label;
  final String emoji;
  final int colorValue;
  const SubscriptionCategory(this.label, this.emoji, this.colorValue);
}

/// Type abonnement
enum SubscriptionType {
  digitalService('Digitale dienst', '🌐'),
  physicalDelivery('Fysiek product (levering)', '📦'),
  membership('Toegang/lidmaatschap', '🎫'),
  software('Software', '💿'),
  donation('Donatie', '❤️'),
  other('Overig', '📋');

  final String label;
  final String emoji;
  const SubscriptionType(this.label, this.emoji);
}

/// Status van abonnement
enum SubscriptionStatus {
  active('Actief', '✅'),
  paused('Gepauzeerd', '⏸️'),
  cancelled('Opgezegd', '📤'),
  ended('Beëindigd', '❌'),
  trial('Proefperiode', '🆓');

  final String label;
  final String emoji;
  const SubscriptionStatus(this.label, this.emoji);
}

/// Betalingsfrequentie
enum PaymentFrequency {
  monthly('Per maand', 1),
  quarterly('Per kwartaal', 3),
  halfYearly('Per half jaar', 6),
  yearly('Per jaar', 12),
  oneTime('Eenmalig', 0),
  other('Anders', 1);

  final String label;
  final int months;
  const PaymentFrequency(this.label, this.months);
}

/// Betaalmethode
enum PaymentMethod {
  directDebit('Automatische incasso', '🏦'),
  creditCard('Creditcard', '💳'),
  ideal('iDEAL', '🔵'),
  paypal('PayPal', '🅿️'),
  appStore('App Store / Google Play', '📱'),
  cash('Contant', '💵'),
  other('Anders', '💰');

  final String label;
  final String emoji;
  const PaymentMethod(this.label, this.emoji);
}

/// Type contract
enum ContractType {
  ongoing('Doorlopend (geen einddatum)', '♾️'),
  fixedTerm('Vaste looptijd', '📅'),
  temporary('Tijdelijk', '⏳'),
  trial('Proefabonnement', '🆓');

  final String label;
  final String emoji;
  const ContractType(this.label, this.emoji);
}

/// Hoe opzeggen
enum CancellationMethod {
  email('Per email', '📧'),
  online('Via online account/portal', '🌐'),
  mail('Per brief (aangetekend)', '✉️'),
  phone('Telefonisch', '📞'),
  app('Via app', '📱'),
  automatic('Automatisch bij nieuwe aanbieder', '🔄');

  final String label;
  final String emoji;
  const CancellationMethod(this.label, this.emoji);
}

/// Actie bij overlijden
enum DeathAction {
  cancelImmediately('Direct opzeggen', '🚨'),
  canContinue('Kan doorlopen (gezinsabonnement)', '👨‍👩‍👧'),
  transferToFamily('Overzetten op partner/gezinslid', '🔄'),
  waitAndSee('Afwachten', '⏳'),
  noAction('Geen actie vereist', '✅');

  final String label;
  final String emoji;
  const DeathAction(this.label, this.emoji);
}

/// Prioriteit opzegging
enum CancellationPriority {
  high('Hoog (binnen 1 week)', '🔴'),
  normal('Normaal (binnen 1 maand)', '🟡'),
  low('Laag (kan wachten)', '🟢');

  final String label;
  final String emoji;
  const CancellationPriority(this.label, this.emoji);
}

/// Locatie inloggegevens
enum CredentialsLocation {
  passwordManager('In wachtwoordmanager', '🔐'),
  paper('Op papier', '📝'),
  browser('In browser opgeslagen', '🌐'),
  partner('Bij partner/gezinslid', '👥'),
  other('Anders', '📋');

  final String label;
  final String emoji;
  const CredentialsLocation(this.label, this.emoji);
}

/// Item status (volledigheid)
enum ItemStatus {
  notStarted('Niet begonnen', '⭕'),
  partial('Bezig', '🔄'),
  complete('Compleet', '✅');

  final String label;
  final String emoji;
  const ItemStatus(this.label, this.emoji);
}







