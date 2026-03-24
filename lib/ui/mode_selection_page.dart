import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/themes/themes.dart';
import '../game/stats_manager.dart'; // P1: 导入 GameMode
import '../l10n/app_localizations.dart';
import '../providers/theme/theme_provider.dart';
import 'game/game_page.dart';
import 'rank_page.dart';

/// 游戏模式选择页面
class ModeSelectionPage extends ConsumerStatefulWidget {
  const ModeSelectionPage({super.key});

  @override
  ConsumerState<ModeSelectionPage> createState() => _ModeSelectionPageState();
}

class _ModeSelectionPageState extends ConsumerState<ModeSelectionPage> {
  bool _classicHovered = false;
  bool _timedHovered = false;
  bool _rankHovered = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofNonNull(context);
    final theme = ref.watch(themeManagerProvider);
    
    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        backgroundColor: theme.cardBackground,
        elevation: 0,
        title: Text(
          l10n.gameTitle,
          style: TextStyle(
            color: theme.primaryText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            const Text(
              '🧱',
              style: TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 24),
            
            // 游戏标题
            Text(
              l10n.selectMode,
              style: TextStyle(
                color: theme.primaryText,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            
            // 经典模式按钮
            MouseRegion(
              onEnter: (_) => setState(() => _classicHovered = true),
              onExit: (_) => setState(() => _classicHovered = false),
              child: GestureDetector(
                onTap: () => _startGame(GameMode.classic),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _classicHovered
                          ? [theme.accent, theme.accent.withOpacity(0.8)]
                          : [theme.accent.withOpacity(0.8), theme.accent.withOpacity(0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _classicHovered
                        ? [
                            BoxShadow(
                              color: theme.accent.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // 图标
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            '🎮',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 文字
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.classicMode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.classicModeDesc,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 箭头
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 计时模式按钮
            MouseRegion(
              onEnter: (_) => setState(() => _timedHovered = true),
              onExit: (_) => setState(() => _timedHovered = false),
              child: GestureDetector(
                onTap: () => _startGame(GameMode.timed),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _timedHovered
                          ? [theme.warning, theme.warning.withOpacity(0.8)]
                          : [theme.warning.withOpacity(0.8), theme.warning.withOpacity(0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _timedHovered
                        ? [
                            BoxShadow(
                              color: theme.warning.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // 图标
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            '⏱️',
                            style: TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 文字
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.timedMode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.timedModeDesc,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 箭头
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 排行榜按钮
            MouseRegion(
              onEnter: (_) => setState(() => _rankHovered = true),
              onExit: (_) => setState(() => _rankHovered = false),
              child: GestureDetector(
                onTap: _openLeaderboard,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _rankHovered
                          ? [theme.combo5, theme.combo5.withOpacity(0.8)]
                          : [theme.combo5.withOpacity(0.8), theme.combo5.withOpacity(0.6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _rankHovered
                        ? [
                            BoxShadow(
                              color: theme.combo5.withOpacity(0.5),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      // 图标
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            '🏆',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 文字
                      Expanded(
                        child: Text(
                          l10n.leaderboard,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // 箭头
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white.withOpacity(0.8),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const Spacer(),
            
            // 提示文字
            Text(
              l10n.modeSelectionTip,
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _startGame(GameMode mode) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(mode: mode),
      ),
    );
  }

  void _openLeaderboard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RankPage(),
      ),
    );
  }
}
