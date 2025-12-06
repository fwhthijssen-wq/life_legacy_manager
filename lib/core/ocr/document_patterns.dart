// lib/core/ocr/document_patterns.dart

/// Patterns voor het herkennen van financiële gegevens uit gescande documenten

class DocumentPatterns {
  // ============== BANKGEGEVENS ==============
  
  /// Nederlandse IBAN: NL + 2 cijfers + 4 letters + 10 cijfers
  static final RegExp ibanPattern = RegExp(
    r'[A-Z]{2}\d{2}\s?[A-Z]{4}\s?\d{4}\s?\d{4}\s?\d{2}',
    caseSensitive: false,
  );
  
  /// BIC/SWIFT code: 8 of 11 karakters
  static final RegExp bicPattern = RegExp(
    r'[A-Z]{4}[A-Z]{2}[A-Z0-9]{2}([A-Z0-9]{3})?',
    caseSensitive: false,
  );
  
  /// Saldo/Bedrag: €1.234,56 of EUR 1234.56
  static final RegExp amountPattern = RegExp(
    r'[€EUR]\s*[\d.,]+|\d+[.,]\d{2}\s*(?:EUR|euro)',
    caseSensitive: false,
  );
  
  /// Alleen getal met decimalen (voor bedragen)
  static final RegExp decimalPattern = RegExp(
    r'\d{1,3}(?:[.,]\d{3})*[.,]\d{2}',
  );
  
  // ============== VERZEKERINGEN ==============
  
  /// Polisnummer: vaak combinatie van letters en cijfers
  static final RegExp policyNumberPattern = RegExp(
    r'(?:polis(?:nummer)?|policy)\s*:?\s*([A-Z0-9-]+)',
    caseSensitive: false,
  );
  
  /// Premie
  static final RegExp premiumPattern = RegExp(
    r'(?:premie|premium)\s*:?\s*[€EUR]?\s*([\d.,]+)',
    caseSensitive: false,
  );
  
  /// Eigen risico
  static final RegExp deductiblePattern = RegExp(
    r'(?:eigen\s*risico|deductible)\s*:?\s*[€EUR]?\s*([\d.,]+)',
    caseSensitive: false,
  );
  
  // ============== PENSIOEN ==============
  
  /// Deelnemersnummer
  static final RegExp participantNumberPattern = RegExp(
    r'(?:deelnemer(?:snummer)?|participant)\s*:?\s*(\d+)',
    caseSensitive: false,
  );
  
  /// Pensioenuitkering
  static final RegExp pensionAmountPattern = RegExp(
    r'(?:pensioen|uitkering|bruto)\s*:?\s*[€EUR]?\s*([\d.,]+)',
    caseSensitive: false,
  );
  
  // ============== DATUMS ==============
  
  /// Datum: DD-MM-YYYY of DD/MM/YYYY of D MAAND YYYY
  static final RegExp datePattern = RegExp(
    r'\d{1,2}[-/]\d{1,2}[-/]\d{2,4}|\d{1,2}\s+(?:januari|februari|maart|april|mei|juni|juli|augustus|september|oktober|november|december)\s+\d{4}',
    caseSensitive: false,
  );
  
  // ============== PERCENTAGES ==============
  
  /// Percentage: 3,5% of 3.5%
  static final RegExp percentagePattern = RegExp(
    r'(\d+[.,]?\d*)\s*%',
  );
  
  // ============== TELEFOON ==============
  
  /// Nederlands telefoonnummer
  static final RegExp phonePattern = RegExp(
    r'(?:\+31|0031|0)\s*[1-9](?:[- ]?\d){8}',
  );
  
  // ============== EMAIL ==============
  
