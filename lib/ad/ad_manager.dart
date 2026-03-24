import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ad_service.dart';

/// 道具奖励类型
enum PowerUpRewardType {
  random, // 随机道具
  bomb, // 炸弹
  refresh, // 刷新
  undo, // 撤销
}

/// 广告配置
class AdConfig {
  /// 是否启用广告
  final bool enabled;
  
  /// 是否启用模拟模式（开发阶段使用）
  final bool simulationMode;
  
  /// 插屏广告展示概率（0.0 - 1.0）
  final double interstitialProbability;
  
  /// 插屏广告最小间隔（游戏局数）
  final int interstitialMinInterval;
  
  /// 激励视频广告奖励的道具类型
  final PowerUpRewardType rewardedPowerUpType;

  const AdConfig({
    this.enabled = true,
    this.simulationMode = true,
    this.interstitialProbability = 0.3,
    this.interstitialMinInterval = 3,
    this.rewardedPowerUpType = PowerUpRewardType.random,
  });

  /// 默认配置
  static const AdConfig defaultConfig = AdConfig();

  /// 从 SharedPreferences 加载配置
  static Future<AdConfig> load(SharedPreferences prefs) async {
    return AdConfig(
      enabled: prefs.getBool('block_blast_ad_enabled') ?? true,
      simulationMode: prefs.getBool('block_blast_ad_simulation_mode') ?? true,
      interstitialProbability: prefs.getDouble('block_blast_ad_interstitial_probability') ?? 0.3,
      interstitialMinInterval: prefs.getInt('block_blast_ad_interstitial_min_interval') ?? 3,
      rewardedPowerUpType: PowerUpRewardType.values[
        prefs.getInt('block_blast_ad_rewarded_power_up_type') ?? 0
      ],
    );
  }

  /// 保存配置到 SharedPreferences
  Future<void> save(SharedPreferences prefs) async {
    await prefs.setBool('block_blast_ad_enabled', enabled);
    await prefs.setBool('block_blast_ad_simulation_mode', simulationMode);
    await prefs.setDouble('block_blast_ad_interstitial_probability', interstitialProbability);
    await prefs.setInt('block_blast_ad_interstitial_min_interval', interstitialMinInterval);
    await prefs.setInt('block_blast_ad_rewarded_power_up_type', rewardedPowerUpType.index);
  }

  /// 复制并修改配置
  AdConfig copyWith({
    bool? enabled,
    bool? simulationMode,
    double? interstitialProbability,
    int? interstitialMinInterval,
    PowerUpRewardType? rewardedPowerUpType,
  }) {
    return AdConfig(
      enabled: enabled ?? this.enabled,
      simulationMode: simulationMode ?? this.simulationMode,
      interstitialProbability: interstitialProbability ?? this.interstitialProbability,
      interstitialMinInterval: interstitialMinInterval ?? this.interstitialMinInterval,
      rewardedPowerUpType: rewardedPowerUpType ?? this.rewardedPowerUpType,
    );
  }
}

/// 广告状态
class AdState {
  /// 激励视频广告是否正在展示
  bool isShowingRewardedAd = false;
  
  /// 插屏广告是否正在展示
  bool isShowingInterstitialAd = false;
  
  /// 激励视频广告是否已加载
  bool isRewardedAdLoaded = false;
  
  /// 插屏广告是否已加载
  bool isInterstitialAdLoaded = false;
}

/// 广告管理器
/// 
/// 负责管理广告配置、广告展示策略和广告服务
class AdManager with ChangeNotifier {
  // 全局实例（用于兼容静态访问层）
  static AdManager? _globalInstance;
  
  // 构造函数（移除单例模式）
  AdManager();
  
  /// 设置全局实例（由 Provider 初始化时调用）
  static void setGlobalInstance(AdManager instance) {
    _globalInstance = instance;
  }
  
  /// 获取全局实例（用于兼容静态访问层）
  static AdManager get instance {
    if (_globalInstance == null) {
      throw StateError(
        'AdManager not initialized. '
        'Make sure the app is wrapped in ProviderScope and the provider is accessed at least once.'
      );
    }
    return _globalInstance!;
  }

  /// 广告配置
  AdConfig _config = AdConfig.defaultConfig;
  
  /// 广告状态
  final AdState _state = AdState();
  
  /// 广告服务
  AdService? _adService;
  
  /// SharedPreferences 实例
  SharedPreferences? _prefs;
  
  /// 广告回调列表
  final List<AdCallback> _callbacks = [];
  
  /// 上次展示插屏广告后的游戏局数
  int _gamesSinceLastInterstitial = 0;

  /// 获取当前广告配置
  AdConfig get config => _config;

  /// 获取当前广告状态
  AdState get state => _state;

