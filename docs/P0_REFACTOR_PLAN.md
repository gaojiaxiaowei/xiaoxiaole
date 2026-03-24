# Block Blast P0 重构详细方案

## 概述

**目标**：将 `game_page.dart`（1778行）重构为清晰的架构，引入 Riverpod 状态管理，拆分文件，优化动画。

**当前问题**：
- 单文件1778行，难以维护
- 状态管理混乱（20+个State变量）
- 动画控制器生命周期管理复杂
- 业务逻辑与UI耦合严重

---

## 1. 状态管理重构方案

### 1.1 Provider 定义

需要创建的 Provider 文件结构：

```
lib/providers/
├── game/
│   ├── game_state.dart          # 游戏状态数据类
│   ├── game_state.freezed.dart  # freezed生成（可选）
│   ├── game_notifier.dart       # 游戏状态控制器
│   └── providers.dart           # 所有Provider导出
├── settings/
│   └── settings_provider.dart   # 设置相关Provider
└── providers.dart               # 总导出文件
```

#### 1.1.1 GameState 数据类

```dart
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
```

#### 1.1.2 GameNotifier 状态控制器

```dart
// lib/providers/game/game_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/block.dart';
import '../../game/clear.dart';
import '../../game/sound.dart';
import '../../game/haptic.dart';
import '../../game/stats_manager.dart';
import 'game_state.dart';

/// 游戏状态控制器
class GameNotifier extends StateNotifier<GameState> {
  GameNotifier({
    required String difficulty,
    required GameMode gameMode,
  }) : _difficulty = difficulty,
       _gameMode = gameMode,
       super(GameState.initial()) {
    _initGame();
  }

  final String _difficulty;
  final GameMode _gameMode;
  
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
      StatsManager().addScoreToHistory(
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
    
    StatsManager().addScoreToHistory(
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
    // 使用 SharedPreferences 加载
    return StatsManager().getHighScore();
  }

  /// 保存最高分
  Future<void> _saveHighScore(int score) async {
    await StatsManager().saveHighScore(score);
  }
}
```

#### 1.1.3 Provider 定义文件

```dart
// lib/providers/game/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/block.dart';
import 'game_state.dart';
import 'game_notifier.dart';

/// 难度设置 Provider
final difficultyProvider = StateProvider<String>((ref) => 'normal');

/// 游戏模式 Provider
final gameModeProvider = StateProvider<GameMode>((ref) => GameMode.classic);

/// 游戏状态 Provider（主 Provider）
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final difficulty = ref.watch(difficultyProvider);
  final gameMode = ref.watch(gameModeProvider);
  return GameNotifier(difficulty: difficulty, gameMode: gameMode);
});

/// 网格状态 Provider（派生）
final gridProvider = Provider<List<List<int>>>((ref) {
  return ref.watch(gameProvider).grid;
});

/// 分数 Provider（派生）
final scoreProvider = Provider<int>((ref) {
  return ref.watch(gameProvider).score;
});

/// 最高分 Provider（派生）
final highScoreProvider = Provider<int>((ref) {
  return ref.watch(gameProvider).highScore;
});

/// 可用方块 Provider（派生）
final availableBlocksProvider = Provider<List<Block>>((ref) {
  return ref.watch(gameProvider).availableBlocks;
});

/// 选中方块 Provider（派生）
final selectedBlockProvider = Provider<Block?>((ref) {
  return ref.watch(gameProvider).selectedBlock;
});

/// 游戏是否结束 Provider（派生）
final isGameOverProvider = Provider<bool>((ref) {
  return ref.watch(gameProvider).isGameOver;
});

/// 游戏是否暂停 Provider（派生）
final isPausedProvider = Provider<bool>((ref) {
  return ref.watch(gameProvider).isPaused;
});

/// 拖拽状态 Provider（派生）
final dragStateProvider = Provider<DragState>((ref) {
  return ref.watch(gameProvider).dragState;
});

/// 消除动画 Provider（派生）
final clearAnimationProvider = Provider<ClearAnimationState?>((ref) {
  return ref.watch(gameProvider).clearAnimation;
});

/// 放置动画 Provider（派生）
final placeAnimationProvider = Provider<PlaceAnimationState?>((ref) {
  return ref.watch(gameProvider).placeAnimation;
});

/// 连击状态 Provider（派生）
final comboStateProvider = Provider<ComboState?>((ref) {
  return ref.watch(gameProvider).comboState;
});

/// 统计数据 Provider（派生）
final statsProvider = Provider<GameStats>((ref) {
  return ref.watch(gameProvider).stats;
});
```

