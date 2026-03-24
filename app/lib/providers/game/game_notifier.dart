// lib/providers/game/game_notifier.dart

import 'dart:ui' show Offset, Color;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/block.dart';
import '../../game/clear.dart';
import '../../game/sound.dart';
import '../../game/haptic.dart';
import '../../game/stats_manager.dart' hide GameMode;
import '../../game/power_up.dart';
import '../../core/error_handler.dart';
import '../stats/stats_provider.dart';
import 'game_state.dart';

/// 游戏状态控制器
class GameNotifier extends StateNotifier<GameState> {
  GameNotifier({
    required String difficulty,
    required GameMode gameMode,
    required this.ref,
  }) : _difficulty = difficulty,
       _gameMode = gameMode,
       super(GameState.initial()) {
    _initGame();
  }

  final String _difficulty;
  final GameMode _gameMode;
  final Ref ref;
  
  /// 用于撤销的状态快照
  List<List<int>>? _lastGrid;
  List<Block>? _lastBlocks;
  int? _lastScore;

  /// 初始化游戏
  Future<void> _initGame() async {
    // 加载最高分
    final highScore = await _loadHighScore();
    
    state = state.copyWith(
      highScore: highScore,
      gameMode: _gameMode,
      stats: GameStats(startTime: DateTime.now()),
    );
    
    startNewGame();
  }

  /// 开始新游戏
  void startNewGame() {
    state = state.copyWith(
      grid: List.generate(8, (_) => List.generate(8, (_) => 0)),
      availableBlocks: Block.getBlocksByUserDifficulty(_difficulty, 0),
      selectedBlock: null,
      score: 0,
      isGameOver: false,
      isPaused: false,
      dragState: const DragState(),
      clearClearAnimation: true,
      clearPlaceAnimation: true,
      clearComboState: true,
      stats: const GameStats(startTime: null),
      remainingSeconds: 60,
      isTimeUp: false,
      isBombSelectionMode: false,
    );
    
    // 更新开始时间
    state = state.copyWith(stats: GameStats(startTime: DateTime.now()));
  }

  /// 放置方块
  void placeBlock(int gridX, int gridY, Block block) {
    if (state.isGameOver || state.isPaused) return;
    if (!ClearLogic.canPlace(state.grid, gridX, gridY, block.shape)) return;

    // 保存当前状态用于撤销
    _saveCurrentState();

    // 计算放置位置
    final placedPositions = block.shape.map((offset) {
      return Offset(gridX + offset.dx, gridY + offset.dy);
    }).toList();

    // 放置方块
    final newGrid = ClearLogic.placeBlock(state.grid, gridX, gridY, block.shape);

    // 播放音效和震动
    SoundManager.playPlace();
    HapticManager.placeSuccess();

    // 设置放置动画状态
    state = state.copyWith(
      grid: newGrid,
      placeAnimation: PlaceAnimationState(
        placedPositions: placedPositions,
        animationValue: 0.0,
      ),
      dragState: const DragState(),
    );
  }

  /// 更新放置动画进度
  void updatePlaceAnimation(double value) {
    if (state.placeAnimation == null) return;
    state = state.copyWith(
      placeAnimation: PlaceAnimationState(
        placedPositions: state.placeAnimation!.placedPositions,
        animationValue: value,
      ),
    );
  }

  /// 放置动画完成，检查消除
  void onPlaceAnimationComplete() {
    if (state.placeAnimation == null) return;
    
    final (rowsToClear, colsToClear) = ClearLogic.checkClearPositions(state.grid);
    
    if (rowsToClear.isNotEmpty || colsToClear.isNotEmpty) {
      _startClearAnimation(rowsToClear, colsToClear);
    } else {
      _updateStateAfterClear(state.grid, 0, 0);
    }
    
    // 清除放置动画
    state = state.copyWith(clearPlaceAnimation: true);
  }

  /// 开始消除动画
  void _startClearAnimation(List<int> rowsToClear, List<int> colsToClear) {
    SoundManager.playClear();
    
    final totalCleared = rowsToClear.length + colsToClear.length;
    if (totalCleared >= 2) {
      HapticManager.heavy();
    } else {
      HapticManager.medium();
    }

    state = state.copyWith(
      clearAnimation: ClearAnimationState(
        clearingRows: rowsToClear,
        clearingCols: colsToClear,
        animationValue: 0.0,
      ),
    );
  }

