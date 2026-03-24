import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/game/clear.dart';

void main() {
  group('ClearLogic - 消除逻辑测试', () {
    group('checkClearPositions - 检查消除位置', () {
      test('应该识别填满的行', () {
        final grid = List.generate(8, (row) => 
          row == 0 ? List.filled(8, 1) : List.filled(8, 0)
        );
        
        final (rowsToClear, colsToClear) = ClearLogic.checkClearPositions(grid);
        
        expect(rowsToClear, [0]);
        expect(colsToClear, isEmpty);
      });

      test('应该识别多行填满', () {
        final grid = List.generate(8, (row) => 
          (row == 0 || row == 2) ? List.filled(8, 1) : List.filled(8, 0)
        );
        
        final (rowsToClear, colsToClear) = ClearLogic.checkClearPositions(grid);
        
        expect(rowsToClear, containsAll([0, 2]));
        expect(colsToClear, isEmpty);
      });

      test('应该识别填满的列', () {
        final grid = List.generate(8, (row) => 
          List.generate(8, (col) => col == 0 ? 1 : 0)
        );
        
        final (rowsToClear, colsToClear) = ClearLogic.checkClearPositions(grid);
        
        expect(rowsToClear, isEmpty);
        expect(colsToClear, [0]);
      });

      test('应该识别多列填满', () {
        final grid = List.generate(8, (row) => 
          List.generate(8, (col) => (col == 0 || col == 3) ? 1 : 0)
        );
        
        final (rowsToClear, colsToClear) = ClearLogic.checkClearPositions(grid);
        
        expect(rowsToClear, isEmpty);
        expect(colsToClear, containsAll([0, 3]));
      });

      test('应该同时识别填满的行和列', () {
        // 创建一个十字形的填满：第0行和第0列都填满
        final grid = List.generate(8, (row) => 
          List.generate(8, (col) => (row == 0 || col == 0) ? 1 : 0)
        );
        
        final (rowsToClear, colsToClear) = ClearLogic.checkClearPositions(grid);
        
        expect(rowsToClear, [0]);
        expect(colsToClear, [0]);
      });

      test('空网格不应该有任何消除', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        
        final (rowsToClear, colsToClear) = ClearLogic.checkClearPositions(grid);
        
        expect(rowsToClear, isEmpty);
        expect(colsToClear, isEmpty);
      });

      test('部分填充的行不应该被消除', () {
        final grid = List.generate(8, (row) => 
          row == 0 ? List.filled(7, 1) + [0] : List.filled(8, 0)
        );
        
        final (rowsToClear, colsToClear) = ClearLogic.checkClearPositions(grid);
        
        expect(rowsToClear, isEmpty);
        expect(colsToClear, isEmpty);
      });
    });

    group('clearRowsAndCols - 执行消除操作', () {
      test('应该清除指定行的所有格子', () {
        final grid = List.generate(8, (row) => 
          row == 0 ? List.filled(8, 1) : List.filled(8, 0)
        );
        
        final newGrid = ClearLogic.clearRowsAndCols(grid, [0], []);
        
        // 行0应该被清空
        expect(newGrid[0].every((cell) => cell == 0), true);
        // 其他行应该保持不变
        for (int row = 1; row < 8; row++) {
          expect(newGrid[row].every((cell) => cell == 0), true);
        }
      });

      test('应该清除指定列的所有格子', () {
        final grid = List.generate(8, (row) => 
          List.generate(8, (col) => col == 0 ? 1 : 0)
        );
        
        final newGrid = ClearLogic.clearRowsAndCols(grid, [], [0]);
        
        // 列0应该被清空
        for (int row = 0; row < 8; row++) {
          expect(newGrid[row][0], 0);
        }
      });

      test('应该同时清除行和列', () {
        final grid = List.generate(8, (row) => List.filled(8, 1));
        
        final newGrid = ClearLogic.clearRowsAndCols(grid, [0, 1], [0, 1]);
        
        // 行0和1的所有格子应该被清空
        expect(newGrid[0].every((cell) => cell == 0), true);
        expect(newGrid[1].every((cell) => cell == 0), true);
        // 列0和1的所有格子应该被清空（但行0,1已经被清空了）
        for (int row = 2; row < 8; row++) {
          expect(newGrid[row][0], 0);
          expect(newGrid[row][1], 0);
        }
      });

      test('不应该修改原始网格', () {
        final grid = List.generate(8, (row) => 
          row == 0 ? List.filled(8, 1) : List.filled(8, 0)
        );
        
        ClearLogic.clearRowsAndCols(grid, [0], []);
        
        // 原始网格应该保持不变
        expect(grid[0].every((cell) => cell == 1), true);
      });
    });

    group('checkAndClear - 检查并消除', () {
      test('应该消除填满的行并返回消除数量', () {
        final grid = List.generate(8, (row) => 
          row == 0 ? List.filled(8, 1) : List.filled(8, 0)
        );
        
        final (newGrid, rowsCleared, colsCleared) = ClearLogic.checkAndClear(grid);
        
        expect(rowsCleared, 1);
        expect(colsCleared, 0);
        expect(newGrid[0].every((cell) => cell == 0), true);
      });

      test('应该消除填满的列并返回消除数量', () {
        final grid = List.generate(8, (row) => 
          List.generate(8, (col) => col == 0 ? 1 : 0)
        );
        
        final (newGrid, rowsCleared, colsCleared) = ClearLogic.checkAndClear(grid);
        
        expect(rowsCleared, 0);
        expect(colsCleared, 1);
        for (int row = 0; row < 8; row++) {
          expect(newGrid[row][0], 0);
        }
      });

      test('应该同时消除行和列', () {
        final grid = List.generate(8, (row) => List.filled(8, 1));
        
        final (newGrid, rowsCleared, colsCleared) = ClearLogic.checkAndClear(grid);
        
        expect(rowsCleared, 8);
        expect(colsCleared, 8);
        // 所有格子应该被清空
        for (int row = 0; row < 8; row++) {
          expect(newGrid[row].every((cell) => cell == 0), true);
        }
      });

      test('空网格不应该消除任何东西', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        
        final (newGrid, rowsCleared, colsCleared) = ClearLogic.checkAndClear(grid);
        
        expect(rowsCleared, 0);
        expect(colsCleared, 0);
      });

      test('连锁消除 - 多行同时消除', () {
        final grid = List.generate(8, (row) => 
          (row == 0 || row == 1 || row == 2) ? List.filled(8, 1) : List.filled(8, 0)
        );
        
        final (newGrid, rowsCleared, colsCleared) = ClearLogic.checkAndClear(grid);
        
        expect(rowsCleared, 3);
        expect(colsCleared, 0);
        expect(newGrid[0].every((cell) => cell == 0), true);
        expect(newGrid[1].every((cell) => cell == 0), true);
        expect(newGrid[2].every((cell) => cell == 0), true);
      });

      test('连锁消除 - 多列同时消除', () {
        final grid = List.generate(8, (row) => 
          List.generate(8, (col) => (col == 0 || col == 1 || col == 2) ? 1 : 0)
        );
        
        final (newGrid, rowsCleared, colsCleared) = ClearLogic.checkAndClear(grid);
        
        expect(rowsCleared, 0);
        expect(colsCleared, 3);
      });

      test('连锁消除 - 行列同时消除', () {
        // 创建一个T字形：第0行全满，第0列全满
        final grid = List.generate(8, (row) => 
          List.generate(8, (col) => (row == 0 || col == 0) ? 1 : 0)
        );
        
        final (newGrid, rowsCleared, colsCleared) = ClearLogic.checkAndClear(grid);
        
        expect(rowsCleared, 1);
        expect(colsCleared, 1);
      });
    });
  });
}
