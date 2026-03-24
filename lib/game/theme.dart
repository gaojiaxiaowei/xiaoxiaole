import 'package:flutter/material.dart';
import 'themes/themes.dart';

/// Block Blast 游戏视觉设计规范
/// 
/// 统一游戏的颜色、字体、间距和圆角规范
/// 确保整个游戏的视觉一致性和品牌识别度
/// 
/// 此文件作为主题系统的兼容层，通过 ThemeManager 获取当前主题

/// 游戏颜色系统
/// 
/// 包含背景色、文字色、强调色和连击特效色
/// 注意：此类现在从当前主题获取颜色
class GameColors {
  GameColors._();

  // ========== 背景色 ==========
  /// 主背景色 - 从当前主题获取
  static Color get background => ThemeManager.instance.currentTheme.background;
  
  /// 卡片/容器背景色 - 从当前主题获取
  static Color get cardBackground => ThemeManager.instance.currentTheme.cardBackground;

  // ========== 文字色 ==========
  /// 主要文字色 - 从当前主题获取
  static Color get primaryText => ThemeManager.instance.currentTheme.primaryText;
  
  /// 次要文字色 - 从当前主题获取
  static Color get secondaryText => ThemeManager.instance.currentTheme.secondaryText;

  // ========== 强调色 ==========
  /// 主题强调色 - 从当前主题获取
  static Color get accent => ThemeManager.instance.currentTheme.accent;
  
  /// 错误/危险色 - 从当前主题获取
  static Color get error => ThemeManager.instance.currentTheme.error;

  /// 警告色 - 从当前主题获取
  static Color get warning => ThemeManager.instance.currentTheme.warning;

  // ========== 连击颜色 ==========
  /// 2连击 - 从当前主题获取
  static Color get combo2 => ThemeManager.instance.currentTheme.combo2;
  
  /// 3连击 - 从当前主题获取
  static Color get combo3 => ThemeManager.instance.currentTheme.combo3;
  
  /// 4连击 - 从当前主题获取
  static Color get combo4 => ThemeManager.instance.currentTheme.combo4;
  
  /// 5连击及以上 - 从当前主题获取
  static Color get combo5 => ThemeManager.instance.currentTheme.combo5;

  // ========== 辅助方法 ==========
  /// 根据连击数获取对应颜色
  static Color getComboColor(int combo) {
    return ThemeManager.instance.currentTheme.getComboColor(combo);
  }
}

/// 游戏文字样式
/// 
/// 统一游戏的字体大小、粗细和颜色
class GameTextStyles {
  GameTextStyles._();

  // ========== 标题样式 ==========
  /// 大标题 - 24px 粗体
  static TextStyle get title => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: GameColors.primaryText,
  );

  // ========== 正文样式 ==========
  /// 正文 - 16px 常规
  static TextStyle get body => TextStyle(
    fontSize: 16,
    color: GameColors.primaryText,
  );

  // ========== 辅助文字样式 ==========
  /// 说明文字 - 12px 浅色
  static TextStyle get caption => TextStyle(
    fontSize: 12,
    color: GameColors.secondaryText,
  );

  // ========== 可复制的样式变体 ==========
  /// 标题样式 - 可自定义颜色
  static TextStyle titleWithColor(Color color) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: color,
  );

  /// 正文样式 - 可自定义颜色
  static TextStyle bodyWithColor(Color color) => TextStyle(
    fontSize: 16,
    color: color,
  );
}

/// 游戏间距规范
/// 
/// 统一游戏内各元素之间的间距
class GameSpacing {
  GameSpacing._();

  /// 超小间距 - 4px
  static const double xs = 4.0;
  
  /// 小间距 - 8px
  static const double sm = 8.0;
  
  /// 中等间距 - 16px（默认）
  static const double md = 16.0;
  
  /// 大间距 - 24px
  static const double lg = 24.0;
  
  /// 超大间距 - 32px
  static const double xl = 32.0;

  // ========== EdgeInsets 便捷方法 ==========
  /// 所有方向相同间距
  static EdgeInsets all(double spacing) => EdgeInsets.all(spacing);
  
  /// 水平间距
  static EdgeInsets horizontal(double spacing) => 
      EdgeInsets.symmetric(horizontal: spacing);
  
