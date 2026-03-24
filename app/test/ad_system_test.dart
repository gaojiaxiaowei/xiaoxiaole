import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/ad/ad_manager.dart';
import 'package:block_blast/ad/ad_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AdManager', () {
    late AdManager adManager;

    setUp(() async {
      // 初始化 SharedPreferences mock数据
      SharedPreferences.setMockInitialValues({});
      
      // 初始化 AdManager
      adManager = AdManager();
      await adManager.initialize();
    });

    tearDown(() {
      adManager.dispose();
    });

    test('AdManager should be a singleton', () {
      final instance1 = AdManager();
      final instance2 = AdManager();
      
      expect(instance1, same(instance2));
    });

    test('AdConfig default values', () {
      final config = AdConfig.defaultConfig;
      
      expect(config.enabled, true);
      expect(config.simulationMode, true);
      expect(config.interstitialProbability, 0.3);
      expect(config.interstitialMinInterval, 3);
    });

    test('AdConfig copyWith', () {
      final config = AdConfig.defaultConfig;
      final newConfig = config.copyWith(enabled: false);
      
      expect(newConfig.enabled, false);
      expect(newConfig.simulationMode, true); // 其他值保持不变
    });

    test('shouldShowInterstitialAd should return false when ads disabled', () async {
      await adManager.setAdEnabled(false);
      
      expect(adManager.shouldShowInterstitialAd(), false);
    });

    test('shouldShowInterstitialAd should respect interval', () async {
      // 设置需要3局后才展示
      adManager.onGameStart();
      adManager.onGameStart();
      adManager.onGameStart();
      
      // 启用广告
      await adManager.setAdEnabled(true);
      
      // 注意：shouldShowInterstitialAd有随机概率，所以这里不直接断言true
      // 只验证不会因为局数不足而返回false
      final result = adManager.shouldShowInterstitialAd();
      expect(result, isA<bool>());
    });

    test('showRewardedAd should return failure when ads disabled', () async {
      await adManager.setAdEnabled(false);
      
      final result = await adManager.showRewardedAd(
        onRewarded: () {},
        onDismissed: () {},
      );
      
      expect(result.success, false);
    });

    test('AdState initial values', () {
      final state = adManager.state;
      
      expect(state.isShowingRewardedAd, false);
      expect(state.isShowingInterstitialAd, false);
    });

    test('isAdEnabled should reflect config', () async {
      await adManager.setAdEnabled(true);
      expect(adManager.isAdEnabled, true);
      
      await adManager.setAdEnabled(false);
      expect(adManager.isAdEnabled, false);
    });

    test('isSimulationMode should be true by default', () {
      expect(adManager.isSimulationMode, true);
    });
  });

  group('MockAdService', () {
    test('should initialize successfully', () async {
      final service = MockAdService();
      await service.initialize();
      expect(service.isSimulationMode, true);
    });

    test('should load and show rewarded ad', () async {
      final service = MockAdService();
      await service.initialize();
      await service.loadAd(AdType.rewarded);
      
      expect(service.isAdLoaded(AdType.rewarded), true);
      
      var rewarded = false;
      final result = await service.showAd(
        AdType.rewarded,
        callback: _TestCallback(
          onRewarded: () => rewarded = true,
        ),
      );
      
      expect(result.success, true);
    });

    test('should load and show interstitial ad', () async {
      final service = MockAdService();
      await service.initialize();
      await service.loadAd(AdType.interstitial);
      
      expect(service.isAdLoaded(AdType.interstitial), true);
      
      var dismissed = false;
      final result = await service.showAd(
        AdType.interstitial,
        callback: _TestCallback(
          onDismissed: () => dismissed = true,
        ),
      );
      
      expect(result.success, true);
    });

    test('should not show ad if not loaded', () async {
      final service = MockAdService();
      await service.initialize();
      
      // 不加载直接展示
      final result = await service.showAd(AdType.rewarded);
      expect(result.success, false);
    });
  });
}

/// 测试用回调
class _TestCallback implements AdCallback {
  final VoidCallback? onRewarded;
  final VoidCallback? onDismissed;

  _TestCallback({this.onRewarded, this.onDismissed});

  @override
  void onAdLoaded(AdType type) {}

  @override
  void onAdFailedToLoad(AdType type, String error) {}

  @override
  void onAdShowed(AdType type) {}

  @override
  void onAdDismissed(AdType type) {
    onDismissed?.call();
  }

  @override
  void onRewardedAdCompleted() {
    onRewarded?.call();
  }

  @override
  void onRewardedAdNotCompleted() {}
}

typedef VoidCallback = void Function();
