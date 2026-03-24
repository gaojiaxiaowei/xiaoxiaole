// lib/providers/daily_challenge/daily_challenge_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/daily_challenge.dart';

/// DailyChallengeManager Provider
/// 
/// 提供 DailyChallengeManager 实例，替代单例模式
final dailyChallengeManagerProvider = Provider<DailyChallengeManager>((ref) {
  final manager = DailyChallengeManager();
  // 设置全局实例（用于兼容静态访问层）
  DailyChallengeManager.setGlobalInstance(manager);
  return manager;
});

/// 今日挑战 Provider（派生）
final todayChallengeProvider = FutureProvider<DailyChallenge>((ref) async {
  final manager = ref.watch(dailyChallengeManagerProvider);
  return await manager.getTodayChallenge();
});
