import 'package:flutter/material.dart';

/// 消除逻辑
class ClearLogic {
  /// 检查哪些行和列需要消除（不执行消除）
  /// 返回: (要消除的行列表, 要消除的列列表)
  static (List<int>, List<int>) checkClearPositions(List<List<int>> grid) {
    final rowsToClear = <int>[];
    final colsToClear = <int>[];

    // 检查每一行
    for (int row = 0; row < 8; row++) {
      if (grid[row].every((cell) => cell == 1)) {
        rowsToClear.add(row);
      }
    }

    // 检查每一列
    for (int col = 0; col < 8; col++) {
      bool isFull = true;
      for (int row = 0; row < 8; row++) {
        if (grid[row][col] == 0) {
          isFull = false;
          break;
        }
      }
      if (isFull) {
        colsToClear.add(col);
      }
    }

    return (rowsToClear, colsToClear);
  }

  /// 执行消除操作
  static List<List<int>> clearRowsAndCols(
    List<List<int>> grid,
    List<int> rowsToClear,
    List<int> colsToClear,
  ) {
    // 创建新的grid副本
    final newGrid = grid.map((row) => List<int>.from(row)).toList();

    // 清除行
    for (final row in rowsToClear) {
      for (int col = 0; col < 8; col++) {
        newGrid[row][col] = 0;
      }
    }

    // 清除列
    for (final col in colsToClear) {
      for (int row = 0; row < 8; row++) {
        newGrid[row][col] = 0;
      }
    }

    return newGrid;
  }

  /// 检查并消除填满的行和列
  /// 返回: (新的grid, 消除的行数, 消除的列数)
  static (List<List<int>>, int, int) checkAndClear(List<List<int>> grid) {
    final (rowsToClear, colsToClear) = checkClearPositions(grid);

    // 如果没有要消除的，直接返回
    if (rowsToClear.isEmpty && colsToClear.isEmpty) {
      return (grid, 0, 0);
    }

    final newGrid = clearRowsAndCols(grid, rowsToClear, colsToClear);
    return (newGrid, rowsToClear.length, colsToClear.length);
  }

  /// 检查方块是否可以放置在指定位置
  static bool canPlace(
    List<List<int>> grid,
    int gridX,
    int gridY,
    List<Offset> blockShape,
  ) {
    for (final offset in blockShape) {
      final x = gridX + offset.dx.toInt();
      final y = gridY + offset.dy.toInt();

      // 检查边界
      if (x < 0 || x >= 8 || y < 0 || y >= 8) {
        return false;
      }

      // 检查是否已有方块
      if (grid[y][x] == 1) {
        return false;
      }
    }
    return true;
  }

  /// 放置方块到网格
  static List<List<int>> placeBlock(
    List<List<int>> grid,
    int gridX,
    int gridY,
    List<Offset> blockShape,
  ) {
    final newGrid = grid.map((row) => List<int>.from(row)).toList();
    for (final offset in blockShape) {
      final x = gridX + offset.dx.toInt();
      final y = gridY + offset.dy.toInt();
      newGrid[y][x] = 1;
    }
    return newGrid;
  }

  /// 检查游戏是否结束
  /// 游戏结束条件：没有任何方块可以放置
  static bool isGameOver(List<List<int>> grid, List<List<Offset>> availableBlocks) {
    for (final blockShape in availableBlocks) {
      // 尝试每个位置
      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          if (canPlace(grid, col, row, blockShape)) {
            return false; // 还有位置可以放，游戏未结束
          }
        }
      }
    }
    return true; // 没有任何方块可以放置，游戏结束
  }

  /// 计算分数
  /// 每行/列10分，连击（同时消除多行/列）有额外加成
  static int calculateScore(int rowsCleared, int colsCleared) {
    final baseScore = (rowsCleared + colsCleared) * 10;
    
    // 连击加成
    final totalCleared = rowsCleared + colsCleared;
    int bonus = 0;
    if (totalCleared >= 4) {
      bonus = 50; // 超级连击
    } else if (totalCleared >= 3) {
      bonus = 30; // 大连击
    } else if (totalCleared >= 2) {
      bonus = 10; // 小连击
    }

    return baseScore + bonus;
  }
}

/// 消除动画控制器
class ClearAnimationController {
  final List<int> clearingRows;
  final List<int> clearingCols;
  final AnimationController animationController;

  ClearAnimationController({
    required this.clearingRows,
    required this.clearingCols,
    required this.animationController,
  });

  bool get isAnimating => animationController.isAnimating;

  void dispose() {
    animationController.dispose();
  }
}
