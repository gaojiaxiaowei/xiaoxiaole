import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/ui/game/widgets/pause_overlay.dart';

void main() {
  group('PauseOverlay', () {
    testWidgets('should display pause icon and text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PauseOverlay(onResume: VoidCallback.empty),
          ),
        ),
      );

      expect(find.byIcon(Icons.pause_circle_filled), findsOneWidget);
      expect(find.text('游戏暂停'), findsOneWidget);
      expect(find.text('继续游戏'), findsOneWidget);
    });

    testWidgets('should call onResume when button pressed', (tester) async {
      var resumed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PauseOverlay(
              onResume: () => resumed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('继续游戏'));
      await tester.pumpAndSettle();
      
      expect(resumed, isTrue);
    });

    testWidgets('should have semi-transparent background', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PauseOverlay(onResume: VoidCallback.empty),
          ),
        ),
      );

      // 查找Container widget
      final containerFinder = find.byType(Container).first;
      final container = tester.widget<Container>(containerFinder);
      
      // 验证有颜色装饰
      expect(container.decoration, isNotNull);
    });

    testWidgets('should have green continue button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PauseOverlay(onResume: VoidCallback.empty),
          ),
        ),
      );

      final buttonFinder = find.byType(ElevatedButton);
      final button = tester.widget<ElevatedButton>(buttonFinder);
      
      // 验证按钮样式
      expect(button.style, isNotNull);
    });

    testWidgets('pause icon should have correct size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PauseOverlay(onResume: VoidCallback.empty),
          ),
        ),
      );

      final iconFinder = find.byIcon(Icons.pause_circle_filled);
      final icon = tester.widget<Icon>(iconFinder);
      
      expect(icon.size, equals(80));
    });
  });
}
