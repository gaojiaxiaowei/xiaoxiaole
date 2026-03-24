import 'package:flutter/material.dart';

/// 主题定义接口
/// 
/// 所有游戏主题必须实现此接口
abstract class AppTheme {
  /// 主题唯一标识
  String get id;
  
  /// 主题显示名称
  String get displayName;
  
  /// 主题描述
  String get description;
  
  // ========== 背景色 ==========
  /// 主背景色
  Color get background;
  
  /// 卡片/容器背景色
  Color get cardBackground;
  
  /// 对话框背景色
  Color get dialogBackground;
  
  /// 对话框项背景色
  Color get dialogItemBackground;

  // ========== 文字色 ==========
  /// 主要文字色
  Color get primaryText;
  
  /// 次要文字色
  Color get secondaryText;

  // ========== 强调色 ==========
  /// 主题强调色
  Color get accent;
  
  /// 错误/危险色
  Color get error;
  
  /// 警告色
  Color get warning;

  // ========== 连击颜色 ==========
  /// 2连击颜色
  Color get combo2;
  
  /// 3连击颜色
  Color get combo3;
  
  /// 4连击颜色
  Color get combo4;
  
  /// 5连击及以上颜色
  Color get combo5;

  // ========== 网格颜色 ==========
  /// 空格子颜色
  Color get emptyCell;
  
  /// 已填充格子颜色
  Color get filledCell;
  
  /// 网格边框颜色
  Color get gridBorder;
  
  /// 网格背景色
  Color get gridBackground;
  
  /// 网格阴影颜色
  Color get gridShadow;

  // ========== 方块颜色 ==========
  /// 获取所有方块的颜色映射
  /// key: block.id, value: Color
  Map<String, Color> get blockColors;

  // ========== 游戏模式按钮颜色 ==========
  /// 经典模式按钮颜色
  Color get classicModeColor;
  
  /// 计时模式按钮颜色
  Color get timedModeColor;
  
  /// 排行榜按钮颜色
  Color get leaderboardColor;

  // ========== 排名颜色 ==========
  /// 金牌颜色
  Color get goldColor;
  
  /// 银牌颜色
  Color get silverColor;
  
  /// 铜牌颜色
  Color get bronzeColor;

  // ========== 辅助方法 ==========
  /// 根据连击数获取对应颜色
  Color getComboColor(int combo) {
    switch (combo) {
      case 2:
        return combo2;
      case 3:
        return combo3;
      case 4:
        return combo4;
      default:
        return combo >= 5 ? combo5 : accent;
    }
  }

  /// 获取方块颜色
  Color getBlockColor(String blockId) {
    return blockColors[blockId] ?? accent;
  }

  /// 获取 Flutter ThemeData
  ThemeData toThemeData() {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: accent,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.dark(
        primary: accent,
        error: error,
        surface: cardBackground,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryText,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: primaryText,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          color: secondaryText,
        ),
      ),
    );
  }
}
