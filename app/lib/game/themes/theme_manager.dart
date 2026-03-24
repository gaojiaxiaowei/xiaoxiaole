import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';
import 'classic_dark_theme.dart';
import 'ocean_blue_theme.dart';
import 'sunset_orange_theme.dart';

/// 主题管理器
/// 
/// 负责主题切换和持久化存储
class ThemeManager extends ChangeNotifier {
  // 全局实例（用于兼容静态访问层）
  static ThemeManager? _globalInstance;
  
  // 构造函数（移除单例模式）
  ThemeManager();
  
  /// 设置全局实例（由 Provider 初始化时调用）
  static void setGlobalInstance(ThemeManager instance) {
    _globalInstance = instance;
  }
  
  /// 获取全局实例（用于兼容静态访问层）
  static ThemeManager get instance {
    if (_globalInstance == null) {
      throw StateError(
        'ThemeManager not initialized. '
        'Make sure the app is wrapped in ProviderScope and the provider is accessed at least once.'
      );
    }
    return _globalInstance!;
  }

  /// 所有可用主题
  static final List<AppTheme> availableThemes = [
    ClassicDarkTheme(),
    OceanBlueTheme(),
    SunsetOrangeTheme(),
  ];

  /// 当前主题
  AppTheme _currentTheme = ClassicDarkTheme();
  AppTheme get currentTheme => _currentTheme;

  /// SharedPreferences 键名
  static const String _themeKey = 'block_blast_theme_id';

  /// 初始化主题（从存储加载）
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final themeId = prefs.getString(_themeKey);
    
    if (themeId != null) {
      final theme = availableThemes.firstWhere(
        (t) => t.id == themeId,
        orElse: () => ClassicDarkTheme(),
      );
      _currentTheme = theme;
    }
    
    notifyListeners();
  }

  /// 切换主题
  Future<void> setTheme(String themeId) async {
    final theme = availableThemes.firstWhere(
      (t) => t.id == themeId,
      orElse: () => ClassicDarkTheme(),
    );
    
    _currentTheme = theme;
    
    // 保存到 SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeId);
    
    notifyListeners();
  }

  /// 获取主题索引
  int get currentThemeIndex {
    return availableThemes.indexWhere((t) => t.id == _currentTheme.id);
  }

  /// 通过索引设置主题
  Future<void> setThemeByIndex(int index) async {
    if (index >= 0 && index < availableThemes.length) {
      await setTheme(availableThemes[index].id);
    }
  }
}
