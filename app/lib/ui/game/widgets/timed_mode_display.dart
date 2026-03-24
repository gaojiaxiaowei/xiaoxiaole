// lib/ui/game/widgets/timed_mode_display.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme/theme_provider.dart';
import '../../../providers/game/providers.dart';
import '../../../game/themes/theme_manager.dart';

class TimedModeDisplay extends ConsumerWidget {
  const TimedModeDisplay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remainingSeconds = ref.watch(gameProvider).remainingSeconds;
    final isTimeUp = ref.watch(gameProvider).isTimeUp;
    final theme = ref.watch(themeManagerProvider).currentTheme;
    
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    final timeString = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    
    // 时间紧迫时（<10秒）显示错误色
    final isUrgent = remainingSeconds < 10 && !isTimeUp;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isUrgent ? theme.error.withOpacity(0.2) : theme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent ? theme.error : theme.gridBorder,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            color: isUrgent ? theme.error : theme.primaryText,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            timeString,
            style: TextStyle(
              color: isUrgent ? theme.error : theme.primaryText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
