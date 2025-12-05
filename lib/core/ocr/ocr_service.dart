// lib/core/ocr/ocr_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'document_patterns.dart';

/// Service voor OCR scanning van documenten
class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();
  
  final ImagePicker _picker = ImagePicker();
  TextRecognizer? _textRecognizer;
  
  /// Check of camera OCR beschikbaar is op dit platform
  bool get isCameraAvailable => Platform.isAndroid || Platform.isIOS;
  
  /// Check of PDF import beschikbaar is (altijd true)
  bool get isPdfAvailable => true;
  
  /// Check of enige scan optie beschikbaar is
  bool get isAvailable => isCameraAvailable || isPdfAvailable;
  
  /// Initialiseer de text recognizer
  TextRecognizer get textRecognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }
  
  /// Maak een foto met de camera
  Future<File?> takePhoto() async {
    if (!isAvailable) return null;
    
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
    }
    return null;
  }
  
  /// Kies een afbeelding uit de galerij
  Future<File?> pickFromGallery() async {
    if (!isAvailable) return null;
    
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      
      if (image != null) {
        return File(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
    return null;
  }
  
  /// Voer OCR uit op een afbeelding
  Future<String?> recognizeText(File imageFile) async {
    if (!isAvailable) return null;
    
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      debugPrint('Error recognizing text: $e');
      return null;
    }
  }
  
  /// Scan een document en extraheer gestructureerde data
  Future<ScannedDocumentData?> scanDocument(File imageFile) async {
    final text = await recognizeText(imageFile);
    if (text == null || text.isEmpty) return null;
    
    return analyzeText(text);
  }
  
  /// Analyseer tekst en extraheer gegevens
  ScannedDocumentData analyzeText(String text) {
    // IBAN zoeken
    String? iban;
    final ibanMatches = DocumentPatterns.ibanPattern.allMatches(text);
    for (final match in ibanMatches) {
      final candidate = DocumentPatterns.normalizeIban(match.group(0)!);
      if (DocumentPatterns.isValidIban(candidate)) {
        iban = candidate;
        break;
      }
    }
    
    // BIC zoeken
    String? bic;
    final bicMatch = DocumentPatterns.bicPattern.firstMatch(text);
    if (bicMatch != null) {
      bic = bicMatch.group(0)!.toUpperCase();
    }
    
    // Bank zoeken
    final bankName = DocumentPatterns.findKnownOrganization(
      text, 
      DocumentPatterns.dutchBanks,
    );
    
    // Verzekeraar zoeken
    final insurerName = DocumentPatterns.findKnownOrganization(
      text, 
      DocumentPatterns.dutchInsurers,
    );
    
    // Pensioenfonds zoeken
    final pensionFund = DocumentPatterns.findKnownOrganization(
      text, 
      DocumentPatterns.dutchPensionFunds,
    );
    
    // Polisnummer zoeken
    String? policyNumber;
    final policyMatch = DocumentPatterns.policyNumberPattern.firstMatch(text);
    if (policyMatch != null && policyMatch.groupCount >= 1) {
      policyNumber = policyMatch.group(1);
    }
    
    // Deelnemersnummer zoeken
    String? participantNumber;
    final participantMatch = DocumentPatterns.participantNumberPattern.firstMatch(text);
    if (participantMatch != null && participantMatch.groupCount >= 1) {
      participantNumber = participantMatch.group(1);
    }
    
    // Premie zoeken
    double? premium;
    final premiumMatch = DocumentPatterns.premiumPattern.firstMatch(text);
    if (premiumMatch != null && premiumMatch.groupCount >= 1) {
      premium = DocumentPatterns.parseAmount(premiumMatch.group(1));
    }
    
    // Eigen risico zoeken
    double? deductible;
    final deductibleMatch = DocumentPatterns.deductiblePattern.firstMatch(text);
    if (deductibleMatch != null && deductibleMatch.groupCount >= 1) {
      deductible = DocumentPatterns.parseAmount(deductibleMatch.group(1));
    }
    
    // Telefoon zoeken
    String? phone;
    final phoneMatch = DocumentPatterns.phonePattern.firstMatch(text);
    if (phoneMatch != null) {
      phone = phoneMatch.group(0);
    }
    
    // Email zoeken
    String? email;
    final emailMatch = DocumentPatterns.emailPattern.firstMatch(text);
    if (emailMatch != null) {
      email = emailMatch.group(0);
    }
    
    // Website zoeken
    String? website;
    final websiteMatch = DocumentPatterns.websitePattern.firstMatch(text);
    if (websiteMatch != null) {
      website = websiteMatch.group(0);
    }
    
    // Alle datums zoeken
    final dates = DocumentPatterns.datePattern
        .allMatches(text)
        .map((m) => m.group(0)!)
        .toList();
    
    // Alle bedragen zoeken
    final amounts = <double>[];
    for (final match in DocumentPatterns.amountPattern.allMatches(text)) {
      final amount = DocumentPatterns.parseAmount(match.group(0));
      if (amount != null && amount > 0) {
        amounts.add(amount);
      }
    }
    
    // Alle percentages zoeken
    final percentages = <double>[];
    for (final match in DocumentPatterns.percentagePattern.allMatches(text)) {
      final pctStr = match.group(1);
      if (pctStr != null) {
        final pct = double.tryParse(pctStr.replaceAll(',', '.'));
        if (pct != null) {
          percentages.add(pct);
        }
      }
    }
    
    // Grootste bedrag is waarschijnlijk saldo/hoofdsom
    double? balance;
    if (amounts.isNotEmpty) {
      amounts.sort((a, b) => b.compareTo(a));
      balance = amounts.first;
    }
    
    return ScannedDocumentData(
      iban: iban,
      bic: bic,
      bankName: bankName,
      balance: balance,
      insurerName: insurerName,
      policyNumber: policyNumber,
      premium: premium,
      deductible: deductible,
      pensionFund: pensionFund,
      participantNumber: participantNumber,
      phone: phone,
      email: email,
      website: website,
      dates: dates,
      amounts: amounts,
      percentages: percentages,
      rawText: text,
    );
  }
  
  /// Kies een PDF bestand
  Future<File?> pickPdf() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      debugPrint('Error picking PDF: $e');
    }
    return null;
  }
  
  /// Extraheer tekst uit een PDF bestand
  Future<String?> extractTextFromPdf(File pdfFile) async {
    try {
      final bytes = await pdfFile.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      
      // Extraheer tekst van alle pagina's
      final StringBuffer textBuffer = StringBuffer();
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      
      for (int i = 0; i < document.pages.count; i++) {
        final String pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
        textBuffer.writeln(pageText);
      }
      
      document.dispose();
      
      return textBuffer.toString();
    } catch (e) {
      debugPrint('Error extracting PDF text: $e');
      return null;
    }
  }
  
  /// Scan een PDF document en extraheer gestructureerde data
  Future<ScannedDocumentData?> scanPdfDocument(File pdfFile) async {
    final text = await extractTextFromPdf(pdfFile);
    if (text == null || text.isEmpty) return null;
    
    return analyzeText(text);
  }
  
  /// Cleanup resources
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
  }
}

