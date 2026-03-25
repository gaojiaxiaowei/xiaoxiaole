// lib/ui/game/controllers/game_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/game/providers.dart';
import '../../../providers/game/game_state.dart' hide GameStats;
import '../../../providers/theme/theme_provider.dart';
import '../../../game/block.dart';
import '../../../game/power_up.dart';
import '../../../game/haptic.dart';
import '../../../game/stats_manager.dart' as stats;
import '../managers/timer_manager.dart';
import '../../game_over_dialog.dart';
import '../power_up_mixin.dart';

/// 游戏控制器 - 管理游戏业务逻辑
class GameController with PowerUpMixin {
  final WidgetRef _ref;
  final TimerManager _timerManager;
  final TickerProvider _tickerProvider;
  final Function(void Function()) _setState;
  final VoidCallback _showPlaceDialog;

  bool _isBombSelectionMode = false;
  int _lastScoreIncrease = 0;

  bool get isBombSelectionMode => _isBombSelectionMode;
  int get lastScoreIncrease => _lastScoreIncrease;

  GameController(
    this._ref,
    this._tickerProvider,
    this._setState,
    this._showPlaceDialog,
  ) : _timerManager = TimerManager(_ref) {
    initPowerUpSystem();
    initPowerUpAnimations(_tickerProvider);
  }

  /// 初始化游戏模式
  void initGameMode(GameMode mode) {
    _ref.read(gameModeProvider.notifier).state = mode;

    // 计时模式启动倒计时
    if (mode == GameMode.timed) {
      _timerManager.startCountdown();
    }
  }

  /// 放置方块
  void placeBlock(int gridX, int gridY, Block block) {
    final gameState = _ref.read(gameProvider);
    saveCurrentState(gameState.grid, gameState.availableBlocks, gameState.score);

    // 计算分数增量
    final scoreIncrease = block.shape.length;
    _setState(() {
      _lastScoreIncrease = scoreIncrease;
    });

    _ref.read(gameProvider.notifier).placeBlock(gridX, gridY, block);
  }

  /// 选中方块
  void selectBlock(Block? block) {
    _ref.read(gameProvider.notifier).selectBlock(block);
  }

  /// 切换暂停状态
  void togglePause() {
    _ref.read(gameProvider.notifier).togglePause();
  }

  /// 使用道具
  void onPowerUpTap(PowerUpType type) {
    if (isUsingPowerUp) {
      cancelPowerUp();
      return;
    }

    switch (type) {
      case PowerUpType.bomb:
        _showBombSelectionDialog();
        break;
      case PowerUpType.refresh:
        _useRefreshPowerUp();
        break;
      case PowerUpType.undo:
        _useUndoPowerUp();
        break;
    }
  }

  /// 使用炸弹
  void useBomb(int gridX, int gridY) {
    _ref.read(gameProvider.notifier).useBomb(gridX, gridY, 0);
    _setState(() {
      _isBombSelectionMode = false;
    });
  }

  /// 重置分数增量
  void resetScoreIncrease() {
    _setState(() {
      _lastScoreIncrease = 0;
    });
  }

  /// 显示游戏结束对话框
  void showGameOverDialog(BuildContext context) {
    final gameState = _ref.read(gameProvider);
    final isNewRecord =
        gameState.score >= gameState.highScore && gameState.score > 0;

    // 转换 GameMode 类型
    stats.GameMode convertGameMode(GameMode mode) {
      switch (mode) {
        case GameMode.timed:
          return stats.GameMode.timed;
        case GameMode.classic:
        case GameMode.daily:
        default:
          return stats.GameMode.classic;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => GameOverDialogContent(
        score: gameState.score,
        highScore: gameState.highScore,
        isNewRecord: isNewRecord,
        stats: GameStats(
          score: gameState.score,
          blocksPlaced: gameState.stats.rowsCleared + gameState.stats.colsCleared, // 近似
          rowsCleared: gameState.stats.rowsCleared,
          colsCleared: gameState.stats.colsCleared,
          maxCombo: gameState.stats.maxCombo,
        ),
        gameMode: convertGameMode(gameState.gameMode),
        onPlayAgain: () {
          Navigator.pop(context);
          _ref.read(gameProvider.notifier).startNewGame();
        },
        highScoreText: '最高分',
        playAgainText: '再来一局',
        gameOverText: '游戏结束',
      ),
    );
  }

  // 私有方法

  void _showBombSelectionDialog() {
    final theme = _ref.read(themeManagerProvider).currentTheme;
    // 这里需要BuildContext，将在GamePage中实现
  }

  void _useRefreshPowerUp() {
    _ref.read(gameProvider.notifier).refreshBlocks();
    HapticManager.light();
  }

  void _useUndoPowerUp() {
    final success = _ref.read(gameProvider.notifier).undo();
    if (success) {
      HapticManager.light();
    }
  }

  /// 释放资源
  void dispose() {
    _timerManager.dispose();
    disposePowerUpSystem();
  }
}