#### 1.1.4 设置 Provider

```dart
// lib/providers/settings/settings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 网格线显示设置
final showGridLinesProvider = StateProvider<bool>((ref) => true);

/// 动画启用设置
final animationEnabledProvider = StateProvider<bool>((ref) => true);

/// 难度设置
final difficultyProvider = StateProvider<String>((ref) => 'normal');

/// 设置加载状态
final settingsLoadedProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  
  // 加载难度
  final difficultyIndex = prefs.getInt('block_blast_difficulty') ?? 1;
  ref.read(difficultyProvider.notifier).state = ['easy', 'normal', 'hard'][difficultyIndex];
  
  // 加载网格线设置
  ref.read(showGridLinesProvider.notifier).state = 
      prefs.getBool('block_blast_show_grid_lines') ?? true;
  
  // 加载动画设置
  ref.read(animationEnabledProvider.notifier).state = 
      prefs.getBool('block_blast_animation_enabled') ?? true;
});
```

### 1.2 迁移步骤

#### 步骤1：添加依赖

在 `pubspec.yaml` 中添加：

```yaml
dependencies:
  flutter_riverpod: ^2.4.9
```

#### 步骤2：修改 main.dart

```dart
// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}
```

#### 步骤3：创建 Provider 文件

按照上述结构创建所有 Provider 文件。

#### 步骤4：逐步迁移 game_page.dart

1. 保留原有 `_GamePageState` 作为参考
2. 创建新的 `GamePage` 使用 ConsumerWidget
3. 逐个替换状态访问为 `ref.watch()`
4. 逐个替换状态更新为 `ref.read().notifier.method()`

#### 步骤5：删除旧代码

确认功能正常后，删除旧的状态变量和方法。

---

## 2. game_page.dart 拆分方案

### 2.1 新文件结构

```
lib/ui/game/
├── game_page.dart              # 主页面（<200行）
├── game_state.dart             # 状态数据类（移到 providers/game/）
├── game_controller.dart        # 业务逻辑（移到 providers/game/game_notifier.dart）
├── providers/
│   ├── game_provider.dart      # 游戏相关Provider
│   └── settings_provider.dart  # 设置相关Provider
├── widgets/
│   ├── game_grid.dart          # 游戏网格组件
│   ├── block_pool.dart         # 方块池组件
│   ├── block_preview.dart      # 方块预览组件
│   ├── score_display.dart      # 分数显示组件
│   ├── combo_effect.dart       # 连击特效组件
│   ├── power_up_bar.dart       # 道具栏组件
│   ├── timed_mode_display.dart # 计时模式显示
│   └── pause_overlay.dart      # 暂停遮罩
├── mixins/
│   └── power_up_mixin.dart     # 道具系统Mixin（保留）
└── animations/
    ├── clear_animation_widget.dart   # 消除动画
    ├── place_animation_widget.dart   # 放置动画
    ├── combo_animation_widget.dart   # 连击动画
    └── score_animation_widget.dart   # 分数动画
```

### 2.2 每个文件的职责和代码

#### 2.2.1 game_page.dart（主页面，<200行）

