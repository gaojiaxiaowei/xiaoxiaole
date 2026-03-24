import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/power_up.dart';
import '../game/power_up_manager.dart';
import '../game/block.dart';
import '../game/themes/themes.dart';
import '../ad/ad_manager.dart';
import '../providers/power_up/power_up_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 道具系统 Mixin - 为游戏页面添加道具功能
mixin PowerUpMixin<T extends StatefulWidget> on ConsumerState<T> {
  // 道具相关状态
  Map<PowerUpType, int> _powerUpCounts = {
    PowerUpType.bomb: 0,
    PowerUpType.refresh: 0,
    PowerUpType.undo: 0,
  };
  
  PowerUpType? _usingPowerUpType; // 当前正在使用的道具类型

  // 撤销相关
  List<List<int>>? _lastGrid; // 上一步的网格状态
  List<Block>? _lastBlocks; // 上一步的方块
  int? _lastScore; // 上一步的分数
  
  // 道具动画
  AnimationController? _powerUpAnimationController;

  /// 初始化道具系统
  Future<void> initPowerUpSystem() async {
    // 加载道具数量
    _powerUpCounts = await ref.read(powerUpManagerProvider).getPowerUpCounts();

    // 给玩家一个随机道具
    await ref.read(powerUpManagerProvider).initializeNewGame();
    _powerUpCounts = await ref.read(powerUpManagerProvider).getPowerUpCounts();

    setState(() {});
  }
  
  /// 初始化道具动画控制器
  void initPowerUpAnimations(TickerProvider vsync) {
    _powerUpAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );
  }

  /// 释放道具动画资源
  void disposePowerUpSystem() {
    _powerUpAnimationController?.dispose();
  }
  
  /// 保存当前状态（用于撤销）
  void saveCurrentState(List<List<int>> grid, List<Block> blocks, int score) {
    _lastGrid = grid.map((row) => List<int>.from(row)).toList();
    _lastBlocks = blocks.map((block) => Block(
      id: block.id,
      shape: List<Offset>.from(block.shape),
      name: block.name,
    )).toList();
    _lastScore = score;
  }
  
  /// 使用道具
  /// 返回：是否成功使用
  Future<bool> usePowerUp(
    PowerUpType type, {
    required List<List<int>> grid,
    required int gridSize,
    int? targetX,
    int? targetY,
    Function(List<List<int>>, int)? onBombUsed,
    Function()? onRefreshUsed,
    Function(List<List<int>>?, List<Block>?, int?)? onUndoUsed,
  }) async {
    // 检查道具数量
    if ((_powerUpCounts[type] ?? 0) <= 0) {
      return false;
    }
    
    // 检查是否已经在使用道具
    if (_usingPowerUpType != null) {
      return false;
    }
    
    switch (type) {
      case PowerUpType.bomb:
        // 炸弹需要目标位置
        if (targetX == null || targetY == null) {
          setState(() {
            _usingPowerUpType = type;
          });
          return false; // 等待玩家选择位置
        }
        
        // 执行炸弹消除
        final result = PowerUpLogic.useBomb(grid, targetX, targetY, gridSize: gridSize);
        if (result.success && result.data != null) {
          final newGrid = result.data!['newGrid'] as List<List<int>>;
          final clearedCount = result.data!['clearedCount'] as int;
          final score = PowerUpLogic.calculateBombScore(clearedCount);
          
          // 使用道具
          await ref.read(powerUpManagerProvider).usePowerUp(type);
          _powerUpCounts = await ref.read(powerUpManagerProvider).getPowerUpCounts();

          onBombUsed?.call(newGrid, score);
          
          setState(() {
            _usingPowerUpType = null;
          });
          
          return true;
        }
        break;
        
      case PowerUpType.refresh:
        // 使用道具
        await ref.read(powerUpManagerProvider).usePowerUp(type);
        _powerUpCounts = await ref.read(powerUpManagerProvider).getPowerUpCounts();

        onRefreshUsed?.call();
        
        setState(() {
          _usingPowerUpType = null;
        });
        
        return true;
        
      case PowerUpType.undo:
        // 检查是否有保存的状态
        if (_lastGrid == null) {
          return false;
        }

        // 使用道具
        await ref.read(powerUpManagerProvider).usePowerUp(type);
        _powerUpCounts = await ref.read(powerUpManagerProvider).getPowerUpCounts();

        onUndoUsed?.call(_lastGrid, _lastBlocks, _lastScore);
        
        // 清除保存的状态
        _lastGrid = null;
        _lastBlocks = null;
        _lastScore = null;
        
        setState(() {
          _usingPowerUpType = null;
        });
        
        return true;
    }
    
    return false;
  }
  
  /// 取消使用道具
  void cancelPowerUp() {
    setState(() {
      _usingPowerUpType = null;
    });
  }
  
  /// 奖励道具（基于成就）
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
      await ref.read(powerUpManagerProvider).rewardPowerUpIfNeeded(
        combo: combo,
        clearedRows: clearedRows,
        clearedCols: clearedCols,
      );

      _powerUpCounts = await ref.read(powerUpManagerProvider).getPowerUpCounts();

      // 播放动画
      _powerUpAnimationController?.forward(from: 0.0);

      setState(() {});
    }
  }

  /// 获取当前使用的道具类型
  PowerUpType? get usingPowerUpType => _usingPowerUpType;
  
  /// 检查是否正在使用道具
  bool get isUsingPowerUp => _usingPowerUpType != null;
  
  /// 获取道具数量
  Map<PowerUpType, int> get powerUpCounts => _powerUpCounts;
}
