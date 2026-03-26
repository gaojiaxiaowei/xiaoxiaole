import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';
import 'ui/game/game_page.dart';
import 'ui/tutorial_page.dart';
import 'game/themes/themes.dart';
import 'providers/theme/theme_provider.dart';
import 'providers/power_up/power_up_provider.dart';
import 'providers/stats/stats_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: BlockBlastApp(),
    ),
  );
}

class BlockBlastApp extends ConsumerStatefulWidget {
  const BlockBlastApp({super.key});

  @override
  ConsumerState<BlockBlastApp> createState() => _BlockBlastAppState();
}

class _BlockBlastAppState extends ConsumerState<BlockBlastApp> {
  @override
  void initState() {
    super.initState();

    // 同步预初始化 PowerUpManager，确保全局实例可用
    // 这必须在 GamePage 创建之前完成，否则 GameController 会崩溃
    // ignore: unused_result
    ref.read(powerUpManagerProvider);

    // 初始化主题管理器（异步）
    Future.microtask(() async {
      await ref.read(themeManagerProvider).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ref.watch(themeManagerProvider);
    
    return MaterialApp(
      title: 'Block Blast',
      theme: themeManager.currentTheme.toThemeData(),
      // 国际化配置
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('zh', 'CN'), // 默认中文
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// 启动页面 - Logo动画 + 检查是否需要显示引导
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _titleOpacity;
  
  bool _animationComplete = false;
  bool _tutorialCheckComplete = false;
  bool _showTutorial = false;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.elasticOut),
      ),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
      ),
    );

    // 启动动画
    _controller.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _animationComplete = true;
        _tryNavigate();
      });
    });

    // 并行检查引导状态
    _checkTutorial();
  }

  Future<void> _checkTutorial() async {
    _showTutorial = await shouldShowTutorial();
    _tutorialCheckComplete = true;
    _tryNavigate();
  }

  void _tryNavigate() {
    if (_animationComplete && _tutorialCheckComplete && mounted) {
      if (_showTutorial) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TutorialPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GamePage()),
        );
      }
    }
  }

  void _skipSplash() {
    _controller.stop();
    // 立即完成动画和检查
    _animationComplete = true;
    _tryNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofNonNull(context);
    final currentTheme = ref.watch(currentThemeProvider);
    
    return GestureDetector(
      onTap: _skipSplash,
      child: Scaffold(
        backgroundColor: currentTheme.background,
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo with fade-in and scale animation
                  Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.scale(
                      scale: _logoScale.value,
                      child: const Text(
                        '🧱',
                        style: TextStyle(fontSize: 100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Title with fade-in animation
                  Opacity(
                    opacity: _titleOpacity.value,
                    child: Text(
                      l10n.gameTitle,
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: currentTheme.primaryText,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 80),
                  // Powered by text
                  Opacity(
                    opacity: _titleOpacity.value,
                    child: Text(
                      'Powered by Flutter',
                      style: TextStyle(
                        fontSize: 14,
                        color: currentTheme.secondaryText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tap to skip hint
                  Opacity(
                    opacity: _titleOpacity.value * 0.7,
                    child: Text(
                      'Tap anywhere to skip',
                      style: TextStyle(
                        fontSize: 12,
                        color: currentTheme.secondaryText.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
