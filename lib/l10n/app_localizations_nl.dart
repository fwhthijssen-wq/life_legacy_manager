// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Dutch Flemish (`nl`).
class AppLocalizationsNl extends AppLocalizations {
  AppLocalizationsNl([String locale = 'nl']) : super(locale);

  @override
  String get appTitle => 'Life & Legacy Manager';

  @override
  String get appSubtitle => 'Uw persoonlijke levenscompas';

  @override
  String get welcome => 'Welkom';

  @override
  String get accountCreate => 'Account Aanmaken';

  @override
  String get login => 'Inloggen';

  @override
  String get logout => 'Uitloggen';

  @override
  String get cancel => 'Annuleren';

  @override
  String get save => 'Opslaan';

  @override
  String get delete => 'Verwijderen';

  @override
  String get edit => 'Bewerken';

  @override
  String get back => 'Terug';

  @override
  String get next => 'Volgende';

  @override
  String get skip => 'Overslaan';

  @override
  String get done => 'Klaar';

  @override
  String get close => 'Sluiten';

  @override
  String get email => 'E-mailadres';

  @override
  String get password => 'Wachtwoord';

  @override
  String get confirmPassword => 'Herhaal wachtwoord';

  @override
  String get firstName => 'Voornaam';

  @override
  String get lastName => 'Achternaam';

  @override
  String get birthDate => 'Geboortedatum';

  @override
  String get gender => 'Geslacht';

  @override
  String get phone => 'Telefoonnummer';

  @override
  String get address => 'Adres';

  @override
  String get postalCode => 'Postcode';

  @override
  String get city => 'Plaats';

  @override
  String get genderMale => 'Man';

  @override
  String get genderFemale => 'Vrouw';

  @override
  String get genderOther => 'Anders';

  @override
  String get genderUnknown => 'Onbekend';

  @override
  String get genderNonBinary => 'Non-binair';

  @override
  String get welcomeTitle => 'Life & Legacy Manager';

  @override
  String get welcomeIntroTitle => 'Welkom';

  @override
  String get welcomeIntroText =>
      'In het leven verzamelen we belangrijke documenten, contracten, en informatie. Van bankrekeningen tot verzekeringen, van energiecontracten tot persoonlijke wensen. Maar waar bewaar je dit allemaal? En wat als je nabestaanden deze informatie nodig hebben?';

  @override
  String get welcomeIntroText2 =>
      'Life & Legacy Manager is uw persoonlijke levenscompas. Een veilige, overzichtelijke plek waar u alle belangrijke informatie verzamelt, beheert en toegankelijk maakt voor uzelf en uw naasten.';

  @override
  String get welcomeWhatToExpect => 'Wat kunt u verwachten?';

  @override
  String get welcomeFooter1 =>
      'Begin vandaag met het organiseren van uw levensinformatie';

  @override
  String get welcomeFooter2 => 'Rust en zekerheid voor u en uw naasten';

  @override
  String get featurePrivacyTitle => 'Volledig Privé';

  @override
  String get featurePrivacyDesc =>
      'Al uw gegevens blijven lokaal op uw apparaat opgeslagen';

  @override
  String get featureOverviewTitle => 'Overzichtelijk';

  @override
  String get featureOverviewDesc =>
      'Gestructureerd per thema: geldzaken, huis, juridisch, en meer';

  @override
  String get featureFamilyTitle => 'Voor Nabestaanden';

  @override
  String get featureFamilyDesc =>
      'Alles wat ze moeten weten, op één plek toegankelijk';

  @override
  String get featureDocumentsTitle => 'Documentbeheer';

  @override
  String get featureDocumentsDesc =>
      'Voeg documenten toe of noteer waar ze bewaard zijn';

  @override
  String get featureProgressTitle => 'Voortgang Bijhouden';

  @override
  String get featureProgressDesc =>
      'Zie in één oogopslag welke onderdelen compleet zijn';

  @override
  String get featureSecurityTitle => 'Veilig Bewaard';

  @override
  String get featureSecurityDesc =>
      'Beveiligd met wachtwoord, pincode of biometrie';

  @override
  String get registerTitle => 'Account aanmaken';

  @override
  String get registerButton => 'Account aanmaken';

  @override
  String get registerSelectDate => 'Selecteer datum';

  @override
  String registerDateFormat(Object day, Object month, Object year) {
    return '$day-$month-$year';
  }

  @override
  String get registerSuccess => 'Account succesvol aangemaakt';

  @override
  String get registerFailed => 'Registratie mislukt';

  @override
  String get registerSelectBirthDate => 'Selecteer een geboortedatum';

  @override
  String get loginTitle => 'Inloggen';

  @override
  String get loginButton => 'Inloggen';

