// lib/providers/stats/stats_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/stats_manager.dart';

/// StatsManager Provider
/// 
/// 提供 StatsManager 实例，替代单例模式
final statsManagerProvider = Provider<StatsManager>((ref) {
  return StatsManager();
});
