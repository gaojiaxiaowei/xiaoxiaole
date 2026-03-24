// lib/ui/game/power_up_mixin.dart

import 'package:flutter/scheduler.dart';
import '../../game/block.dart';
import '../../game/power_up_manager.dart';

/// 道具系统 Mixin - 为 GameController 提供道具功能
mixin PowerUpMixin {
  /// 道具管理器实例
  PowerUpManager? _powerUpManager;
  
  /// 是否正在使用道具
  bool _isUsingPowerUp = false;
  
  /// 当前使用的道具类型
  String? _currentPowerUpType;
  
  /// TickerProvider 用于动画
  TickerProvider? _tickerProvider;
  
  /// 动画控制器（如果需要）
  Ticker? _powerUpAnimationTicker;
  
  /// 初始化道具系统
  void initPowerUpSystem() {
    _powerUpManager = PowerUpManager.instance;
  }
  
  /// 初始化道具动画
  void initPowerUpAnimations(TickerProvider tickerProvider) {
    _tickerProvider = tickerProvider;
  }
  
  /// 是否正在使用道具
  bool get isUsingPowerUp => _isUsingPowerUp;
  
  /// 当前道具类型
  String? get currentPowerUpType => _currentPowerUpType;
  
  /// 开始使用道具
  void startUsingPowerUp(String type) {
    _isUsingPowerUp = true;
    _currentPowerUpType = type;
  }
  
  /// 取消道具使用
  void cancelPowerUp() {
    _isUsingPowerUp = false;
    _currentPowerUpType = null;
  }
  
  /// 保存当前游戏状态（用于撤销功能）
  void saveCurrentState(
    List<List<int>> grid,
    List<Block> availableBlocks,
    int score,
  ) {
    // 保存状态到内存，用于撤销功能
    // 实际实现可能需要保存到 provider 或其他状态管理
  }
  
  /// 释放道具系统资源
  void disposePowerUpSystem() {
    _powerUpAnimationTicker?.dispose();
    _powerUpAnimationTicker = null;
    _powerUpManager = null;
    _tickerProvider = null;
  }
}
