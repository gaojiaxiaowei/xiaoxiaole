// lib/ui/game/widgets/game_body_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/game/providers.dart';
import '../../../providers/theme/theme_provider.dart';
import '../../game/controllers/game_controller.dart';
import '../animations/animation_controllers.dart';
import 'game_grid.dart';
import 'block_pool.dart';
import 'combo_effect.dart';
import 'power_up_bar.dart';
import 'timed_mode_display.dart';

/// 游戏主体内容Widget
class GameBodyWidget extends ConsumerWidget {
  final AnimationControllers controllers;
  final GameController gameController;

  const GameBodyWidget({
    super.key,
    required this.controllers,
    required this.gameController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameMode = ref.watch(gameModeProvider);
    final isGameOver = ref.watch(gameProvider.select((s) => s.isGameOver));
    final isPaused = ref.watch(gameProvider.select((s) => s.isPaused));
    final comboState = ref.watch(comboStateProvider);

    return Column(
      children: [
        const SizedBox(height: 20),
        if (gameMode == GameMode.timed)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TimedModeDisplay(),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: PowerUpBar(
            enabled: !isGameOver && !isPaused,
            onPowerUpTap: gameController.onPowerUpTap,
          ),
        ),
        Center(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              RepaintBoundary(
                key: const ValueKey('game_grid'),
                child: GameGrid(
                  controllers: controllers,
                  onPlaceBlock: gameController.placeBlock,
                  onBombTap: gameController.useBomb,
                  isBombSelectionMode: gameController.isBombSelectionMode,
                ),
              ),
              if (comboState != null)
                RepaintBoundary(
                  key: const ValueKey('combo_effect'),
                  child: ComboEffect(
                    state: comboState,
                    onComplete: () {
                      ref.read(gameProvider.notifier).clearComboEffect();
                    },
                  ),
                ),
            ],
          ),
        ),
        const Spacer(),
        RepaintBoundary(
          key: const ValueKey('block_pool'),
          child: BlockPool(
            controllers: controllers,
            onBlockSelected: gameController.selectBlock,
          ),
        ),
        const SizedBox(height: 20),
        _buildDragHint(ref),
      ],
    );
  }

  Widget _buildDragHint(WidgetRef ref) {
    final dragState = ref.watch(dragStateProvider);
    final selectedBlock = ref.watch(selectedBlockProvider);
    final theme = ref.watch(themeManagerProvider).currentTheme;

    String? hintText;
    Color? hintColor;

    if (dragState.isDragging && dragState.draggingBlock != null) {
      hintText = dragState.previewData?.canPlace == true ? '松开放置方块' : '位置无效';
      hintColor = dragState.previewData?.canPlace == true ? theme.accent : theme.error;
    } else if (selectedBlock != null) {
      hintText = '拖拽方块到网格上';
      hintColor = theme.secondaryText;
    }

    if (hintText == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        hintText,
        style: TextStyle(color: hintColor, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
