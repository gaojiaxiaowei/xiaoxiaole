# 道具系统集成指南

## 概述

道具系统已实现完成，包含以下文件：

- `lib/game/power_up.dart` - 道具数据模型和逻辑
- `lib/game/power_up_manager.dart` - 道具管理器（存储、获取、使用）
- `lib/ui/power_up_mixin.dart` - 道具系统 Mixin（为游戏页面提供道具功能）
- `test/game/power_up_test.dart` - 道具系统测试

## 集成步骤

### 1. 修改 `GamePageState` 类

在 `lib/ui/game_page.dart` 中，修改 `_GamePageState` 类：

```dart
// 导入道具系统
import 'power_up_mixin.dart';
import '../game/power_up.dart';

// 修改类定义，添加 PowerUpMixin
class _GamePageState extends State<GamePage> 
    with TickerProviderStateMixin, PowerUpMixin {  // 添加 PowerUpMixin
  
  // ... 现有代码 ...
  
  @override
  void initState() {
    super.initState();
    _initClearAnimationController();
    _loadSettings();
    _loadHighScore();
    
    // 初始化道具系统
    initPowerUpSystem();
    initPowerUpAnimations(this);  // 传入 vsync
    
    _startNewGame();
    _gameStartTime = DateTime.now();
  }
  
  @override
  void dispose() {
    // 释放道具系统资源
    disposePowerUpSystem();
    
    // ... 现有的 dispose 代码 ...
    _clearAnimationController?.dispose();
    // ... 其他 dispose ...
    
    super.dispose();
  }
  
  // ... 其他现有代码 ...
}
```

### 2. 修改 `_startNewGame` 方法

```dart
void _startNewGame() {
  setState(() {
    _grid = List.generate(8, (_) => List.generate(8, (_) => 0));
    _availableBlocks = Block.getBlocksByUserDifficulty(_difficulty, _score);
    _selectedBlock = null;
    _score = 0;
    _isGameOver = false;
    _isDragging = false;
    _draggingBlock = null;
    _previewData = null;
    
    // 重置本局统计
    _rowsClearedThisGame = 0;
    _colsClearedThisGame = 0;
    _maxComboThisGame = 0;
    _gameStartTime = DateTime.now();
  });
  
  // 每局开始时获得一个随机道具
  initPowerUpSystem();
}
```

### 3. 修改 `_placeBlock` 方法（保存状态用于撤销）

```dart
void _placeBlock(int gridX, int gridY, Block block) {
  if (_isGameOver || _isPaused) return;

  // 检查是否可以放置
  if (!ClearLogic.canPlace(_grid, gridX, gridY, block.shape)) {
    return;
  }

  // 保存当前状态（用于撤销道具）
  saveCurrentState(_grid, _availableBlocks, _score);

  // ... 现有的放置逻辑 ...
  final placedPositions = block.shape.map((offset) {
    return Offset(gridX + offset.dx, gridY + offset.dy);
  }).toList();

  var newGrid = ClearLogic.placeBlock(_grid, gridX, gridY, block.shape);
  _playPlaceAnimation(newGrid, placedPositions, block);
}
```

### 4. 修改 `_updateStateAfterClear` 方法（奖励道具）

```dart
void _updateStateAfterClear(
  List<List<int>> newGrid,
  Block placedBlock,
  int clearScore,
  int clearedCount,
) {
  // ... 现有代码 ...
  
  // 移除已使用的方块
  final newBlocks = List<Block>.from(_availableBlocks)..remove(placedBlock);
  
  // 如果方块用完了，生成新的
  if (newBlocks.isEmpty) {
    newBlocks.addAll(Block.getBlocksByUserDifficulty(_difficulty, _score));
  }
  
  // 更新分数
  final newScore = _score + clearScore;
  
  // 更新最高分
  if (newScore > _highScore) {
    _highScore = newScore;
    _saveHighScore();
  }
  
  // 显示分数动画
  if (clearScore > 0) {
    _showScoreAnimation(clearScore);
  }
  
  // **新增：检查是否应该奖励道具**
  rewardPowerUpIfNeeded(
    combo: clearedCount,
    clearedRows: _rowsClearedThisGame,
    clearedCols: _colsClearedThisGame,
  );
  
  // ... 其余现有代码 ...
  
  setState(() {
    _grid = newGrid;
    _availableBlocks = newBlocks;
    _score = newScore;
    // ... 其他状态更新 ...
  });
  
  // 检查游戏是否结束
  _checkGameOver();
}
```

### 5. 在 `build` 方法中添加道具栏

找到 `build` 方法中返回的 Scaffold，在合适的位置（如分数下方）添加道具栏：

