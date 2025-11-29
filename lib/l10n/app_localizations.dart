import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_nl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('nl')
  ];

  /// De titel van de applicatie
  ///
  /// In nl, this message translates to:
  /// **'Life & Legacy Manager'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Uw persoonlijke levenscompas'**
  String get appSubtitle;

  /// No description provided for @welcome.
  ///
  /// In nl, this message translates to:
  /// **'Welkom'**
  String get welcome;

  /// No description provided for @accountCreate.
  ///
  /// In nl, this message translates to:
  /// **'Account Aanmaken'**
  String get accountCreate;

  /// No description provided for @login.
  ///
  /// In nl, this message translates to:
  /// **'Inloggen'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In nl, this message translates to:
  /// **'Uitloggen'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In nl, this message translates to:
  /// **'Annuleren'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In nl, this message translates to:
  /// **'Opslaan'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In nl, this message translates to:
  /// **'Verwijderen'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In nl, this message translates to:
  /// **'Bewerken'**
  String get edit;

  /// No description provided for @back.
  ///
  /// In nl, this message translates to:
  /// **'Terug'**
  String get back;

  /// No description provided for @next.
  ///
  /// In nl, this message translates to:
  /// **'Volgende'**
  String get next;

  /// No description provided for @skip.
  ///
  /// In nl, this message translates to:
  /// **'Overslaan'**
  String get skip;

  /// No description provided for @done.
  ///
  /// In nl, this message translates to:
  /// **'Klaar'**
  String get done;

  /// No description provided for @close.
  ///
  /// In nl, this message translates to:
  /// **'Sluiten'**
  String get close;

  /// No description provided for @confirm.
  ///
  /// In nl, this message translates to:
  /// **'Bevestigen'**
  String get confirm;

  /// No description provided for @create.
  ///
  /// In nl, this message translates to:
  /// **'Aanmaken'**
  String get create;

  /// No description provided for @update.
  ///
  /// In nl, this message translates to:
  /// **'Bijwerken'**
  String get update;

  /// No description provided for @add.
  ///
  /// In nl, this message translates to:
  /// **'Toevoegen'**
  String get add;

  /// No description provided for @remove.
  ///
  /// In nl, this message translates to:
  /// **'Verwijderen'**
  String get remove;

  /// No description provided for @continueButton.
  ///
  /// In nl, this message translates to:
  /// **'Doorgaan'**
  String get continueButton;

  /// No description provided for @yes.
  ///
  /// In nl, this message translates to:
  /// **'Ja'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In nl, this message translates to:
  /// **'Nee'**
  String get no;

  /// No description provided for @email.
  ///
  /// In nl, this message translates to:
  /// **'E-mailadres'**
  String get email;

  /// No description provided for @password.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord'**
  String get password;

  /// No description provided for @confirmPassword.
  ///
  /// In nl, this message translates to:
  /// **'Herhaal wachtwoord'**
  String get confirmPassword;

  /// No description provided for @firstName.
  ///
  /// In nl, this message translates to:
  /// **'Voornaam'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In nl, this message translates to:
  /// **'Achternaam'**
  String get lastName;

  /// No description provided for @namePrefix.
  ///
  /// In nl, this message translates to:
  /// **'Tussenvoegsel'**
  String get namePrefix;

  /// No description provided for @birthDate.
  ///
  /// In nl, this message translates to:
  /// **'Geboortedatum'**
  String get birthDate;

  /// No description provided for @gender.
  ///
  /// In nl, this message translates to:
  /// **'Geslacht'**
  String get gender;

  /// No description provided for @phone.
  ///
  /// In nl, this message translates to:
  /// **'Telefoonnummer'**
  String get phone;

  /// No description provided for @address.
  ///
  /// In nl, this message translates to:
  /// **'Adres'**
  String get address;

  /// No description provided for @postalCode.
  ///
  /// In nl, this message translates to:
  /// **'Postcode'**
  String get postalCode;

  /// No description provided for @city.
  ///
  /// In nl, this message translates to:
  /// **'Plaats'**
  String get city;

  /// No description provided for @description.
  ///
  /// In nl, this message translates to:
  /// **'Omschrijving'**
  String get description;

  /// No description provided for @name.
  ///
  /// In nl, this message translates to:
  /// **'Naam'**
  String get name;

  /// No description provided for @genderMale.
  ///
  /// In nl, this message translates to:
  /// **'Man'**
  String get genderMale;

  /// No description provided for @genderFemale.
  ///
  /// In nl, this message translates to:
  /// **'Vrouw'**
  String get genderFemale;

  /// No description provided for @genderOther.
  ///
  /// In nl, this message translates to:
  /// **'Anders'**
  String get genderOther;

  /// No description provided for @genderUnknown.
  ///
  /// In nl, this message translates to:
  /// **'Onbekend'**
  String get genderUnknown;

  /// No description provided for @genderNonBinary.
  ///
  /// In nl, this message translates to:
  /// **'Non-binair'**
  String get genderNonBinary;

  /// No description provided for @welcomeTitle.
  ///
  /// In nl, this message translates to:
  /// **'Life & Legacy Manager'**
  String get welcomeTitle;

  /// No description provided for @welcomeIntroTitle.
  ///
  /// In nl, this message translates to:
  /// **'Welkom'**
  String get welcomeIntroTitle;

  /// No description provided for @welcomeIntroText.
  ///
  /// In nl, this message translates to:
  /// **'In het leven verzamelen we belangrijke documenten, contracten, en informatie. Van bankrekeningen tot verzekeringen, van energiecontracten tot persoonlijke wensen. Maar waar bewaar je dit allemaal? En wat als je nabestaanden deze informatie nodig hebben?'**
  String get welcomeIntroText;

  /// No description provided for @welcomeIntroText2.
  ///
  /// In nl, this message translates to:
  /// **'Life & Legacy Manager is uw persoonlijke levenscompas. Een veilige, overzichtelijke plek waar u alle belangrijke informatie verzamelt, beheert en toegankelijk maakt voor uzelf en uw naasten.'**
  String get welcomeIntroText2;

  /// No description provided for @welcomeWhatToExpect.
  ///
  /// In nl, this message translates to:
  /// **'Wat kunt u verwachten?'**
  String get welcomeWhatToExpect;

  /// No description provided for @welcomeFooter1.
  ///
  /// In nl, this message translates to:
  /// **'Begin vandaag met het organiseren van uw levensinformatie'**
  String get welcomeFooter1;

  /// No description provided for @welcomeFooter2.
  ///
  /// In nl, this message translates to:
  /// **'Rust en zekerheid voor u en uw naasten'**
  String get welcomeFooter2;

  /// No description provided for @featurePrivacyTitle.
  ///
  /// In nl, this message translates to:
  /// **'Volledig Privé'**
  String get featurePrivacyTitle;

  /// No description provided for @featurePrivacyDesc.
  ///
  /// In nl, this message translates to:
  /// **'Al uw gegevens blijven lokaal op uw apparaat opgeslagen'**
  String get featurePrivacyDesc;

  /// No description provided for @featureOverviewTitle.
  ///
  /// In nl, this message translates to:
  /// **'Overzichtelijk'**
  String get featureOverviewTitle;

  /// No description provided for @featureOverviewDesc.
  ///
  /// In nl, this message translates to:
  /// **'Gestructureerd per thema: geldzaken, huis, juridisch, en meer'**
  String get featureOverviewDesc;

  /// No description provided for @featureFamilyTitle.
  ///
  /// In nl, this message translates to:
  /// **'Voor Nabestaanden'**
  String get featureFamilyTitle;

  /// No description provided for @featureFamilyDesc.
  ///
  /// In nl, this message translates to:
  /// **'Alles wat ze moeten weten, op één plek toegankelijk'**
  String get featureFamilyDesc;

  /// No description provided for @featureDocumentsTitle.
  ///
  /// In nl, this message translates to:
  /// **'Documentbeheer'**
  String get featureDocumentsTitle;

  /// No description provided for @featureDocumentsDesc.
  ///
  /// In nl, this message translates to:
  /// **'Voeg documenten toe of noteer waar ze bewaard zijn'**
  String get featureDocumentsDesc;

  /// No description provided for @featureProgressTitle.
  ///
  /// In nl, this message translates to:
  /// **'Voortgang Bijhouden'**
  String get featureProgressTitle;

  /// No description provided for @featureProgressDesc.
  ///
  /// In nl, this message translates to:
  /// **'Zie in één oogopslag welke onderdelen compleet zijn'**
  String get featureProgressDesc;

  /// No description provided for @featureSecurityTitle.
  ///
  /// In nl, this message translates to:
  /// **'Veilig Bewaard'**
  String get featureSecurityTitle;

  /// No description provided for @featureSecurityDesc.
  ///
  /// In nl, this message translates to:
  /// **'Beveiligd met wachtwoord, pincode of biometrie'**
  String get featureSecurityDesc;

  /// No description provided for @registerTitle.
  ///
  /// In nl, this message translates to:
  /// **'Account aanmaken'**
  String get registerTitle;

  /// No description provided for @registerButton.
  ///
  /// In nl, this message translates to:
  /// **'Account aanmaken'**
  String get registerButton;

  /// No description provided for @registerSelectDate.
  ///
  /// In nl, this message translates to:
  /// **'Selecteer datum'**
  String get registerSelectDate;

  /// No description provided for @registerDateFormat.
  ///
  /// In nl, this message translates to:
  /// **'{day}-{month}-{year}'**
  String registerDateFormat(Object day, Object month, Object year);

  /// No description provided for @registerSuccess.
  ///
  /// In nl, this message translates to:
  /// **'Account succesvol aangemaakt'**
  String get registerSuccess;

  /// No description provided for @registerFailed.
  ///
  /// In nl, this message translates to:
  /// **'Registratie mislukt'**
  String get registerFailed;

  /// No description provided for @registerSelectBirthDate.
  ///
  /// In nl, this message translates to:
  /// **'Selecteer een geboortedatum'**
  String get registerSelectBirthDate;

  /// No description provided for @loginTitle.
  ///
  /// In nl, this message translates to:
  /// **'Inloggen'**
  String get loginTitle;

  /// No description provided for @loginButton.
  ///
  /// In nl, this message translates to:
  /// **'Inloggen'**
  String get loginButton;

  /// No description provided for @loginForgotPassword.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord vergeten?'**
  String get loginForgotPassword;

  /// No description provided for @loginNoAccount.
  ///
  /// In nl, this message translates to:
  /// **'Nog geen account?'**
  String get loginNoAccount;

  /// No description provided for @loginFailed.
  ///
  /// In nl, this message translates to:
  /// **'Inloggen mislukt. Controleer uw gegevens.'**
  String get loginFailed;

  /// No description provided for @pinSetupTitle.
  ///
  /// In nl, this message translates to:
  /// **'Snel Inloggen'**
  String get pinSetupTitle;

  /// No description provided for @pinSetupSubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Stel een pincode in om voortaan snel en gemakkelijk in te loggen zonder uw volledige wachtwoord te typen.'**
  String get pinSetupSubtitle;

  /// No description provided for @pinChooseTitle.
  ///
  /// In nl, this message translates to:
  /// **'Kies uw pincode'**
  String get pinChooseTitle;

  /// No description provided for @pinChooseSubtitle.
  ///
  /// In nl, this message translates to:
  /// **'4 tot 8 cijfers'**
  String get pinChooseSubtitle;

  /// No description provided for @pinNew.
  ///
  /// In nl, this message translates to:
  /// **'Nieuwe PIN'**
  String get pinNew;

  /// No description provided for @pinNewHint.
  ///
  /// In nl, this message translates to:
  /// **'Voer 4-8 cijfers in'**
  String get pinNewHint;

  /// No description provided for @pinConfirm.
  ///
  /// In nl, this message translates to:
  /// **'Herhaal PIN'**
  String get pinConfirm;

  /// No description provided for @pinConfirmHint.
  ///
  /// In nl, this message translates to:
  /// **'Voer dezelfde PIN nogmaals in'**
  String get pinConfirmHint;

  /// No description provided for @pinSetup.
  ///
  /// In nl, this message translates to:
  /// **'PIN Instellen'**
  String get pinSetup;

  /// No description provided for @pinSetupInProgress.
  ///
  /// In nl, this message translates to:
  /// **'Bezig met opslaan...'**
  String get pinSetupInProgress;

  /// No description provided for @pinSkipLater.
  ///
  /// In nl, this message translates to:
  /// **'Nu niet, later instellen'**
  String get pinSkipLater;

  /// No description provided for @pinSkipTitle.
  ///
  /// In nl, this message translates to:
  /// **'PIN overslaan'**
  String get pinSkipTitle;

  /// No description provided for @pinSkipMessage.
  ///
  /// In nl, this message translates to:
  /// **'Weet u zeker dat u geen PIN wilt instellen? U kunt dit later alsnog doen via instellingen.\n\nZonder PIN moet u steeds uw volledige wachtwoord invoeren.'**
  String get pinSkipMessage;

  /// No description provided for @pinTipsTitle.
  ///
  /// In nl, this message translates to:
  /// **'Tips voor een veilige PIN'**
  String get pinTipsTitle;

  /// No description provided for @pinTip1.
  ///
  /// In nl, this message translates to:
  /// **'Gebruik geen voor de hand liggende cijfers zoals 1234 of uw geboortejaar'**
  String get pinTip1;

  /// No description provided for @pinTip2.
  ///
  /// In nl, this message translates to:
  /// **'Vertel uw PIN niet aan anderen'**
  String get pinTip2;

  /// No description provided for @pinTip3.
  ///
  /// In nl, this message translates to:
  /// **'U kunt de PIN later wijzigen via instellingen'**
  String get pinTip3;

  /// No description provided for @pinBiometricAvailable.
  ///
  /// In nl, this message translates to:
  /// **'Biometrische beveiliging beschikbaar! Na het instellen van de PIN kunt u ook vingerafdruk/gezichtsherkenning activeren.'**
  String get pinBiometricAvailable;

  /// No description provided for @pinBiometricTitle.
  ///
  /// In nl, this message translates to:
  /// **'Biometrische beveiliging'**
  String get pinBiometricTitle;

  /// No description provided for @pinBiometricMessage.
  ///
  /// In nl, this message translates to:
  /// **'Uw apparaat ondersteunt vingerafdruk of gezichtsherkenning. Wilt u dit ook activeren voor snelle toegang?'**
  String get pinBiometricMessage;

  /// No description provided for @pinBiometricNotNow.
  ///
  /// In nl, this message translates to:
  /// **'Nu niet'**
  String get pinBiometricNotNow;

  /// No description provided for @pinBiometricActivate.
  ///
  /// In nl, this message translates to:
  /// **'Activeren'**
  String get pinBiometricActivate;

  /// No description provided for @unlockTitle.
  ///
  /// In nl, this message translates to:
  /// **'Welkom terug'**
  String get unlockTitle;

  /// No description provided for @unlockSubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Voer uw pincode in om door te gaan'**
  String get unlockSubtitle;

  /// No description provided for @unlockPinLabel.
  ///
  /// In nl, this message translates to:
  /// **'Pincode'**
  String get unlockPinLabel;

  /// No description provided for @unlockPinHint.
  ///
  /// In nl, this message translates to:
  /// **'Voer uw PIN in'**
  String get unlockPinHint;

  /// No description provided for @unlockButton.
  ///
  /// In nl, this message translates to:
  /// **'Ontgrendelen'**
  String get unlockButton;

  /// No description provided for @unlockInProgress.
  ///
  /// In nl, this message translates to:
  /// **'Bezig...'**
  String get unlockInProgress;

  /// No description provided for @unlockBiometric.
  ///
  /// In nl, this message translates to:
  /// **'Biometrisch Ontgrendelen'**
  String get unlockBiometric;

  /// No description provided for @unlockWithPassword.
  ///
  /// In nl, this message translates to:
  /// **'Inloggen met wachtwoord'**
  String get unlockWithPassword;

  /// No description provided for @unlockError.
  ///
  /// In nl, this message translates to:
  /// **'Onjuiste PIN. Probeer opnieuw.'**
  String get unlockError;

  /// No description provided for @unlockBiometricFailed.
  ///
  /// In nl, this message translates to:
  /// **'Biometrische authenticatie mislukt'**
  String get unlockBiometricFailed;

  /// No description provided for @unlockBiometricUnavailable.
  ///
  /// In nl, this message translates to:
  /// **'Biometrie niet beschikbaar'**
  String get unlockBiometricUnavailable;

  /// No description provided for @unlockInfoMessage.
  ///
  /// In nl, this message translates to:
  /// **'Uw gegevens zijn veilig opgeslagen op dit apparaat'**
  String get unlockInfoMessage;

  /// No description provided for @recoveryPhraseTitle.
  ///
  /// In nl, this message translates to:
  /// **'Herstelzinnen Bewaren'**
  String get recoveryPhraseTitle;

  /// No description provided for @recoveryPhraseSubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Schrijf deze 12 woorden op en bewaar ze op een veilige plek'**
  String get recoveryPhraseSubtitle;

  /// No description provided for @recoveryPhraseWarning.
  ///
  /// In nl, this message translates to:
  /// **'BELANGRIJK: Als u uw wachtwoord vergeet, zijn deze woorden de ENIGE manier om toegang te herstellen.'**
  String get recoveryPhraseWarning;

  /// No description provided for @recoveryPhraseInstructions.
  ///
  /// In nl, this message translates to:
  /// **'1. Schrijf alle 12 woorden op in de juiste volgorde\n2. Bewaar ze op een veilige plek (niet digitaal!)\n3. Vertel niemand deze woorden\n4. U hebt ze nodig om uw wachtwoord te herstellen'**
  String get recoveryPhraseInstructions;

  /// No description provided for @recoveryPhraseCopyWarning.
  ///
  /// In nl, this message translates to:
  /// **'Kopieer deze woorden NIET naar uw klembord of een digitaal document'**
  String get recoveryPhraseCopyWarning;

  /// No description provided for @recoveryPhraseConfirmTitle.
  ///
  /// In nl, this message translates to:
  /// **'Bevestig Herstelzinnen'**
  String get recoveryPhraseConfirmTitle;

  /// No description provided for @recoveryPhraseConfirmSubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Voer de woorden in om te bevestigen dat u ze hebt opgeschreven'**
  String get recoveryPhraseConfirmSubtitle;

  /// No description provided for @recoveryPhraseConfirmInstructions.
  ///
  /// In nl, this message translates to:
  /// **'Voer woord {number} in:'**
  String recoveryPhraseConfirmInstructions(Object number);

  /// No description provided for @recoveryPhraseConfirmError.
  ///
  /// In nl, this message translates to:
  /// **'Onjuist woord. Controleer uw notities en probeer opnieuw.'**
  String get recoveryPhraseConfirmError;

  /// No description provided for @recoveryPhraseConfirmed.
  ///
  /// In nl, this message translates to:
  /// **'Herstelzinnen bevestigd! Uw account is nu beveiligd.'**
  String get recoveryPhraseConfirmed;

  /// No description provided for @recoveryPhraseIWroteItDown.
  ///
  /// In nl, this message translates to:
  /// **'Ik heb de woorden opgeschreven'**
  String get recoveryPhraseIWroteItDown;

  /// No description provided for @recoveryPhraseShowAgain.
  ///
  /// In nl, this message translates to:
  /// **'Toon opnieuw'**
  String get recoveryPhraseShowAgain;

  /// No description provided for @recoveryPhraseWord.
  ///
  /// In nl, this message translates to:
  /// **'Woord {number}'**
  String recoveryPhraseWord(Object number);

  /// No description provided for @passwordRecoveryTitle.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord Herstellen'**
  String get passwordRecoveryTitle;

  /// No description provided for @passwordRecoverySubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Voer uw 12-woorden herstelzinnen in'**
  String get passwordRecoverySubtitle;

  /// No description provided for @passwordRecoveryInstructions.
  ///
  /// In nl, this message translates to:
  /// **'Voer alle 12 woorden in de juiste volgorde in om uw wachtwoord te herstellen.'**
  String get passwordRecoveryInstructions;

  /// No description provided for @passwordRecoveryEnterWords.
  ///
  /// In nl, this message translates to:
  /// **'Voer herstelzinnen in'**
  String get passwordRecoveryEnterWords;

  /// No description provided for @passwordRecoveryWordsHint.
  ///
  /// In nl, this message translates to:
  /// **'woord1 woord2 woord3 ...'**
  String get passwordRecoveryWordsHint;

  /// No description provided for @passwordRecoveryNewPassword.
  ///
  /// In nl, this message translates to:
  /// **'Nieuw wachtwoord'**
  String get passwordRecoveryNewPassword;

  /// No description provided for @passwordRecoveryConfirmPassword.
  ///
  /// In nl, this message translates to:
  /// **'Bevestig nieuw wachtwoord'**
  String get passwordRecoveryConfirmPassword;

  /// No description provided for @passwordRecoveryRecover.
  ///
  /// In nl, this message translates to:
  /// **'Herstel Wachtwoord'**
  String get passwordRecoveryRecover;

  /// No description provided for @passwordRecoverySuccess.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord succesvol hersteld!'**
  String get passwordRecoverySuccess;

  /// No description provided for @passwordRecoveryFailed.
  ///
  /// In nl, this message translates to:
  /// **'Herstelzinnen onjuist. Probeer opnieuw.'**
  String get passwordRecoveryFailed;

  /// No description provided for @passwordRecoveryNoPhrase.
  ///
  /// In nl, this message translates to:
  /// **'Geen herstelzinnen ingesteld'**
  String get passwordRecoveryNoPhrase;

  /// No description provided for @passwordRecoveryNoAccess.
  ///
  /// In nl, this message translates to:
  /// **'Zonder herstelzinnen kunt u uw wachtwoord niet herstellen. Neem contact op met support.'**
  String get passwordRecoveryNoAccess;

  /// No description provided for @dossierTitle.
  ///
  /// In nl, this message translates to:
  /// **'Dossiers'**
  String get dossierTitle;

  /// No description provided for @dossierSelect.
  ///
  /// In nl, this message translates to:
  /// **'Selecteer Dossier'**
  String get dossierSelect;

  /// No description provided for @dossierSelectSubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Kies welk dossier u wilt beheren'**
  String get dossierSelectSubtitle;

  /// No description provided for @dossierCreate.
  ///
  /// In nl, this message translates to:
  /// **'Nieuw Dossier'**
  String get dossierCreate;

  /// No description provided for @dossierCreateTitle.
  ///
  /// In nl, this message translates to:
  /// **'Dossier Aanmaken'**
  String get dossierCreateTitle;

  /// No description provided for @dossierEditTitle.
  ///
  /// In nl, this message translates to:
  /// **'Dossier Bewerken'**
  String get dossierEditTitle;

  /// No description provided for @dossierName.
  ///
  /// In nl, this message translates to:
  /// **'Dossiernaam'**
  String get dossierName;

  /// No description provided for @dossierNameHint.
  ///
  /// In nl, this message translates to:
  /// **'bijv. Mijn Gezin, Ouders, etc.'**
  String get dossierNameHint;

  /// No description provided for @dossierDescription.
  ///
  /// In nl, this message translates to:
  /// **'Omschrijving (optioneel)'**
  String get dossierDescription;

  /// No description provided for @dossierDescriptionHint.
  ///
  /// In nl, this message translates to:
  /// **'Waar gaat dit dossier over?'**
  String get dossierDescriptionHint;

  /// No description provided for @dossierIcon.
  ///
  /// In nl, this message translates to:
  /// **'Icoon'**
  String get dossierIcon;

  /// No description provided for @dossierColor.
  ///
  /// In nl, this message translates to:
  /// **'Kleur'**
  String get dossierColor;

  /// No description provided for @dossierPersonCount.
  ///
  /// In nl, this message translates to:
  /// **'{count} personen'**
  String dossierPersonCount(Object count);

  /// No description provided for @dossierCreatedAt.
  ///
  /// In nl, this message translates to:
  /// **'Aangemaakt op {date}'**
  String dossierCreatedAt(Object date);

  /// No description provided for @dossierDeleteTitle.
  ///
  /// In nl, this message translates to:
  /// **'Dossier Verwijderen?'**
  String get dossierDeleteTitle;

  /// No description provided for @dossierDeleteMessage.
  ///
  /// In nl, this message translates to:
  /// **'Weet u zeker dat u dit dossier wilt verwijderen?\n\nAlle personen en gegevens in dit dossier worden permanent verwijderd.'**
  String get dossierDeleteMessage;

  /// No description provided for @dossierDeleteConfirm.
  ///
  /// In nl, this message translates to:
  /// **'Ja, Verwijderen'**
  String get dossierDeleteConfirm;

  /// No description provided for @dossierDeleteCancel.
  ///
  /// In nl, this message translates to:
  /// **'Annuleren'**
  String get dossierDeleteCancel;

  /// No description provided for @dossierDeleted.
  ///
  /// In nl, this message translates to:
  /// **'Dossier verwijderd'**
  String get dossierDeleted;

  /// No description provided for @dossierSaved.
  ///
  /// In nl, this message translates to:
  /// **'Dossier opgeslagen'**
  String get dossierSaved;

  /// No description provided for @dossierNoDossiers.
  ///
  /// In nl, this message translates to:
  /// **'Nog geen dossiers'**
  String get dossierNoDossiers;

  /// No description provided for @dossierCreateFirst.
  ///
  /// In nl, this message translates to:
  /// **'Maak uw eerste dossier aan om te beginnen'**
  String get dossierCreateFirst;

  /// No description provided for @dossierActive.
  ///
  /// In nl, this message translates to:
  /// **'Actief'**
  String get dossierActive;

  /// No description provided for @dossierInactive.
  ///
  /// In nl, this message translates to:
  /// **'Inactief'**
  String get dossierInactive;

  /// No description provided for @dossierManage.
  ///
  /// In nl, this message translates to:
  /// **'Dossiers Beheren'**
  String get dossierManage;

  /// No description provided for @splashTitle.
  ///
  /// In nl, this message translates to:
  /// **'Life & Legacy Manager'**
  String get splashTitle;

  /// No description provided for @splashSubtitle.
  ///
  /// In nl, this message translates to:
  /// **'Uw persoonlijke levenscompas'**
  String get splashSubtitle;

  /// No description provided for @splashLoading.
  ///
  /// In nl, this message translates to:
  /// **'Even geduld...'**
  String get splashLoading;

  /// No description provided for @loading.
  ///
  /// In nl, this message translates to:
  /// **'Even geduld...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In nl, this message translates to:
  /// **'Er ging iets mis'**
  String get error;

  /// No description provided for @success.
  ///
  /// In nl, this message translates to:
  /// **'Gelukt!'**
  String get success;

  /// No description provided for @validationRequired.
  ///
  /// In nl, this message translates to:
  /// **'Dit veld is verplicht'**
  String get validationRequired;

  /// No description provided for @validationEmail.
  ///
  /// In nl, this message translates to:
  /// **'Ongeldig e-mailadres'**
  String get validationEmail;

  /// No description provided for @validationPasswordLength.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoord moet minimaal 6 tekens zijn'**
  String get validationPasswordLength;

  /// No description provided for @validationPasswordMatch.
  ///
  /// In nl, this message translates to:
  /// **'Wachtwoorden komen niet overeen'**
  String get validationPasswordMatch;

  /// No description provided for @validationPinLength.
  ///
  /// In nl, this message translates to:
  /// **'PIN moet minimaal 4 cijfers zijn'**
  String get validationPinLength;

  /// No description provided for @validationPinMax.
  ///
  /// In nl, this message translates to:
  /// **'PIN mag maximaal 8 cijfers zijn'**
  String get validationPinMax;

  /// No description provided for @validationPinMatch.
  ///
  /// In nl, this message translates to:
  /// **'PIN\'s komen niet overeen'**
  String get validationPinMatch;

  /// No description provided for @validationPinEmpty.
  ///
  /// In nl, this message translates to:
  /// **'Vul een PIN in'**
  String get validationPinEmpty;

  /// No description provided for @validationNameMin.
  ///
  /// In nl, this message translates to:
  /// **'{field} moet minimaal 2 tekens bevatten'**
  String validationNameMin(Object field);

  /// No description provided for @validationNameRequired.
  ///
  /// In nl, this message translates to:
  /// **'Vul {field} in'**
  String validationNameRequired(Object field);

  /// No description provided for @personEdit.
  ///
  /// In nl, this message translates to:
  /// **'Persoon bewerken'**
  String get personEdit;

  /// No description provided for @personAdd.
  ///
  /// In nl, this message translates to:
  /// **'Persoon toevoegen'**
  String get personAdd;

  /// No description provided for @personNotFound.
  ///
  /// In nl, this message translates to:
  /// **'Persoon niet gevonden'**
  String get personNotFound;

  /// No description provided for @personSaveChanges.
  ///
  /// In nl, this message translates to:
  /// **'Wijzigingen opslaan'**
  String get personSaveChanges;

  /// No description provided for @personRelationToUser.
  ///
  /// In nl, this message translates to:
  /// **'Relatie tot gebruiker'**
  String get personRelationToUser;

  /// No description provided for @personRelationSelf.
  ///
  /// In nl, this message translates to:
  /// **'Ikzelf'**
  String get personRelationSelf;

  /// No description provided for @personRelationPartner.
  ///
  /// In nl, this message translates to:
  /// **'Partner'**
  String get personRelationPartner;

  /// No description provided for @personRelationChild.
  ///
  /// In nl, this message translates to:
  /// **'Kind'**
  String get personRelationChild;

  /// No description provided for @personRelationParent.
  ///
  /// In nl, this message translates to:
  /// **'Ouder'**
  String get personRelationParent;

  /// No description provided for @personRelationFamily.
  ///
  /// In nl, this message translates to:
  /// **'Familie'**
  String get personRelationFamily;

  /// No description provided for @personRelationFriend.
  ///
  /// In nl, this message translates to:
  /// **'Vriend(in)'**
  String get personRelationFriend;

  /// No description provided for @personRelationOther.
  ///
  /// In nl, this message translates to:
  /// **'Overig'**
  String get personRelationOther;

  /// No description provided for @personDeathDate.
  ///
  /// In nl, this message translates to:
  /// **'Overlijdensdatum (optioneel)'**
  String get personDeathDate;

  /// No description provided for @personNotes.
  ///
  /// In nl, this message translates to:
  /// **'Opmerkingen / notities'**
  String get personNotes;

  /// No description provided for @personSelectDate.
  ///
  /// In nl, this message translates to:
  /// **'Klik om datum te kiezen'**
  String get personSelectDate;

  /// No description provided for @personChooseRelation.
  ///
  /// In nl, this message translates to:
  /// **'Kies een relatie'**
  String get personChooseRelation;

  /// No description provided for @personPhoneShort.
  ///
  /// In nl, this message translates to:
  /// **'Telefoonnummer lijkt te kort'**
  String get personPhoneShort;

  /// No description provided for @personPhoneInvalid.
  ///
  /// In nl, this message translates to:
  /// **'Ongeldig telefoonnummer'**
  String get personPhoneInvalid;

  /// No description provided for @personPostalInvalid.
  ///
  /// In nl, this message translates to:
  /// **'Postcode moet zijn als 1234 AB'**
  String get personPostalInvalid;

  /// No description provided for @personManage.
  ///
  /// In nl, this message translates to:
  /// **'Personen Beheren'**
  String get personManage;

  /// No description provided for @personNoPersons.
  ///
  /// In nl, this message translates to:
  /// **'Nog geen personen in dit dossier'**
  String get personNoPersons;

  /// No description provided for @personAddFirst.
  ///
  /// In nl, this message translates to:
  /// **'Voeg de eerste persoon toe'**
  String get personAddFirst;

  /// No description provided for @personDeleted.
  ///
  /// In nl, this message translates to:
  /// **'Persoon verwijderd'**
  String get personDeleted;

  /// No description provided for @personSaved.
  ///
  /// In nl, this message translates to:
  /// **'Persoon opgeslagen'**
  String get personSaved;

  /// No description provided for @personDeleteTitle.
  ///
  /// In nl, this message translates to:
  /// **'Persoon Verwijderen?'**
  String get personDeleteTitle;

  /// No description provided for @personDeleteMessage.
  ///
  /// In nl, this message translates to:
  /// **'Weet u zeker dat u {name} wilt verwijderen?'**
  String personDeleteMessage(Object name);

  /// No description provided for @personAge.
  ///
  /// In nl, this message translates to:
  /// **'{age} jaar'**
  String personAge(Object age);

  /// No description provided for @personYearsOld.
  ///
  /// In nl, this message translates to:
  /// **'{years} jaar'**
  String personYearsOld(Object years);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'nl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'nl':
      return AppLocalizationsNl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
