import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'power_up.dart';

/// 道具管理器 - 负责道具的存储、获取和使用
class PowerUpManager {
  static const String _storageKey = 'block_blast_power_ups';
  
  // 全局实例（用于兼容静态访问层）
  static PowerUpManager? _globalInstance;
  
  // 默认构造函数
  PowerUpManager();
  
  /// 设置全局实例（由 Provider 初始化时调用）
  static void setGlobalInstance(PowerUpManager instance) {
    _globalInstance = instance;
  }
  
  /// 获取全局实例（用于兼容静态访问层）
  static PowerUpManager get instance {
    if (_globalInstance == null) {
      throw StateError(
        'PowerUpManager not initialized. '
        'Make sure the app is wrapped in ProviderScope and the provider is accessed at least once.'
      );
    }
    return _globalInstance!;
  }

  /// 获取所有道具数量
  Future<Map<PowerUpType, int>> getPowerUpCounts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    
    if (jsonStr == null) {
      // 默认：每种道具 0 个
      return {
        PowerUpType.bomb: 0,
        PowerUpType.refresh: 0,
        PowerUpType.undo: 0,
      };
    }
    
    final Map<String, dynamic> json = jsonDecode(jsonStr);
    return {
      PowerUpType.bomb: json['bomb'] ?? 0,
      PowerUpType.refresh: json['refresh'] ?? 0,
      PowerUpType.undo: json['undo'] ?? 0,
    };
  }

  /// 获取指定道具的数量
  Future<int> getPowerUpCount(PowerUpType type) async {
    final counts = await getPowerUpCounts();
    return counts[type] ?? 0;
  }

  /// 增加道具数量
  Future<void> addPowerUp(PowerUpType type, {int count = 1}) async {
    final counts = await getPowerUpCounts();
    counts[type] = (counts[type] ?? 0) + count;
    await _savePowerUpCounts(counts);
  }

  /// 使用道具（减少数量）
  Future<bool> usePowerUp(PowerUpType type) async {
    final counts = await getPowerUpCounts();
    final currentCount = counts[type] ?? 0;
    
    if (currentCount <= 0) {
      return false; // 道具数量不足
    }
    
    counts[type] = currentCount - 1;
    await _savePowerUpCounts(counts);
    return true;
  }

  /// 保存道具数量
  Future<void> _savePowerUpCounts(Map<PowerUpType, int> counts) async {
    final prefs = await SharedPreferences.getInstance();
    final json = {
      'bomb': counts[PowerUpType.bomb] ?? 0,
      'refresh': counts[PowerUpType.refresh] ?? 0,
      'undo': counts[PowerUpType.undo] ?? 0,
    };
    await prefs.setString(_storageKey, jsonEncode(json));
  }

  /// 重置所有道具（用于测试或重置游戏）
  Future<void> resetPowerUps() async {
    await _savePowerUpCounts({
      PowerUpType.bomb: 0,
      PowerUpType.refresh: 0,
      PowerUpType.undo: 0,
    });
  }

  /// 初始化新游戏 - 给玩家一个随机道具
  Future<void> initializeNewGame() async {
    final randomType = PowerUpLogic.getRandomPowerUpType();
    await addPowerUp(randomType);
  }

  /// 奖励道具（基于成就）
  /// 
  /// [combo] - 连击数
  /// [clearedRows] - 消除的行数
  /// [clearedCols] - 消除的列数
  Future<void> rewardPowerUpIfNeeded({
    required int combo,
    int clearedRows = 0,
    int clearedCols = 0,
  }) async {
    if (PowerUpLogic.shouldRewardPowerUp(
      combo: combo,
      clearedRows: clearedRows,
      clearedCols: clearedCols,
    )) {
      final randomType = PowerUpLogic.getRandomPowerUpType();
      await addPowerUp(randomType);
    }
  }

  /// 检查是否有可用的道具
  Future<bool> hasAnyPowerUp() async {
    final counts = await getPowerUpCounts();
    return counts.values.any((count) => count > 0);
  }
}
