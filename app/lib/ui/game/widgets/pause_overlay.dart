// lib/ui/game/widgets/pause_overlay.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../game/themes/theme_manager.dart';
import '../../../providers/theme/theme_provider.dart';

class PauseOverlay extends ConsumerWidget {
  final VoidCallback onResume;

  const PauseOverlay({
    super.key,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeManagerProvider);
    return Positioned.fill(
      child: GestureDetector(
        onTap: onResume,
        child: Container(
          color: theme.background.withOpacity(0.7),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.pause_circle_filled,
                  color: theme.primaryText,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  '游戏暂停',
                  style: TextStyle(
                    color: theme.primaryText,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('继续游戏'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accent,
                    foregroundColor: theme.primaryText,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
