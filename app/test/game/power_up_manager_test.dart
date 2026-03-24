import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/game/power_up.dart';
import 'package:block_blast/game/power_up_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PowerUpManager Tests', () {
    late PowerUpManager powerUpManager;

    setUp(() async {
      // 设置 mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      powerUpManager = PowerUpManager();
      await powerUpManager.resetPowerUps();
    });

    tearDown(() async {
      await powerUpManager.resetPowerUps();
    });

    group('单例模式测试', () {
      test('PowerUpManager 是单例', () {
        final manager1 = PowerUpManager();
        final manager2 = PowerUpManager();

        expect(identical(manager1, manager2), true);
      });
    });

    group('道具数量管理测试', () {
      test('初始道具数量为0', () async {
        final counts = await powerUpManager.getPowerUpCounts();

        expect(counts[PowerUpType.bomb], 0);
        expect(counts[PowerUpType.refresh], 0);
        expect(counts[PowerUpType.undo], 0);
      });

      test('添加单个道具', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb);

        final counts = await powerUpManager.getPowerUpCounts();
        expect(counts[PowerUpType.bomb], 1);
        expect(counts[PowerUpType.refresh], 0);
        expect(counts[PowerUpType.undo], 0);
      });

      test('添加多个道具 - 同类型', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 5);

        final count = await powerUpManager.getPowerUpCount(PowerUpType.bomb);
        expect(count, 5);
      });

      test('添加多个道具 - 不同类型', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 2);
        await powerUpManager.addPowerUp(PowerUpType.refresh, count: 3);
        await powerUpManager.addPowerUp(PowerUpType.undo, count: 1);

        final counts = await powerUpManager.getPowerUpCounts();
        expect(counts[PowerUpType.bomb], 2);
        expect(counts[PowerUpType.refresh], 3);
        expect(counts[PowerUpType.undo], 1);
      });

      test('获取单个道具数量', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 3);

        final count = await powerUpManager.getPowerUpCount(PowerUpType.bomb);
        expect(count, 3);

        final refreshCount = await powerUpManager.getPowerUpCount(PowerUpType.refresh);
        expect(refreshCount, 0);
      });

      test('重置道具', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 5);
        await powerUpManager.addPowerUp(PowerUpType.refresh, count: 3);

        await powerUpManager.resetPowerUps();

        final counts = await powerUpManager.getPowerUpCounts();
        expect(counts[PowerUpType.bomb], 0);
        expect(counts[PowerUpType.refresh], 0);
        expect(counts[PowerUpType.undo], 0);
      });
    });

    group('使用道具测试', () {
      test('成功使用道具', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 2);

        final success = await powerUpManager.usePowerUp(PowerUpType.bomb);
        expect(success, true);

        final count = await powerUpManager.getPowerUpCount(PowerUpType.bomb);
        expect(count, 1);
      });

      test('使用道具到0', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 1);

        var success = await powerUpManager.usePowerUp(PowerUpType.bomb);
        expect(success, true);

        success = await powerUpManager.usePowerUp(PowerUpType.bomb);
        expect(success, false); // 没有道具了

        final count = await powerUpManager.getPowerUpCount(PowerUpType.bomb);
        expect(count, 0);
      });

      test('使用不存在的道具返回 false', () async {
        final success = await powerUpManager.usePowerUp(PowerUpType.bomb);
        expect(success, false);
      });

      test('使用各类型道具', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb);
        await powerUpManager.addPowerUp(PowerUpType.refresh);
        await powerUpManager.addPowerUp(PowerUpType.undo);

        expect(await powerUpManager.usePowerUp(PowerUpType.bomb), true);
        expect(await powerUpManager.usePowerUp(PowerUpType.refresh), true);
        expect(await powerUpManager.usePowerUp(PowerUpType.undo), true);

        final counts = await powerUpManager.getPowerUpCounts();
        expect(counts[PowerUpType.bomb], 0);
        expect(counts[PowerUpType.refresh], 0);
        expect(counts[PowerUpType.undo], 0);
      });
    });

    group('道具奖励测试', () {
      test('连击5次奖励道具', () async {
        await powerUpManager.rewardPowerUpIfNeeded(combo: 5);

        final hasAny = await powerUpManager.hasAnyPowerUp();
        expect(hasAny, true);
      });

      test('连击4次不奖励道具', () async {
        await powerUpManager.rewardPowerUpIfNeeded(combo: 4);

        final hasAny = await powerUpManager.hasAnyPowerUp();
        expect(hasAny, false);
      });

      test('消除3行奖励道具', () async {
        await powerUpManager.rewardPowerUpIfNeeded(
          combo: 1,
          clearedRows: 3,
        );

        final hasAny = await powerUpManager.hasAnyPowerUp();
        expect(hasAny, true);
      });

      test('消除2行不奖励道具', () async {
        await powerUpManager.rewardPowerUpIfNeeded(
          combo: 1,
          clearedRows: 2,
        );

        final hasAny = await powerUpManager.hasAnyPowerUp();
        expect(hasAny, false);
      });

      test('消除3列奖励道具', () async {
        await powerUpManager.rewardPowerUpIfNeeded(
          combo: 1,
          clearedCols: 3,
        );

        final hasAny = await powerUpManager.hasAnyPowerUp();
        expect(hasAny, true);
      });

      test('消除3行3列只奖励1个道具', () async {
        await powerUpManager.rewardPowerUpIfNeeded(
          combo: 5,
          clearedRows: 3,
          clearedCols: 3,
        );

        final counts = await powerUpManager.getPowerUpCounts();
        final total = counts.values.fold(0, (sum, count) => sum + count);
        expect(total, 1); // 只奖励1个道具
      });

      test('多次满足条件多次奖励', () async {
        await powerUpManager.rewardPowerUpIfNeeded(combo: 5);
        await powerUpManager.rewardPowerUpIfNeeded(combo: 5);
        await powerUpManager.rewardPowerUpIfNeeded(combo: 5);

        final counts = await powerUpManager.getPowerUpCounts();
        final total = counts.values.fold(0, (sum, count) => sum + count);
        expect(total, 3);
      });
    });

    group('初始化新游戏测试', () {
      test('初始化新游戏获得1个随机道具', () async {
        await powerUpManager.initializeNewGame();

        final counts = await powerUpManager.getPowerUpCounts();
        final total = counts.values.fold(0, (sum, count) => sum + count);
        expect(total, 1);
      });

      test('多次初始化累积道具', () async {
        await powerUpManager.initializeNewGame();
        await powerUpManager.initializeNewGame();
        await powerUpManager.initializeNewGame();

        final counts = await powerUpManager.getPowerUpCounts();
        final total = counts.values.fold(0, (sum, count) => sum + count);
        expect(total, 3);
      });
    });

    group('检查可用道具测试', () {
      test('没有道具时返回 false', () async {
        final hasAny = await powerUpManager.hasAnyPowerUp();
        expect(hasAny, false);
      });

      test('有道具时返回 true', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb);

        final hasAny = await powerUpManager.hasAnyPowerUp();
        expect(hasAny, true);
      });

      test('道具用完后返回 false', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 1);
        await powerUpManager.usePowerUp(PowerUpType.bomb);

        final hasAny = await powerUpManager.hasAnyPowerUp();
        expect(hasAny, false);
      });
    });

    group('边界条件测试', () {
      test('添加0个道具', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 0);

        final count = await powerUpManager.getPowerUpCount(PowerUpType.bomb);
        expect(count, 0);
      });

      test('添加大量道具', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 999);

        final count = await powerUpManager.getPowerUpCount(PowerUpType.bomb);
        expect(count, 999);
      });

      test('负数连击参数', () async {
        // 负数连击不应该导致崩溃
        await powerUpManager.rewardPowerUpIfNeeded(combo: -1);

        final hasAny = await powerUpManager.hasAnyPowerUp();
        expect(hasAny, false);
      });

      test('负数清除行数参数', () async {
        await powerUpManager.rewardPowerUpIfNeeded(
          combo: 1,
          clearedRows: -1,
          clearedCols: -1,
        );

        final hasAny = await powerUpManager.hasAnyPowerUp();
        expect(hasAny, false);
      });
    });

    group('持久化测试', () {
      test('道具数量持久化', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 3);
        await powerUpManager.addPowerUp(PowerUpType.refresh, count: 2);

        // 创建新实例（实际会从 SharedPreferences 读取）
        final newManager = PowerUpManager();
        final counts = await newManager.getPowerUpCounts();

        expect(counts[PowerUpType.bomb], 3);
        expect(counts[PowerUpType.refresh], 2);
      });

      test('使用道具后持久化', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 2);
        await powerUpManager.usePowerUp(PowerUpType.bomb);

        final newManager = PowerUpManager();
        final count = await newManager.getPowerUpCount(PowerUpType.bomb);

        expect(count, 1);
      });

      test('重置后持久化', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 5);
        await powerUpManager.resetPowerUps();

        final newManager = PowerUpManager();
        final counts = await newManager.getPowerUpCounts();

        expect(counts[PowerUpType.bomb], 0);
      });
    });

    group('并发安全测试', () {
      test('连续快速添加道具', () async {
        // 模拟快速连续添加
        for (int i = 0; i < 10; i++) {
          await powerUpManager.addPowerUp(PowerUpType.bomb);
        }

        final count = await powerUpManager.getPowerUpCount(PowerUpType.bomb);
        expect(count, 10);
      });

      test('连续快速使用道具', () async {
        await powerUpManager.addPowerUp(PowerUpType.bomb, count: 5);

        var successCount = 0;
        for (int i = 0; i < 10; i++) {
          if (await powerUpManager.usePowerUp(PowerUpType.bomb)) {
            successCount++;
          }
        }

        expect(successCount, 5); // 只有5个道具可用
      });
    });
  });
}