  /// 是否启用广告
  bool get isAdEnabled => _config.enabled;

  /// 是否为模拟模式
  bool get isSimulationMode => _config.simulationMode;

  /// 初始化广告管理器
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    _config = await AdConfig.load(_prefs!);
    
    // 创建广告服务
    if (_config.simulationMode || kDebugMode) {
      _adService = MockAdService();
    } else {
      // TODO: 在生产环境中使用真实的广告服务
      // 例如：Google Mobile Ads
      _adService = MockAdService();
    }
    
    await _adService?.initialize();
    
    // 预加载广告
    await _preloadAds();
    
    _notifyStateChange();
  }

  /// 预加载广告
  Future<void> _preloadAds() async {
    if (!_config.enabled || _adService == null) return;
    
    // 并行预加载两种广告
    await Future.wait([
      _adService!.loadAd(AdType.rewarded),
      _adService!.loadAd(AdType.interstitial),
    ]);
    
    _state.isRewardedAdLoaded = _adService!.isAdLoaded(AdType.rewarded);
    _state.isInterstitialAdLoaded = _adService!.isAdLoaded(AdType.interstitial);
  }

  /// 更新配置
  Future<void> updateConfig(AdConfig newConfig) async {
    _config = newConfig;
    if (_prefs != null) {
      await _config.save(_prefs!);
    }
    _notifyStateChange();
  }

  /// 设置广告开关
  Future<void> setAdEnabled(bool enabled) async {
    await updateConfig(_config.copyWith(enabled: enabled));
  }

  /// 设置模拟模式
  Future<void> setSimulationMode(bool simulationMode) async {
    await updateConfig(_config.copyWith(simulationMode: simulationMode));
  }

  /// 添加广告回调
  void addCallback(AdCallback callback) {
    if (!_callbacks.contains(callback)) {
      _callbacks.add(callback);
    }
  }

  /// 移除广告回调
  void removeCallback(AdCallback callback) {
    _callbacks.remove(callback);
  }

  /// 游戏开始时调用
  void onGameStart() {
    _gamesSinceLastInterstitial++;
  }

  /// 游戏结束时调用
  void onGameEnd() {
    // 重置计数
  }

  /// 检查是否应该展示插屏广告
  bool shouldShowInterstitialAd() {
    if (!_config.enabled) return false;
    
    // 检查游戏局数间隔
    if (_gamesSinceLastInterstitial < _config.interstitialMinInterval) {
      return false;
    }
    
    // 根据概率决定是否展示
    final random = Random();
    return random.nextDouble() < _config.interstitialProbability;
  }

  /// 展示激励视频广告
  /// 
  /// [onRewarded] - 获得奖励时的回调
  /// [onDismissed] - 广告关闭时的回调（无论是否获得奖励）
  Future<AdResult> showRewardedAd({
    VoidCallback? onRewarded,
    VoidCallback? onDismissed,
  }) async {
    if (!_config.enabled || _adService == null) {
      // 广告未启用，直接返回失败
      onDismissed?.call();
      return const AdResult(success: false, errorMessage: '广告未启用');
    }

    // 检查广告是否已加载
    if (!_adService!.isAdLoaded(AdType.rewarded)) {
      // 尝试加载广告
      await _adService!.loadAd(AdType.rewarded);
      
      if (!_adService!.isAdLoaded(AdType.rewarded)) {
        // 加载失败，静默处理
        onDismissed?.call();
        return const AdResult(success: false, errorMessage: '广告加载失败');
      }
    }

    _state.isShowingRewardedAd = true;
    _notifyStateChange();

    // 创建回调处理器
    final callback = _RewardedAdCallback(
      onRewarded: () {
        onRewarded?.call();
      },
      onDismissed: () {
        _state.isShowingRewardedAd = false;
        _notifyStateChange();
        onDismissed?.call();
        // 重新加载广告
        _adService?.loadAd(AdType.rewarded);
      },
    );

    final result = await _adService!.showAd(
      AdType.rewarded,
      callback: callback,
    );

    return result;
  }

  /// 展示插屏广告
  /// 
  /// [onDismissed] - 广告关闭时的回调
  Future<AdResult> showInterstitialAd({
    VoidCallback? onDismissed,
  }) async {
    if (!_config.enabled || _adService == null) {
      onDismissed?.call();
      return const AdResult(success: false, errorMessage: '广告未启用');
    }

    // 检查是否应该展示插屏广告
    if (!shouldShowInterstitialAd()) {
      onDismissed?.call();
      return const AdResult(success: false, errorMessage: '不满足展示条件');
    }

    // 检查广告是否已加载
    if (!_adService!.isAdLoaded(AdType.interstitial)) {
      // 尝试加载广告
      await _adService!.loadAd(AdType.interstitial);
      
      if (!_adService!.isAdLoaded(AdType.interstitial)) {
        // 加载失败，静默处理
        onDismissed?.call();
        return const AdResult(success: false, errorMessage: '广告加载失败');
      }
    }

    _state.isShowingInterstitialAd = true;
    _notifyStateChange();

    final result = await _adService!.showAd(
      AdType.interstitial,
      callback: _InterstitialAdCallback(
        onDismissed: () {
          _state.isShowingInterstitialAd = false;
          _gamesSinceLastInterstitial = 0; // 重置计数
          _notifyStateChange();
          onDismissed?.call();
          // 重新加载广告
          _adService?.loadAd(AdType.interstitial);
        },
      ),
    );

    return result;
  }

  /// 通知状态变化
  void _notifyStateChange() {
    notifyListeners();
    for (final callback in _callbacks) {
      // 回调可以根据需要扩展
    }
  }

  /// 销毁资源
  void dispose() {
    _adService?.disposeAllAds();
    _callbacks.clear();
  }
}