```dart
// lib/ui/game/game_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game/providers.dart';
import '../../providers/settings/settings_provider.dart';
import '../../game/block.dart';
import '../../game/themes/themes.dart';
import 'widgets/game_grid.dart';
import 'widgets/block_pool.dart';
import 'widgets/score_display.dart';
import 'widgets/combo_effect.dart';
import 'widgets/power_up_bar.dart';
import 'widgets/timed_mode_display.dart';
import 'widgets/pause_overlay.dart';
import '../settings_page.dart';
import '../help_page.dart';
import '../game_over_dialog.dart';

/// 游戏主页面
class GamePage extends ConsumerStatefulWidget {
  final GameMode mode;

  const GamePage({
    super.key,
    this.mode = GameMode.classic,
  });

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage>
    with TickerProviderStateMixin {
  
  late final AnimationControllers _controllers;

  @override
  void initState() {
    super.initState();
    
    // 初始化动画控制器
    _controllers = AnimationControllers(this);
    
    // 设置游戏模式
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameModeProvider.notifier).state = widget.mode;
    });
  }

  @override
  void dispose() {
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final isPaused = ref.watch(isPausedProvider);
    final isGameOver = ref.watch(isGameOverProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildGameBody(),
          if (isPaused) PauseOverlay(onResume: _togglePause),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E1E1E),
      title: const Text('Block Blast', style: TextStyle(color: Colors.white)),
      actions: [
        ScoreDisplay(controllers: _controllers),
        IconButton(
          icon: Icon(
            ref.watch(isPausedProvider) ? Icons.play_arrow : Icons.pause,
            color: Colors.white,
          ),
          onPressed: _togglePause,
        ),
        IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpPage()),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildGameBody() {
    final gameMode = ref.watch(gameModeProvider);
    final comboState = ref.watch(comboStateProvider);

    return Column(
      children: [
        const SizedBox(height: 20),
        
        // 计时模式倒计时
        if (gameMode == GameMode.timed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TimedModeDisplay(),
          ),
        
        // 道具栏
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: PowerUpBar(
            enabled: !_isGameOver && !_isPaused && !_isDragging,
            onPowerUpTap: _onPowerUpTap,
          ),
        ),
        
        // 游戏网格
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GameGrid(
                controllers: _controllers,
                onPlaceBlock: _placeBlock,
              ),
              // 连击特效
              if (comboState != null)
                ComboEffect(
                  state: comboState,
                  animation: _controllers.comboAnimation,
                ),
            ],
          ),
        ),
        
        const Spacer(),
        
        // 方块池
        BlockPool(
          controllers: _controllers,
          onBlockSelected: _selectBlock,
        ),
        
        const SizedBox(height: 20),
        
        // 拖拽提示
        _buildDragHint(),
      ],
    );
  }

  Widget _buildDragHint() {
    final dragState = ref.watch(dragStateProvider);
    final selectedBlock = ref.watch(selectedBlockProvider);

    if (dragState.isDragging && dragState.draggingBlock != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          dragState.previewData?.canPlace == true ? '松开放置方块' : '位置无效',
          style: TextStyle(
            color: dragState.previewData?.canPlace == true 
                ? Colors.green 
                : Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } else if (selectedBlock != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(
          '拖拽方块到网格上',
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget? _buildFloatingActionButton() {
    final selectedBlock = ref.watch(selectedBlockProvider);
    final isDragging = ref.watch(dragStateProvider).isDragging;

    if (selectedBlock != null && !isDragging) {
      return FloatingActionButton(
        onPressed: _showPlaceDialog,
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  void _togglePause() {
    ref.read(gameProvider.notifier).togglePause();
  }

  void _selectBlock(Block? block) {
    ref.read(gameProvider.notifier).selectBlock(block);
  }

  void _placeBlock(int gridX, int gridY, Block block) {
    ref.read(gameProvider.notifier).placeBlock(gridX, gridY, block);
    _controllers.playPlaceAnimation();
  }

  void _showPlaceDialog() {
    // ... 显示放置对话框
  }

  void _onPowerUpTap(PowerUpType type) {
    // ... 道具处理
  }
}

/// 动画控制器集合
class AnimationControllers {
  final AnimationController clearAnimation;
  final AnimationController placeAnimation;
  final AnimationController comboAnimation;
  final AnimationController scoreBounceAnimation;
  final AnimationController scorePopupAnimation;
  final AnimationController dragScaleAnimation;

  AnimationControllers(TickerProvider vsync)
      : clearAnimation = AnimationController(
          duration: const Duration(milliseconds: 350),
          vsync: vsync,
        ),
        placeAnimation = AnimationController(
          duration: const Duration(milliseconds: 200),
          vsync: vsync,
        ),
        comboAnimation = AnimationController(
          duration: const Duration(milliseconds: 600),
          vsync: vsync,
        ),
        scoreBounceAnimation = AnimationController(
          duration: const Duration(milliseconds: 200),
          vsync: vsync,
        ),
        scorePopupAnimation = AnimationController(
          duration: const Duration(milliseconds: 600),
          vsync: vsync,
        ),
        dragScaleAnimation = AnimationController(
          duration: const Duration(milliseconds: 150),
          vsync: vsync,
        );

  void dispose() {
    clearAnimation.dispose();
    placeAnimation.dispose();
    comboAnimation.dispose();
    scoreBounceAnimation.dispose();
    scorePopupAnimation.dispose();
    dragScaleAnimation.dispose();
  }

  void playPlaceAnimation() {
    placeAnimation.forward(from: 0.0);
  }

  void playClearAnimation() {
    clearAnimation.forward(from: 0.0);
  }

  void playComboAnimation() {
    comboAnimation.forward(from: 0.0);
  }
}
```

