// lib/modules/contacts/services/contact_export_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../person/person_model.dart';

/// Export formaat opties
enum ExportFormat {
  txt('Tekst (.txt)', 'txt', Icons.text_snippet),
  pdf('PDF (.pdf)', 'pdf', Icons.picture_as_pdf),
  rtf('Rich Text (.rtf)', 'rtf', Icons.description);

  final String label;
  final String extension;
  final IconData icon;
  const ExportFormat(this.label, this.extension, this.icon);
}

/// Service voor het exporteren van contacten
class ContactExportService {
  
  // ===== EMAIL FUNCTIES =====
  
  /// Stuur email naar één contact
  static Future<bool> sendEmailToContact(PersonModel contact, {String? subject, String? body}) async {
    if (contact.email == null || contact.email!.isEmpty) {
      return false;
    }
    
    final uri = Uri(
      scheme: 'mailto',
      path: contact.email,
      queryParameters: {
        if (subject != null) 'subject': subject,
        if (body != null) 'body': body,
      },
    );
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }
    return false;
  }

  /// Stuur bulk email naar meerdere contacten
  static Future<bool> sendBulkEmail(
    List<PersonModel> contacts, {
    String? subject,
    String? body,
    bool useBcc = true, // BCC voor privacy
  }) async {
    final emails = contacts
        .where((c) => c.email != null && c.email!.isNotEmpty)
        .map((c) => c.email!)
        .toList();
    
    if (emails.isEmpty) return false;
    
    // Handmatig mailto URL bouwen om + encoding te voorkomen
    final buffer = StringBuffer('mailto:');
    
    if (!useBcc) {
      buffer.write(emails.join(','));
    }
    
    final params = <String>[];
    if (useBcc) {
      params.add('bcc=${Uri.encodeComponent(emails.join(','))}');
    }
    if (subject != null && subject.isNotEmpty) {
      params.add('subject=${Uri.encodeComponent(subject)}');
    }
    if (body != null && body.isNotEmpty) {
      params.add('body=${Uri.encodeComponent(body)}');
    }
    
    if (params.isNotEmpty) {
      buffer.write('?');
      buffer.write(params.join('&'));
    }
    
    final uri = Uri.parse(buffer.toString());
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }
    return false;
  }

  // ===== CSV EXPORT =====

  /// Genereer CSV string van contacten
  static String generateCsv(List<PersonModel> contacts) {
    final buffer = StringBuffer();
    
    // Header - updated to new structure
    buffer.writeln('Voornaam,Tussenvoegsel,Achternaam,Email,Telefoon,Straat,Postcode,Plaats,Categorieën,Notities');
    
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

  /// Escape CSV waarden (quotes en komma's)
  static String _escapeCsv(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// Exporteer naar CSV en deel
  static Future<void> exportToCsv(
    BuildContext context,
    List<PersonModel> contacts, {
    String filename = 'contacten',
  }) async {
    try {
      final csv = generateCsv(contacts);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename.csv');
      await file.writeAsString(csv);
      
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Contacten Export',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export mislukt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ===== ADRESLIJST TEKST =====

  /// Genereer eenvoudige adreslijst als tekst
  static String generateAddressList(List<PersonModel> contacts) {
    final buffer = StringBuffer();
    buffer.writeln('ADRESLIJST');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    for (final contact in contacts) {
      buffer.writeln(contact.fullName);
      if (contact.address != null && contact.address!.isNotEmpty) {
        buffer.writeln(contact.address);
      }
      if (contact.postalCode != null || contact.city != null) {
        buffer.writeln('${contact.postalCode ?? ''} ${contact.city ?? ''}'.trim());
      }
      if (contact.email != null && contact.email!.isNotEmpty) {
        buffer.writeln('Email: ${contact.email}');
      }
      if (contact.phone != null && contact.phone!.isNotEmpty) {
        buffer.writeln('Tel: ${contact.phone}');
      }
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  // ===== CATEGORIE FILTERS =====

  /// Filter contacten op categorieën
  static List<PersonModel> filterByCategories(
    List<PersonModel> contacts,
    Set<ContactCategory> categories,
  ) {
    if (categories.isEmpty) return contacts;
    return contacts.where((c) => c.hasAnyCategory(categories)).toList();
  }

  /// Tel contacten per categorie
  static Map<ContactCategory, int> countByCategory(List<PersonModel> contacts) {
    return {
      for (final cat in ContactCategory.values)
        cat: contacts.where((c) => c.hasCategory(cat)).length,
    };
  }

  // ===== BRIEF/POST FUNCTIES =====

  /// Filter contacten die een volledig adres hebben
  static List<PersonModel> filterWithAddress(List<PersonModel> contacts) {
    return contacts.where((c) => 
      c.address != null && c.address!.isNotEmpty &&
      c.city != null && c.city!.isNotEmpty
    ).toList();
  }

  /// Genereer één brief voor een contact (tekst formaat)
  static String generateLetter(
    PersonModel contact, {
    required String body,
    String? senderName,
    String? senderAddress,
  }) {
    final buffer = StringBuffer();
    
    // Afzender (rechtsboven)
    if (senderName != null || senderAddress != null) {
      if (senderName != null) buffer.writeln(senderName);
      if (senderAddress != null) {
        // Adres kan meerdere regels bevatten (straat + postcode/plaats)
        for (final line in senderAddress.split('\n')) {
          if (line.trim().isNotEmpty) buffer.writeln(line.trim());
        }
      }
      buffer.writeln();
    }
    
    // Datum
    final now = DateTime.now();
    final months = ['januari', 'februari', 'maart', 'april', 'mei', 'juni',
                    'juli', 'augustus', 'september', 'oktober', 'november', 'december'];
    buffer.writeln('${now.day} ${months[now.month - 1]} ${now.year}');
    buffer.writeln();
    
    // Geadresseerde
    buffer.writeln(contact.fullName);
    if (contact.address != null && contact.address!.isNotEmpty) {
      buffer.writeln(contact.address);
    }
    if (contact.postalCode != null || contact.city != null) {
      buffer.writeln('${contact.postalCode ?? ''} ${contact.city ?? ''}'.trim());
    }
    buffer.writeln();
    buffer.writeln();
    
    // Inhoud (met placeholder vervanging)
    final personalizedBody = body
        .replaceAll('{naam}', contact.fullName)
        .replaceAll('{voornaam}', contact.firstName)
        .replaceAll('{achternaam}', contact.lastName);
    buffer.writeln(personalizedBody);
    
    return buffer.toString();
  }

  /// Genereer meerdere brieven (gescheiden door pagina-einden) - tekst formaat
  static String generateLetters(
    List<PersonModel> contacts, {
    required String body,
    String? senderName,
    String? senderAddress,
  }) {
    final buffer = StringBuffer();
    
    for (int i = 0; i < contacts.length; i++) {
      buffer.write(generateLetter(
        contacts[i],
        body: body,
        senderName: senderName,
        senderAddress: senderAddress,
      ));
      
      if (i < contacts.length - 1) {
        buffer.writeln();
        buffer.writeln('─' * 60);
        buffer.writeln('--- VOLGENDE PAGINA ---');
        buffer.writeln('─' * 60);
        buffer.writeln();
      }
    }
    
    return buffer.toString();
  }

  // ===== PDF GENERATIE =====

  /// Genereer PDF voor brieven
  static Future<Uint8List> generateLettersPdf(
    List<PersonModel> contacts, {
    required String body,
    String? senderName,
    String? senderAddress,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final months = ['januari', 'februari', 'maart', 'april', 'mei', 'juni',
                    'juli', 'augustus', 'september', 'oktober', 'november', 'december'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';

    for (final contact in contacts) {
      final personalizedBody = body
          .replaceAll('{naam}', contact.fullName)
          .replaceAll('{voornaam}', contact.firstName)
          .replaceAll('{achternaam}', contact.lastName);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(50),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Afzender rechtsboven
              if (senderName != null || senderAddress != null)
                pw.Align(
                  alignment: pw.Alignment.topRight,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      if (senderName != null) pw.Text(senderName),
                      if (senderAddress != null)
                        // Adres kan meerdere regels bevatten
                        ...senderAddress.split('\n')
                            .where((line) => line.trim().isNotEmpty)
                            .map((line) => pw.Text(line.trim())),
                    ],
                  ),
                ),
              pw.SizedBox(height: 30),
              
              // Datum
              pw.Text(dateStr),
              pw.SizedBox(height: 20),
              
              // Geadresseerde
              pw.Text(contact.fullName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              if (contact.address != null && contact.address!.isNotEmpty)
                pw.Text(contact.address!),
              if (contact.postalCode != null || contact.city != null)
                pw.Text('${contact.postalCode ?? ''} ${contact.city ?? ''}'.trim()),
              pw.SizedBox(height: 40),
              
              // Inhoud
              pw.Text(personalizedBody),
            ],
          ),
        ),
      );
    }

    return pdf.save();
  }

  /// Genereer PDF voor adresetiketten
  static Future<Uint8List> generateAddressLabelsPdf(List<PersonModel> contacts) async {
    final pdf = pw.Document();
    final labelsPerPage = 10; // 2 kolommen x 5 rijen
    
    for (int i = 0; i < contacts.length; i += labelsPerPage) {
      final pageContacts = contacts.skip(i).take(labelsPerPage).toList();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (context) => pw.GridView(
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: pageContacts.map((contact) => pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(contact.fullName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                  if (contact.address != null && contact.address!.isNotEmpty)
                    pw.Text(contact.address!, style: const pw.TextStyle(fontSize: 10)),
                  if (contact.postalCode != null || contact.city != null)
                    pw.Text('${contact.postalCode ?? ''} ${contact.city ?? ''}'.trim(), 
                      style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            )).toList(),
          ),
        ),
      );
    }

    return pdf.save();
  }

  /// Genereer PDF voor adreslijst
  static Future<Uint8List> generateAddressListPdf(List<PersonModel> contacts) async {
    final pdf = pw.Document();
    final contactsPerPage = 15;
    
    for (int i = 0; i < contacts.length; i += contactsPerPage) {
      final pageContacts = contacts.skip(i).take(contactsPerPage).toList();
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (i == 0) ...[
                pw.Text('ADRESLIJST', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 5),
                pw.Text('${contacts.length} contacten', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
                pw.Divider(),
                pw.SizedBox(height: 10),
              ],
              ...pageContacts.map((contact) => pw.Container(
                margin: const pw.EdgeInsets.only(bottom: 15),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(contact.fullName, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    if (contact.address != null && contact.address!.isNotEmpty)
                      pw.Text(contact.address!, style: const pw.TextStyle(fontSize: 10)),
                    pw.Row(
                      children: [
                        if (contact.postalCode != null || contact.city != null)
                          pw.Expanded(
                            child: pw.Text('${contact.postalCode ?? ''} ${contact.city ?? ''}'.trim(),
                              style: const pw.TextStyle(fontSize: 10)),
                          ),
                        if (contact.phone != null && contact.phone!.isNotEmpty)
                          pw.Text('Tel: ${contact.phone}', style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                    if (contact.email != null && contact.email!.isNotEmpty)
                      pw.Text('Email: ${contact.email}', style: const pw.TextStyle(fontSize: 9, color: PdfColors.blue)),
                  ],
                ),
              )),
            ],
          ),
        ),
      );
    }

    return pdf.save();
  }

  // ===== RTF GENERATIE =====

  /// Genereer RTF voor brieven (Word-compatibel)
  static String generateLettersRtf(
    List<PersonModel> contacts, {
    required String body,
    String? senderName,
    String? senderAddress,
  }) {
    final buffer = StringBuffer();
    buffer.write(r'{\rtf1\ansi\deff0');
    buffer.write(r'{\fonttbl{\f0 Arial;}}');
    buffer.write(r'\f0\fs22');
    
    final now = DateTime.now();
    final months = ['januari', 'februari', 'maart', 'april', 'mei', 'juni',
                    'juli', 'augustus', 'september', 'oktober', 'november', 'december'];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}';

    for (int i = 0; i < contacts.length; i++) {
      final contact = contacts[i];
      final personalizedBody = body
          .replaceAll('{naam}', contact.fullName)
          .replaceAll('{voornaam}', contact.firstName)
          .replaceAll('{achternaam}', contact.lastName);

      // Afzender rechtsboven
      if (senderName != null || senderAddress != null) {
        buffer.write(r'\qr ');
        if (senderName != null) buffer.write('$senderName\\line ');
        if (senderAddress != null) {
          // Adres kan meerdere regels bevatten
          for (final line in senderAddress.split('\n')) {
            if (line.trim().isNotEmpty) buffer.write('${line.trim()}\\line ');
          }
        }
        buffer.write(r'\ql\par\par ');
      }
      
      // Datum
      buffer.write('$dateStr\\par\\par ');
      
      // Geadresseerde
      buffer.write('{\\b ${contact.fullName}}\\line ');
      if (contact.address != null && contact.address!.isNotEmpty) {
        buffer.write('${contact.address}\\line ');
      }
      if (contact.postalCode != null || contact.city != null) {
        buffer.write('${contact.postalCode ?? ''} ${contact.city ?? ''}'.trim());
        buffer.write('\\par\\par\\par ');
      }
      
      // Inhoud
      buffer.write(_escapeRtf(personalizedBody));
      
      // Pagina-einde (behalve laatste)
      if (i < contacts.length - 1) {
        buffer.write(r'\page ');
      }
    }
    
    buffer.write('}');
    return buffer.toString();
  }

  /// Genereer RTF voor adresetiketten
  static String generateAddressLabelsRtf(List<PersonModel> contacts) {
    final buffer = StringBuffer();
    buffer.write(r'{\rtf1\ansi\deff0');
    buffer.write(r'{\fonttbl{\f0 Arial;}}');
    buffer.write(r'\f0\fs20');
    
    buffer.write('{\\b ADRESETIKETTEN}\\par');
    buffer.write('${contacts.length} etiketten\\par\\par');
    
    for (int i = 0; i < contacts.length; i++) {
      final contact = contacts[i];
      
      buffer.write('\\pard\\box\\brdrs\\brdrw10\\brsp80 ');
      buffer.write('{\\b ${contact.fullName}}\\line ');
      if (contact.address != null && contact.address!.isNotEmpty) {
        buffer.write('${contact.address}\\line ');
      }
      if (contact.postalCode != null || contact.city != null) {
        buffer.write('${contact.postalCode ?? ''} ${contact.city ?? ''}'.trim());
      }
      buffer.write('\\par\\par ');
    }
    
    buffer.write('}');
    return buffer.toString();
  }

  /// Genereer RTF voor adreslijst
  static String generateAddressListRtf(List<PersonModel> contacts) {
    final buffer = StringBuffer();
    buffer.write(r'{\rtf1\ansi\deff0');
    buffer.write(r'{\fonttbl{\f0 Arial;}}');
    buffer.write(r'\f0\fs22');
    
    buffer.write('{\\fs32\\b ADRESLIJST}\\par');
    buffer.write('${contacts.length} contacten\\par');
    buffer.write('\\pard\\brdrb\\brdrs\\brdrw10\\brsp20\\par\\par ');
    
    for (final contact in contacts) {
      buffer.write('{\\b ${contact.fullName}}\\line ');
      if (contact.address != null && contact.address!.isNotEmpty) {
        buffer.write('${contact.address}\\line ');
      }
      if (contact.postalCode != null || contact.city != null) {
        buffer.write('${contact.postalCode ?? ''} ${contact.city ?? ''}'.trim());
        buffer.write('\\line ');
      }
      if (contact.phone != null && contact.phone!.isNotEmpty) {
        buffer.write('Tel: ${contact.phone}\\line ');
      }
      if (contact.email != null && contact.email!.isNotEmpty) {
        buffer.write('{\\cf1 Email: ${contact.email}}\\line ');
      }
      buffer.write('\\par ');
    }
    
    buffer.write('}');
    return buffer.toString();
  }

  static String _escapeRtf(String text) {
    return text
        .replaceAll('\\', '\\\\')
        .replaceAll('{', '\\{')
        .replaceAll('}', '\\}')
        .replaceAll('\n', '\\par ');
  }

  // ===== ADRESETIKETTEN TEKST =====

  /// Genereer adresetiketten (voor enveloppen)
  static String generateAddressLabels(
    List<PersonModel> contacts, {
    int labelsPerRow = 2,
    int labelWidth = 40,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('ADRESETIKETTEN');
    buffer.writeln('=' * 80);
    buffer.writeln('(${contacts.length} etiketten)');
    buffer.writeln();
    
    for (int i = 0; i < contacts.length; i += labelsPerRow) {
      final rowContacts = contacts.skip(i).take(labelsPerRow).toList();
      final labels = rowContacts.map((c) => _formatLabel(c, labelWidth)).toList();
      
      // Print labels naast elkaar
      final maxLines = labels.map((l) => l.length).reduce((a, b) => a > b ? a : b);
      
      for (int line = 0; line < maxLines; line++) {
        for (int col = 0; col < labels.length; col++) {
          if (line < labels[col].length) {
            buffer.write(labels[col][line].padRight(labelWidth + 4));
          } else {
            buffer.write(' ' * (labelWidth + 4));
          }
        }
        buffer.writeln();
      }
      buffer.writeln();
      buffer.writeln('-' * 80);
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  static List<String> _formatLabel(PersonModel contact, int width) {
    final lines = <String>[];
    lines.add(contact.fullName);
    if (contact.address != null && contact.address!.isNotEmpty) {
      lines.add(contact.address!);
    }
    if (contact.postalCode != null || contact.city != null) {
      lines.add('${contact.postalCode ?? ''} ${contact.city ?? ''}'.trim());
    }
    return lines;
  }

  /// Genereer envelop adressering (compact formaat)
  static String generateEnvelopeAddresses(List<PersonModel> contacts) {
    final buffer = StringBuffer();
    buffer.writeln('ENVELOP ADRESSEN');
    buffer.writeln('=' * 50);
    buffer.writeln();
    
    for (int i = 0; i < contacts.length; i++) {
      final contact = contacts[i];
      buffer.writeln('${i + 1}.');
      buffer.writeln('  ${contact.fullName}');
      if (contact.address != null && contact.address!.isNotEmpty) {
        buffer.writeln('  ${contact.address}');
      }
      if (contact.postalCode != null || contact.city != null) {
        buffer.writeln('  ${contact.postalCode ?? ''} ${contact.city ?? ''}'.trim());
      }
      buffer.writeln();
    }
    
    return buffer.toString();
  }

  // ===== EXPORT MET FORMAAT KEUZE =====

  /// Toon formaat selectie dialoog
  static Future<ExportFormat?> showFormatDialog(BuildContext context) async {
    return showDialog<ExportFormat>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kies bestandsformaat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ExportFormat.values.map((format) => ListTile(
            leading: Icon(format.icon),
            title: Text(format.label),
            onTap: () => Navigator.pop(context, format),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuleren'),
          ),
        ],
      ),
    );
  }

  /// Exporteer brieven met formaat keuze
  static Future<void> exportLetters(
    BuildContext context,
    List<PersonModel> contacts, {
    required String body,
    String? senderName,
    String? senderAddress,
    String filename = 'brieven',
    ExportFormat? format,
  }) async {
    try {
      final lettersWithAddress = filterWithAddress(contacts);
      
      if (lettersWithAddress.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Geen contacten met volledig adres'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Vraag om formaat als niet opgegeven
      final selectedFormat = format ?? await showFormatDialog(context);
      if (selectedFormat == null) return;
      
      Uint8List? bytes;
      String? textContent;
      
      switch (selectedFormat) {
        case ExportFormat.pdf:
          bytes = await generateLettersPdf(
            lettersWithAddress,
            body: body,
            senderName: senderName,
            senderAddress: senderAddress,
          );
          break;
        case ExportFormat.rtf:
          textContent = generateLettersRtf(
            lettersWithAddress,
            body: body,
            senderName: senderName,
            senderAddress: senderAddress,
          );
          break;
        case ExportFormat.txt:
          textContent = generateLetters(
            lettersWithAddress,
            body: body,
            senderName: senderName,
            senderAddress: senderAddress,
          );
          break;
      }
      
      // Sla op via FilePicker
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Brieven opslaan',
        fileName: '$filename.${selectedFormat.extension}',
        type: FileType.custom,
        allowedExtensions: [selectedFormat.extension],
      );
      
      if (result != null) {
        final file = File(result);
        if (bytes != null) {
          await file.writeAsBytes(bytes);
        } else if (textContent != null) {
          await file.writeAsString(textContent);
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Brieven opgeslagen: ${file.path}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export mislukt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Exporteer adresetiketten met formaat keuze
  static Future<void> exportAddressLabels(
    BuildContext context,
    List<PersonModel> contacts, {
    String filename = 'adresetiketten',
    ExportFormat? format,
  }) async {
    try {
      final contactsWithAddress = filterWithAddress(contacts);
      
      if (contactsWithAddress.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Geen contacten met volledig adres'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      // Vraag om formaat als niet opgegeven
      final selectedFormat = format ?? await showFormatDialog(context);
      if (selectedFormat == null) return;
      
      Uint8List? bytes;
      String? textContent;
      
      switch (selectedFormat) {
        case ExportFormat.pdf:
          bytes = await generateAddressLabelsPdf(contactsWithAddress);
          break;
        case ExportFormat.rtf:
          textContent = generateAddressLabelsRtf(contactsWithAddress);
          break;
        case ExportFormat.txt:
          textContent = generateAddressLabels(contactsWithAddress);
          break;
      }
      
      // Sla op via FilePicker
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Adresetiketten opslaan',
        fileName: '$filename.${selectedFormat.extension}',
        type: FileType.custom,
        allowedExtensions: [selectedFormat.extension],
      );
      
      if (result != null) {
        final file = File(result);
        if (bytes != null) {
          await file.writeAsBytes(bytes);
        } else if (textContent != null) {
          await file.writeAsString(textContent);
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Adresetiketten opgeslagen: ${file.path}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export mislukt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Exporteer adreslijst met formaat keuze
  static Future<void> shareAddressList(
    BuildContext context,
    List<PersonModel> contacts, {
    String filename = 'adreslijst',
    ExportFormat? format,
  }) async {
    try {
      final contactsWithAddress = filterWithAddress(contacts);
      
      if (contactsWithAddress.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Geen contacten met volledig adres'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      // Vraag om formaat als niet opgegeven
      final selectedFormat = format ?? await showFormatDialog(context);
      if (selectedFormat == null) return;
      
      Uint8List? bytes;
      String? textContent;
      
      switch (selectedFormat) {
        case ExportFormat.pdf:
          bytes = await generateAddressListPdf(contactsWithAddress);
          break;
        case ExportFormat.rtf:
          textContent = generateAddressListRtf(contactsWithAddress);
          break;
        case ExportFormat.txt:
          textContent = generateEnvelopeAddresses(contactsWithAddress);
          break;
      }
      
      // Sla op via FilePicker
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Adreslijst opslaan',
        fileName: '$filename.${selectedFormat.extension}',
        type: FileType.custom,
        allowedExtensions: [selectedFormat.extension],
      );
      
      if (result != null) {
        final file = File(result);
        if (bytes != null) {
          await file.writeAsBytes(bytes);
        } else if (textContent != null) {
          await file.writeAsString(textContent);
        }
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Adreslijst opgeslagen: ${file.path}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export mislukt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Direct printen via systeem print dialoog
  static Future<void> printDocument(
    BuildContext context,
    Future<Uint8List> Function() pdfGenerator, {
    String documentName = 'Document',
  }) async {
    try {
      final pdfBytes = await pdfGenerator();
      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: documentName,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Printen mislukt: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Print brieven
  static Future<void> printLetters(
    BuildContext context,
    List<PersonModel> contacts, {
    required String body,
    String? senderName,
    String? senderAddress,
  }) async {
    final contactsWithAddress = filterWithAddress(contacts);
    if (contactsWithAddress.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geen contacten met volledig adres'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    await printDocument(
      context,
      () => generateLettersPdf(
        contactsWithAddress,
        body: body,
        senderName: senderName,
        senderAddress: senderAddress,
      ),
      documentName: 'Brieven',
    );
  }

  /// Print adresetiketten
  static Future<void> printAddressLabels(
    BuildContext context,
    List<PersonModel> contacts,
  ) async {
    final contactsWithAddress = filterWithAddress(contacts);
    if (contactsWithAddress.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geen contacten met volledig adres'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    await printDocument(
      context,
      () => generateAddressLabelsPdf(contactsWithAddress),
      documentName: 'Adresetiketten',
    );
  }

  /// Print adreslijst
  static Future<void> printAddressList(
    BuildContext context,
    List<PersonModel> contacts,
  ) async {
    final contactsWithAddress = filterWithAddress(contacts);
    if (contactsWithAddress.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Geen contacten met volledig adres'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    await printDocument(
      context,
      () => generateAddressListPdf(contactsWithAddress),
      documentName: 'Adreslijst',
    );
  }
}

/// Types mailings (voor template selectie)
enum MailingType {
  all('Alle contacten', Icons.people),
  christmas('Kerstkaarten', Icons.card_giftcard),
  newsletter('Nieuwsbrief', Icons.newspaper),
  party('Feesten', Icons.celebration),
  funeral('Rouwkaarten', Icons.sentiment_neutral);

  final String label;
  final IconData icon;
  const MailingType(this.label, this.icon);
}
