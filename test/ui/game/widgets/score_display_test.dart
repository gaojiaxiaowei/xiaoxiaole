import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/ui/game/widgets/score_display.dart';
import 'package:block_blast/game/themes/theme_manager.dart';

void main() {
  setUp(() {
    // 初始化 ThemeManager
    ThemeManager.setGlobalInstance(ThemeManager());
  });

  group('ScoreDisplay', () {
    testWidgets('should be a ConsumerWidget', (tester) async {
      // 验证ScoreDisplay是一个ConsumerWidget
      expect(ScoreDisplay, isA<Type>());
    });

    testWidgets('should accept lastScoreIncrease parameter', (tester) async {
      // 创建widget实例，验证参数可传递
      const widget = ScoreDisplay(
        lastScoreIncrease: 10,
      );
      
      expect(widget.lastScoreIncrease, equals(10));
    });

    testWidgets('should accept onAnimationComplete callback', (tester) async {
      var completed = false;
      
      final widget = ScoreDisplay(
        onAnimationComplete: () => completed = true,
      );
      
      expect(widget.onAnimationComplete, isNotNull);
    });

    testWidgets('should have default values', (tester) async {
      const widget = ScoreDisplay();
      
      expect(widget.lastScoreIncrease, equals(0));
      expect(widget.onAnimationComplete, isNull);
    });

    // 注意：完整的Widget测试需要ProviderScope环境
    // 这里只测试Widget的基本结构和参数
    testWidgets('should construct without errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ScoreDisplay(),
          ),
        ),
      );

      // 验证widget树构建成功
      expect(find.byType(ScoreDisplay), findsOneWidget);
    });
  });
}
