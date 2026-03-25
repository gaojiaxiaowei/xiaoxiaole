// lib/providers/power_up/power_up_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/power_up_manager.dart';

/// PowerUpManager Provider
///
/// 提供 PowerUpManager 实例，替代单例模式
final powerUpManagerProvider = Provider<PowerUpManager>((ref) {
  final manager = PowerUpManager();  // 创建新实例，而不是获取 instance
  // 设置全局实例（用于兼容静态访问层）
  PowerUpManager.setGlobalInstance(manager);
  return manager;
});
