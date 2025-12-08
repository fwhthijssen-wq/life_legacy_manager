// lib/core/utils/text_formatters.dart

import 'package:flutter/services.dart';

/// Formatter die de eerste letter van elk woord als hoofdletter maakt
/// Bijv: "jan de vries" wordt "Jan De Vries"
class CapitalizeWordsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    
    final words = newValue.text.split(' ');
    final capitalizedWords = words.map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).toList();
    
    final newText = capitalizedWords.join(' ');
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

/// Formatter die alleen de eerste letter van het eerste woord als hoofdletter maakt
/// Bijv: "straatnaam 123" wordt "Straatnaam 123"
class CapitalizeFirstFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    
    final newText = newValue.text[0].toUpperCase() + 
                    newValue.text.substring(1);
    
    return TextEditingValue(
      text: newText,
      selection: newValue.selection,
    );
  }
}

/// Formatter voor Nederlandse postcodes (4 cijfers + 2 letters, letters worden hoofdletters)
/// Bijv: "1234ab" wordt "1234 AB" of "1234AB" afhankelijk van input
class DutchPostalCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Verwijder alle spaties voor verwerking
    String text = newValue.text.replaceAll(' ', '');
    
    if (text.isEmpty) return newValue;
    
    // Maximum 6 karakters (4 cijfers + 2 letters)
    if (text.length > 6) {
      text = text.substring(0, 6);
    }
    
    // Split in cijfers en letters
    String digits = '';
    String letters = '';
    
    for (int i = 0; i < text.length; i++) {
      if (i < 4) {
        // Eerste 4 karakters moeten cijfers zijn
        if (RegExp(r'[0-9]').hasMatch(text[i])) {
          digits += text[i];
        }
      } else {
        // Laatste 2 karakters moeten letters zijn (maak hoofdletters)
        if (RegExp(r'[a-zA-Z]').hasMatch(text[i])) {
          letters += text[i].toUpperCase();
        }
      }
    }
    
    // Combineer met spatie tussen cijfers en letters
    String formattedText = digits;
    if (letters.isNotEmpty) {
      formattedText += ' $letters';
    }
    
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

/// Validator voor Nederlandse postcodes
/// Returns null als geldig, anders een foutmelding
String? validateDutchPostalCode(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null; // Leeg is toegestaan (niet verplicht)
  }
  
  // Verwijder spaties
  final cleaned = value.replaceAll(' ', '');
  
  // Check formaat: 4 cijfers + 2 letters
  final regex = RegExp(r'^[1-9][0-9]{3}[A-Za-z]{2}$');
  
  if (!regex.hasMatch(cleaned)) {
    return 'Gebruik formaat: 1234 AB';
  }
  
  return null;
}

/// Helper functie om een naam te kapitaliseren (eerste letter hoofdletter)
String capitalizeFirst(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

/// Helper functie om elk woord te kapitaliseren
String capitalizeWords(String text) {
  if (text.isEmpty) return text;
  return text.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

/// Helper functie om postcode te formatteren (hoofdletters)
String formatPostalCode(String text) {
  final cleaned = text.replaceAll(' ', '');
  if (cleaned.length <= 4) return cleaned;
  
  final digits = cleaned.substring(0, 4);
  final letters = cleaned.substring(4).toUpperCase();
  return '$digits $letters';
}