#### 2.2.2 widgets/game_grid.dart

```dart
// lib/ui/game/widgets/game_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/game/providers.dart';
import '../../../providers/settings/settings_provider.dart';
import '../../../game/grid.dart' as grid_widget;
import '../../game/game_page.dart';

class GameGrid extends ConsumerWidget {
  final AnimationControllers controllers;
  final Function(int gridX, int gridY, Block block)? onPlaceBlock;

  const GameGrid({
    super.key,
    required this.controllers,
    this.onPlaceBlock,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final showGridLines = ref.watch(showGridLinesProvider);
    final animationEnabled = ref.watch(animationEnabledProvider);

    return DragTarget<BlockDragData>(
      onWillAcceptWithDetails: (details) {
        if (details.data.block == null) return false;
        return true;
      },
      onMove: (details) {
        _handleDragMove(ref, details);
      },
      onLeave: (data) {
        ref.read(gameProvider.notifier).clearPreview();
      },
      onAcceptWithDetails: (details) {
        _handleDrop(ref, details);
      },
      builder: (context, candidateData, rejectedData) {
        return grid_widget.GridWidget(
          grid: gameState.grid,
          cellSize: 40,
          previewData: _toGridPreviewData(gameState.dragState.previewData),
          clearAnimationData: _toGridClearAnimationData(gameState.clearAnimation),
          placeAnimationData: _toGridPlaceAnimationData(gameState.placeAnimation),
          showGridLines: showGridLines,
          animationEnabled: animationEnabled,
        );
      },
    );
  }

  void _handleDragMove(WidgetRef ref, DragTargetDetails<BlockDragData> details) {
    final block = details.data.block;
    if (block == null) return;

    // 计算网格坐标（需要从全局坐标转换）
    // ... 坐标转换逻辑
    
    // ref.read(gameProvider.notifier).updatePreview(gridX, gridY, block);
  }

  void _handleDrop(WidgetRef ref, DragTargetDetails<BlockDragData> details) {
    final dragState = ref.read(dragStateProvider);
    final block = dragState.draggingBlock;
    
    if (dragState.previewGridX != null && 
        dragState.previewGridY != null && 
        block != null) {
      onPlaceBlock?.call(dragState.previewGridX!, dragState.previewGridY!, block);
    }
  }

  grid_widget.BlockPreviewData? _toGridPreviewData(BlockPreviewData? data) {
    if (data == null) return null;
    return grid_widget.BlockPreviewData(
      previewPositions: data.previewPositions,
      canPlace: data.canPlace,
    );
  }

  grid_widget.ClearAnimationData? _toGridClearAnimationData(ClearAnimationState? state) {
    if (state == null) return null;
    return grid_widget.ClearAnimationData(
      clearingRows: state.clearingRows,
      clearingCols: state.clearingCols,
      animationValue: state.animationValue,
    );
  }

  grid_widget.PlaceAnimationData? _toGridPlaceAnimationData(PlaceAnimationState? state) {
    if (state == null) return null;
    return grid_widget.PlaceAnimationData(
      placedPositions: state.placedPositions,
      animationValue: state.animationValue,
    );
  }
}
```

#### 2.2.3 widgets/block_pool.dart

