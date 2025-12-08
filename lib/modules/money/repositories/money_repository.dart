// lib/modules/money/repositories/money_repository.dart

import 'package:uuid/uuid.dart';
import '../../../core/app_database.dart';
import '../../person/person_model.dart';
import '../models/money_item_model.dart';
import '../models/bank_account_model.dart';
import '../models/money_document_model.dart';
import '../models/direct_debit_model.dart';
import '../models/insurance_model.dart';
import '../models/pension_model.dart';
import '../models/income_model.dart';
import '../models/expense_model.dart';
import '../models/debt_model.dart';

/// Verzekering met gekoppelde persoon info
class InsuranceWithPerson {
  final InsuranceModel insurance;
  final MoneyItemModel moneyItem;
  final PersonModel person;

  InsuranceWithPerson({
    required this.insurance,
    required this.moneyItem,
    required this.person,
  });
}

class MoneyRepository {
  static const _uuid = Uuid();
  
  final AppDatabase _db;
  
  MoneyRepository(this._db);

  // ============== MONEY ITEMS ==============

  /// Haal alle geldzaken items op voor een dossier
  static Future<List<MoneyItemModel>> getItemsForDossier(String dossierId) async {
    final db = AppDatabase.instance;
    final results = await db.query(
      'money_items',
      where: 'dossier_id = ?',
      whereArgs: [dossierId],
      orderBy: 'category, created_at DESC',
    );
    return results.map((m) => MoneyItemModel.fromMap(m)).toList();
  }

  /// Haal items op per categorie
  static Future<List<MoneyItemModel>> getItemsByCategory(
    String dossierId,
    MoneyCategory category,
  ) async {
    final db = AppDatabase.instance;
    final results = await db.query(
      'money_items',
      where: 'dossier_id = ? AND category = ?',
      whereArgs: [dossierId, category.value],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => MoneyItemModel.fromMap(m)).toList();
  }

  /// Tel items per categorie
  static Future<Map<MoneyCategory, int>> countByCategory(String dossierId) async {
    final db = AppDatabase.instance;
    final results = await db.rawQuery('''
      SELECT category, COUNT(*) as count 
      FROM money_items 
      WHERE dossier_id = ? 
      GROUP BY category
    ''', [dossierId]);

    final counts = <MoneyCategory, int>{};
    for (final cat in MoneyCategory.values) {
      counts[cat] = 0;
    }
    for (final row in results) {
      final category = MoneyCategory.fromString(row['category'] as String?);
      counts[category] = row['count'] as int;
    }
    return counts;
  }

  /// Bereken voortgang per categorie
  static Future<Map<MoneyCategory, double>> progressByCategory(String dossierId) async {
    final db = AppDatabase.instance;
    final results = await db.rawQuery('''
      SELECT category, status, COUNT(*) as count 
      FROM money_items 
      WHERE dossier_id = ? 
      GROUP BY category, status
    ''', [dossierId]);

    final progress = <MoneyCategory, double>{};
    final totals = <MoneyCategory, int>{};
    final completeCount = <MoneyCategory, int>{};

    for (final cat in MoneyCategory.values) {
      totals[cat] = 0;
      completeCount[cat] = 0;
    }

    for (final row in results) {
      final category = MoneyCategory.fromString(row['category'] as String?);
      final status = row['status'] as String?;
      final count = row['count'] as int;

      totals[category] = (totals[category] ?? 0) + count;
      if (status == 'complete') {
        completeCount[category] = (completeCount[category] ?? 0) + count;
      } else if (status == 'partial') {
        completeCount[category] = (completeCount[category] ?? 0) + (count * 0.5).round();
      }
    }

    for (final cat in MoneyCategory.values) {
      if (totals[cat]! > 0) {
        progress[cat] = (completeCount[cat]! / totals[cat]!) * 100;
      } else {
        progress[cat] = 0;
      }
    }

    return progress;
  }

