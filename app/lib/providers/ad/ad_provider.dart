// lib/providers/ad/ad_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../ad/ad_manager.dart';

/// AdManager Provider
/// 
/// 提供 AdManager 实例，替代单例模式
/// 使用 ChangeNotifierProvider 因为 AdManager 继承自 ChangeNotifier
final adManagerProvider = ChangeNotifierProvider<AdManager>((ref) {
  final manager = AdManager();
  // 设置全局实例（用于兼容静态访问层）
  AdManager.setGlobalInstance(manager);
  return manager;
});

/// 广告启用状态 Provider（派生）
final adEnabledProvider = Provider<bool>((ref) {
  return ref.watch(adManagerProvider).isAdEnabled;
});

/// 模拟模式状态 Provider（派生）
final adSimulationModeProvider = Provider<bool>((ref) {
  return ref.watch(adManagerProvider).isSimulationMode;
});
