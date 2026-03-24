// lib/ui/game/widgets/combo_effect.dart

import 'package:flutter/material.dart';
import '../../../providers/game/game_state.dart';
import '../animations/combo_animation_widget.dart';

/// 连击特效组件
/// 
/// 使用 ComboAnimationWidget 实现动画效果，避免全局 rebuild
class ComboEffect extends StatelessWidget {
  final ComboState state;
  final VoidCallback onComplete;

  const ComboEffect({
    super.key,
    required this.state,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -50,
      left: 0,
      right: 0,
      child: ComboAnimationWidget(
        text: state.text,
        color: state.color,
        count: state.count,
        onComplete: onComplete,
      ),
    );
  }
}
