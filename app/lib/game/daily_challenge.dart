import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

/// 挑战类型枚举
enum ChallengeType {
  score,    // 分数挑战：达到指定分数
  clear,    // 消除挑战：消除指定行/列数
  combo,    // 连击挑战：达成指定连击数
}

/// 每日挑战数据类
class DailyChallenge {
  final DateTime date;           // 挑战日期
  final ChallengeType type;      // 挑战类型
  final int target;              // 目标值（分数/行数/连击数）
  final bool isCompleted;        // 是否完成
  final DateTime? completedTime; // 完成时间
  final int progress;            // 当前进度

  DailyChallenge({
    required this.date,
    required this.type,
    required this.target,
    this.isCompleted = false,
    this.completedTime,
    this.progress = 0,
  });

  // 获取挑战描述
  String get description {
    switch (type) {
      case ChallengeType.score:
        return '达到 $target 分';
      case ChallengeType.clear:
        return '消除 $target 行/列';
      case ChallengeType.combo:
        return '达成 $target 连击';
    }
  }

  // 获取奖励描述
  String get reward {
    switch (type) {
      case ChallengeType.score:
        return '🏆 评分 x2';
      case ChallengeType.clear:
        return '⭐ 经验 +100';
      case ChallengeType.combo:
        return '💎 连击大师';
    }
  }

  // 获取进度百分比
  double get progressPercentage {
    if (target == 0) return 0;
    return (progress / target).clamp(0.0, 1.0);
  }

  // 转换为JSON
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'type': type.index,
    'target': target,
    'isCompleted': isCompleted,
    'completedTime': completedTime?.toIso8601String(),
    'progress': progress,
  };

  // 从JSON创建
  factory DailyChallenge.fromJson(Map<String, dynamic> json) {
    return DailyChallenge(
      date: DateTime.parse(json['date']),
      type: ChallengeType.values[json['type']],
      target: json['target'],
      isCompleted: json['isCompleted'] ?? false,
      completedTime: json['completedTime'] != null 
          ? DateTime.parse(json['completedTime']) 
          : null,
      progress: json['progress'] ?? 0,
    );
  }

  // 复制并更新
  DailyChallenge copyWith({
    DateTime? date,
    ChallengeType? type,
    int? target,
    bool? isCompleted,
    DateTime? completedTime,
    int? progress,
  }) {
    return DailyChallenge(
      date: date ?? this.date,
      type: type ?? this.type,
      target: target ?? this.target,
      isCompleted: isCompleted ?? this.isCompleted,
      completedTime: completedTime ?? this.completedTime,
      progress: progress ?? this.progress,
    );
  }
}

/// 每日挑战管理类
class DailyChallengeManager {
  // 存储Key
  static const String keyCurrentChallenge = 'block_blast_daily_challenge';
  static const String keyChallengeHistory = 'block_blast_challenge_history';
  
  // 全局实例（用于兼容静态访问层）
  static DailyChallengeManager? _globalInstance;
  
  // 构造函数（移除单例模式）
  DailyChallengeManager();
  
  /// 设置全局实例（由 Provider 初始化时调用）
  static void setGlobalInstance(DailyChallengeManager instance) {
    _globalInstance = instance;
  }
  
  /// 获取全局实例（用于兼容静态访问层）
  static DailyChallengeManager get instance {
    if (_globalInstance == null) {
      throw StateError(
        'DailyChallengeManager not initialized. '
        'Make sure the app is wrapped in ProviderScope and the provider is accessed at least once.'
      );
    }
    return _globalInstance!;
  }

  // 随机数生成器（基于日期种子）
  Random _getSeededRandom(DateTime date) {
    final seed = date.year * 10000 + date.month * 100 + date.day;
    return Random(seed);
  }

  // 生成每日挑战
  DailyChallenge generateChallenge(DateTime date) {
    final random = _getSeededRandom(date);
    
    // 随机选择挑战类型
    final typeIndex = random.nextInt(ChallengeType.values.length);
    final type = ChallengeType.values[typeIndex];
    
    // 根据类型生成目标值
    int target;
    switch (type) {
      case ChallengeType.score:
        // 分数目标：300-1000
        target = 300 + random.nextInt(701); // 300-1000
        break;
      case ChallengeType.clear:
        // 消除目标：10-30行/列
        target = 10 + random.nextInt(21); // 10-30
        break;
      case ChallengeType.combo:
        // 连击目标：2-5连击
        target = 2 + random.nextInt(4); // 2-5
        break;
    }
    
    return DailyChallenge(
      date: date,
      type: type,
      target: target,
    );
  }

  // 获取今日挑战
  Future<DailyChallenge> getTodayChallenge() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayDate();
    