/// 激励视频广告回调处理器
class _RewardedAdCallback implements AdCallback {
  final VoidCallback onRewarded;
  final VoidCallback onDismissed;

  _RewardedAdCallback({
    required this.onRewarded,
    required this.onDismissed,
  });

  @override
  void onAdLoaded(AdType type) {}

  @override
  void onAdFailedToLoad(AdType type, String error) {
    onDismissed();
  }

  @override
  void onAdShowed(AdType type) {}

  @override
  void onAdDismissed(AdType type) {
    onDismissed();
  }

  @override
  void onRewardedAdCompleted() {
    onRewarded();
  }

  @override
  void onRewardedAdNotCompleted() {
    onDismissed();
  }
}

/// 插屏广告回调处理器
class _InterstitialAdCallback implements AdCallback {
  final VoidCallback onDismissed;

  _InterstitialAdCallback({required this.onDismissed});

  @override
  void onAdLoaded(AdType type) {}

  @override
  void onAdFailedToLoad(AdType type, String error) {
    onDismissed();
  }

  @override
  void onAdShowed(AdType type) {}

  @override
  void onAdDismissed(AdType type) {
    onDismissed();
  }

  @override
  void onRewardedAdCompleted() {}

  @override
  void onRewardedAdNotCompleted() {}
}

/// 模拟广告服务 - 用于开发阶段
class MockAdService implements AdService {
  final Map<AdType, AdLoadState> _loadStates = {
    AdType.rewarded: AdLoadState.notLoaded,
    AdType.interstitial: AdLoadState.notLoaded,
  };

  @override
  bool get isSimulationMode => true;

  @override
  Future<void> initialize() async {
    // 模拟初始化延迟
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> loadAd(AdType type) async {
    _loadStates[type] = AdLoadState.loading;
    
    // 模拟加载延迟
    await Future.delayed(const Duration(milliseconds: 300));
    
    // 模拟加载成功（100%成功率）
    _loadStates[type] = AdLoadState.loaded;
  }

  @override
  bool isAdLoaded(AdType type) {
    return _loadStates[type] == AdLoadState.loaded;
  }

  @override
  AdLoadState getAdLoadState(AdType type) {
    return _loadStates[type] ?? AdLoadState.notLoaded;
  }

  @override
  Future<AdResult> showAd(
    AdType type, {
    AdCallback? callback,
    Map<String, dynamic>? context,
  }) async {
    if (!isAdLoaded(type)) {
      callback?.onAdFailedToLoad(type, '广告未加载');
      return const AdResult(success: false, errorMessage: '广告未加载');
    }

    callback?.onAdShowed(type);

    if (type == AdType.rewarded) {
      // 模拟激励视频广告展示
      // 为了测试，我们模拟用户观看了广告
      await Future.delayed(const Duration(seconds: 2));
      
      // 80% 概率完成观看
      final completed = Random().nextDouble() < 0.8;
      
      if (completed) {
        callback?.onRewardedAdCompleted();
        callback?.onAdDismissed(type);
        return const AdResult(success: true, rewarded: true);
      } else {
        callback?.onRewardedAdNotCompleted();
        callback?.onAdDismissed(type);
        return const AdResult(success: true, rewarded: false);
      }
    } else {
      // 模拟插屏广告展示
      await Future.delayed(const Duration(seconds: 2));
      callback?.onAdDismissed(type);
      return const AdResult(success: true);
    }
  }

  @override
  void disposeAd(AdType type) {
    _loadStates[type] = AdLoadState.notLoaded;
  }

  @override
  void disposeAllAds() {
    for (final type in AdType.values) {
      _loadStates[type] = AdLoadState.notLoaded;
    }
  }
}
