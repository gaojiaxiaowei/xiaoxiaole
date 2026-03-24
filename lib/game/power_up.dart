import 'dart:math';

/// 道具类型
enum PowerUpType {
  bomb,    // 炸弹：消除 3x3 区域的方块
  refresh, // 刷新：重新生成3个可选方块
  undo,    // 撤销：撤销上一步操作
}

/// 道具数据
class PowerUp {
  final PowerUpType type;
  final String name;
  final String description;
  final String icon;

  const PowerUp({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
  });

  /// 获取道具的默认配置
  static const Map<PowerUpType, PowerUp> configs = {
    PowerUpType.bomb: PowerUp(
      type: PowerUpType.bomb,
      name: '炸弹',
      description: '消除 3x3 区域的方块',
      icon: '💣',
    ),
    PowerUpType.refresh: PowerUp(
      type: PowerUpType.refresh,
      name: '刷新',
      description: '重新生成3个可选方块',
      icon: '🔄',
    ),
    PowerUpType.undo: PowerUp(
      type: PowerUpType.undo,
      name: '撤销',
      description: '撤销上一步操作',
      icon: '↩️',
    ),
  };

  /// 根据类型获取道具配置
  static PowerUp fromType(PowerUpType type) {
    return configs[type]!;
  }
}

/// 道具使用结果
class PowerUpUseResult {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data; // 额外数据，如炸弹消除的位置等

  const PowerUpUseResult({
    required this.success,
    this.message,
    this.data,
  });
}

/// 道具系统逻辑
class PowerUpLogic {
  /// 使用炸弹道具 - 消除 3x3 区域的方块
  /// 
  /// [grid] - 游戏网格
  /// [centerX] - 中心点X坐标
  /// [centerY] - 中心点Y坐标
  /// [gridSize] - 网格大小（默认8）
  /// 
  /// 返回：消除的位置列表和新网格
  static PowerUpUseResult useBomb(
    List<List<int>> grid,
    int centerX,
    int centerY, {
    int gridSize = 8,
  }) {
    // 检查中心点是否在有效范围内
    if (centerX < 0 || centerX >= gridSize || centerY < 0 || centerY >= gridSize) {
      return const PowerUpUseResult(
        success: false,
        message: '无效的位置',
      );
    }

    // 检查中心点是否有方块
    if (grid[centerY][centerX] == 0) {
      return const PowerUpUseResult(
        success: false,
        message: '该位置没有方块',
      );
    }

    // 创建新网格（深拷贝）
    final newGrid = grid.map((row) => List<int>.from(row)).toList();
    final clearedPositions = <Map<String, int>>[];

    // 消除 3x3 区域
    for (int dy = -1; dy <= 1; dy++) {
      for (int dx = -1; dx <= 1; dx++) {
        final y = centerY + dy;
        final x = centerX + dx;
        
        // 检查边界
        if (x >= 0 && x < gridSize && y >= 0 && y < gridSize) {
          if (newGrid[y][x] == 1) {
            newGrid[y][x] = 0;
            clearedPositions.add({'x': x, 'y': y});
          }
        }
      }
    }

    return PowerUpUseResult(
      success: true,
      message: '成功消除了 ${clearedPositions.length} 个方块',
      data: {
        'newGrid': newGrid,
        'clearedPositions': clearedPositions,
        'clearedCount': clearedPositions.length,
      },
    );
  }

  /// 计算炸弹道具的得分
  /// 
  /// [clearedCount] - 消除的方块数量
  /// 
  /// 返回：获得的分数
  static int calculateBombScore(int clearedCount) {
    // 基础分：每个方块 5 分
    // 如果消除 9 个方块，额外奖励 20 分
    int score = clearedCount * 5;
    if (clearedCount >= 9) {
      score += 20;
    }
    return score;
  }

  /// 获取随机道具类型
  /// 
  /// 返回：随机道具类型
  static PowerUpType getRandomPowerUpType() {
    final random = Random();
    return PowerUpType.values[random.nextInt(PowerUpType.values.length)];
  }

  /// 检查是否应该奖励道具
  /// 
  /// [combo] - 连击数
  /// [clearedRows] - 消除的行数
  /// [clearedCols] - 消除的列数
  /// 
  /// 返回：是否应该奖励道具
  static bool shouldRewardPowerUp({
    required int combo,
    int clearedRows = 0,
    int clearedCols = 0,
  }) {
    // 连击 5 次以上奖励道具
    if (combo >= 5) {
      return true;
    }
    
    // 一次消除 3 行或 3 列以上奖励道具
    if (clearedRows >= 3 || clearedCols >= 3) {
      return true;
    }
    
    return false;
  }
}
