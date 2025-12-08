// lib/core/bulk_import/services/multi_account_scanner.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/scanned_account.dart';
import '../../ocr/ocr_service.dart';
import '../../ocr/document_patterns.dart';

/// Service voor het scannen van documenten met meerdere bankrekeningen
class MultiAccountScanner {
  final OcrService _ocrService = OcrService();
  
  /// Scan een PDF en extraheer alle bankrekeningen
  Future<MultiAccountScanResult?> scanPdf(File pdfFile) async {
    final text = await _ocrService.extractTextFromPdf(pdfFile);
    if (text == null || text.isEmpty) return null;
    
    return _analyzeForAccounts(text, pdfFile.path.split('/').last);
  }
  
  /// Scan een afbeelding en extraheer alle bankrekeningen
  Future<MultiAccountScanResult?> scanImage(File imageFile) async {
    final text = await _ocrService.recognizeText(imageFile);
    if (text == null || text.isEmpty) return null;
    
    return _analyzeForAccounts(text, imageFile.path.split('/').last);
  }
  
  /// Analyseer tekst voor meerdere bankrekeningen
  MultiAccountScanResult _analyzeForAccounts(String text, String? documentName) {
    final accounts = <ScannedAccount>[];
    final foundIbans = <String>{};
    
    // Vind alle IBANs in de tekst
    final ibanMatches = DocumentPatterns.ibanPattern.allMatches(text);
    
    for (final match in ibanMatches) {
      final rawIban = match.group(0)!;
      final iban = DocumentPatterns.normalizeIban(rawIban);
      
      // Skip duplicaten
      if (foundIbans.contains(iban)) continue;
      if (!DocumentPatterns.isValidIban(iban)) continue;
      
      foundIbans.add(iban);
      
      // Zoek context rond deze IBAN (200 karakters voor en na)
      final startPos = (match.start - 200).clamp(0, text.length);
      final endPos = (match.end + 300).clamp(0, text.length);
      final context = text.substring(startPos, endPos);
      
      // Extraheer gegevens uit de context
      final account = _extractAccountFromContext(iban, context, text);
      accounts.add(account);
    }
    
    // Detecteer document datum
    String? documentDate;
    final dates = DocumentPatterns.datePattern.allMatches(text);
    if (dates.isNotEmpty) {
      documentDate = dates.first.group(0);
    }
    
    return MultiAccountScanResult(
      accounts: accounts,
      documentName: documentName,
      documentDate: documentDate,
      rawText: text,
    );
  }
  
  /// Extraheer rekeninggegevens uit de context rond een IBAN
  ScannedAccount _extractAccountFromContext(String iban, String context, String fullText) {
    // Detecteer bank op basis van IBAN BIC code
    final bankName = _detectBankFromIban(iban) ?? 
                     _detectBankFromText(context) ??
                     _detectBankFromText(fullText);
    
    // Zoek rekeninghouder naam (vaak in de buurt van IBAN)
    final accountHolder = _extractAccountHolder(context);
    
    // Zoek saldo (bedrag in de buurt van IBAN)
    final balance = _extractBalance(context);
    
    // Detecteer rekeningtype
    final accountType = _detectAccountType(context, iban);
    
    // Bereken confidence
    double confidence = 0.5;
    if (bankName != null) confidence += 0.2;
    if (accountHolder != null) confidence += 0.15;
    if (balance != null) confidence += 0.15;
    
    return ScannedAccount(
      iban: iban,
      accountHolder: accountHolder,
      bankName: bankName,
      balance: balance,
      accountType: accountType,
      confidence: confidence.clamp(0.0, 1.0),
    );
  }
  
  /// Detecteer bank op basis van IBAN BIC code
  String? _detectBankFromIban(String iban) {
    if (iban.length < 8) return null;
    
    final bic = iban.substring(4, 8).toUpperCase();
    
    // Nederlandse bank BIC codes
    const bicToBankName = {
      'ABNA': 'ABN AMRO',
      'INGB': 'ING',
      'RABO': 'Rabobank',
      'SNSB': 'SNS',
      'ASNB': 'ASN Bank',
      'TRIO': 'Triodos Bank',
      'KNAB': 'Knab',
      'BUNQ': 'bunq',
      'RBRB': 'RegioBank',
      'FVLB': 'Van Lanschot',
      'FRBK': 'Friesland Bank',
      'KNAS': 'Knab',
    };
    
    return bicToBankName[bic];
  }
  
  /// Detecteer bank op basis van tekst (logo, naam)
  String? _detectBankFromText(String text) {
    final lowerText = text.toLowerCase();
    
    for (final bank in DocumentPatterns.dutchBanks) {
      if (lowerText.contains(bank.toLowerCase())) {
        return bank;
      }
    }
    
    return null;
  }
  
