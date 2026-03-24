// lib/ui/game/managers/timer_manager.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/game/providers.dart';

/// 计时模式管理器
class TimerManager {
  final Ref _ref;
  Timer? _gameTimer;

  TimerManager(this._ref);

  /// 启动倒计时
  void startCountdown() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentState = _ref.read(gameProvider);
      if (currentState.isPaused || currentState.isGameOver) {
        return;
      }

      final newSeconds = currentState.remainingSeconds - 1;
      _ref.read(gameProvider.notifier).updateRemainingSeconds(newSeconds);

      if (newSeconds <= 0) {
        timer.cancel();
        _ref.read(gameProvider.notifier).onTimeUp();
      }
    });
  }

  /// 停止计时器
  void stop() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  /// 释放资源
  void dispose() {
    stop();
  }
}
