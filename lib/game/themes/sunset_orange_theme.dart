import 'package:flutter/material.dart';
import 'app_theme.dart';

/// 日落橙主题
/// 
/// 暖色背景配橙色强调色
class SunsetOrangeTheme extends AppTheme {
  @override
  String get id => 'sunset_orange';

  @override
  String get displayName => '日落橙';

  @override
  String get description => '暖色背景配橙色强调色';

  // ========== 背景色 ==========
  @override
  Color get background => const Color(0xFF1A0F0A);

  @override
  Color get cardBackground => const Color(0xFF2A1810);

  @override
  Color get dialogBackground => const Color(0xFF2A1810);

  @override
  Color get dialogItemBackground => const Color(0xFF3D2218);

  // ========== 文字色 ==========
  @override
  Color get primaryText => Colors.white;

  @override
  Color get secondaryText => const Color(0xFFD4A574);

  // ========== 强调色 ==========
  @override
  Color get accent => const Color(0xFFFF5722);

  @override
  Color get error => const Color(0xFFEF5350);

  @override
  Color get warning => const Color(0xFFFFB74D);

  // ========== 连击颜色 ==========
  @override
  Color get combo2 => const Color(0xFFFFD54F);

  @override
  Color get combo3 => const Color(0xFFFFAB40);

  @override
  Color get combo4 => const Color(0xFFFF7043);

  @override
  Color get combo5 => const Color(0xFFEC407A);

  // ========== 网格颜色 ==========
  @override
  Color get emptyCell => const Color(0xFF120A06);

  @override
  Color get filledCell => const Color(0xFFFF8A65);

  @override
  Color get gridBorder => const Color(0xFF3D2818);

  @override
  Color get gridBackground => const Color(0xFF2A1810);

  @override
  Color get gridShadow => const Color(0xFF0A0503);

  // ========== 方块颜色（暖色系为主） ==========
  @override
  Map<String, Color> get blockColors => {
    // 单格 - 鲜红色
    'single': const Color(0xFFEF5350),
    // 横条 2格 - 橙色
    'h2': const Color(0xFFFF7043),
    // 横条 3格 - 金黄色
    'h3': const Color(0xFFFFCA28),
    // 横条 4格 - 深橙色
    'h4': const Color(0xFFFF5722),
    // 竖条 2格 - 橙色
    'v2': const Color(0xFFFF7043),
    // 竖条 3格 - 金黄色
    'v3': const Color(0xFFFFCA28),
    // 竖条 4格 - 深橙色
    'v4': const Color(0xFFFF5722),
    // 方块 2x2 - 琥珀色
    'square': const Color(0xFFFFB300),
    // L形 - 深红色
    'l': const Color(0xFFE64A19),
    // 反L形 - 深红色
    'rl': const Color(0xFFE64A19),
    // T形 - 玫红色
    't': const Color(0xFFF06292),
    // Z形 - 珊瑚色
    'z': const Color(0xFFFF8A65),
    // S形 - 珊瑚色
    's': const Color(0xFFFF8A65),
    // 十字形 - 深橙色
    'cross': const Color(0xFFE65100),
    // 横条 5格 - 红橙色
    'h5': const Color(0xFFD84315),
    // 竖条 5格 - 红橙色
    'v5': const Color(0xFFD84315),
    // 3x3大方块 - 深红色
    'bigSquare': const Color(0xFFBF360C),
    // 阶梯形 - 棕色
    'stairs': const Color(0xFF8D6E63),
    // U形 - 暗红色
    'u': const Color(0xFFC62828),
    // 大T形 - 棕红色
    'bigT': const Color(0xFFD84315),
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
