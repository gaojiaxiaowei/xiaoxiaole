import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/themes/themes.dart';
import '../providers/theme/theme_provider.dart';
import '../l10n/app_localizations.dart';
import 'game/game_page.dart';

/// 新手引导页面
class TutorialPage extends ConsumerStatefulWidget {
  const TutorialPage({super.key});

  @override
  ConsumerState<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends ConsumerState<TutorialPage> {
  static const String _keyTutorialShown = 'block_blast_tutorial_shown';

  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<TutorialStep>? _steps;

  /// 获取引导步骤（延迟初始化，需要 context）
  List<TutorialStep> _getSteps(AppLocalizations l10n, AppTheme theme) {
    return [
      TutorialStep(
        icon: Icons.celebration,
        iconColor: theme.combo2,
        title: l10n.tutorialWelcome,
        description: l10n.tutorialWelcomeDesc,
      ),
      TutorialStep(
        icon: Icons.touch_app,
        iconColor: theme.accent,
        title: l10n.tutorialDrag,
        description: l10n.tutorialDragDesc,
      ),
      TutorialStep(
        icon: Icons.grid_on,
        iconColor: theme.accent,
        title: l10n.tutorialClear,
        description: l10n.tutorialClearDesc,
      ),
      TutorialStep(
        icon: Icons.rocket_launch,
        iconColor: theme.warning,
        title: l10n.tutorialReady,
        description: l10n.tutorialReadyDesc,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTutorialShown, true);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GamePage()),
      );
    }
  }

  void _skipTutorial() {
    _completeTutorial();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeManagerProvider).currentTheme;
    final l10n = AppLocalizations.ofNonNull(context);

    // 延迟初始化步骤（需要 context 来获取本地化字符串）
    _steps ??= _getSteps(l10n, theme);

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
            child: Column(
              children: [
                // 跳过按钮
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextButton(
                      onPressed: _skipTutorial,
                      child: Text(
                        l10n.skip,
                        style: TextStyle(
                          color: theme.secondaryText,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                
                // PageView 内容
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _steps!.length,
                    itemBuilder: (context, index) {
                      return _buildTutorialStep(_steps![index], theme);
                    },
                  ),
                ),
                
                // 底部指示器和按钮
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    children: [
                      // 页面指示器
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_steps!.length, (index) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index 
                                  ? theme.accent 
                                  : theme.secondaryText.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // 按钮
                      if (_currentPage == _steps!.length - 1)
                        // 最后一页显示"开始游戏"按钮
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _completeTutorial,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.accent,
                              foregroundColor: theme.primaryText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              l10n.startGame,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      else
                        // 其他页显示"下一步"按钮
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.cardBackground,
                              foregroundColor: theme.primaryText,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              side: BorderSide(
                                color: theme.secondaryText.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              l10n.nextStep,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildTutorialStep(TutorialStep step, AppTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标容器
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.cardBackground,
              borderRadius: BorderRadius.circular(60),
              boxShadow: [
                BoxShadow(
                  color: step.iconColor.withOpacity(0.2),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Icon(
              step.icon,
              size: 60,
              color: step.iconColor,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // 标题
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.primaryText,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 描述
          Text(
            step.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.secondaryText,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

/// 引导步骤数据模型
class TutorialStep {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const TutorialStep({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });
}

/// 检查是否需要显示引导
Future<bool> shouldShowTutorial() async {
  final prefs = await SharedPreferences.getInstance();
  return !(prefs.getBool('block_blast_tutorial_shown') ?? false);
}
