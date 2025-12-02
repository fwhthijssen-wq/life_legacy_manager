// lib/modules/dossier/screens/create_dossier_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../dossier_repository.dart';
import '../dossier_model.dart';
import '../../auth/providers/auth_providers.dart';

class CreateDossierScreen extends ConsumerStatefulWidget {
  const CreateDossierScreen({super.key});

  @override
  ConsumerState<CreateDossierScreen> createState() => _CreateDossierScreenState();
}

class _CreateDossierScreenState extends ConsumerState<CreateDossierScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _partnerNameController = TextEditingController();

  DossierType _selectedType = DossierType.family;
  String _selectedIcon = 'family';
  String _selectedColor = 'teal';
  bool _isLoading = false;
  bool _useCustomName = false;

  final List<Map<String, dynamic>> _colors = [
    {'value': 'teal', 'color': Colors.teal},
    {'value': 'blue', 'color': Colors.blue},
    {'value': 'green', 'color': Colors.green},
    {'value': 'orange', 'color': Colors.orange},
    {'value': 'purple', 'color': Colors.purple},
    {'value': 'red', 'color': Colors.red},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _lastNameController.dispose();
    _partnerNameController.dispose();
    super.dispose();
  }

  void _onTypeChanged(DossierType type) {
    setState(() {
      _selectedType = type;
      _selectedIcon = type.defaultIcon;
      _updateSuggestedName();
    });
  }

  void _updateSuggestedName() {
    if (_useCustomName) return;
    
    final lastName = _lastNameController.text.trim();
    final partnerName = _partnerNameController.text.trim();
    
    String suggestedName = '';
    String suggestedDescription = '';
    
    switch (_selectedType) {
      case DossierType.family:
        if (lastName.isNotEmpty) {
          suggestedName = 'Familie $lastName';
          suggestedDescription = 'Gezinsdossier';
        }
        break;
      case DossierType.couple:
        if (lastName.isNotEmpty && partnerName.isNotEmpty) {
          suggestedName = '$lastName & $partnerName';
          suggestedDescription = 'Echtpaar zonder kinderen';
        } else if (lastName.isNotEmpty) {
          suggestedName = 'Huishouden $lastName';
          suggestedDescription = 'Echtpaar zonder kinderen';
        }
        break;
      case DossierType.single:
        if (lastName.isNotEmpty) {
          suggestedName = lastName;
          suggestedDescription = 'Alleenstaande';
        }
        break;
      case DossierType.other:
        if (lastName.isNotEmpty) {
          suggestedName = 'Dossier $lastName';
          suggestedDescription = '';
        }
        break;
    }
    
    if (suggestedName.isNotEmpty) {
      _nameController.text = suggestedName;
    }
    if (suggestedDescription.isNotEmpty && _descriptionController.text.isEmpty) {
      _descriptionController.text = suggestedDescription;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authStateProvider);
    
    if (authState.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geen gebruiker ingelogd')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await DossierRepository.createDossier(
        userId: authState.userId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        type: _selectedType,
      );

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dossierCreateTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ===== STAP 1: TYPE SELECTIE =====
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('1', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          )),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Type huishouden',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...DossierType.values.map((type) {
                      final isSelected = _selectedType == type;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          onTap: () => _onTypeChanged(type),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.primaryColor.withOpacity(0.1)
                                  : Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? theme.primaryColor
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  type.emoji,
                                  style: const TextStyle(fontSize: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        type.displayName,
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                      Text(
                                        type.description,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(Icons.check_circle, color: theme.primaryColor),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // ===== STAP 2: NAAM INVOER =====
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('2', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          )),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Naam invullen',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Achternaam veld (voor suggestie)
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: _selectedType == DossierType.single
                            ? 'Naam persoon'
                            : 'Achternaam',
                        hintText: _selectedType == DossierType.single
                            ? 'bijv. Oom Piet'
                            : 'bijv. Jansen',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      onChanged: (_) => _updateSuggestedName(),
                      textInputAction: TextInputAction.next,
                    ),
                    
                    // Partner naam (alleen voor couple)
                    if (_selectedType == DossierType.couple) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _partnerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Naam partner',
                          hintText: 'bijv. Jan & Truus',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.people),
                        ),
                        onChanged: (_) => _updateSuggestedName(),
                        textInputAction: TextInputAction.next,
                      ),
                    ],
                    
                    const SizedBox(height: 16),
                    
                    // Suggestie chip
                    if (_nameController.text.isNotEmpty && !_useCustomName)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb, color: Colors.green[700], size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Suggestie: "${_nameController.text}"',
                                style: TextStyle(color: Colors.green[700]),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _useCustomName = true);
                              },
                              child: const Text('Aanpassen'),
                            ),
                          ],
                        ),
                      ),
                    
                    // Custom naam veld
                    if (_useCustomName) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: l10n.dossierName,
                          hintText: l10n.dossierNameHint,
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.label),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.auto_fix_high),
                            tooltip: 'Gebruik suggestie',
                            onPressed: () {
                              setState(() {
                                _useCustomName = false;
                                _updateSuggestedName();
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return l10n.validationRequired;
                          }
                          return null;
                        },
                      ),
                    ],
                    
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.dossierDescription,
                        hintText: l10n.dossierDescriptionHint,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),

            // ===== STAP 3: KLEUR =====
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('3', style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          )),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          l10n.dossierColor,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: _colors.map((colorData) {
                        final isSelected = _selectedColor == colorData['value'];
                        return InkWell(
                          onTap: () {
                            setState(() => _selectedColor = colorData['value'] as String);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: colorData['color'] as Color,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.black
                                    : Colors.transparent,
                                width: 3,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: (colorData['color'] as Color).withOpacity(0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== PREVIEW =====
            Card(
              color: _getColor(_selectedColor).withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _getColor(_selectedColor).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          _selectedType.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _nameController.text.isEmpty
                                ? 'Naam dossier'
                                : _nameController.text,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_descriptionController.text.isNotEmpty)
                            Text(
                              _descriptionController.text,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getColor(_selectedColor),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _selectedType.displayName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ===== SAVE BUTTON =====
            SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  _isLoading ? l10n.loading : l10n.create,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Color _getColor(String colorValue) {
    switch (colorValue) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      default:
        return Colors.teal;
    }
  }
}