```dart
// lib/ui/game/widgets/block_pool.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/game/providers.dart';
import '../../../game/block.dart';
import '../../../game/drag.dart';
import '../../../game/haptic.dart';
import '../game_page.dart';

class BlockPool extends ConsumerWidget {
  final AnimationControllers controllers;
  final Function(Block?)? onBlockSelected;

  const BlockPool({
    super.key,
    required this.controllers,
    this.onBlockSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableBlocks = ref.watch(availableBlocksProvider);
    final selectedBlock = ref.watch(selectedBlockProvider);
    final isPaused = ref.watch(isPausedProvider);

    if (isPaused) {
      return _buildPausedPool(availableBlocks);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: availableBlocks.map((block) {
          final isSelected = selectedBlock?.id == block.id;
          return _buildBlockItem(ref, block, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildPausedPool(List<Block> blocks) {
    return IgnorePointer(
      ignoring: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: blocks.map((block) {
            return Opacity(
              opacity: 0.4,
              child: _buildBlockPreview(block, 28),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBlockItem(WidgetRef ref, Block block, bool isSelected) {
    return GestureDetector(
      onTap: () {
        onBlockSelected?.call(block);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Draggable<BlockDragData>(
          data: BlockDragData(block: block, shape: block.shape),
          onDragStarted: () {
            HapticManager.dragStart();
            onBlockSelected?.call(block);
            controllers.dragScaleAnimation.forward();
          },
          onDragEnd: (details) {
            controllers.dragScaleAnimation.reverse();
          },
          feedback: _buildBlockFeedback(block),
          childWhenDragging: Opacity(
            opacity: 0.3,
            child: _buildBlockPreview(block, 28),
          ),
          child: _buildBlockPreview(block, 28),
        ),
      ),
    );
  }

  Widget _buildBlockPreview(Block block, double cellSize) {
    // ... 方块预览构建逻辑（从原game_page.dart复制）
    int maxX = 0, maxY = 0;
    for (final offset in block.shape) {
      if (offset.dx.toInt() > maxX) maxX = offset.dx.toInt();
      if (offset.dy.toInt() > maxY) maxY = offset.dy.toInt();
    }

    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(maxY + 1, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(maxX + 1, (col) {
              final hasCell = block.shape.any(
                (offset) => offset.dx.toInt() == col && offset.dy.toInt() == row,
              );
              return Container(
                width: cellSize,
                height: cellSize,
                margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  color: hasCell ? block.color : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  Widget _buildBlockFeedback(Block block) {
    return Material(
      color: Colors.transparent,
      child: Transform.scale(
        scale: 1.15,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: block.color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: _buildBlockPreview(block, 32),
        ),
      ),
    );
  }
}
```

#### 2.2.4 widgets/score_display.dart

```dart
// lib/ui/game/widgets/score_display.dart

import 'package:flutter/material.dart';
import '../../../providers/game/providers.dart';
import '../game_page.dart';

class ScoreDisplay extends StatelessWidget {
  final AnimationControllers controllers;

  const ScoreDisplay({
    super.key,
    required this.controllers,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final score = ref.watch(scoreProvider);
        final highScore = ref.watch(highScoreProvider);

        return Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              _buildScoreArea(score, highScore),
              _buildScorePopup(score),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreArea(int score, int highScore) {
    return AnimatedBuilder(
      animation: controllers.scoreBounceAnimation,
      builder: (context, child) {
        final scale = 1.0 + (controllers.scoreBounceAnimation.value * 0.4);
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '分数: $score',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '最高: $highScore',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScorePopup(int lastIncrease) {
    if (lastIncrease <= 0) return const SizedBox.shrink();

    return Positioned(
      right: 8,
      top: -10,
      child: AnimatedBuilder(
        animation: controllers.scorePopupAnimation,
        builder: (context, child) {
          final opacity = 1.0 - controllers.scorePopupAnimation.value;
          final offset = -40 * controllers.scorePopupAnimation.value;
          return Transform.translate(
            offset: Offset(0, offset),
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          );
        },
        child: Text(
          '+$lastIncrease',
          style: const TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
```

#### 2.2.5 widgets/combo_effect.dart

```dart
// lib/ui/game/widgets/combo_effect.dart

import 'package:flutter/material.dart';
import '../../../providers/game/game_state.dart';
import '../game_page.dart';

class ComboEffect extends StatelessWidget {
  final ComboState state;
  final Animation<double> animation;

  const ComboEffect({
    super.key,
    required this.state,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -50,
      left: 0,
      right: 0,
      child: AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final slideOffset = -30 * animation.value;
          final opacity = 1.0 - animation.value;
          final scale = 1.0 + (animation.value * 0.3);
          
          return Transform.translate(
            offset: Offset(0, slideOffset),
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: child,
              ),
            ),
          );
        },
        child: _buildComboText(),
      ),
    );
  }

  Widget _buildComboText() {
    final hasShine = state.count >= 5;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              if (hasShine)
                Text(
                  state.text,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 6
                      ..color = state.color.withOpacity(0.5),
                    shadows: [
                      Shadow(
                        color: state.color.withOpacity(0.8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
              Text(
                state.text,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: state.color,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (state.count >= 2) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: state.color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: state.color, width: 2),
              ),
              child: Text(
                '${state.count}x',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: state.color.withOpacity(0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
```