    // 尝试从缓存加载
    final jsonStr = prefs.getString(keyCurrentChallenge);
    if (jsonStr != null) {
      try {
        final challenge = DailyChallenge.fromJson(
          json.decode(jsonStr) as Map<String, dynamic>
        );
        
        // 检查是否是今天的挑战
        if (_isSameDay(challenge.date, today)) {
          return challenge;
        }
        
        // 不是今天的挑战，保存到历史
        if (challenge.isCompleted) {
          await _saveToHistory(challenge);
        }
      } catch (e) {
        // 解析失败，生成新挑战
      }
    }
    
    // 生成新的今日挑战
    final newChallenge = generateChallenge(today);
    await _saveChallenge(newChallenge);
    return newChallenge;
  }

  // 更新挑战进度
  Future<DailyChallenge> updateProgress({
    int? score,
    int? clearedLines,
    int? maxCombo,
  }) async {
    final challenge = await getTodayChallenge();
    if (challenge.isCompleted) return challenge;
    
    int newProgress = challenge.progress;
    
    // 根据挑战类型更新进度
    switch (challenge.type) {
      case ChallengeType.score:
        if (score != null && score > newProgress) {
          newProgress = score;
        }
        break;
      case ChallengeType.clear:
        if (clearedLines != null) {
          newProgress = challenge.progress + clearedLines;
        }
        break;
      case ChallengeType.combo:
        if (maxCombo != null && maxCombo > newProgress) {
          newProgress = maxCombo;
        }
        break;
    }
    
    // 检查是否完成
    final isCompleted = newProgress >= challenge.target;
    
    // 更新挑战
    final updatedChallenge = challenge.copyWith(
      progress: newProgress,
      isCompleted: isCompleted,
      completedTime: isCompleted ? DateTime.now() : null,
    );
    
    await _saveChallenge(updatedChallenge);
    
    // 如果刚完成，保存到历史
    if (isCompleted && !challenge.isCompleted) {
      await _saveToHistory(updatedChallenge);
    }
    
    return updatedChallenge;
  }

  // 保存挑战
  Future<void> _saveChallenge(DailyChallenge challenge) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      keyCurrentChallenge, 
      json.encode(challenge.toJson())
    );
  }

  // 保存到历史
  Future<void> _saveToHistory(DailyChallenge challenge) async {
    final prefs = await SharedPreferences.getInstance();
    
    // 加载历史
    final jsonStr = prefs.getString(keyChallengeHistory);
    List<DailyChallenge> history = [];
    
    if (jsonStr != null) {
      try {
        final List<dynamic> jsonList = json.decode(jsonStr);
        history = jsonList
            .map((json) => DailyChallenge.fromJson(json as Map<String, dynamic>))
            .toList();
      } catch (e) {
        history = [];
      }
    }
    
    // 添加新记录（避免重复）
    final existingIndex = history.indexWhere((c) => _isSameDay(c.date, challenge.date));
    if (existingIndex >= 0) {
      history[existingIndex] = challenge;
    } else {
      history.insert(0, challenge);
    }
    
    // 只保留最近30天
    if (history.length > 30) {
      history = history.sublist(0, 30);
    }
    
    // 保存
    final jsonList = history.map((c) => c.toJson()).toList();
    await prefs.setString(keyChallengeHistory, json.encode(jsonList));
  }

  // 获取挑战历史
  Future<List<DailyChallenge>> getChallengeHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(keyChallengeHistory);
    
    if (jsonStr == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(jsonStr);
      return jsonList
          .map((json) => DailyChallenge.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // 获取连续完成天数
  Future<int> getStreakDays() async {
    final history = await getChallengeHistory();
    if (history.isEmpty) return 0;
    
    // 按日期排序
    history.sort((a, b) => b.date.compareTo(a.date));
    
    int streak = 0;
    DateTime? lastDate;
    
    for (final challenge in history) {
      if (!challenge.isCompleted) break;
      
      if (lastDate == null) {
        // 第一条记录
        if (_isSameDay(challenge.date, _getTodayDate()) ||
            _isYesterday(challenge.date)) {
          streak = 1;
          lastDate = challenge.date;
        } else {
          break;
        }
      } else {
        // 检查是否是连续的前一天
        if (_isConsecutiveDay(challenge.date, lastDate)) {
          streak++;
          lastDate = challenge.date;
        } else {
          break;
        }
      }
    }
    
    return streak;
  }

  // 辅助方法：获取今天的日期（去除时分秒）
  DateTime _getTodayDate() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // 辅助方法：判断是否是同一天
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // 辅助方法：判断是否是昨天
  bool _isYesterday(DateTime date) {
    final yesterday = _getTodayDate().subtract(const Duration(days: 1));
    return _isSameDay(date, yesterday);
  }

  // 辅助方法：判断是否是连续的前一天
  bool _isConsecutiveDay(DateTime earlier, DateTime later) {
    final difference = later.difference(earlier);
    return difference.inDays == 1;
  }

  // 重置挑战数据（用于测试）
  Future<void> resetChallengeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyCurrentChallenge);
    await prefs.remove(keyChallengeHistory);
  }
}
