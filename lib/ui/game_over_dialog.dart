import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../game/themes/themes.dart';
import '../game/stats_manager.dart';
import '../game/share_util.dart';
import '../core/text_styles.dart';
import '../providers/theme/theme_provider.dart';
import '../l10n/app_localizations.dart';

/// 本局游戏统计数据
class GameStats {
  final int score;
  final int blocksPlaced;
  final int rowsCleared;
  final int colsCleared;
  final int maxCombo;

  const GameStats({
    required this.score,
    required this.blocksPlaced,
    required this.rowsCleared,
    required this.colsCleared,
    required this.maxCombo,
  });
}

/// 游戏结束弹窗内容（优化版 - 带动画、统计、庆祝效果）
class GameOverDialogContent extends ConsumerStatefulWidget {
  final bool isNewRecord;
  final int score;
  final int highScore;
  final GameStats stats;
  final GameMode gameMode; // 游戏模式
  final int? rank; // 排名（如果在前3名）
  final VoidCallback onPlayAgain;
  final String highScoreText;
  final String playAgainText;
  final String gameOverText;

  const GameOverDialogContent({
    super.key,
    required this.isNewRecord,
    required this.score,
    required this.highScore,
    required this.stats,
    required this.gameMode, // 添加游戏模式参数
    this.rank,
    required this.onPlayAgain,
    required this.highScoreText,
    required this.playAgainText,
    required this.gameOverText,
  });

  @override
  ConsumerState<GameOverDialogContent> createState() => _GameOverDialogContentState();
}

