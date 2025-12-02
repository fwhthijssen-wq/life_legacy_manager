// lib/modules/household/models/household_member.dart

class HouseholdMember {
  final String id;
  final String dossierId;
  final String personId;
  final HouseholdRelation relation;
  final bool isPrimary;
  final DateTime createdAt;

  const HouseholdMember({
    required this.id,
    required this.dossierId,
    required this.personId,
    required this.relation,
    this.isPrimary = false,
    required this.createdAt,
  });

  factory HouseholdMember.fromMap(Map<String, dynamic> map) {
    return HouseholdMember(
      id: map['id'] as String,
      dossierId: map['dossier_id'] as String,
      personId: map['person_id'] as String,
      relation: HouseholdRelation.fromString(map['relation'] as String),
      isPrimary: (map['is_primary'] as int) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dossier_id': dossierId,
      'person_id': personId,
      'relation': relation.value,
      'is_primary': isPrimary ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  HouseholdMember copyWith({
    String? id,
    String? dossierId,
    String? personId,
    HouseholdRelation? relation,
    bool? isPrimary,
    DateTime? createdAt,
  }) {
    return HouseholdMember(
      id: id ?? this.id,
      dossierId: dossierId ?? this.dossierId,
      personId: personId ?? this.personId,
      relation: relation ?? this.relation,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum HouseholdRelation {
  accountHolder('accounthouder'),
  partner('partner'),
  child('kind'),
  parent('ouder'),
  sibling('broer_zus'),
  other('overig');

  final String value;
  const HouseholdRelation(this.value);

  static HouseholdRelation fromString(String value) {
    return HouseholdRelation.values.firstWhere(
      (r) => r.value == value,
      orElse: () => HouseholdRelation.other,
    );
  }

  String getDisplayName() {
    switch (this) {
      case HouseholdRelation.accountHolder:
        return 'Accounthouder';
      case HouseholdRelation.partner:
        return 'Partner';
      case HouseholdRelation.child:
        return 'Kind';
      case HouseholdRelation.parent:
        return 'Ouder';
      case HouseholdRelation.sibling:
        return 'Broer/Zus';
      case HouseholdRelation.other:
        return 'Overig';
    }
  }
}
