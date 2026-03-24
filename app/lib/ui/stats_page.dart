import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/theme/theme_provider.dart';
import 'package:intl/intl.dart';
import '../game/stats_manager.dart';
import '../game/themes/themes.dart';
import '../providers/stats/stats_provider.dart';
import '../l10n/app_localizations.dart';

/// 游戏统计页面
class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  Map<String, int> _stats = {};
  List<ScoreRecord> _scoreHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  // 加载统计数据
  Future<void> _loadStats() async {
    final statsManager = ref.read(statsManagerProvider);
    final stats = await statsManager.getAllStats();
    final history = await statsManager.getScoreHistory();
    setState(() {
      _stats = stats;
      _scoreHistory = history;
      _isLoading = false;
    });
  }

  // 重置统计数据
  Future<void> _resetStats() async {
    final theme = ref.read(themeManagerProvider);
    final l10n = AppLocalizations.ofNonNull(context);
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackground,
        title: Text(
          l10n.confirmReset,
          style: TextStyle(color: theme.primaryText),
        ),
        content: Text(
          l10n.confirmResetDesc,
          style: TextStyle(color: theme.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: theme.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              l10n.confirm,
              style: TextStyle(color: theme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(statsManagerProvider).resetAllStats();
      await _loadStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.statsResetSuccess),
            backgroundColor: theme.cardBackground,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // 格式化游戏时长（秒 -> 分钟）
  String _formatPlayTime(int seconds, AppLocalizations l10n) {
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '$minutes ${l10n.minutes}';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return '$hours ${l10n.hours} $remainingMinutes ${l10n.minutes}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeManagerProvider);
    final l10n = AppLocalizations.ofNonNull(context);
    
    return Scaffold(
          backgroundColor: theme.background,
          appBar: AppBar(
            backgroundColor: theme.cardBackground,
            title: Text(
              l10n.gameStats,
              style: TextStyle(color: theme.primaryText),
            ),
            iconTheme: IconThemeData(color: theme.primaryText),
            actions: [
              IconButton(
                icon: Icon(Icons.refresh, color: theme.primaryText),
                onPressed: _resetStats,
                tooltip: l10n.resetStats,
              ),
            ],
          ),
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: theme.accent,
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 总游戏局数
                    _buildStatCard(
                      icon: Icons.games,
                      iconColor: theme.accent,
                      title: l10n.totalGames,
                      value: '${_stats['totalGames'] ?? 0}',
                      subtitle: l10n.gamesUnit,
                      theme: theme,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 最高分
                    _buildStatCard(
                      icon: Icons.emoji_events,
                      iconColor: theme.combo2,
                      title: l10n.highestScore,
                      value: '${_stats['highScore'] ?? 0}',
                      subtitle: l10n.scoreUnit,
                      theme: theme,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 累计消除行数
                    _buildStatCard(
                      icon: Icons.view_stream,
                      iconColor: theme.accent,
                      title: l10n.totalRowsCleared,
                      value: '${_stats['totalRowsCleared'] ?? 0}',
                      subtitle: l10n.rowsUnit,
                      theme: theme,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 累计消除列数
                    _buildStatCard(
                      icon: Icons.view_column,
                      iconColor: theme.combo5,
                      title: l10n.totalColsCleared,
                      value: '${_stats['totalColsCleared'] ?? 0}',
                      subtitle: l10n.colsUnit,
                      theme: theme,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 最高连击
                    _buildStatCard(
                      icon: Icons.bolt,
                      iconColor: theme.warning,
                      title: l10n.highestCombo,
                      value: '${_stats['maxCombo'] ?? 0}',
                      subtitle: l10n.comboUnit,
                      theme: theme,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 总游戏时长
                    _buildStatCard(
                      icon: Icons.schedule,
                      iconColor: theme.error,
                      title: l10n.totalPlayTime,
                      value: _formatPlayTime(_stats['totalPlayTime'] ?? 0, l10n),
                      subtitle: '',
                      theme: theme,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // 分数历史记录标题
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        children: [
                          Icon(Icons.history, color: theme.combo3, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.recent10Games,
                            style: TextStyle(
                              color: theme.primaryText,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // 分数历史记录列表
                    if (_scoreHistory.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: theme.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            l10n.noGameRecords,
                            style: TextStyle(color: theme.secondaryText, fontSize: 14),
                          ),
                        ),
                      )
                    else
                      ..._buildScoreHistoryList(theme, l10n),
                    
                    const SizedBox(height: 12),
                    
                    // 趋势图（如果有足够数据）
                    if (_scoreHistory.length >= 3) _buildTrendChart(theme, l10n),
                    
                    const SizedBox(height: 32),
                    
                    // 返回按钮
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back),
                      label: Text(l10n.backToSettings),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.accent,
                        foregroundColor: theme.primaryText,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                );
      }

  // 构建统计卡片
  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required AppTheme theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 图标
          Container(
            width: 48,
            height: 48,
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
          
          // 标题和副标题
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      value,
                      style: TextStyle(
                        color: theme.primaryText,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          subtitle,
                          style: TextStyle(
                            color: theme.secondaryText,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 构建分数历史记录列表
  List<Widget> _buildScoreHistoryList(AppTheme theme, AppLocalizations l10n) {
    return _scoreHistory.asMap().entries.map((entry) {
      final index = entry.key;
      final record = entry.value;
      final isHighest = _scoreHistory.isNotEmpty && 
          record.score == _scoreHistory.map((r) => r.score).reduce((a, b) => a > b ? a : b);
      
      return Container(
        margin: EdgeInsets.only(top: index == 0 ? 0 : 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: isHighest 
              ? Border.all(color: theme.combo2.withOpacity(0.5), width: 1)
              : null,
        ),
        child: Row(
          children: [
            // 排名
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: index == 0 
                    ? theme.combo2.withOpacity(0.2)
                    : theme.secondaryText.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  '#${index + 1}',
                  style: TextStyle(
                    color: index == 0 ? theme.combo2 : theme.secondaryText,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 12),
            
            // 分数
            Expanded(
              child: Text(
                '${record.score} ${l10n.scoreUnit}',
                style: TextStyle(
                  color: isHighest ? theme.combo2 : theme.primaryText,
                  fontSize: 16,
                  fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            // 消除统计
            Row(
              children: [
                Icon(Icons.swap_horiz, size: 14, color: theme.accent.withOpacity(0.7)),
                const SizedBox(width: 2),
                Text(
                  '${record.rowsCleared}',
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.swap_vert, size: 14, color: theme.combo5.withOpacity(0.7)),
                const SizedBox(width: 2),
                Text(
                  '${record.colsCleared}',
                  style: TextStyle(
                    color: theme.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(width: 12),
            
            // 日期
            Text(
              _formatDate(record.date, l10n),
              style: TextStyle(
                color: theme.secondaryText,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  // 格式化日期
  String _formatDate(DateTime date, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return '${l10n.today} ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays == 1) {
      return '${l10n.yesterday} ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}${l10n.daysAgo}';
    } else {
      return DateFormat('MM-dd HH:mm').format(date);
    }
  }

  // 构建趋势图（简单折线图）
  Widget _buildTrendChart(AppTheme theme, AppLocalizations l10n) {
    final maxScore = _scoreHistory.map((r) => r.score).reduce((a, b) => a > b ? a : b);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: theme.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                l10n.scoreTrend,
                style: TextStyle(
                  color: theme.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 简单的柱状图
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _scoreHistory.reversed.map((record) {
                final barHeight = (record.score / maxScore) * 80.0;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barHeight.clamp(4.0, 80.0),
                          decoration: BoxDecoration(
                            color: theme.accent.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 图例
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_scoreHistory.length}${l10n.rounds}',
                style: TextStyle(color: theme.secondaryText, fontSize: 11),
              ),
              Text(
                '${l10n.highest}: $maxScore',
                style: TextStyle(color: theme.combo2, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
