import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/stats_manager.dart';
import '../game/theme.dart';
import '../game/themes/themes.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme/theme_provider.dart';

/// 计时模式的倒计时显示组件
class TimedModeCountdown extends ConsumerStatefulWidget {
  final GameMode gameMode;
  final int initialSeconds;
  final VoidCallback? onTimeUp;
  final Function(int remainingSeconds)? onTick;
  final bool paused; // 暂停状态

  const TimedModeCountdown({
    super.key,
    required this.gameMode,
    this.initialSeconds = 60,
    this.onTimeUp,
    this.onTick,
    this.paused = false, // 默认不暂停
  });

  @override
  ConsumerState<TimedModeCountdown> createState() => _TimedModeCountdownState();
}

class _TimedModeCountdownState extends ConsumerState<TimedModeCountdown>
    with TickerProviderStateMixin {
  late AnimationController _warningController;
  late Animation<double> _warningAnimation;
  
  Timer? _timer;
  int _remainingSeconds = 0;
  bool _isWarning = false;

  @override
  void initState() {
    super.initState();
    
    _remainingSeconds = widget.initialSeconds;
    
    // 警告动画控制器
    _warningController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _warningAnimation = Tween<double>(begin: 1.0, end: 0.5).animate(
      CurvedAnimation(parent: _warningController, curve: Curves.easeInOut),
    );
    
    // 只有在不暂停时才启动计时器
    if (!widget.paused) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(TimedModeCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 检查暂停状态变化
    if (widget.paused != oldWidget.paused) {
      if (widget.paused) {
        // 进入暂停，停止计时器
        _stopTimer();
      } else {
        // 恢复游戏，重新启动计时器
        _startTimer();
      }
    }
  }

  /// 启动计时器
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          
          // 最后10秒开始警告
          if (_remainingSeconds <= 10 && !_isWarning) {
            _isWarning = true;
            _startWarningAnimation();
          }
          
          // 回调
          widget.onTick?.call(_remainingSeconds);
        });
      } else {
        _stopTimer();
        widget.onTimeUp?.call();
      }
    });
  }

  /// 停止计时器
  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// 启动警告动画
  void _startWarningAnimation() {
    _warningController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _stopTimer();
    _warningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofNonNull(context);
    final theme = ref.watch(themeManagerProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isWarning ? theme.error : theme.warning,
          width: 2,
        ),
        boxShadow: _isWarning
            ? [
                BoxShadow(
                  color: theme.error.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 时钟图标
          Icon(
            Icons.timer,
            color: _isWarning ? theme.error : theme.warning,
            size: 24,
          ),
          const SizedBox(width: 12),
          // 时间显示
          _isWarning
              ? AnimatedBuilder(
                  animation: _warningAnimation,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _warningAnimation.value,
                      child: _buildTimeText(),
                    );
                  },
                )
              : _buildTimeText(),
        ],
      ),
    );
  }

  /// 构建时间文本
  Widget _buildTimeText() {
    final theme = ref.watch(themeManagerProvider);
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    return Text(
      timeStr,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _isWarning ? theme.error : Colors.white,
      ),
    );
  }

  /// 获取背景颜色
  Color _getBackgroundColor() {
    final theme = ref.watch(themeManagerProvider);
    if (_isWarning) {
      return theme.error.withOpacity(0.3);
    } else if (_remainingSeconds <= 30) {
      return theme.warning.withOpacity(0.2);
    } else {
      return theme.accent.withOpacity(0.2);
    }
  }
}

/// 计时模式进度条组件
class TimedModeProgressBar extends ConsumerWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const TimedModeProgressBar({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = remainingSeconds / totalSeconds;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: Colors.grey.withOpacity(0.3),
        valueColor: AlwaysStoppedAnimation<Color>(
          _getProgressColor(progress, ref),
        ),
        minHeight: 8,
      ),
    );
  }

  /// 根据进度获取颜色
  Color _getProgressColor(double progress, WidgetRef ref) {
    final theme = ref.watch(themeManagerProvider);
    if (progress <= 0.15) {
      return theme.error;
    } else if (progress <= 0.3) {
      return theme.warning;
    } else {
      return theme.accent;
    }
  }
}

/// 计时模式时间警告组件
class TimedModeWarning extends ConsumerWidget {
  final int remainingSeconds;

  const TimedModeWarning({
    super.key,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (remainingSeconds > 10) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.ofNonNull(context);
    final theme = ref.watch(themeManagerProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.error.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            remainingSeconds > 0
                ? l10n.timeRemaining(remainingSeconds)
                : l10n.timeUp,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
