import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 分数记录类
class ScoreRecord {
  final int score;
  final DateTime date;
  final int rowsCleared;
  final int colsCleared;

  ScoreRecord(
    this.score,
    this.date, {
    this.rowsCleared = 0,
    this.colsCleared = 0,
  });

  Map<String, dynamic> toJson() => {
    'score': score,
    'date': date.toIso8601String(),
    'rowsCleared': rowsCleared,
    'colsCleared': colsCleared,
  };

  factory ScoreRecord.fromJson(Map<String, dynamic> json) => ScoreRecord(
    json['score'],
    DateTime.parse(json['date']),
    rowsCleared: json['rowsCleared'] ?? 0,
    colsCleared: json['colsCleared'] ?? 0,
  );
}

/// 游戏模式枚举
enum GameMode {
  classic,  // 经典模式
  timed,    // 计时模式
}

/// 游戏统计管理类
class StatsManager {
  // 存储Key
  static const String keyTotalGames = 'block_blast_total_games';
  static const String keyHighScore = 'block_blast_high_score';
  static const String keyHighScoreTimed = 'block_blast_high_score_timed'; // 计时模式最高分
  static const String keyTotalRowsCleared = 'block_blast_total_rows_cleared';
  static const String keyTotalColsCleared = 'block_blast_total_cols_cleared';
  static const String keyMaxCombo = 'block_blast_max_combo';
  static const String keyTotalPlayTime = 'block_blast_total_play_time'; // 秒
  static const String keyScoreHistory = 'block_blast_score_history'; // 分数历史
  static const String keyScoreHistoryTimed = 'block_blast_score_history_timed'; // 计时模式分数历史

  // 构造函数（移除单例模式）
  StatsManager();

  // 获取总游戏局数
  Future<int> getTotalGames() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyTotalGames) ?? 0;
  }

  // 获取最高分
  Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyHighScore) ?? 0;
  }

  // 获取累计消除行数
  Future<int> getTotalRowsCleared() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyTotalRowsCleared) ?? 0;
  }

  // 获取累计消除列数
  Future<int> getTotalColsCleared() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyTotalColsCleared) ?? 0;
  }

  // 获取最高连击
  Future<int> getMaxCombo() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyMaxCombo) ?? 0;
  }

  // 获取总游戏时长（秒）
  Future<int> getTotalPlayTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyTotalPlayTime) ?? 0;
  }

  // 增加游戏局数
  Future<void> incrementTotalGames() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(keyTotalGames) ?? 0;
    await prefs.setInt(keyTotalGames, current + 1);
  }

  // 更新最高分
  Future<void> updateHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(keyHighScore) ?? 0;
    if (score > current) {
      await prefs.setInt(keyHighScore, score);
    }
  }

  // 获取计时模式最高分
  Future<int> getHighScoreTimed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(keyHighScoreTimed) ?? 0;
  }

  // 更新计时模式最高分
  Future<void> updateHighScoreTimed(int score) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(keyHighScoreTimed) ?? 0;
    if (score > current) {
      await prefs.setInt(keyHighScoreTimed, score);
    }
  }

  // 增加消除行数
  Future<void> addRowsCleared(int rows) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(keyTotalRowsCleared) ?? 0;
    await prefs.setInt(keyTotalRowsCleared, current + rows);
  }

  // 增加消除列数
  Future<void> addColsCleared(int cols) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(keyTotalColsCleared) ?? 0;
    await prefs.setInt(keyTotalColsCleared, current + cols);
  }

  // 更新最高连击
  Future<void> updateMaxCombo(int combo) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(keyMaxCombo) ?? 0;
    if (combo > current) {
      await prefs.setInt(keyMaxCombo, combo);
    }
  }

  // 增加游戏时长（秒）
  Future<void> addPlayTime(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(keyTotalPlayTime) ?? 0;
    await prefs.setInt(keyTotalPlayTime, current + seconds);
  }

  // 获取所有统计数据
  Future<Map<String, int>> getAllStats() async {
    return {
      'totalGames': await getTotalGames(),
      'highScore': await getHighScore(),
      'totalRowsCleared': await getTotalRowsCleared(),
      'totalColsCleared': await getTotalColsCleared(),
      'maxCombo': await getMaxCombo(),
      'totalPlayTime': await getTotalPlayTime(),
    };
  }

  // 添加分数到历史记录（只保留最近10局）
  Future<void> addScoreToHistory(int score, {int rowsCleared = 0, int colsCleared = 0, GameMode mode = GameMode.classic}) async {
    if (score <= 0) return; // 不记录0分
    
    final prefs = await SharedPreferences.getInstance();
    final key = mode == GameMode.classic ? keyScoreHistory : keyScoreHistoryTimed;
    
    List<ScoreRecord> history = await getScoreHistory(mode: mode);
    
    // 添加新记录
    history.insert(0, ScoreRecord(score, DateTime.now(), rowsCleared: rowsCleared, colsCleared: colsCleared));
    
    // 只保留最近10局
    if (history.length > 10) {
      history = history.sublist(0, 10);
    }
    
    // 保存
    final jsonList = history.map((r) => r.toJson()).toList();
    await prefs.setString(key, json.encode(jsonList));
  }

  // 获取分数历史记录
  Future<List<ScoreRecord>> getScoreHistory({GameMode mode = GameMode.classic}) async {
    final prefs = await SharedPreferences.getInstance();
    final key = mode == GameMode.classic ? keyScoreHistory : keyScoreHistoryTimed;
    final jsonStr = prefs.getString(key);
    if (jsonStr == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(jsonStr);
      return jsonList
          .map((json) => ScoreRecord.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  // 重置所有统计数据
  Future<void> resetAllStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(keyTotalGames);
    await prefs.remove(keyHighScore);
    await prefs.remove(keyHighScoreTimed);
    await prefs.remove(keyTotalRowsCleared);
    await prefs.remove(keyTotalColsCleared);
    await prefs.remove(keyMaxCombo);
    await prefs.remove(keyTotalPlayTime);
    await prefs.remove(keyScoreHistory);
    await prefs.remove(keyScoreHistoryTimed);
  }
}
