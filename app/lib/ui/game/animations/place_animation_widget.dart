// lib/ui/game/animations/place_animation_widget.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 放置动画组件
/// 
/// 特点：
/// - 弹性缩放效果
/// - 自己管理 AnimationController 生命周期
/// - 完成时通过回调通知父组件
class PlaceAnimationWidget extends StatefulWidget {
  final Widget child;
  final List<Offset> placedPositions;
  final VoidCallback onComplete;

  const PlaceAnimationWidget({
    super.key,
    required this.child,
    required this.placedPositions,
    required this.onComplete,
  });

  @override
  State<PlaceAnimationWidget> createState() => _PlaceAnimationWidgetState();
}

class _PlaceAnimationWidgetState extends State<PlaceAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
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
        // 弹性缩放效果
        final t = _controller.value;
        double scale;
        
        if (t < 0.4) {
          // 前半段：从小到大
          scale = 0.8 + 0.2 * (t / 0.4);
        } else {
          // 后半段：弹性效果
          final bounceT = (t - 0.4) / 0.6;
          const decay = 4.0;
          const freq = 4.5 * math.pi;
          const amplitude = 0.12;
          scale = 1.0 + amplitude * math.exp(-decay * bounceT) * math.sin(freq * bounceT);
        }
        
        return Transform.scale(scale: scale, child: child);
      },
      child: widget.child,
    );
  }
}
