/// API 服务类
/// 
/// 封装所有业务API接口，提供类型安全的方法调用。
/// 支持离线模式和本地缓存。

import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'api_models.dart';

/// API 服务
class ApiService {
  final ApiClient _client;
  SharedPreferences? _prefs;

  // 全局实例（用于兼容静态访问层）
  static ApiService? _globalInstance;
  
  // 构造函数
  ApiService({ApiClient? client}) : _client = client ?? ApiClient();
  
  /// 设置全局实例（由 Provider 初始化时调用）
  static void setGlobalInstance(ApiService instance) {
    _globalInstance = instance;
  }
  
  /// 获取全局实例（用于兼容静态访问层）
  static ApiService get instance {
    if (_globalInstance == null) {
      throw StateError(
        'ApiService not initialized. '
        'Make sure the app is wrapped in ProviderScope and the provider is accessed at least once.'
      );
    }
    return _globalInstance!;
  }

  // 缓存键
  static const _keyCurrentUser = 'current_user';
  static const _keyDeviceId = 'device_id';
  static const _keyLastSyncTime = 'last_sync_time';

  /// 初始化服务
  Future<void> init() async {
    await _client.init();
    _prefs = await SharedPreferences.getInstance();
  }

  /// 获取设备ID
  Future<String> get deviceId async {
    var id = _prefs?.getString(_keyDeviceId);
    if (id == null) {
      id = 'device_${DateTime.now().millisecondsSinceEpoch}';
      await _prefs?.setString(_keyDeviceId, id);
    }
    return id;
  }

  // ==================== 用户接口 ====================

  /// 用户注册
  Future<ApiResponse<AuthResponse>> register({
    required String username,
    required String password,
    String? nickname,
  }) async {
    final response = await _client.post<AuthResponse>(
      '/api/user/register',
      data: RegisterRequest(
        username: username,
        password: password,
        nickname: nickname,
        deviceId: await deviceId,
      ).toJson(),
      fromJson: (data) => AuthResponse.fromJson(data),
    );

    if (response.isSuccess && response.data != null) {
      await _client.saveAuth(response.data!);
      await _saveCurrentUser(response.data!);
    }

    return response;
  }

  /// 用户登录
  Future<ApiResponse<AuthResponse>> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.post<AuthResponse>(
      '/api/user/login',
      data: LoginRequest(
        username: username,
        password: password,
        deviceId: await deviceId,
      ).toJson(),
      fromJson: (data) => AuthResponse.fromJson(data),
    );

    if (response.isSuccess && response.data != null) {
      await _client.saveAuth(response.data!);
      await _saveCurrentUser(response.data!);
    }

