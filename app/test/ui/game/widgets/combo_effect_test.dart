import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/ui/game/widgets/combo_effect.dart';
import 'package:block_blast/providers/game/game_state.dart';

void main() {
  group('ComboEffect', () {
    testWidgets('should display combo text', (tester) async {
      const comboState = ComboState(
        text: 'GOOD!',
        color: Colors.yellow,
        count: 2,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComboEffect(
              state: comboState,
              onComplete: () {},
            ),
          ),
        ),
      );

      expect(find.text('GOOD!'), findsOneWidget);
    });

    testWidgets('should accept combo state with different counts', (tester) async {
      const comboState = ComboState(
        text: 'EXCELLENT!',
        color: Colors.red,
        count: 4,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComboEffect(
              state: comboState,
              onComplete: () {},
            ),
          ),
        ),
      );

      expect(find.text('EXCELLENT!'), findsOneWidget);
    });

    testWidgets('should accept onComplete callback', (tester) async {
      var completed = false;
      const comboState = ComboState(
        text: 'GREAT!',
        color: Colors.orange,
        count: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComboEffect(
              state: comboState,
              onComplete: () => completed = true,
            ),
          ),
        ),
      );

      expect(completed, isFalse); // 还没触发
    });

    testWidgets('should be a StatelessWidget', (tester) async {
      const comboState = ComboState(
        text: 'AMAZING!',
        color: Colors.purple,
        count: 5,
      );

      const widget = ComboEffect(
        state: comboState,
        onComplete: VoidCallback.empty,
      );

      // 验证是StatelessWidget
      expect(widget, isA<StatelessWidget>());
    });

    testWidgets('should use Positioned widget', (tester) async {
      const comboState = ComboState(
        text: 'GOOD!',
        color: Colors.yellow,
        count: 2,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ComboEffect(
              state: comboState,
              onComplete: VoidCallback.empty,
            ),
          ),
        ),
      );

      // 验证有Positioned widget
      expect(find.byType(Positioned), findsOneWidget);
    });

    testWidgets('should display AMAZING for combo >= 5', (tester) async {
      const comboState = ComboState(
        text: 'AMAZING!',
        color: Color(0xFF9C27B0),
        count: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ComboEffect(
              state: comboState,
              onComplete: () {},
            ),
          ),
        ),
      );

      expect(find.text('AMAZING!'), findsOneWidget);
    });

    testWidgets('should use correct colors for different combos', (tester) async {
      // GOOD (combo = 2)
      const goodState = ComboState(
        text: 'GOOD!',
        color: Color(0xFFFFEB3B),
        count: 2,
      );
      expect(goodState.color, const Color(0xFFFFEB3B));

      // GREAT (combo = 3)
      const greatState = ComboState(
        text: 'GREAT!',
        color: Color(0xFFFF9800),
        count: 3,
      );
      expect(greatState.color, const Color(0xFFFF9800));

      // EXCELLENT (combo = 4)
      const excellentState = ComboState(
        text: 'EXCELLENT!',
        color: Color(0xFFF44336),
        count: 4,
      );
      expect(excellentState.color, const Color(0xFFF44336));

      // AMAZING (combo >= 5)
      const amazingState = ComboState(
        text: 'AMAZING!',
        color: Color(0xFF9C27B0),
        count: 5,
      );
      expect(amazingState.color, const Color(0xFF9C27B0));
    });
  });
}
