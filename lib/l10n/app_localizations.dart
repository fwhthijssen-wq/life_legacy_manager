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

  /// Ondertitel van de app
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

  /// No description provided for @pinConfirm.
  ///
  /// In nl, this message translates to:
  /// **'Herhaal PIN'**
  String get pinConfirm;

  /// No description provided for @pinSetup.
  ///
  /// In nl, this message translates to:
  /// **'PIN Instellen'**
  String get pinSetup;

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

  /// No description provided for @unlockButton.
  ///
  /// In nl, this message translates to:
  /// **'Ontgrendelen'**
  String get unlockButton;

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