  /// 垂直间距
  static EdgeInsets vertical(double spacing) => 
      EdgeInsets.symmetric(vertical: spacing);
  
  /// 常用间距快捷方式
  static EdgeInsets get xsAll => EdgeInsets.all(xs);
  static EdgeInsets get smAll => EdgeInsets.all(sm);
  static EdgeInsets get mdAll => EdgeInsets.all(md);
  static EdgeInsets get lgAll => EdgeInsets.all(lg);
  static EdgeInsets get xlAll => EdgeInsets.all(xl);
}

/// 游戏圆角规范
/// 
/// 统一游戏内各元素的圆角大小
class GameRadius {
  GameRadius._();

  /// 小圆角 - 4px（按钮、小卡片）
  static const double sm = 4.0;
  
  /// 中等圆角 - 8px（卡片、容器）
  static const double md = 8.0;
  
  /// 大圆角 - 12px（对话框、大卡片）
  static const double lg = 12.0;

  // ========== BorderRadius 便捷方法 ==========
  /// 所有角相同圆角
  static BorderRadius all(double radius) => BorderRadius.circular(radius);
  
  /// 常用圆角快捷方式
  static BorderRadius get smAll => BorderRadius.circular(sm);
  static BorderRadius get mdAll => BorderRadius.circular(md);
  static BorderRadius get lgAll => BorderRadius.circular(lg);

  // ========== Radius 对象 ==========
  /// 获取 Radius 对象（用于 BoxDecoration 等）
  static Radius get smRadius => Radius.circular(sm);
  static Radius get mdRadius => Radius.circular(md);
  static Radius get lgRadius => Radius.circular(lg);
}

/// 游戏主题数据
/// 
/// 可以在 MaterialApp 中使用的主题配置
/// 注意：此类现在从当前主题获取颜色
class GameTheme {
  GameTheme._();

  // ========== 颜色别名（向后兼容） ==========
  /// 主背景色
  static Color get background => ThemeManager.instance.currentTheme.background;
  
  /// 卡片/容器背景色
  static Color get cardBackground => ThemeManager.instance.currentTheme.cardBackground;
  
  /// 主要文字色
  static Color get primaryText => ThemeManager.instance.currentTheme.primaryText;
  
  /// 次要文字色
  static Color get secondaryText => ThemeManager.instance.currentTheme.secondaryText;
  
  /// 主题强调色
  static Color get accent => ThemeManager.instance.currentTheme.accent;
  
  /// 错误/危险色
  static Color get error => ThemeManager.instance.currentTheme.error;

  /// 警告色
  static Color get warning => ThemeManager.instance.currentTheme.warning;
  
  /// 2连击颜色
  static Color get combo2 => ThemeManager.instance.currentTheme.combo2;
  
  /// 3连击颜色
  static Color get combo3 => ThemeManager.instance.currentTheme.combo3;
  
  /// 4连击颜色
  static Color get combo4 => ThemeManager.instance.currentTheme.combo4;
  
  /// 5连击及以上颜色
  static Color get combo5 => ThemeManager.instance.currentTheme.combo5;
  
  /// 对话框背景色
  static Color get dialogBackground => ThemeManager.instance.currentTheme.dialogBackground;
  
  /// 对话框项背景色
  static Color get dialogItemBackground => ThemeManager.instance.currentTheme.dialogItemBackground;
  
  // ========== 网格颜色 ==========
  /// 空格子颜色
  static Color get emptyCell => ThemeManager.instance.currentTheme.emptyCell;
  
  /// 已填充格子颜色
  static Color get filledCell => ThemeManager.instance.currentTheme.filledCell;
  
  /// 网格边框颜色
  static Color get gridBorder => ThemeManager.instance.currentTheme.gridBorder;
  
  /// 网格背景色
  static Color get gridBackground => ThemeManager.instance.currentTheme.gridBackground;
  
  /// 网格阴影颜色
  static Color get gridShadow => ThemeManager.instance.currentTheme.gridShadow;

  /// 获取亮色主题（暂未实现）
  static ThemeData get light => ThemeData.light();

  /// 获取暗色主题
  static ThemeData get dark => ThemeManager.instance.currentTheme.toThemeData();
}
