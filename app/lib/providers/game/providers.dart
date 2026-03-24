// lib/providers/game/providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/block.dart';
import '../settings/settings_provider.dart'; // 导入设置中的difficultyProvider
import '../stats/stats_provider.dart'; // 导入 StatsManager Provider
import 'game_state.dart';
import 'game_notifier.dart';

/// 游戏模式 Provider
final gameModeProvider = StateProvider<GameMode>((ref) => GameMode.classic);

/// 游戏状态 Provider（主 Provider）
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final difficulty = ref.watch(difficultyProvider);
  final gameMode = ref.watch(gameModeProvider);
  return GameNotifier(difficulty: difficulty, gameMode: gameMode, ref: ref);
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
