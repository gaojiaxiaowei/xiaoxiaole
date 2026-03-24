// lib/ui/game/widgets/game_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme/theme_provider.dart';
import '../../../providers/game/providers.dart';
import '../../../providers/settings/settings_provider.dart';
import '../../../game/block.dart';
import '../../../game/drag.dart';
import '../../../game/grid.dart' as grid_widget;
import '../../../game/grid.dart' show BlockDragData;
import '../../../game/themes/theme_manager.dart';
import '../animations/animation_controllers.dart';

class GameGrid extends ConsumerStatefulWidget {
  final AnimationControllers controllers;
  final Function(int gridX, int gridY, Block block)? onPlaceBlock;
  final Function(int gridX, int gridY)? onBombTap;
  final bool isBombSelectionMode;

  const GameGrid({
    super.key,
    required this.controllers,
    this.onPlaceBlock,
    this.onBombTap,
    this.isBombSelectionMode = false,
  });

  @override
  ConsumerState<GameGrid> createState() => _GameGridState();
}

class _GameGridState extends ConsumerState<GameGrid> {
  final GlobalKey _gridKey = GlobalKey();
  bool _clearAnimationPlaying = false;
  bool _placeAnimationPlaying = false;

  @override
  void initState() {
    super.initState();
    
    // 只在 initState 添加一次监听器
    widget.controllers.placeAnimation.addListener(_onPlaceAnimationUpdate);
    widget.controllers.clearAnimation.addListener(_onClearAnimationUpdate);
    widget.controllers.placeAnimation.addStatusListener(_onPlaceAnimationStatus);
    widget.controllers.clearAnimation.addStatusListener(_onClearAnimationStatus);
  }

  @override
  void dispose() {
    widget.controllers.placeAnimation.removeListener(_onPlaceAnimationUpdate);
    widget.controllers.clearAnimation.removeListener(_onClearAnimationUpdate);
    widget.controllers.placeAnimation.removeStatusListener(_onPlaceAnimationStatus);
    widget.controllers.clearAnimation.removeStatusListener(_onClearAnimationStatus);
    super.dispose();
  }

  void _onPlaceAnimationUpdate() {
    if (widget.controllers.placeAnimation.status == AnimationStatus.forward) {
      ref.read(gameProvider.notifier).updatePlaceAnimation(
        widget.controllers.placeAnimation.value,
      );
    }
  }

  void _onClearAnimationUpdate() {
    if (widget.controllers.clearAnimation.status == AnimationStatus.forward) {
      ref.read(gameProvider.notifier).updateClearAnimation(
        widget.controllers.clearAnimation.value,
      );
    }
  }

