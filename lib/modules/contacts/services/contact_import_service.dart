// lib/modules/contacts/services/contact_import_service.dart

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../person/person_model.dart';

/// Service voor het importeren van contacten
class ContactImportService {
  static const _uuid = Uuid();

  /// Laat gebruiker een CSV of vCard bestand kiezen
  static Future<ImportFileResult?> pickImportFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt', 'vcf'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;
    
    final path = result.files.first.path;
    if (path == null) return null;
    
    final extension = path.toLowerCase().split('.').last;
    return ImportFileResult(
      path: path,
      type: extension == 'vcf' ? ImportFileType.vcard : ImportFileType.csv,
    );
  }

  /// Laat gebruiker een CSV bestand kiezen (voor backwards compatibility)
  static Future<String?> pickCsvFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return null;
    return result.files.first.path;
  }
  
  // ========== VCARD IMPORT ==========
  
  /// Parse vCard bestand
  static Future<List<VCardContact>> parseVCardFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      return parseVCardContent(content);
    } catch (e) {
      return [];
    }
  }
  
  /// Parse vCard content (kan meerdere contacten bevatten)
  static List<VCardContact> parseVCardContent(String content) {
    final contacts = <VCardContact>[];
    
    // Split op BEGIN:VCARD
    final vcards = content.split(RegExp(r'BEGIN:VCARD', caseSensitive: false));
    
    for (final vcard in vcards) {
      if (vcard.trim().isEmpty) continue;
      
      final contact = _parseVCard('BEGIN:VCARD$vcard');
      if (contact != null) {
        contacts.add(contact);
      }
    }
    
    return contacts;
  }
  
  /// Parse een enkele vCard
  static VCardContact? _parseVCard(String content) {
    final lines = content.split(RegExp(r'\r?\n'));
    
    String? firstName;
    String? lastName;
    String? email;
    String? phone;
    String? address;
    String? postalCode;
    String? city;
    String? organization;
    
    for (final rawLine in lines) {
      // Handle line folding (lines starting with space/tab are continuations)
      final line = rawLine.trim();
      if (line.isEmpty) continue;
      
      // Parse N (Name) field: N:LastName;FirstName;MiddleName;Prefix;Suffix
      if (line.toUpperCase().startsWith('N:') || line.toUpperCase().startsWith('N;')) {
        final value = _extractVCardValue(line);
        final parts = value.split(';');
        if (parts.isNotEmpty) lastName = parts[0].trim();
        if (parts.length > 1) firstName = parts[1].trim();
      }
      // Parse FN (Formatted Name) as fallback
      else if (line.toUpperCase().startsWith('FN:') || line.toUpperCase().startsWith('FN;')) {
        if (firstName == null && lastName == null) {
          final value = _extractVCardValue(line);
          final parts = value.split(' ');
          if (parts.isNotEmpty) firstName = parts[0];
          if (parts.length > 1) lastName = parts.sublist(1).join(' ');
        }
      }
      // Parse EMAIL
      else if (line.toUpperCase().startsWith('EMAIL')) {
        email ??= _extractVCardValue(line);
      }
      // Parse TEL (telephone)
      else if (line.toUpperCase().startsWith('TEL')) {
        phone ??= _extractVCardValue(line);
      }
      // Parse ADR (address): ADR:;;Street;City;Region;PostalCode;Country
      else if (line.toUpperCase().startsWith('ADR')) {
        final value = _extractVCardValue(line);
        final parts = value.split(';');
        if (parts.length > 2 && parts[2].isNotEmpty) address = parts[2].trim();
        if (parts.length > 3 && parts[3].isNotEmpty) city = parts[3].trim();
        if (parts.length > 5 && parts[5].isNotEmpty) postalCode = parts[5].trim();
      }
      // Parse ORG (organization)
      else if (line.toUpperCase().startsWith('ORG')) {
        organization = _extractVCardValue(line).split(';').first;
      }
    }
    
    // Skip if no name
    if ((firstName == null || firstName.isEmpty) && (lastName == null || lastName.isEmpty)) {
      return null;
    }
    
    return VCardContact(
      firstName: firstName ?? '',
      lastName: lastName ?? '',
      email: email,
      phone: phone,
      address: address,
      postalCode: postalCode,
      city: city,
      organization: organization,
    );
  }
  
  /// Extract value from vCard line (handles parameters like TYPE=WORK)
  static String _extractVCardValue(String line) {
    final colonIndex = line.indexOf(':');
    if (colonIndex < 0) return '';
    return line.substring(colonIndex + 1).trim();
  }
  
  /// Convert vCard contacts to PersonModels
  static List<PersonModel> vCardsToContacts(
    List<VCardContact> vcards,
    String dossierId,
  ) {
    return vcards.map((vc) => PersonModel(
      id: _uuid.v4(),
      dossierId: dossierId,
      firstName: vc.firstName.isNotEmpty ? vc.firstName : 'Onbekend',
      lastName: vc.lastName.isNotEmpty ? vc.lastName : 'Onbekend',
      email: vc.email,
      phone: vc.phone,
      address: vc.address,
      postalCode: vc.postalCode,
      city: vc.city,
      notes: vc.organization,
      isContact: true,
    )).toList();
  }

  /// Parse CSV bestand naar ruwe data
  static Future<CsvParseResult> parseCsvFile(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      
      return parseCsvContent(content);
    } catch (e) {
      return CsvParseResult(
        success: false,
        errorMessage: 'Kon bestand niet lezen: $e',
        headers: [],
        rows: [],
      );
    }
  }

  /// Parse CSV content string
  static CsvParseResult parseCsvContent(String content) {
    try {
      final lines = content.split('\n').where((line) => line.trim().isNotEmpty).toList();
      
      if (lines.isEmpty) {
        return CsvParseResult(
          success: false,
          errorMessage: 'Bestand is leeg',
          headers: [],
          rows: [],
        );
      }

      // Detecteer scheidingsteken
      final separator = _detectSeparator(lines.first);
      
      // Parse headers
      final headers = _parseCsvLine(lines.first, separator);
      
      // Parse data rows
      final rows = <List<String>>[];
      for (int i = 1; i < lines.length; i++) {
        final row = _parseCsvLine(lines[i], separator);
        if (row.isNotEmpty) {
          // Vul aan met lege waarden als row korter is dan headers
          while (row.length < headers.length) {
            row.add('');
          }
          rows.add(row);
        }
      }

      return CsvParseResult(
        success: true,
        headers: headers,
        rows: rows,
        separator: separator,
      );
    } catch (e) {
      return CsvParseResult(
        success: false,
        errorMessage: 'Fout bij parsen: $e',
        headers: [],
        rows: [],
      );
    }
  }

  /// Detecteer het scheidingsteken (comma, semicolon, tab)
  static String _detectSeparator(String line) {
    final commaCount = ','.allMatches(line).length;
    final semicolonCount = ';'.allMatches(line).length;
    final tabCount = '\t'.allMatches(line).length;

    if (semicolonCount > commaCount && semicolonCount > tabCount) {
      return ';';
    } else if (tabCount > commaCount) {
      return '\t';
    }
    return ',';
  }

  /// Parse een CSV regel (met quote handling)
  static List<String> _parseCsvLine(String line, String separator) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];

      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          // Escaped quote
          current.write('"');
          i++;
        } else {
          // Toggle quote mode
          inQuotes = !inQuotes;
        }
      } else if (char == separator && !inQuotes) {
        result.add(current.toString().trim());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }

    result.add(current.toString().trim());
    return result;
  }

  /// Converteer CSV data naar PersonModels met mapping
  static List<PersonModel> convertToContacts({
    required String dossierId,
    required List<String> headers,
    required List<List<String>> rows,
    required Map<String, int> columnMapping,
  }) {
    final contacts = <PersonModel>[];

    for (final row in rows) {
      final firstName = _getValueByMapping(row, columnMapping, 'firstName') ?? '';
      final lastName = _getValueByMapping(row, columnMapping, 'lastName') ?? '';
      
      // Skip als naam ontbreekt
      if (firstName.isEmpty && lastName.isEmpty) continue;

      contacts.add(PersonModel(
        id: _uuid.v4(),
        dossierId: dossierId,
        firstName: firstName.isNotEmpty ? firstName : 'Onbekend',
        namePrefix: _getValueByMapping(row, columnMapping, 'namePrefix'),
        lastName: lastName.isNotEmpty ? lastName : 'Onbekend',
        email: _getValueByMapping(row, columnMapping, 'email'),
        phone: _getValueByMapping(row, columnMapping, 'phone'),
        address: _getValueByMapping(row, columnMapping, 'address'),
        postalCode: _getValueByMapping(row, columnMapping, 'postalCode'),
        city: _getValueByMapping(row, columnMapping, 'city'),
        notes: _getValueByMapping(row, columnMapping, 'notes'),
        isContact: true,
        categories: _parseCategories(_getValueByMapping(row, columnMapping, 'category')),
      ));
    }

    return contacts;
  }

  static String? _getValueByMapping(List<String> row, Map<String, int> mapping, String field) {
    final index = mapping[field];
    if (index == null || index < 0 || index >= row.length) return null;
    final value = row[index].trim();
    return value.isEmpty ? null : value;
  }

  static Set<ContactCategory> _parseCategories(String? value) {
    if (value == null || value.isEmpty) return {};
    final lower = value.toLowerCase();
    final categories = <ContactCategory>{};
    
    if (lower.contains('famil')) categories.add(ContactCategory.family);
    if (lower.contains('vriend') || lower.contains('friend')) categories.add(ContactCategory.friend);
    if (lower.contains('profess') || lower.contains('werk') || lower.contains('work') || lower.contains('colleg')) {
      categories.add(ContactCategory.colleague);
    }
    if (lower.contains('buur') || lower.contains('neighbor')) categories.add(ContactCategory.neighbor);
    if (lower.contains('kennis') || lower.contains('acquaint')) categories.add(ContactCategory.acquaintance);
    if (lower.contains('club') || lower.contains('vereni')) categories.add(ContactCategory.club);
    if (lower.contains('school') || lower.contains('kind')) categories.add(ContactCategory.school);
    if (lower.contains('zorg') || lower.contains('medic') || lower.contains('arts')) categories.add(ContactCategory.medical);
    
    // Als geen specifieke categorie gevonden, gebruik 'other'
    if (categories.isEmpty && value.isNotEmpty) {
      categories.add(ContactCategory.other);
    }
    
    return categories;
  }

  /// Probeer automatisch kolommen te mappen
  static Map<String, int> autoMapColumns(List<String> headers) {
    final mapping = <String, int>{};
    
    for (int i = 0; i < headers.length; i++) {
      final header = headers[i].toLowerCase().trim();
      
      // Voornaam
      if (_matchesAny(header, ['voornaam', 'first name', 'firstname', 'first', 'given name'])) {
        mapping['firstName'] = i;
      }
      // Tussenvoegsel
      else if (_matchesAny(header, ['tussenvoegsel', 'prefix', 'middle', 'tussen'])) {
        mapping['namePrefix'] = i;
      }
      // Achternaam
      else if (_matchesAny(header, ['achternaam', 'last name', 'lastname', 'last', 'surname', 'family name'])) {
        mapping['lastName'] = i;
      }
      // Email
      else if (_matchesAny(header, ['email', 'e-mail', 'mail', 'emailadres'])) {
        mapping['email'] = i;
      }
      // Telefoon
      else if (_matchesAny(header, ['telefoon', 'phone', 'tel', 'telefoonnummer', 'mobile', 'mobiel'])) {
        mapping['phone'] = i;
      }
      // Adres
      else if (_matchesAny(header, ['adres', 'address', 'straat', 'street', 'straatnaam'])) {
        mapping['address'] = i;
      }
      // Postcode
      else if (_matchesAny(header, ['postcode', 'postal code', 'zip', 'zipcode', 'zip code'])) {
        mapping['postalCode'] = i;
      }
      // Plaats
      else if (_matchesAny(header, ['plaats', 'city', 'woonplaats', 'stad', 'town'])) {
        mapping['city'] = i;
      }
      // Notities
      else if (_matchesAny(header, ['notities', 'notes', 'opmerkingen', 'remarks'])) {
        mapping['notes'] = i;
      }
      // Categorie
      else if (_matchesAny(header, ['categorie', 'category', 'type', 'groep', 'group'])) {
        mapping['category'] = i;
      }
    }
    
    return mapping;
  }

  static bool _matchesAny(String value, List<String> patterns) {
    for (final pattern in patterns) {
      if (value == pattern || value.contains(pattern)) {
        return true;
      }
    }
    return false;
  }

  /// Exporteer bestaande contacten naar CSV (voor backup/template)
  static String exportContactsToCsv(List<PersonModel> contacts) {
    final buffer = StringBuffer();
    
    // Headers
    buffer.writeln('Voornaam,Tussenvoegsel,Achternaam,Email,Telefoon,Adres,Postcode,Plaats,Categorieën,Notities');
    
    // Data
    for (final contact in contacts) {
      buffer.writeln([
        _escapeCsv(contact.firstName),
        _escapeCsv(contact.namePrefix ?? ''),
        _escapeCsv(contact.lastName),
        _escapeCsv(contact.email ?? ''),
        _escapeCsv(contact.phone ?? ''),
        _escapeCsv(contact.address ?? ''),
        _escapeCsv(contact.postalCode ?? ''),
        _escapeCsv(contact.city ?? ''),
        _escapeCsv(contact.categoriesDisplay),
        _escapeCsv(contact.notes ?? ''),
      ].join(','));
    }
    
    return buffer.toString();
  }

  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}

