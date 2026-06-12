import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('fr'),
  ];

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Keep your life\'s rhythm'**
  String get tagline;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @speechAssist.
  ///
  /// In en, this message translates to:
  /// **'Speech assist'**
  String get speechAssist;

  /// No description provided for @speechAssistSub.
  ///
  /// In en, this message translates to:
  /// **'Hands-free voice mode'**
  String get speechAssistSub;

  /// No description provided for @howHelps.
  ///
  /// In en, this message translates to:
  /// **'How aria helps'**
  String get howHelps;

  /// No description provided for @sensesWalk.
  ///
  /// In en, this message translates to:
  /// **'Senses your walk'**
  String get sensesWalk;

  /// No description provided for @playsABeat.
  ///
  /// In en, this message translates to:
  /// **'Plays a beat'**
  String get playsABeat;

  /// No description provided for @learnsAdapts.
  ///
  /// In en, this message translates to:
  /// **'Learns & adapts'**
  String get learnsAdapts;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @aboutYou.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get aboutYou;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueBtn;

  /// No description provided for @connectSensors.
  ///
  /// In en, this message translates to:
  /// **'Connect sensors'**
  String get connectSensors;

  /// No description provided for @lowerBack.
  ///
  /// In en, this message translates to:
  /// **'Lower back'**
  String get lowerBack;

  /// No description provided for @leftAnkle.
  ///
  /// In en, this message translates to:
  /// **'Left ankle'**
  String get leftAnkle;

  /// No description provided for @rightAnkle.
  ///
  /// In en, this message translates to:
  /// **'Right ankle'**
  String get rightAnkle;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @pairing.
  ///
  /// In en, this message translates to:
  /// **'Pairing…'**
  String get pairing;

  /// No description provided for @notConnected.
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// No description provided for @connectAll.
  ///
  /// In en, this message translates to:
  /// **'Connect all'**
  String get connectAll;

  /// No description provided for @baselineWalk.
  ///
  /// In en, this message translates to:
  /// **'Baseline walk'**
  String get baselineWalk;

  /// No description provided for @startWalk.
  ///
  /// In en, this message translates to:
  /// **'Start walk'**
  String get startWalk;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning,'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon,'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening,'**
  String get goodEvening;

  /// No description provided for @readyWalk.
  ///
  /// In en, this message translates to:
  /// **'Ready to take a mindful walk?'**
  String get readyWalk;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'{n} day streak'**
  String dayStreak(int n);

  /// No description provided for @allReady.
  ///
  /// In en, this message translates to:
  /// **'All ready'**
  String get allReady;

  /// No description provided for @sensors.
  ///
  /// In en, this message translates to:
  /// **'Sensors'**
  String get sensors;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @todaysNote.
  ///
  /// In en, this message translates to:
  /// **'Today\'s note'**
  String get todaysNote;

  /// No description provided for @totalSessions.
  ///
  /// In en, this message translates to:
  /// **'Total sessions'**
  String get totalSessions;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @minutesWalked.
  ///
  /// In en, this message translates to:
  /// **'Minutes walked'**
  String get minutesWalked;

  /// No description provided for @recentSessions.
  ///
  /// In en, this message translates to:
  /// **'Recent sessions'**
  String get recentSessions;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @avgCadence.
  ///
  /// In en, this message translates to:
  /// **'Avg cadence'**
  String get avgCadence;

  /// No description provided for @totalWalkTime.
  ///
  /// In en, this message translates to:
  /// **'Total walking time'**
  String get totalWalkTime;

  /// No description provided for @walksThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Walks this week'**
  String get walksThisWeek;

  /// No description provided for @keepGoing.
  ///
  /// In en, this message translates to:
  /// **'Keep going'**
  String get keepGoing;

  /// No description provided for @stepsPerMin.
  ///
  /// In en, this message translates to:
  /// **'steps / min'**
  String get stepsPerMin;

  /// No description provided for @matchedToPace.
  ///
  /// In en, this message translates to:
  /// **'matched to your pace'**
  String get matchedToPace;

  /// No description provided for @inRhythm.
  ///
  /// In en, this message translates to:
  /// **'In rhythm'**
  String get inRhythm;

  /// No description provided for @steadying.
  ///
  /// In en, this message translates to:
  /// **'Steadying'**
  String get steadying;

  /// No description provided for @endWalk.
  ///
  /// In en, this message translates to:
  /// **'End walk'**
  String get endWalk;

  /// No description provided for @helpRespiration.
  ///
  /// In en, this message translates to:
  /// **'Help & Respiration'**
  String get helpRespiration;

  /// No description provided for @freezeDetected.
  ///
  /// In en, this message translates to:
  /// **'Freeze detected'**
  String get freezeDetected;

  /// No description provided for @hereWithYou.
  ///
  /// In en, this message translates to:
  /// **'I\'m right here with you'**
  String get hereWithYou;

  /// No description provided for @breatheFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow the circle and breathe. Take your time.'**
  String get breatheFollow;

  /// No description provided for @breathingExercise.
  ///
  /// In en, this message translates to:
  /// **'Breathing exercise'**
  String get breathingExercise;

  /// No description provided for @breathingSub.
  ///
  /// In en, this message translates to:
  /// **'Slow, guided breaths'**
  String get breathingSub;

  /// No description provided for @callEmergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Call emergency contact'**
  String get callEmergencyContact;

  /// No description provided for @callEmergencySub.
  ///
  /// In en, this message translates to:
  /// **'Reach your saved contact'**
  String get callEmergencySub;

  /// No description provided for @imOkayContinue.
  ///
  /// In en, this message translates to:
  /// **'I\'m okay, continue'**
  String get imOkayContinue;

  /// No description provided for @niceWalk.
  ///
  /// In en, this message translates to:
  /// **'Nice walk,'**
  String get niceWalk;

  /// No description provided for @keptRhythm.
  ///
  /// In en, this message translates to:
  /// **'You kept a steady rhythm the whole way.'**
  String get keptRhythm;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @avgPace.
  ///
  /// In en, this message translates to:
  /// **'Avg pace'**
  String get avgPace;

  /// No description provided for @freezeEased.
  ///
  /// In en, this message translates to:
  /// **'Freeze eased'**
  String get freezeEased;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @cueVolume.
  ///
  /// In en, this message translates to:
  /// **'Cue volume'**
  String get cueVolume;

  /// No description provided for @beatTempo.
  ///
  /// In en, this message translates to:
  /// **'Beat tempo'**
  String get beatTempo;

  /// No description provided for @manageSensors.
  ///
  /// In en, this message translates to:
  /// **'Manage sensors'**
  String get manageSensors;

  /// No description provided for @dailyReminders.
  ///
  /// In en, this message translates to:
  /// **'Daily reminders'**
  String get dailyReminders;

  /// No description provided for @speechAssistHandsFree.
  ///
  /// In en, this message translates to:
  /// **'Speech assist (hands-free)'**
  String get speechAssistHandsFree;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @chooseYourBeat.
  ///
  /// In en, this message translates to:
  /// **'Choose your beat'**
  String get chooseYourBeat;

  /// No description provided for @chooseThisBeat.
  ///
  /// In en, this message translates to:
  /// **'Choose this beat'**
  String get chooseThisBeat;

  /// No description provided for @beatsTab.
  ///
  /// In en, this message translates to:
  /// **'Beats'**
  String get beatsTab;

  /// No description provided for @songsTab.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songsTab;

  /// No description provided for @beatSteady.
  ///
  /// In en, this message translates to:
  /// **'Steady'**
  String get beatSteady;

  /// No description provided for @beatSteadySub.
  ///
  /// In en, this message translates to:
  /// **'Calm and even'**
  String get beatSteadySub;

  /// No description provided for @beatGentle.
  ///
  /// In en, this message translates to:
  /// **'Gentle'**
  String get beatGentle;

  /// No description provided for @beatGentleSub.
  ///
  /// In en, this message translates to:
  /// **'Easy walking pace'**
  String get beatGentleSub;

  /// No description provided for @beatBrisk.
  ///
  /// In en, this message translates to:
  /// **'Brisk'**
  String get beatBrisk;

  /// No description provided for @beatBriskSub.
  ///
  /// In en, this message translates to:
  /// **'A little brisker'**
  String get beatBriskSub;

  /// No description provided for @beatForest.
  ///
  /// In en, this message translates to:
  /// **'Forest calm'**
  String get beatForest;

  /// No description provided for @beatForestSub.
  ///
  /// In en, this message translates to:
  /// **'Gentle woodland rhythm'**
  String get beatForestSub;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get listening;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal information'**
  String get personalInfo;

  /// No description provided for @medicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Medical information'**
  String get medicalInfo;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency contact'**
  String get emergencyContact;

  /// No description provided for @fieldName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get fieldName;

  /// No description provided for @fieldAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get fieldAge;

  /// No description provided for @fieldMeds.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get fieldMeds;

  /// No description provided for @fieldClinician.
  ///
  /// In en, this message translates to:
  /// **'Assigned clinician'**
  String get fieldClinician;

  /// No description provided for @fieldRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get fieldRelationship;

  /// No description provided for @fieldPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldPhone;

  /// No description provided for @audioPrefs.
  ///
  /// In en, this message translates to:
  /// **'Audio preferences'**
  String get audioPrefs;

  /// No description provided for @sensorConfig.
  ///
  /// In en, this message translates to:
  /// **'Sensor configuration'**
  String get sensorConfig;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @accessibility.
  ///
  /// In en, this message translates to:
  /// **'Accessibility'**
  String get accessibility;

  /// No description provided for @allSessions.
  ///
  /// In en, this message translates to:
  /// **'All sessions'**
  String get allSessions;

  /// No description provided for @sortLatest.
  ///
  /// In en, this message translates to:
  /// **'Latest first'**
  String get sortLatest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest first'**
  String get sortOldest;

  /// No description provided for @sortLongest.
  ///
  /// In en, this message translates to:
  /// **'Longest first'**
  String get sortLongest;

  /// No description provided for @sortMostSteps.
  ///
  /// In en, this message translates to:
  /// **'Most steps'**
  String get sortMostSteps;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @progressQuote.
  ///
  /// In en, this message translates to:
  /// **'Every step you take is a small act of courage.'**
  String get progressQuote;

  /// No description provided for @summaryQuote.
  ///
  /// In en, this message translates to:
  /// **'Rhythm is a gentle anchor — you found yours today.'**
  String get summaryQuote;
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
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
