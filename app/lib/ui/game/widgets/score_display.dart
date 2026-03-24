// lib/ui/game/widgets/score_display.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/game/providers.dart';
import '../animations/score_animation_widget.dart';

/// 分数显示组件
/// 
/// 使用 ScoreAnimationWidget 实现动画效果，避免全局 rebuild
class ScoreDisplay extends ConsumerWidget {
  final int lastScoreIncrease;
  final VoidCallback? onAnimationComplete;

  const ScoreDisplay({
    super.key,
    this.lastScoreIncrease = 0,
    this.onAnimationComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(scoreProvider);
    final highScore = ref.watch(highScoreProvider);

    return ScoreAnimationWidget(
      score: score,
      highScore: highScore,
      scoreIncrease: lastScoreIncrease,
      onAnimationComplete: onAnimationComplete,
    );
  }
}