  /// 更新消除动画进度
  void updateClearAnimation(double value) {
    if (state.clearAnimation == null) return;
    state = state.copyWith(
      clearAnimation: state.clearAnimation!.copyWith(animationValue: value),
    );
  }

  /// 消除动画完成，执行消除并检查连锁
  void onClearAnimationComplete() {
    if (state.clearAnimation == null) return;
    
    final rowsToClear = state.clearAnimation!.clearingRows;
    final colsToClear = state.clearAnimation!.clearingCols;
    final totalCleared = rowsToClear.length + colsToClear.length;

    // 更新统计
    final newStats = state.stats.copyWith(
      rowsCleared: state.stats.rowsCleared + rowsToClear.length,
      colsCleared: state.stats.colsCleared + colsToClear.length,
      maxCombo: totalCleared > state.stats.maxCombo ? totalCleared : state.stats.maxCombo,
    );

    // 显示连击特效
    if (totalCleared >= 2) {
      _showComboEffect(totalCleared);
    }

    // 执行消除
    final newGrid = ClearLogic.clearRowsAndCols(state.grid, rowsToClear, colsToClear);
    
    // 检查连锁消除
    final (nextRows, nextCols) = ClearLogic.checkClearPositions(newGrid);
    
    if (nextRows.isNotEmpty || nextCols.isNotEmpty) {
      SoundManager.playCombo(2);
      _startClearAnimation(nextRows, nextCols);
    } else {
      final score = ClearLogic.calculateScore(rowsToClear.length, colsToClear.length);
      _updateStateAfterClear(newGrid, score, totalCleared);
      state = state.copyWith(stats: newStats);
    }
    
    // 清除消除动画
    state = state.copyWith(clearClearAnimation: true);
  }

  /// 消除后更新状态
  void _updateStateAfterClear(List<List<int>> newGrid, int clearScore, int clearedCount) {
    // 移除已使用的方块
    final newBlocks = state.availableBlocks
        .where((b) => b.id != state.dragState.draggingBlock?.id)
        .toList();

    // 如果方块池空了，生成新的
    final blocks = newBlocks.isEmpty 
        ? Block.getBlocksByUserDifficulty(_difficulty, state.score)
        : newBlocks;

    final totalIncrease = clearScore + (state.dragState.draggingBlock?.shape.length ?? 0);
    final newScore = state.score + totalIncrease;
    final newHighScore = newScore > state.highScore ? newScore : state.highScore;

    state = state.copyWith(
      grid: newGrid,
      availableBlocks: blocks,
      clearSelectedBlock: true,
      score: newScore,
      highScore: newHighScore,
    );

    // 保存最高分
    if (newScore > state.highScore) {
      _saveHighScore(newHighScore);
    }

    // 检查游戏结束
    _checkGameOver();
  }

  /// 显示连击特效
  void _showComboEffect(int combo) {
    String text;
    Color color;

    if (combo >= 5) {
      text = 'AMAZING!';
      color = const Color(0xFF9C27B0);
    } else if (combo >= 4) {
      text = 'EXCELLENT!';
      color = const Color(0xFFF44336);
    } else if (combo >= 3) {
      text = 'GREAT!';
      color = const Color(0xFFFF9800);
    } else {
      text = 'GOOD!';
      color = const Color(0xFFFFEB3B);
    }

    state = state.copyWith(
      comboState: ComboState(text: text, color: color, count: combo),
    );
  }

  /// 清除连击特效
  void clearComboEffect() {
    state = state.copyWith(clearComboState: true);
  }

  /// 检查游戏结束
  void _checkGameOver() {
    final availableShapes = state.availableBlocks.map((b) => b.shape).toList();
    if (ClearLogic.isGameOver(state.grid, availableShapes)) {
      state = state.copyWith(isGameOver: true);
      SoundManager.playGameOver();
      HapticManager.long();
      
      // 保存分数历史
      ref.read(statsManagerProvider).addScoreToHistory(
        state.score,
        rowsCleared: state.stats.rowsCleared,
        colsCleared: state.stats.colsCleared,
      );
    }
  }

