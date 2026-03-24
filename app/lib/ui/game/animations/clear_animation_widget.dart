// lib/ui/game/animations/clear_animation_widget.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 消除动画组件
/// 
/// 特点：
/// - 自己管理 AnimationController 生命周期
/// - 使用 AnimatedBuilder 避免 rebuild 父组件
/// - 完成时通过回调通知父组件
class ClearAnimationWidget extends StatefulWidget {
  final Widget child;
  final List<int> clearingRows;
  final List<int> clearingCols;
  final VoidCallback onComplete;

  const ClearAnimationWidget({
    super.key,
    required this.child,
    required this.clearingRows,
    required this.clearingCols,
    required this.onComplete,
  });

  @override
  State<ClearAnimationWidget> createState() => _ClearAnimationWidgetState();
}

class _ClearAnimationWidgetState extends State<ClearAnimationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
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
        return _ClearEffect(
          value: _controller.value,
          clearingRows: widget.clearingRows,
          clearingCols: widget.clearingCols,
          child: child!,
        );
      },
      child: widget.child,
    );
  }
}

/// 消除效果绘制组件
class _ClearEffect extends StatelessWidget {
  final double value;
  final List<int> clearingRows;
  final List<int> clearingCols;
  final Widget child;

  const _ClearEffect({
    required this.value,
    required this.clearingRows,
    required this.clearingCols,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 前50%闪烁，后50%缩放消失
    if (value < 0.5) {
      // 闪烁效果
      final flashValue = (value * 2 * 6 * math.pi).sin();
      final opacity = 0.5 + 0.5 * (flashValue + 1) / 2;
      return Opacity(opacity: opacity, child: child);
    } else {
      // 缩放消失
      final disappearValue = (value - 0.5) * 2;
      final scale = 1.0 + disappearValue * 0.3;
      return Opacity(
        opacity: 1.0 - disappearValue,
        child: Transform.scale(scale: scale, child: child),
      );
    }
  }
}
