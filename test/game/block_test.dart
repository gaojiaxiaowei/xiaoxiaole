import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/game/block.dart';
import 'package:block_blast/game/themes/themes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // 初始化 ThemeManager 全局实例
    ThemeManager.setGlobalInstance(ThemeManager());
  });

  group('Block Tests', () {
    group('Block 定义测试', () {
      test('所有预定义方块都有正确的属性', () {
        expect(Block.allBlocks.length, greaterThan(10));

        for (final block in Block.allBlocks) {
          expect(block.id, isNotEmpty);
          expect(block.shape, isNotEmpty);
          expect(block.name, isNotEmpty);
        }
      });

      test('单格方块定义正确', () {
        final single = Block.allBlocks.firstWhere((b) => b.id == 'single');
        expect(single.shape.length, 1);
        expect(single.shape.first, const Offset(0, 0));
      });

      test('2x2方块定义正确', () {
        final square = Block.allBlocks.firstWhere((b) => b.id == 'square');
        expect(square.shape.length, 4);
        expect(square.name, '方块');
      });

      test('L形方块定义正确', () {
        final lShape = Block.allBlocks.firstWhere((b) => b.id == 'l');
        expect(lShape.shape.length, 4);
        expect(lShape.name, 'L形');
      });

      test('T形方块定义正确', () {
        final tShape = Block.allBlocks.firstWhere((b) => b.id == 't');
        expect(tShape.shape.length, 4);
        expect(tShape.name, 'T形');
      });

      test('十字形方块定义正确', () {
        final cross = Block.allBlocks.firstWhere((b) => b.id == 'cross');
        expect(cross.shape.length, 5);
        expect(cross.name, '十字');
      });

      test('3x3大方块定义正确', () {
        final bigSquare = Block.allBlocks.firstWhere((b) => b.id == 'bigSquare');
        expect(bigSquare.shape.length, 9);
        expect(bigSquare.name, '大方块');
      });

      test('所有方块形状坐标都是非负整数', () {
        for (final block in Block.allBlocks) {
          for (final offset in block.shape) {
            expect(offset.dx, greaterThanOrEqualTo(0));
            expect(offset.dy, greaterThanOrEqualTo(0));
          }
        }
      });

      test('方块ID唯一性', () {
        final ids = Block.allBlocks.map((b) => b.id).toList();
        final uniqueIds = ids.toSet();
        expect(ids.length, uniqueIds.length);
      });
    });

    group('Block 颜色测试', () {
      test('方块颜色从主题获取', () {
        // ThemeManager 已在 setUpAll 中初始化
        for (final block in Block.allBlocks) {
          // 获取颜色不应该抛出异常
          expect(() => block.color, returnsNormally);

          final color = block.color;
          expect(color, isNotNull);
        }
      });
    });

    group('getRandomBlocks 测试', () {
      test('返回3个方块', () {
        for (int i = 0; i < 10; i++) {
          final blocks = Block.getRandomBlocks();
          expect(blocks.length, 3);
        }
      });

      test('返回的方块来自预定义列表', () {
        final blocks = Block.getRandomBlocks();
        for (final block in blocks) {
          expect(Block.allBlocks.contains(block), true);
        }
      });

      test('多次调用返回不同结果（随机性）', () {
        final results = <String>{};
        for (int i = 0; i < 50; i++) {
          final blocks = Block.getRandomBlocks();
          final key = blocks.map((b) => b.id).join(',');
          results.add(key);
        }
        // 50次调用应该有多种不同的组合
        expect(results.length, greaterThan(1));
      });
    });

    group('getBlocksByDifficulty 测试 - 普通难度', () {
      test('低分(0-499)返回3个方块', () {
        for (int score = 0; score < 500; score += 100) {
          final blocks = Block.getBlocksByDifficulty(score);
          expect(blocks.length, 3, reason: '分数 $score 应返回3个方块');
        }
      });

      test('高分(>1000)返回2个方块', () {
        for (int score = 1001; score <= 2000; score += 100) {
          final blocks = Block.getBlocksByDifficulty(score);
          expect(blocks.length, 2, reason: '分数 $score 应返回2个方块');
        }
      });

      test('中等分数(500-1000)返回2-3个方块', () {
        for (int score = 500; score <= 1000; score += 100) {
          final blocks = Block.getBlocksByDifficulty(score);
          expect(blocks.length, inInclusiveRange(2, 3));
        }
      });

      test('返回的方块来自预定义列表', () {
        final blocks = Block.getBlocksByDifficulty(0);
        for (final block in blocks) {
          expect(Block.allBlocks.contains(block), true);
        }
      });
    });

    group('getBlocksByUserDifficulty 测试 - 简单难度', () {
      test('简单难度返回3个方块', () {
        for (int i = 0; i < 10; i++) {
          final blocks = Block.getBlocksByUserDifficulty('easy', 0);
          expect(blocks.length, 3);
        }
      });

      test('简单难度只返回简单方块', () {
        const easyBlockIds = [
          'single', 'h2', 'v2', 'h3', 'v3', 'square', 'h4', 'v4',
        ];

        for (int i = 0; i < 10; i++) {
          final blocks = Block.getBlocksByUserDifficulty('easy', 0);
          for (final block in blocks) {
            expect(easyBlockIds.contains(block.id), true,
                reason: '${block.id} 不在简单方块池中');
          }
        }
      });

      test('简单难度忽略分数参数', () {
        // 简单难度不应该受分数影响
        final blocks0 = Block.getBlocksByUserDifficulty('easy', 0);
        final blocksHigh = Block.getBlocksByUserDifficulty('easy', 10000);

        expect(blocks0.length, 3);
        expect(blocksHigh.length, 3);
      });
    });

    group('getBlocksByUserDifficulty 测试 - 困难难度', () {
      test('困难难度返回2-3个方块', () {
        for (int i = 0; i < 20; i++) {
          final blocks = Block.getBlocksByUserDifficulty('hard', 0);
          expect(blocks.length, inInclusiveRange(2, 3));
        }
      });

      test('困难难度只返回困难方块', () {
        const hardBlockIds = [
          'h4', 'v4', 'h5', 'v5', 'square', 'bigSquare',
          'cross', 'bigT', 'stairs', 'l', 'rl', 't', 'u',
        ];

        for (int i = 0; i < 10; i++) {
          final blocks = Block.getBlocksByUserDifficulty('hard', 0);
          for (final block in blocks) {
            expect(hardBlockIds.contains(block.id), true,
                reason: '${block.id} 不在困难方块池中');
          }
        }
      });

      test('困难难度忽略分数参数', () {
        // 困难难度不应该受分数影响
        final blocks0 = Block.getBlocksByUserDifficulty('hard', 0);
        final blocksHigh = Block.getBlocksByUserDifficulty('hard', 10000);

        expect(blocks0.length, inInclusiveRange(2, 3));
        expect(blocksHigh.length, inInclusiveRange(2, 3));
      });
    });

    group('getBlocksByUserDifficulty 测试 - 边界条件', () {
      test('未知难度默认使用普通难度逻辑', () {
        final blocks = Block.getBlocksByUserDifficulty('unknown', 0);
        expect(blocks.length, 3); // 低分应该返回3个
      });

      test('空字符串难度使用普通难度逻辑', () {
        final blocks = Block.getBlocksByUserDifficulty('', 0);
        expect(blocks.length, 3);
      });

      test('null安全 - 极端分数值', () {
        expect(() => Block.getBlocksByUserDifficulty('easy', -1), returnsNormally);
        expect(() => Block.getBlocksByUserDifficulty('easy', 999999999), returnsNormally);
        expect(() => Block.getBlocksByDifficulty(-1), returnsNormally);
        expect(() => Block.getBlocksByDifficulty(999999999), returnsNormally);
      });
    });

    group('方块形状边界测试', () {
      test('横条形状边界正确', () {
        final h5 = Block.allBlocks.firstWhere((b) => b.id == 'h5');
        expect(h5.shape.length, 5);

        int maxX = 0;
        for (final offset in h5.shape) {
          if (offset.dx > maxX) maxX = offset.dx.toInt();
        }
        expect(maxX, 4);
      });

      test('竖条形状边界正确', () {
        final v5 = Block.allBlocks.firstWhere((b) => b.id == 'v5');
        expect(v5.shape.length, 5);

        int maxY = 0;
        for (final offset in v5.shape) {
          if (offset.dy > maxY) maxY = offset.dy.toInt();
        }
        expect(maxY, 4);
      });

      test('U形方块有空洞', () {
        final uShape = Block.allBlocks.firstWhere((b) => b.id == 'u');
        // U形: (0,0), (2,0), (0,1), (1,1), (2,1)
        // 位置 (1,0) 是空的
        expect(uShape.shape.length, 5);

        final hasHole = !uShape.shape.any(
          (offset) => offset.dx == 1 && offset.dy == 0,
        );
        expect(hasHole, true);
      });
    });
  });
}
