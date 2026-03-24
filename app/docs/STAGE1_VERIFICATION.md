# 阶段1验证说明

## 验证步骤

### 1. 安装依赖
```bash
cd /home/gem/workspace/agent/workspace/projects/block-blast/app
flutter pub get
```

### 2. 静态分析
```bash
flutter analyze
```

预期结果：无错误

### 3. 运行项目
```bash
flutter run
```

### 4. 验证 Provider 功能

#### 4.1 测试 game_state.dart
创建测试文件 `test/providers/game_state_test.dart`：
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/providers/game/game_state.dart';

void main() {
  test('GameState initial state should be correct', () {
    final state = GameState.initial();
    expect(state.grid.length, 8);
    expect(state.grid[0].length, 8);
    expect(state.score, 0);
    expect(state.isGameOver, false);
  });

  test('GameState copyWith should work correctly', () {
    final state = GameState.initial();
    final newState = state.copyWith(score: 100);
    expect(newState.score, 100);
    expect(state.score, 0); // 原状态不变
  });
}
```

#### 4.2 测试 Provider
创建测试文件 `test/providers/game_provider_test.dart`：
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:block_blast/providers/game/providers.dart';

void main() {
  test('gameProvider should be accessible', () {
    final container = ProviderContainer();
    final gameState = container.read(gameProvider);
    expect(gameState.grid.length, 8);
  });

  test('gridProvider should return grid from game state', () {
    final container = ProviderContainer();
    final grid = container.read(gridProvider);
    expect(grid.length, 8);
  });
}
```

### 5. 运行测试
```bash
flutter test
```

## 文件结构检查

执行以下命令确认文件结构：
```bash
tree lib/providers -L 3
```

预期输出：
```
lib/providers/
├── game/
│   ├── game_notifier.dart
│   ├── game_state.dart
│   └── providers.dart
├── providers.dart
└── settings/
    └── settings_provider.dart
```

## 代码质量检查

### 1. 检查 import 路径
```bash
grep -r "^import" lib/providers/ | grep -v "package:flutter\|package:flutter_riverpod\|package:shared_preferences"
```

所有 import 应该使用相对路径，格式为 `../../...`

### 2. 检查不可变性
```bash
grep -r "@immutable" lib/providers/game/
```

所有状态类都应该有 `@immutable` 注解

### 3. 检查 Provider 定义
```bash
grep -r "final.*Provider" lib/providers/game/providers.dart | wc -l
```

应该有 15 个 Provider 定义

## 常见问题排查

### 问题1：找不到 flutter 命令
**解决方案**：确保 Flutter SDK 已正确安装并添加到 PATH

### 问题2：依赖冲突
**解决方案**：
```bash
flutter pub cache repair
flutter pub get
```

### 问题3：import 路径错误
**解决方案**：检查文件实际位置，确保相对路径正确

## 验证完成标准

- [ ] `flutter pub get` 成功
- [ ] `flutter analyze` 无错误
- [ ] 项目可以运行
- [ ] Provider 可以正常读取
- [ ] 所有测试通过

## 下一阶段准备

阶段1验证通过后，可以开始阶段2：
- 拆分 game_page.dart
- 创建独立的 widget 组件
- 使用新的 Provider 替换原有状态管理

参考文档：`docs/P0_REFACTOR_PLAN.md` 第2节
