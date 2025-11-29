# 🚀 SPRINT 1A - DOSSIERS FUNCTIONALITEIT

## ✅ WAT IS NIEUW

### 1. **Meerdere Dossiers**
- Gebruikers kunnen nu meerdere dossiers aanmaken
- Elk dossier heeft eigen personen en (later) eigen gegevens
- Use cases: "Mijn Gezin", "Ouders", "Schoonouders", etc.

### 2. **Naam Tussenvoegsels**
- Nieuw veld `namePrefix` in Person model
- Ondersteuning voor "van", "van der", "de", etc.
- Helper methods: `fullName` en `formalName`

### 3. **Volledige Tweetaligheid**
- Alle nieuwe schermen zijn volledig NL/EN
- 60+ nieuwe translation keys toegevoegd
- Bestaande schermen ge-audit en bijgewerkt

## 📦 GEWIJZIGDE BESTANDEN

### Database (BREAKING CHANGE - versie 2):
- ✅ `lib/core/app_database.dart`
  - Nieuwe tabel: `dossiers`
  - Nieuwe kolom in `persons`: `dossier_id`, `name_prefix`
  - Nieuwe kolom in `users`: `recovery_phrase_hash` (voor later)
  - Automatische migratie van bestaande data

### Nieuwe Modules:
- ✅ `lib/modules/dossier/dossier_model.dart`
- ✅ `lib/modules/dossier/dossier_repository.dart`
- ✅ `lib/modules/dossier/dossier_providers.dart`
- ✅ `lib/modules/dossier/screens/select_dossier_screen.dart`
- ✅ `lib/modules/dossier/screens/create_dossier_screen.dart`

### Aangepaste Bestanden:
- ✅ `lib/modules/person/person_model.dart` - namePrefix + dossierId
- ✅ `lib/core/person_repository.dart` - getPersonsForDossier()
- ✅ `lib/modules/auth/repository/auth_repository.dart` - maakt standaard dossier
- ✅ `lib/modules/home/home_screen.dart` - dossier selectie
- ✅ `lib/modules/person/select_person_screen.dart` - dossierId parameter
- ✅ `lib/modules/person/add_person_screen.dart` - namePrefix veld
- ✅ `lib/modules/person/edit_person_screen.dart` - namePrefix veld (moet je nog updaten)
- ✅ `lib/modules/person/person_detail_screen.dart` - fullName weergave (moet je nog updaten)

### Translations:
- ✅ `lib/l10n/app_nl.arb` - volledige update
- ✅ `lib/l10n/app_en.arb` - volledige update

## 🔧 INSTALLATIE

### Stap 1: Backup maken
```bash
# Maak backup van huidige database (optioneel maar aanbevolen)
# Database locatie: zie hieronder
```

### Stap 2: Code updaten
```bash
# Unzip sprint1a.zip in je project root
# Dit overschrijft bestaande bestanden in /lib
unzip sprint1a.zip
```

### Stap 3: Dependencies checken
```bash
flutter pub get
```

### Stap 4: Database migratie
```bash
# Bij eerste run wordt database automatisch gemigreerd van v1 naar v2
# Alle bestaande data blijft behouden!
flutter run
```

### Stap 5: Testen
1. Start app
2. Login met bestaand account OF maak nieuw account
3. Je ziet nu "Dossier Selectie" scherm
4. Voor bestaande users: er is automatisch "Mijn Dossier" aangemaakt
5. Maak een tweede dossier: "Test Dossier"
6. Voeg personen toe in beide dossiers
7. Test het wisselen tussen dossiers

## 📊 DATABASE MIGRATIE DETAILS

### Wat gebeurt er automatisch:
1. **Nieuwe tabel** `dossiers` wordt aangemaakt
2. **Voor elke bestaande user**:
   - Standaard dossier "Mijn Dossier" wordt aangemaakt
   - Alle bestaande persons worden gekoppeld aan dit dossier
3. **Nieuwe kolommen** toegevoegd:
   - `persons.name_prefix` (NULL allowed)
   - `persons.dossier_id` (NOT NULL, gekoppeld aan standaard dossier)
   - `users.recovery_phrase_hash` (NULL, voor Sprint 1B)

