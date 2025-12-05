// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Life & Legacy Manager';

  @override
  String get appSubtitle => 'Your personal life compass';

  @override
  String get welcome => 'Welcome';

  @override
  String get accountCreate => 'Create Account';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get back => 'Back';

  @override
  String get next => 'Next';

  @override
  String get skip => 'Skip';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get create => 'Create';

  @override
  String get update => 'Update';

  @override
  String get add => 'Add';

  @override
  String get remove => 'Remove';

  @override
  String get continueButton => 'Continue';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get namePrefix => 'Prefix';

  @override
  String get birthDate => 'Date of Birth';

  @override
  String get gender => 'Gender';

  @override
  String get phone => 'Phone Number';

  @override
  String get address => 'Address';

  @override
  String get postalCode => 'Postal Code';

  @override
  String get city => 'City';

  @override
  String get description => 'Description';

  @override
  String get name => 'Name';

  @override
  String get genderMale => 'Male';

  @override
  String get genderFemale => 'Female';

  @override
  String get genderOther => 'Other';

  @override
  String get genderUnknown => 'Unknown';

  @override
  String get genderNonBinary => 'Non-binary';

  @override
  String get welcomeTitle => 'Life & Legacy Manager';

  @override
  String get welcomeIntroTitle => 'Welcome';

  @override
  String get welcomeIntroText =>
      'Throughout life we collect important documents, contracts, and information. From bank accounts to insurance policies, from energy contracts to personal wishes. But where do you keep all this? And what if your loved ones need this information?';

  @override
  String get welcomeIntroText2 =>
      'Life & Legacy Manager is your personal life compass. A safe, organized place where you collect, manage and make accessible all important information for yourself and your loved ones.';

  @override
  String get welcomeWhatToExpect => 'What can you expect?';

  @override
  String get welcomeFooter1 => 'Start organizing your life information today';

  @override
  String get welcomeFooter2 => 'Peace of mind for you and your loved ones';

  @override
  String get featurePrivacyTitle => 'Completely Private';

  @override
  String get featurePrivacyDesc =>
      'All your data is stored locally on your device';

  @override
  String get featureOverviewTitle => 'Well Organized';

  @override
  String get featureOverviewDesc =>
      'Structured by theme: finances, home, legal, and more';

  @override
  String get featureFamilyTitle => 'For Your Loved Ones';

  @override
  String get featureFamilyDesc =>
      'Everything they need to know, in one accessible place';

  @override
  String get featureDocumentsTitle => 'Document Management';

  @override
  String get featureDocumentsDesc =>
      'Add documents or note where they are stored';

  @override
  String get featureProgressTitle => 'Track Progress';

  @override
  String get featureProgressDesc =>
      'See at a glance which sections are complete';

  @override
  String get featureSecurityTitle => 'Securely Stored';

  @override
  String get featureSecurityDesc =>
      'Protected with password, PIN code or biometrics';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get registerButton => 'Create Account';

  @override
  String get registerSelectDate => 'Select date';

  @override
  String registerDateFormat(Object day, Object month, Object year) {
    return '$month/$day/$year';
  }

  @override
  String get registerSuccess => 'Account created successfully';

  @override
  String get registerFailed => 'Registration failed';

  @override
  String get registerSelectBirthDate => 'Select a birth date';

  @override
  String get registerWelcome => 'Create Your Account';

  @override
  String get registerSubtitle => 'Fill in your details to get started';

  @override
  String get registerBackToLogin => 'Already have an account? Login';

  @override
  String get optional => 'optional';

  @override
  String get namePrefixHint => 'e.g. van, de, van de';

  @override
  String get loginTitle => 'Login';

  @override
  String get loginButton => 'Login';

  @override
  String get loginForgotPassword => 'Forgot password?';

  @override
  String get loginNoAccount => 'Don\'t have an account?';

  @override
  String get loginFailed => 'Login failed. Please check your credentials.';

  @override
  String get pinSetupTitle => 'Quick Login';

  @override
  String get pinSetupSubtitle =>
      'Set up a PIN code to quickly and easily log in without typing your full password.';

  @override
  String get pinChooseTitle => 'Choose your PIN';

  @override
  String get pinChooseSubtitle => '4 to 8 digits';

  @override
  String get pinNew => 'New PIN';

  @override
  String get pinNewHint => 'Enter 4-8 digits';

  @override
  String get pinConfirm => 'Confirm PIN';

  @override
  String get pinConfirmHint => 'Enter the same PIN again';

  @override
  String get pinSetup => 'Set Up PIN';

  @override
  String get pinSetupInProgress => 'Saving...';

  @override
  String get pinSkipLater => 'Not now, set up later';

  @override
  String get pinSkipTitle => 'Skip PIN';

  @override
  String get pinSkipMessage =>
      'Are you sure you don\'t want to set up a PIN? You can still do this later via settings.\n\nWithout a PIN you\'ll need to enter your full password each time.';

  @override
  String get pinTipsTitle => 'Tips for a secure PIN';

  @override
  String get pinTip1 =>
      'Don\'t use obvious numbers like 1234 or your birth year';

  @override
  String get pinTip2 => 'Don\'t share your PIN with others';

  @override
  String get pinTip3 => 'You can change your PIN later in settings';

  @override
  String get pinBiometricAvailable =>
      'Biometric security available! After setting up your PIN you can also activate fingerprint/face recognition.';

  @override
  String get pinBiometricTitle => 'Biometric Security';

  @override
  String get pinBiometricMessage =>
      'Your device supports fingerprint or face recognition. Would you like to activate this for quick access?';

  @override
  String get pinBiometricNotNow => 'Not now';

  @override
  String get pinBiometricActivate => 'Activate';

  @override
  String get unlockTitle => 'Welcome back';

  @override
  String get unlockSubtitle => 'Enter your PIN code to continue';

  @override
  String get unlockPinLabel => 'PIN code';

  @override
  String get unlockPinHint => 'Enter your PIN';

  @override
  String get unlockButton => 'Unlock';

  @override
  String get unlockInProgress => 'Unlocking...';

  @override
  String get unlockBiometric => 'Unlock with Biometrics';

  @override
  String get unlockWithPassword => 'Login with password';

  @override
  String get unlockError => 'Incorrect PIN. Please try again.';

  @override
  String get unlockBiometricFailed => 'Biometric authentication failed';

  @override
  String get unlockBiometricUnavailable => 'Biometrics not available';

  @override
  String get unlockInfoMessage => 'Your data is safely stored on this device';

  @override
  String get recoveryPhraseTitle => 'Save Recovery Phrase';

  @override
  String get recoveryPhraseSubtitle =>
      'Write down these 12 words and keep them in a safe place';

  @override
  String get recoveryPhraseWarning =>
      'IMPORTANT: If you forget your password, these words are the ONLY way to restore access.';

  @override
  String get recoveryPhraseInstructions =>
      '1. Write down all 12 words in the correct order\n2. Keep them in a safe place (not digitally!)\n3. Don\'t tell anyone these words\n4. You\'ll need them to recover your password';

  @override
  String get recoveryPhraseCopyWarning =>
      'Do NOT copy these words to your clipboard or a digital document';

  @override
  String get recoveryPhraseConfirmTitle => 'Confirm Recovery Phrase';

  @override
  String get recoveryPhraseConfirmSubtitle =>
      'Enter the words to confirm you\'ve written them down';

  @override
  String recoveryPhraseConfirmInstructions(Object number) {
    return 'Enter word $number:';
  }

  @override
  String get recoveryPhraseConfirmError =>
      'Incorrect word. Check your notes and try again.';

  @override
  String get recoveryPhraseConfirmed =>
      'Recovery phrase confirmed! Your account is now secured.';

  @override
  String get recoveryPhraseIWroteItDown => 'I\'ve written down the words';

  @override
  String get recoveryPhraseShowAgain => 'Show again';

  @override
  String recoveryPhraseWord(Object number) {
    return 'Word $number';
  }

  @override
  String get passwordRecoveryTitle => 'Recover Password';

  @override
  String get passwordRecoverySubtitle => 'Enter your 12-word recovery phrase';

  @override
  String get passwordRecoveryInstructions =>
      'Enter all 12 words in the correct order to recover your password.';

  @override
  String get passwordRecoveryEnterWords => 'Enter recovery phrase';

  @override
  String get passwordRecoveryWordsHint => 'word1 word2 word3 ...';

  @override
  String get passwordRecoveryNewPassword => 'New password';

  @override
  String get passwordRecoveryConfirmPassword => 'Confirm new password';

  @override
  String get passwordRecoveryRecover => 'Recover Password';

  @override
  String get passwordRecoverySuccess => 'Password recovered successfully!';

  @override
  String get passwordRecoveryFailed =>
      'Recovery phrase incorrect. Please try again.';

  @override
  String get passwordRecoveryNoPhrase => 'No recovery phrase set';

  @override
  String get passwordRecoveryNoAccess =>
      'Without a recovery phrase you cannot recover your password. Please contact support.';

  @override
  String get dossierTitle => 'Dossiers';

  @override
  String get dossierSelect => 'Select Dossier';

  @override
  String get dossierSelectSubtitle => 'Choose which dossier to manage';

  @override
  String get dossierCreate => 'New Dossier';

  @override
  String get dossierCreateTitle => 'Create Dossier';

  @override
  String get dossierEditTitle => 'Edit Dossier';

  @override
  String get dossierName => 'Dossier Name';

  @override
  String get dossierNameHint => 'e.g. My Family, Parents, etc.';

  @override
  String get dossierDescription => 'Description (optional)';

  @override
  String get dossierDescriptionHint => 'What is this dossier about?';

  @override
  String get dossierIcon => 'Icon';

  @override
  String get dossierColor => 'Color';

  @override
  String dossierPersonCount(Object count) {
    return '$count persons';
  }

  @override
  String dossierCreatedAt(Object date) {
    return 'Created on $date';
  }

  @override
  String get dossierDeleteTitle => 'Delete Dossier?';

  @override
  String get dossierDeleteMessage =>
      'Are you sure you want to delete this dossier?\n\nAll persons and data in this dossier will be permanently deleted.';

  @override
  String get dossierDeleteConfirm => 'Yes, Delete';

  @override
  String get dossierDeleteCancel => 'Cancel';

  @override
  String get dossierDeleted => 'Dossier deleted';

  @override
  String get dossierSaved => 'Dossier saved';

  @override
  String get dossierNoDossiers => 'No dossiers yet';

  @override
  String get dossierCreateFirst => 'Create your first dossier to get started';

  @override
  String get dossierActive => 'Active';

  @override
  String get dossierInactive => 'Inactive';

  @override
  String get dossierManage => 'Manage Dossiers';

  @override
  String get splashTitle => 'Life & Legacy Manager';

  @override
  String get splashSubtitle => 'Your personal life compass';

  @override
  String get splashLoading => 'Please wait...';

  @override
  String get loading => 'Please wait...';

  @override
  String get error => 'Something went wrong';

  @override
  String get success => 'Success!';

  @override
  String get validationRequired => 'This field is required';

  @override
  String get validationEmail => 'Invalid email address';

  @override
  String get validationPasswordLength =>
      'Password must be at least 6 characters';

  @override
  String get validationPasswordMatch => 'Passwords do not match';

  @override
  String get validationPinLength => 'PIN must be at least 4 digits';

  @override
  String get validationPinMax => 'PIN can be maximum 8 digits';

  @override
  String get validationPinMatch => 'PINs do not match';

  @override
  String get validationPinEmpty => 'Enter a PIN';

  @override
  String validationNameMin(Object field) {
    return '$field must be at least 2 characters';
  }

  @override
  String validationNameRequired(Object field) {
    return 'Enter $field';
  }

  @override
  String get personEdit => 'Edit Person';

  @override
  String get personAdd => 'Add Person';

  @override
  String get personNotFound => 'Person not found';

  @override
  String get personSaveChanges => 'Save Changes';

  @override
  String get personRelationToUser => 'Relationship to user';

  @override
  String get personRelationSelf => 'Myself';

  @override
  String get personRelationPartner => 'Partner';

  @override
  String get personRelationChild => 'Child';

  @override
  String get personRelationParent => 'Parent';

  @override
  String get personRelationFamily => 'Family';

  @override
  String get personRelationFriend => 'Friend';

  @override
  String get personRelationOther => 'Other';

  @override
  String get personDeathDate => 'Date of death (optional)';

  @override
  String get personNotes => 'Comments / notes';

  @override
  String get personSelectDate => 'Click to select date';

  @override
  String get personChooseRelation => 'Choose a relationship';

  @override
  String get personPhoneShort => 'Phone number seems too short';

  @override
  String get personPhoneInvalid => 'Invalid phone number';

  @override
  String get personPostalInvalid => 'Postal code must be like 1234 AB';

  @override
  String get personManage => 'Manage Persons';

  @override
  String get personNoPersons => 'No persons in this dossier yet';

  @override
  String get personAddFirst => 'Add the first person';

  @override
  String get personDeleted => 'Person deleted';

  @override
  String get personSaved => 'Person saved';

  @override
  String get personDeleteTitle => 'Delete Person?';

  @override
  String personDeleteMessage(Object name) {
    return 'Are you sure you want to delete $name?';
  }

  @override
  String personAge(Object age) {
    return '$age years';
  }

  @override
  String personYearsOld(Object years) {
    return '$years years old';
  }

  @override
  String get personManageSubtitle => 'Manage all persons';

  @override
  String get moneyMatters => 'Money matters';

  @override
  String get houseEnergy => 'Home & energy';

  @override
  String get relation => 'Relation';

  @override
  String get relationSelf => 'Myself';

  @override
  String get relationPartner => 'Partner';

  @override
  String get relationChild => 'Child';

  @override
  String get relationParent => 'Parent';

  @override
  String get relationFamily => 'Family';

  @override
  String get relationFriend => 'Friend';

  @override
  String get relationOther => 'Other';

  @override
  String get deathDate => 'Date of death';

  @override
  String get notes => 'Notes';

  @override
  String get authenticity => 'Authenticity';

  @override
  String get specifications => 'Specifications';

  @override
  String get contacts => 'Contacts';

  @override
  String get documents => 'Documents';

  @override
  String get story => 'Story';

  @override
  String get storyHint => 'Tell the story behind this item...';

  @override
  String get itemName => 'Item name';

  @override
  String get itemNameHint => 'e.g. Grandma\'s ring, Vintage watch';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get subcategory => 'Subcategory';

  @override
  String get brand => 'Brand';

  @override
  String get model => 'Model';

  @override
  String get year => 'Year';

  @override
  String get serialNumber => 'Serial number';

  @override
  String get condition => 'Condition';

  @override
  String get color => 'Color';

  @override
  String get material => 'Material';

  @override
  String get photos => 'Photos';

  @override
  String get addPhoto => 'Add photo';

  @override
  String get purchaseDetails => 'Purchase details';

  @override
  String get purchaseDate => 'Purchase date';

  @override
  String get purchasedFrom => 'Purchased from';

  @override
  String get purchasedFromHint => 'e.g. Store, Online, Auction';

  @override
  String get purchasePrice => 'Purchase price';

  @override
  String get origin => 'Origin';

  @override
  String get inheritedFrom => 'Inherited from';

  @override
  String get giftFrom => 'Gift from';

  @override
  String get receivedDate => 'Received date';

  @override
  String get currentValue => 'Current value';

  @override
  String get estimatedValue => 'Estimated value';

  @override
  String get valuationBasis => 'Valuation basis';

  @override
  String get lastValuationDate => 'Last valuation date';

  @override
  String get appraisal => 'Appraisal';

  @override
  String get appraiserName => 'Appraiser name';

  @override
  String get appraisalDate => 'Appraisal date';

  @override
  String get appraisedValue => 'Appraised value';

  @override
  String get isInsured => 'Insured';

  @override
  String get insuranceType => 'Insurance type';

  @override
  String get insurerName => 'Insurer name';

  @override
  String get policyNumber => 'Policy number';

  @override
  String get insuredAmount => 'Insured amount';

  @override
  String get locationType => 'Location type';

  @override
  String get locationDetails => 'Location details';

  @override
  String get locationDetailsHint => 'e.g. Home, Safe, Storage unit';

  @override
  String get specificLocation => 'Specific location';

  @override
  String get specificLocationHint => 'e.g. Bedroom, Cabinet 2';

  @override
  String get accessibility => 'Accessibility';

  @override
  String get keyLocation => 'Key location';

  @override
  String get codeLocation => 'Code location';

  @override
  String get accessViaPerson => 'Access via person';

  @override
  String get warranty => 'Warranty';

  @override
  String get hasWarranty => 'Has warranty';

  @override
  String get warrantyYears => 'Warranty years';

  @override
  String get warrantyExpiry => 'Warranty expiry';

  @override
  String get warrantyProvider => 'Warranty provider';

  @override
  String get maintenance => 'Maintenance';

  @override
  String get maintenanceInterval => 'Maintenance interval';

  @override
  String get maintenanceIntervalHint => 'e.g. Yearly, Every 6 months';

  @override
  String get lastMaintenance => 'Last maintenance';

  @override
  String get nextMaintenance => 'Next maintenance';

  @override
  String get maintenanceReminder => 'Maintenance reminder';

  @override
  String get whoGetsThis => 'Who gets this?';

  @override
  String get heirAssigned => 'Heir assigned';

  @override
  String get inheritanceDestination => 'Inheritance destination';

  @override
  String get heirName => 'Heir name';

  @override
  String get inheritanceReason => 'Assignment reason';

  @override
  String get inheritanceReasonHint => 'Why does this go to this person?';

  @override
  String get sentimentalValue => 'Sentimental value';

  @override
  String get mentionedInWill => 'Mentioned in will';

  @override
  String get survivorInstructions => 'Instructions for survivors';

  @override
  String get survivorInstructionsHint => 'What should survivors know/do?';

  @override
  String get sellingInfo => 'Selling information';

  @override
  String get whereToSell => 'Where to sell';

  @override
  String get whereToSellHint => 'e.g. Auction, Dealer, Online';

  @override
  String get estimatedSellingPrice => 'Estimated selling price';

  @override
  String get estimatedSellingTime => 'Estimated selling time';

  @override
  String get estimatedSellingTimeHint => 'e.g. 1-3 months';

  @override
  String get hasCertificate => 'Has certificate';

  @override
  String get hasProvenance => 'Has provenance';

  @override
  String get expertName => 'Expert name';

  @override
  String get registrationNumber => 'Registration number';

  @override
  String get registrationNumberHint => 'e.g. License plate, Serial number';

  @override
  String get specificationsFor => 'Specifications for';

  @override
  String get specificationsComingSoon => 'Specifications coming soon';

  @override
  String get maintenanceContact => 'Maintenance contact';

  @override
  String get company => 'Company';

  @override
  String get website => 'Website';

  @override
  String get dealerContact => 'Dealer contact';

  @override
  String get contactPerson => 'Contact person';

  @override
  String get auctionAccounts => 'Auction accounts';

  @override
  String get auctionAccountsLabel => 'Auction accounts';

  @override
  String get auctionAccountsHint => 'e.g. Catawiki, eBay accounts';

  @override
  String get documentsComingSoon => 'Documents coming soon';

  @override
  String get storyBehindItem => 'The story behind this item';

  @override
  String get specialMemories => 'Special memories';

  @override
  String get specialMemoriesHint => 'Share special memories...';

  @override
  String get whyValuable => 'Why is this valuable?';

  @override
  String get whyValuableHint => 'Emotional or historical value...';

  @override
  String get notesHint => 'Additional notes...';

  @override
  String get pleaseFixErrors => 'Please fix the errors';

  @override
  String get savedSuccessfully => 'Saved successfully';

  @override
  String get confirmDelete => 'Confirm delete';

  @override
  String get confirmDeleteMessage => 'Are you sure you want to delete this?';

  @override
  String get sortByName => 'By name';

  @override
  String get sortByValue => 'By value';

  @override
  String get sortByDate => 'By date';

  @override
  String get addItem => 'Add item';

  @override
  String get editItem => 'Edit item';

  @override
  String get noItemsInCategory => 'No items in this category';

  @override
  String get addFirstItemHint => 'Add the first item';

  @override
  String get items => 'items';

  @override
  String get totalValue => 'Total value';

  @override
  String get basicInfo => 'Basic information';

  @override
  String get purchaseValue => 'Purchase & Value';

  @override
  String get insurance => 'Insurance';

  @override
  String get location => 'Location';

  @override
  String get maintenanceWarranty => 'Maintenance & Warranty';

  @override
  String get inheritance => 'Inheritance';
}
