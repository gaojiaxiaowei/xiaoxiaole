import 'dart:async';
import 'package:flutter/material.dart';
import 'app_localizations_zh.dart';
import 'app_localizations_en.dart';

/// 应用国际化配置类（抽象类）
abstract class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  /// 获取当前Locale对应的AppLocalizations实例
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  /// 获取当前Locale对应的AppLocalizations实例（非空）
  static AppLocalizations ofNonNull(BuildContext context) {
    final localizations = of(context);
    assert(localizations != null, 'AppLocalizations not found in context');
    return localizations!;
  }

  /// 本地化资源代理
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// 支持的语言列表
  static const List<Locale> supportedLocales = [
    Locale('zh', 'CN'), // 中文（默认）
    Locale('en', 'US'), // 英文
  ];

  /// 判断是否支持该语言
  static bool isSupported(Locale locale) {
    return supportedLocales.any((supported) =>
        supported.languageCode == locale.languageCode &&
        supported.countryCode == locale.countryCode);
  }

  /// 游戏标题
  String get gameTitle;

  /// 分数
  String get score;

  /// 最高分
  String get highScore;

  /// 设置
  String get settings;

  /// 帮助
  String get help;

  /// 暂停
  String get pause;

  /// 继续
  String get continue_;

  /// 游戏结束
  String get gameOver;

  /// 再来一局
  String get playAgain;

  /// 每日挑战
  String get dailyChallenge;

  /// 今日无挑战
  String get noChallengeToday;

  /// 今日挑战
  String get todayChallenge;

  /// 进度
  String get progress;

  /// 奖励
  String get reward;

  /// 挑战历史
  String get challengeHistory;

  /// 暂无历史
  String get noHistory;

  /// 剩余时间
  String timeRemaining(int seconds);

  /// 时间到
  String get timeUp;
  
  // P1: 模式选择相关
  /// 选择模式
  String get selectMode;
  
  /// 经典模式
  String get classicMode;
  
  /// 经典模式描述
  String get classicModeDesc;
  
  /// 计时模式
  String get timedMode;
  
  /// 计时模式描述
  String get timedModeDesc;
  
  /// 模式选择提示
  String get modeSelectionTip;
  
  // 排行榜相关
  /// 排行榜
  String get leaderboard;
  
  /// 全球排行
  String get globalLeaderboard;
  
  /// 地区排行
  String get regionLeaderboard;
  
  /// 排名
  String get rank;
  
  /// 昵称
  String get nickname;
  
  /// 我的排名
  String get myRank;
  
  /// 暂无排行数据
  String get noLeaderboardData;
  
  /// 刷新
  String get refresh;
  
  /// 加载中
  String get loading;

  // Tutorial 相关
  /// 欢迎来到 Block Blast!
  String get tutorialWelcome;

  /// 一款简单又上瘾的消除游戏
  String get tutorialWelcomeDesc;

  /// 从底部拖拽方块到网格
  String get tutorialDrag;

  /// 长按方块，拖动到8x8网格上的合适位置
  String get tutorialDragDesc;

  /// 填满一行或一列即可消除
  String get tutorialClear;

  /// 整行或整列填满后会自动消除并获得分数
  String get tutorialClearDesc;

  /// 准备好了吗？开始游戏吧！
  String get tutorialReady;

  /// 挑战你的最高分，享受消除的乐趣
  String get tutorialReadyDesc;

  /// 跳过
  String get skip;

  /// 开始游戏
  String get startGame;

  /// 下一步
  String get nextStep;

  // Help 相关
  /// 游戏说明
  String get gameInstructions;

  /// 游戏目标
  String get gameGoal;

  /// 将方块放入网格，消除填满的行和列，获得高分！
  String get gameGoalDesc;

  /// 操作方法
  String get operationMethod;

  /// 从底部方块池拖拽方块到网格上放置。拖拽时会显示放置预览。
  String get operationMethodDesc;

  /// 消除规则
  String get clearRules;

  /// 当一行或一列被填满时会自动消除，消除后空出位置可以继续放置方块。
  String get clearRulesDesc;

  /// 计分规则
  String get scoringRules;

  /// 放置方块：每个格子 +1 分
  String get scoringPlace;

  /// 消除行/列：每格 +10 分
  String get scoringClear;

  /// 连击加成：连续消除获得更多分数
  String get scoringCombo;

  /// 游戏结束
  String get gameEnd;

  /// 当剩余的方块都无法放置到网格上时，游戏结束。尽量获得更高的分数!
  String get gameEndDesc;

  /// 小提示
  String get smallTip;

  /// 尽量保持网格中心区域空旷
  String get tip1;

  /// 优先消除难以填充的行/列
  String get tip2;

  /// 注意观察剩余方块的形状
  String get tip3;

  /// 连击可以获得大量分数
  String get tip4;

  // Stats 相关
  /// 游戏统计
  String get gameStats;

  /// 重置统计
  String get resetStats;

  /// 确认重置
  String get confirmReset;

  /// 确定要重置所有游戏统计数据吗？此操作不可撤销。
  String get confirmResetDesc;

  /// 取消
  String get cancel;

  /// 确定
  String get confirm;

  /// 统计数据已重置
  String get statsResetSuccess;

  /// 总游戏局数
  String get totalGames;

  /// 局
  String get gamesUnit;

  /// 最高分
  String get highestScore;

  /// 分
  String get scoreUnit;

  /// 累计消除行数
  String get totalRowsCleared;

  /// 行
  String get rowsUnit;

  /// 累计消除列数
  String get totalColsCleared;

  /// 列
  String get colsUnit;

  /// 最高连击
  String get highestCombo;

  /// 连击
  String get comboUnit;

  /// 总游戏时长
  String get totalPlayTime;

  /// 分钟
  String get minutes;

  /// 小时
  String get hours;

  /// 最近10局成绩
  String get recent10Games;

  /// 暂无游戏记录
  String get noGameRecords;

  /// 今天
  String get today;

  /// 昨天
  String get yesterday;

  /// 天前
  String get daysAgo;

  /// 分数趋势
  String get scoreTrend;

  /// 局
  String get rounds;

  /// 最高
  String get highest;

  /// 返回设置
  String get backToSettings;

  // Game Over 相关
  /// 新纪录！
  String get newRecord;

  /// 本局得分
  String get currentScore;

  /// 本局统计
  String get currentStats;

  /// 放置
  String get placed;

  /// 消行
  String get clearedRows;

  /// 消列
  String get clearedCols;

  /// 连击
  String get combo;

  /// 距离最高分还差
  String get diffToHighScore;

  /// 分享成绩
  String get shareScore;

  /// 分享成功！
  String get shareSuccess;

  /// 分享失败，请重试
  String get shareFailed;

  /// 第 X 名
  String get rankPosition;
}

/// AppLocalizations 的本地化代理实现
class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.isSupported(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    // 根据语言代码返回对应的实现
    switch (locale.languageCode) {
      case 'zh':
        return AppLocalizationsZh(locale);
      case 'en':
        return AppLocalizationsEn(locale);
      default:
        // 默认使用中文
        return AppLocalizationsZh(locale);
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

