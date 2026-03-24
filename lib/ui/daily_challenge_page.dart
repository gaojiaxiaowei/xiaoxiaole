import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/daily_challenge.dart';
import '../game/themes/theme_manager.dart';
import '../l10n/app_localizations.dart';
import '../providers/daily_challenge/daily_challenge_provider.dart';
import '../providers/theme/theme_provider.dart';

/// 每日挑战页面
class DailyChallengePage extends ConsumerStatefulWidget {
  const DailyChallengePage({super.key});

  @override
  ConsumerState<DailyChallengePage> createState() => _DailyChallengePageState();
}

class _DailyChallengePageState extends ConsumerState<DailyChallengePage> {
  DailyChallenge? _todayChallenge;
  List<DailyChallenge> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 加载挑战数据
  Future<void> _loadData() async {
    try {
      final challengeManager = ref.read(dailyChallengeManagerProvider);
      final challenge = await challengeManager.getTodayChallenge();
      final history = await challengeManager.getChallengeHistory();

      setState(() {
        _todayChallenge = challenge;
        _history = history;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofNonNull(context);
    final theme = ref.watch(themeManagerProvider).currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyChallenge),
        centerTitle: true,
        backgroundColor: theme.cardBackground,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(l10n),
    );
  }

  /// 构建主体内容
  Widget _buildBody(AppLocalizations l10n) {
    final theme = ref.watch(themeManagerProvider).currentTheme;

    if (_todayChallenge == null) {
      return Center(
        child: Text(
          l10n.noChallengeToday,
          style: TextStyle(
            fontSize: 16,
            color: theme.primaryText,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 今日挑战卡片
          _buildTodayChallengeCard(l10n),
          const SizedBox(height: 24),
          // 历史记录
          _buildHistorySection(l10n),
        ],
      ),
    );
  }

  /// 构建今日挑战卡片
  Widget _buildTodayChallengeCard(AppLocalizations l10n) {
    final challenge = _todayChallenge!;
    final theme = ref.watch(themeManagerProvider).currentTheme;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _getChallengeColor(challenge.type).withOpacity(0.3),
            _getChallengeColor(challenge.type).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getChallengeColor(challenge.type),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题和状态
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _getChallengeIcon(challenge.type),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.todayChallenge,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryText,
                    ),
                  ),
                ],
              ),
              if (challenge.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '✓ 已完成',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // 挑战描述
          Text(
            challenge.description,
            style: TextStyle(
              fontSize: 18,
              color: theme.primaryText,
            ),
          ),
          const SizedBox(height: 12),
          // 进度条
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.progress,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.secondaryText,
                    ),
                  ),
                  Text(
                    '${challenge.progress}/${challenge.target}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: challenge.progressPercentage,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getChallengeColor(challenge.type),
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 奖励
          Row(
            children: [
              Icon(
                Icons.card_giftcard,
                size: 16,
                color: theme.secondaryText,
              ),
              const SizedBox(width: 8),
              Text(
                '${l10n.reward}: ${challenge.reward}',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建历史记录部分
  Widget _buildHistorySection(AppLocalizations l10n) {
    final theme = ref.watch(themeManagerProvider).currentTheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.challengeHistory,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.primaryText,
          ),
        ),
        const SizedBox(height: 12),
        if (_history.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                l10n.noHistory,
                style: TextStyle(
                  color: theme.secondaryText,
                ),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _history.length,
            itemBuilder: (context, index) {
              final challenge = _history[index];
              return _buildHistoryItem(challenge);
            },
          ),
      ],
    );
  }

  /// 构建历史记录项
  Widget _buildHistoryItem(DailyChallenge challenge) {
    final theme = ref.watch(themeManagerProvider).currentTheme;
    final dateStr = '${challenge.date.year}-${challenge.date.month.toString().padLeft(2, '0')}-${challenge.date.day.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: challenge.isCompleted
            ? theme.accent.withOpacity(0.1)
            : theme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: challenge.isCompleted ? theme.accent : theme.error,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            _getChallengeIcon(challenge.type),
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  challenge.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.primaryText,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            challenge.isCompleted ? Icons.check_circle : Icons.cancel,
            color: challenge.isCompleted ? theme.accent : theme.error,
            size: 24,
          ),
        ],
      ),
    );
  }

  /// 获取挑战类型对应的颜色
  Color _getChallengeColor(ChallengeType type) {
    final theme = ref.watch(themeManagerProvider).currentTheme;
    switch (type) {
      case ChallengeType.score:
        return theme.warning;
      case ChallengeType.clear:
        return theme.accent;
      case ChallengeType.combo:
        return theme.combo5;
    }
  }

  /// 获取挑战类型对应的图标
  String _getChallengeIcon(ChallengeType type) {
    switch (type) {
      case ChallengeType.score:
        return '⭐';
      case ChallengeType.clear:
        return '💥';
      case ChallengeType.combo:
        return '🔥';
    }
  }
}
