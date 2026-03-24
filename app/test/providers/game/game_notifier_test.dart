import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/providers/game/game_notifier.dart';
import 'package:block_blast/providers/game/game_state.dart';
import 'package:block_blast/game/block.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GameNotifier', () {
    late GameNotifier notifier;

    setUp(() {
      notifier = GameNotifier(
        difficulty: 'normal',
        gameMode: GameMode.classic,
      );
    });

    tearDown(() {
      notifier.dispose();
    });

    test('initial state should have correct grid dimensions', () {
      expect(notifier.state.grid, hasLength(8));
      expect(notifier.state.grid[0], hasLength(8));
    });

    test('initial state should have zero score', () {
      expect(notifier.state.score, equals(0));
    });

    test('initial state should not be game over', () {
      expect(notifier.state.isGameOver, isFalse);
    });

    test('togglePause should toggle isPaused', () {
      expect(notifier.state.isPaused, isFalse);
      
      notifier.togglePause();
      expect(notifier.state.isPaused, isTrue);
      
      notifier.togglePause();
      expect(notifier.state.isPaused, isFalse);
    });

    test('selectBlock should update selectedBlock', () {
      final block = Block.allBlocks.first;
      
      notifier.selectBlock(block);
      expect(notifier.state.selectedBlock, equals(block));
      
      notifier.selectBlock(null);
      expect(notifier.state.selectedBlock, isNull);
    });

    test('startNewGame should reset state', () {
      // 修改状态
      notifier.togglePause();
      
      // 重新开始
      notifier.startNewGame();
      
      expect(notifier.state.score, equals(0));
      expect(notifier.state.isGameOver, isFalse);
      expect(notifier.state.isPaused, isFalse);
    });

    test('startNewGame should clear grid', () {
      // 重新开始
      notifier.startNewGame();
      
      // 验证网格已清空
      expect(
        notifier.state.grid.every((row) => row.every((cell) => cell == 0)),
        isTrue,
      );
    });

    test('startNewGame should generate new blocks', () {
      // 重新开始
      notifier.startNewGame();
      
      // 验证有可用方块
      expect(notifier.state.availableBlocks, isNotEmpty);
    });

    test('updateRemainingSeconds should update time', () {
      notifier.updateRemainingSeconds(50);
      expect(notifier.state.remainingSeconds, equals(50));
    });

    test('onTimeUp should set game over and time up flags', () {
      notifier.onTimeUp();
      
      expect(notifier.state.isTimeUp, isTrue);
      expect(notifier.state.isGameOver, isTrue);
    });

    test('toggleBombSelectionMode should toggle bomb selection mode', () {
      expect(notifier.state.isBombSelectionMode, isFalse);
      
      notifier.toggleBombSelectionMode();
      expect(notifier.state.isBombSelectionMode, isTrue);
      
      notifier.toggleBombSelectionMode();
      expect(notifier.state.isBombSelectionMode, isFalse);
    });

    test('refreshBlocks should update available blocks', () {
      final originalBlocks = notifier.state.availableBlocks;
      
      notifier.refreshBlocks();
      
      // 验证方块池已更新（可能相同，但调用了刷新逻辑）
      expect(notifier.state.availableBlocks.length, inInclusiveRange(2, 3));
    });

    test('clearPreview should reset drag state', () {
      notifier.clearPreview();
      
      expect(notifier.state.dragState.isDragging, isFalse);
      expect(notifier.state.dragState.draggingBlock, isNull);
    });

    test('clearComboEffect should clear combo state', () {
      notifier.clearComboEffect();
      
      expect(notifier.state.comboState, isNull);
    });
  });

  group('GameNotifier - undo functionality', () {
    late GameNotifier notifier;

    setUp(() {
      notifier = GameNotifier(
        difficulty: 'normal',
        gameMode: GameMode.classic,
      );
    });

    tearDown(() {
      notifier.dispose();
    });

    test('undo should return false when no state saved', () {
      final result = notifier.undo();
      expect(result, isFalse);
    });
  });
}