  static final RegExp emailPattern = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  );
  
  // ============== WEBSITE ==============
  
  static final RegExp websitePattern = RegExp(
    r'(?:https?://)?(?:www\.)?[a-zA-Z0-9-]+\.[a-zA-Z]{2,}(?:/[^\s]*)?',
    caseSensitive: false,
  );
  
  // ============== BEKENDE BANKEN ==============
  
  static const List<String> dutchBanks = [
    'ABN AMRO',
    'ING',
    'Rabobank',
    'SNS',
    'ASN',
    'Triodos',
    'Knab',
    'bunq',
    'N26',
    'Revolut',
    'RegioBank',
  ];
  
  // ============== BEKENDE VERZEKERAARS ==============
  
  static const List<String> dutchInsurers = [
    'Achmea',
    'Aegon',
    'Allianz',
    'ASR',
    'Centraal Beheer',
    'CZ',
    'Delta Lloyd',
    'Interpolis',
    'Menzis',
    'Nationale-Nederlanden',
    'OHRA',
    'VGZ',
    'Zilveren Kruis',
    'FBTO',
    'Univé',
  ];
  
  // ============== BEKENDE PENSIOENFONDSEN ==============
  
  static const List<String> dutchPensionFunds = [
    'ABP',
    'PFZW',
    'PMT',
    'PME',
    'bpfBOUW',
    'Pensioenfonds Metaal en Techniek',
    'Pensioenfonds Zorg en Welzijn',
    'SVB',
  ];
  
  /// Zoek een bekende organisatie in de tekst
  static String? findKnownOrganization(String text, List<String> organizations) {
    final lowerText = text.toLowerCase();
    for (final org in organizations) {
      if (lowerText.contains(org.toLowerCase())) {
        return org;
      }
    }
    return null;
  }
  
  /// Parse een bedrag string naar double
  static double? parseAmount(String? amountStr) {
    if (amountStr == null || amountStr.isEmpty) return null;
    
    // Verwijder valuta symbolen en spaties
    var cleaned = amountStr.replaceAll(RegExp(r'[€EUR\s]', caseSensitive: false), '');
    
    // Bepaal decimaal scheidingsteken
    // Als er zowel . als , in zit, is de laatste het decimaalteken
    if (cleaned.contains('.') && cleaned.contains(',')) {
      final lastDot = cleaned.lastIndexOf('.');
      final lastComma = cleaned.lastIndexOf(',');
      
      if (lastComma > lastDot) {
        // Komma is decimaalteken (Nederlands)
        cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // Punt is decimaalteken (Engels)
        cleaned = cleaned.replaceAll(',', '');
      }
    } else if (cleaned.contains(',')) {
      // Alleen komma, waarschijnlijk Nederlands decimaalteken
      cleaned = cleaned.replaceAll(',', '.');
    }
    
    return double.tryParse(cleaned);
  }
  
  /// Normaliseer IBAN (verwijder spaties)
  static String normalizeIban(String iban) {
    return iban.replaceAll(RegExp(r'\s'), '').toUpperCase();
  }
  
  /// Valideer IBAN checksum (basis check)
  static bool isValidIban(String iban) {
    final normalized = normalizeIban(iban);
    if (normalized.length < 15 || normalized.length > 34) return false;
    
    // Nederlandse IBAN moet 18 karakters zijn
    if (normalized.startsWith('NL') && normalized.length != 18) return false;
    
    return true;
  }
}

/// Resultaat van document scanning
class ScannedDocumentData {
  // Bank gegevens
  final String? iban;
  final String? bic;
  final String? bankName;
  final double? balance;
  final String? accountHolder;
  
  // Verzekering gegevens
  final String? insurerName;
  final String? policyNumber;
  final double? premium;
  final double? deductible;
  final double? coverageAmount;
  
  // Pensioen gegevens
  final String? pensionFund;
  final String? participantNumber;
  final double? expectedPension;
  
  // Algemeen
  final String? phone;
  final String? email;
  final String? website;
  final List<String> dates;
  final List<double> amounts;
  final List<double> percentages;
  
  // Ruwe tekst
  final String rawText;
  
  ScannedDocumentData({
    this.iban,
    this.bic,
    this.bankName,
    this.balance,
    this.accountHolder,
    this.insurerName,
    this.policyNumber,
    this.premium,
    this.deductible,
    this.coverageAmount,
    this.pensionFund,
    this.participantNumber,
    this.expectedPension,
    this.phone,
    this.email,
    this.website,
    this.dates = const [],
    this.amounts = const [],
    this.percentages = const [],
    required this.rawText,
  });
  
  bool get hasData => 
    iban != null || 
    bankName != null || 
    insurerName != null || 
    policyNumber != null ||
    pensionFund != null ||
    amounts.isNotEmpty;
}






