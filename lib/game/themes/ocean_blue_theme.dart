import 'package:flutter/material.dart';
import 'app_theme.dart';

/// 海洋蓝主题
/// 
/// 深蓝色背景配蓝色强调色
class OceanBlueTheme extends AppTheme {
  @override
  String get id => 'ocean_blue';

  @override
  String get displayName => '海洋蓝';

  @override
  String get description => '深蓝色背景配蓝色强调色';

  // ========== 背景色 ==========
  @override
  Color get background => const Color(0xFF0A1929);

  @override
  Color get cardBackground => const Color(0xFF0D2137);

  @override
  Color get dialogBackground => const Color(0xFF0D2137);

  @override
  Color get dialogItemBackground => const Color(0xFF132F4C);

  // ========== 文字色 ==========
  @override
  Color get primaryText => Colors.white;

  @override
  Color get secondaryText => const Color(0xFF7EB8DA);

  // ========== 强调色 ==========
  @override
  Color get accent => const Color(0xFF2196F3);

  @override
  Color get error => const Color(0xFFEF5350);

  @override
  Color get warning => const Color(0xFFFFB74D);

  // ========== 连击颜色 ==========
  @override
  Color get combo2 => const Color(0xFF4FC3F7);

  @override
  Color get combo3 => const Color(0xFF29B6F6);

  @override
  Color get combo4 => const Color(0xFF03A9F4);

  @override
  Color get combo5 => const Color(0xFF00BCD4);

  // ========== 网格颜色 ==========
  @override
  Color get emptyCell => const Color(0xFF071318);

  @override
  Color get filledCell => const Color(0xFF42A5F5);

  @override
  Color get gridBorder => const Color(0xFF1A3A5C);

  @override
  Color get gridBackground => const Color(0xFF0D2137);

  @override
  Color get gridShadow => const Color(0xFF000510);

  // ========== 方块颜色（蓝色系为主） ==========
  @override
  Map<String, Color> get blockColors => {
    // 单格 - 浅蓝色
    'single': const Color(0xFF81D4FA),
    // 横条 2格 - 青色
    'h2': const Color(0xFF4DD0E1),
    // 横条 3格 - 浅青色
    'h3': const Color(0xFF80DEEA),
    // 横条 4格 - 蓝色
    'h4': const Color(0xFF29B6F6),
    // 竖条 2格 - 青色
    'v2': const Color(0xFF4DD0E1),
    // 竖条 3格 - 浅青色
    'v3': const Color(0xFF80DEEA),
    // 竖条 4格 - 蓝色
    'v4': const Color(0xFF29B6F6),
    // 方块 2x2 - 深蓝色
    'square': const Color(0xFF42A5F5),
    // L形 - 靛蓝色
    'l': const Color(0xFF5C6BC0),
    // 反L形 - 靛蓝色
    'rl': const Color(0xFF5C6BC0),
    // T形 - 蓝紫色
    't': const Color(0xFF7986CB),
    // Z形 - 深青色
    'z': const Color(0xFF26A69A),
    // S形 - 深青色
    's': const Color(0xFF26A69A),
    // 十字形 - 海蓝色
    'cross': const Color(0xFF00ACC1),
    // 横条 5格 - 深蓝色
    'h5': const Color(0xFF1E88E5),
    // 竖条 5格 - 深蓝色
    'v5': const Color(0xFF1E88E5),
    // 3x3大方块 - 靛蓝色
    'bigSquare': const Color(0xFF3949AB),
    // 阶梯形 - 蓝灰色
    'stairs': const Color(0xFF546E7A),
    // U形 - 深青蓝色
    'u': const Color(0xFF00838F),
    // 大T形 - 宝蓝色
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
