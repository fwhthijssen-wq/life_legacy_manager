// lib/core/app_database.dart

import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

class AppDatabase {
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    // Windows: FFI gebruiken
    if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'life_legacy_manager.db');
    
    // DEBUG: Print database locatie
    print('');
    print('════════════════════════════════════════════');
    print('📁 DATABASE PAD: $path');
    print('════════════════════════════════════════════');
    print('');

    return await openDatabase(
      path,
      version: 11, // ← VERSIE 11: emoji kolom voor mailing_lists
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // USERS tabel (login/registratie)
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        first_name TEXT NOT NULL,
        name_prefix TEXT,
        last_name TEXT NOT NULL,
        gender TEXT,
        birth_date INTEGER,
        email TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        pin_hash TEXT,
        is_pin_enabled INTEGER NOT NULL DEFAULT 0,
        is_biometric_enabled INTEGER NOT NULL DEFAULT 0,
        recovery_phrase_hash TEXT,
        created_at INTEGER NOT NULL,
        last_login INTEGER
      );
    ''');

    // DOSSIERS tabel
    await db.execute('''
      CREATE TABLE dossiers (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        color TEXT,
        type TEXT DEFAULT 'family',
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    ''');

    // PERSONS tabel (uitgebreid met contact-velden)
    await db.execute('''
      CREATE TABLE persons (
        id TEXT PRIMARY KEY,
        dossier_id TEXT NOT NULL,
        first_name TEXT NOT NULL,
        name_prefix TEXT,
        last_name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        birth_date TEXT,
        address TEXT,
        postal_code TEXT,
        city TEXT,
        gender TEXT,
        notes TEXT,
        relation TEXT,
        death_date TEXT,
        is_contact INTEGER NOT NULL DEFAULT 0,
        contact_categories TEXT,
        created_at INTEGER,
        FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
      );
    ''');

    // Index voor sneller zoeken
    await db.execute('CREATE INDEX idx_persons_dossier ON persons(dossier_id);');
    await db.execute('CREATE INDEX idx_dossiers_user ON dossiers(user_id);');
    await db.execute('CREATE INDEX idx_persons_contact ON persons(is_contact);');
    
    // HOUSEHOLD_MEMBERS tabel (gezinsleden per dossier)
    await db.execute('''
      CREATE TABLE household_members (
        id TEXT PRIMARY KEY,
        dossier_id TEXT NOT NULL,
        person_id TEXT NOT NULL,
        relation TEXT NOT NULL,
        is_primary INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE,
        FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE,
        UNIQUE(dossier_id, person_id)
      );
    ''');
    
    // PERSONAL_DOCUMENTS tabel (documenten per persoon)
    await db.execute('''
      CREATE TABLE personal_documents (
        id TEXT PRIMARY KEY,
        person_id TEXT NOT NULL,
        document_type TEXT NOT NULL,
        document_number TEXT,
        issue_date TEXT,
        expiry_date TEXT,
        issuing_authority TEXT,
        document_file_path TEXT,
        physical_location TEXT,
        notes TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE
      );
    ''');
    
    // Uitbreiding persons tabel met BSN en burgerlijke staat
    await db.execute('ALTER TABLE persons ADD COLUMN bsn TEXT;');
    await db.execute('ALTER TABLE persons ADD COLUMN civil_status TEXT;');
    
    // EMAIL_TEMPLATES tabel
    await db.execute('''
      CREATE TABLE email_templates (
        id TEXT PRIMARY KEY,
        dossier_id TEXT NOT NULL,
        name TEXT NOT NULL,
        subject TEXT,
        body TEXT,
        mailing_type TEXT,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
      );
    ''');
    
    // MAILING_LISTS tabel
    await db.execute('''
      CREATE TABLE mailing_lists (
        id TEXT PRIMARY KEY,
        dossier_id TEXT NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        contact_ids TEXT,
        mailing_type TEXT,
        emoji TEXT DEFAULT '📋',
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
      );
    ''');
    
    // Indexes voor nieuwe tabellen
    await db.execute('CREATE INDEX idx_household_dossier ON household_members(dossier_id);');
    await db.execute('CREATE INDEX idx_household_person ON household_members(person_id);');
    await db.execute('CREATE INDEX idx_documents_person ON personal_documents(person_id);');
    await db.execute('CREATE INDEX idx_templates_dossier ON email_templates(dossier_id);');
    await db.execute('CREATE INDEX idx_templates_type ON email_templates(mailing_type);');
    await db.execute('CREATE INDEX idx_mailing_lists_dossier ON mailing_lists(dossier_id);');
    
    // ============== MONEY MODULE TABELLEN ==============
    
    // MONEY_ITEMS tabel (centrale tabel voor alle geldzaken)
    await db.execute('''
      CREATE TABLE money_items (
        id TEXT PRIMARY KEY,
        dossier_id TEXT NOT NULL,
        person_id TEXT NOT NULL,
        category TEXT NOT NULL,
        type TEXT NOT NULL,
        name TEXT,
        status TEXT DEFAULT 'not_started',
        created_at INTEGER NOT NULL,
        updated_at INTEGER,
        FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE,
        FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE
      );
    ''');
    
    // BANK_ACCOUNTS tabel
    await db.execute('''
      CREATE TABLE bank_accounts (
        id TEXT PRIMARY KEY,
        money_item_id TEXT NOT NULL,
        bank_name TEXT NOT NULL,
        account_type TEXT,
        iban TEXT,
        account_holder TEXT,
        balance REAL,
        notes TEXT,
        FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
      );
    ''');
    
    // INSURANCES tabel
    await db.execute('''
      CREATE TABLE insurances (
        id TEXT PRIMARY KEY,
        money_item_id TEXT NOT NULL,
        company TEXT,
        insurance_type TEXT,
        policy_number TEXT,
        insured_person_id TEXT,
        co_insured TEXT,
        start_date TEXT,
        end_date TEXT,
        duration TEXT,
        premium REAL,
        payment_frequency TEXT,
        payment_method TEXT,
        linked_bank_account_id TEXT,
        coverage_amount REAL,
        deductible REAL,
        additional_coverage TEXT,
        notice_period TEXT,
        auto_renewal INTEGER DEFAULT 1,
        cancellation_method TEXT,
        last_cancellation_date TEXT,
        advisor_name TEXT,
        advisor_phone TEXT,
        advisor_email TEXT,
        service_phone TEXT,
        service_email TEXT,
        website TEXT,
        claims_url TEXT,
        death_action TEXT,
        beneficiaries TEXT,
        action_required TEXT,
        death_instructions TEXT,
        notes TEXT,
        FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
      );
    ''');
    
    // PENSIONS tabel
    await db.execute('''
      CREATE TABLE pensions (
        id TEXT PRIMARY KEY,
        money_item_id TEXT NOT NULL,
        pension_type TEXT,
        provider TEXT,
        participant_number TEXT,
        participant_name TEXT,
        employer TEXT,
        accrual_period_start TEXT,
        accrual_period_end TEXT,
        current_capital REAL,
        expected_monthly_payout REAL,
        pension_start_date TEXT,
        has_partner_pension INTEGER DEFAULT 0,
        partner_pension_percentage REAL,
        partner_name TEXT,
        has_orphan_pension INTEGER DEFAULT 0,
        has_disability_pension INTEGER DEFAULT 0,
        monthly_contribution REAL,
        paid_by TEXT,
        tax_treatment TEXT,
        allows_extra_contributions INTEGER DEFAULT 0,
        has_survivor_pension INTEGER DEFAULT 0,
        survivor_payout_amount REAL,
        survivor_conditions TEXT,
        surrender_value REAL,
        claim_contact_person TEXT,
        claim_contact_phone TEXT,
        claim_contact_email TEXT,
        survivor_instructions TEXT,
        service_phone TEXT,
        service_email TEXT,
        website TEXT,
        portal_url TEXT,
        notes TEXT,
        FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
      );
    ''');
    
    // INCOMES tabel
    await db.execute('''
      CREATE TABLE incomes (
        id TEXT PRIMARY KEY,
        money_item_id TEXT NOT NULL,
        income_type TEXT,
        source TEXT,
        gross_amount REAL,
        net_amount REAL,
        frequency TEXT,
        start_date TEXT,
        end_date TEXT,
        notes TEXT,
        FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
      );
    ''');
    
    // EXPENSES tabel
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        money_item_id TEXT NOT NULL,
        expense_type TEXT,
        creditor TEXT,
        payee TEXT,
        amount REAL,
        frequency TEXT,
        due_date TEXT,
        auto_payment INTEGER DEFAULT 0,
        linked_bank_account_id TEXT,
        notes TEXT,
        FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
      );
    ''');
    
    // DEBTS tabel
    await db.execute('''
      CREATE TABLE debts (
        id TEXT PRIMARY KEY,
        money_item_id TEXT NOT NULL,
        debt_type TEXT,
        creditor TEXT,
        original_amount REAL,
        current_amount REAL,
        interest_rate REAL,
        monthly_payment REAL,
        start_date TEXT,
        end_date TEXT,
        collateral TEXT,
        notes TEXT,
        FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
      );
    ''');
    
    // MONEY_DOCUMENTS tabel
    await db.execute('''
      CREATE TABLE money_documents (
        id TEXT PRIMARY KEY,
        money_item_id TEXT NOT NULL,
        title TEXT NOT NULL,
        document_type TEXT,
        file_path TEXT,
        physical_location TEXT,
        document_date TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
      );
    ''');
    
    // DIRECT_DEBITS tabel
    await db.execute('''
      CREATE TABLE direct_debits (
        id TEXT PRIMARY KEY,
        bank_account_id TEXT NOT NULL,
        description TEXT NOT NULL,
        amount REAL,
        frequency TEXT,
        beneficiary TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (bank_account_id) REFERENCES bank_accounts(id) ON DELETE CASCADE
      );
    ''');
    
    // Indexes voor money tabellen
    await db.execute('CREATE INDEX idx_money_items_dossier ON money_items(dossier_id);');
    await db.execute('CREATE INDEX idx_money_items_person ON money_items(person_id);');
    await db.execute('CREATE INDEX idx_money_items_category ON money_items(category);');
    await db.execute('CREATE INDEX idx_bank_accounts_item ON bank_accounts(money_item_id);');
    await db.execute('CREATE INDEX idx_insurances_item ON insurances(money_item_id);');
    await db.execute('CREATE INDEX idx_pensions_item ON pensions(money_item_id);');
    await db.execute('CREATE INDEX idx_incomes_item ON incomes(money_item_id);');
    await db.execute('CREATE INDEX idx_expenses_item ON expenses(money_item_id);');
    await db.execute('CREATE INDEX idx_debts_item ON debts(money_item_id);');
    await db.execute('CREATE INDEX idx_money_docs_item ON money_documents(money_item_id);');
    await db.execute('CREATE INDEX idx_direct_debits_account ON direct_debits(bank_account_id);');
    
    // ============== HOUSING MODULE TABELLEN ==============
    await _createHousingTables(db);
    
    // ============== ASSETS MODULE TABELLEN ==============
    await _createAssetsTables(db);
    
    // ============== SUBSCRIPTIONS MODULE TABELLEN ==============
    await _createSubscriptionsTables(db);
  }
  
  /// Housing tabellen aanmaken
  Future<void> _createHousingTables(Database db) async {
    // PROPERTIES tabel
    await db.execute('''
      CREATE TABLE IF NOT EXISTS properties (
        id TEXT PRIMARY KEY,
        dossier_id TEXT NOT NULL,
        person_id TEXT NOT NULL,
        name TEXT,
        street TEXT,
        house_number TEXT,
        postal_code TEXT,
        city TEXT,
        country TEXT DEFAULT 'Nederland',
        property_type TEXT DEFAULT 'singleFamily',
        ownership_type TEXT DEFAULT 'owned',
        build_year INTEGER,
        living_area REAL,
        plot_area REAL,
        rooms INTEGER,
        bedrooms INTEGER,
        energy_label TEXT,
        is_monument INTEGER DEFAULT 0,
        cadastral_municipality TEXT,
        cadastral_section TEXT,
        cadastral_number TEXT,
        cadastral_full_number TEXT,
        cadastral_url TEXT,
        woz_value REAL,
        woz_reference_date TEXT,
        taxation_value REAL,
        taxation_date TEXT,
        owner_ids TEXT,
        ownership_ratio TEXT,
        has_marriage_contract INTEGER DEFAULT 0,
        has_cohabitation_contract INTEGER DEFAULT 0,
        will_reference TEXT,
        heirs_description TEXT,
        ozb_amount REAL,
        ozb_payment_method TEXT,
        ozb_bank_account_id TEXT,
        water_board_name TEXT,
        water_board_amount REAL,
        leasehold_amount REAL,
        leasehold_end_date TEXT,
        vve_name TEXT,
        vve_monthly_contribution REAL,
        vve_contact_name TEXT,
        vve_contact_phone TEXT,
        vve_contact_email TEXT,
        home_insurance_id TEXT,
        contents_insurance_id TEXT,
        building_insurance_id TEXT,
        liability_insurance_id TEXT,
        death_action TEXT,
        death_instructions TEXT,
        number_of_keys INTEGER,
        spare_key_location TEXT,
        alarm_code_location TEXT,
        mortgage_deed_location TEXT,
        purchase_deed_location TEXT,
        building_permits_location TEXT,
        blueprints_location TEXT,
        warranty_location TEXT,
        electrical_schema_location TEXT,
        plumbing_schema_location TEXT,
        notes TEXT,
        status TEXT DEFAULT 'notStarted',
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
      );
    ''');
    
    // MORTGAGES tabel
    await db.execute('''
      CREATE TABLE IF NOT EXISTS mortgages (
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        provider TEXT,
        mortgage_type TEXT,
        original_amount REAL,
        current_amount REAL,
        interest_rate REAL,
        interest_type TEXT,
        monthly_payment REAL,
        start_date TEXT,
        end_date TEXT,
        nhg INTEGER DEFAULT 0,
        notes TEXT,
        status TEXT DEFAULT 'notStarted',
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
      );
    ''');
    
    // ENERGY_CONTRACTS tabel
    await db.execute('''
      CREATE TABLE IF NOT EXISTS energy_contracts (
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        energy_type TEXT,
        provider TEXT,
        contract_type TEXT,
        start_date TEXT,
        end_date TEXT,
        monthly_amount REAL,
        notes TEXT,
        status TEXT DEFAULT 'notStarted',
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
      );
    ''');
    
    // INSTALLATIONS tabel
    await db.execute('''
      CREATE TABLE IF NOT EXISTS installations (
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        installation_type TEXT,
        brand TEXT,
        model TEXT,
        installation_date TEXT,
        warranty_end_date TEXT,
        maintenance_company TEXT,
        maintenance_phone TEXT,
        notes TEXT,
        status TEXT DEFAULT 'notStarted',
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
      );
    ''');
    
    // RENTAL_CONTRACTS tabel
    await db.execute('''
      CREATE TABLE IF NOT EXISTS rental_contracts (
        id TEXT PRIMARY KEY,
        property_id TEXT NOT NULL,
        landlord_name TEXT,
        landlord_phone TEXT,
        landlord_email TEXT,
        monthly_rent REAL,
        deposit REAL,
        start_date TEXT,
        end_date TEXT,
        notice_period_months INTEGER,
        notes TEXT,
        status TEXT DEFAULT 'notStarted',
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (property_id) REFERENCES properties(id) ON DELETE CASCADE
      );
    ''');
    
    // Indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_properties_dossier ON properties(dossier_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_mortgages_property ON mortgages(property_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_energy_property ON energy_contracts(property_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_installations_property ON installations(property_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_rental_property ON rental_contracts(property_id);');
  }
  
  /// Assets tabellen aanmaken
  Future<void> _createAssetsTables(Database db) async {
    // ASSETS tabel
    await db.execute('''
      CREATE TABLE IF NOT EXISTS assets (
        id TEXT PRIMARY KEY,
        dossier_id TEXT NOT NULL,
        person_id TEXT NOT NULL,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        sub_type TEXT,
        brand TEXT,
        model TEXT,
        year INTEGER,
        serial_number TEXT,
        condition TEXT,
        color TEXT,
        material TEXT,
        main_photo_path TEXT,
        additional_photos TEXT,
        purchase_date TEXT,
        purchased_from TEXT,
        purchase_price REAL,
        purchase_proof_path TEXT,
        payment_method TEXT,
        origin TEXT,
        origin_person_name TEXT,
        origin_date TEXT,
        current_value REAL,
        valuation_basis TEXT,
        last_valuation_date TEXT,
        appraiser_name TEXT,
        appraisal_date TEXT,
        appraised_value REAL,
        appraisal_report_path TEXT,
        appraisal_purpose TEXT,
        is_insured INTEGER DEFAULT 0,
        insurance_type TEXT,
        insurer_name TEXT,
        policy_number TEXT,
        insured_amount REAL,
        linked_insurance_id TEXT,
        insurance_photos_path TEXT,
        location_type TEXT,
        location_details TEXT,
        specific_location TEXT,
        location_photo_path TEXT,
        accessibility TEXT,
        key_location TEXT,
        code_location TEXT,
        access_via_person_name TEXT,
        alternative_locations TEXT,
        has_warranty INTEGER DEFAULT 0,
        warranty_years INTEGER,
        warranty_expiry_date TEXT,
        warranty_proof_path TEXT,
        warranty_provider TEXT,
        maintenance_history TEXT,
        maintenance_interval_months INTEGER,
        last_maintenance_date TEXT,
        next_maintenance_date TEXT,
        maintenance_reminder INTEGER DEFAULT 0,
        has_heir INTEGER DEFAULT 0,
        inheritance_destination TEXT,
        heir_person_id TEXT,
        heir_person_name TEXT,
        inheritance_reason TEXT,
        sentimental_value TEXT,
        mentioned_in_will INTEGER DEFAULT 0,
        heir_instructions TEXT,
        selling_suggestions TEXT,
        estimated_selling_price REAL,
        estimated_selling_time TEXT,
        authenticity TEXT,
        has_certificate_of_authenticity INTEGER DEFAULT 0,
        certificate_path TEXT,
        has_provenance INTEGER DEFAULT 0,
        provenance_path TEXT,
        expert_name TEXT,
        registration_number TEXT,
        specifications_json TEXT,
        maintenance_company TEXT,
        maintenance_phone TEXT,
        maintenance_email TEXT,
        maintenance_website TEXT,
        maintenance_address TEXT,
        dealer_company TEXT,
        dealer_contact TEXT,
        dealer_phone TEXT,
        auction_accounts TEXT,
        story TEXT,
        special_memories TEXT,
        why_valuable TEXT,
        notes TEXT,
        status TEXT DEFAULT 'notStarted',
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
      );
    ''');
    
    // ASSET_DOCUMENTS tabel
    await db.execute('''
      CREATE TABLE IF NOT EXISTS asset_documents (
        id TEXT PRIMARY KEY,
        asset_id TEXT NOT NULL,
        title TEXT NOT NULL,
        document_type TEXT,
        file_path TEXT,
        physical_location TEXT,
        document_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (asset_id) REFERENCES assets(id) ON DELETE CASCADE
      );
    ''');
    
    // Indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_assets_dossier ON assets(dossier_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_assets_person ON assets(person_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_assets_category ON assets(category);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_asset_docs ON asset_documents(asset_id);');
  }
  
  /// Subscriptions tabellen aanmaken
  Future<void> _createSubscriptionsTables(Database db) async {
    // SUBSCRIPTIONS tabel
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subscriptions (
        id TEXT PRIMARY KEY,
        dossier_id TEXT NOT NULL,
        person_id TEXT,
        name TEXT NOT NULL,
        provider TEXT,
        category TEXT NOT NULL,
        subscription_type TEXT DEFAULT 'digitalService',
        account_number TEXT,
        start_date TEXT,
        status TEXT DEFAULT 'active',
        cost REAL,
        payment_frequency TEXT DEFAULT 'monthly',
        payment_method TEXT DEFAULT 'directDebit',
        linked_bank_account_id TEXT,
        credit_card_last4 TEXT,
        payment_day INTEGER,
        last_payment_date TEXT,
        next_payment_date TEXT,
        contract_type TEXT DEFAULT 'ongoing',
        min_term_months INTEGER,
        min_term_end_date TEXT,
        contract_end_date TEXT,
        auto_renewal INTEGER DEFAULT 1,
        renewal_months INTEGER,
        had_trial_period INTEGER DEFAULT 0,
        trial_end_date TEXT,
        notice_period_days INTEGER,
        last_cancellation_date TEXT,
        cancellation_method TEXT,
        cancellation_email TEXT,
        cancellation_url TEXT,
        cancellation_address TEXT,
        cancellation_phone TEXT,
        cancellation_confirmation_required INTEGER DEFAULT 0,
        early_cancellation_fee REAL,
        cancellation_conditions TEXT,
        website_url TEXT,
        credentials_location TEXT,
        credentials_location_detail TEXT,
        username TEXT,
        account_type TEXT,
        shared_with TEXT,
        has_2fa INTEGER DEFAULT 0,
        two_factor_method TEXT,
        package_name TEXT,
        max_screens INTEGER,
        max_resolution TEXT,
        max_profiles INTEGER,
        location_name TEXT,
        location_address TEXT,
        opening_hours TEXT,
        member_number TEXT,
        membership_type TEXT,
        benefits TEXT,
        death_action TEXT DEFAULT 'cancelImmediately',
        cancellation_priority TEXT DEFAULT 'normal',
        refund_possible INTEGER DEFAULT 0,
        survivor_instructions TEXT,
        service_phone TEXT,
        service_email TEXT,
        service_website TEXT,
        service_hours TEXT,
        account_url TEXT,
        cancellation_page_url TEXT,
        has_discount INTEGER DEFAULT 0,
        discount_type TEXT,
        discount_percentage REAL,
        normal_price REAL,
        discount_price REAL,
        discount_end_date TEXT,
        promo_code TEXT,
        notes TEXT,
        item_status TEXT DEFAULT 'notStarted',
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
      );
    ''');
    
    // SUBSCRIPTION_DOCUMENTS tabel
    await db.execute('''
      CREATE TABLE IF NOT EXISTS subscription_documents (
        id TEXT PRIMARY KEY,
        subscription_id TEXT NOT NULL,
        title TEXT NOT NULL,
        document_type TEXT,
        file_path TEXT,
        physical_location TEXT,
        document_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE
      );
    ''');
    
    // Indexes
    await db.execute('CREATE INDEX IF NOT EXISTS idx_subscriptions_dossier ON subscriptions(dossier_id);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_subscriptions_category ON subscriptions(category);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_subscription_docs ON subscription_documents(subscription_id);');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('🔄 Database upgrade: v$oldVersion → v$newVersion');

    if (oldVersion < 2) {
      print('📊 Upgrading to version 2...');
      
      await db.execute('''
        CREATE TABLE dossiers (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          icon TEXT,
          color TEXT,
          is_active INTEGER NOT NULL DEFAULT 1,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        );
      ''');

      await db.execute('ALTER TABLE persons ADD COLUMN name_prefix TEXT;');
      await db.execute('ALTER TABLE persons ADD COLUMN dossier_id TEXT;');
      await db.execute('ALTER TABLE users ADD COLUMN recovery_phrase_hash TEXT;');

      final users = await db.query('users');
      for (final user in users) {
        final userId = user['id'] as String;
        final dossierId = 'dossier_${userId}_default';
        await db.insert('dossiers', {
          'id': dossierId,
          'user_id': userId,
          'name': 'Mijn Dossier',
          'description': 'Standaard dossier',
          'is_active': 1,
          'created_at': DateTime.now().millisecondsSinceEpoch,
        });
        await db.execute('UPDATE persons SET dossier_id = ? WHERE dossier_id IS NULL', [dossierId]);
      }

      await db.execute('CREATE INDEX idx_persons_dossier ON persons(dossier_id);');
      await db.execute('CREATE INDEX idx_dossiers_user ON dossiers(user_id);');
      print('🎉 Database upgrade naar v2 voltooid!');
    }
    
    if (oldVersion < 3) {
      print('👨‍👩‍👧‍👦 Upgrading to version 3...');
      
      await db.execute('''
        CREATE TABLE household_members (
          id TEXT PRIMARY KEY,
          dossier_id TEXT NOT NULL,
          person_id TEXT NOT NULL,
          relation TEXT NOT NULL,
          is_primary INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE,
          FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE,
          UNIQUE(dossier_id, person_id)
        );
      ''');
      
      await db.execute('''
        CREATE TABLE personal_documents (
          id TEXT PRIMARY KEY,
          person_id TEXT NOT NULL,
          document_type TEXT NOT NULL,
          document_number TEXT,
          issue_date TEXT,
          expiry_date TEXT,
          issuing_authority TEXT,
          document_file_path TEXT,
          physical_location TEXT,
          notes TEXT,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE
        );
      ''');
      
      await db.execute('ALTER TABLE persons ADD COLUMN bsn TEXT;');
      await db.execute('ALTER TABLE persons ADD COLUMN civil_status TEXT;');
      
      await db.execute('CREATE INDEX idx_household_dossier ON household_members(dossier_id);');
      await db.execute('CREATE INDEX idx_household_person ON household_members(person_id);');
      await db.execute('CREATE INDEX idx_documents_person ON personal_documents(person_id);');
      
      print('🎉 Database upgrade naar v3 voltooid!');
    }
    
    if (oldVersion < 4) {
      print('📇 Upgrading to version 4: Contacten in persons tabel...');
      
      // Contact-velden toevoegen aan persons tabel
      await db.execute('ALTER TABLE persons ADD COLUMN is_contact INTEGER NOT NULL DEFAULT 0;');
      await db.execute('ALTER TABLE persons ADD COLUMN contact_category TEXT;');
      await db.execute('ALTER TABLE persons ADD COLUMN for_christmas_card INTEGER NOT NULL DEFAULT 0;');
      await db.execute('ALTER TABLE persons ADD COLUMN for_newsletter INTEGER NOT NULL DEFAULT 0;');
      await db.execute('ALTER TABLE persons ADD COLUMN for_party INTEGER NOT NULL DEFAULT 0;');
      await db.execute('ALTER TABLE persons ADD COLUMN for_funeral INTEGER NOT NULL DEFAULT 0;');
      print('✅ Persons tabel uitgebreid met contact-velden');
      
      // Index voor contacten
      await db.execute('CREATE INDEX idx_persons_contact ON persons(is_contact);');
      print('✅ Contact index aangemaakt');
      
      print('🎉 Database upgrade naar v4 voltooid!');
    }
    
    if (oldVersion < 5) {
      print('📧 Upgrading to version 5: Email templates...');
      
      // Email templates tabel
      await db.execute('''
        CREATE TABLE email_templates (
          id TEXT PRIMARY KEY,
          dossier_id TEXT NOT NULL,
          name TEXT NOT NULL,
          subject TEXT,
          body TEXT,
          mailing_type TEXT,
          is_default INTEGER NOT NULL DEFAULT 0,
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
        );
      ''');
      
      // Index voor templates
      await db.execute('CREATE INDEX idx_templates_dossier ON email_templates(dossier_id);');
      await db.execute('CREATE INDEX idx_templates_type ON email_templates(mailing_type);');
      
      print('🎉 Database upgrade naar v5 voltooid!');
    }
    
    if (oldVersion < 6) {
      print('📋 Upgrading to version 6: Mailing lijsten...');
      
      // Mailing lijsten tabel
      await db.execute('''
        CREATE TABLE mailing_lists (
          id TEXT PRIMARY KEY,
          dossier_id TEXT NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          contact_ids TEXT,
          mailing_type TEXT,
          emoji TEXT DEFAULT '📋',
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE
        );
      ''');
      
      // Index voor lijsten
      await db.execute('CREATE INDEX idx_mailing_lists_dossier ON mailing_lists(dossier_id);');
      
      print('🎉 Database upgrade naar v6 voltooid!');
    }
    
    if (oldVersion < 7) {
      print('📋 Upgrading to version 7: Meerdere categorieën per contact...');
      
      // Voeg nieuwe 'categories' kolom toe
      await db.execute('ALTER TABLE persons ADD COLUMN categories TEXT;');
      
      // Migreer bestaande data: kopieer contact_category naar categories
      await db.execute('''
        UPDATE persons 
        SET categories = contact_category 
        WHERE contact_category IS NOT NULL AND contact_category != ''
      ''');
      
      print('🎉 Database upgrade naar v7 voltooid!');
      print('   → Bestaande categorieën gemigreerd naar nieuwe structuur');
    }
    
    if (oldVersion < 8) {
      print('📋 Upgrading to version 8: created_at kolom + schema cleanup...');
      
      // Voeg created_at kolom toe aan persons
      await db.execute('ALTER TABLE persons ADD COLUMN created_at INTEGER;');
      
      // Voeg contact_categories kolom toe (hernoemd van categories)
      try {
        await db.execute('ALTER TABLE persons ADD COLUMN contact_categories TEXT;');
        // Kopieer bestaande categories data
        await db.execute('''
          UPDATE persons 
          SET contact_categories = categories 
          WHERE categories IS NOT NULL AND categories != ''
        ''');
      } catch (e) {
        print('   contact_categories kolom bestaat mogelijk al: $e');
      }
      
      print('🎉 Database upgrade naar v8 voltooid!');
    }
    
    if (oldVersion < 9) {
      print('💰 Upgrading to version 9: Money items en gerelateerde tabellen...');
      
      // MONEY_ITEMS tabel (centrale tabel voor alle geldzaken)
      await db.execute('''
        CREATE TABLE money_items (
          id TEXT PRIMARY KEY,
          dossier_id TEXT NOT NULL,
          person_id TEXT NOT NULL,
          category TEXT NOT NULL,
          type TEXT NOT NULL,
          name TEXT,
          status TEXT DEFAULT 'not_started',
          created_at INTEGER NOT NULL,
          updated_at INTEGER,
          FOREIGN KEY (dossier_id) REFERENCES dossiers(id) ON DELETE CASCADE,
          FOREIGN KEY (person_id) REFERENCES persons(id) ON DELETE CASCADE
        );
      ''');
      
      // BANK_ACCOUNTS tabel
      await db.execute('''
        CREATE TABLE bank_accounts (
          id TEXT PRIMARY KEY,
          money_item_id TEXT NOT NULL,
          bank_name TEXT NOT NULL,
          account_type TEXT,
          iban TEXT,
          account_holder TEXT,
          balance REAL,
          notes TEXT,
          FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
        );
      ''');
      
      // INSURANCES tabel
      await db.execute('''
        CREATE TABLE insurances (
          id TEXT PRIMARY KEY,
          money_item_id TEXT NOT NULL,
          company TEXT,
          insurance_type TEXT,
          policy_number TEXT,
          insured_person_id TEXT,
          co_insured TEXT,
          start_date TEXT,
          end_date TEXT,
          duration TEXT,
          premium REAL,
          payment_frequency TEXT,
          payment_method TEXT,
          linked_bank_account_id TEXT,
          coverage_amount REAL,
          deductible REAL,
          additional_coverage TEXT,
          notice_period TEXT,
          auto_renewal INTEGER DEFAULT 1,
          cancellation_method TEXT,
          last_cancellation_date TEXT,
          advisor_name TEXT,
          advisor_phone TEXT,
          advisor_email TEXT,
          service_phone TEXT,
          service_email TEXT,
          website TEXT,
          claims_url TEXT,
          death_action TEXT,
          beneficiaries TEXT,
          action_required TEXT,
          death_instructions TEXT,
          notes TEXT,
          FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
        );
      ''');
      
      // PENSIONS tabel
      await db.execute('''
        CREATE TABLE pensions (
          id TEXT PRIMARY KEY,
          money_item_id TEXT NOT NULL,
          pension_type TEXT,
          provider TEXT,
          participant_number TEXT,
          participant_name TEXT,
          employer TEXT,
          accrual_period_start TEXT,
          accrual_period_end TEXT,
          current_capital REAL,
          expected_monthly_payout REAL,
          pension_start_date TEXT,
          has_partner_pension INTEGER DEFAULT 0,
          partner_pension_percentage REAL,
          partner_name TEXT,
          has_orphan_pension INTEGER DEFAULT 0,
          has_disability_pension INTEGER DEFAULT 0,
          monthly_contribution REAL,
          paid_by TEXT,
          tax_treatment TEXT,
          allows_extra_contributions INTEGER DEFAULT 0,
          has_survivor_pension INTEGER DEFAULT 0,
          survivor_payout_amount REAL,
          survivor_conditions TEXT,
          surrender_value REAL,
          claim_contact_person TEXT,
          claim_contact_phone TEXT,
          claim_contact_email TEXT,
          survivor_instructions TEXT,
          service_phone TEXT,
          service_email TEXT,
          website TEXT,
          portal_url TEXT,
          notes TEXT,
          FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
        );
      ''');
      
      // INCOMES tabel
      await db.execute('''
        CREATE TABLE incomes (
          id TEXT PRIMARY KEY,
          money_item_id TEXT NOT NULL,
          income_type TEXT,
          source TEXT,
          gross_amount REAL,
          net_amount REAL,
          frequency TEXT,
          start_date TEXT,
          end_date TEXT,
          notes TEXT,
          FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
        );
      ''');
      
      // EXPENSES tabel
      await db.execute('''
        CREATE TABLE expenses (
          id TEXT PRIMARY KEY,
          money_item_id TEXT NOT NULL,
          expense_type TEXT,
          creditor TEXT,
          payee TEXT,
          amount REAL,
          frequency TEXT,
          due_date TEXT,
          auto_payment INTEGER DEFAULT 0,
          linked_bank_account_id TEXT,
          notes TEXT,
          FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
        );
      ''');
      
      // DEBTS tabel
      await db.execute('''
        CREATE TABLE debts (
          id TEXT PRIMARY KEY,
          money_item_id TEXT NOT NULL,
          debt_type TEXT,
          creditor TEXT,
          original_amount REAL,
          current_amount REAL,
          interest_rate REAL,
          monthly_payment REAL,
          start_date TEXT,
          end_date TEXT,
          collateral TEXT,
          notes TEXT,
          FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
        );
      ''');
      
      // MONEY_DOCUMENTS tabel
      await db.execute('''
        CREATE TABLE money_documents (
          id TEXT PRIMARY KEY,
          money_item_id TEXT NOT NULL,
          title TEXT NOT NULL,
          document_type TEXT,
          file_path TEXT,
          physical_location TEXT,
          document_date TEXT,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (money_item_id) REFERENCES money_items(id) ON DELETE CASCADE
        );
      ''');
      
      // DIRECT_DEBITS tabel
      await db.execute('''
        CREATE TABLE direct_debits (
          id TEXT PRIMARY KEY,
          bank_account_id TEXT NOT NULL,
          description TEXT NOT NULL,
          amount REAL,
          frequency TEXT,
          beneficiary TEXT,
          created_at INTEGER NOT NULL,
          FOREIGN KEY (bank_account_id) REFERENCES bank_accounts(id) ON DELETE CASCADE
        );
      ''');
      
      // Indexes voor money tabellen
      await db.execute('CREATE INDEX idx_money_items_dossier ON money_items(dossier_id);');
      await db.execute('CREATE INDEX idx_money_items_person ON money_items(person_id);');
      await db.execute('CREATE INDEX idx_money_items_category ON money_items(category);');
      await db.execute('CREATE INDEX idx_bank_accounts_item ON bank_accounts(money_item_id);');
      await db.execute('CREATE INDEX idx_insurances_item ON insurances(money_item_id);');
      await db.execute('CREATE INDEX idx_pensions_item ON pensions(money_item_id);');
      await db.execute('CREATE INDEX idx_incomes_item ON incomes(money_item_id);');
      await db.execute('CREATE INDEX idx_expenses_item ON expenses(money_item_id);');
      await db.execute('CREATE INDEX idx_debts_item ON debts(money_item_id);');
      await db.execute('CREATE INDEX idx_money_docs_item ON money_documents(money_item_id);');
      await db.execute('CREATE INDEX idx_direct_debits_account ON direct_debits(bank_account_id);');
      
      print('🎉 Database upgrade naar v9 voltooid!');
      print('   → money_items, bank_accounts, insurances, pensions, incomes, expenses, debts tabellen aangemaakt');
    }
    
    if (oldVersion < 10) {
      print('🏠📦📋 Upgrading to version 10: Housing, Assets, Subscriptions tabellen...');
      
      // Housing tabellen
      await _createHousingTables(db);
      print('   ✅ Housing tabellen aangemaakt');
      
      // Assets tabellen
      await _createAssetsTables(db);
      print('   ✅ Assets tabellen aangemaakt');
      
      // Subscriptions tabellen
      await _createSubscriptionsTables(db);
      print('   ✅ Subscriptions tabellen aangemaakt');
      
      print('🎉 Database upgrade naar v10 voltooid!');
    }

    if (oldVersion < 11) {
      print('📋 Upgrading to version 11: emoji kolom voor mailing_lists...');
      
      // Voeg emoji kolom toe aan mailing_lists
      await db.execute("ALTER TABLE mailing_lists ADD COLUMN emoji TEXT DEFAULT '📋';");
      
      print('🎉 Database upgrade naar v11 voltooid!');
    }
  }

  // ---------- Helper methoden ----------

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? where,
    List<Object?>? whereArgs,
    String? orderBy,
  }) async {
    final db = await database;
    return db.query(
      table,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
    );
  }

  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = await database;
    return db.insert(
      table,
      values,
      conflictAlgorithm: conflictAlgorithm ?? ConflictAlgorithm.abort,
    );
  }

  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.update(table, values, where: where, whereArgs: whereArgs);
  }

  Future<int> delete(
    String table, {
    String? where,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;
    return db.delete(table, where: where, whereArgs: whereArgs);
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<Object?>? args]) async {
    final db = await database;
    return db.rawQuery(sql, args);
  }

  Future<int> rawUpdate(String sql, [List<Object?>? args]) async {
    final db = await database;
    return db.rawUpdate(sql, args);
  }
}
