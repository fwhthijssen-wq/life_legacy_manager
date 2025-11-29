// lib/modules/dossier/dossier_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dossier_model.dart';
import 'dossier_repository.dart';
import '../auth/providers/auth_providers.dart';

/// Provider voor geselecteerd dossier ID
final selectedDossierIdProvider = StateProvider<String?>((ref) => null);

/// Provider voor lijst van dossiers van huidige user
final dossiersProvider = FutureProvider<List<DossierModel>>((ref) async {
  final authState = ref.watch(authStateProvider);
  
  // ✅ CORRECT: authState.userId (gevonden in auth_state.dart!)
  if (authState.userId == null) {
    return [];
  }

  return await DossierRepository.getDossiersForUser(authState.userId!);
});

/// Provider voor huidig geselecteerd dossier
final currentDossierProvider = FutureProvider<DossierModel?>((ref) async {
  final dossierId = ref.watch(selectedDossierIdProvider);
  
  if (dossierId == null) return null;
  
  return await DossierRepository.getDossierById(dossierId);
});

/// Provider om dossiers te refreshen (na create/update/delete)
final dossiersRefreshProvider = StateProvider<int>((ref) => 0);

/// Helper om dossiers te refreshen
void refreshDossiers(WidgetRef ref) {
  ref.read(dossiersRefreshProvider.notifier).state++;
  ref.invalidate(dossiersProvider);
}
