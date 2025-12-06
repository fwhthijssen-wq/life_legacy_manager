// lib/core/premium/premium_features.dart

/// Alle premium features in de app
enum PremiumFeature {
  // ===== CONTACTEN =====
  unlimitedContacts('Onbeperkt contacten', 'Voeg onbeperkt contacten toe'),
  bulkEmail('Bulk email', 'Stuur email naar meerdere contacten tegelijk'),
  pdfAddressList('PDF adreslijsten', 'Genereer professionele adreslijsten'),
  addressLabels('Adresstickers', 'Print Avery-formaat adresstickers'),
  importContacts('Import contacten', 'Importeer van CSV, vCard, Google, Outlook'),
  exportContacts('Export contacten', 'Exporteer naar CSV of vCard'),
  emailTemplates('Email templates', 'Maak en bewaar email sjablonen'),
  smartSelections('Slimme selecties', 'Sla contactselecties op voor later'),
  
  // ===== PERSONEN =====
  unlimitedPersons('Onbeperkt personen', 'Voeg onbeperkt personen toe'),
  documentStorage('Documenten opslag', 'Sla scans van documenten op'),
  
  // ===== DOSSIERS =====
  unlimitedDossiers('Onbeperkt dossiers', 'Maak onbeperkt dossiers aan'),
  dossierSharing('Dossier delen', 'Deel dossiers met familieleden'),
  
  // ===== GELDZAKEN =====
  bankAccounts('Bankrekeningen', 'Beheer bankrekeningen'),
  insurances('Verzekeringen', 'Beheer verzekeringen'),
  subscriptions('Abonnementen', 'Beheer abonnementen en vaste lasten'),
  
  // ===== BACKUP =====
  cloudBackup('Cloud backup', 'Automatische backup naar de cloud'),
  exportBackup('Export backup', 'Exporteer alle gegevens'),
  
  // ===== ALGEMEEN =====
  removeAds('Geen advertenties', 'Verwijder alle advertenties'),
  prioritySupport('Prioriteit support', 'Snellere reactie op vragen');

  final String displayName;
  final String description;
  
  const PremiumFeature(this.displayName, this.description);
}

/// Gratis limieten voor de app
class FreeLimits {
  /// Maximum aantal contacten in gratis versie
  static const int maxContacts = 25;
  
  /// Maximum aantal personen in gratis versie
  static const int maxPersons = 10;
  
  /// Maximum aantal dossiers in gratis versie
  static const int maxDossiers = 2;
  
  /// Maximum aantal documenten per persoon in gratis versie
  static const int maxDocumentsPerPerson = 3;
}

/// Premium pakket types
enum PremiumPlan {
  free('Gratis', 0),
  monthly('Maandelijks', 4.99),
  yearly('Jaarlijks', 39.99),
  lifetime('Eenmalig', 79.99);

  final String displayName;
  final double price;
  
  const PremiumPlan(this.displayName, this.price);
  
  /// Besparing percentage voor yearly vs monthly
  double get yearlySavings {
    if (this == PremiumPlan.yearly) {
      final monthlyYearly = PremiumPlan.monthly.price * 12;
      return ((monthlyYearly - price) / monthlyYearly * 100).roundToDouble();
    }
    return 0;
  }
}






