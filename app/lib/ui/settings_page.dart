import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../game/sound.dart';
import '../game/haptic.dart';
import '../game/theme.dart';
import '../game/themes/themes.dart';
import '../game/stats_manager.dart';
import '../ad/ad_manager.dart';
import '../providers/stats/stats_provider.dart';
import '../providers/ad/ad_provider.dart';
import '../providers/theme/theme_provider.dart';
import 'help_page.dart';
import 'stats_page.dart';
import '../core/text_styles.dart';

/// 难度等级
enum Difficulty {
  easy,
  normal,
  hard,
}

/// 难度显示名称
extension DifficultyExtension on Difficulty {
  String get displayName {
    switch (this) {
      case Difficulty.easy:
        return '简单';
      case Difficulty.normal:
        return '普通';
      case Difficulty.hard:
        return '困难';
    }
  }
}

/// 设置页面
class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  // 游戏设置
  bool _showGridLines = true;
  bool _animationEnabled = true;
  Difficulty _difficulty = Difficulty.normal;

  // 音效设置
  bool _soundEnabled = true;
  bool _bgmEnabled = true;
  bool _hapticEnabled = true;
  double _volume = 0.5;

  // 主题设置
  int _currentThemeIndex = 0;

  // 广告设置
  bool _adEnabled = true;
  bool _adSimulationMode = true;

  @override
  void initState() {
    super.initState();
    final themeManager = ref.read(themeManagerProvider);
    _currentThemeIndex = themeManager.currentThemeIndex;
    themeManager.addListener(_onThemeChanged);
    _loadSettings();
  }

  @override
  void dispose() {
    ref.read(themeManagerProvider).removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {
      _currentThemeIndex = ref.read(themeManagerProvider).currentThemeIndex;
    });
  }

  // 加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 游戏设置
      _showGridLines = prefs.getBool('block_blast_show_grid_lines') ?? true;
      _animationEnabled = prefs.getBool('block_blast_animation_enabled') ?? true;
      final difficultyIndex = prefs.getInt('block_blast_difficulty') ?? 1;
      _difficulty = Difficulty.values[difficultyIndex];

      // 音效设置
      _soundEnabled = prefs.getBool('block_blast_sound_enabled') ?? true;
      _bgmEnabled = prefs.getBool('block_blast_bgm_enabled') ?? true;
      _hapticEnabled = prefs.getBool('block_blast_haptic_enabled') ?? true;
      _volume = prefs.getDouble('block_blast_volume') ?? 0.5;
      
      // 广告设置
      _adEnabled = prefs.getBool('block_blast_ad_enabled') ?? true;
      _adSimulationMode = prefs.getBool('block_blast_ad_simulation_mode') ?? true;
    });

    // 同步到 SoundManager 和 HapticManager
    SoundManager.toggle(_soundEnabled);
    SoundManager.toggleBGM(_bgmEnabled);
    HapticManager.toggle(_hapticEnabled);
    // Bug 1 修复:加载时也应用音量设置
    SoundManager.setVolume(_volume);

    // 同步广告设置到 AdManager
    final adManager = ref.read(adManagerProvider);
    adManager.setAdEnabled(_adEnabled);
    adManager.setSimulationMode(_adSimulationMode);
  }

  // 保存显示网格线设置
  Future<void> _saveGridLinesSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('block_blast_show_grid_lines', value);
    setState(() {
      _showGridLines = value;
    });
  }

  // 保存动画效果设置
  Future<void> _saveAnimationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('block_blast_animation_enabled', value);
    setState(() {
      _animationEnabled = value;
    });
  }

  // 保存难度设置
  Future<void> _saveDifficultySetting(Difficulty value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('block_blast_difficulty', value.index);
    setState(() {
      _difficulty = value;
    });
  }

  // 保存音效设置
  Future<void> _saveSoundSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('block_blast_sound_enabled', value);
    SoundManager.toggle(value);
    setState(() {
      _soundEnabled = value;
    });
  }

  // 保存背景音乐设置
  Future<void> _saveBGMSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('block_blast_bgm_enabled', value);
    SoundManager.toggleBGM(value);
    if (value) {
      SoundManager.playBGM();
    } else {
      SoundManager.stopBGM();
    }
    setState(() {
      _bgmEnabled = value;
    });
  }

  // 保存震动设置
  Future<void> _saveHapticSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('block_blast_haptic_enabled', value);
    HapticManager.toggle(value);
    setState(() {
      _hapticEnabled = value;
    });
  }

  // 保存音量设置
  Future<void> _saveVolumeSetting(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('block_blast_volume', value);
    // Bug 1 修复：将音量应用到 SoundManager
    SoundManager.setVolume(value);
    setState(() {
      _volume = value;
    });
  }

  // 保存广告启用设置
  Future<void> _saveAdEnabledSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('block_blast_ad_enabled', value);
    ref.read(adManagerProvider).setAdEnabled(value);
    setState(() {
      _adEnabled = value;
    });
  }

  // 保存广告模拟模式设置
  Future<void> _saveAdSimulationModeSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('block_blast_ad_simulation_mode', value);
    ref.read(adManagerProvider).setSimulationMode(value);
    setState(() {
      _adSimulationMode = value;
    });
  }

  // 保存主题设置
  Future<void> _saveThemeSetting(int index) async {
    await ref.read(themeManagerProvider).setThemeByIndex(index);
  }

  // 重置最高分
  Future<void> _resetHighScore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameTheme.dialogBackground,
        title: Text(
          '确认重置',
          style: TextStyle(color: GameTheme.primaryText),
        ),
        content: Text(
          '确定要重置最高分吗？此操作不可撤销。',
          style: TextStyle(color: GameTheme.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '取消',
              style: TextStyle(color: GameTheme.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '确定',
              style: TextStyle(color: GameTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('block_blast_high_score');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('最高分已重置'),
            backgroundColor: GameTheme.cardBackground,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // 清除所有数据
  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: GameTheme.dialogBackground,
        title: Text(
          '确认清除',
          style: TextStyle(color: GameTheme.primaryText),
        ),
        content: Text(
          '确定要清除所有游戏数据吗？\n\n这将删除：\n• 最高分记录\n• 游戏统计数据\n• 分数历史\n\n此操作不可撤销。',
          style: TextStyle(color: GameTheme.secondaryText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '取消',
              style: TextStyle(color: GameTheme.secondaryText),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              '确定清除',
              style: TextStyle(color: GameTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final prefs = await SharedPreferences.getInstance();
      // 清除所有游戏相关数据
      await prefs.remove('block_blast_high_score');
      await ref.read(statsManagerProvider).resetAllStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('所有数据已清除'),
            backgroundColor: GameTheme.cardBackground,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // 导出游戏数据（预留）
  Future<void> _exportData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('导出功能即将上线'),
        backgroundColor: GameTheme.cardBackground,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = ref.watch(themeManagerProvider);
    return ListenableBuilder(
      listenable: themeManager,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: GameTheme.background,
          appBar: AppBar(
            backgroundColor: GameTheme.cardBackground,
            title: Text(
              '设置',
              style: TextStyle(color: GameTheme.primaryText),
            ),
            iconTheme: IconThemeData(color: GameTheme.primaryText),
          ),
          body: ListView(
            children: [
              // ===== 游戏说明 & 统计 =====
              _buildSectionHeader('信息'),
              _buildSettingItem(
                icon: Icons.help_outline,
                title: '游戏说明',
                subtitle: '了解游戏规则和操作方法',
                trailing: Icon(
                  Icons.chevron_right,
                  color: GameTheme.secondaryText,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const HelpPage()),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.bar_chart,
                title: '游戏统计',
                subtitle: '查看游戏数据和成就',
                trailing: Icon(
                  Icons.chevron_right,
                  color: GameTheme.secondaryText,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatsPage()),
                  );
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.history,
                title: '历史记录',
                subtitle: '查看最近10局游戏成绩',
                trailing: Icon(
                  Icons.chevron_right,
                  color: GameTheme.secondaryText,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const StatsPage()),
                  );
                },
              ),
              
              // ===== 主题设置 =====
              _buildSectionHeader('主题设置'),
              _buildThemeSelector(),
              
              // ===== 游戏设置 =====
              _buildSectionHeader('游戏设置'),
              _buildSettingItem(
                icon: Icons.grid_on,
                title: '显示网格线',
                subtitle: '在游戏网格上显示辅助线',
                trailing: Switch(
                  value: _showGridLines,
                  onChanged: _saveGridLinesSetting,
                  activeColor: GameTheme.accent,
                ),
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.animation,
                title: '动画效果',
                subtitle: '启用方块放置和消除动画',
                trailing: Switch(
                  value: _animationEnabled,
                  onChanged: _saveAnimationSetting,
                  activeColor: GameTheme.accent,
                ),
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.tune,
                title: '游戏难度',
                subtitle: '当前:${_difficulty.displayName}',
                trailing: _buildDifficultySelector(),
              ),
              
              // ===== 广告设置 =====
              _buildSectionHeader('广告设置'),
              _buildSettingItem(
                icon: Icons.ad_units,
                title: '启用广告',
                subtitle: '在游戏中展示广告获取道具奖励',
                trailing: Switch(
                  value: _adEnabled,
                  onChanged: _saveAdEnabledSetting,
                  activeColor: GameTheme.accent,
                ),
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.developer_mode,
                title: '开发模式',
                subtitle: '使用模拟广告（不展示真实广告）',
                trailing: Switch(
                  value: _adSimulationMode,
                  onChanged: _saveAdSimulationModeSetting,
                  activeColor: GameTheme.accent,
                ),
              ),
              
              // ===== 音效设置 =====
              _buildSectionHeader('音效设置'),
              _buildSettingItem(
                icon: Icons.volume_up,
                title: '音效',
                subtitle: '控制游戏音效',
                trailing: Switch(
                  value: _soundEnabled,
                  onChanged: _saveSoundSetting,
                  activeColor: GameTheme.accent,
                ),
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.music_note,
                title: '背景音乐',
                subtitle: '控制背景音乐播放',
                trailing: Switch(
                  value: _bgmEnabled,
                  onChanged: _saveBGMSetting,
                  activeColor: GameTheme.accent,
                ),
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.vibration,
                title: '震动',
                subtitle: '控制游戏震动反馈',
                trailing: Switch(
                  value: _hapticEnabled,
                  onChanged: _saveHapticSetting,
                  activeColor: GameTheme.accent,
                ),
              ),
              _buildDivider(),
              _buildVolumeSlider(),
              
              // ===== 数据管理 =====
              _buildSectionHeader('数据管理'),
              _buildSettingItem(
                icon: Icons.refresh,
                title: '重置最高分',
                subtitle: '清除本地存储的最高分记录',
                trailing: TextButton(
                  onPressed: _resetHighScore,
                  style: TextButton.styleFrom(
                    foregroundColor: GameTheme.warning,
                  ),
                  child: const Text('重置'),
                ),
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.delete_forever,
                title: '清除所有数据',
                subtitle: '删除所有游戏数据和统计',
                trailing: TextButton(
                  onPressed: _clearAllData,
                  style: TextButton.styleFrom(
                    foregroundColor: GameTheme.error,
                  ),
                  child: const Text('清除'),
                ),
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.file_download,
                title: '导出游戏数据',
                subtitle: '导出游戏进度和统计数据',
                trailing: TextButton(
                  onPressed: _exportData,
                  style: TextButton.styleFrom(
                    foregroundColor: GameTheme.accent,
                  ),
                  child: const Text('导出'),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 返回游戏按钮
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('返回游戏'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GameTheme.accent,
                    foregroundColor: GameTheme.primaryText,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // 构建分组标题
  Widget _buildSectionHeader(String title) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: GameTheme.accent,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 构建分隔线
  Widget _buildDivider() {
    return Divider(
      color: GameTheme.gridBorder,
      height: 1,
    );
  }

  // 构建主题选择器
  Widget _buildThemeSelector() {
    return Container(
      color: GameTheme.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.palette,
                color: GameTheme.secondaryText,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                '游戏主题',
                style: TextStyle(
                  color: GameTheme.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 主题卡片列表
          Row(
            children: ThemeManager.availableThemes.asMap().entries.map((entry) {
              final index = entry.key;
              final theme = entry.value;
              final isSelected = _currentThemeIndex == index;
              
              return Expanded(
                child: GestureDetector(
                  onTap: () => _saveThemeSetting(index),
                  child: Container(
                    margin: EdgeInsets.only(
                      right: index < ThemeManager.availableThemes.length - 1 ? 8 : 0,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                        ? GameTheme.accent.withOpacity(0.2)
                        : GameTheme.dialogItemBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? GameTheme.accent : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        // 主题预览色块
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: theme.background,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.accent,
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // 小方块预览
                              Positioned(
                                left: 6,
                                top: 6,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: theme.accent,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 6,
                                bottom: 6,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: theme.blockColors.values.first,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // 主题名称
                        Text(
                          theme.displayName,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected ? GameTheme.accent : GameTheme.primaryText,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 构建难度选择器
  Widget _buildDifficultySelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: GameTheme.dialogItemBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: Difficulty.values.map((d) {
          final isSelected = _difficulty == d;
          return GestureDetector(
            onTap: () => _saveDifficultySetting(d),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? GameTheme.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                d.displayName,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? GameTheme.primaryText : GameTheme.secondaryText,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 构建音量滑块
  Widget _buildVolumeSlider() {
    return Container(
      color: GameTheme.cardBackground,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.volume_down,
            color: GameTheme.secondaryText,
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '音量',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: GameTheme.primaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: GameTheme.accent,
                    inactiveTrackColor: GameTheme.dialogItemBackground,
                    thumbColor: GameTheme.accent,
                    overlayColor: GameTheme.accent.withOpacity(0.2),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _volume,
                    onChanged: _saveVolumeSetting,
                    min: 0.0,
                    max: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '${(_volume * 100).round()}%',
              style: AppTextStyles.bodySmall.copyWith(
                color: GameTheme.secondaryText,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  // 构建设置项
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: GameTheme.cardBackground,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: GameTheme.secondaryText,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: GameTheme.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: GameTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