  @override
  String get loginForgotPassword => 'Wachtwoord vergeten?';

  @override
  String get loginNoAccount => 'Nog geen account?';

  @override
  String get loginFailed => 'Inloggen mislukt. Controleer uw gegevens.';

  @override
  String get pinSetupTitle => 'Snel Inloggen';

  @override
  String get pinSetupSubtitle =>
      'Stel een pincode in om voortaan snel en gemakkelijk in te loggen zonder uw volledige wachtwoord te typen.';

  @override
  String get pinChooseTitle => 'Kies uw pincode';

  @override
  String get pinChooseSubtitle => '4 tot 8 cijfers';

  @override
  String get pinNew => 'Nieuwe PIN';

  @override
  String get pinNewHint => 'Voer 4-8 cijfers in';

  @override
  String get pinConfirm => 'Herhaal PIN';

  @override
  String get pinConfirmHint => 'Voer dezelfde PIN nogmaals in';

  @override
  String get pinSetup => 'PIN Instellen';

  @override
  String get pinSetupInProgress => 'Bezig met opslaan...';

  @override
  String get pinSkipLater => 'Nu niet, later instellen';

  @override
  String get pinSkipTitle => 'PIN overslaan';

  @override
  String get pinSkipMessage =>
      'Weet u zeker dat u geen PIN wilt instellen? U kunt dit later alsnog doen via instellingen.\n\nZonder PIN moet u steeds uw volledige wachtwoord invoeren.';

  @override
  String get pinTipsTitle => 'Tips voor een veilige PIN';

  @override
  String get pinTip1 =>
      'Gebruik geen voor de hand liggende cijfers zoals 1234 of uw geboortejaar';

  @override
  String get pinTip2 => 'Vertel uw PIN niet aan anderen';

  @override
  String get pinTip3 => 'U kunt de PIN later wijzigen via instellingen';

  @override
  String get pinBiometricAvailable =>
      'Biometrische beveiliging beschikbaar! Na het instellen van de PIN kunt u ook vingerafdruk/gezichtsherkenning activeren.';

  @override
  String get pinBiometricTitle => 'Biometrische beveiliging';

  @override
  String get pinBiometricMessage =>
      'Uw apparaat ondersteunt vingerafdruk of gezichtsherkenning. Wilt u dit ook activeren voor snelle toegang?';

  @override
  String get pinBiometricNotNow => 'Nu niet';

  @override
  String get pinBiometricActivate => 'Activeren';

  @override
  String get unlockTitle => 'Welkom terug';

  @override
  String get unlockSubtitle => 'Voer uw pincode in om door te gaan';

  @override
  String get unlockPinLabel => 'Pincode';

  @override
  String get unlockPinHint => 'Voer uw PIN in';

  @override
  String get unlockButton => 'Ontgrendelen';

  @override
  String get unlockInProgress => 'Bezig...';

  @override
  String get unlockBiometric => 'Biometrisch Ontgrendelen';

  @override
  String get unlockWithPassword => 'Inloggen met wachtwoord';

  @override
  String get unlockError => 'Onjuiste PIN. Probeer opnieuw.';

  @override
  String get unlockBiometricFailed => 'Biometrische authenticatie mislukt';

  @override
  String get unlockBiometricUnavailable => 'Biometrie niet beschikbaar';

  @override
  String get unlockInfoMessage =>
      'Uw gegevens zijn veilig opgeslagen op dit apparaat';

  @override
  String get splashTitle => 'Life & Legacy Manager';

  @override
  String get splashSubtitle => 'Uw persoonlijke levenscompas';

  @override
  String get splashLoading => 'Even geduld...';

  @override
  String get loading => 'Even geduld...';

  @override
  String get error => 'Er ging iets mis';

  @override
  String get success => 'Gelukt!';

  @override
  String get validationRequired => 'Dit veld is verplicht';

  @override
  String get validationEmail => 'Ongeldig e-mailadres';

  @override
  String get validationPasswordLength =>
      'Wachtwoord moet minimaal 6 tekens zijn';

  @override
  String get validationPasswordMatch => 'Wachtwoorden komen niet overeen';

  @override
  String get validationPinLength => 'PIN moet minimaal 4 cijfers zijn';

  @override
  String get validationPinMax => 'PIN mag maximaal 8 cijfers zijn';

  @override
  String get validationPinMatch => 'PIN\'s komen niet overeen';

  @override
  String get validationPinEmpty => 'Vul een PIN in';

  @override
  String validationNameMin(Object field) {
    return '$field moet minimaal 2 tekens bevatten';
  }

  @override
  String validationNameRequired(Object field) {
    return 'Vul $field in';
  }
}
