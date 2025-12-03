// lib/modules/contacts/services/duplicate_detection_service.dart

import '../../person/person_model.dart';

/// Service voor het detecteren van duplicaten
class DuplicateDetectionService {
  
  /// Zoek mogelijke duplicaten voor een nieuw contact
  static List<DuplicateMatch> findDuplicates(
    PersonModel newContact,
    List<PersonModel> existingContacts, {
    double threshold = 0.7, // Minimale match score (0-1)
  }) {
    final matches = <DuplicateMatch>[];
    
    for (final existing in existingContacts) {
      if (existing.id == newContact.id) continue; // Skip zelfde contact
      
      final score = _calculateMatchScore(newContact, existing);
      
      if (score >= threshold) {
        matches.add(DuplicateMatch(
          existingContact: existing,
          matchScore: score,
          matchReasons: _getMatchReasons(newContact, existing),
        ));
      }
    }
    
    // Sorteer op score (hoogste eerst)
    matches.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    
    return matches;
  }

  /// Zoek duplicaten in een lijst van te importeren contacten
  static List<ImportDuplicateResult> findImportDuplicates(
    List<PersonModel> importContacts,
    List<PersonModel> existingContacts, {
    double threshold = 0.7,
  }) {
    final results = <ImportDuplicateResult>[];
    
    for (final importContact in importContacts) {
      final duplicates = findDuplicates(
        importContact, 
        existingContacts, 
        threshold: threshold,
      );
      
      results.add(ImportDuplicateResult(
        importContact: importContact,
        possibleDuplicates: duplicates,
        hasDuplicates: duplicates.isNotEmpty,
      ));
    }
    
    return results;
  }

  /// Bereken match score tussen twee contacten (0-1)
  static double _calculateMatchScore(PersonModel a, PersonModel b) {
    double totalScore = 0;
    double maxScore = 0;
    
    // Naam vergelijking (gewicht: 3)
    maxScore += 3;
    final nameScore = _compareNames(a, b);
    totalScore += nameScore * 3;
    
    // Email vergelijking (gewicht: 4 - zeer betrouwbaar)
    if (a.email != null && b.email != null && 
        a.email!.isNotEmpty && b.email!.isNotEmpty) {
      maxScore += 4;
      if (_normalizeEmail(a.email!) == _normalizeEmail(b.email!)) {
        totalScore += 4;
      }
    }
    
    // Telefoon vergelijking (gewicht: 3)
    if (a.phone != null && b.phone != null && 
        a.phone!.isNotEmpty && b.phone!.isNotEmpty) {
      maxScore += 3;
      if (_normalizePhone(a.phone!) == _normalizePhone(b.phone!)) {
        totalScore += 3;
      }
    }
    
    // Adres vergelijking (gewicht: 2)
    if (a.address != null && b.address != null && 
        a.address!.isNotEmpty && b.address!.isNotEmpty) {
      maxScore += 2;
      if (_normalizeString(a.address!) == _normalizeString(b.address!)) {
        totalScore += 2;
      }
    }
    
    // Postcode vergelijking (gewicht: 2)
    if (a.postalCode != null && b.postalCode != null && 
        a.postalCode!.isNotEmpty && b.postalCode!.isNotEmpty) {
      maxScore += 2;
      if (_normalizePostalCode(a.postalCode!) == _normalizePostalCode(b.postalCode!)) {
        totalScore += 2;
      }
    }
    
    if (maxScore == 0) return 0;
    return totalScore / maxScore;
  }

  /// Vergelijk namen en geef score (0-1)
  static double _compareNames(PersonModel a, PersonModel b) {
    final aFirst = _normalizeString(a.firstName);
    final bFirst = _normalizeString(b.firstName);
    final aLast = _normalizeString(a.lastName);
    final bLast = _normalizeString(b.lastName);
    
    // Exacte match
    if (aFirst == bFirst && aLast == bLast) {
      return 1.0;
    }
    
    // Achternaam match + voornaam begint hetzelfde
    if (aLast == bLast && 
        aFirst.isNotEmpty && bFirst.isNotEmpty &&
        (aFirst.startsWith(bFirst) || bFirst.startsWith(aFirst))) {
      return 0.9;
    }
    
    // Alleen achternaam match
    if (aLast == bLast) {
      return 0.5;
    }
    
    // Levenshtein distance voor fuzzy matching
    final fullNameA = '$aFirst $aLast';
    final fullNameB = '$bFirst $bLast';
    final distance = _levenshteinDistance(fullNameA, fullNameB);
    final maxLen = fullNameA.length > fullNameB.length ? fullNameA.length : fullNameB.length;
    
    if (maxLen == 0) return 0;
    final similarity = 1 - (distance / maxLen);
    
    return similarity > 0.7 ? similarity : 0;
  }

