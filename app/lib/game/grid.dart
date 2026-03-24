import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'block.dart';
import 'theme.dart';
import '../core/constants.dart';

/// 方块拖拽数据
class BlockDragData {
  final Block block;
  final List<Offset> shape;
  
  const BlockDragData({
    required this.block,
    required this.shape,
  });
}

/// 方块预览数据
class BlockPreviewData {
  final List<Offset> previewPositions; // 预览位置列表
  final bool canPlace; // 是否可以放置

  BlockPreviewData({
    required this.previewPositions,
    required this.canPlace,
  });
}

/// 消除动画数据
class ClearAnimationData {
  final List<int> clearingRows; // 要消除的行
  final List<int> clearingCols; // 要消除的列
  final double animationValue; // 动画进度 (0.0 - 1.0)

  ClearAnimationData({
    required this.clearingRows,
    required this.clearingCols,
    required this.animationValue,
  });

  /// 检查某个格子是否在消除范围内
  bool isClearing(int row, int col) {
    return clearingRows.contains(row) || clearingCols.contains(col);
  }
}

/// 放置动画数据
class PlaceAnimationData {
  final List<Offset> placedPositions; // 刚放置的格子位置
  final double animationValue; // 动画进度 (0.0 - 1.0)

  PlaceAnimationData({
    required this.placedPositions,
    required this.animationValue,
  });

  /// 检查某个格子是否刚放置
  bool isPlaced(int row, int col) {
    return placedPositions.any((pos) => pos.dx.toInt() == col && pos.dy.toInt() == row);
  }
}

/// 8x8游戏网格 - 支持拖拽放置和实时预览
class GridWidget extends StatefulWidget {
  final List<List<int>> grid; // 0=空, 1=有方块
  final double cellSize;
  final Color? emptyColor;
  final Color? filledColor;
  final Color? borderColor;
  final Function(int gridX, int gridY)? onCellTap; // 点击事件
  final BlockPreviewData? previewData; // 拖拽预览数据
  final Function(int gridX, int gridY)? onDragAccepted; // 拖拽接受回调
  final bool isDragTarget; // 是否作为拖拽目标
  final ClearAnimationData? clearAnimationData; // 消除动画数据
  final PlaceAnimationData? placeAnimationData; // 放置动画数据
  final bool showGridLines; // Bug 3 修复：是否显示网格线
  final bool animationEnabled; // Bug 3 修复：是否启用动画

  const GridWidget({
    super.key,
    required this.grid,
    this.cellSize = GameConfig.defaultCellSize,
    this.emptyColor,
    this.filledColor,
    this.borderColor,
    this.onCellTap,
    this.previewData,
    this.onDragAccepted,
    this.isDragTarget = false,
    this.clearAnimationData,
    this.placeAnimationData,
    this.showGridLines = true, // Bug 3 修复：默认显示网格线
    this.animationEnabled = true, // Bug 3 修复：默认启用动画
  });

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  // 当前拖拽悬停位置
  int? _hoverGridX;
  int? _hoverGridY;

  @override
  Widget build(BuildContext context) {
    final gridContent = _buildGridContent();

    if (widget.isDragTarget) {
      return DragTarget<BlockDragData>(
        onWillAcceptWithDetails: (details) {
          return details.data.block != null;
        },
        onMove: (details) {
          _updateHoverPosition(details.offset);
        },
        onLeave: (data) {
          setState(() {
            _hoverGridX = null;
            _hoverGridY = null;
          });
        },
        onAcceptWithDetails: (details) {
          if (_hoverGridX != null && _hoverGridY != null && widget.onDragAccepted != null) {
            widget.onDragAccepted!(_hoverGridX!, _hoverGridY!);
          }
          setState(() {
            _hoverGridX = null;
            _hoverGridY = null;
          });
        },
        builder: (context, candidateData, rejectedData) {
          return gridContent;
        },
      );
    }

    return GestureDetector(
      onTapUp: (details) {
        if (widget.onCellTap != null) {
          final tapX = details.localPosition.dx;
          final tapY = details.localPosition.dy;
          final gridX = (tapX / widget.cellSize).floor();
          final gridY = (tapY / widget.cellSize).floor();
          
          if (gridX >= 0 && gridX < GameConfig.gridSize && gridY >= 0 && gridY < GameConfig.gridSize) {
            widget.onCellTap!(gridX, gridY);
          }
        }
      },
      child: gridContent,
    );
  }