  void _onPlaceAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _placeAnimationPlaying = false;
      });
      ref.read(gameProvider.notifier).onPlaceAnimationComplete();
    } else if (status == AnimationStatus.forward) {
      setState(() {
        _placeAnimationPlaying = true;
      });
    }
  }

  void _onClearAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _clearAnimationPlaying = false;
      });
      ref.read(gameProvider.notifier).onClearAnimationComplete();
    } else if (status == AnimationStatus.forward) {
      setState(() {
        _clearAnimationPlaying = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 只订阅需要的字段，不订阅整个 GameState
    final grid = ref.watch(gameProvider.select((s) => s.grid));
    final dragState = ref.watch(gameProvider.select((s) => s.dragState));
    final clearAnimation = ref.watch(gameProvider.select((s) => s.clearAnimation));
    final placeAnimation = ref.watch(gameProvider.select((s) => s.placeAnimation));
    final showGridLines = ref.watch(showGridLinesProvider);
    final animationEnabled = ref.watch(animationEnabledProvider);

    // 只触发动画，不添加监听器
    if (placeAnimation != null && !_placeAnimationPlaying) {
      widget.controllers.playPlaceAnimation();
    }
    if (clearAnimation != null && !_clearAnimationPlaying) {
      widget.controllers.playClearAnimation();
    }

    // 炸弹选择模式
    if (widget.isBombSelectionMode) {
      final theme = ref.watch(themeManagerProvider).currentTheme;
      return Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.warning,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.warning.withOpacity(0.6),
                  blurRadius: 16,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: grid_widget.GridWidget(
              grid: grid,
              cellSize: 40,
              previewData: _toGridPreviewData(dragState.previewData),
              clearAnimationData: _toGridClearAnimationData(clearAnimation),
              placeAnimationData: _toGridPlaceAnimationData(placeAnimation),
              showGridLines: showGridLines,
              animationEnabled: animationEnabled,
              onCellTap: (gridX, gridY) {
                if (grid[gridY][gridX] == 1) {
                  widget.onBombTap?.call(gridX, gridY);
                }
              },
            ),
          ),
          Positioned(
            top: -30,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.warning.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '点击方块使用炸弹',
                  style: TextStyle(
                    color: theme.primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // 正常模式
    return DragTarget<BlockDragData>(
      key: _gridKey,
      onWillAcceptWithDetails: (details) {
        if (details.data.block == null) return false;
        ref.read(gameProvider.notifier).updateDragState(
              ref.read(gameProvider).dragState.copyWith(
                    isDragging: true,
                    draggingBlock: details.data.block,
                  ),
            );
        ref.read(gameProvider.notifier).selectBlock(details.data.block);
        return true;
      },
      onMove: (details) {
        final dragState = ref.read(dragStateProvider);
        if (dragState.draggingBlock == null) return;

        // 计算网格坐标
        final RenderBox? renderBox =
            _gridKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox == null) return;

        final localPosition = renderBox.globalToLocal(details.offset);
        final cellSize = 42.0; // cellSize + margin
        final gridX = (localPosition.dx / cellSize).floor();
        final gridY = (localPosition.dy / cellSize).floor();

        if (gridX >= 0 && gridX < 8 && gridY >= 0 && gridY < 8) {
          ref
              .read(gameProvider.notifier)
              .updatePreview(gridX, gridY, dragState.draggingBlock!);
        } else {
          ref.read(gameProvider.notifier).clearPreview();
        }
      },
      onLeave: (data) {
        ref.read(gameProvider.notifier).clearPreview();
      },
      onAcceptWithDetails: (details) {
        final dragState = ref.read(dragStateProvider);
        if (dragState.previewGridX != null &&
            dragState.previewGridY != null &&
            dragState.draggingBlock != null) {
          widget.onPlaceBlock?.call(
            dragState.previewGridX!,
            dragState.previewGridY!,
            dragState.draggingBlock!,
          );
        } else {
          ref.read(gameProvider.notifier).clearPreview();
        }
      },
      builder: (context, candidateData, rejectedData) {
        return grid_widget.GridWidget(
          grid: grid,
          cellSize: 40,
          previewData: _toGridPreviewData(dragState.previewData),
          clearAnimationData: _toGridClearAnimationData(clearAnimation),
          placeAnimationData: _toGridPlaceAnimationData(placeAnimation),
          showGridLines: showGridLines,
          animationEnabled: animationEnabled,
        );
      },
    );
  }

  grid_widget.BlockPreviewData? _toGridPreviewData(BlockPreviewData? data) {
    if (data == null) return null;
    return grid_widget.BlockPreviewData(
      previewPositions: data.previewPositions,
      canPlace: data.canPlace,
    );
  }

  grid_widget.ClearAnimationData? _toGridClearAnimationData(
      ClearAnimationState? state) {
    if (state == null) return null;
    return grid_widget.ClearAnimationData(
      clearingRows: state.clearingRows,
      clearingCols: state.clearingCols,
      animationValue: state.animationValue,
    );
  }

  grid_widget.PlaceAnimationData? _toGridPlaceAnimationData(
      PlaceAnimationState? state) {
    if (state == null) return null;
    return grid_widget.PlaceAnimationData(
      placedPositions: state.placedPositions,
      animationValue: state.animationValue,
    );
  }
}