#### 2.2.6 widgets/pause_overlay.dart

```dart
// lib/ui/game/widgets/pause_overlay.dart

import 'package:flutter/material.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;

  const PauseOverlay({
    super.key,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onResume,
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.pause_circle_filled,
                  color: Colors.white,
                  size: 80,
                ),
                const SizedBox(height: 16),
                const Text(
                  '游戏暂停',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('继续游戏'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

### 2.3 迁移步骤

**第一步：创建新目录结构**
```bash
mkdir -p lib/ui/game/widgets
mkdir -p lib/ui/game/animations
mkdir -p lib/providers/game
mkdir -p lib/providers/settings
```

**第二步：创建 Provider 文件**
1. 创建 `lib/providers/game/game_state.dart`
2. 创建 `lib/providers/game/game_notifier.dart`
3. 创建 `lib/providers/game/providers.dart`
4. 创建 `lib/providers/settings/settings_provider.dart`

**第三步：创建 Widget 文件**
1. 创建各个 widget 文件
2. 复制相关代码到对应文件
3. 调整 import

**第四步：修改 game_page.dart**
1. 重写为使用 Riverpod 的版本
2. 保持原有功能不变

**第五步：测试验证**
1. 运行单元测试
2. 手动测试各个功能
3. 确认无回归

---

## 3. 动画优化方案

### 3.1 AnimatedBuilder 改造

当前代码已经使用了 AnimatedBuilder，但可以进一步优化：

#### 3.1.1 消除动画优化

```dart
// lib/ui/game/animations/clear_animation_widget.dart

import 'package:flutter/material.dart';

/// 消除动画组件
class ClearAnimationWidget extends StatefulWidget {
  final Widget child;
  final List<int> clearingRows;
  final List<int> clearingCols;
  final VoidCallback onComplete;

  const ClearAnimationWidget({
    super.key,
    required this.child,
    required this.clearingRows,
    required this.clearingCols,
    required this.onComplete,
  });

  @override
  State<ClearAnimationWidget> createState() => _ClearAnimationWidgetState();
}

class _ClearAnimationWidgetState extends State<ClearAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    )..forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _ClearEffect(
          value: _controller.value,
          clearingRows: widget.clearingRows,
          clearingCols: widget.clearingCols,
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

class _ClearEffect extends StatelessWidget {
  final double value;
  final List<int> clearingRows;
  final List<int> clearingCols;
  final Widget child;

  const _ClearEffect({
    required this.value,
    required this.clearingRows,
    required this.clearingCols,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 前50%闪烁，后50%缩放消失
    if (value < 0.5) {
      // 闪烁效果
      final flashValue = (value * 2 * 6 * 3.14159).sin();
      final opacity = 0.5 + 0.5 * (flashValue + 1) / 2;
      return Opacity(opacity: opacity, child: child);
    } else {
      // 缩放消失
      final disappearValue = (value - 0.5) * 2;
      final scale = 1.0 + disappearValue * 0.3;
      return Opacity(
        opacity: 1.0 - disappearValue,
        child: Transform.scale(scale: scale, child: child),
      );
    }
  }
}
```

#### 3.1.2 放置动画优化

```dart
// lib/ui/game/animations/place_animation_widget.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 放置动画组件
class PlaceAnimationWidget extends StatefulWidget {
  final Widget child;
  final List<Offset> placedPositions;
  final VoidCallback onComplete;

  const PlaceAnimationWidget({
    super.key,
    required this.child,
    required this.placedPositions,
    required this.onComplete,
  });

  @override
  State<PlaceAnimationWidget> createState() => _PlaceAnimationWidgetState();
}

class _PlaceAnimationWidgetState extends State<PlaceAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    )..forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 弹性缩放效果
        final t = _controller.value;
        double scale;
        if (t < 0.4) {
          scale = 0.8 + 0.2 * (t / 0.4);
        } else {
          final bounceT = (t - 0.4) / 0.6;
          const decay = 4.0;
          const freq = 4.5 * math.pi;
          const amplitude = 0.12;
          scale = 1.0 + amplitude * math.exp(-decay * bounceT) * math.sin(freq * bounceT);
        }
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}
```

#### 3.1.3 连击动画优化

```dart
// lib/ui/game/animations/combo_animation_widget.dart

import 'package:flutter/material.dart';

