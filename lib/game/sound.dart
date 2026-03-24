import 'package:audioplayers/audioplayers.dart';
import '../core/app_logger.dart';

/// 音效管理器
/// 支持本地音效文件播放，如果文件不存在则静默跳过
class SoundManager {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _bgmPlayer = AudioPlayer(); // 背景音乐播放器
  static bool _enabled = true;
  static bool _bgmEnabled = true; // 背景音乐开关
  static bool _initialized = false;
  
  /// 音效文件路径
  static const String _placeSound = 'assets/sounds/place.mp3';
  static const String _clearSound = 'assets/sounds/clear.mp3';
  static const String _comboSound = 'assets/sounds/combo.mp3';
  static const String _gameOverSound = 'assets/sounds/game_over.mp3';
  static const String _bgmSound = 'assets/sounds/bgm.mp3'; // 背景音乐
  
  /// 音量设置
  static const double _defaultVolume = 0.5;
  static const double _comboVolume = 0.7;
  static const double _bgmVolume = 0.3; // 背景音乐音量较低
  
  /// 初始化音效系统
  static Future<void> init() async {
    if (_initialized) return;
    
    try {
      await _player.setVolume(_defaultVolume);
      _initialized = true;
    } catch (e, stackTrace) {
      // 静默失败
      AppLogger.error('SoundManager初始化失败', e, stackTrace);
    }
  }
  
  /// 切换音效开关
  static void toggle(bool enabled) {
    _enabled = enabled;
  }
  
  /// 获取音效开关状态
  static bool get isEnabled => _enabled;
  
  /// 设置音量
  static Future<void> setVolume(double volume) async {
    try {
      await _player.setVolume(volume);
    } catch (e, stackTrace) {
      // 静默失败
      AppLogger.error('SoundManager设置音量失败', e, stackTrace);
    }
  }
  
  /// 播放放置音效
  static Future<void> playPlace() async {
    if (!_enabled) return;
    await _playSound(_placeSound, _defaultVolume);
  }
  
  /// 播放消除音效
  static Future<void> playClear() async {
    if (!_enabled) return;
    await _playSound(_clearSound, _defaultVolume);
  }
  
  /// 播放连击音效
  static Future<void> playCombo(int comboCount) async {
    if (!_enabled) return;
    await _playSound(_comboSound, _comboVolume);
  }
  
  /// 播放游戏结束音效
  static Future<void> playGameOver() async {
    if (!_enabled) return;
    await _playSound(_gameOverSound, _defaultVolume);
  }
  
  /// 播放背景音乐（循环播放）
  static Future<void> playBGM() async {
    if (!_bgmEnabled) return;
    try {
      await _bgmPlayer.setVolume(_bgmVolume);
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop); // 循环播放
      await _bgmPlayer.play(AssetSource(_bgmSound));
    } catch (e, stackTrace) {
      // 音效文件不存在时静默跳过
      AppLogger.debug('播放背景音乐失败', e, stackTrace);
    }
  }
  
  /// 停止背景音乐
  static Future<void> stopBGM() async {
    try {
      await _bgmPlayer.stop();
    } catch (e, stackTrace) {
      // 静默失败
      AppLogger.debug('停止背景音乐失败', e, stackTrace);
    }
  }
  
  /// 暂停背景音乐
  static Future<void> pauseBGM() async {
    try {
      await _bgmPlayer.pause();
    } catch (e, stackTrace) {
      // 静默失败
      AppLogger.debug('暂停背景音乐失败', e, stackTrace);
    }
  }
  
  /// 恢复背景音乐
  static Future<void> resumeBGM() async {
    if (!_bgmEnabled) return;
    try {
      await _bgmPlayer.resume();
    } catch (e, stackTrace) {
      // 静默失败
      AppLogger.debug('恢复背景音乐失败', e, stackTrace);
    }
  }
  
  /// 切换背景音乐开关
  static void toggleBGM(bool enabled) {
    _bgmEnabled = enabled;
    if (!enabled) {
      stopBGM();
    }
  }
  
  /// 获取背景音乐开关状态
  static bool get isBGMEnabled => _bgmEnabled;
  
  /// 内部播放方法
  static Future<void> _playSound(String assetPath, double volume) async {
    try {
      await _player.setVolume(volume);
      await _player.play(AssetSource(assetPath));
    } catch (e, stackTrace) {
      // 音效文件不存在时静默跳过
      AppLogger.debug('播放音效失败: $assetPath', e, stackTrace);
    }
  }
  
  /// 释放资源
  static void dispose() {
    _player.dispose();
    _bgmPlayer.dispose();
  }
}
