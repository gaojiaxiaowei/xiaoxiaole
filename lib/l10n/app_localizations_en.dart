import 'app_localizations.dart';

/// 英文翻译
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn(super.locale);

  @override
  String get gameTitle => 'Block Blast';

  @override
  String get score => 'Score';

  @override
  String get highScore => 'Best';

  @override
  String get settings => 'Settings';

  @override
  String get help => 'Help';

  @override
  String get pause => 'Pause';

  @override
  String get continue_ => 'Continue';

  @override
  String get gameOver => 'Game Over';

  @override
  String get playAgain => 'Play Again';

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get noChallengeToday => 'No challenge today';

  @override
  String get todayChallenge => 'Today\'s Challenge';

  @override
  String get progress => 'Progress';

  @override
  String get reward => 'Reward';

  @override
  String get challengeHistory => 'Challenge History';

  @override
  String get noHistory => 'No history';

  @override
  String timeRemaining(int seconds) => '$seconds seconds left';

  @override
  String get timeUp => 'Time\'s up!';
  
  // P1: Mode selection related
  @override
  String get selectMode => 'Select Mode';
  
  @override
  String get classicMode => 'Classic Mode';
  
  @override
  String get classicModeDesc => 'Relax and enjoy';
  
  @override
  String get timedMode => 'Timed Mode';
  
  @override
  String get timedModeDesc => '60-second challenge';
  
  @override
  String get modeSelectionTip => 'Choose a game mode to start';
  
  // Leaderboard related
  @override
  String get leaderboard => 'Leaderboard';
  
  @override
  String get globalLeaderboard => 'Global';
  
  @override
  String get regionLeaderboard => 'Regional';
  
  @override
  String get rank => 'Rank';
  
  @override
  String get nickname => 'Nickname';
  
  @override
  String get myRank => 'My Rank';
  
  @override
  String get noLeaderboardData => 'No leaderboard data';
  
  @override
  String get refresh => 'Refresh';
  
  @override
  String get loading => 'Loading';
  
  // Tutorial related
  @override
  String get tutorialWelcome => 'Welcome to Block Blast!';

  @override
  String get tutorialWelcomeDesc => 'A simple and addictive puzzle game';

  @override
  String get tutorialDrag => 'Drag blocks from bottom to grid';

  @override
  String get tutorialDragDesc => 'Long press a block and drag it to the right position on the 8x8 grid';

  @override
  String get tutorialClear => 'Fill a row or column to clear';

  @override
  String get tutorialClearDesc => 'When a row or column is filled, it will be cleared automatically and you\'ll get points';

  @override
  String get tutorialReady => 'Ready? Let\'s play!';

  @override
  String get tutorialReadyDesc => 'Challenge your high score and enjoy the fun';

  @override
  String get skip => 'Skip';

  @override
  String get startGame => 'Start Game';

  @override
  String get nextStep => 'Next';

  // Help related
  @override
  String get gameInstructions => 'How to Play';

  @override
  String get gameGoal => 'Goal';

  @override
  String get gameGoalDesc => 'Place blocks on the grid, clear filled rows and columns, get high scores!';

  @override
  String get operationMethod => 'Controls';

  @override
  String get operationMethodDesc => 'Drag blocks from the bottom pool to the grid. You\'ll see a preview while dragging.';

  @override
  String get clearRules => 'Clearing Rules';

  @override
  String get clearRulesDesc => 'When a row or column is filled, it clears automatically and frees up space for more blocks.';

  @override
  String get scoringRules => 'Scoring';

  @override
  String get scoringPlace => '• Place block: +1 point per cell';

  @override
  String get scoringClear => '• Clear row/column: +10 points per cell';

  @override
  String get scoringCombo => '• Combo bonus: chain clears for more points';

  @override
  String get gameEnd => 'Game Over';

  @override
  String get gameEndDesc => 'The game ends when remaining blocks cannot be placed. Try to get the highest score!';

  @override
  String get smallTip => 'Tips';

  @override
  String get tip1 => '• Keep the center of the grid open';

  @override
  String get tip2 => '• Prioritize clearing hard-to-fill rows/columns';

  @override
  String get tip3 => '• Watch the shapes of remaining blocks';

  @override
  String get tip4 => '• Combos give massive points';

  // Stats related
  @override
  String get gameStats => 'Game Stats';

  @override
  String get resetStats => 'Reset Stats';

  @override
  String get confirmReset => 'Confirm Reset';

  @override
  String get confirmResetDesc => 'Are you sure you want to reset all game stats? This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get statsResetSuccess => 'Stats have been reset';

  @override
  String get totalGames => 'Total Games';

  @override
  String get gamesUnit => 'games';

  @override
  String get highestScore => 'High Score';

  @override
  String get scoreUnit => 'pts';

  @override
  String get totalRowsCleared => 'Total Rows Cleared';

  @override
  String get rowsUnit => 'rows';

  @override
  String get totalColsCleared => 'Total Columns Cleared';

  @override
  String get colsUnit => 'cols';

  @override
  String get highestCombo => 'Highest Combo';

  @override
  String get comboUnit => 'combo';

  @override
  String get totalPlayTime => 'Total Play Time';

  @override
  String get minutes => 'min';

  @override
  String get hours => 'hr';

  @override
  String get recent10Games => 'Recent 10 Games';

  @override
  String get noGameRecords => 'No game records yet';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get daysAgo => 'days ago';

  @override
  String get scoreTrend => 'Score Trend';

  @override
  String get rounds => 'games';

  @override
  String get highest => 'Best';

  @override
  String get backToSettings => 'Back to Settings';

  // Game Over related
  @override
  String get newRecord => '🎉 New Record!';

  @override
  String get currentScore => 'Current Score';

  @override
  String get currentStats => 'This Game';

  @override
  String get placed => 'Placed';

  @override
  String get clearedRows => 'Rows';

  @override
  String get clearedCols => 'Cols';

  @override
  String get combo => 'Combo';

  @override
  String get diffToHighScore => 'Points to beat';

  @override
  String get shareScore => 'Share Score';

  @override
  String get shareSuccess => 'Shared successfully!';

  @override
  String get shareFailed => 'Share failed, please retry';

  @override
  String get rankPosition => 'Rank';
}
