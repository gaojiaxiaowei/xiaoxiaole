// lib/ui/game/game_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game/providers.dart';
import '../../providers/theme/theme_provider.dart';
import '../../game/block.dart';
import '../../game/power_up.dart';
import '../settings_page.dart';
import '../help_page.dart';
import 'controllers/game_controller.dart';
import 'animations/animation_controllers.dart';
import 'widgets/game_grid.dart';
import 'widgets/score_display.dart';
import 'widgets/pause_overlay.dart';
import 'widgets/game_body_widget.dart';

/// 游戏主页面 - 只负责UI布局
class GamePage extends ConsumerStatefulWidget {
  final GameMode mode;

  const GamePage({
    super.key,
    this.mode = GameMode.classic,
  });

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage>
    with TickerProviderStateMixin {
  late final AnimationControllers _controllers;
  late final GameController _gameController;

  @override
  void initState() {
    super.initState();
    _controllers = AnimationControllers(this);
    _gameController = GameController(
      ref,
      this,
      setState,
      _showPlaceDialog,
    );

    // 设置游戏模式
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _gameController.initGameMode(widget.mode);
    });
  }

  @override
  void dispose() {
    _gameController.dispose();
    _controllers.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPaused = ref.watch(isPausedProvider);
    final isGameOver = ref.watch(isGameOverProvider);
    final comboState = ref.watch(comboStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildGameBody(),
          if (isPaused) PauseOverlay(onResume: _gameController.togglePause),
          if (isGameOver && !isPaused) _buildGameOverListener(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildAppBar() {
    final theme = ref.watch(themeManagerProvider).currentTheme;
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text('Block Blast', style: TextStyle(color: theme.primaryText)),
      actions: [
        // 分数显示 - 独立重绘层
        RepaintBoundary(
          key: const ValueKey('score_display'),
          child: ScoreDisplay(
            lastScoreIncrease: _gameController.lastScoreIncrease,
            onAnimationComplete: () {
              _gameController.resetScoreIncrease();
            },
          ),
        ),
        IconButton(
          icon: Icon(
            ref.watch(isPausedProvider) ? Icons.play_arrow : Icons.pause,
            color: theme.primaryText,
          ),
          onPressed: _gameController.togglePause,
        ),
        IconButton(
          icon: Icon(Icons.help_outline, color: theme.primaryText),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HelpPage()),
          ),
        ),
        IconButton(
          icon: Icon(Icons.settings, color: theme.primaryText),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildGameBody() {
    return GameBodyWidget(
      controllers: _controllers,
      gameController: _gameController,
    );
  }

  Widget? _buildFloatingActionButton() {
    final selectedBlock = ref.watch(selectedBlockProvider);
    final isDragging = ref.watch(dragStateProvider).isDragging;
    final theme = ref.watch(themeManagerProvider).currentTheme;

    if (selectedBlock != null && !isDragging) {
      return FloatingActionButton(
        onPressed: _showPlaceDialog,
        backgroundColor: theme.accent,
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  Widget _buildGameOverListener() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && ref.read(isGameOverProvider)) {
        _gameController.showGameOverDialog(context);
      }
    });
    return const SizedBox.shrink();
  }

  // UI 交互方法

  void _showPlaceDialog() {
    final selectedBlock = ref.read(selectedBlockProvider);
    if (selectedBlock == null) return;

    final theme = ref.watch(themeManagerProvider).currentTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackground,
        title: Text('选择放置位置', style: TextStyle(color: theme.primaryText)),
        content: SizedBox(
          width: 320,
          height: 320,
          child: GestureDetector(
            onTapUp: (details) {
              final gridX = (details.localPosition.dx / 40.0).floor();
              final gridY = (details.localPosition.dy / 40.0).floor();
              Navigator.pop(context);
              _gameController.placeBlock(gridX, gridY, selectedBlock);
            },
            child: GameGrid(controllers: _controllers),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('取消', style: TextStyle(color: theme.secondaryText)),
          ),
        ],
      ),
    );
  }
}