class _GameOverDialogContentState extends ConsumerState<GameOverDialogContent>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _scoreScaleAnimation;
  // 庆祝动画控制器
  AnimationController? _celebrationController;
  final List<_Confetti> _confettiList = [];
  // Hover状态
  bool _isPlayAgainHovered = false;
  bool _isShareHovered = false;

  @override
  void initState() {
    super.initState();
    // 主弹窗渐入动画（300ms)
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutBack,
      ),
    );
    // 分数缩放动画
    _scoreScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.15), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    // 新纪录时启动庆祝动画
    if (widget.isNewRecord) {
      _initCelebration();
      _celebrationController = AnimationController(
        duration: const Duration(seconds: 3),
        vsync: this,
      );
      // 生成彩带
      final random = math.Random();
      for (int i = 0; i < 50; i++) {
        _confettiList.add(_Confetti(
          x: random.nextDouble(),
          y: -0.1 - random.nextDouble() * 0.5,
          color: _getRandomColor(random),
          size: 4 + random.nextDouble() * 6,
          speed: 0.3 + random.nextDouble() * 0.7,
          rotation: random.nextDouble() * 360,
          rotationSpeed: (random.nextDouble() - 0.5) * 360,
        ));
      }
      _celebrationController!.addListener(() {
        setState(() {
          for (var confetti in _confettiList) {
            confetti.y += confetti.speed * 0.02;
            confetti.rotation += confetti.rotationSpeed * 0.02;
            confetti.x += (math.sin(confetti.y * 10) * 0.01);
          }
        });
      });
      _celebrationController!.forward();
    }
    _fadeController.forward();
  }

  void _initCelebration() {
    // 庆祝动画初始化逻辑
  }

  Color _getRandomColor(math.Random random) {
    // 使用固定颜色列表，因为此方法在 initState 中调用，不能使用 ref
    final colors = [
      const Color(0xFFFFD700), // 金黄色
      const Color(0xFFFF8C00), // 橙色
      const Color(0xFFFF4444), // 红色
      const Color(0xFF9B59B6), // 紫色
      const Color(0xFF00BCD4), // 青色
      const Color(0xFFFF9800), // 警告色
    ];
    return colors[random.nextInt(colors.length)];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _celebrationController?.dispose();
    super.dispose();
  }

  int get _scoreDiff => widget.highScore - widget.score;

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeManagerProvider);
    final l10n = AppLocalizations.ofNonNull(context);
    
    return Stack(
          children: [
            // 彩带动画层（新纪录时)
            if (widget.isNewRecord && _celebrationController != null)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _celebrationController!,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: _ConfettiPainter(_confettiList, theme),
                    );
                  },
                ),
              ),
            // 主弹窗内容
            AnimatedBuilder(
              animation: _fadeController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: child,
                  ),
                );
              },
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Center(
                  child: Container(
                    width: 340,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: theme.dialogBackground,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 标题区域
                        _buildHeader(theme, l10n),
                        // 本局得分 - 更大更醒目
                        _buildScoreSection(theme, l10n),
                        const SizedBox(height: 16),
                        // 本局统计
                        _buildStatsSection(theme, l10n),
                        const SizedBox(height: 16),
                        // 历史最高分对比
                        _buildHighScoreSection(theme, l10n),
                        const SizedBox(height: 20),
                        // 按钮区域
                        _buildButtons(theme, l10n),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
  }

  Widget _buildHeader(AppTheme theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        children: [
          // 新纪录徽章
          if (widget.isNewRecord) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.combo2, theme.combo3],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.combo2.withOpacity(0.5),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    l10n.newRecord,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 排名显示（前3名）
          if (widget.rank != null && widget.rank! <= 3) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getRankColor(widget.rank!, theme).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getRankColor(widget.rank!, theme),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getRankEmoji(widget.rank!),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${l10n.rankPosition} ${widget.rank} ${l10n.rank}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _getRankColor(widget.rank!, theme),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 游戏结束文字
          if (!widget.isNewRecord)
            Text(
              widget.gameOverText,
              style: AppTextStyles.titleLarge.copyWith(
                color: theme.primaryText,
                fontSize: 26,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreSection(AppTheme theme, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.accent.withOpacity(0.2),
            theme.accent.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.accent.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            l10n.currentScore,
            style: AppTextStyles.bodyMedium.copyWith(
              color: theme.primaryText.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _fadeController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scoreScaleAnimation.value,
                child: Text(
                  '${widget.score}',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: theme.primaryText,
                    fontSize: 56,
                    letterSpacing: 2,
                    shadows: widget.isNewRecord
                        ? [
                            Shadow(
                              color: theme.accent.withOpacity(0.8),
                              blurRadius: 20,
                            ),
                          ]
                        : [
                            Shadow(
                              color: theme.accent.withOpacity(0.5),
                              blurRadius: 10,
                            ),
                          ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(AppTheme theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.dialogItemBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              l10n.currentStats,
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('🧱', l10n.placed, widget.stats.blocksPlaced, theme),
                _buildStatItem('↔️', l10n.clearedRows, widget.stats.rowsCleared, theme),
                _buildStatItem('↕️', l10n.clearedCols, widget.stats.colsCleared, theme),
                _buildStatItem('🔥', l10n.combo, widget.stats.maxCombo, theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, int value, AppTheme theme) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: AppTextStyles.titleSmall.copyWith(
            color: theme.primaryText,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: theme.secondaryText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildHighScoreSection(AppTheme theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // 历史最高分
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.emoji_events,
                color: theme.combo2,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                '${widget.highScoreText}: ${widget.highScore}',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
          // 分数差距（非新纪录时显示)
          if (!widget.isNewRecord && _scoreDiff > 0) ...[
            const SizedBox(height: 8),
            Text(
              '${l10n.diffToHighScore} $_scoreDiff ${l10n.scoreUnit}',
              style: AppTextStyles.bodySmall.copyWith(
                color: theme.combo2.withOpacity(0.8),
                fontSize: 13,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildButtons(AppTheme theme, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 再来一局按钮（主按钮) - hover效果
          MouseRegion(
            onEnter: (_) => setState(() => _isPlayAgainHovered = true),
            onExit: (_) => setState(() => _isPlayAgainHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isPlayAgainHovered
                      ? [theme.accent, theme.accent.withOpacity(0.8)]
                      : [theme.accent, theme.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: _isPlayAgainHovered
                    ? [
                        BoxShadow(
                          color: theme.accent.withOpacity(0.5),
                          blurRadius: 12,
                          spreadRadius: 2,
                        )
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: widget.onPlayAgain,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: theme.primaryText,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  widget.playAgainText,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: theme.primaryText,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 分享按钮 - hover效果
          MouseRegion(
            onEnter: (_) => setState(() => _isShareHovered = true),
            onExit: (_) => setState(() => _isShareHovered = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: _isShareHovered
                    ? theme.secondaryText.withOpacity(0.2)
                    : Colors.transparent,
                border: Border.all(
                  color: _isShareHovered
                      ? theme.secondaryText
                      : theme.secondaryText.withOpacity(0.5),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: OutlinedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  
                  // 调用分享功能
                  final success = await ShareUtil.shareGameResult(
                    score: widget.score,
                    rowsCleared: widget.stats.rowsCleared,
                    colsCleared: widget.stats.colsCleared,
                    gameMode: widget.gameMode,
                    maxCombo: widget.stats.maxCombo,
                  );
                  
                  // 显示分享结果提示
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? l10n.shareSuccess : l10n.shareFailed),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: success ? theme.combo4 : theme.error,
                      ),
                    );
                  }
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: _isShareHovered
                      ? theme.primaryText
                      : theme.secondaryText,
                  side: const BorderSide(color: Colors.transparent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.share, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      l10n.shareScore,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: _isShareHovered ? theme.primaryText : theme.secondaryText,
                        fontSize: 15,
                        fontWeight: _isShareHovered ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRankColor(int rank, AppTheme theme) {
    switch (rank) {
      case 1:
        return theme.combo2;
      case 2:
        return theme.secondaryText;
      case 3:
        return theme.combo3;  // 第3名铜牌色（橙色）
      default:
        return theme.secondaryText;
    }
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '🏅';
    }
  }
}

/// 彩带粒子
class _Confetti {
  double x;
  double y;
  final Color color;
  final double size;
  final double speed;
  double rotation;
  final double rotationSpeed;

  _Confetti({
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speed,
    required this.rotation,
    required this.rotationSpeed,
  });
}

/// 彩带绘制器
class _ConfettiPainter extends CustomPainter {
  final List<_Confetti> confettiList;
  final AppTheme theme;

  _ConfettiPainter(this.confettiList, this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    for (var confetti in confettiList) {
      if (confetti.y > 1.2) continue;

      final paint = Paint()..color = confetti.color;
      final center = Offset(
        confetti.x * size.width,
        confetti.y * size.height,
      );

      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(confetti.rotation * math.pi / 180);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: confetti.size,
          height: confetti.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
