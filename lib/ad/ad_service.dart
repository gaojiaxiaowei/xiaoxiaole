import 'dart:async';
import 'package:flutter/foundation.dart';

/// 广告类型
enum AdType {
  rewarded, // 激励视频广告
  interstitial, // 插屏广告
}

/// 广告加载状态
enum AdLoadState {
  notLoaded, // 未加载
  loading, // 加载中
  loaded, // 已加载
  failed, // 加载失败
}

/// 广告结果
class AdResult {
  final bool success;
  final bool rewarded; // 是否获得奖励（仅激励视频有效）
  final String? errorMessage;

  const AdResult({
    required this.success,
    this.rewarded = false,
    this.errorMessage,
  });
}

/// 广告回调接口
abstract class AdCallback {
  /// 广告加载完成
  void onAdLoaded(AdType type);

  /// 广告加载失败
  void onAdFailedToLoad(AdType type, String error);

  /// 广告展示
  void onAdShowed(AdType type);

  /// 广告被关闭
  void onAdDismissed(AdType type);

  /// 激励视频广告完成观看（获得奖励）
  void onRewardedAdCompleted();

  /// 激励视频广告未完成观看
  void onRewardedAdNotCompleted();
}

/// 广告服务抽象类 - 定义广告操作接口
abstract class AdService {
  /// 初始化广告服务
  Future<void> initialize();

  /// 加载广告
  Future<void> loadAd(AdType type);

  /// 检查广告是否已加载
  bool isAdLoaded(AdType type);

  /// 获取广告加载状态
  AdLoadState getAdLoadState(AdType type);

  /// 展示广告
  /// 
  /// [type] - 广告类型
  /// [callback] - 广告回调（可选）
  /// [context] - 上下文信息（用于UI展示）
  Future<AdResult> showAd(
    AdType type, {
    AdCallback? callback,
    Map<String, dynamic>? context,
  });

  /// 销毁广告
  void disposeAd(AdType type);

  /// 销毁所有广告
  void disposeAllAds();

  /// 是否为模拟模式
  bool get isSimulationMode;
}
