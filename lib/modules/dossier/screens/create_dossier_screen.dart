// lib/modules/dossier/screens/create_dossier_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../l10n/app_localizations.dart';
import '../dossier_repository.dart';
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

  String _selectedIcon = 'folder';
  String _selectedColor = 'teal';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _icons = [
    {'value': 'folder', 'icon': Icons.folder},
    {'value': 'family', 'icon': Icons.family_restroom},
    {'value': 'elderly', 'icon': Icons.elderly},
    {'value': 'person', 'icon': Icons.person},
    {'value': 'group', 'icon': Icons.group},
  ];

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
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final authState = ref.read(authStateProvider);
    
    // ✅ CORRECT: authState.userId (gevonden in auth_state.dart!)
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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dossierCreateTitle),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.dossierName,
                hintText: l10n.dossierNameHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.label),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.validationRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.dossierDescription,
                hintText: l10n.dossierDescriptionHint,
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.dossierIcon,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _icons.map((iconData) {
                final isSelected = _selectedIcon == iconData['value'];
                return ChoiceChip(
                  label: Icon(iconData['icon'] as IconData),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedIcon = iconData['value'] as String);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.dossierColor,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              children: _colors.map((colorData) {
                final isSelected = _selectedColor == colorData['value'];
                return ChoiceChip(
                  label: Container(
                    width: 40,
                    height: 24,
                    decoration: BoxDecoration(
                      color: colorData['color'] as Color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedColor = colorData['value'] as String);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _save,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(_isLoading ? l10n.loading : l10n.create),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
