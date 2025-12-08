// lib/core/bulk_import/models/scanned_account.dart

/// Een gescande bankrekening uit een document
class ScannedAccount {
  final String iban;
  final String? accountHolder;
  final String? bankName;
  final double? balance;
  final String? balanceDate;
  final String? accountType; // betaalrekening, spaarrekening, etc.
  final double confidence; // 0.0 - 1.0
  
  // Voor matching met dossierleden
  String? matchedPersonId;
  String? matchedPersonName;
  double matchConfidence;
  
  // Status
  bool isSelected;
  
  ScannedAccount({
    required this.iban,
    this.accountHolder,
    this.bankName,
    this.balance,
    this.balanceDate,
    this.accountType,
    this.confidence = 0.8,
    this.matchedPersonId,
    this.matchedPersonName,
    this.matchConfidence = 0.0,
    this.isSelected = true,
  });
  
  /// Maak een kopie met aangepaste waarden
  ScannedAccount copyWith({
    String? iban,
    String? accountHolder,
    String? bankName,
    double? balance,
    String? balanceDate,
    String? accountType,
    double? confidence,
    String? matchedPersonId,
    String? matchedPersonName,
    double? matchConfidence,
    bool? isSelected,
  }) {
    return ScannedAccount(
      iban: iban ?? this.iban,
      accountHolder: accountHolder ?? this.accountHolder,
      bankName: bankName ?? this.bankName,
      balance: balance ?? this.balance,
      balanceDate: balanceDate ?? this.balanceDate,
      accountType: accountType ?? this.accountType,
      confidence: confidence ?? this.confidence,
      matchedPersonId: matchedPersonId ?? this.matchedPersonId,
      matchedPersonName: matchedPersonName ?? this.matchedPersonName,
      matchConfidence: matchConfidence ?? this.matchConfidence,
      isSelected: isSelected ?? this.isSelected,
    );
  }
  
  /// Korte weergave van IBAN (NL91 **** **** 1234)
  String get maskedIban {
    if (iban.length < 18) return iban;
    return '${iban.substring(0, 4)} **** **** ${iban.substring(14)}';
  }
  
  /// Detecteer rekeningtype op basis van IBAN of context
  String get detectedType {
    if (accountType != null) return accountType!;
    // ING spaarrekeningen beginnen vaak met bepaalde nummers
    // ABN AMRO heeft andere patronen, etc.
    return 'Betaalrekening'; // Default
  }
  
  @override
  String toString() {
    return 'ScannedAccount(iban: $maskedIban, holder: $accountHolder, bank: $bankName, balance: €$balance)';
  }
}

/// Resultaat van een multi-account scan
class MultiAccountScanResult {
  final List<ScannedAccount> accounts;
  final String? documentName;
  final String? documentDate;
  final String rawText;
  final DateTime scannedAt;
  
  // Statistieken
  final int totalIbansFound;
  final int uniqueAccountsFound;
  
  MultiAccountScanResult({
    required this.accounts,
    this.documentName,
    this.documentDate,
    required this.rawText,
    DateTime? scannedAt,
  }) : scannedAt = scannedAt ?? DateTime.now(),
       totalIbansFound = accounts.length,
       uniqueAccountsFound = accounts.map((a) => a.iban).toSet().length;
  
  /// Zijn er rekeningen gevonden?
  bool get hasAccounts => accounts.isNotEmpty;
  
  /// Hoeveel rekeningen zijn geselecteerd voor import?
  int get selectedCount => accounts.where((a) => a.isSelected).length;
  
  /// Totaal saldo van alle geselecteerde rekeningen
  double get totalSelectedBalance {
    return accounts
        .where((a) => a.isSelected && a.balance != null)
        .fold(0.0, (sum, a) => sum + a.balance!);
  }
  
  /// Groepeer rekeningen per bank
  Map<String, List<ScannedAccount>> get accountsByBank {
    final map = <String, List<ScannedAccount>>{};
    for (final account in accounts) {
      final bank = account.bankName ?? 'Onbekend';
      map.putIfAbsent(bank, () => []).add(account);
    }
    return map;
  }
}


