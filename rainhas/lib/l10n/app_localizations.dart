import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Chess puzzles in 3D'**
  String get appSubtitle;

  /// No description provided for @sectionQueens.
  ///
  /// In en, this message translates to:
  /// **'Queens'**
  String get sectionQueens;

  /// No description provided for @sectionKnight.
  ///
  /// In en, this message translates to:
  /// **'Knight'**
  String get sectionKnight;

  /// No description provided for @classicMode.
  ///
  /// In en, this message translates to:
  /// **'Classic Mode'**
  String get classicMode;

  /// No description provided for @challenges.
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @howToPlay.
  ///
  /// In en, this message translates to:
  /// **'How to play'**
  String get howToPlay;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @modeQueensTitle.
  ///
  /// In en, this message translates to:
  /// **'Queens Challenges'**
  String get modeQueensTitle;

  /// No description provided for @modeTourTitle.
  ///
  /// In en, this message translates to:
  /// **'Knight\'s Tour'**
  String get modeTourTitle;

  /// No description provided for @modeKnightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Peaceful Knights'**
  String get modeKnightsTitle;

  /// No description provided for @modeQueensShort.
  ///
  /// In en, this message translates to:
  /// **'Queens'**
  String get modeQueensShort;

  /// No description provided for @modeTourShort.
  ///
  /// In en, this message translates to:
  /// **'Knight\'s Tour'**
  String get modeTourShort;

  /// No description provided for @modeKnightsShort.
  ///
  /// In en, this message translates to:
  /// **'Peaceful Knights'**
  String get modeKnightsShort;

  /// No description provided for @dailyTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge'**
  String get dailyTitle;

  /// No description provided for @dailyPlay.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get dailyPlay;

  /// No description provided for @dailyDone.
  ///
  /// In en, this message translates to:
  /// **'Done! Come back tomorrow'**
  String get dailyDone;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No streak yet} =1{1-day streak} other{{count}-day streak}}'**
  String streakDays(int count);

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best: {count}'**
  String bestStreak(int count);

  /// No description provided for @dailyCompleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily challenge complete!'**
  String get dailyCompleteTitle;

  /// No description provided for @streakBonus.
  ///
  /// In en, this message translates to:
  /// **'Streak bonus: +{hints} hints!'**
  String streakBonus(int hints);

  /// No description provided for @streakLine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Streak: 1 day} other{Streak: {count} days}}'**
  String streakLine(int count);

  /// No description provided for @boardSize.
  ///
  /// In en, this message translates to:
  /// **'{n}×{n} board'**
  String boardSize(int n);

  /// No description provided for @beatPreviousBoard.
  ///
  /// In en, this message translates to:
  /// **'Beat the previous board'**
  String get beatPreviousBoard;

  /// No description provided for @solutionsProgress.
  ///
  /// In en, this message translates to:
  /// **'Solutions: {found} of {total}'**
  String solutionsProgress(int found, int total);

  /// No description provided for @bestTimeSuffix.
  ///
  /// In en, this message translates to:
  /// **' · best {time}'**
  String bestTimeSuffix(String time);

  /// No description provided for @dragHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to rotate · pinch to zoom'**
  String get dragHint;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @hintButton.
  ///
  /// In en, this message translates to:
  /// **'Hint ({count})'**
  String hintButton(int count);

  /// No description provided for @centerCamera.
  ///
  /// In en, this message translates to:
  /// **'Center camera'**
  String get centerCamera;

  /// No description provided for @restart.
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get restart;

  /// No description provided for @showAttacks.
  ///
  /// In en, this message translates to:
  /// **'Show attacked squares'**
  String get showAttacks;

  /// No description provided for @hideAttacks.
  ///
  /// In en, this message translates to:
  /// **'Hide attacked squares'**
  String get hideAttacks;

  /// No description provided for @noHintsTitle.
  ///
  /// In en, this message translates to:
  /// **'Out of hints'**
  String get noHintsTitle;

  /// No description provided for @noHintsVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch a short video to get {video} hints.\n\nYou also earn {perLevel} hint for each new level you beat.'**
  String noHintsVideo(int video, int perLevel);

  /// No description provided for @noHintsNoVideo.
  ///
  /// In en, this message translates to:
  /// **'No video available right now. You earn {perLevel} hint for each new level you beat.'**
  String noHintsNoVideo(int perLevel);

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @watch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watch;

  /// No description provided for @levelComplete.
  ///
  /// In en, this message translates to:
  /// **'Level complete!'**
  String get levelComplete;

  /// No description provided for @timeLine.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String timeLine(String time);

  /// No description provided for @hintsUsedLine.
  ///
  /// In en, this message translates to:
  /// **'Hints used: {count}'**
  String hintsUsedLine(int count);

  /// No description provided for @hintReward.
  ///
  /// In en, this message translates to:
  /// **'+{count} bonus hint!'**
  String hintReward(int count);

  /// No description provided for @boardUnlocked.
  ///
  /// In en, this message translates to:
  /// **'{n}×{n} board unlocked!'**
  String boardUnlocked(int n);

  /// No description provided for @modeCompleted.
  ///
  /// In en, this message translates to:
  /// **'You completed every level in this mode!'**
  String get modeCompleted;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get nextLevel;

  /// No description provided for @levelTitle.
  ///
  /// In en, this message translates to:
  /// **'Level {number} · {n}×{n}'**
  String levelTitle(int number, int n);

  /// No description provided for @classicTitle.
  ///
  /// In en, this message translates to:
  /// **'Classic {n}×{n}'**
  String classicTitle(int n);

  /// No description provided for @newSolution.
  ///
  /// In en, this message translates to:
  /// **'New solution!'**
  String get newSolution;

  /// No description provided for @solved.
  ///
  /// In en, this message translates to:
  /// **'Solved!'**
  String get solved;

  /// No description provided for @alreadyFound.
  ///
  /// In en, this message translates to:
  /// **'You had already found this solution.'**
  String get alreadyFound;

  /// No description provided for @solutionsFoundLine.
  ///
  /// In en, this message translates to:
  /// **'Solutions found: {found} of {total}'**
  String solutionsFoundLine(int found, int total);

  /// No description provided for @newRecord.
  ///
  /// In en, this message translates to:
  /// **'New best time!'**
  String get newRecord;

  /// No description provided for @hintPlaceQueen.
  ///
  /// In en, this message translates to:
  /// **'Try placing a queen on the highlighted square.'**
  String get hintPlaceQueen;

  /// No description provided for @hintRemoveQueen.
  ///
  /// In en, this message translates to:
  /// **'The highlighted queen is not part of the solution.'**
  String get hintRemoveQueen;

  /// No description provided for @hintPlaceKnight.
  ///
  /// In en, this message translates to:
  /// **'Try placing a knight on the highlighted square.'**
  String get hintPlaceKnight;

  /// No description provided for @hintRemoveKnight.
  ///
  /// In en, this message translates to:
  /// **'Remove the highlighted knight.'**
  String get hintRemoveKnight;

  /// No description provided for @tourVisited.
  ///
  /// In en, this message translates to:
  /// **'That square was already visited.'**
  String get tourVisited;

  /// No description provided for @tourLMove.
  ///
  /// In en, this message translates to:
  /// **'The knight moves in an \"L\": pick a green square.'**
  String get tourLMove;

  /// No description provided for @tourStuck.
  ///
  /// In en, this message translates to:
  /// **'No way out! Undo a few moves.'**
  String get tourStuck;

  /// No description provided for @tourHintJump.
  ///
  /// In en, this message translates to:
  /// **'Jump to the highlighted square.'**
  String get tourHintJump;

  /// No description provided for @tourHintBack.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{This path is a dead end. Undo 1 move (back to square {square}).} other{This path is a dead end. Undo {count} moves (back to square {square}).}}'**
  String tourHintBack(int count, int square);

  /// No description provided for @storeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Purchases become available when the app is installed from Google Play.'**
  String get storeUnavailable;

  /// No description provided for @purchaseError.
  ///
  /// In en, this message translates to:
  /// **'Purchase error: {error}'**
  String purchaseError(String error);

  /// No description provided for @hintsSection.
  ///
  /// In en, this message translates to:
  /// **'Hints'**
  String get hintsSection;

  /// No description provided for @youHaveHints.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{You have 1 hint} other{You have {count} hints}}'**
  String youHaveHints(int count);

  /// No description provided for @hintsEarnInfo.
  ///
  /// In en, this message translates to:
  /// **'Earn {perLevel} hint for each new level you beat, or {video} by watching a video.'**
  String hintsEarnInfo(int perLevel, int video);

  /// No description provided for @adsSection.
  ///
  /// In en, this message translates to:
  /// **'Ads'**
  String get adsSection;

  /// No description provided for @removeAds.
  ///
  /// In en, this message translates to:
  /// **'Remove ads'**
  String get removeAds;

  /// No description provided for @removeAdsInfo.
  ///
  /// In en, this message translates to:
  /// **'Removes the banner and the ads between levels. Videos that give hints stay optional.'**
  String get removeAdsInfo;

  /// No description provided for @themesSection.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themesSection;

  /// No description provided for @purchased.
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Unavailable'**
  String get unavailable;

  /// No description provided for @inUse.
  ///
  /// In en, this message translates to:
  /// **'In use'**
  String get inUse;

  /// No description provided for @useTheme.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get useTheme;

  /// No description provided for @tapToPreview.
  ///
  /// In en, this message translates to:
  /// **'Tap to preview'**
  String get tapToPreview;

  /// No description provided for @freeWithStars.
  ///
  /// In en, this message translates to:
  /// **'Free with {count} stars'**
  String freeWithStars(int count);

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @themeTitle.
  ///
  /// In en, this message translates to:
  /// **'{name} theme'**
  String themeTitle(String name);

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @plusHints.
  ///
  /// In en, this message translates to:
  /// **'+{count} hints!'**
  String plusHints(int count);

  /// No description provided for @themeWood.
  ///
  /// In en, this message translates to:
  /// **'Wood'**
  String get themeWood;

  /// No description provided for @themeTournament.
  ///
  /// In en, this message translates to:
  /// **'Tournament'**
  String get themeTournament;

  /// No description provided for @themeMarble.
  ///
  /// In en, this message translates to:
  /// **'Marble'**
  String get themeMarble;

  /// No description provided for @themeNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get themeNeon;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get developedBy;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @licenses.
  ///
  /// In en, this message translates to:
  /// **'Software licenses'**
  String get licenses;

  /// No description provided for @aboutInspiration.
  ///
  /// In en, this message translates to:
  /// **'Inspired by the eight queens puzzle, posed in 1848 by Max Bezzel, and by the knight\'s tour, studied by Euler.'**
  String get aboutInspiration;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'Phone default'**
  String get languageSystem;

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @helpQueens.
  ///
  /// In en, this message translates to:
  /// **'Place N queens on an N×N board so that no queen attacks another. A queen attacks in straight lines: along its row, its column and its diagonals.\n\n• Tap a square to place or remove a queen.\n• Queens in red are attacking each other.\n• The eye button marks the squares under attack.'**
  String get helpQueens;

  /// No description provided for @helpClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic Mode: the board starts empty and there are no levels. Each size has several solutions — 92 on the 8×8. How many can you find?'**
  String get helpClassic;

  /// No description provided for @helpChallenge.
  ///
  /// In en, this message translates to:
  /// **'Challenges: some queens (dark) are already fixed, and there is only one way to complete the board.'**
  String get helpChallenge;

  /// No description provided for @helpTour.
  ///
  /// In en, this message translates to:
  /// **'Knight\'s Tour: the knight moves in an \"L\" — two squares in one direction and one to the side. Visit EVERY free square on the board, exactly once each.\n\n• The knight starts on the square marked 1.\n• Tap one of the green squares to jump there.\n• The numbers show the order of your path.\n• Squares with a block cannot be used.\n• If you get stuck, use Undo.'**
  String get helpTour;

  /// No description provided for @helpKnights.
  ///
  /// In en, this message translates to:
  /// **'Peaceful Knights: place the requested number of knights so that no knight attacks another. A knight attacks the squares one \"L\" away.\n\n• Tap a square to place or remove a knight.\n• Knights in red are attacking each other.\n• Squares with a block cannot be used.\n• The requested number is always the maximum possible on that board.'**
  String get helpKnights;

  /// No description provided for @helpProgress.
  ///
  /// In en, this message translates to:
  /// **'Levels: beat a level to unlock the next one. Beat every level of a board to unlock the next board.\n\nStars: 3 without hints, 2 with one hint, 1 with more hints.\n\nHints: each new level you beat gives 1 hint. When you run out, you can watch a video to get more.'**
  String get helpProgress;

  /// No description provided for @helpDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily Challenge: a new puzzle every day, the same for all players. Play every day to grow your streak — every 7 days in a row you earn bonus hints.'**
  String get helpDaily;
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
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
