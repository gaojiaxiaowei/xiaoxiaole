import 'package:flutter/material.dart';
import 'app_theme.dart';

/// 经典暗色主题（默认）
/// 
/// 深黑色背景配绿色强调色
class ClassicDarkTheme extends AppTheme {
  @override
  String get id => 'classic_dark';

  @override
  String get displayName => '经典暗色';

  @override
  String get description => '深黑色背景配绿色强调色';

  // ========== 背景色 ==========
  @override
  Color get background => const Color(0xFF121212);

  @override
  Color get cardBackground => const Color(0xFF1E1E1E);

  @override
  Color get dialogBackground => const Color(0xFF1E1E1E);

  @override
  Color get dialogItemBackground => const Color(0xFF2A2A2A);

  // ========== 文字色 ==========
  @override
  Color get primaryText => Colors.white;

  @override
  Color get secondaryText => const Color(0xFFB0B0B0);

  // ========== 强调色 ==========
  @override
  Color get accent => const Color(0xFF4CAF50);

  @override
  Color get error => const Color(0xFFE53935);

  @override
  Color get warning => const Color(0xFFFF9800);

  // ========== 连击颜色 ==========
  @override
  Color get combo2 => const Color(0xFFFFEB3B);

  @override
  Color get combo3 => const Color(0xFFFF9800);

  @override
  Color get combo4 => const Color(0xFFF44336);

  @override
  Color get combo5 => const Color(0xFF9C27B0);

  // ========== 网格颜色 ==========
  @override
  Color get emptyCell => const Color(0xFF1A1A1A);

  @override
  Color get filledCell => const Color(0xFF66BB6A);

  @override
  Color get gridBorder => const Color(0xFF2D2D2D);

  @override
  Color get gridBackground => const Color(0xFF1E1E1E);

  @override
  Color get gridShadow => const Color(0xFF000000);

  // ========== 方块颜色 ==========
  @override
  Map<String, Color> get blockColors => {
    // 单格 - 鲜红色
    'single': const Color(0xFFFF5252),
    // 横条 2格 - 橙色
    'h2': const Color(0xFFFF9800),
    // 横条 3格 - 黄色
    'h3': const Color(0xFFFFEB3B),
    // 横条 4格 - 绿色
    'h4': const Color(0xFF4CAF50),
    // 竖条 2格 - 橙色
    'v2': const Color(0xFFFF9800),
    // 竖条 3格 - 黄色
    'v3': const Color(0xFFFFEB3B),
    // 竖条 4格 - 绿色
    'v4': const Color(0xFF4CAF50),
    // 方块 2x2 - 青色
    'square': const Color(0xFF00BCD4),
    // L形 - 蓝色
    'l': const Color(0xFF2196F3),
    // 反L形 - 蓝色
    'rl': const Color(0xFF2196F3),
    // T形 - 紫色
    't': const Color(0xFF9C27B0),
    // Z形 - 粉色
    'z': const Color(0xFFE91E63),
    // S形 - 粉色
    's': const Color(0xFFE91E63),
    // 十字形 - 深橙
    'cross': const Color(0xFFFF5722),
    // 横条 5格 - 靛蓝
    'h5': const Color(0xFF3F51B5),
    // 竖条 5格 - 靛蓝
    'v5': const Color(0xFF3F51B5),
    // 3x3大方块 - 深绿
    'bigSquare': const Color(0xFF009688),
    // 阶梯形 - 深紫
    'stairs': const Color(0xFF673AB7),
    // U形 - 深红
    'u': const Color(0xFFC62828),
    // 大T形 - 深蓝
    'bigT': const Color(0xFF1565C0),
  };

  // ========== 游戏模式按钮颜色 ==========
  @override
  Color get classicModeColor => const Color(0xFF4CAF50);

  @override
  Color get timedModeColor => const Color(0xFFFF9800);

  @override
  Color get leaderboardColor => const Color(0xFF9C27B0);

  // ========== 排名颜色 ==========
  @override
  Color get goldColor => const Color(0xFFFFD700);

  @override
  Color get silverColor => const Color(0xFFC0C0C0);

  @override
  Color get bronzeColor => const Color(0xFFCD7F32);
}