    return response;
  }

  /// 获取用户信息
  Future<ApiResponse<UserProfile>> getProfile({String? userId}) async {
    final params = userId != null ? {'user_id': userId} : null;
    
    return _client.get<UserProfile>(
      '/api/user/profile',
      queryParameters: params,
      fromJson: (data) => UserProfile.fromJson(data),
      useCache: true,
      cacheExpiry: const Duration(minutes: 5),
    );
  }

  /// 登出
  Future<void> logout() async {
    await _client.clearAuth();
    await _prefs?.remove(_keyCurrentUser);
  }

  /// 检查是否已登录
  bool get isLoggedIn => _client.token != null && !_client.isTokenExpired;

  /// 获取当前用户缓存
  AuthResponse? getCurrentUser() {
    final data = _prefs?.getString(_keyCurrentUser);
    if (data == null) return null;
    
    try {
      // 简化处理：返回基本用户信息
      // 实际应该从JSON反序列化完整对象
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveCurrentUser(AuthResponse user) async {
    // 简化处理，实际应该序列化完整对象
    await _prefs?.setString(_keyCurrentUser, user.userId);
  }

  // ==================== 分数接口 ====================

  /// 提交分数
  /// 
  /// 如果离线，会保存到本地队列，稍后同步
  Future<ApiResponse<SubmitScoreResponse>> submitScore({
    required int score,
    required int linesCleared,
    required int blocksPlaced,
    required String gameMode,
    required int durationSeconds,
  }) async {
    final request = SubmitScoreRequest(
      score: score,
      linesCleared: linesCleared,
      blocksPlaced: blocksPlaced,
      gameMode: gameMode,
      durationSeconds: durationSeconds,
      deviceId: await deviceId,
    );

    try {
      final response = await _client.post<SubmitScoreResponse>(
        '/api/score/submit',
        data: request.toJson(),
        fromJson: (data) => SubmitScoreResponse.fromJson(data),
      );

      // 更新最后同步时间
      await _prefs?.setInt(_keyLastSyncTime, 
        DateTime.now().millisecondsSinceEpoch);

      return response;
    } on ApiException catch (e) {
      // 网络错误时保存到离线队列
      if (e.type == ApiErrorType.network || e.type == ApiErrorType.timeout) {
        await _client.savePendingScore(PendingScore(
          id: 'score_${DateTime.now().millisecondsSinceEpoch}',
          request: request,
        ));
        
        // 返回一个模拟的成功响应
        return ApiResponse<SubmitScoreResponse>(
          code: 200,
          message: '分数已保存，将在网络恢复后同步',
          data: SubmitScoreResponse(
            recordId: 'offline_${DateTime.now().millisecondsSinceEpoch}',
            score: score,
            rank: 0,
            isNewHigh: false,
          ),
        );
      }
      rethrow;
    }
  }

  /// 获取排行榜
  Future<ApiResponse<LeaderboardData>> getLeaderboard({
    String type = 'global',
    int page = 1,
    int pageSize = 20,
  }) async {
    return _client.get<LeaderboardData>(
      '/api/score/leaderboard',
      queryParameters: {
        'type': type,
        'page': page,
        'page_size': pageSize,
      },
      fromJson: (data) => LeaderboardData.fromJson(data),
      useCache: true,
      cacheExpiry: const Duration(minutes: 5),
    );
  }

  /// 获取历史记录
  Future<ApiResponse<ScoreHistoryData>> getScoreHistory({
    String? userId,
    int page = 1,
    int pageSize = 20,
    String? gameMode,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    
    if (userId != null) params['user_id'] = userId;
    if (gameMode != null) params['game_mode'] = gameMode;

    return _client.get<ScoreHistoryData>(
      '/api/score/history',
      queryParameters: params,
      fromJson: (data) => ScoreHistoryData.fromJson(data),
    );
  }

  /// 同步离线分数
  /// 
  /// 将本地保存的离线分数上传到服务器
  Future<int> syncOfflineScores() async {
    final pending = await _client.getPendingScores();
    int syncedCount = 0;

    for (final score in pending) {
      if (score.synced) continue;

      try {
        final response = await _client.post<SubmitScoreResponse>(
          '/api/score/submit',
          data: score.request.toJson(),
          fromJson: (data) => SubmitScoreResponse.fromJson(data),
        );

        if (response.isSuccess) {
          await _client.removePendingScore(score.id);
          syncedCount++;
        }
      } catch (_) {
        // 同步失败，保留在队列中
        continue;
      }
    }

    if (syncedCount > 0) {
      await _prefs?.setInt(_keyLastSyncTime, 
        DateTime.now().millisecondsSinceEpoch);
    }

    return syncedCount;
  }

  /// 获取待同步分数数量
  Future<int> getPendingScoreCount() async {
    final pending = await _client.getPendingScores();
    return pending.where((s) => !s.synced).length;
  }

  // ==================== 每日挑战接口 ====================

  /// 获取今日挑战
  Future<ApiResponse<DailyChallengeData>> getTodayChallenge() async {
    return _client.get<DailyChallengeData>(
      '/api/challenge/today',
      fromJson: (data) => DailyChallengeData.fromJson(data),
      useCache: true,
      cacheExpiry: const Duration(hours: 1),
    );
  }

  /// 完成挑战
  Future<ApiResponse<CompleteChallengeResponse>> completeChallenge({
    required String challengeId,
    required int score,
    required int linesCleared,
    required int blocksPlaced,
    required int durationSeconds,
  }) async {
    return _client.post<CompleteChallengeResponse>(
      '/api/challenge/complete',
      data: CompleteChallengeRequest(
        challengeId: challengeId,
        score: score,
        linesCleared: linesCleared,
        blocksPlaced: blocksPlaced,
        durationSeconds: durationSeconds,
      ).toJson(),
      fromJson: (data) => CompleteChallengeResponse.fromJson(data),
    );
  }

  // ==================== Token刷新 ====================

  /// 刷新Token
  Future<ApiResponse<TokenRefreshResponse>> refreshToken() async {
    final token = _client.refreshToken;
    if (token == null) {
      return ApiResponse<TokenRefreshResponse>(
        code: 401,
        message: '无刷新Token',
      );
    }

    final response = await _client.post<TokenRefreshResponse>(
      '/api/auth/refresh',
      data: RefreshTokenRequest(refreshToken: token).toJson(),
      fromJson: (data) => TokenRefreshResponse.fromJson(data),
    );

    if (response.isSuccess && response.data != null) {
      // 更新保存的token
      final auth = AuthResponse(
        userId: getCurrentUser()?.userId ?? '',
        username: getCurrentUser()?.username ?? '',
        nickname: getCurrentUser()?.nickname ?? '',
        token: response.data!.token,
        refreshToken: response.data!.refreshToken,
        expiresAt: response.data!.expiresAt,
      );
      await _client.saveAuth(auth);
    }

    return response;
  }

  // ==================== 缓存管理 ====================

  /// 清除所有缓存
  Future<void> clearAllCache() async {
    await _client.clearCache();
  }

  /// 获取最后同步时间
  DateTime? getLastSyncTime() {
    final timestamp = _prefs?.getInt(_keyLastSyncTime);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 检查是否需要同步（超过1小时未同步）
  bool get needsSync {
    final lastSync = getLastSyncTime();
    if (lastSync == null) return true;
    return DateTime.now().difference(lastSync).inHours >= 1;
  }
  
  /// 初始化全局实例
  static Future<void> initGlobal() async {
    final instance = ApiService();
    await instance.init();
    setGlobalInstance(instance);
  }
}
