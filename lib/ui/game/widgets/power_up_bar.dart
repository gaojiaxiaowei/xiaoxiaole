// lib/ui/game/widgets/power_up_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../game/power_up.dart';
import '../../../game/power_up_manager.dart';
import '../../../game/themes/theme_manager.dart';
import '../../../providers/power_up/power_up_provider.dart';
import '../../../providers/theme/theme_provider.dart';

class PowerUpBar extends ConsumerStatefulWidget {
  final bool enabled;
  final Function(PowerUpType) onPowerUpTap;

  const PowerUpBar({
    super.key,
    required this.enabled,
    required this.onPowerUpTap,
  });

  @override
  ConsumerState<PowerUpBar> createState() => _PowerUpBarState();
}

class _PowerUpBarState extends ConsumerState<PowerUpBar> {
  Map<PowerUpType, int> _powerUpCounts = {
    PowerUpType.bomb: 0,
    PowerUpType.refresh: 0,
    PowerUpType.undo: 0,
  };

  @override
  void initState() {
    super.initState();
    _loadPowerUpCounts();
  }

  Future<void> _loadPowerUpCounts() async {
    final counts = await ref.read(powerUpManagerProvider).getPowerUpCounts();
    setState(() {
      _powerUpCounts = counts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeManagerProvider).currentTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildPowerUpButton(
            type: PowerUpType.bomb,
            icon: Icons.whatshot,
            label: '炸弹',
            color: theme.error,
          ),
          _buildPowerUpButton(
            type: PowerUpType.refresh,
            icon: Icons.refresh,
            label: '刷新',
            color: theme.accent,
          ),
          _buildPowerUpButton(
            type: PowerUpType.undo,
            icon: Icons.undo,
            label: '撤销',
            color: theme.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpButton({
    required PowerUpType type,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final theme = ref.watch(themeManagerProvider).currentTheme;
    final count = _powerUpCounts[type] ?? 0;
    final isEnabled = widget.enabled && count > 0;

    return GestureDetector(
      onTap: isEnabled
          ? () {
              widget.onPowerUpTap(type);
              // 刷新道具数量
              _loadPowerUpCounts();
            }
          : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? color.withOpacity(0.2) : theme.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isEnabled ? color : theme.gridBorder,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isEnabled ? color : theme.secondaryText,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? theme.primaryText : theme.secondaryText,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isEnabled ? color : theme.gridBorder,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'x$count',
                style: TextStyle(
                  color: theme.primaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
