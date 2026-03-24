// lib/ui/game/animations/combo_animation_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../game/themes/theme_manager.dart';
import '../../../providers/theme/theme_provider.dart';

/// 连击动画组件
///
/// 特点：
/// - 快速闪烁 + 向上飘动
/// - 自己管理 AnimationController 生命周期
/// - 完成时通过回调通知父组件
class ComboAnimationWidget extends ConsumerStatefulWidget {
  final String text;
  final Color color;
  final int count;
  final VoidCallback onComplete;

  const ComboAnimationWidget({
    super.key,
    required this.text,
    required this.color,
    required this.count,
    required this.onComplete,
  });

  @override
  ConsumerState<ComboAnimationWidget> createState() => _ComboAnimationWidgetState();
}

class _ComboAnimationWidgetState extends ConsumerState<ComboAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 快速闪烁动画
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 10),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // 透明度渐变动画
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
    ]).animate(_controller);

    // 向上飘动动画
    _slideAnimation = Tween<double>(begin: 0, end: -30).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    // 动画完成后通知父组件
    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: _buildComboContent(),
    );
  }

  Widget _buildComboContent() {
    final theme = ref.watch(themeManagerProvider);
    final hasShine = widget.count >= 5;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            if (hasShine)
              Text(
                widget.text,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = 6
                    ..color = widget.color.withOpacity(0.5),
                ),
              ),
            Text(
              widget.text,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: widget.color,
              ),
            ),
          ],
        ),
        if (widget.count >= 2) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: widget.color, width: 2),
            ),
            child: Text(
              '${widget.count}x',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.primaryText,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
