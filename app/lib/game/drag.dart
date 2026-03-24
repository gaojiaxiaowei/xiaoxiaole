import 'package:flutter/material.dart';
import 'block.dart';
import 'grid.dart';
import 'theme.dart';
import '../core/constants.dart';

/// 方块拖拽组件
class DraggableBlock extends StatelessWidget {
  final Block block;
  final double cellSize;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragEnded;

  const DraggableBlock({
    super.key,
    required this.block,
    this.cellSize = 30,
    this.onDragStarted,
    this.onDragEnded,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<BlockDragData>(
      data: BlockDragData(block: block, shape: block.shape),
      onDragStarted: onDragStarted,
      onDragEnd: (details) => onDragEnded?.call(),
      feedback: _buildBlockPreview(),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildBlockPreview(),
      ),
      child: _buildBlockPreview(),
    );
  }

  Widget _buildBlockPreview() {
    // 计算方块的边界
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
}

/// 方块池（底部3个待选方块）
class BlockPool extends StatelessWidget {
  final List<Block> blocks;
  final Block? selectedBlock;
  final Function(Block) onBlockSelected;
  final Function(Block)? onDragStarted;
  final Function(Block)? onDragEnded;

  const BlockPool({
    super.key,
    required this.blocks,
    required this.selectedBlock,
    required this.onBlockSelected,
    this.onDragStarted,
    this.onDragEnded,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GameTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: blocks.map((block) {
          final isSelected = selectedBlock?.id == block.id;
          return GestureDetector(
            onTap: () => onBlockSelected(block),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? GameTheme.accent : Colors.transparent,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DraggableBlock(
                block: block,
                cellSize: 25,
                onDragStarted: () => onDragStarted?.call(block),
                onDragEnded: () => onDragEnded?.call(block),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// 放置目标区域 - 已废弃，不再使用
// class DropTargetWidget extends StatelessWidget {
//   final List<List<int>> grid;
//   final Block? draggingBlock;
//   final Offset? dragPosition;
//   final Function(int, int, Block) onBlockPlaced;
//
//   const DropTargetWidget({
//     super.key,
//     required this.grid,
//     this.draggingBlock,
//     this.dragPosition,
//     required this.onBlockPlaced,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return DragTarget<BlockDragData>(
//       onWillAcceptWithDetails: (details) => details.data.block != null,
//       onAcceptWithDetails: (details) {
//         // 计算放置位置
//         if (dragPosition != null) {
//           final cellSize = GameConfig.defaultCellSize;
//           final gridX = (dragPosition!.dx / cellSize).floor();
//           final gridY = (dragPosition!.dy / cellSize).floor();
//
//           if (gridX >= 0 && gridX < GameConfig.gridSize && gridY >= 0 && gridY < GameConfig.gridSize) {
//             onBlockPlaced(gridX, gridY, details.data.block);
//           }
//         }
//       },
//       builder: (context, candidateData, rejectedData) {
//         return const SizedBox.shrink();
//       },
//     );
//   }
// }
