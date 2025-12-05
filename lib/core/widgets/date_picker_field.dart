// lib/core/widgets/date_picker_field.dart
// Herbruikbare form widgets met validatie

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Helper om verplichte veld labels te maken met rode asterisk
String requiredLabel(String label) => '$label *';

/// Helper widget voor labels met verplichte markering
class RequiredLabel extends StatelessWidget {
  final String label;
  final bool isRequired;

  const RequiredLabel({
    super.key,
    required this.label,
    this.isRequired = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isRequired) return Text(label);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: label),
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Colors.red),
          ),
        ],
      ),
    );
  }
}

/// Herbruikbare datumkiezer widget
class DatePickerField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final bool enabled;
  final String? Function(String?)? validator;
  final VoidCallback? onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialDate;

  const DatePickerField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.prefixIcon = Icons.calendar_today,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.firstDate,
    this.lastDate,
    this.initialDate,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText ?? 'DD-MM-JJJJ',
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_month),
          onPressed: enabled ? () => _selectDate(context) : null,
        ),
      ),
      validator: validator,
      onTap: enabled ? () => _selectDate(context) : null,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // Parse huidige waarde als die er is
    DateTime? currentDate;
    if (controller.text.isNotEmpty) {
      currentDate = _parseDate(controller.text);
    }

    final DateTime now = DateTime.now();
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? initialDate ?? now,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(2100),
      locale: const Locale('nl', 'NL'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    ) ?? (currentDate ?? now);

    // Format naar DD-MM-YYYY
    controller.text = DateFormat('dd-MM-yyyy').format(picked);
    onChanged?.call();
  }

  DateTime? _parseDate(String text) {
    try {
      // Probeer verschillende formaten
      final formats = [
        'dd-MM-yyyy',
        'dd/MM/yyyy',
        'd-M-yyyy',
        'd/M/yyyy',
        'yyyy-MM-dd',
      ];
      
      for (final format in formats) {
        try {
          return DateFormat(format).parse(text);
        } catch (_) {
          continue;
        }
      }
    } catch (_) {}
    return null;
  }
}

/// IBAN veld met validatie en formatting
class IbanField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final VoidCallback? onChanged;

  const IbanField({
    super.key,
    required this.controller,
    this.labelText = 'IBAN',
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'NL00 BANK 0000 0000 00',
        prefixIcon: const Icon(Icons.account_balance),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return null; // Optioneel
        final cleaned = value.replaceAll(' ', '').toUpperCase();
        if (cleaned.length < 15 || cleaned.length > 34) {
          return 'Ongeldige IBAN lengte';
        }
        if (cleaned.startsWith('NL') && cleaned.length != 18) {
          return 'Nederlandse IBAN moet 18 karakters zijn';
        }
        if (!RegExp(r'^[A-Z]{2}\d{2}[A-Z0-9]+$').hasMatch(cleaned)) {
          return 'Ongeldig IBAN formaat';
        }
        return null;
      },
      onChanged: (_) {
        // Auto-format met spaties
        final text = controller.text.replaceAll(' ', '').toUpperCase();
        if (text.length > 4) {
          final formatted = text.replaceAllMapped(
            RegExp(r'.{4}'),
            (match) => '${match.group(0)} ',
          ).trim();
          if (formatted != controller.text) {
            controller.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        }
        onChanged?.call();
      },
    );
  }
}

/// Bedrag veld met Euro formatting
class AmountField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final bool enabled;
  final bool allowNegative;
  final String? Function(String?)? validator;
  final VoidCallback? onChanged;

  const AmountField({
    super.key,
    required this.controller,
    required this.labelText,
    this.hintText,
    this.enabled = true,
    this.allowNegative = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText ?? '0,00',
        prefixIcon: const Icon(Icons.euro),
        prefixText: '€ ',
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) return null;
        final cleaned = value.replaceAll('.', '').replaceAll(',', '.');
        final amount = double.tryParse(cleaned);
        if (amount == null) {
          return 'Ongeldig bedrag';
        }
        if (!allowNegative && amount < 0) {
          return 'Bedrag mag niet negatief zijn';
        }
        return null;
      },
      onChanged: (_) => onChanged?.call(),
    );
  }
}

/// Percentage veld met validatie
class PercentageField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final double? min;
  final double? max;
  final VoidCallback? onChanged;

  const PercentageField({
    super.key,
    required this.controller,
    required this.labelText,
    this.enabled = true,
    this.min,
    this.max,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: '0,0',
        prefixIcon: const Icon(Icons.percent),
        suffixText: '%',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        final cleaned = value.replaceAll(',', '.');
        final pct = double.tryParse(cleaned);
        if (pct == null) {
          return 'Ongeldig percentage';
        }
        if (min != null && pct < min!) {
          return 'Minimaal $min%';
        }
        if (max != null && pct > max!) {
          return 'Maximaal $max%';
        }
        return null;
      },
      onChanged: (_) => onChanged?.call(),
    );
  }
}

/// Telefoon veld met validatie
class PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final VoidCallback? onChanged;

  const PhoneField({
    super.key,
    required this.controller,
    this.labelText = 'Telefoon',
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: '06-12345678',
        prefixIcon: const Icon(Icons.phone),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');
        if (cleaned.length < 10) {
          return 'Telefoonnummer te kort';
        }
        return null;
      },
      onChanged: (_) => onChanged?.call(),
    );
  }
}

/// Email veld met validatie
class EmailField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final VoidCallback? onChanged;

  const EmailField({
    super.key,
    required this.controller,
    this.labelText = 'Email',
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'email@voorbeeld.nl',
        prefixIcon: const Icon(Icons.email),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) {
          return 'Ongeldig emailadres';
        }
        return null;
      },
      onChanged: (_) => onChanged?.call(),
    );
  }
}

/// Website veld met validatie
class WebsiteField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final VoidCallback? onChanged;

  const WebsiteField({
    super.key,
    required this.controller,
    this.labelText = 'Website',
    this.enabled = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.url,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: 'www.voorbeeld.nl',
        prefixIcon: const Icon(Icons.language),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return null;
        // Voeg https:// toe als niet aanwezig
        var url = value;
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'https://$url';
        }
        final uri = Uri.tryParse(url);
        if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
          return 'Ongeldige website URL';
        }
        return null;
      },
      onChanged: (_) => onChanged?.call(),
    );
  }
}

