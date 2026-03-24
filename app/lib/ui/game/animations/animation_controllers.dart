// lib/ui/game/animations/animation_controllers.dart

import 'package:flutter/material.dart';

/// 动画控制器集合
/// 
/// 注意：
/// - comboAnimation、scoreBounceAnimation、scorePopupAnimation 已移至独立组件
/// - 只保留需要全局协调的动画控制器
class AnimationControllers {
  final AnimationController clearAnimation;
  final AnimationController placeAnimation;
  final AnimationController dragScaleAnimation;

  AnimationControllers(TickerProvider vsync)
      : clearAnimation = AnimationController(
          duration: const Duration(milliseconds: 350),
          vsync: vsync,
        ),
        placeAnimation = AnimationController(
          duration: const Duration(milliseconds: 200),
          vsync: vsync,
        ),
        dragScaleAnimation = AnimationController(
          duration: const Duration(milliseconds: 150),
          vsync: vsync,
        );

  void dispose() {
    clearAnimation.dispose();
    placeAnimation.dispose();
    dragScaleAnimation.dispose();
  }

  void playPlaceAnimation() {
    placeAnimation.forward(from: 0.0);
  }

  void playClearAnimation() {
    clearAnimation.forward(from: 0.0);
  }

  void playDragScaleAnimation() {
    dragScaleAnimation.forward();
  }

  void reverseDragScaleAnimation() {
    dragScaleAnimation.reverse();
  }
}