  void _updateHoverPosition(Offset globalOffset) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(globalOffset);
    
    final gridX = (localPosition.dx / widget.cellSize).floor();
    final gridY = (localPosition.dy / widget.cellSize).floor();
    
    if (gridX >= 0 && gridX < GameConfig.gridSize && gridY >= 0 && gridY < GameConfig.gridSize) {
      if (_hoverGridX != gridX || _hoverGridY != gridY) {
        setState(() {
          _hoverGridX = gridX;
          _hoverGridY = gridY;
        });
      }
    } else {
      if (_hoverGridX != null || _hoverGridY != null) {
        setState(() {
          _hoverGridX = null;
          _hoverGridY = null;
        });
      }
    }
  }

  Widget _buildGridContent() {
    // 获取当前预览数据（优先使用外部传入的，其次使用悬停位置计算的）
    BlockPreviewData? effectivePreviewData = widget.previewData;

    return Container(
      decoration: BoxDecoration(
        color: GameTheme.gridBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.borderColor ?? GameTheme.gridBorder, width: 2),
        boxShadow: [
          // 主阴影 - 增加深度感
          BoxShadow(
            color: GameTheme.gridShadow.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
          // 内发光 - 边缘高光
          BoxShadow(
            color: GameTheme.accent.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: -2,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(8, (row) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(8, (col) {
              final isFilled = widget.grid[row][col] == 1;

              // 检查是否是预览位置
              bool isPreview = false;
              bool canPlace = true;
              if (effectivePreviewData != null) {
                isPreview = effectivePreviewData.previewPositions.any(
                  (pos) => pos.dx == col && pos.dy == row,
                );
                canPlace = effectivePreviewData.canPlace;
              }

              // 检查是否在消除动画中
              bool isClearing = false;
              double clearAnimValue = 0.0;
              if (widget.clearAnimationData != null && isFilled) {
                isClearing = widget.clearAnimationData!.isClearing(row, col);
                clearAnimValue = widget.clearAnimationData!.animationValue;
              }

              // 检查是否在放置动画中
              bool isPlacing = false;
              double placeAnimValue = 0.0;
              if (widget.placeAnimationData != null) {
                isPlacing = widget.placeAnimationData!.isPlaced(row, col);
                placeAnimValue = widget.placeAnimationData!.animationValue;
              }

              Color cellColor;
              double opacity = 1.0;
              double scale = 1.0;

              if (isClearing) {
                // 消除动画：闪烁 + 缩放消失
                // 前50%：闪烁效果（使用正弦波）
                // 后50%：缩放消失
                if (clearAnimValue < 0.5) {
                  // 闪烁阶段：快速闪烁2-3次
                  final flashProgress = clearAnimValue * 2; // 0.0 - 1.0
                  // 使用正弦波产生闪烁效果，频率6（闪烁3次）
                  opacity = 0.5 + 0.5 * (math.sin(flashProgress * 6 * math.pi) + 1) / 2;
                  cellColor = GameTheme.combo2; // 闪烁时用黄色高亮
                } else {
                  // 缩放消失阶段
                  final disappearProgress = (clearAnimValue - 0.5) * 2; // 0.0 - 1.0
                  opacity = 1.0 - disappearProgress;
                  scale = 1.0 + disappearProgress * 0.3; // 缩放到 1.3 倍
                  cellColor = widget.filledColor ?? GameTheme.filledCell;
                }
              } else if (isPreview) {
                // 预览位置：使用边框而非半透明填充
                // 背景色保持透明或淡色
                if (canPlace) {
                  // 可以放置：淡绿色背景 + 绿色边框
                  cellColor = GameTheme.accent.withOpacity(0.2);
                } else {
                  // 不能放置：淡红色背景 + 红色边框
                  cellColor = GameTheme.error.withOpacity(0.2);
                }
              } else if (isFilled) {
                cellColor = widget.filledColor ?? GameTheme.filledCell;
              } else {
                cellColor = widget.emptyColor ?? GameTheme.emptyCell;
              }

              Widget cell = Container(
                width: widget.cellSize,
                height: widget.cellSize,
                margin: const EdgeInsets.all(2), // 增加间隙从1到2
                decoration: BoxDecoration(
                  color: cellColor,
                  borderRadius: BorderRadius.circular(4),
                  // Bug 3 修复：根据设置显示/隐藏网格线
                  border: widget.showGridLines
                      ? (isPreview
                          ? Border.all(
                              color: canPlace
                                  ? GameTheme.accent.withOpacity(0.9)
                                  : GameTheme.error.withOpacity(0.9),
                              width: 3, // 加粗边框
                            )
                          : null)
                      : (isPreview
                          ? Border.all(
                              color: canPlace
                                  ? GameTheme.accent.withOpacity(0.9)
                                  : GameTheme.error.withOpacity(0.9),
                              width: 3, // 加粗边框
                            )
                          : null),
                  // 为填充格子添加微妙的阴影
                  boxShadow: isFilled
                      ? [
                          BoxShadow(
                            color: GameTheme.gridShadow.withOpacity(0.3),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : isPreview
                          ? [
                              // 预览格子添加发光效果（增强版）
                              BoxShadow(
                                color: canPlace
                                    ? GameTheme.accent.withOpacity(0.6)
                                    : GameTheme.error.withOpacity(0.6),
                                blurRadius: 12, // 增强发光范围
                                spreadRadius: 2,
                              ),
                              // 外发光效果
                              BoxShadow(
                                color: canPlace
                                    ? GameTheme.accent.withOpacity(0.4)
                                    : GameTheme.error.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ]
                          : null,
                ),
              );

              // Bug 3 修复：根据设置决定是否应用动画效果
              if (widget.animationEnabled) {
                // 应用动画效果
                if (isClearing) {
                  cell = Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: cell,
                    ),
                  );
                } else if (isPlacing) {
                  // 放置动画：弹性缩放效果（0.8 -> 1.0）
                  // 使用阻尼弹性曲线模拟 elasticOut
                  final t = placeAnimValue;
                  // 弹性公式：快速到达 1.0，然后有轻微回弹并稳定
                  double placeScale;
                  if (t < 0.4) {
                    // 前半段：快速从 0.8 放大到 1.0
                    placeScale = 0.8 + 0.2 * (t / 0.4);
                  } else {
                    // 后半段：弹性回弹效果
                    final bounceT = (t - 0.4) / 0.6; // 0 -> 1
                    // 阻尼振荡：exp(-decay) * sin(freq)
                    // decay=4, freq=4.5π 产生约1.5次回弹
                    final decay = 4.0;
                    final freq = 4.5 * math.pi;
                    final amplitude = 0.12; // 最大回弹幅度 12%
                    placeScale = 1.0 + amplitude * math.exp(-decay * bounceT) * math.sin(freq * bounceT);
                  }
                  cell = Transform.scale(
                    scale: placeScale,
                    child: cell,
                  );
                }
              }

              return cell;
            }),
          );
        }),
      ),
    );
  }
}

