import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_service.dart';
import '../api/api_models.dart';
import '../game/themes/theme_manager.dart';
import '../l10n/app_localizations.dart';
import '../providers/theme/theme_provider.dart';

/// 排行榜页面
class RankPage extends ConsumerStatefulWidget {
  const RankPage({super.key});

  @override
  ConsumerState<RankPage> createState() => _RankPageState();
}

class _RankPageState extends ConsumerState<RankPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LeaderboardData? _globalData;
  LeaderboardData? _regionData;
  bool _isLoadingGlobal = true;
  bool _isLoadingRegion = false;
  String? _errorGlobal;
  String? _errorRegion;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadGlobalData();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && _regionData == null && !_isLoadingRegion) {
      _loadRegionData();
    }
  }

  Future<void> _loadGlobalData() async {
    setState(() {
      _isLoadingGlobal = true;
      _errorGlobal = null;
    });

    try {
      final apiService = ApiService.instance;
      final response = await apiService.getLeaderboard(type: 'global');

      if (response.isSuccess && response.data != null) {
        setState(() {
          _globalData = response.data;
          _isLoadingGlobal = false;
        });
      } else {
        setState(() {
          _errorGlobal = response.message;
          _isLoadingGlobal = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorGlobal = e.toString();
        _isLoadingGlobal = false;
      });
    }
  }

  Future<void> _loadRegionData() async {
    setState(() {
      _isLoadingRegion = true;
      _errorRegion = null;
    });

    try {
      final apiService = ApiService.instance;
      final response = await apiService.getLeaderboard(type: 'region');

      if (response.isSuccess && response.data != null) {
        setState(() {
          _regionData = response.data;
          _isLoadingRegion = false;
        });
      } else {
        setState(() {
          _errorRegion = response.message;
          _isLoadingRegion = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorRegion = e.toString();
        _isLoadingRegion = false;
      });
    }
  }

  Future<void> _refreshCurrentTab() async {
    if (_tabController.index == 0) {
      await _loadGlobalData();
    } else {
      await _loadRegionData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofNonNull(context);
    final theme = ref.watch(themeManagerProvider).currentTheme;

    return Scaffold(
      backgroundColor: theme.background,
      appBar: AppBar(
        title: Text(
          l10n.leaderboard,
          style: TextStyle(
            color: theme.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: theme.cardBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.primaryText),
            onPressed: _refreshCurrentTab,
            tooltip: l10n.refresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.accent,
          indicatorWeight: 3,
          labelColor: theme.accent,
          unselectedLabelColor: theme.secondaryText,
          labelStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          tabs: [
            Tab(text: l10n.globalLeaderboard),
            Tab(text: l10n.regionLeaderboard),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTabContent(
            isLoading: _isLoadingGlobal,
            error: _errorGlobal,
            data: _globalData,
            onRetry: _loadGlobalData,
            l10n: l10n,
          ),
          _buildTabContent(
            isLoading: _isLoadingRegion,
            error: _errorRegion,
            data: _regionData,
            onRetry: _loadRegionData,
            l10n: l10n,
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent({
    required bool isLoading,
    required String? error,
    required LeaderboardData? data,
    required VoidCallback onRetry,
    required AppLocalizations l10n,
  }) {
    final theme = ref.watch(themeManagerProvider).currentTheme;

    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: theme.accent),
            const SizedBox(height: 16),
            Text(
              l10n.loading,
              style: TextStyle(color: theme.secondaryText),
            ),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.error),
            const SizedBox(height: 16),
            Text(
              error,
              style: TextStyle(color: theme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.accent,
              ),
              child: Text(l10n.refresh),
            ),
          ],
        ),
      );
    }

    if (data == null || data.leaderboard.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64, color: theme.secondaryText),
            const SizedBox(height: 16),
            Text(
              l10n.noLeaderboardData,
              style: TextStyle(color: theme.secondaryText),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.leaderboard.length,
            itemBuilder: (context, index) {
              final entry = data.leaderboard[index];
              return _buildRankItem(entry, data.myRank);
            },
          ),
        ),
        // 底部个人排名
        _buildMyRankCard(data, l10n),
      ],
    );
  }

  Widget _buildRankItem(LeaderboardEntry entry, int myRank) {
    final theme = ref.watch(themeManagerProvider).currentTheme;
    final isMe = entry.rank == myRank;
    final rankColor = _getRankColor(entry.rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe
            ? theme.accent.withOpacity(0.15)
            : theme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: theme.accent, width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 排名徽章
          _buildRankBadge(entry.rank, rankColor),
          const SizedBox(width: 12),
          // 头像占位
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: theme.cardBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                entry.nickname.isNotEmpty ? entry.nickname[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryText,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 昵称
          Expanded(
            child: Text(
              entry.nickname,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                color: theme.primaryText,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 分数
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _formatScore(entry.score),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankBadge(int rank, Color color) {
    String badgeText;
    Widget? badgeIcon;

    if (rank == 1) {
      badgeIcon = const Text('🥇', style: TextStyle(fontSize: 28));
      badgeText = '';
    } else if (rank == 2) {
      badgeIcon = const Text('🥈', style: TextStyle(fontSize: 28));
      badgeText = '';
    } else if (rank == 3) {
      badgeIcon = const Text('🥉', style: TextStyle(fontSize: 28));
      badgeText = '';
    } else {
      badgeText = '#$rank';
    }

    return SizedBox(
      width: 44,
      height: 44,
      child: Center(
        child: badgeIcon ??
            Text(
              badgeText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
      ),
    );
  }

  Widget _buildMyRankCard(LeaderboardData data, AppLocalizations l10n) {
    final theme = ref.watch(themeManagerProvider).currentTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 我的排名
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.accent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.myRank,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#${data.myRank}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.accent,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 我的分数
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.score,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatScore(data.myScore),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryText,
                    ),
                  ),
                ],
              ),
            ),
            // 刷新按钮
            IconButton(
              onPressed: _refreshCurrentTab,
              icon: Icon(Icons.refresh, color: theme.accent),
              tooltip: l10n.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    final theme = ref.watch(themeManagerProvider).currentTheme;
    
    switch (rank) {
      case 1:
        return theme.combo2;  // 金色用黄色
      case 2:
        return theme.secondaryText;  // 银色用次要文字色
      case 3:
        return theme.warning;  // 铜色用橙色
      default:
        return theme.primaryText;
    }
  }

  String _formatScore(int score) {
    if (score >= 1000000) {
      return '${(score / 1000000).toStringAsFixed(1)}M';
    } else if (score >= 1000) {
      return '${(score / 1000).toStringAsFixed(1)}K';
    }
    return score.toString();
  }
}
