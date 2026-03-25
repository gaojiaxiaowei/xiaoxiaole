// lib/ui/game/widgets/block_pool.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/game/providers.dart';
import '../../../providers/settings/settings_provider.dart';
import '../../../providers/theme/theme_provider.dart';
import '../../../game/block.dart';
import '../../../game/grid.dart' show BlockDragData;
import '../../../game/drag.dart';
import '../../../game/haptic.dart';
import '../../../game/themes/theme_manager.dart';
import '../animations/animation_controllers.dart';

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
    final theme = ref.watch(themeManagerProvider).currentTheme;

    if (isPaused) {
      return _buildPausedPool(availableBlocks, ref);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.gridShadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: availableBlocks.map((block) {
          final isSelected = selectedBlock?.id == block.id;
          return _buildBlockItem(context, ref, block, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildPausedPool(List<Block> blocks, WidgetRef ref) {
    final theme = ref.watch(themeManagerProvider).currentTheme;
    return IgnorePointer(
      ignoring: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: theme.cardBackground,
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

  Widget _buildBlockItem(BuildContext context, WidgetRef ref, Block block, bool isSelected) {
    final theme = ref.watch(themeManagerProvider).currentTheme;
    return GestureDetector(
      onTap: () {
        onBlockSelected?.call(block);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? theme.accent.withOpacity(0.15) : Colors.transparent,
          border: Border.all(
            color: isSelected ? theme.accent : Colors.transparent,
            width: isSelected ? 3 : 0,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.accent.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Draggable<BlockDragData>(
          data: BlockDragData(block: block, shape: block.shape),
          onDragStarted: () {
            HapticManager.dragStart();
            onBlockSelected?.call(block);
            controllers.playDragScaleAnimation();
          },
          onDragEnd: (details) {
            controllers.reverseDragScaleAnimation();
          },
          feedback: _buildBlockFeedback(block, ref),
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

  Widget _buildBlockFeedback(Block block, WidgetRef ref) {
    final theme = ref.watch(themeManagerProvider).currentTheme;
    return Material(
      color: Colors.transparent,
      child: Transform.scale(
        scale: 1.15,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: theme.gridShadow,
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
