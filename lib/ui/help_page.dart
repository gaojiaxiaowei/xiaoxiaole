import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/themes/themes.dart';
import '../providers/theme/theme_provider.dart';
import '../l10n/app_localizations.dart';

/// 帮助/游戏说明页面
class HelpPage extends ConsumerWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeManagerProvider);
    final l10n = AppLocalizations.ofNonNull(context);
    
    return Scaffold(
      backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: theme.cardBackground,
            title: Text(
              l10n.gameInstructions,
              style: TextStyle(color: theme.primaryText),
            ),
            iconTheme: IconThemeData(color: theme.primaryText),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 游戏目标
                _buildRuleCard(
                  context: context,
                  icon: Icons.flag,
                  iconColor: theme.accent,
                  title: l10n.gameGoal,
                  description: l10n.gameGoalDesc,
                  theme: theme,
                ),
                
                const SizedBox(height: 12),
                
                // 操作方法
                _buildRuleCard(
                  context: context,
                  icon: Icons.touch_app,
                  iconColor: theme.accent,
                  title: l10n.operationMethod,
                  description: l10n.operationMethodDesc,
                  theme: theme,
                ),
                
                const SizedBox(height: 12),
                
                // 消除规则
                _buildRuleCard(
                  context: context,
                  icon: Icons.auto_fix_high,
                  iconColor: theme.warning,
                  title: l10n.clearRules,
                  description: l10n.clearRulesDesc,
                  theme: theme,
                ),
                
                const SizedBox(height: 12),
                
                // 计分规则
                _buildRuleCard(
                  context: context,
                  icon: Icons.stars,
                  iconColor: theme.combo2,
                  title: l10n.scoringRules,
                  description: '${l10n.scoringPlace}\n${l10n.scoringClear}\n${l10n.scoringCombo}',
                  theme: theme,
                ),
                
                const SizedBox(height: 12),
                
                // 游戏结束
                _buildRuleCard(
                  context: context,
                  icon: Icons.stop_circle_outlined,
                  iconColor: theme.error,
                  title: l10n.gameEnd,
                  description: l10n.gameEndDesc,
                  theme: theme,
                ),
                
                const SizedBox(height: 24),
                
                // 小提示
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.accent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb,
                        color: theme.accent,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.smallTip,
                              style: TextStyle(
                                color: theme.accent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${l10n.tip1}\n${l10n.tip2}\n${l10n.tip3}\n${l10n.tip4}',
                              style: TextStyle(
                                color: theme.secondaryText,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // 开始游戏按钮
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.play_arrow),
                    label: Text(
                      l10n.startGame,
                      style: const TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accent,
                      foregroundColor: theme.primaryText,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
  }

  // 构建规则卡片
  Widget _buildRuleCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required AppTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