/// 连击动画组件
class ComboAnimationWidget extends StatefulWidget {
  final String text;
  final Color color;
  final int count;
  final VoidCallback onComplete;

  const ComboAnimationWidget({
    super.key,
    required this.text,
    required this.color,
    required this.count,
    required this.onComplete,
  });

  @override
  State<ComboAnimationWidget> createState() => _ComboAnimationWidgetState();
}

class _ComboAnimationWidgetState extends State<ComboAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 快速闪烁
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 10),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 透明度渐变
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    // 向上飘动
    _slideAnimation = Tween<double>(begin: 0, end: -30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: _buildComboContent(),
    );
  }

  Widget _buildComboContent() {
    final hasShine = widget.count >= 5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (hasShine)
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 6
                    ..color = widget.color.withOpacity(0.5),
                ),
              ),
            Text(
              widget.text,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
            ),
          ],
        ),
        if (widget.count >= 2) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.color, width: 2),
            ),
            child: Text(
              '${widget.count}x',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
```

### 3.2 独立动画 Widget

所有动画都封装为独立的 StatefulWidget，具有以下特点：
- 自己管理 AnimationController 生命周期
- 完成时通过回调通知父组件
- 可复用，易于测试

---

## 4. 执行计划

### 4.1 分阶段执行

#### 阶段1：引入Riverpod + 创建Provider（预计1小时）

**任务清单**：
- [ ] 添加 flutter_riverpod 依赖到 pubspec.yaml
- [ ] 创建 lib/providers/ 目录结构
- [ ] 实现 GameState 数据类
- [ ] 实现 GameNotifier 状态控制器
- [ ] 实现 Provider 定义文件
- [ ] 修改 main.dart 添加 ProviderScope

**验证点**：
- 项目可以编译通过
- Provider 可以正常读取

#### 阶段2：拆分game_page.dart（预计2小时）

**任务清单**：
- [ ] 创建 widgets/ 目录
- [ ] 实现 game_grid.dart
- [ ] 实现 block_pool.dart
- [ ] 实现 score_display.dart
- [ ] 实现 combo_effect.dart
- [ ] 实现 pause_overlay.dart
- [ ] 实现其他辅助组件
- [ ] 重写 game_page.dart 使用新组件

**验证点**：
- UI 渲染正常
- 交互功能正常

#### 阶段3：优化动画（预计1小时）

**任务清单**：
- [ ] 创建 animations/ 目录
- [ ] 实现 clear_animation_widget.dart
- [ ] 实现 place_animation_widget.dart
- [ ] 实现 combo_animation_widget.dart
- [ ] 实现 score_animation_widget.dart
- [ ] 集成到各组件中

**验证点**：
- 动画流畅
- 无卡顿

#### 阶段4：测试验证（预计0.5小时）

**任务清单**：
- [ ] 运行单元测试
- [ ] 手动测试游戏功能
- [ ] 检查性能
- [ ] 修复发现的问题

**验证点**：
- 所有测试通过
- 功能无回归

### 4.2 风险点

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| Riverpod 学习曲线 | 开发时间延长 | 先阅读官方文档，参考示例代码 |
| 状态迁移遗漏 | 功能异常 | 逐步迁移，每步验证 |
| 动画性能下降 | 用户体验差 | 使用 DevTools 分析，优化关键路径 |
| Provider 依赖循环 | 编译错误 | 合理设计 Provider 层级，避免互相依赖 |
| Widget 重建过多 | 性能问题 | 使用 select/family 等优化手段 |

### 4.3 回滚方案

1. **Git 分支策略**：
   ```bash
   git checkout -b feature/riverpod-refactor
   ```
   每个阶段完成后提交，出现问题可以回滚到上一个阶段。

2. **备份原文件**：
   ```bash
   cp lib/ui/game_page.dart lib/ui/game_page.dart.backup
   ```

3. **渐进式迁移**：
   - 可以同时保留新旧代码
   - 通过开关控制使用哪个版本
   - 确认稳定后再删除旧代码

---

## 5. 总结

本重构方案将：

1. **状态管理清晰化**：通过 Riverpod 将分散的状态统一管理
2. **代码模块化**：将1778行的巨型文件拆分为多个职责单一的模块
3. **动画优化**：将动画逻辑封装为独立组件，提高可维护性
4. **向后兼容**：渐进式迁移，保证功能不丢失

重构完成后，项目将具备更好的可维护性和扩展性。
