// lib/providers/api/api_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../api/api_service.dart';

/// ApiService Provider
/// 
/// 提供 ApiService 实例，替代单例模式
final apiServiceProvider = Provider<ApiService>((ref) {
  final service = ApiService();
  // 设置全局实例（用于兼容静态访问层）
  ApiService.setGlobalInstance(service);
  return service;
});

/// 是否已登录 Provider（派生）
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(apiServiceProvider).isLoggedIn;
});

/// 需要同步 Provider（派生）
final needsSyncProvider = Provider<bool>((ref) {
  return ref.watch(apiServiceProvider).needsSync;
});
