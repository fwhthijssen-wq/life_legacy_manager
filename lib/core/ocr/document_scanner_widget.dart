// lib/core/ocr/document_scanner_widget.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'ocr_service.dart';
import 'document_patterns.dart';

/// Type document dat gescand wordt
enum DocumentType {
  bankStatement('Bankafschrift', Icons.account_balance, Colors.blue),
  insurancePolicy('Verzekeringspolis', Icons.shield, Colors.orange),
  pensionStatement('Pensioen UPO', Icons.elderly, Colors.purple),
  loanContract('Leningscontract', Icons.description, Colors.brown),
  other('Overig document', Icons.document_scanner, Colors.grey);

  final String label;
  final IconData icon;
  final Color color;
  const DocumentType(this.label, this.icon, this.color);
}

/// Widget voor het scannen van documenten
class DocumentScannerWidget extends StatefulWidget {
  final DocumentType documentType;
  final Function(ScannedDocumentData) onDataScanned;
  final VoidCallback? onCancel;

  const DocumentScannerWidget({
    super.key,
    required this.documentType,
    required this.onDataScanned,
    this.onCancel,
  });

  @override
  State<DocumentScannerWidget> createState() => _DocumentScannerWidgetState();
}

class _DocumentScannerWidgetState extends State<DocumentScannerWidget> {
  final OcrService _ocrService = OcrService();
  bool _isProcessing = false;
  String? _error;
  ScannedDocumentData? _scannedData;
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!_ocrService.isAvailable) {
      return _buildUnavailable(theme);
    }

    if (_isProcessing) {
      return _buildProcessing(theme);
    }

    if (_scannedData != null) {
      return _buildResults(theme);
    }

    return _buildScanner(theme);
  }

  Widget _buildUnavailable(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.desktop_windows, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Document scannen niet beschikbaar',
            style: theme.textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Deze functie is alleen beschikbaar op Android en iOS.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildScanner(ThemeData theme) {
    final isMobile = _ocrService.isCameraAvailable;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.documentType.color.withOpacity(0.1),
            widget.documentType.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.documentType.color.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: widget.documentType.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.documentType.icon,
              size: 40,
              color: widget.documentType.color,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isMobile ? 'Scan ${widget.documentType.label}' : 'Import ${widget.documentType.label}',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isMobile 
                ? 'Maak een foto of kies een PDF om gegevens automatisch in te vullen'
                : 'Selecteer een PDF document om gegevens automatisch in te vullen',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red[700], fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          
          // PDF import knop (altijd beschikbaar)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _pickPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Selecteer PDF'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          
          // Camera opties (alleen op mobile)
          if (isMobile) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galerij'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          if (widget.onCancel != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Annuleren'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProcessing(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: widget.documentType.color),
          const SizedBox(height: 24),
          Text(
            'Document analyseren...',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tekst wordt herkend en geanalyseerd',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(ThemeData theme) {
    final data = _scannedData!;
    final foundItems = <_FoundItem>[];

    // Verzamel gevonden items
    if (data.iban != null) {
      foundItems.add(_FoundItem('IBAN', data.iban!, Icons.account_balance));
    }
    if (data.bic != null) {
      foundItems.add(_FoundItem('BIC/SWIFT', data.bic!, Icons.swap_horiz));
    }
    if (data.bankName != null) {
      foundItems.add(_FoundItem('Bank', data.bankName!, Icons.business));
    }
    if (data.insurerName != null) {
      foundItems.add(_FoundItem('Verzekeraar', data.insurerName!, Icons.shield));
    }
    if (data.policyNumber != null) {
      foundItems.add(_FoundItem('Polisnummer', data.policyNumber!, Icons.tag));
    }
    if (data.pensionFund != null) {
      foundItems.add(_FoundItem('Pensioenfonds', data.pensionFund!, Icons.elderly));
    }
    if (data.participantNumber != null) {
      foundItems.add(_FoundItem('Deelnemersnr', data.participantNumber!, Icons.badge));
    }
    if (data.premium != null) {
      foundItems.add(_FoundItem('Premie', '€${data.premium!.toStringAsFixed(2)}', Icons.euro));
    }
    if (data.deductible != null) {
      foundItems.add(_FoundItem('Eigen risico', '€${data.deductible!.toStringAsFixed(2)}', Icons.money_off));
    }
    if (data.balance != null) {
      foundItems.add(_FoundItem('Saldo/Bedrag', '€${data.balance!.toStringAsFixed(2)}', Icons.account_balance_wallet));
    }
    if (data.phone != null) {
      foundItems.add(_FoundItem('Telefoon', data.phone!, Icons.phone));
    }
    if (data.email != null) {
      foundItems.add(_FoundItem('Email', data.email!, Icons.email));
    }
    if (data.website != null) {
      foundItems.add(_FoundItem('Website', data.website!, Icons.language));
    }
    if (data.dates.isNotEmpty) {
      foundItems.add(_FoundItem('Datum', data.dates.first, Icons.calendar_today));
    }
    if (data.percentages.isNotEmpty) {
      foundItems.add(_FoundItem('Percentage', '${data.percentages.first}%', Icons.percent));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, color: Colors.green[700]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Document gescand!',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${foundItems.length} velden herkend',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                tooltip: 'Opnieuw scannen',
              ),
            ],
          ),
          if (foundItems.isEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Geen herkenbare gegevens gevonden. Probeer een scherpere foto.',
                      style: TextStyle(color: Colors.orange[700]),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Herkende gegevens:',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...foundItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Icon(item.icon, size: 18, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 100,
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.value,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(Icons.check_circle, size: 18, color: Colors.green[600]),
                ],
              ),
            )),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Opnieuw'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: foundItems.isNotEmpty
                      ? () => widget.onDataScanned(data)
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Overnemen'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _takePhoto() async {
    setState(() {
      _error = null;
      _isProcessing = true;
    });

    try {
      final file = await _ocrService.takePhoto();
      if (file != null) {
        _imageFile = file;
        final data = await _ocrService.scanDocument(file);
        setState(() {
          _scannedData = data;
          _isProcessing = false;
        });
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Fout bij scannen: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() {
      _error = null;
      _isProcessing = true;
    });

    try {
      final file = await _ocrService.pickFromGallery();
      if (file != null) {
        _imageFile = file;
        final data = await _ocrService.scanDocument(file);
        setState(() {
          _scannedData = data;
          _isProcessing = false;
        });
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Fout bij laden: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _pickPdf() async {
    setState(() {
      _error = null;
      _isProcessing = true;
    });

    try {
      final file = await _ocrService.pickPdf();
      if (file != null) {
        final data = await _ocrService.scanPdfDocument(file);
        setState(() {
          _scannedData = data;
          _isProcessing = false;
        });
      } else {
        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Fout bij lezen PDF: $e';
        _isProcessing = false;
      });
    }
  }

  void _reset() {
    setState(() {
      _scannedData = null;
      _imageFile = null;
      _error = null;
    });
  }
}

class _FoundItem {
  final String label;
  final String value;
  final IconData icon;

  _FoundItem(this.label, this.value, this.icon);
}

/// Bottom sheet om een document te scannen
Future<ScannedDocumentData?> showDocumentScanner(
  BuildContext context, {
  required DocumentType documentType,
}) async {
  return showModalBottomSheet<ScannedDocumentData>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DocumentScannerWidget(
          documentType: documentType,
          onDataScanned: (data) => Navigator.pop(context, data),
          onCancel: () => Navigator.pop(context),
        ),
      ),
    ),
  );
}

