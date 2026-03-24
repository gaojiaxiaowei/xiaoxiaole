// lib/providers/game/game_state.dart

import 'package:flutter/material.dart';
import '../../game/block.dart';

/// 游戏状态数据类（不可变）
@immutable
class GameState {
  /// 8x8 游戏网格
  final List<List<int>> grid;
  
  /// 当前可选方块
  final List<Block> availableBlocks;
  
  /// 当前选中的方块
  final Block? selectedBlock;
  
  /// 分数
  final int score;
  
  /// 最高分
  final int highScore;
  
  /// 游戏是否结束
  final bool isGameOver;
  
  /// 游戏是否暂停
  final bool isPaused;
  
  /// 游戏模式
  final GameMode gameMode;
  
  /// 拖拽状态
  final DragState dragState;
  
  /// 消除动画状态
  final ClearAnimationState? clearAnimation;
  
  /// 放置动画状态
  final PlaceAnimationState? placeAnimation;
  
  /// 连击状态
  final ComboState? comboState;
  
  /// 统计数据
  final GameStats stats;
  
  /// 计时模式剩余时间
  final int remainingSeconds;
  
  /// 是否时间用尽
  final bool isTimeUp;
  
  /// 炸弹选择模式
  final bool isBombSelectionMode;

  const GameState({
    required this.grid,
    required this.availableBlocks,
    this.selectedBlock,
    this.score = 0,
    this.highScore = 0,
    this.isGameOver = false,
    this.isPaused = false,
    this.gameMode = GameMode.classic,
    this.dragState = const DragState(),
    this.clearAnimation,
    this.placeAnimation,
    this.comboState,
    this.stats = const GameStats(),
    this.remainingSeconds = 60,
    this.isTimeUp = false,
    this.isBombSelectionMode = false,
  });

  /// 初始状态
  static GameState initial() => GameState(
    grid: List.generate(8, (_) => List.generate(8, (_) => 0)),
    availableBlocks: [],
  );

  /// copyWith 方法
  GameState copyWith({
    List<List<int>>? grid,
    List<Block>? availableBlocks,
    Block? selectedBlock,
    bool clearSelectedBlock = false,
    int? score,
    int? highScore,
    bool? isGameOver,
    bool? isPaused,
    GameMode? gameMode,
    DragState? dragState,
    ClearAnimationState? clearAnimation,
    bool clearClearAnimation = false,
    PlaceAnimationState? placeAnimation,
    bool clearPlaceAnimation = false,
    ComboState? comboState,
    bool clearComboState = false,
    GameStats? stats,
    int? remainingSeconds,
    bool? isTimeUp,
    bool? isBombSelectionMode,
  }) {
    return GameState(
      grid: grid ?? this.grid,
      availableBlocks: availableBlocks ?? this.availableBlocks,
      selectedBlock: clearSelectedBlock ? null : (selectedBlock ?? this.selectedBlock),
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      isGameOver: isGameOver ?? this.isGameOver,
      isPaused: isPaused ?? this.isPaused,
      gameMode: gameMode ?? this.gameMode,
      dragState: dragState ?? this.dragState,
      clearAnimation: clearClearAnimation ? null : (clearAnimation ?? this.clearAnimation),
      placeAnimation: clearPlaceAnimation ? null : (placeAnimation ?? this.placeAnimation),
      comboState: clearComboState ? null : (comboState ?? this.comboState),
      stats: stats ?? this.stats,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isTimeUp: isTimeUp ?? this.isTimeUp,
      isBombSelectionMode: isBombSelectionMode ?? this.isBombSelectionMode,
    );
  }
}

/// 游戏模式
enum GameMode {
  classic,
  timed,
  daily,
}

/// 拖拽状态
@immutable
class DragState {
  final bool isDragging;
  final Block? draggingBlock;
  final int? previewGridX;
  final int? previewGridY;
  final BlockPreviewData? previewData;

  const DragState({
    this.isDragging = false,
    this.draggingBlock,
    this.previewGridX,
    this.previewGridY,
    this.previewData,
  });

  DragState copyWith({
    bool? isDragging,
    Block? draggingBlock,
    bool clearDraggingBlock = false,
    int? previewGridX,
    bool clearPreviewGridX = false,
    int? previewGridY,
    bool clearPreviewGridY = false,
    BlockPreviewData? previewData,
    bool clearPreviewData = false,
  }) {
    return DragState(
      isDragging: isDragging ?? this.isDragging,
      draggingBlock: clearDraggingBlock ? null : (draggingBlock ?? this.draggingBlock),
      previewGridX: clearPreviewGridX ? null : (previewGridX ?? this.previewGridX),
      previewGridY: clearPreviewGridY ? null : (previewGridY ?? this.previewGridY),
      previewData: clearPreviewData ? null : (previewData ?? this.previewData),
    );
  }
}

/// 方块预览数据
@immutable
class BlockPreviewData {
  final List<Offset> previewPositions;
  final bool canPlace;

  const BlockPreviewData({
    required this.previewPositions,
    required this.canPlace,
  });
}

/// 消除动画状态
@immutable
class ClearAnimationState {
  final List<int> clearingRows;
  final List<int> clearingCols;
  final double animationValue;

  const ClearAnimationState({
    required this.clearingRows,
    required this.clearingCols,
    required this.animationValue,
  });

  ClearAnimationState copyWith({
    List<int>? clearingRows,
    List<int>? clearingCols,
    double? animationValue,
  }) {
    return ClearAnimationState(
      clearingRows: clearingRows ?? this.clearingRows,
      clearingCols: clearingCols ?? this.clearingCols,
      animationValue: animationValue ?? this.animationValue,
    );
  }
}

/// 放置动画状态
@immutable
class PlaceAnimationState {
  final List<Offset> placedPositions;
  final double animationValue;

  const PlaceAnimationState({
    required this.placedPositions,
    required this.animationValue,
  });
}

/// 连击状态
@immutable
class ComboState {
  final String text;
  final Color color;
  final int count;

  const ComboState({
    required this.text,
    required this.color,
    required this.count,
  });
}

/// 游戏统计
@immutable
class GameStats {
  final int rowsCleared;
  final int colsCleared;
  final int maxCombo;
  final DateTime? startTime;

  const GameStats({
    this.rowsCleared = 0,
    this.colsCleared = 0,
    this.maxCombo = 0,
    this.startTime,
  });

  GameStats copyWith({
    int? rowsCleared,
    int? colsCleared,
    int? maxCombo,
    DateTime? startTime,
  }) {
    return GameStats(
      rowsCleared: rowsCleared ?? this.rowsCleared,
      colsCleared: colsCleared ?? this.colsCleared,
      maxCombo: maxCombo ?? this.maxCombo,
      startTime: startTime ?? this.startTime,
    );
  }
}
