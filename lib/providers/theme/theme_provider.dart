// lib/providers/theme/theme_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../game/themes/theme_manager.dart';
import '../../game/themes/app_theme.dart';

/// ThemeManager Provider
/// 
/// 提供 ThemeManager 实例，替代单例模式
/// 使用 ChangeNotifierProvider 因为 ThemeManager 继承自 ChangeNotifier
final themeManagerProvider = ChangeNotifierProvider<ThemeManager>((ref) {
  final manager = ThemeManager();
  // 设置全局实例（用于兼容静态访问层）
  ThemeManager.setGlobalInstance(manager);
  return manager;
});

/// 当前主题 Provider（派生）
final currentThemeProvider = Provider<AppTheme>((ref) {
  return ref.watch(themeManagerProvider).currentTheme;
});
