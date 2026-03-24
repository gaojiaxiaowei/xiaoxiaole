// lib/ui/game/animations/score_animation_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../game/themes/theme_manager.dart';
import '../../../providers/theme/theme_provider.dart';

/// 分数动画组件
///
/// 特点：
/// - 分数跳动动画
/// - 加分弹出动画
/// - 自己管理 AnimationController 生命周期
/// - 完成时通过回调通知父组件
class ScoreAnimationWidget extends ConsumerStatefulWidget {
  final int score;
  final int highScore;
  final int scoreIncrease;
  final VoidCallback? onAnimationComplete;

  const ScoreAnimationWidget({
    super.key,
    required this.score,
    required this.highScore,
    this.scoreIncrease = 0,
    this.onAnimationComplete,
  });

  @override
  ConsumerState<ScoreAnimationWidget> createState() => _ScoreAnimationWidgetState();
}

class _ScoreAnimationWidgetState extends ConsumerState<ScoreAnimationWidget>
    with TickerProviderStateMixin {
  late final AnimationController _bounceController;
  late final AnimationController _popupController;

  @override
  void initState() {
    super.initState();
    
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _popupController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(ScoreAnimationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 分数变化时触发动画
    if (widget.score != oldWidget.score) {
      _bounceController.forward(from: 0.0);
    }
    
    // 有加分时显示弹出动画
    if (widget.scoreIncrease > 0 && oldWidget.scoreIncrease == 0) {
      _popupController.forward(from: 0.0).then((_) {
        widget.onAnimationComplete?.call();
      });
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _popupController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildScoreArea(),
          if (widget.scoreIncrease > 0) _buildScorePopup(),
        ],
      ),
    );
  }

  Widget _buildScoreArea() {
    final theme = ref.watch(themeManagerProvider);
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        final scale = 1.0 + (_bounceController.value * 0.4);
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '分数: ${widget.score}',
              style: TextStyle(
                color: theme.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '最高: ${widget.highScore}',
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScorePopup() {
    final theme = ref.watch(themeManagerProvider);
    return Positioned(
      right: 8,
      top: -10,
      child: AnimatedBuilder(
        animation: _popupController,
        builder: (context, child) {
          final opacity = 1.0 - _popupController.value;
          final offset = -40 * _popupController.value;
          return Transform.translate(
            offset: Offset(0, offset),
            child: Opacity(
              opacity: opacity,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.accent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.accent, width: 1),
          ),
          child: Text(
            '+${widget.scoreIncrease}',
            style: TextStyle(
              color: theme.accent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
