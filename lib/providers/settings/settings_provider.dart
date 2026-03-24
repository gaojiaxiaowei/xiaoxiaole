// lib/providers/settings/settings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 网格线显示设置
final showGridLinesProvider = StateProvider<bool>((ref) => true);

/// 动画启用设置
final animationEnabledProvider = StateProvider<bool>((ref) => true);

/// 难度设置（全局唯一）
final difficultyProvider = StateProvider<String>((ref) => 'normal');

/// 设置加载状态
final settingsLoadedProvider = FutureProvider<void>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  
  // 加载难度
  final difficultyIndex = prefs.getInt('block_blast_difficulty') ?? 1;
  ref.read(difficultyProvider.notifier).state = ['easy', 'normal', 'hard'][difficultyIndex];
  
  // 加载网格线设置
  ref.read(showGridLinesProvider.notifier).state = 
      prefs.getBool('block_blast_show_grid_lines') ?? true;
  
  // 加载动画设置
  ref.read(animationEnabledProvider.notifier).state = 
      prefs.getBool('block_blast_animation_enabled') ?? true;
});