/// Resultaat van CSV parsing
class CsvParseResult {
  final bool success;
  final String? errorMessage;
  final List<String> headers;
  final List<List<String>> rows;
  final String? separator;

  const CsvParseResult({
    required this.success,
    this.errorMessage,
    required this.headers,
    required this.rows,
    this.separator,
  });

  int get rowCount => rows.length;
  int get columnCount => headers.length;
}

/// Veld mapping opties
class ImportFieldOption {
  final String id;
  final String label;
  final bool required;

  const ImportFieldOption({
    required this.id,
    required this.label,
    this.required = false,
  });

  static const List<ImportFieldOption> allOptions = [
    ImportFieldOption(id: 'firstName', label: 'Voornaam', required: true),
    ImportFieldOption(id: 'namePrefix', label: 'Tussenvoegsel'),
    ImportFieldOption(id: 'lastName', label: 'Achternaam', required: true),
    ImportFieldOption(id: 'email', label: 'Email'),
    ImportFieldOption(id: 'phone', label: 'Telefoon'),
    ImportFieldOption(id: 'address', label: 'Adres'),
    ImportFieldOption(id: 'postalCode', label: 'Postcode'),
    ImportFieldOption(id: 'city', label: 'Plaats'),
    ImportFieldOption(id: 'category', label: 'Categorie'),
    ImportFieldOption(id: 'notes', label: 'Notities'),
  ];
}

/// Bestandstype voor import
enum ImportFileType { csv, vcard }

/// Resultaat van bestand kiezen
class ImportFileResult {
  final String path;
  final ImportFileType type;
  
  const ImportFileResult({required this.path, required this.type});
}

/// vCard contact data
class VCardContact {
  final String firstName;
  final String lastName;
  final String? email;
  final String? phone;
  final String? address;
  final String? postalCode;
  final String? city;
  final String? organization;
  
  const VCardContact({
    required this.firstName,
    required this.lastName,
    this.email,
    this.phone,
    this.address,
    this.postalCode,
    this.city,
    this.organization,
  });
  
  String get fullName => '$firstName $lastName'.trim();
}