  /// Extraheer rekeninghouder naam
  String? _extractAccountHolder(String context) {
    // Patronen voor rekeninghouder
    final patterns = [
      RegExp(r't\.?n\.?v\.?\s+([A-Z][a-z]+(?:\s+[A-Za-z]+){0,3})', caseSensitive: false),
      RegExp(r'(?:rekeninghouder|naam|name)\s*:?\s*([A-Z][a-z]+(?:\s+[A-Za-z]+){0,3})', caseSensitive: false),
      RegExp(r'(?:aan|voor|van)\s+([A-Z][a-z]+\s+(?:de\s+|van\s+)?[A-Z][a-z]+)', caseSensitive: false),
    ];
    
    for (final pattern in patterns) {
      final match = pattern.firstMatch(context);
      if (match != null && match.groupCount >= 1) {
        final name = match.group(1)?.trim();
        if (name != null && name.length > 2 && name.length < 50) {
          return name;
        }
      }
    }
    
    return null;
  }
  
  /// Extraheer saldo bedrag
  double? _extractBalance(String context) {
    // Zoek naar saldo patronen
    final saldoPatterns = [
      RegExp(r'(?:saldo|balance|stand)\s*:?\s*[€EUR]?\s*([-]?[\d.,]+)', caseSensitive: false),
      RegExp(r'[€EUR]\s*([-]?[\d.,]+(?:\.\d{3})*[,]\d{2})', caseSensitive: false),
      RegExp(r'([-]?[\d.,]+)\s*(?:EUR|euro)', caseSensitive: false),
    ];
    
    for (final pattern in saldoPatterns) {
      final match = pattern.firstMatch(context);
      if (match != null && match.groupCount >= 1) {
        final amount = DocumentPatterns.parseAmount(match.group(1));
        if (amount != null) {
          return amount;
        }
      }
    }
    
    return null;
  }
  
  /// Detecteer type rekening
  String? _detectAccountType(String context, String iban) {
    final lowerContext = context.toLowerCase();
    
    // Spaarrekening indicatoren
    if (lowerContext.contains('spaar') || 
        lowerContext.contains('savings') ||
        lowerContext.contains('deposito')) {
      return 'Spaarrekening';
    }
    
    // Betaalrekening indicatoren
    if (lowerContext.contains('betaal') || 
        lowerContext.contains('current') ||
        lowerContext.contains('checking') ||
        lowerContext.contains('privé')) {
      return 'Betaalrekening';
    }
    
    // Zakelijke rekening
    if (lowerContext.contains('zakelijk') || 
        lowerContext.contains('business')) {
      return 'Zakelijke rekening';
    }
    
    // Gezamenlijke rekening
    if (lowerContext.contains('en/of') || 
        lowerContext.contains('gezamenlijk') ||
        lowerContext.contains('joint')) {
      return 'Gezamenlijke rekening';
    }
    
    return null; // Onbekend
  }
  
  /// Match gevonden rekeningen met dossierleden
  Future<void> matchWithPersons(
    MultiAccountScanResult result,
    List<PersonInfo> persons,
  ) async {
    for (var i = 0; i < result.accounts.length; i++) {
      final account = result.accounts[i];
      
      if (account.accountHolder == null) continue;
      
      // Zoek beste match
      PersonInfo? bestMatch;
      double bestScore = 0.0;
      
      for (final person in persons) {
        final score = _calculateNameMatchScore(
          account.accountHolder!,
          person.fullName,
        );
        
        if (score > bestScore && score > 0.5) {
          bestScore = score;
          bestMatch = person;
        }
      }
      
      if (bestMatch != null) {
        result.accounts[i] = account.copyWith(
          matchedPersonId: bestMatch.id,
          matchedPersonName: bestMatch.fullName,
          matchConfidence: bestScore,
        );
      }
    }
  }
  
  /// Bereken naam match score (0.0 - 1.0)
  double _calculateNameMatchScore(String scannedName, String personName) {
    final scannedLower = scannedName.toLowerCase().trim();
    final personLower = personName.toLowerCase().trim();
    
    // Exacte match
    if (scannedLower == personLower) return 1.0;
    
    // Bevat volledige naam
    if (scannedLower.contains(personLower) || personLower.contains(scannedLower)) {
      return 0.9;
    }
    
    // Split in woorden
    final scannedWords = scannedLower.split(RegExp(r'\s+'));
    final personWords = personLower.split(RegExp(r'\s+'));
    
    // Tel matching woorden
    int matchingWords = 0;
    for (final word in scannedWords) {
      if (word.length < 2) continue;
      if (personWords.any((p) => p.contains(word) || word.contains(p))) {
        matchingWords++;
      }
    }
    
    if (matchingWords == 0) return 0.0;
    
    // Score gebaseerd op percentage matching woorden
    final maxWords = scannedWords.length > personWords.length 
        ? scannedWords.length 
        : personWords.length;
    
    return (matchingWords / maxWords).clamp(0.0, 1.0);
  }
}

/// Simpele persoon info voor matching
class PersonInfo {
  final String id;
  final String fullName;
  final String? firstName;
  final String? lastName;
  
  PersonInfo({
    required this.id,
    required this.fullName,
    this.firstName,
    this.lastName,
  });
}