  /// Krijg redenen voor de match
  static List<String> _getMatchReasons(PersonModel a, PersonModel b) {
    final reasons = <String>[];
    
    // Naam
    if (_normalizeString(a.firstName) == _normalizeString(b.firstName) &&
        _normalizeString(a.lastName) == _normalizeString(b.lastName)) {
      reasons.add('Zelfde naam');
    } else if (_normalizeString(a.lastName) == _normalizeString(b.lastName)) {
      reasons.add('Zelfde achternaam');
    }
    
    // Email
    if (a.email != null && b.email != null && 
        a.email!.isNotEmpty && b.email!.isNotEmpty &&
        _normalizeEmail(a.email!) == _normalizeEmail(b.email!)) {
      reasons.add('Zelfde email');
    }
    
    // Telefoon
    if (a.phone != null && b.phone != null && 
        a.phone!.isNotEmpty && b.phone!.isNotEmpty &&
        _normalizePhone(a.phone!) == _normalizePhone(b.phone!)) {
      reasons.add('Zelfde telefoon');
    }
    
    // Adres
    if (a.address != null && b.address != null && 
        a.address!.isNotEmpty && b.address!.isNotEmpty &&
        _normalizeString(a.address!) == _normalizeString(b.address!)) {
      reasons.add('Zelfde adres');
    }
    
    return reasons;
  }

  /// Normaliseer string (lowercase, trim, remove extra spaces)
  static String _normalizeString(String s) {
    return s.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Normaliseer email
  static String _normalizeEmail(String email) {
    return email.toLowerCase().trim();
  }

  /// Normaliseer telefoonnummer (alleen cijfers)
  static String _normalizePhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }

  /// Normaliseer postcode
  static String _normalizePostalCode(String postalCode) {
    return postalCode.replaceAll(RegExp(r'\s'), '').toUpperCase();
  }

  /// Levenshtein distance voor fuzzy string matching
  static int _levenshteinDistance(String s1, String s2) {
    if (s1.isEmpty) return s2.length;
    if (s2.isEmpty) return s1.length;

    List<int> previousRow = List.generate(s2.length + 1, (i) => i);
    List<int> currentRow = List.filled(s2.length + 1, 0);

    for (int i = 0; i < s1.length; i++) {
      currentRow[0] = i + 1;

      for (int j = 0; j < s2.length; j++) {
        int insertCost = previousRow[j + 1] + 1;
        int deleteCost = currentRow[j] + 1;
        int replaceCost = previousRow[j] + (s1[i] == s2[j] ? 0 : 1);

        currentRow[j + 1] = [insertCost, deleteCost, replaceCost].reduce((a, b) => a < b ? a : b);
      }

      final temp = previousRow;
      previousRow = currentRow;
      currentRow = temp;
    }

    return previousRow[s2.length];
  }
}

/// Resultaat van een duplicaat match
class DuplicateMatch {
  final PersonModel existingContact;
  final double matchScore;
  final List<String> matchReasons;

  const DuplicateMatch({
    required this.existingContact,
    required this.matchScore,
    required this.matchReasons,
  });

  /// Score als percentage
  int get matchPercentage => (matchScore * 100).round();

  /// Is dit een sterke match (>85%)?
  bool get isStrongMatch => matchScore >= 0.85;

  /// Match score kleur
  String get matchLevel {
    if (matchScore >= 0.9) return 'Zeer waarschijnlijk duplicaat';
    if (matchScore >= 0.8) return 'Waarschijnlijk duplicaat';
    if (matchScore >= 0.7) return 'Mogelijk duplicaat';
    return 'Onzeker';
  }
}

/// Resultaat voor import duplicaat check
class ImportDuplicateResult {
  final PersonModel importContact;
  final List<DuplicateMatch> possibleDuplicates;
  final bool hasDuplicates;

  const ImportDuplicateResult({
    required this.importContact,
    required this.possibleDuplicates,
    required this.hasDuplicates,
  });

  /// Beste match (hoogste score)
  DuplicateMatch? get bestMatch => 
      possibleDuplicates.isNotEmpty ? possibleDuplicates.first : null;
}



