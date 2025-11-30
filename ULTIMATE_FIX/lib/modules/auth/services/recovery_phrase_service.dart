import 'dart:math';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'wordlists/bip39_english.dart';
import 'wordlists/bip39_dutch.dart';

/// Language options for recovery phrase
enum RecoveryPhraseLanguage {
  english,
  dutch,
}

/// Recovery Phrase Service
/// Generates, validates and hashes recovery phrases using BIP39 standard
class RecoveryPhraseService {
  static const int phraseLength = 12;
  
  /// Generate a 12-word recovery phrase in the specified language
  /// 
  /// [language] - Language for the wordlist (English or Dutch)
  /// Returns a list of 12 random words from the BIP39 wordlist
  static List<String> generatePhrase({
    RecoveryPhraseLanguage language = RecoveryPhraseLanguage.english,
  }) {
    final random = Random.secure();
    final wordlist = _getWordlist(language);
    final phrase = <String>[];
    
    for (int i = 0; i < phraseLength; i++) {
      final index = random.nextInt(wordlist.length);
      phrase.add(wordlist[index]);
    }
    
    return phrase;
  }
  
  /// Hash a recovery phrase for secure storage
  /// 
  /// [phrase] - List of words in the recovery phrase
  /// Returns SHA-256 hash of the phrase
  static String hashPhrase(List<String> phrase) {
    // Normalize: lowercase and join with single space
    final normalized = phrase.map((w) => w.toLowerCase().trim()).join(' ');
    final bytes = utf8.encode(normalized);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Validate a recovery phrase
  /// 
  /// [phrase] - List of words to validate
  /// [language] - Expected language of the phrase
  /// Returns true if all words are valid BIP39 words in the specified language
  static bool validatePhrase(
    List<String> phrase, {
    RecoveryPhraseLanguage language = RecoveryPhraseLanguage.english,
  }) {
    // Check length
    if (phrase.length != phraseLength) {
      return false;
    }
    
    // Check each word is in the wordlist
    final wordlist = _getWordlist(language);
    for (final word in phrase) {
      if (!wordlist.contains(word.toLowerCase().trim())) {
        return false;
      }
    }
    
    return true;
  }
  
  /// Validate a single word
  /// 
  /// [word] - Word to validate
  /// [language] - Language to check against
  /// Returns true if the word exists in the BIP39 wordlist
  static bool validateWord(
    String word, {
    RecoveryPhraseLanguage language = RecoveryPhraseLanguage.english,
  }) {
    if (language == RecoveryPhraseLanguage.english) {
      return Bip39English.isValidWord(word);
    } else {
      return Bip39Dutch.isValidWord(word);
    }
  }
  
  /// Verify a recovery phrase against a stored hash
  /// 
  /// [phrase] - Recovery phrase to verify
  /// [storedHash] - Previously stored hash to compare against
  /// Returns true if the phrase matches the stored hash
  static bool verifyPhrase(List<String> phrase, String storedHash) {
    final phraseHash = hashPhrase(phrase);
    return phraseHash == storedHash;
  }
  
  /// Parse a recovery phrase from a string
  /// 
  /// [input] - String containing recovery phrase (space or comma separated)
  /// Returns list of normalized words
  static List<String> parsePhrase(String input) {
    // Remove extra whitespace and split
    final cleaned = input.trim().replaceAll(RegExp(r'\s+'), ' ');
    
    // Split by space or comma
    final words = cleaned.split(RegExp(r'[,\s]+')).where((w) => w.isNotEmpty).toList();
    
    // Normalize to lowercase
    return words.map((w) => w.toLowerCase().trim()).toList();
  }
  
  /// Get autocomplete suggestions for a partial word
  /// 
  /// [partial] - Partial word to match
  /// [language] - Language for suggestions
  /// [limit] - Maximum number of suggestions to return
  /// Returns list of matching words from the BIP39 wordlist
  static List<String> getAutocompleteSuggestions(
    String partial, {
    RecoveryPhraseLanguage language = RecoveryPhraseLanguage.english,
    int limit = 10,
  }) {
    if (partial.isEmpty) return [];
    
    final wordlist = _getWordlist(language);
    final normalizedPartial = partial.toLowerCase().trim();
    
    final matches = wordlist
        .where((word) => word.startsWith(normalizedPartial))
        .take(limit)
        .toList();
    
    return matches;
  }
  
  /// Get the wordlist for the specified language
  static List<String> _getWordlist(RecoveryPhraseLanguage language) {
    if (language == RecoveryPhraseLanguage.english) {
      return Bip39English.words;
    } else {
      return Bip39Dutch.words;
    }
  }
  
  /// Detect the language of a recovery phrase
  /// 
  /// [phrase] - Recovery phrase to analyze
  /// Returns the detected language or null if unable to determine
  static RecoveryPhraseLanguage? detectLanguage(List<String> phrase) {
    if (phrase.isEmpty) return null;
    
    int englishMatches = 0;
    int dutchMatches = 0;
    
    for (final word in phrase) {
      final normalized = word.toLowerCase().trim();
      if (Bip39English.isValidWord(normalized)) {
        englishMatches++;
      }
      if (Bip39Dutch.isValidWord(normalized)) {
        dutchMatches++;
      }
    }
    
    // If majority of words match a language, return that
    if (englishMatches > dutchMatches && englishMatches >= phrase.length / 2) {
      return RecoveryPhraseLanguage.english;
    } else if (dutchMatches > englishMatches && dutchMatches >= phrase.length / 2) {
      return RecoveryPhraseLanguage.dutch;
    }
    
    return null;
  }
  
  /// Format a recovery phrase for display
  /// 
  /// [phrase] - Recovery phrase to format
  /// [numbered] - Whether to include numbers (e.g., "1. word")
  /// Returns formatted string
  static String formatPhrase(List<String> phrase, {bool numbered = false}) {
    if (numbered) {
      return phrase
          .asMap()
          .entries
          .map((entry) => '${entry.key + 1}. ${entry.value}')
          .join('\n');
    }
    return phrase.join(' ');
  }
}