```dart
@override
Widget build(BuildContext context) {
  final l10n = AppLocalizations.ofNonNull(context);
  
  return Scaffold(
    body: Container(
      decoration: BoxDecoration(
        color: ThemeManager().currentTheme.background,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 顶部栏（分数、设置按钮等）
            _buildTopBar(),
            
            // **新增：道具栏**
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: buildPowerUpBar(
                enabled: !_isGameOver && !_isPaused && !_isDragging,
                onPowerUpTap: _onPowerUpTap,
              ),
            ),
            
            // 分数显示
            _buildScoreDisplay(),
            
            // 游戏网格
            _buildGrid(),
            
            // 可选方块
            _buildAvailableBlocks(),
          ],
        ),
      ),
    ),
  );
}

// **新增：处理道具点击**
void _onPowerUpTap(PowerUpType type) {
  if (isUsingPowerUp) {
    cancelPowerUp();
    return;
  }
  
  switch (type) {
    case PowerUpType.bomb:
      // 炸弹需要选择位置
      _showBombSelectionDialog();
      break;
    case PowerUpType.refresh:
      // 刷新方块
      _useRefreshPowerUp();
      break;
    case PowerUpType.undo:
      // 撤销操作
      _useUndoPowerUp();
      break;
  }
}

// **新增：显示炸弹选择对话框**
void _showBombSelectionDialog() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('选择炸弹位置'),
      content: const Text('点击网格中的方块来使用炸弹'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            cancelPowerUp();
          },
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            setState(() {
              // 进入炸弹选择模式
              // 点击网格时调用 _useBombPowerUp(x, y)
            });
          },
          child: const Text('确定'),
        ),
      ],
    ),
  );
}

// **新增：使用炸弹道具**
void _useBombPowerUp(int gridX, int gridY) async {
  final success = await usePowerUp(
    PowerUpType.bomb,
    grid: _grid,
    gridSize: 8,
    targetX: gridX,
    targetY: gridY,
    onBombUsed: (newGrid, score) {
      setState(() {
        _grid = newGrid;
        _score += score;
      });
      _showScoreAnimation(score);
    },
  );
  
  if (!success) {
    // 显示错误提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('无法使用炸弹')),
    );
  }
}

// **新增：使用刷新道具**
void _useRefreshPowerUp() async {
  final success = await usePowerUp(
    PowerUpType.refresh,
    grid: _grid,
    gridSize: 8,
    onRefreshUsed: () {
      setState(() {
        _availableBlocks = Block.getBlocksByUserDifficulty(_difficulty, _score);
      });
    },
  );
  
  if (!success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('无法使用刷新')),
    );
  }
}

// **新增：使用撤销道具**
void _useUndoPowerUp() async {
  final success = await usePowerUp(
    PowerUpType.undo,
    grid: _grid,
    gridSize: 8,
    onUndoUsed: (lastGrid, lastBlocks, lastScore) {
      setState(() {
        if (lastGrid != null) _grid = lastGrid;
        if (lastBlocks != null) _availableBlocks = lastBlocks;
        if (lastScore != null) _score = lastScore;
      });
    },
  );
  
  if (!success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('无法撤销')),
    );
  }
}
```

### 6. 修改网格点击处理（支持炸弹选择）

如果玩家正在使用炸弹道具，点击网格时应该使用炸弹：

```dart
// 在 GridWidget 的 onCellTap 回调中
onCellTap: (gridX, gridY) {
  if (usingPowerUpType == PowerUpType.bomb) {
    _useBombPowerUp(gridX, gridY);
  } else {
    // 原有的点击逻辑
  }
},
```

## 测试

运行测试确保道具系统工作正常：

```bash
/home/gem/flutter/bin/flutter test test/game/power_up_test.dart
```

## 道具效果说明

### 1. 炸弹（💣）
- **效果**：消除 3x3 区域的方块
- **使用**：点击炸弹道具，然后点击网格中的方块
- **得分**：每个消除的方块 5 分，消除 9 个额外奖励 20 分

### 2. 刷新（🔄）
- **效果**：重新生成 3 个可选方块
- **使用**：直接点击刷新道具

### 3. 撤销（↩️）
- **效果**：撤销上一步操作（恢复网格、方块和分数）
- **使用**：直接点击撤销道具
- **限制**：只能撤销上一步，不能连续撤销多步

## 道具获取方式

1. **每局游戏开始**：自动获得 1 个随机道具
2. **连击奖励**：连击 5 次以上，获得 1 个随机道具
3. **消除奖励**：一次消除 3 行或 3 列以上，获得 1 个随机道具

## 数据存储

道具数量使用 `SharedPreferences` 存储，跨游戏保留。

## 注意事项

1. 道具在游戏暂停或结束时无法使用
2. 炸弹需要选择有方块的位置才能使用
3. 撤销只能撤销上一步操作
4. 道具数量显示在道具按钮右下角
5. 道具正在使用时，按钮会高亮显示