// 预览网格（拖拽时半透明显示）- 已废弃，保留兼容性
// class PreviewGridWidget extends StatelessWidget {
//   final List<List<int>> grid;
//   final List<Offset> previewPositions;
//   final double cellSize;
//
//   const PreviewGridWidget({
//     super.key,
//     required this.grid,
//     required this.previewPositions,
//     this.cellSize = GameConfig.defaultCellSize,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // 创建预览位置的Set，方便快速查找
//     final previewSet = previewPositions.map((p) => '${p.dx.toInt()},${p.dy.toInt()}').toSet();
//
//     return Container(
//       decoration: BoxDecoration(
//         color: GameTheme.gridBorder,
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: GameTheme.gridBorder, width: 2),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: List.generate(GameConfig.gridSize, (row) {
//           return Row(
//             mainAxisSize: MainAxisSize.min,
//             children: List.generate(GameConfig.gridSize, (col) {
//               final isFilled = grid[row][col] == 1;
//               final isPreview = previewSet.contains('$col,$row');
//
//               Color cellColor;
//               if (isPreview) {
//                 cellColor = GameTheme.accent.withOpacity(0.5); // 预览半透明
//               } else if (isFilled) {
//                 cellColor = GameTheme.filledCell;
//               } else {
//                 cellColor = GameTheme.emptyCell;
//               }
//
//               return Container(
//                 width: cellSize,
//                 height: cellSize,
//                 margin: const EdgeInsets.all(GameConfig.cellMargin),
//                 decoration: BoxDecoration(
//                   color: cellColor,
//                   borderRadius: BorderRadius.circular(4),
//                 ),
//               );
//             }),
//           );
//         }),
//       ),
//     );
//   }
// }
