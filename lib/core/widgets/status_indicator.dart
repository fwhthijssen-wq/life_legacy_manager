// lib/core/widgets/status_indicator.dart

import 'package:flutter/material.dart';

/// Universele status voor alle items in de app
enum ItemStatus {
  notStarted('not_started', 'Niet begonnen'),
  inProgress('in_progress', 'Bezig'),
  complete('complete', 'Compleet');

  final String value;
  final String label;
  const ItemStatus(this.value, this.label);

  static ItemStatus fromString(String? value) {
    return ItemStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ItemStatus.notStarted,
    );
  }

  Color get color {
    switch (this) {
      case ItemStatus.notStarted:
        return Colors.red;
      case ItemStatus.inProgress:
        return Colors.blue;
      case ItemStatus.complete:
        return Colors.green;
    }
  }
}

/// Widget met 3 klikbare status bolletjes: rood (niet begonnen), blauw (bezig), groen (compleet)
class StatusIndicator extends StatelessWidget {
  final ItemStatus status;
  final ValueChanged<ItemStatus>? onStatusChanged;
  final bool enabled;
  final double size;

  const StatusIndicator({
    super.key,
    required this.status,
    this.onStatusChanged,
    this.enabled = true,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusCircle(
          color: Colors.red,
          isSelected: status == ItemStatus.notStarted,
          size: size,
          tooltip: 'Niet begonnen',
          onTap: enabled && onStatusChanged != null
              ? () => onStatusChanged!(ItemStatus.notStarted)
              : null,
        ),
        SizedBox(width: size * 0.3),
        _StatusCircle(
          color: Colors.blue,
          isSelected: status == ItemStatus.inProgress,
          size: size,
          tooltip: 'Bezig',
          onTap: enabled && onStatusChanged != null
              ? () => onStatusChanged!(ItemStatus.inProgress)
              : null,
        ),
        SizedBox(width: size * 0.3),
        _StatusCircle(
          color: Colors.green,
          isSelected: status == ItemStatus.complete,
          size: size,
          tooltip: 'Compleet',
          onTap: enabled && onStatusChanged != null
              ? () => onStatusChanged!(ItemStatus.complete)
              : null,
        ),
      ],
    );
  }
}

class _StatusCircle extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final double size;
  final String tooltip;
  final VoidCallback? onTap;

  const _StatusCircle({
    required this.color,
    required this.isSelected,
    required this.size,
    required this.tooltip,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? color : Colors.transparent,
            border: Border.all(
              color: color,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  color: Colors.white,
                  size: size * 0.6,
                )
              : null,
        ),
      ),
    );
  }
}

/// StatusIndicator met label
class StatusIndicatorWithLabel extends StatelessWidget {
  final ItemStatus status;
  final ValueChanged<ItemStatus>? onStatusChanged;
  final bool enabled;
  final double size;
  final bool showLabel;

  const StatusIndicatorWithLabel({
    super.key,
    required this.status,
    this.onStatusChanged,
    this.enabled = true,
    this.size = 24,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Text(
            'Status:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(width: 12),
        ],
        StatusIndicator(
          status: status,
          onStatusChanged: onStatusChanged,
          enabled: enabled,
          size: size,
        ),
        if (showLabel) ...[
          const SizedBox(width: 12),
          Text(
            status.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: status.color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }
}

/// Mixin voor auto-status berekening
/// Gebruik: extend je State class met dit mixin en implementeer getRequiredFields() en getOptionalFields()
mixin AutoStatusMixin<T extends StatefulWidget> on State<T> {
  /// Override deze methode om de verplichte velden te definiëren
  /// Return een map van veldnaam -> waarde (null of lege string = niet ingevuld)
  Map<String, dynamic> getRequiredFields() => {};

  /// Override deze methode om de optionele velden te definiëren
  Map<String, dynamic> getOptionalFields() => {};

  /// Bereken de status op basis van ingevulde velden
  ItemStatus calculateStatus() {
    final requiredFields = getRequiredFields();
    final optionalFields = getOptionalFields();
    
    // Check of alle verplichte velden zijn ingevuld
    final allRequiredFilled = requiredFields.values.every(_isFieldFilled);
    
    // Check of er velden zijn ingevuld (verplicht of optioneel)
    final anyFieldFilled = requiredFields.values.any(_isFieldFilled) ||
        optionalFields.values.any(_isFieldFilled);

    // Check of alle velden zijn ingevuld
    final allFieldsFilled = allRequiredFilled &&
        optionalFields.values.every(_isFieldFilled);

    if (allFieldsFilled) {
      return ItemStatus.complete;
    } else if (anyFieldFilled) {
      return ItemStatus.inProgress;
    } else {
      return ItemStatus.notStarted;
    }
  }

  bool _isFieldFilled(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is bool) return value; // true = filled, false = not filled
    if (value is num) return value != 0;
    return true; // Other types are considered filled if not null
  }
}

/// Helper functie voor status berekening zonder mixin
ItemStatus calculateItemStatus({
  required Map<String, dynamic> requiredFields,
  Map<String, dynamic> optionalFields = const {},
}) {
  bool isFieldFilled(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    if (value is List) return value.isNotEmpty;
    if (value is bool) return value;
    if (value is num) return value != 0;
    return true;
  }

  final allRequiredFilled = requiredFields.values.every(isFieldFilled);
  final anyFieldFilled = requiredFields.values.any(isFieldFilled) ||
      optionalFields.values.any(isFieldFilled);
  final allFieldsFilled = allRequiredFilled &&
      optionalFields.values.every(isFieldFilled);

  if (allFieldsFilled) {
    return ItemStatus.complete;
  } else if (anyFieldFilled) {
    return ItemStatus.inProgress;
  } else {
    return ItemStatus.notStarted;
  }
}






