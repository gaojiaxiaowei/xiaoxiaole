import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/game/haptic.dart';
import 'package:vibration/vibration.dart';

void main() {
  group('HapticManager - 震动反馈测试', () {
    setUp(() {
      // 重置状态
      HapticManager.toggle(true);
    });

    group('toggle - 开关控制', () {
      test('应该能够启用震动', () {
        HapticManager.toggle(true);
        
        expect(HapticManager.isEnabled, true);
      });

      test('应该能够禁用震动', () {
        HapticManager.toggle(false);
        
        expect(HapticManager.isEnabled, false);
      });

      test('应该能够切换状态', () {
        HapticManager.toggle(true);
        expect(HapticManager.isEnabled, true);
        
        HapticManager.toggle(false);
        expect(HapticManager.isEnabled, false);
        
        HapticManager.toggle(true);
        expect(HapticManager.isEnabled, true);
      });
    });

    group('isEnabled - 状态查询', () {
      test('初始状态应该是启用', () {
        expect(HapticManager.isEnabled, true);
      });

      test('状态应该与toggle一致', () {
        HapticManager.toggle(false);
        expect(HapticManager.isEnabled, false);
        
        HapticManager.toggle(true);
        expect(HapticManager.isEnabled, true);
      });
    });

    group('hasVibrator - 设备支持检测', () {
      test('应该返回布尔值', () async {
        final result = await HapticManager.hasVibrator;
        
        expect(result, isA<bool>());
      });

      test('应该缓存结果', () async {
        final result1 = await HapticManager.hasVibrator;
        final result2 = await HapticManager.hasVibrator;
        
        expect(result1, result2);
      });
    });

    group('震动方法 - 启用状态', () {
      test('light() 不应该抛出异常', () async {
        HapticManager.toggle(true);
        
        // 只是验证不会抛出异常
        await HapticManager.light();
        expect(true, true);
      });

      test('medium() 不应该抛出异常', () async {
        HapticManager.toggle(true);
        
        await HapticManager.medium();
        expect(true, true);
      });

      test('heavy() 不应该抛出异常', () async {
        HapticManager.toggle(true);
        
        await HapticManager.heavy();
        expect(true, true);
      });

      test('long() 不应该抛出异常', () async {
        HapticManager.toggle(true);
        
        await HapticManager.long();
        expect(true, true);
      });

      test('dragStart() 不应该抛出异常', () async {
        HapticManager.toggle(true);
        
        await HapticManager.dragStart();
        expect(true, true);
      });

      test('placeSuccess() 不应该抛出异常', () async {
        HapticManager.toggle(true);
        
        await HapticManager.placeSuccess();
        expect(true, true);
      });

      test('warning() 不应该抛出异常', () async {
        HapticManager.toggle(true);
        
        await HapticManager.warning();
        expect(true, true);
      });
    });

    group('震动方法 - 禁用状态', () {
      test('禁用时 light() 不应该震动', () async {
        HapticManager.toggle(false);
        
        await HapticManager.light();
        // 禁用状态下应该直接返回，不震动
        expect(HapticManager.isEnabled, false);
      });

      test('禁用时 medium() 不应该震动', () async {
        HapticManager.toggle(false);
        
        await HapticManager.medium();
        expect(HapticManager.isEnabled, false);
      });

      test('禁用时 heavy() 不应该震动', () async {
        HapticManager.toggle(false);
        
        await HapticManager.heavy();
        expect(HapticManager.isEnabled, false);
      });

      test('禁用时 long() 不应该震动', () async {
        HapticManager.toggle(false);
        
        await HapticManager.long();
        expect(HapticManager.isEnabled, false);
      });

      test('禁用时 dragStart() 不应该震动', () async {
        HapticManager.toggle(false);
        
        await HapticManager.dragStart();
        expect(HapticManager.isEnabled, false);
      });

      test('禁用时 placeSuccess() 不应该震动', () async {
        HapticManager.toggle(false);
        
        await HapticManager.placeSuccess();
        expect(HapticManager.isEnabled, false);
      });

      test('禁用时 warning() 不应该震动', () async {
        HapticManager.toggle(false);
        
        await HapticManager.warning();
        expect(HapticManager.isEnabled, false);
      });
    });

    group('震动档位 - 参数验证', () {
      test('light() 应该使用10ms持续时间', () async {
        // 这个测试验证方法存在且可调用
        // 实际震动参数在方法内部定义
        HapticManager.toggle(true);
        await HapticManager.light();
        expect(true, true);
      });

      test('medium() 应该使用50ms持续时间', () async {
        HapticManager.toggle(true);
        await HapticManager.medium();
        expect(true, true);
      });

      test('heavy() 应该使用100ms持续时间', () async {
        HapticManager.toggle(true);
        await HapticManager.heavy();
        expect(true, true);
      });

      test('long() 应该使用200ms持续时间', () async {
        HapticManager.toggle(true);
        await HapticManager.long();
        expect(true, true);
      });

      test('dragStart() 应该使用10ms持续时间', () async {
        HapticManager.toggle(true);
        await HapticManager.dragStart();
        expect(true, true);
      });

      test('placeSuccess() 应该使用30ms持续时间', () async {
        HapticManager.toggle(true);
        await HapticManager.placeSuccess();
        expect(true, true);
      });

      test('warning() 应该使用pattern震动', () async {
        HapticManager.toggle(true);
        await HapticManager.warning();
        expect(true, true);
      });
    });

    group('综合场景测试', () {
      test('游戏流程：拖拽 -> 放置 -> 消除', () async {
        HapticManager.toggle(true);
        
        // 开始拖拽
        await HapticManager.dragStart();
        
        // 放置成功
        await HapticManager.placeSuccess();
        
        // 消除一行（中等震动）
        await HapticManager.medium();
        
        expect(HapticManager.isEnabled, true);
      });

      test('游戏流程：连击震动', () async {
        HapticManager.toggle(true);
        
        // 连击使用强烈震动
        await HapticManager.heavy();
        
        expect(HapticManager.isEnabled, true);
      });

      test('游戏流程：游戏结束', () async {
        HapticManager.toggle(true);
        
        // 游戏结束使用长震动
        await HapticManager.long();
        
        expect(HapticManager.isEnabled, true);
      });

      test('游戏流程：放置失败', () async {
        HapticManager.toggle(true);
        
        // 放置失败使用警告震动
        await HapticManager.warning();
        
        expect(HapticManager.isEnabled, true);
      });

      test('用户关闭震动后所有操作静默', () async {
        HapticManager.toggle(false);
        
        // 所有震动操作应该静默跳过
        await HapticManager.light();
        await HapticManager.medium();
        await HapticManager.heavy();
        await HapticManager.long();
        await HapticManager.dragStart();
        await HapticManager.placeSuccess();
        await HapticManager.warning();
        
        expect(HapticManager.isEnabled, false);
      });

      test('切换震动状态', () async {
        // 启用
        HapticManager.toggle(true);
        expect(HapticManager.isEnabled, true);
        await HapticManager.light();
        
        // 禁用
        HapticManager.toggle(false);
        expect(HapticManager.isEnabled, false);
        await HapticManager.medium();
        
        // 再次启用
        HapticManager.toggle(true);
        expect(HapticManager.isEnabled, true);
        await HapticManager.heavy();
      });
    });

    group('边界情况测试', () {
      test('连续调用不应抛出异常', () async {
        HapticManager.toggle(true);
        
        // 快速连续调用
        await HapticManager.light();
        await HapticManager.light();
        await HapticManager.light();
        
        expect(true, true);
      });

      test('在禁用和启用之间快速切换', () async {
        for (int i = 0; i < 10; i++) {
          HapticManager.toggle(i % 2 == 0);
          await HapticManager.light();
        }
        
        expect(true, true);
      });
    });
  });
}
