// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appSubtitle => 'Chess puzzles in 3D';

  @override
  String get sectionQueens => 'Queens';

  @override
  String get sectionKnight => 'Knight';

  @override
  String get classicMode => 'Classic Mode';

  @override
  String get challenges => 'Challenges';

  @override
  String get store => 'Store';

  @override
  String get howToPlay => 'How to play';

  @override
  String get about => 'About';

  @override
  String get modeQueensTitle => 'Queens Challenges';

  @override
  String get modeTourTitle => 'Knight\'s Tour';

  @override
  String get modeKnightsTitle => 'Peaceful Knights';

  @override
  String get modeQueensShort => 'Queens';

  @override
  String get modeTourShort => 'Knight\'s Tour';

  @override
  String get modeKnightsShort => 'Peaceful Knights';

  @override
  String get dailyTitle => 'Daily Challenge';

  @override
  String get dailyPlay => 'Play';

  @override
  String get dailyDone => 'Done! Come back tomorrow';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count-day streak',
      one: '1-day streak',
      zero: 'No streak yet',
    );
    return '$_temp0';
  }

  @override
  String bestStreak(int count) {
    return 'Best: $count';
  }

  @override
  String get dailyCompleteTitle => 'Daily challenge complete!';

  @override
  String streakBonus(int hints) {
    return 'Streak bonus: +$hints hints!';
  }

  @override
  String streakLine(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Streak: $count days',
      one: 'Streak: 1 day',
    );
    return '$_temp0';
  }

  @override
  String boardSize(int n) {
    return '$n×$n board';
  }

  @override
  String get beatPreviousBoard => 'Beat the previous board';

  @override
  String solutionsProgress(int found, int total) {
    return 'Solutions: $found of $total';
  }

  @override
  String bestTimeSuffix(String time) {
    return ' · best $time';
  }

  @override
  String get dragHint => 'Drag to rotate · pinch to zoom';

  @override
  String get undo => 'Undo';

  @override
  String hintButton(int count) {
    return 'Hint ($count)';
  }

  @override
  String get centerCamera => 'Center camera';

  @override
  String get restart => 'Restart';

  @override
  String get showAttacks => 'Show attacked squares';

  @override
  String get hideAttacks => 'Hide attacked squares';

  @override
  String get noHintsTitle => 'Out of hints';

  @override
  String noHintsVideo(int video, int perLevel) {
    return 'Watch a short video to get $video hints.\n\nYou also earn $perLevel hint for each new level you beat.';
  }

  @override
  String noHintsNoVideo(int perLevel) {
    return 'No video available right now. You earn $perLevel hint for each new level you beat.';
  }

  @override
  String get notNow => 'Not now';

  @override
  String get watch => 'Watch';

  @override
  String get levelComplete => 'Level complete!';

  @override
  String timeLine(String time) {
    return 'Time: $time';
  }

  @override
  String hintsUsedLine(int count) {
    return 'Hints used: $count';
  }

  @override
  String hintReward(int count) {
    return '+$count bonus hint!';
  }

  @override
  String boardUnlocked(int n) {
    return '$n×$n board unlocked!';
  }

  @override
  String get modeCompleted => 'You completed every level in this mode!';

  @override
  String get menu => 'Menu';

  @override
  String get playAgain => 'Play again';

  @override
  String get nextLevel => 'Next';

  @override
  String levelTitle(int number, int n) {
    return 'Level $number · $n×$n';
  }

  @override
  String classicTitle(int n) {
    return 'Classic $n×$n';
  }

  @override
  String get newSolution => 'New solution!';

  @override
  String get solved => 'Solved!';

  @override
  String get alreadyFound => 'You had already found this solution.';

  @override
  String solutionsFoundLine(int found, int total) {
    return 'Solutions found: $found of $total';
  }

  @override
  String get newRecord => 'New best time!';

  @override
  String get hintPlaceQueen => 'Try placing a queen on the highlighted square.';

  @override
  String get hintRemoveQueen =>
      'The highlighted queen is not part of the solution.';

  @override
  String get hintPlaceKnight =>
      'Try placing a knight on the highlighted square.';

  @override
  String get hintRemoveKnight => 'Remove the highlighted knight.';

  @override
  String get tourVisited => 'That square was already visited.';

  @override
  String get tourLMove => 'The knight moves in an \"L\": pick a green square.';

  @override
  String get tourStuck => 'No way out! Undo a few moves.';

  @override
  String get tourHintJump => 'Jump to the highlighted square.';

  @override
  String tourHintBack(int count, int square) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'This path is a dead end. Undo $count moves (back to square $square).',
      one: 'This path is a dead end. Undo 1 move (back to square $square).',
    );
    return '$_temp0';
  }

  @override
  String get storeUnavailable =>
      'Purchases become available when the app is installed from Google Play.';

  @override
  String purchaseError(String error) {
    return 'Purchase error: $error';
  }

  @override
  String get hintsSection => 'Hints';

  @override
  String youHaveHints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'You have $count hints',
      one: 'You have 1 hint',
    );
    return '$_temp0';
  }

  @override
  String hintsEarnInfo(int perLevel, int video) {
    return 'Earn $perLevel hint for each new level you beat, or $video by watching a video.';
  }

  @override
  String get adsSection => 'Ads';

  @override
  String get removeAds => 'Remove ads';

  @override
  String get removeAdsInfo =>
      'Removes the banner and the ads between levels. Videos that give hints stay optional.';

  @override
  String get themesSection => 'Themes';

  @override
  String get purchased => 'Purchased';

  @override
  String get unavailable => 'Unavailable';

  @override
  String get inUse => 'In use';

  @override
  String get useTheme => 'Use';

  @override
  String get tapToPreview => 'Tap to preview';

  @override
  String freeWithStars(int count) {
    return 'Free with $count stars';
  }

  @override
  String get free => 'Free';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String themeTitle(String name) {
    return '$name theme';
  }

  @override
  String get close => 'Close';

  @override
  String plusHints(int count) {
    return '+$count hints!';
  }

  @override
  String get themeWood => 'Wood';

  @override
  String get themeTournament => 'Tournament';

  @override
  String get themeMarble => 'Marble';

  @override
  String get themeNeon => 'Neon';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get developedBy => 'Developed by';

  @override
  String get contact => 'Contact';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get licenses => 'Software licenses';

  @override
  String get aboutInspiration =>
      'Inspired by the eight queens puzzle, posed in 1848 by Max Bezzel, and by the knight\'s tour, studied by Euler.';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Phone default';

  @override
  String get gotIt => 'Got it';

  @override
  String get helpQueens =>
      'Place N queens on an N×N board so that no queen attacks another. A queen attacks in straight lines: along its row, its column and its diagonals.\n\n• Tap a square to place or remove a queen.\n• Queens in red are attacking each other.\n• The eye button marks the squares under attack.';

  @override
  String get helpClassic =>
      'Classic Mode: the board starts empty and there are no levels. Each size has several solutions — 92 on the 8×8. How many can you find?';

  @override
  String get helpChallenge =>
      'Challenges: some queens (dark) are already fixed, and there is only one way to complete the board.';

  @override
  String get helpTour =>
      'Knight\'s Tour: the knight moves in an \"L\" — two squares in one direction and one to the side. Visit EVERY free square on the board, exactly once each.\n\n• The knight starts on the square marked 1.\n• Tap one of the green squares to jump there.\n• The numbers show the order of your path.\n• Squares with a block cannot be used.\n• If you get stuck, use Undo.';

  @override
  String get helpKnights =>
      'Peaceful Knights: place the requested number of knights so that no knight attacks another. A knight attacks the squares one \"L\" away.\n\n• Tap a square to place or remove a knight.\n• Knights in red are attacking each other.\n• Squares with a block cannot be used.\n• The requested number is always the maximum possible on that board.';

  @override
  String get helpProgress =>
      'Levels: beat a level to unlock the next one. Beat every level of a board to unlock the next board.\n\nStars: 3 without hints, 2 with one hint, 1 with more hints.\n\nHints: each new level you beat gives 1 hint. When you run out, you can watch a video to get more.';

  @override
  String get helpDaily =>
      'Daily Challenge: a new puzzle every day, the same for all players. Play every day to grow your streak — every 7 days in a row you earn bonus hints.';

  @override
  String get shareButton => 'Share';

  @override
  String shareText(String what, String time, String link) {
    return 'I solved $what in $time on 8 Queens! Can you beat me? $link';
  }

  @override
  String get shareFooter => 'Play free on Google Play';
}
