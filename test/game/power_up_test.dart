import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/game/power_up.dart';
import 'package:block_blast/game/power_up_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PowerUp Tests', () {
    late PowerUpManager powerUpManager;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      powerUpManager = PowerUpManager();
      await powerUpManager.resetPowerUps();
    });

    tearDown(() async {
      await powerUpManager.resetPowerUps();
    });

    group('PowerUpType Tests', () {
      test('道具类型枚举值正确', () {
        expect(PowerUpType.values.length, 3);
        expect(PowerUpType.bomb.index, 0);
        expect(PowerUpType.refresh.index, 1);
        expect(PowerUpType.undo.index, 2);
      });

      test('道具配置正确', () {
        final bombConfig = PowerUp.configs[PowerUpType.bomb]!;
        expect(bombConfig.name, '炸弹');
        expect(bombConfig.description, '消除 3x3 区域的方块');
        expect(bombConfig.icon, '💣');

        final refreshConfig = PowerUp.configs[PowerUpType.refresh]!;
        expect(refreshConfig.name, '刷新');
        expect(refreshConfig.description, '重新生成3个可选方块');
        expect(refreshConfig.icon, '🔄');

        final undoConfig = PowerUp.configs[PowerUpType.undo]!;
        expect(undoConfig.name, '撤销');
        expect(undoConfig.description, '撤销上一步操作');
        expect(undoConfig.icon, '↩️');
      });

      test('炸弹道具逻辑 - 成功案例', () {
        // 创建测试网格
        final grid = List.generate(8, (_) => List.filled(8, 0));
        
        // 在中心位置放置方块（3x3区域全部填满）
        for (int i = 2; i <= 4; i++) {
          for (int j = 2; j <= 4; j++) {
            grid[i][j] = 1;
          }
        }
        
        // 使用炸弹
        final result = PowerUpLogic.useBomb(grid, 3, 3);
        
        expect(result.success, true);
        expect(result.data, isNotNull);
        
        final newGrid = result.data!['newGrid'] as List<List<int>>;
        final clearedPositions = result.data!['clearedPositions'] as List<Map<String, int>>;
        final clearedCount = result.data!['clearedCount'] as int;
        
        // 验证消除了 9 个方块（3x3 区域）
        expect(clearedCount, equals(9));
        
        // 验证新网格中这些位置被清空
        for (final pos in clearedPositions) {
          final x = pos['x']!;
          final y = pos['y']!;
          expect(newGrid[y][x], 0);
        }
      });

      test('炸弹道具逻辑 - 边界情况', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        
        // 在边缘位置使用炸弹（左上角）- 炸弹中心在(0, 1)，即x=0, y=1
        // 3x3范围: x: 0-1, y: 0-2
        // 只有x=0, y=0-1在有效范围内
        grid[0][0] = 1; // y=0, x=0
        grid[0][1] = 1; // y=0, x=1 (炸弹中心)
        grid[1][0] = 1; // y=1, x=0
        grid[1][1] = 1; // y=1, x=1
        
        final result = PowerUpLogic.useBomb(grid, 0, 1);
        
        expect(result.success, true);
        
        final clearedPositions = result.data!['clearedPositions'] as List<Map<String, int>>;
        final clearedCount = result.data!['clearedCount'] as int;
        
        // 应该只消除 4 个方块（边缘区域）
        expect(clearedCount, equals(4));
      });

      test('炸弹道具逻辑 - 空位置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        
        // 中心位置没有方块
        final result = PowerUpLogic.useBomb(grid, 3, 3);
        
        expect(result.success, false);
        expect(result.message, '该位置没有方块');
      });

      test('炸弹道具逻辑 - 无效位置', () {
        final grid = List.generate(8, (_) => List.filled(8, 0));
        
        final result = PowerUpLogic.useBomb(grid, -1, 3);
        
        expect(result.success, false);
        expect(result.message, '无效的位置');
      });

      test('炸弹得分计算', () {
        expect(PowerUpLogic.calculateBombScore(1), 5);
        expect(PowerUpLogic.calculateBombScore(5), 25);
        expect(PowerUpLogic.calculateBombScore(9), 65); // 45 + 20
        expect(PowerUpLogic.calculateBombScore(10), 70); // 50 + 20
      });

      test('随机道具类型', () {
        final types = <PowerUpType>{};
        for (int i = 0; i < 100; i++) {
          types.add(PowerUpLogic.getRandomPowerUpType());
        }
        
        // 验证所有类型都被生成
        expect(types.contains(PowerUpType.bomb), true);
        expect(types.contains(PowerUpType.refresh), true);
        expect(types.contains(PowerUpType.undo), true);
      });

      test('道具奖励判断', () {
        // 连击 5 次，应该奖励
        expect(PowerUpLogic.shouldRewardPowerUp(combo: 5), true);
        
        // 连击 4 次，不应奖励
        expect(PowerUpLogic.shouldRewardPowerUp(combo: 4), false);
        
        // 消除 3 行，应该奖励
        expect(PowerUpLogic.shouldRewardPowerUp(combo: 1, clearedRows: 3), true);
        
        // 消除 2 行，不应奖励
        expect(PowerUpLogic.shouldRewardPowerUp(combo: 1, clearedRows: 2), false);
      });
    });

    group('PowerUpManager Tests', () {
      test('道具数量管理', () async {
        // 初始应该为 0
        var counts = await powerUpManager.getPowerUpCounts();
        expect(counts[PowerUpType.bomb], 0);
        expect(counts[PowerUpType.refresh], 0);
        expect(counts[PowerUpType.undo], 0);
        
        // 添加道具
        await powerUpManager.addPowerUp(PowerUpType.bomb);
        counts = await powerUpManager.getPowerUpCounts();
        expect(counts[PowerUpType.bomb], 1);
        
        // 再次添加
        await powerUpManager.addPowerUp(PowerUpType.bomb);
        counts = await powerUpManager.getPowerUpCounts();
        expect(counts[PowerUpType.bomb], 2);
        
        // 添加其他道具
        await powerUpManager.addPowerUp(PowerUpType.refresh);
        counts = await powerUpManager.getPowerUpCounts();
        expect(counts[PowerUpType.refresh], 1);
      });

      test('使用道具', () async {
        // 添加道具
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 2);
        
        // 使用一次
        var success = await powerUpManager.usePowerUp(PowerUpType.bomb);
        expect(success, true);
        
        var counts = await powerUpManager.getPowerUpCounts();
        expect(counts[PowerUpType.bomb], 1);
        
        // 再次使用
        success = await powerUpManager.usePowerUp(PowerUpType.bomb);
        expect(success, true);
        
        counts = await powerUpManager.getPowerUpCounts();
        expect(counts[PowerUpType.bomb], 0);
        
        // 尝试使用没有的道具
        success = await powerUpManager.usePowerUp(PowerUpType.bomb);
        expect(success, false);
      });

      test('道具奖励', () async {
        // 连击 5 次，应该奖励
        await powerUpManager.rewardPowerUpIfNeeded(combo: 5);
        
        var counts = await powerUpManager.getPowerUpCounts();
        final totalPowerUps = counts.values.reduce((a, b) => a + b);
        expect(totalPowerUps, 1);
      });

      test('初始化新游戏', () async {
        await powerUpManager.initializeNewGame();
        
        var counts = await powerUpManager.getPowerUpCounts();
        final totalPowerUps = counts.values.reduce((a, b) => a + b);
        expect(totalPowerUps, 1);
      });
    });
  });
}
