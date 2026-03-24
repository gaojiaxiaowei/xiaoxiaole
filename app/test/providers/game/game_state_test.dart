import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/providers/game/game_state.dart';
import 'package:block_blast/game/block.dart';

void main() {
  group('GameState', () {
    test('initial state should have empty grid and no blocks', () {
      final state = GameState.initial();
      
      expect(state.grid, hasLength(8));
      expect(state.grid.every((row) => row.every((cell) => cell == 0)), isTrue);
      expect(state.availableBlocks, isEmpty);
      expect(state.score, equals(0));
      expect(state.highScore, equals(0));
      expect(state.isGameOver, isFalse);
      expect(state.isPaused, isFalse);
    });

    test('copyWith should create new instance with updated values', () {
      final original = GameState.initial();
      final updated = original.copyWith(
        score: 100,
        isPaused: true,
      );
      
      expect(updated.score, equals(100));
      expect(updated.isPaused, isTrue);
      expect(updated.grid, equals(original.grid));
    });

    test('copyWith with clear flags should set fields to null', () {
      final testBlock = Block.allBlocks.first;
      final state = GameState(
        grid: [],
        availableBlocks: [],
        selectedBlock: testBlock,
      );
      
      final cleared = state.copyWith(clearSelectedBlock: true);
      
      expect(cleared.selectedBlock, isNull);
    });

    test('copyWith should preserve unmodified fields', () {
      final original = GameState.initial();
      final updated = original.copyWith(score: 100);
      
      expect(updated.highScore, equals(original.highScore));
      expect(updated.isGameOver, equals(original.isGameOver));
      expect(updated.gameMode, equals(original.gameMode));
    });
  });

  group('DragState', () {
    test('copyWith should preserve unmodified fields', () {
      final state = DragState(
        isDragging: true,
        previewGridX: 3,
        previewGridY: 4,
      );
      
      final updated = state.copyWith(isDragging: false);
      
      expect(updated.isDragging, isFalse);
      expect(updated.previewGridX, equals(3));
      expect(updated.previewGridY, equals(4));
    });

    test('copyWith with clear flags should set fields to null', () {
      final testBlock = Block.allBlocks.first;
      final state = DragState(
        isDragging: true,
        draggingBlock: testBlock,
        previewGridX: 3,
      );
      
      final cleared = state.copyWith(clearDraggingBlock: true);
      
      expect(cleared.draggingBlock, isNull);
      expect(cleared.previewGridX, equals(3));
    });
  });

  group('GameStats', () {
    test('copyWith should update stats correctly', () {
      final stats = GameStats(
        rowsCleared: 5,
        colsCleared: 3,
        maxCombo: 4,
      );
      
      final updated = stats.copyWith(rowsCleared: 10);
      
      expect(updated.rowsCleared, equals(10));
      expect(updated.colsCleared, equals(3));
      expect(updated.maxCombo, equals(4));
    });

    test('default values should be zero', () {
      const stats = GameStats();
      
      expect(stats.rowsCleared, equals(0));
      expect(stats.colsCleared, equals(0));
      expect(stats.maxCombo, equals(0));
      expect(stats.startTime, isNull);
    });
  });

  group('ComboState', () {
    test('should store combo information', () {
      const comboState = ComboState(
        text: 'GOOD!',
        color: Color(0xFFFFEB3B),
        count: 2,
      );
      
      expect(comboState.text, equals('GOOD!'));
      expect(comboState.count, equals(2));
    });
  });

  group('ClearAnimationState', () {
    test('should store clear animation data', () {
      const clearState = ClearAnimationState(
        clearingRows: [0, 1],
        clearingCols: [2],
        animationValue: 0.5,
      );
      
      expect(clearState.clearingRows, equals([0, 1]));
      expect(clearState.clearingCols, equals([2]));
      expect(clearState.animationValue, equals(0.5));
    });
  });
}
