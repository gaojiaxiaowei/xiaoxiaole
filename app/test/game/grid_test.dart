import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:block_blast/game/grid.dart';
import 'package:block_blast/game/block.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Grid 数据操作测试', () {
    group('网格初始化测试', () {
      test('创建空网格', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));

        expect(grid.length, 8);
        for (final row in grid) {
          expect(row.length, 8);
          for (final cell in row) {
            expect(cell, 0);
          }
        }
      });

      test('网格大小正确', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        expect(grid.length, 8);
        expect(grid[0].length, 8);
      });
    });

    group('方块放置测试', () {
      test('在有效位置放置单格方块', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final block = Block.allBlocks.firstWhere((b) => b.id == 'single');

        // 放置在 (3, 3)
        for (final offset in block.shape) {
          final x = 3 + offset.dx.toInt();
          final y = 3 + offset.dy.toInt();
          grid[y][x] = 1;
        }

        expect(grid[3][3], 1);
        expect(grid[0][0], 0);
      });

      test('在边界位置放置方块', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final block = Block.allBlocks.firstWhere((b) => b.id == 'square');

        // 放置在右下角 (6, 6)
        for (final offset in block.shape) {
          final x = 6 + offset.dx.toInt();
          final y = 6 + offset.dy.toInt();
          if (x < 8 && y < 8) {
            grid[y][x] = 1;
          }
        }

        expect(grid[6][6], 1);
        expect(grid[6][7], 1);
        expect(grid[7][6], 1);
        expect(grid[7][7], 1);
      });

      test('检测是否可以放置方块', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final block = Block.allBlocks.firstWhere((b) => b.id == 'h3');

        // 检查在 (0, 0) 放置
        bool canPlace = true;
        for (final offset in block.shape) {
          final x = 0 + offset.dx.toInt();
          final y = 0 + offset.dy.toInt();
          if (x < 0 || x >= 8 || y < 0 || y >= 8 || grid[y][x] != 0) {
            canPlace = false;
            break;
          }
        }

        expect(canPlace, true);
      });

      test('检测不能放置方块 - 已占用', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        grid[0][1] = 1; // 占用一个位置

        final block = Block.allBlocks.firstWhere((b) => b.id == 'h3');

        bool canPlace = true;
        for (final offset in block.shape) {
          final x = 0 + offset.dx.toInt();
          final y = 0 + offset.dy.toInt();
          if (x < 0 || x >= 8 || y < 0 || y >= 8 || grid[y][x] != 0) {
            canPlace = false;
            break;
          }
        }

        expect(canPlace, false);
      });

      test('检测不能放置方块 - 超出边界', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final block = Block.allBlocks.firstWhere((b) => b.id == 'h5');

        // 尝试在 (5, 0) 放置横5（需要5格，但只有3格空间）
        bool canPlace = true;
        for (final offset in block.shape) {
          final x = 5 + offset.dx.toInt();
          final y = 0 + offset.dy.toInt();
          if (x < 0 || x >= 8 || y < 0 || y >= 8 || grid[y][x] != 0) {
            canPlace = false;
            break;
          }
        }

        expect(canPlace, false);
      });
    });

    group('行/列消除测试', () {
      test('检测可消除的行', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));

        // 填满第3行
        for (int col = 0; col < 8; col++) {
          grid[3][col] = 1;
        }

        final rowsToClear = <int>[];
        for (int row = 0; row < 8; row++) {
          if (grid[row].every((cell) => cell == 1)) {
            rowsToClear.add(row);
          }
        }

        expect(rowsToClear, [3]);
      });

      test('检测可消除的列', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));

        // 填满第4列
        for (int row = 0; row < 8; row++) {
          grid[row][4] = 1;
        }

        final colsToClear = <int>[];
        for (int col = 0; col < 8; col++) {
          bool isFull = true;
          for (int row = 0; row < 8; row++) {
            if (grid[row][col] != 1) {
              isFull = false;
              break;
            }
          }
          if (isFull) {
            colsToClear.add(col);
          }
        }

        expect(colsToClear, [4]);
      });

      test('消除行', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));

        // 填满第2行和第5行
        for (int col = 0; col < 8; col++) {
          grid[2][col] = 1;
          grid[5][col] = 1;
        }

        // 消除行
        final rowsToClear = [2, 5];
        for (final row in rowsToClear) {
          for (int col = 0; col < 8; col++) {
            grid[row][col] = 0;
          }
        }

        // 验证行已清空
        for (final row in rowsToClear) {
          for (int col = 0; col < 8; col++) {
            expect(grid[row][col], 0);
          }
        }
      });

      test('消除列', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));

        // 填满第1列和第6列
        for (int row = 0; row < 8; row++) {
          grid[row][1] = 1;
          grid[row][6] = 1;
        }

        // 消除列
        final colsToClear = [1, 6];
        for (final col in colsToClear) {
          for (int row = 0; row < 8; row++) {
            grid[row][col] = 0;
          }
        }

        // 验证列已清空
        for (final col in colsToClear) {
          for (int row = 0; row < 8; row++) {
            expect(grid[row][col], 0);
          }
        }
      });

      test('同时消除行和列', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));

        // 填满第0行和第0列
        for (int col = 0; col < 8; col++) {
          grid[0][col] = 1;
        }
        for (int row = 0; row < 8; row++) {
          grid[row][0] = 1;
        }

        // 消除
        for (int col = 0; col < 8; col++) {
          grid[0][col] = 0;
        }
        for (int row = 0; row < 8; row++) {
          grid[row][0] = 0;
        }

        // 验证
        expect(grid[0].every((c) => c == 0), true);
        for (int row = 0; row < 8; row++) {
          expect(grid[row][0], 0);
        }
      });
    });

    group('网格状态检查测试', () {
      test('检查网格是否为空', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        bool isEmpty = true;
        for (final row in grid) {
          for (final cell in row) {
            if (cell != 0) {
              isEmpty = false;
              break;
            }
          }
        }
        expect(isEmpty, true);
      });

      test('检查网格是否已满', () {
        final grid = List.generate(8, (_) => List.filled(8, 1));
        bool isFull = true;
        for (final row in grid) {
          for (final cell in row) {
            if (cell != 1) {
              isFull = false;
              break;
            }
          }
        }
        expect(isFull, true);
      });

      test('计算已占用格子数', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        grid[0][0] = 1;
        grid[1][1] = 1;
        grid[2][2] = 1;

        int count = 0;
        for (final row in grid) {
          for (final cell in row) {
            if (cell == 1) count++;
          }
        }

        expect(count, 3);
      });
    });

    group('游戏结束检测测试', () {
      test('有空位时可以放置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        final blocks = Block.getRandomBlocks();

        // 检查是否有任何方块可以放置
        bool canPlaceAny = false;
        for (final block in blocks) {
          for (int y = 0; y < 8; y++) {
            for (int x = 0; x < 8; x++) {
              bool canPlace = true;
              for (final offset in block.shape) {
                final nx = x + offset.dx.toInt();
                final ny = y + offset.dy.toInt();
                if (nx < 0 || nx >= 8 || ny < 0 || ny >= 8 || grid[ny][nx] != 0) {
                  canPlace = false;
                  break;
                }
              }
              if (canPlace) {
                canPlaceAny = true;
                break;
              }
            }
            if (canPlaceAny) break;
          }
          if (canPlaceAny) break;
        }

        expect(canPlaceAny, true); // 空网格应该可以放置
      });

      test('几乎满的网格检测', () {
        final grid = List.generate(8, (_) => List.filled(8, 1));
        // 只留下 (0,0) 一个空位
        grid[0][0] = 0;

        final singleBlock = Block.allBlocks.firstWhere((b) => b.id == 'single');

        // 检查单格方块是否可以放置
        bool canPlaceSingle = false;
        for (int y = 0; y < 8 && !canPlaceSingle; y++) {
          for (int x = 0; x < 8 && !canPlaceSingle; x++) {
            bool canPlace = true;
            for (final offset in singleBlock.shape) {
              final nx = x + offset.dx.toInt();
              final ny = y + offset.dy.toInt();
              if (nx < 0 || nx >= 8 || ny < 0 || ny >= 8 || grid[ny][nx] != 0) {
                canPlace = false;
                break;
              }
            }
            if (canPlace) canPlaceSingle = true;
          }
        }

        expect(canPlaceSingle, true); // 单格方块应该可以放在 (0,0)
      });
    });
  });
}
