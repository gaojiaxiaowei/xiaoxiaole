import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:block_blast/game/grid.dart';
import 'package:block_blast/game/block.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BlockDragData Tests', () {
    test('创建拖拽数据', () {
      final block = Block.allBlocks.firstWhere((b) => b.id == 'square');
      final dragData = BlockDragData(
        block: block,
        shape: block.shape,
      );

      expect(dragData.block, block);
      expect(dragData.shape, block.shape);
    });

    test('const 构造函数', () {
      const dragData = BlockDragData(
        block: Block(
          id: 'test',
          shape: [Offset(0, 0)],
          name: '测试',
        ),
        shape: [Offset(0, 0)],
      );

      expect(dragData.block.id, 'test');
    });

    test('形状与方块形状一致', () {
      for (final block in Block.allBlocks) {
        final dragData = BlockDragData(
          block: block,
          shape: block.shape,
        );

        expect(dragData.shape.length, block.shape.length);
        for (int i = 0; i < block.shape.length; i++) {
          expect(dragData.shape[i], block.shape[i]);
        }
      }
    });
  });

  group('BlockPreviewData Tests', () {
    test('创建预览数据 - 可放置', () {
      final previewData = BlockPreviewData(
        previewPositions: [
          const Offset(0, 0),
          const Offset(1, 0),
          const Offset(0, 1),
          const Offset(1, 1),
        ],
        canPlace: true,
      );

      expect(previewData.previewPositions.length, 4);
      expect(previewData.canPlace, true);
    });

    test('创建预览数据 - 不可放置', () {
      final previewData = BlockPreviewData(
        previewPositions: [
          const Offset(0, 0),
        ],
        canPlace: false,
      );

      expect(previewData.canPlace, false);
    });

    test('空预览位置', () {
      final previewData = BlockPreviewData(
        previewPositions: [],
        canPlace: true,
      );

      expect(previewData.previewPositions, isEmpty);
    });

    test('边界坐标预览', () {
      // 网格边界位置
      final previewData = BlockPreviewData(
        previewPositions: [
          const Offset(0, 0), // 左上角
          const Offset(7, 7), // 右下角
        ],
        canPlace: true,
      );

      expect(previewData.previewPositions.length, 2);
    });

    test('超出网格范围的预览坐标', () {
      // 注意：预览数据本身不做边界检查，由调用方负责
      final previewData = BlockPreviewData(
        previewPositions: [
          const Offset(-1, -1), // 负坐标
          const Offset(8, 8),   // 超出范围
        ],
        canPlace: false,
      );

      expect(previewData.previewPositions.length, 2);
      expect(previewData.canPlace, false);
    });
  });

  group('ClearAnimationData Tests', () {
    test('创建消除动画数据', () {
      final clearData = ClearAnimationData(
        clearingRows: [0, 7],
        clearingCols: [3, 4],
        animationValue: 0.5,
      );

      expect(clearData.clearingRows, [0, 7]);
      expect(clearData.clearingCols, [3, 4]);
      expect(clearData.animationValue, 0.5);
    });

    test('isClearing 检测 - 行消除', () {
      final clearData = ClearAnimationData(
        clearingRows: [2, 5],
        clearingCols: [],
        animationValue: 0.0,
      );

      expect(clearData.isClearing(2, 0), true); // 第2行
      expect(clearData.isClearing(2, 7), true); // 第2行
      expect(clearData.isClearing(5, 3), true); // 第5行
      expect(clearData.isClearing(0, 0), false); // 不在消除行
      expect(clearData.isClearing(1, 2), false); // 不在消除行
    });

    test('isClearing 检测 - 列消除', () {
      final clearData = ClearAnimationData(
        clearingRows: [],
        clearingCols: [1, 6],
        animationValue: 0.5,
      );

      expect(clearData.isClearing(0, 1), true); // 第1列
      expect(clearData.isClearing(7, 1), true); // 第1列
      expect(clearData.isClearing(0, 6), true); // 第6列
      expect(clearData.isClearing(0, 0), false); // 不在消除列
      expect(clearData.isClearing(3, 3), false); // 不在消除列
    });

    test('isClearing 检测 - 行列同时消除', () {
      final clearData = ClearAnimationData(
        clearingRows: [3],
        clearingCols: [3],
        animationValue: 0.8,
      );

      // 交叉点 (3, 3) 在行3和列3
      expect(clearData.isClearing(3, 3), true);
      // 行3的其他位置
      expect(clearData.isClearing(3, 0), true);
      expect(clearData.isClearing(3, 7), true);
      // 列3的其他位置
      expect(clearData.isClearing(0, 3), true);
      expect(clearData.isClearing(7, 3), true);
      // 不在消除范围内
      expect(clearData.isClearing(0, 0), false);
      expect(clearData.isClearing(7, 7), false);
    });

    test('动画进度边界', () {
      // 动画开始
      final startData = ClearAnimationData(
        clearingRows: [0],
        clearingCols: [],
        animationValue: 0.0,
      );
      expect(startData.animationValue, 0.0);

      // 动画结束
      final endData = ClearAnimationData(
        clearingRows: [0],
        clearingCols: [],
        animationValue: 1.0,
      );
      expect(endData.animationValue, 1.0);
    });

    test('空消除列表', () {
      final clearData = ClearAnimationData(
        clearingRows: [],
        clearingCols: [],
        animationValue: 0.0,
      );

      for (int row = 0; row < 8; row++) {
        for (int col = 0; col < 8; col++) {
          expect(clearData.isClearing(row, col), false);
        }
      }
    });
  });

  group('PlaceAnimationData Tests', () {
    test('创建放置动画数据', () {
      final placeData = PlaceAnimationData(
        placedPositions: [
          const Offset(0, 0),
          const Offset(1, 0),
        ],
        animationValue: 0.5,
      );

      expect(placeData.placedPositions.length, 2);
      expect(placeData.animationValue, 0.5);
    });

    test('isPlaced 检测', () {
      final placeData = PlaceAnimationData(
        placedPositions: [
          const Offset(0, 0),
          const Offset(1, 1),
          const Offset(2, 2),
        ],
        animationValue: 0.3,
      );

      expect(placeData.isPlaced(0, 0), true);
      expect(placeData.isPlaced(1, 1), true);
      expect(placeData.isPlaced(2, 2), true);
      expect(placeData.isPlaced(0, 1), false); // 位置不存在
      expect(placeData.isPlaced(3, 3), false); // 位置不存在
    });

    test('坐标顺序不影响 isPlaced', () {
      final placeData = PlaceAnimationData(
        placedPositions: [
          const Offset(5, 3), // col=5, row=3
        ],
        animationValue: 0.0,
      );

      // isPlaced(row, col) 内部用 dx=col, dy=row 比较
      expect(placeData.isPlaced(3, 5), true);
      expect(placeData.isPlaced(5, 3), false); // 顺序反了
    });

    test('动画进度范围', () {
      // 开始
      final startData = PlaceAnimationData(
        placedPositions: [],
        animationValue: 0.0,
      );
      expect(startData.animationValue, 0.0);

      // 结束
      final endData = PlaceAnimationData(
        placedPositions: [],
        animationValue: 1.0,
      );
      expect(endData.animationValue, 1.0);

      // 中间值
      final midData = PlaceAnimationData(
        placedPositions: [],
        animationValue: 0.42,
      );
      expect(midData.animationValue, closeTo(0.42, 0.001));
    });

    test('空放置位置列表', () {
      final placeData = PlaceAnimationData(
        placedPositions: [],
        animationValue: 0.5,
      );

      expect(placeData.placedPositions, isEmpty);
      expect(placeData.isPlaced(0, 0), false);
    });

    test('大量放置位置', () {
      // 模拟放置大方块
      final positions = <Offset>[];
      for (int i = 0; i < 9; i++) {
        positions.add(Offset((i % 3).toDouble(), (i ~/ 3).toDouble()));
      }

      final placeData = PlaceAnimationData(
        placedPositions: positions,
        animationValue: 0.5,
      );

      expect(placeData.placedPositions.length, 9);
      // 检查所有位置都能正确识别
      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          expect(placeData.isPlaced(row, col), true);
        }
      }
    });
  });
}
