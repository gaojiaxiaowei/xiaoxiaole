import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/game/clear.dart';
import 'package:flutter/material.dart';

void main() {
  group('ClearLogic - 放置逻辑测试', () {
    group('canPlace - 放置检测', () {
      test('应该允许在空网格中放置方块', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [Offset(0, 0), Offset(1, 0), Offset(0, 1)]; // L形
        
        expect(ClearLogic.canPlace(grid, 0, 0, blockShape), true);
      });

      test('应该允许在网格中心放置方块', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [Offset(0, 0), Offset(1, 0), Offset(2, 0)]; // 横3
        
        expect(ClearLogic.canPlace(grid, 2, 3, blockShape), true);
      });

      test('应该在右边界允许放置（刚好贴合）', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [Offset(0, 0), Offset(1, 0), Offset(2, 0)]; // 横3（长度3）
        
        // 放置在x=5，占据5,6,7，刚好贴合右边界
        expect(ClearLogic.canPlace(grid, 5, 0, blockShape), true);
      });

      test('应该在底部边界允许放置（刚好贴合）', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [Offset(0, 0), Offset(0, 1), Offset(0, 2)]; // 竖3（高度3）
        
        // 放置在y=5，占据5,6,7，刚好贴合底部边界
        expect(ClearLogic.canPlace(grid, 0, 5, blockShape), true);
      });
    });

    group('canPlace - 边界检测', () {
      test('应该拒绝超出左边界的放置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [Offset(0, 0), Offset(1, 0)];
        
        expect(ClearLogic.canPlace(grid, -1, 0, blockShape), false);
      });

      test('应该拒绝超出右边界的放置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [Offset(0, 0), Offset(1, 0), Offset(2, 0)]; // 横3
        
        // 放置在x=6，会占据6,7,8，超出边界
        expect(ClearLogic.canPlace(grid, 6, 0, blockShape), false);
      });

      test('应该拒绝超出上边界的放置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [Offset(0, 0), Offset(0, 1)];
        
        expect(ClearLogic.canPlace(grid, 0, -1, blockShape), false);
      });

      test('应该拒绝超出下边界的放置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [Offset(0, 0), Offset(0, 1), Offset(0, 2)]; // 竖3
        
        // 放置在y=6，会占据6,7,8，超出边界
        expect(ClearLogic.canPlace(grid, 0, 6, blockShape), false);
      });

      test('应该拒绝部分超出右边界的放置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [Offset(0, 0), Offset(1, 0)]; // 横2
        
        // 放置在x=7，会占据7,8，超出边界
        expect(ClearLogic.canPlace(grid, 7, 0, blockShape), false);
      });

      test('应该拒绝部分超出下边界的放置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [Offset(0, 0), Offset(0, 1)]; // 竖2
        
        // 放置在y=7，会占据7,8，超出边界
        expect(ClearLogic.canPlace(grid, 0, 7, blockShape), false);
      });

      test('应该允许大方块在网格中心放置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [
          Offset(0, 0), Offset(1, 0), Offset(2, 0),
          Offset(0, 1), Offset(1, 1), Offset(2, 1),
          Offset(0, 2), Offset(1, 2), Offset(2, 2),
        ]; // 3x3大方块
        
        // 放置在x=2, y=2，占据2-4，有效
        expect(ClearLogic.canPlace(grid, 2, 2, blockShape), true);
      });

      test('应该拒绝大方块超出边界', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [
          Offset(0, 0), Offset(1, 0), Offset(2, 0),
          Offset(0, 1), Offset(1, 1), Offset(2, 1),
          Offset(0, 2), Offset(1, 2), Offset(2, 2),
        ]; // 3x3大方块
        
        // 放置在x=6，会超出右边界
        expect(ClearLogic.canPlace(grid, 6, 0, blockShape), false);
        
        // 放置在y=6，会超出下边界
        expect(ClearLogic.canPlace(grid, 0, 6, blockShape), false);
      });
    });

    group('canPlace - 碰撞检测', () {
      test('应该拒绝与已有方块碰撞的放置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        grid[0][0] = 1; // 在(0,0)放置一个方块
        
        final blockShape = [Offset(0, 0), Offset(1, 0)];
        
        expect(ClearLogic.canPlace(grid, 0, 0, blockShape), false);
      });

      test('应该拒绝部分碰撞的放置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        grid[2][2] = 1; // 在(2,2)放置一个方块
        
        final blockShape = [Offset(0, 0), Offset(1, 0), Offset(2, 0)]; // 横3
        
        // 放置在x=0, y=2，会占据(0,2), (1,2), (2,2)，其中(2,2)碰撞
        expect(ClearLogic.canPlace(grid, 0, 2, blockShape), false);
      });

      test('应该允许避开已有方块的放置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        grid[0][0] = 1; // 在(0,0)放置一个方块
        
        final blockShape = [Offset(0, 0), Offset(1, 0)];
        
        // 放置在x=1, y=0，避开(0,0)
        expect(ClearLogic.canPlace(grid, 1, 0, blockShape), true);
      });

      test('应该在填充的网格中找到空位放置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        // 填充部分格子
        grid[0][0] = 1;
        grid[0][1] = 1;
        grid[1][0] = 1;
        
        final blockShape = [Offset(0, 0)]; // 单格
        
        // 在(1,1)放置，是空的
        expect(ClearLogic.canPlace(grid, 1, 1, blockShape), true);
      });

      test('应该拒绝在填满的网格中放置', () {
        final grid = List.generate(8, (_) => List.filled(8, 1)); // 全满
        
        final blockShape = [Offset(0, 0)]; // 单格
        
        // 任何位置都无法放置
        expect(ClearLogic.canPlace(grid, 0, 0, blockShape), false);
        expect(ClearLogic.canPlace(grid, 3, 3, blockShape), false);
        expect(ClearLogic.canPlace(grid, 7, 7, blockShape), false);
      });

      test('应该处理复杂形状的碰撞检测', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        // 创建一些障碍
        grid[2][2] = 1;
        grid[3][3] = 1;
        
        final blockShape = [
          Offset(0, 0), Offset(1, 0), Offset(2, 0), Offset(3, 0),
          Offset(1, 1), Offset(2, 1),
          Offset(2, 2),
        ]; // 大T形
        
        // 放置在x=0, y=0，会碰撞
        expect(ClearLogic.canPlace(grid, 0, 0, blockShape), false);
        
        // 放置在x=0, y=4，不会碰撞
        expect(ClearLogic.canPlace(grid, 0, 4, blockShape), true);
      });
    });

    group('placeBlock - 放置方块', () {
      test('应该正确放置单格方块', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [Offset(0, 0)];
        
        final newGrid = ClearLogic.placeBlock(grid, 3, 3, blockShape);
        
        expect(newGrid[3][3], 1);
        // 其他位置应该保持为空
        expect(newGrid[0][0], 0);
        expect(newGrid[7][7], 0);
      });

      test('应该正确放置L形方块', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [
          Offset(0, 0), Offset(0, 1), Offset(0, 2), Offset(1, 2),
        ]; // L形
        
        final newGrid = ClearLogic.placeBlock(grid, 2, 2, blockShape);
        
        expect(newGrid[2][2], 1); // (2,2)
        expect(newGrid[3][2], 1); // (2,3)
        expect(newGrid[4][2], 1); // (2,4)
        expect(newGrid[4][3], 1); // (3,4)
      });

      test('应该正确放置3x3大方块', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [
          Offset(0, 0), Offset(1, 0), Offset(2, 0),
          Offset(0, 1), Offset(1, 1), Offset(2, 1),
          Offset(0, 2), Offset(1, 2), Offset(2, 2),
        ];
        
        final newGrid = ClearLogic.placeBlock(grid, 2, 2, blockShape);
        
        // 检查3x3区域
        for (int row = 2; row < 5; row++) {
          for (int col = 2; col < 5; col++) {
            expect(newGrid[row][col], 1);
          }
        }
      });

      test('不应该修改原始网格', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blockShape = [Offset(0, 0)];
        
        ClearLogic.placeBlock(grid, 3, 3, blockShape);
        
        // 原始网格应该保持不变
        expect(grid[3][3], 0);
      });

      test('应该在已有方块上正确叠加', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        grid[0][0] = 1; // 已有方块
        
        final blockShape = [Offset(0, 0), Offset(1, 0)];
        
        final newGrid = ClearLogic.placeBlock(grid, 1, 0, blockShape);
        
        expect(newGrid[0][0], 1); // 原有方块
        expect(newGrid[0][1], 1); // 新放置
        expect(newGrid[0][2], 1); // 新放置
      });
    });

    group('isGameOver - 游戏结束检测', () {
      test('空网格不应该结束游戏', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final availableBlocks = [
          [Offset(0, 0)], // 单格
        ];
        
        expect(ClearLogic.isGameOver(grid, availableBlocks), false);
      });

      test('有可用位置时不应该结束游戏', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        grid[0][0] = 1;
        
        final availableBlocks = [
          [Offset(0, 0)], // 单格
        ];
        
        expect(ClearLogic.isGameOver(grid, availableBlocks), false);
      });

      test('全满网格应该结束游戏', () {
        final grid = List.generate(8, (_) => List.filled(8, 1));
        final availableBlocks = [
          [Offset(0, 0)], // 单格
        ];
        
        expect(ClearLogic.isGameOver(grid, availableBlocks), true);
      });

      test('无法放置任何方块时应该结束游戏', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        // 只留下一个空位
        grid[7][7] = 0;
        for (int row = 0; row < 8; row++) {
          for (int col = 0; col < 8; col++) {
            if (row != 7 || col != 7) {
              grid[row][col] = 1;
            }
          }
        }
        
        final availableBlocks = [
          [Offset(0, 0), Offset(1, 0)], // 横2，需要2个位置
        ];
        
        // 只剩1个位置，无法放置横2
        expect(ClearLogic.isGameOver(grid, availableBlocks), true);
      });

      test('有任一方块可以放置时不应该结束游戏', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        // 只留下一个空位
        grid[7][7] = 0;
        for (int row = 0; row < 8; row++) {
          for (int col = 0; col < 8; col++) {
            if (row != 7 || col != 7) {
              grid[row][col] = 1;
            }
          }
        }
        
        final availableBlocks = [
          [Offset(0, 0), Offset(1, 0)], // 横2，需要2个位置
          [Offset(0, 0)], // 单格，只需要1个位置
        ];
        
        // 虽然横2放不下，但单格可以放下
        expect(ClearLogic.isGameOver(grid, availableBlocks), false);
      });
    });
  });
}
