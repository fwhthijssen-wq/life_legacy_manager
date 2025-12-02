// lib/modules/household/providers/household_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/household_repository.dart';
import '../models/household_member.dart';
import '../models/personal_document.dart';

// Repository provider
final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  return HouseholdRepository();
});

// Household members for current dossier
final householdMembersProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, dossierId) async {
    final repository = ref.read(householdRepositoryProvider);
    return repository.getHouseholdMembers(dossierId);
  },
);

// Primary household member
final primaryMemberProvider = FutureProvider.family<Map<String, dynamic>?, String>(
  (ref, dossierId) async {
    final repository = ref.read(householdRepositoryProvider);
    return repository.getPrimaryMember(dossierId);
  },
);

// Documents for a person
final personDocumentsProvider = FutureProvider.family<List<PersonalDocument>, String>(
  (ref, personId) async {
    final repository = ref.read(householdRepositoryProvider);
    return repository.getPersonDocuments(personId);
  },
);

// Expiring documents for dossier
final expiringDocumentsProvider = FutureProvider.family<List<PersonalDocument>, String>(
  (ref, dossierId) async {
    final repository = ref.read(householdRepositoryProvider);
    return repository.getExpiringDocuments(dossierId);
  },
);