  /// 更新拖拽状态
  void updateDragState(DragState dragState) {
    state = state.copyWith(dragState: dragState);
  }

  /// 更新预览
  void updatePreview(int gridX, int gridY, Block block) {
    if (state.dragState.previewGridX == gridX && 
        state.dragState.previewGridY == gridY && 
        state.dragState.draggingBlock == block) {
      return;
    }

    final previewPositions = block.shape.map((offset) {
      return Offset(gridX + offset.dx, gridY + offset.dy);
    }).toList();

    final canPlace = ClearLogic.canPlace(state.grid, gridX, gridY, block.shape);

    state = state.copyWith(
      dragState: state.dragState.copyWith(
        isDragging: true,
        draggingBlock: block,
        previewGridX: gridX,
        previewGridY: gridY,
        previewData: BlockPreviewData(
          previewPositions: previewPositions,
          canPlace: canPlace,
        ),
      ),
      selectedBlock: block,
    );
  }

  /// 清除预览
  void clearPreview() {
    state = state.copyWith(
      dragState: const DragState(),
    );
  }

  /// 选择方块
  void selectBlock(Block? block) {
    state = state.copyWith(selectedBlock: block);
  }

  /// 暂停/继续游戏
  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  /// 更新倒计时
  void updateRemainingSeconds(int seconds) {
    state = state.copyWith(remainingSeconds: seconds);
  }

  /// 时间用尽
  void onTimeUp() {
    state = state.copyWith(
      isTimeUp: true,
      isGameOver: true,
    );
    
    SoundManager.playGameOver();
    HapticManager.long();
    
    ref.read(statsManagerProvider).addScoreToHistory(
      state.score,
      rowsCleared: state.stats.rowsCleared,
      colsCleared: state.stats.colsCleared,
    );
  }

  /// 进入/退出炸弹选择模式
  void toggleBombSelectionMode() {
    state = state.copyWith(isBombSelectionMode: !state.isBombSelectionMode);
  }

  /// 保存当前状态（用于撤销）
  void _saveCurrentState() {
    _lastGrid = state.grid.map((row) => List<int>.from(row)).toList();
    _lastBlocks = state.availableBlocks.map((block) => Block(
      id: block.id,
      shape: List<Offset>.from(block.shape),
      name: block.name,
    )).toList();
    _lastScore = state.score;
  }

  /// 撤销
  bool undo() {
    if (_lastGrid == null) return false;

    state = state.copyWith(
      grid: _lastGrid!,
      availableBlocks: _lastBlocks!,
      score: _lastScore!,
    );

    _lastGrid = null;
    _lastBlocks = null;
    _lastScore = null;

    return true;
  }

  /// 刷新方块池
  void refreshBlocks() {
    state = state.copyWith(
      availableBlocks: Block.getBlocksByUserDifficulty(_difficulty, state.score),
    );
  }

  /// 炸弹消除
  void useBomb(int gridX, int gridY, int clearedCount) {
    final newGrid = List.generate(8, (row) => List.generate(8, (col) {
      // 3x3范围消除
      if ((row - gridY).abs() <= 1 && (col - gridX).abs() <= 1) {
        return 0;
      }
      return state.grid[row][col];
    }));

    final score = PowerUpLogic.calculateBombScore(clearedCount);
    
    state = state.copyWith(
      grid: newGrid,
      score: state.score + score,
      isBombSelectionMode: false,
    );
  }

  /// 加载最高分
  Future<int> _loadHighScore() async {
    return ErrorHandler.runGuardedAsync(
      () => ref.read(statsManagerProvider).getHighScore(),
      defaultValue: 0,
      context: 'loadHighScore',
    );
  }

  /// 保存最高分
  Future<void> _saveHighScore(int score) async {
    await ErrorHandler.runGuardedAsync(
      () => ref.read(statsManagerProvider).updateHighScore(score),
      context: 'saveHighScore',
    );
  }
}