### Database locaties:
**Windows:**
```
C:\Users\[NAAM]\AppData\Local\life_legacy_manager\databases\life_legacy_manager.db
```

**Android Emulator:**
```
/data/data/com.yourcompany.life_legacy_manager/databases/life_legacy_manager.db
```

**macOS:**
```
~/Library/Containers/life_legacy_manager/Data/Library/Application Support/databases/
```

### Rollback (als je het ongedaan wilt maken):
```bash
# Optie 1: Verwijder database en start opnieuw
flutter clean
# Uninstall app van device/emulator
flutter run

# Optie 2: Restore backup (als je die hebt gemaakt)
```

## 🎯 NIEUWE USER FLOW

### Bij Registratie:
```
1. User vult registratieformulier in
2. Account wordt aangemaakt
3. Automatisch: "Mijn Dossier" wordt aangemaakt
4. Automatisch: User wordt als Person toegevoegd in dit dossier
5. User gaat naar PIN setup
6. Na PIN setup → Dossier Selectie scherm
7. User selecteert "Mijn Dossier"
8. User komt op Home scherm
```

### Bij Login (bestaande user):
```
1. User logt in
2. App checkt: welke dossiers heeft deze user?
3. Als 1 dossier → direct naar Home
4. Als meerdere dossiers → Dossier Selectie scherm
5. User selecteert dossier
6. Home scherm toont geselecteerd dossier
```

### Dossier Wisselen:
```
1. Op Home scherm: klik folder icoon (rechts boven)
2. Dossier Selectie scherm opent
3. Selecteer ander dossier
4. Terug naar Home met nieuw dossier
5. Alle personen/data zijn nu van het nieuwe dossier
```

## 📝 NOG TE DOEN (door jou):

### EditPersonScreen updaten:
```dart
// Voeg toe in edit_person_screen.dart:

final _namePrefixController = TextEditingController();

// In _loadPerson():
_namePrefixController.text = p.namePrefix ?? '';

// In build() tussen firstName en lastName:
TextFormField(
  controller: _namePrefixController,
  decoration: InputDecoration(
    labelText: l10n.namePrefix,
    hintText: 'bijv. van, van der, de',
    border: const OutlineInputBorder(),
  ),
),

// In _save():
namePrefix: _namePrefixController.text.trim().isEmpty 
  ? null 
  : _namePrefixController.text.trim(),
```

### PersonDetailScreen updaten:
```dart
// Gebruik person.fullName in plaats van:
// "${person.firstName} ${person.lastName}"

// Voorbeeld:
Text(person.fullName, style: ...)
```

## 🐛 TROUBLESHOOTING

### "Database is locked"
```bash
# Stop alle running instances
flutter clean
# Verwijder app van emulator
# Run opnieuw
flutter run
```

### "Column dossier_id doesn't exist"
```
Dit betekent migratie is mislukt.
Oplossing:
1. Uninstall app
2. flutter clean
3. flutter run
```

### "No dossiers found"
```
Dit zou niet moeten gebeuren, maar als het wel gebeurt:
1. Check database logs in console
2. Maak handmatig een dossier via de UI
3. Als dat niet werkt: uninstall + reinstall
```

## ✅ CHECKLIST NA INSTALLATIE

- [ ] App start zonder errors
- [ ] Database migratie succesvol (check console logs)
- [ ] Dossier Selectie scherm toont "Mijn Dossier"
- [ ] Kan nieuw dossier aanmaken
- [ ] Kan persoon toevoegen met tussenvoegsel
- [ ] Kan tussen dossiers wisselen
- [ ] Personen zijn gescheiden per dossier
- [ ] fullName toont tussenvoegsel correct
- [ ] NL/EN translations werken beide

## 🎉 VOLGENDE SPRINT

**Sprint 1B - Wachtwoord Recovery Phrase**
- 12-woorden recovery phrase bij registratie
- Recovery flow bij "wachtwoord vergeten"
- Database veld is al aanwezig (`recovery_phrase_hash`)

Klaar voor Sprint 1B? Geef een seintje! 🚀
