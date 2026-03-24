class GameConfig {
  // 网格配置
  static const int gridSize = 8;
  static const double defaultCellSize = 40.0;
  static const double cellMargin = 1.0;
  
  // 动画时长
  static const Duration clearAnimationDuration = Duration(milliseconds: 350);
  static const Duration placeAnimationDuration = Duration(milliseconds: 200);
  static const Duration comboAnimationDuration = Duration(milliseconds: 800);
  static const Duration scoreAnimationDuration = Duration(milliseconds: 600);
  static const Duration scoreBounceDuration = Duration(milliseconds: 200);
}