  /// Maak nieuw money item aan
  static Future<MoneyItemModel> createItem({
    required String dossierId,
    required String personId,
    required MoneyCategory category,
    required String type,
    String? name,
  }) async {
    final db = AppDatabase.instance;
    final id = _uuid.v4();
    final now = DateTime.now();

    final item = MoneyItemModel(
      id: id,
      dossierId: dossierId,
      personId: personId,
      category: category,
      type: type,
      name: name,
      status: MoneyItemStatus.notStarted,
      createdAt: now,
    );

    await db.insert('money_items', item.toMap());
    return item;
  }

  /// Update status van item
  static Future<void> updateItemStatus(String itemId, MoneyItemStatus status) async {
    final db = AppDatabase.instance;
    await db.update(
      'money_items',
      {
        'status': status.value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  /// Verwijder item (cascade naar detail tabel)
  static Future<void> deleteItem(String itemId) async {
    final db = AppDatabase.instance;
    await db.delete('money_items', where: 'id = ?', whereArgs: [itemId]);
  }

  // ============== BANKREKENINGEN ==============

  /// Haal bankrekening op bij money_item_id
  static Future<BankAccountModel?> getBankAccount(String moneyItemId) async {
    final db = AppDatabase.instance;
    final results = await db.query(
      'bank_accounts',
      where: 'money_item_id = ?',
      whereArgs: [moneyItemId],
    );
    if (results.isEmpty) return null;
    return BankAccountModel.fromMap(results.first);
  }

  /// Haal alle bankrekeningen op voor dossier
  static Future<List<BankAccountModel>> getBankAccountsForDossier(String dossierId) async {
    final db = AppDatabase.instance;
    final results = await db.rawQuery('''
      SELECT ba.* FROM bank_accounts ba
      INNER JOIN money_items mi ON ba.money_item_id = mi.id
      WHERE mi.dossier_id = ?
      ORDER BY ba.bank_name
    ''', [dossierId]);
    return results.map((m) => BankAccountModel.fromMap(m)).toList();
  }

  /// Maak bankrekening aan
  static Future<BankAccountModel> createBankAccount({
    required String dossierId,
    required String personId,
    required String bankName,
    required BankAccountType accountType,
    String? iban,
    String? accountHolder,
    double? balance,
  }) async {
    final db = AppDatabase.instance;
    
    // Eerst money_item aanmaken
    final moneyItem = await createItem(
      dossierId: dossierId,
      personId: personId,
      category: MoneyCategory.bankAccount,
      type: accountType.value,
      name: '$bankName - ${accountType.label}',
    );

    // Dan bankrekening details
    final id = _uuid.v4();
    final account = BankAccountModel(
      id: id,
      moneyItemId: moneyItem.id,
      bankName: bankName,
      accountType: accountType,
      iban: iban,
      accountHolder: accountHolder,
      balance: balance,
    );

    await db.insert('bank_accounts', account.toMap());
    return account;
  }

  /// Update bankrekening
  static Future<void> updateBankAccount(BankAccountModel account) async {
    final db = AppDatabase.instance;
    await db.update(
      'bank_accounts',
      account.toMap(),
      where: 'id = ?',
      whereArgs: [account.id],
    );
    // Update ook money_item naam
    await db.update(
      'money_items',
      {
        'name': '${account.bankName} - ${account.accountType.label}',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [account.moneyItemId],
    );
  }

  // ============== DOCUMENTEN ==============

  /// Haal documenten op voor een money item
  static Future<List<MoneyDocumentModel>> getDocuments(String moneyItemId) async {
    final db = AppDatabase.instance;
    final results = await db.query(
      'money_documents',
      where: 'money_item_id = ?',
      whereArgs: [moneyItemId],
      orderBy: 'created_at DESC',
    );
    return results.map((m) => MoneyDocumentModel.fromMap(m)).toList();
  }

  /// Voeg document toe
  static Future<MoneyDocumentModel> addDocument({
    required String moneyItemId,
    required String title,
    MoneyDocumentType type = MoneyDocumentType.other,
    String? filePath,
    String? physicalLocation,
    String? documentDate,
  }) async {
    final db = AppDatabase.instance;
    final id = _uuid.v4();
    final now = DateTime.now();

    final doc = MoneyDocumentModel(
      id: id,
      moneyItemId: moneyItemId,
      title: title,
      documentType: type,
      filePath: filePath,
      physicalLocation: physicalLocation,
      documentDate: documentDate,
      createdAt: now,
    );

    await db.insert('money_documents', doc.toMap());
    return doc;
  }

  /// Verwijder document
  static Future<void> deleteDocument(String documentId) async {
    final db = AppDatabase.instance;
    await db.delete('money_documents', where: 'id = ?', whereArgs: [documentId]);
  }

  // ============== AUTOMATISCHE INCASSO'S ==============

  /// Haal incasso's op voor bankrekening
  static Future<List<DirectDebitModel>> getDirectDebits(String bankAccountId) async {
    final db = AppDatabase.instance;
    final results = await db.query(
      'direct_debits',
      where: 'bank_account_id = ?',
      whereArgs: [bankAccountId],
      orderBy: 'description',
    );
    return results.map((m) => DirectDebitModel.fromMap(m)).toList();
  }

  /// Voeg incasso toe
  static Future<DirectDebitModel> addDirectDebit({
    required String bankAccountId,
    required String description,
    double? amount,
    PaymentFrequency frequency = PaymentFrequency.monthly,
    String? beneficiary,
  }) async {
    final db = AppDatabase.instance;
    final id = _uuid.v4();
    final now = DateTime.now();

    final debit = DirectDebitModel(
      id: id,
      bankAccountId: bankAccountId,
      description: description,
      amount: amount,
      frequency: frequency,
      beneficiary: beneficiary,
      createdAt: now,
    );

    await db.insert('direct_debits', debit.toMap());
    return debit;
  }

  /// Verwijder incasso
  static Future<void> deleteDirectDebit(String debitId) async {
    final db = AppDatabase.instance;
    await db.delete('direct_debits', where: 'id = ?', whereArgs: [debitId]);
  }

  // ============== STATISTIEKEN ==============

  /// Bereken totaal saldo alle bankrekeningen (voor dashboard)
  static Future<double> getTotalBankBalance(String dossierId) async {
    final db = AppDatabase.instance;
    final results = await db.rawQuery('''
      SELECT SUM(ba.balance) as total FROM bank_accounts ba
      INNER JOIN money_items mi ON ba.money_item_id = mi.id
      WHERE mi.dossier_id = ? AND ba.balance IS NOT NULL
    ''', [dossierId]);
    
    if (results.isEmpty || results.first['total'] == null) return 0;
    return results.first['total'] as double;
  }

  /// Bereken totaal maandelijkse incasso's
  static Future<double> getTotalMonthlyDirectDebits(String dossierId) async {
    final debits = await getAllDirectDebitsForDossier(dossierId);
    double total = 0;
    for (final debit in debits) {
      total += debit.monthlyAmount;
    }
    return total;
  }

  /// Haal alle incasso's voor dossier
  static Future<List<DirectDebitModel>> getAllDirectDebitsForDossier(String dossierId) async {
    final db = AppDatabase.instance;
    final results = await db.rawQuery('''
      SELECT dd.* FROM direct_debits dd
      INNER JOIN bank_accounts ba ON dd.bank_account_id = ba.id
      INNER JOIN money_items mi ON ba.money_item_id = mi.id
      WHERE mi.dossier_id = ?
    ''', [dossierId]);
    return results.map((m) => DirectDebitModel.fromMap(m)).toList();
  }

  // ============== INSTANCE METHODS ==============

  /// Maak nieuw money item aan (instance method)
  Future<void> createMoneyItem(MoneyItemModel item) async {
    await _db.insert('money_items', item.toMap());
  }

  /// Update money item (instance method)
  Future<void> updateMoneyItem(MoneyItemModel item) async {
    await _db.update(
      'money_items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  /// Haal money item op (instance method)
  Future<MoneyItemModel?> getMoneyItem(String id) async {
    final results = await _db.query(
      'money_items',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return MoneyItemModel.fromMap(results.first);
  }

  /// Verwijder money item (instance method)
  Future<void> deleteMoneyItem(String id) async {
    await _db.delete('money_items', where: 'id = ?', whereArgs: [id]);
  }

  // ============== VERZEKERINGEN (INSTANCE) ==============

  /// Maak verzekering aan
  Future<void> createInsurance(InsuranceModel insurance) async {
    await _db.insert('insurances', insurance.toMap());
  }

  /// Haal verzekering op
  Future<InsuranceModel?> getInsurance(String id) async {
    final results = await _db.query(
      'insurances',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return InsuranceModel.fromMap(results.first);
  }

  /// Haal verzekering op bij money_item_id
  Future<InsuranceModel?> getInsuranceByMoneyItemId(String moneyItemId) async {
    final results = await _db.query(
      'insurances',
      where: 'money_item_id = ?',
      whereArgs: [moneyItemId],
    );
    if (results.isEmpty) return null;
    return InsuranceModel.fromMap(results.first);
  }

  /// Update verzekering
  Future<void> updateInsurance(InsuranceModel insurance) async {
    await _db.update(
      'insurances',
      insurance.toMap(),
      where: 'id = ?',
      whereArgs: [insurance.id],
    );
    // Update ook money_item naam
    await _db.update(
      'money_items',
      {
        'name': '${insurance.company} - ${insurance.insuranceType.label}',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [insurance.moneyItemId],
    );
  }

  /// Haal alle verzekeringen op voor dossier met persoon info
  Future<List<InsuranceWithPerson>> getInsurancesForDossier(String dossierId) async {
    final results = await _db.rawQuery('''
      SELECT 
        i.*,
        mi.id as mi_id, mi.dossier_id, mi.person_id, mi.category, mi.type, mi.name as mi_name, mi.status, mi.created_at as mi_created_at, mi.updated_at as mi_updated_at,
        p.id as p_id, p.first_name, p.name_prefix, p.last_name, p.gender, p.relation, p.phone, p.email, p.address, p.postal_code, p.city
      FROM insurances i
      INNER JOIN money_items mi ON i.money_item_id = mi.id
      INNER JOIN persons p ON mi.person_id = p.id
      WHERE mi.dossier_id = ?
      ORDER BY i.company
    ''', [dossierId]);

    return results.map((row) {
      final insurance = InsuranceModel.fromMap({
        'id': row['id'],
        'money_item_id': row['money_item_id'],
        'company': row['company'],
        'insurance_type': row['insurance_type'],
        'policy_number': row['policy_number'],
        'insured_person_id': row['insured_person_id'],
        'co_insured': row['co_insured'],
        'start_date': row['start_date'],
        'end_date': row['end_date'],
        'duration': row['duration'],
        'premium': row['premium'],
        'payment_frequency': row['payment_frequency'],
        'payment_method': row['payment_method'],
        'linked_bank_account_id': row['linked_bank_account_id'],
        'coverage_amount': row['coverage_amount'],
        'deductible': row['deductible'],
        'additional_coverage': row['additional_coverage'],
        'notice_period': row['notice_period'],
        'auto_renewal': row['auto_renewal'],
        'cancellation_method': row['cancellation_method'],
        'last_cancellation_date': row['last_cancellation_date'],
        'advisor_name': row['advisor_name'],
        'advisor_phone': row['advisor_phone'],
        'advisor_email': row['advisor_email'],
        'service_phone': row['service_phone'],
        'service_email': row['service_email'],
        'website': row['website'],
        'claims_url': row['claims_url'],
        'death_action': row['death_action'],
        'beneficiaries': row['beneficiaries'],
        'action_required': row['action_required'],
        'death_instructions': row['death_instructions'],
        'notes': row['notes'],
      });

      final moneyItem = MoneyItemModel(
        id: row['mi_id'] as String,
        dossierId: row['dossier_id'] as String,
        personId: row['person_id'] as String,
        category: MoneyCategory.fromString(row['category'] as String?),
        type: row['type'] as String,
        name: row['mi_name'] as String?,
        status: MoneyItemStatus.fromString(row['status'] as String?),
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['mi_created_at'] as int),
        updatedAt: row['mi_updated_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(row['mi_updated_at'] as int)
            : null,
      );

      final person = PersonModel(
        id: row['p_id'] as String,
        dossierId: row['dossier_id'] as String,
        firstName: row['first_name'] as String,
        namePrefix: row['name_prefix'] as String?,
        lastName: row['last_name'] as String,
        gender: row['gender'] as String?,
        relation: row['relation'] as String?,
        phone: row['phone'] as String?,
        email: row['email'] as String?,
        address: row['address'] as String?,
        postalCode: row['postal_code'] as String?,
        city: row['city'] as String?,
      );

      return InsuranceWithPerson(
        insurance: insurance,
        moneyItem: moneyItem,
        person: person,
      );
    }).toList();
  }

  /// Verwijder verzekering
  Future<void> deleteInsurance(String id, String moneyItemId) async {
    await _db.delete('insurances', where: 'id = ?', whereArgs: [id]);
    await _db.delete('money_items', where: 'id = ?', whereArgs: [moneyItemId]);
  }

  // ============== PENSIOENEN (INSTANCE) ==============

  /// Maak pensioen aan
  Future<void> createPension(PensionModel pension) async {
    await _db.insert('pensions', pension.toMap());
  }

  /// Haal pensioen op
  Future<PensionModel?> getPension(String id) async {
    final results = await _db.query(
      'pensions',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (results.isEmpty) return null;
    return PensionModel.fromMap(results.first);
  }

  /// Update pensioen
  Future<void> updatePension(PensionModel pension) async {
    await _db.update(
      'pensions',
      pension.toMap(),
      where: 'id = ?',
      whereArgs: [pension.id],
    );
    // Update ook money_item naam
    final name = pension.provider?.isNotEmpty == true
        ? '${pension.provider} - ${pension.pensionType.label}'
        : pension.pensionType.label;
    await _db.update(
      'money_items',
      {
        'name': name,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [pension.moneyItemId],
    );
  }

  /// Haal alle pensioenen op voor dossier met persoon info
  Future<List<PensionWithPerson>> getPensionsForDossier(String dossierId) async {
    final results = await _db.rawQuery('''
      SELECT 
        p.*,
        mi.id as mi_id, mi.dossier_id, mi.person_id, mi.category, mi.type, mi.name as mi_name, mi.status, mi.created_at as mi_created_at, mi.updated_at as mi_updated_at,
        pe.id as pe_id, pe.first_name, pe.name_prefix, pe.last_name, pe.gender, pe.relation, pe.phone, pe.email
      FROM pensions p
      INNER JOIN money_items mi ON p.money_item_id = mi.id
      INNER JOIN persons pe ON mi.person_id = pe.id
      WHERE mi.dossier_id = ?
      ORDER BY p.provider
    ''', [dossierId]);

    return results.map((row) {
      final pension = PensionModel.fromMap({
        'id': row['id'],
        'money_item_id': row['money_item_id'],
        'pension_type': row['pension_type'],
        'provider': row['provider'],
        'participant_number': row['participant_number'],
        'participant_name': row['participant_name'],
        'employer': row['employer'],
        'accrual_period_start': row['accrual_period_start'],
        'accrual_period_end': row['accrual_period_end'],
        'current_capital': row['current_capital'],
        'expected_monthly_payout': row['expected_monthly_payout'],
        'pension_start_date': row['pension_start_date'],
        'has_partner_pension': row['has_partner_pension'],
        'partner_pension_percentage': row['partner_pension_percentage'],
        'partner_name': row['partner_name'],
        'has_orphan_pension': row['has_orphan_pension'],
        'has_disability_pension': row['has_disability_pension'],
        'monthly_contribution': row['monthly_contribution'],
        'paid_by': row['paid_by'],
        'tax_treatment': row['tax_treatment'],
        'allows_extra_contributions': row['allows_extra_contributions'],
        'has_survivor_pension': row['has_survivor_pension'],
        'survivor_payout_amount': row['survivor_payout_amount'],
        'survivor_conditions': row['survivor_conditions'],
        'surrender_value': row['surrender_value'],
        'claim_contact_person': row['claim_contact_person'],
        'claim_contact_phone': row['claim_contact_phone'],
        'claim_contact_email': row['claim_contact_email'],
        'survivor_instructions': row['survivor_instructions'],
        'service_phone': row['service_phone'],
        'service_email': row['service_email'],
        'website': row['website'],
        'portal_url': row['portal_url'],
        'notes': row['notes'],
      });

      final moneyItem = MoneyItemModel(
        id: row['mi_id'] as String,
        dossierId: row['dossier_id'] as String,
        personId: row['person_id'] as String,
        category: MoneyCategory.fromString(row['category'] as String?),
        type: row['type'] as String,
        name: row['mi_name'] as String?,
        status: MoneyItemStatus.fromString(row['status'] as String?),
        createdAt: DateTime.fromMillisecondsSinceEpoch(row['mi_created_at'] as int),
        updatedAt: row['mi_updated_at'] != null
            ? DateTime.fromMillisecondsSinceEpoch(row['mi_updated_at'] as int)
            : null,
      );

      final person = PersonModel(
        id: row['pe_id'] as String,
        dossierId: row['dossier_id'] as String,
        firstName: row['first_name'] as String,
        namePrefix: row['name_prefix'] as String?,
        lastName: row['last_name'] as String,
        gender: row['gender'] as String?,
        relation: row['relation'] as String?,
        phone: row['phone'] as String?,
        email: row['email'] as String?,
      );

      return PensionWithPerson(
        pension: pension,
        moneyItem: moneyItem,
        person: person,
      );
    }).toList();
  }

  /// Verwijder pensioen
  Future<void> deletePension(String id, String moneyItemId) async {
    await _db.delete('pensions', where: 'id = ?', whereArgs: [id]);
    await _db.delete('money_items', where: 'id = ?', whereArgs: [moneyItemId]);
  }

  // ============== INKOMSTEN (INSTANCE) ==============

  Future<void> createIncome(IncomeModel income) async {
    await _db.insert('incomes', income.toMap());
  }

  Future<IncomeModel?> getIncome(String id) async {
    final results = await _db.query('incomes', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return IncomeModel.fromMap(results.first);
  }

  Future<void> updateIncome(IncomeModel income) async {
    await _db.update('incomes', income.toMap(), where: 'id = ?', whereArgs: [income.id]);
    final name = income.source?.isNotEmpty == true
        ? '${income.source} - ${income.incomeType.label}'
        : income.incomeType.label;
    await _db.update('money_items', {'name': name, 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [income.moneyItemId]);
  }

  Future<List<IncomeWithPerson>> getIncomesForDossier(String dossierId) async {
    final results = await _db.rawQuery('''
      SELECT i.*, mi.id as mi_id, mi.dossier_id, mi.person_id, mi.category, mi.type, mi.name as mi_name, mi.status, mi.created_at as mi_created_at, mi.updated_at as mi_updated_at,
             pe.id as pe_id, pe.first_name, pe.name_prefix, pe.last_name, pe.gender, pe.relation, pe.phone, pe.email
      FROM incomes i
      INNER JOIN money_items mi ON i.money_item_id = mi.id
      INNER JOIN persons pe ON mi.person_id = pe.id
      WHERE mi.dossier_id = ?
      ORDER BY i.source
    ''', [dossierId]);
    return results.map((row) => IncomeWithPerson(
      income: IncomeModel.fromMap(row),
      moneyItem: MoneyItemModel(id: row['mi_id'] as String, dossierId: row['dossier_id'] as String, personId: row['person_id'] as String, category: MoneyCategory.fromString(row['category'] as String?), type: row['type'] as String, name: row['mi_name'] as String?, status: MoneyItemStatus.fromString(row['status'] as String?), createdAt: DateTime.fromMillisecondsSinceEpoch(row['mi_created_at'] as int), updatedAt: row['mi_updated_at'] != null ? DateTime.fromMillisecondsSinceEpoch(row['mi_updated_at'] as int) : null),
      person: PersonModel(id: row['pe_id'] as String, dossierId: row['dossier_id'] as String, firstName: row['first_name'] as String, namePrefix: row['name_prefix'] as String?, lastName: row['last_name'] as String, gender: row['gender'] as String?, relation: row['relation'] as String?, phone: row['phone'] as String?, email: row['email'] as String?),
    )).toList();
  }

  Future<void> deleteIncome(String id, String moneyItemId) async {
    await _db.delete('incomes', where: 'id = ?', whereArgs: [id]);
    await _db.delete('money_items', where: 'id = ?', whereArgs: [moneyItemId]);
  }

  // ============== VASTE LASTEN (INSTANCE) ==============

  Future<void> createExpense(ExpenseModel expense) async {
    await _db.insert('expenses', expense.toMap());
  }

  Future<ExpenseModel?> getExpense(String id) async {
    final results = await _db.query('expenses', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return ExpenseModel.fromMap(results.first);
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    await _db.update('expenses', expense.toMap(), where: 'id = ?', whereArgs: [expense.id]);
    final name = expense.creditor?.isNotEmpty == true
        ? '${expense.creditor} - ${expense.expenseType.label}'
        : expense.expenseType.label;
    await _db.update('money_items', {'name': name, 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [expense.moneyItemId]);
  }

  Future<List<ExpenseWithPerson>> getExpensesForDossier(String dossierId) async {
    final results = await _db.rawQuery('''
      SELECT e.*, mi.id as mi_id, mi.dossier_id, mi.person_id, mi.category, mi.type, mi.name as mi_name, mi.status, mi.created_at as mi_created_at, mi.updated_at as mi_updated_at,
             pe.id as pe_id, pe.first_name, pe.name_prefix, pe.last_name, pe.gender, pe.relation, pe.phone, pe.email
      FROM expenses e
      INNER JOIN money_items mi ON e.money_item_id = mi.id
      INNER JOIN persons pe ON mi.person_id = pe.id
      WHERE mi.dossier_id = ?
      ORDER BY e.payee
    ''', [dossierId]);
    return results.map((row) => ExpenseWithPerson(
      expense: ExpenseModel.fromMap(row),
      moneyItem: MoneyItemModel(id: row['mi_id'] as String, dossierId: row['dossier_id'] as String, personId: row['person_id'] as String, category: MoneyCategory.fromString(row['category'] as String?), type: row['type'] as String, name: row['mi_name'] as String?, status: MoneyItemStatus.fromString(row['status'] as String?), createdAt: DateTime.fromMillisecondsSinceEpoch(row['mi_created_at'] as int), updatedAt: row['mi_updated_at'] != null ? DateTime.fromMillisecondsSinceEpoch(row['mi_updated_at'] as int) : null),
      person: PersonModel(id: row['pe_id'] as String, dossierId: row['dossier_id'] as String, firstName: row['first_name'] as String, namePrefix: row['name_prefix'] as String?, lastName: row['last_name'] as String, gender: row['gender'] as String?, relation: row['relation'] as String?, phone: row['phone'] as String?, email: row['email'] as String?),
    )).toList();
  }

  Future<void> deleteExpense(String id, String moneyItemId) async {
    await _db.delete('expenses', where: 'id = ?', whereArgs: [id]);
    await _db.delete('money_items', where: 'id = ?', whereArgs: [moneyItemId]);
  }

  // ============== SCHULDEN (INSTANCE) ==============

  Future<void> createDebt(DebtModel debt) async {
    await _db.insert('debts', debt.toMap());
  }

  Future<DebtModel?> getDebt(String id) async {
    final results = await _db.query('debts', where: 'id = ?', whereArgs: [id]);
    if (results.isEmpty) return null;
    return DebtModel.fromMap(results.first);
  }

  Future<void> updateDebt(DebtModel debt) async {
    await _db.update('debts', debt.toMap(), where: 'id = ?', whereArgs: [debt.id]);
    final name = debt.creditor?.isNotEmpty == true
        ? '${debt.creditor} - ${debt.debtType.label}'
        : debt.debtType.label;
    await _db.update('money_items', {'name': name, 'updated_at': DateTime.now().millisecondsSinceEpoch}, where: 'id = ?', whereArgs: [debt.moneyItemId]);
  }

  Future<List<DebtWithPerson>> getDebtsForDossier(String dossierId) async {
    final results = await _db.rawQuery('''
      SELECT d.*, mi.id as mi_id, mi.dossier_id, mi.person_id, mi.category, mi.type, mi.name as mi_name, mi.status, mi.created_at as mi_created_at, mi.updated_at as mi_updated_at,
             pe.id as pe_id, pe.first_name, pe.name_prefix, pe.last_name, pe.gender, pe.relation, pe.phone, pe.email
      FROM debts d
      INNER JOIN money_items mi ON d.money_item_id = mi.id
      INNER JOIN persons pe ON mi.person_id = pe.id
      WHERE mi.dossier_id = ?
      ORDER BY d.creditor
    ''', [dossierId]);
    return results.map((row) => DebtWithPerson(
      debt: DebtModel.fromMap(row),
      moneyItem: MoneyItemModel(id: row['mi_id'] as String, dossierId: row['dossier_id'] as String, personId: row['person_id'] as String, category: MoneyCategory.fromString(row['category'] as String?), type: row['type'] as String, name: row['mi_name'] as String?, status: MoneyItemStatus.fromString(row['status'] as String?), createdAt: DateTime.fromMillisecondsSinceEpoch(row['mi_created_at'] as int), updatedAt: row['mi_updated_at'] != null ? DateTime.fromMillisecondsSinceEpoch(row['mi_updated_at'] as int) : null),
      person: PersonModel(id: row['pe_id'] as String, dossierId: row['dossier_id'] as String, firstName: row['first_name'] as String, namePrefix: row['name_prefix'] as String?, lastName: row['last_name'] as String, gender: row['gender'] as String?, relation: row['relation'] as String?, phone: row['phone'] as String?, email: row['email'] as String?),
    )).toList();
  }

  Future<void> deleteDebt(String id, String moneyItemId) async {
    await _db.delete('debts', where: 'id = ?', whereArgs: [id]);
    await _db.delete('money_items', where: 'id = ?', whereArgs: [moneyItemId]);
  }
}

/// Pensioen met gekoppelde persoon info
class PensionWithPerson {
  final PensionModel pension;
  final MoneyItemModel moneyItem;
  final PersonModel person;

  PensionWithPerson({
    required this.pension,
    required this.moneyItem,
    required this.person,
  });
}

/// Inkomen met gekoppelde persoon info
class IncomeWithPerson {
  final IncomeModel income;
  final MoneyItemModel moneyItem;
  final PersonModel person;

  IncomeWithPerson({
    required this.income,
    required this.moneyItem,
    required this.person,
  });
}

/// Vaste last met gekoppelde persoon info
class ExpenseWithPerson {
  final ExpenseModel expense;
  final MoneyItemModel moneyItem;
  final PersonModel person;

  ExpenseWithPerson({
    required this.expense,
    required this.moneyItem,
    required this.person,
  });
}

/// Schuld met gekoppelde persoon info
class DebtWithPerson {
  final DebtModel debt;
  final MoneyItemModel moneyItem;
  final PersonModel person;

  DebtWithPerson({
    required this.debt,
    required this.moneyItem,
    required this.person,
  });
}


