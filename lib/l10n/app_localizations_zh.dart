import 'app_localizations.dart';

/// 中文翻译
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh(super.locale);

  @override
  String get gameTitle => 'Block Blast';

  @override
  String get score => '分数';

  @override
  String get highScore => '最高';

  @override
  String get settings => '设置';

  @override
  String get help => '帮助';

  @override
  String get pause => '暂停';

  @override
  String get continue_ => '继续';

  @override
  String get gameOver => '游戏结束';

  @override
  String get playAgain => '再来一局';

  @override
  String get dailyChallenge => '每日挑战';

  @override
  String get noChallengeToday => '今日无挑战';

  @override
  String get todayChallenge => '今日挑战';

  @override
  String get progress => '进度';

  @override
  String get reward => '奖励';

  @override
  String get challengeHistory => '挑战历史';

  @override
  String get noHistory => '暂无历史';

  @override
  String timeRemaining(int seconds) => '剩余 $seconds 秒';

  @override
  String get timeUp => '时间到';
  
  // P1: 模式选择相关
  @override
  String get selectMode => '选择模式';
  
  @override
  String get classicMode => '经典模式';
  
  @override
  String get classicModeDesc => '无限时间，轻松享受';
  
  @override
  String get timedMode => '计时模式';
  
  @override
  String get timedModeDesc => '60秒限时挑战';
  
  @override
  String get modeSelectionTip => '选择一种游戏模式开始';
  
  // 排行榜相关
  @override
  String get leaderboard => '排行榜';
  
  @override
  String get globalLeaderboard => '全球排行';
  
  @override
  String get regionLeaderboard => '地区排行';
  
  @override
  String get rank => '排名';
  
  @override
  String get nickname => '昵称';
  
  @override
  String get myRank => '我的排名';
  
  @override
  String get noLeaderboardData => '暂无排行数据';
  
  @override
  String get refresh => '刷新';
  
  @override
  String get loading => '加载中';
  
  // Tutorial 相关
  @override
  String get tutorialWelcome => '欢迎来到 Block Blast!';

  @override
  String get tutorialWelcomeDesc => '一款简单又上瘾的消除游戏';

  @override
  String get tutorialDrag => '从底部拖拽方块到网格';

  @override
  String get tutorialDragDesc => '长按方块，拖动到8x8网格上的合适位置';

  @override
  String get tutorialClear => '填满一行或一列即可消除';

  @override
  String get tutorialClearDesc => '整行或整列填满后会自动消除并获得分数';

  @override
  String get tutorialReady => '准备好了吗？开始游戏吧！';

  @override
  String get tutorialReadyDesc => '挑战你的最高分，享受消除的乐趣';

  @override
  String get skip => '跳过';

  @override
  String get startGame => '开始游戏';

  @override
  String get nextStep => '下一步';

  // Help 相关
  @override
  String get gameInstructions => '游戏说明';

  @override
  String get gameGoal => '游戏目标';

  @override
  String get gameGoalDesc => '将方块放入网格，消除填满的行和列，获得高分！';

  @override
  String get operationMethod => '操作方法';

  @override
  String get operationMethodDesc => '从底部方块池拖拽方块到网格上放置。拖拽时会显示放置预览。';

  @override
  String get clearRules => '消除规则';

  @override
  String get clearRulesDesc => '当一行或一列被填满时会自动消除，消除后空出位置可以继续放置方块。';

  @override
  String get scoringRules => '计分规则';

  @override
  String get scoringPlace => '• 放置方块：每个格子 +1 分';

  @override
  String get scoringClear => '• 消除行/列：每格 +10 分';

  @override
  String get scoringCombo => '• 连击加成：连续消除获得更多分数';

  @override
  String get gameEnd => '游戏结束';

  @override
  String get gameEndDesc => '当剩余的方块都无法放置到网格上时，游戏结束。尽量获得更高的分数!';

  @override
  String get smallTip => '小提示';

  @override
  String get tip1 => '• 尽量保持网格中心区域空旷';

  @override
  String get tip2 => '• 优先消除难以填充的行/列';

  @override
  String get tip3 => '• 注意观察剩余方块的形状';

  @override
  String get tip4 => '• 连击可以获得大量分数';

  // Stats 相关
  @override
  String get gameStats => '游戏统计';

  @override
  String get resetStats => '重置统计';

  @override
  String get confirmReset => '确认重置';

  @override
  String get confirmResetDesc => '确定要重置所有游戏统计数据吗？此操作不可撤销。';

  @override
  String get cancel => '取消';

  @override
  String get confirm => '确定';

  @override
  String get statsResetSuccess => '统计数据已重置';

  @override
  String get totalGames => '总游戏局数';

  @override
  String get gamesUnit => '局';

  @override
  String get highestScore => '最高分';

  @override
  String get scoreUnit => '分';

  @override
  String get totalRowsCleared => '累计消除行数';

  @override
  String get rowsUnit => '行';

  @override
  String get totalColsCleared => '累计消除列数';

  @override
  String get colsUnit => '列';

  @override
  String get highestCombo => '最高连击';

  @override
  String get comboUnit => '连击';

  @override
  String get totalPlayTime => '总游戏时长';

  @override
  String get minutes => '分钟';

  @override
  String get hours => '小时';

  @override
  String get recent10Games => '最近10局成绩';

  @override
  String get noGameRecords => '暂无游戏记录';

  @override
  String get today => '今天';

  @override
  String get yesterday => '昨天';

  @override
  String get daysAgo => '天前';

  @override
  String get scoreTrend => '分数趋势';

  @override
  String get rounds => '局';

  @override
  String get highest => '最高';

  @override
  String get backToSettings => '返回设置';

  // Game Over 相关
  @override
  String get newRecord => '🎉 新纪录！';

  @override
  String get currentScore => '本局得分';

  @override
  String get currentStats => '本局统计';

  @override
  String get placed => '放置';

  @override
  String get clearedRows => '消行';

  @override
  String get clearedCols => '消列';

  @override
  String get combo => '连击';

  @override
  String get diffToHighScore => '距离最高分还差';

  @override
  String get shareScore => '分享成绩';

  @override
  String get shareSuccess => '分享成功！';

  @override
  String get shareFailed => '分享失败，请重试';

  @override
  String get rankPosition => '第';
}
