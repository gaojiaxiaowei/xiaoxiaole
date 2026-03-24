import 'package:vibration/vibration.dart';

/// 震动反馈管理器
/// 
/// 提供游戏中的触觉反馈，增强游戏手感
/// Web端自动优雅降级（静默跳过）
class HapticManager {
  static bool _enabled = true;
  static bool? _hasVibrator;

  /// 检查设备是否支持震动
  static Future<bool> get hasVibrator async {
    if (_hasVibrator != null) return _hasVibrator!;
    
    try {
      _hasVibrator = await Vibration.hasVibrator() ?? false;
      return _hasVibrator!;
    } catch (e) {
      // Web端或不支持震动API的设备
      _hasVibrator = false;
      return false;
    }
  }

  /// 切换震动开关
  static void toggle(bool enabled) {
    _enabled = enabled;
  }

  /// 获取当前震动开关状态
  static bool get isEnabled => _enabled;

  /// 轻微震动（10ms）
  /// 用于：放置方块
  static Future<void> light() async {
    if (!_enabled) return;
    if (await hasVibrator) {
      Vibration.vibrate(duration: 10);
    }
  }

  /// 中等震动（50ms）
  /// 用于：消除行/列
  static Future<void> medium() async {
    if (!_enabled) return;
    if (await hasVibrator) {
      Vibration.vibrate(duration: 50);
    }
  }

  /// 强烈震动（100ms）
  /// 用于：连击
  static Future<void> heavy() async {
    if (!_enabled) return;
    if (await hasVibrator) {
      Vibration.vibrate(duration: 100);
    }
  }

  /// 长震动（200ms）
  /// 用于：游戏结束
  static Future<void> long() async {
    if (!_enabled) return;
    if (await hasVibrator) {
      Vibration.vibrate(duration: 200);
    }
  }

  /// 拖拽开始震动（10ms）
  /// 用于：开始拖拽方块
  static Future<void> dragStart() async {
    if (!_enabled) return;
    if (await hasVibrator) {
      Vibration.vibrate(duration: 10);
    }
  }

  /// 放置成功震动（30ms）
  /// 用于：方块成功放置
  static Future<void> placeSuccess() async {
    if (!_enabled) return;
    if (await hasVibrator) {
      Vibration.vibrate(duration: 30);
    }
  }

  /// 警告震动（短促2次）
  /// 用于：放置失败/无效位置
  static Future<void> warning() async {
    if (!_enabled) return;
    if (await hasVibrator) {
      Vibration.vibrate(pattern: [0, 30, 50, 30]);
    }
  }
}
