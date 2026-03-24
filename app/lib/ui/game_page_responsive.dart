import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/block.dart';
import '../game/grid.dart';
import '../game/drag.dart';
import '../game/clear.dart';
import '../game/sound.dart';
import 'settings_page.dart';
import 'help_page.dart';

/// 响应式布局配置
class ResponsiveConfig {
  final double cellSize;
  final double blockPoolCellSize;
  final double blockPoolPadding;
  final double scoreFontSize;
  final double highScoreFontSize;
  final double comboFontSize;
  final double tipFontSize;
  final double topSpacing;
  final double bottomSpacing;
  final double centerPadding;
  final bool isSmallScreen;

  ResponsiveConfig({
    required this.cellSize,
    required this.blockPoolCellSize,
    required this.blockPoolPadding,
    required this.scoreFontSize,
    required this.highScoreFontSize,
    required this.comboFontSize,
    required this.tipFontSize,
    required this.topSpacing,
    required this.bottomSpacing,
    required this.centerPadding,
    required this.isSmallScreen,
  });

  factory ResponsiveConfig.fromContext(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    
    // 计算网格尺寸
    final gridPadding = 16.0;
    final gridSpacing = 16.0;
    final availableWidth = screenWidth - gridPadding * 2 - gridSpacing;
    final cellSize = availableWidth / 8;
    final responsiveCellSize = cellSize.clamp(32.0, 50.0);
    
    // 方块池尺寸
    final isSmallScreen = screenHeight < 600;
    final blockPoolCellSize = isSmallScreen ? 22.0 : (responsiveCellSize * 0.65).clamp(22.0, 32.0);
    final blockPoolPadding = isSmallScreen ? 12.0 : 20.0;
    
    // 字体大小
    final scoreFontSize = (screenWidth * 0.045).clamp(14.0, 18.0);
    final highScoreFontSize = (screenWidth * 0.03).clamp(10.0, 12.0);
    final comboFontSize = (screenWidth * 0.09).clamp(28.0, 40.0);
    final tipFontSize = (screenWidth * 0.035).clamp(12.0, 14.0);
    
    // 间距
    final topSpacing = isSmallScreen ? 10.0 : 20.0;
    final bottomSpacing = isSmallScreen ? 10.0 : 20.0;
    
    // 大屏居中
    final maxGridWidth = responsiveCellSize * 8 + gridSpacing + gridPadding * 2;
    final centerPadding = screenWidth > 600 ? (screenWidth - maxGridWidth) / 2 : 0.0;

    return ResponsiveConfig(
      cellSize: responsiveCellSize,
      blockPoolCellSize: blockPoolCellSize,
      blockPoolPadding: blockPoolPadding,
      scoreFontSize: scoreFontSize,
      highScoreFontSize: highScoreFontSize,
      comboFontSize: comboFontSize,
      tipFontSize: tipFontSize,
      topSpacing: topSpacing,
      bottomSpacing: bottomSpacing,
      centerPadding: centerPadding,
      isSmallScreen: isSmallScreen,
    );
  }
}
