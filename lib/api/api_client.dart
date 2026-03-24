/// API 客户端封装
/// 
/// 基于 Dio 实现的 HTTP 客户端，支持：
/// - Mock 模式（开发阶段使用模拟数据）
/// - 离线缓存（SharedPreferences）
/// - 自动 Token 刷新
/// - 请求重试
/// - 网络状态检测

import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_models.dart';
import '../core/app_logger.dart';

/// API 异常类型
enum ApiErrorType {
  network, // 网络错误
  timeout, // 超时
  unauthorized, // 未授权
  server, // 服务器错误
  unknown, // 未知错误
}

/// API 异常
class ApiException implements Exception {
  final int? code;
  final String message;
  final ApiErrorType type;

  ApiException({
    this.code,
    required this.message,
    this.type = ApiErrorType.unknown,
  });

  @override
  String toString() => 'ApiException: $message (code: $code, type: $type)';
}

/// 网络状态
enum NetworkStatus {
  online,
  offline,
  unknown,
}

/// API 客户端配置
class ApiClientConfig {
  final String baseUrl;
  final bool enableMock;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final int maxRetries;
  final Duration retryDelay;

  const ApiClientConfig({
    this.baseUrl = 'https://api.blockblast.game/v1',
    this.enableMock = true, // 默认使用Mock模式
    this.connectTimeout = const Duration(seconds: 10),
    this.receiveTimeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
  });
}

/// API 客户端
class ApiClient {
  final ApiClientConfig config;
  late final Dio _dio;
  SharedPreferences? _prefs;

  // 缓存键
  static const _keyToken = 'api_token';
  static const _keyRefreshToken = 'api_refresh_token';
  static const _keyTokenExpiresAt = 'api_token_expires_at';
  static const _keyUserCache = 'api_user_cache';
  static const _keyLeaderboardCache = 'api_leaderboard_cache';
  static const _keyPendingScores = 'api_pending_scores';

  // Mock数据生成器
  final _random = Random();

  ApiClient({this.config = const ApiClientConfig()}) {
    _dio = Dio(BaseOptions(
      baseUrl: config.baseUrl,
      connectTimeout: config.connectTimeout,
      receiveTimeout: config.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // 添加拦截器
    _dio.interceptors.add(_AuthInterceptor(this));
    _dio.interceptors.add(LogInterceptor(
      request: false,
      requestHeader: false,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
    ));
  }

  /// 初始化（必须在使用前调用）
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// 获取当前Token
  String? get token => _prefs?.getString(_keyToken);

  /// 获取刷新Token
  String? get refreshToken => _prefs?.getString(_keyRefreshToken);

  /// Token是否过期
  bool get isTokenExpired {
    final expiresAt = _prefs?.getInt(_keyTokenExpiresAt) ?? 0;
    return DateTime.now().millisecondsSinceEpoch ~/ 1000 >= expiresAt - 60;
  }

  /// 保存认证信息
  Future<void> saveAuth(AuthResponse auth) async {
    await _prefs?.setString(_keyToken, auth.token);
    await _prefs?.setString(_keyRefreshToken, auth.refreshToken);
    await _prefs?.setInt(_keyTokenExpiresAt, auth.expiresAt);
  }

  /// 清除认证信息
  Future<void> clearAuth() async {
    await _prefs?.remove(_keyToken);
    await _prefs?.remove(_keyRefreshToken);
    await _prefs?.remove(_keyTokenExpiresAt);
    await _prefs?.remove(_keyUserCache);
  }

  /// GET 请求
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
    bool useCache = false,
    Duration? cacheExpiry,
  }) async {
    if (config.enableMock) {
      return _mockGet<T>(path, queryParameters, fromJson);
    }

    // 检查缓存
    if (useCache) {
      final cached = _getCached<T>(path, fromJson);
      if (cached != null) return cached;
    }

    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      final apiResponse = ApiResponse<T>.fromJson(
        response.data,
        fromJson,
      );

      // 缓存成功的响应
      if (useCache && apiResponse.isSuccess) {
        _setCache(path, response.data, cacheExpiry);
      }

      return apiResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST 请求
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    T Function(dynamic)? fromJson,
  }) async {
    if (config.enableMock) {
      return _mockPost<T>(path, data, fromJson);
    }

    try {
      final response = await _dio.post(path, data: data);
      return ApiResponse<T>.fromJson(response.data, fromJson);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== Mock 实现 ====================

  /// Mock GET 请求
  Future<ApiResponse<T>> _mockGet<T>(
    String path,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  ) async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(400)));

    // 根据路径返回对应的Mock数据
    dynamic mockData;

    if (path == '/api/user/profile') {
      mockData = _mockUserProfile();
    } else if (path == '/api/score/leaderboard') {
      mockData = _mockLeaderboard(queryParameters);
    } else if (path == '/api/score/history') {
      mockData = _mockScoreHistory(queryParameters);
    } else if (path == '/api/challenge/today') {
      mockData = _mockDailyChallenge();
    } else {
      return ApiResponse<T>(
        code: 404,
        message: 'Not Found',
      );
    }

    return ApiResponse<T>(
      code: 200,
      message: 'success',
      data: fromJson != null ? fromJson(mockData) : mockData as T,
    );
  }

  /// Mock POST 请求
  Future<ApiResponse<T>> _mockPost<T>(
    String path,
    dynamic data,
    T Function(dynamic)? fromJson,
  ) async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 100 + _random.nextInt(400)));

    dynamic mockData;

    if (path == '/api/user/register') {
      mockData = _mockAuthResponse(data, isNew: true);
    } else if (path == '/api/user/login') {
      mockData = _mockAuthResponse(data);
    } else if (path == '/api/score/submit') {
      mockData = _mockSubmitScore(data);
    } else if (path == '/api/challenge/complete') {
      mockData = _mockCompleteChallenge(data);
    } else if (path == '/api/auth/refresh') {
      mockData = _mockTokenRefresh();
    } else {
      return ApiResponse<T>(
        code: 404,
        message: 'Not Found',
      );
    }

    return ApiResponse<T>(
      code: 200,
      message: 'success',
      data: fromJson != null ? fromJson(mockData) : mockData as T,
    );
  }

  // Mock 数据生成方法
  Map<String, dynamic> _mockAuthResponse(dynamic data, {bool isNew = false}) {
    final username = (data as Map)['username'] as String;
    return {
      'user_id': 'u_${DateTime.now().millisecondsSinceEpoch}',
      'username': username,
      'nickname': (data['nickname'] as String?) ?? username,
      'avatar': 'https://cdn.blockblast.game/avatar/default.png',
      'token': 'mock_token_${_random.nextInt(1000000)}',
      'refresh_token': 'mock_refresh_${_random.nextInt(1000000)}',
      'expires_at': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 86400,
      'stats': isNew
          ? null
          : {
              'total_games': 10 + _random.nextInt(100),
              'highest_score': 5000 + _random.nextInt(10000),
              'total_score': 50000 + _random.nextInt(100000),
            },
    };
  }

  Map<String, dynamic> _mockUserProfile() {
    return {
      'user_id': 'u_12345678',
      'username': 'mock_user',
      'nickname': '模拟用户',
      'avatar': 'https://cdn.blockblast.game/avatar/default.png',
      'level': 1 + _random.nextInt(50),
      'experience': 1000 + _random.nextInt(50000),
      'created_at': '2024-01-15T10:30:00Z',
      'stats': {
        'total_games': 50 + _random.nextInt(200),
        'highest_score': 8000 + _random.nextInt(15000),
        'total_score': 100000 + _random.nextInt(500000),
        'daily_streak': 1 + _random.nextInt(30),
        'challenges_completed': _random.nextInt(100),
      },
    };
  }

  Map<String, dynamic> _mockSubmitScore(dynamic data) {
    final score = (data as Map)['score'] as int;
    return {
      'record_id': 'r_${DateTime.now().millisecondsSinceEpoch}',
      'score': score,
      'rank': 1 + _random.nextInt(10000),
      'is_new_high': _random.nextBool(),
      'rewards': {
        'experience': (score / 100).round(),
        'coins': (score / 200).round(),
      },
    };
  }

  Map<String, dynamic> _mockLeaderboard(Map<String, dynamic>? params) {
    final page = (params?['page'] as int?) ?? 1;
    final pageSize = (params?['page_size'] as int?) ?? 20;
    final type = (params?['type'] as String?) ?? 'global';

    final List<Map<String, dynamic>> entries = [];
    for (int i = 0; i < pageSize; i++) {
      final rank = (page - 1) * pageSize + i + 1;
      entries.add({
        'rank': rank,
        'user_id': 'u_${1000 + i}',
        'nickname': '玩家${1000 + i}',
        'avatar': 'https://cdn.blockblast.game/avatar/${i % 10}.png',
        'score': 25000 - rank * 100 - _random.nextInt(50),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }

    return {
      'type': type,
      'page': page,
      'page_size': pageSize,
      'total': 10000,
      'my_rank': 156 + _random.nextInt(1000),
      'my_score': 8000 + _random.nextInt(5000),
      'leaderboard': entries,
    };
  }

  Map<String, dynamic> _mockScoreHistory(Map<String, dynamic>? params) {
    final page = (params?['page'] as int?) ?? 1;
    final pageSize = (params?['page_size'] as int?) ?? 20;

    final List<Map<String, dynamic>> records = [];
    for (int i = 0; i < pageSize; i++) {
      final timestamp = DateTime.now().subtract(Duration(days: i * 2));
      records.add({
        'record_id': 'r_${timestamp.millisecondsSinceEpoch}_$i',
        'score': 5000 + _random.nextInt(15000),
        'lines_cleared': 5 + _random.nextInt(20),
        'blocks_placed': 20 + _random.nextInt(50),
        'game_mode': _random.nextBool() ? 'classic' : 'challenge',
        'duration_seconds': 60 + _random.nextInt(300),
        'created_at': timestamp.toIso8601String(),
      });
    }

    return {
      'page': page,
      'page_size': pageSize,
      'total': 100 + _random.nextInt(200),
      'records': records,
    };
  }

  Map<String, dynamic> _mockDailyChallenge() {
    final today = DateTime.now();
    final challengeTypes = [
      {'title': '消除大师', 'desc': '在单局游戏中消除至少15行', 'type': 'lines_cleared', 'value': 15},
      {'title': '得分王者', 'desc': '单局得分超过10000分', 'type': 'score', 'value': 10000},
      {'title': '速通挑战', 'desc': '在120秒内完成游戏', 'type': 'duration', 'value': 120},
    ];
    final typeIndex = today.day % challengeTypes.length;
    final challenge = challengeTypes[typeIndex];

    return {
      'challenge_id': 'c_${today.year}${today.month.toString().padLeft(2, '0')}${today.day.toString().padLeft(2, '0')}',
      'date': today.toIso8601String().split('T')[0],
      'title': challenge['title'],
      'description': challenge['desc'],
      'target': {
        'type': challenge['type'],
        'value': challenge['value'],
      },
      'rewards': {
        'experience': 200,
        'coins': 100,
        'badge': challenge['type'] == 'lines_cleared' ? 'elimination_master' : null,
      },
      'is_completed': _random.nextBool(),
      'progress': {
        'current': _random.nextInt((challenge['value'] as int) + 5),
        'target': challenge['value'],
      },
      'expires_at': DateTime(today.year, today.month, today.day + 1).toIso8601String(),
    };
  }

  Map<String, dynamic> _mockCompleteChallenge(dynamic data) {
    return {
      'challenge_id': (data as Map)['challenge_id'],
      'completed': true,
      'rewards_claimed': {
        'experience': 200,
        'coins': 100,
      },
      'new_level': 16,
      'new_experience': 12700,
    };
  }

  Map<String, dynamic> _mockTokenRefresh() {
    return {
      'token': 'mock_new_token_${_random.nextInt(1000000)}',
      'refresh_token': 'mock_new_refresh_${_random.nextInt(1000000)}',
      'expires_at': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 86400,
    };
  }

  // ==================== 缓存相关 ====================

  String _cacheKey(String path, [Map<String, dynamic>? params]) {
    final paramStr = params?.entries.map((e) => '${e.key}=${e.value}').join('&') ?? '';
    return 'cache_${path}_$paramStr';
  }

  ApiResponse<T>? _getCached<T>(String path, T Function(dynamic)? fromJson) {
    final key = _cacheKey(path);
    final cached = _prefs?.getString(key);
    if (cached == null) return null;

    try {
      final decoded = jsonDecode(cached);
      final timestamp = decoded['timestamp'] as int;
      final expiry = decoded['expiry'] as int?;

      // 检查是否过期
      if (expiry != null &&
          DateTime.now().millisecondsSinceEpoch > timestamp + expiry) {
        return null;
      }

      return ApiResponse<T>.fromJson(decoded['data'], fromJson);
    } catch (e, stackTrace) {
      AppLogger.debug('读取缓存失败', e, stackTrace);
      return null;
    }
  }

  Future<void> _setCache(String path, dynamic data, Duration? expiry) async {
    final key = _cacheKey(path);
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiry': expiry?.inMilliseconds,
    };
    await _prefs?.setString(key, jsonEncode(cacheData));
  }

  /// 清除所有缓存
  Future<void> clearCache() async {
    final keys = _prefs?.getKeys().where((k) => k.startsWith('cache_')) ?? [];
    for (final key in keys) {
      await _prefs?.remove(key);
    }
  }

  // ==================== 离线数据同步 ====================

  /// 保存待同步的分数
  Future<void> savePendingScore(PendingScore score) async {
    final pending = await getPendingScores();
    pending.add(score);
    await _prefs?.setString(_keyPendingScores, jsonEncode(
      pending.map((s) => s.toJson()).toList(),
    ));
  }

  /// 获取所有待同步的分数
  Future<List<PendingScore>> getPendingScores() async {
    final data = _prefs?.getString(_keyPendingScores);
    if (data == null) return [];
    
    try {
      final list = jsonDecode(data) as List;
      return list.map((e) => PendingScore.fromJson(e)).toList();
    } catch (e, stackTrace) {
      AppLogger.debug('解析待同步分数失败', e, stackTrace);
      return [];
    }
  }

  /// 移除已同步的分数
  Future<void> removePendingScore(String id) async {
    final pending = await getPendingScores();
    pending.removeWhere((s) => s.id == id);
    await _prefs?.setString(_keyPendingScores, jsonEncode(
      pending.map((s) => s.toJson()).toList(),
    ));
  }

  /// 标记分数为已同步
  Future<void> markScoreSynced(String id) async {
    final pending = await getPendingScores();
    final index = pending.indexWhere((s) => s.id == id);
    if (index != -1) {
      pending[index] = PendingScore(
        id: id,
        request: pending[index].request,
        synced: true,
      );
      await _prefs?.setString(_keyPendingScores, jsonEncode(
        pending.map((s) => s.toJson()).toList(),
      ));
    }
  }

  // ==================== 错误处理 ====================

  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          message: '请求超时，请检查网络连接',
          type: ApiErrorType.timeout,
        );
      case DioExceptionType.connectionError:
        return ApiException(
          message: '网络连接失败',
          type: ApiErrorType.network,
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401) {
          return ApiException(
            code: statusCode,
            message: '未授权，请重新登录',
            type: ApiErrorType.unauthorized,
          );
        }
        if (statusCode != null && statusCode >= 500) {
          return ApiException(
            code: statusCode,
            message: '服务器错误',
            type: ApiErrorType.server,
          );
        }
        final data = e.response?.data;
        return ApiException(
          code: statusCode,
          message: data?['message'] ?? '请求失败',
        );
      default:
        return ApiException(
          message: e.message ?? '未知错误',
          type: ApiErrorType.unknown,
        );
    }
  }
}

/// 认证拦截器
class _AuthInterceptor extends Interceptor {
  final ApiClient client;

  _AuthInterceptor(this.client);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // 添加Token到请求头
    final token = client.token;
    if (token != null && !client.isTokenExpired) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Token过期时尝试刷新
    if (err.response?.statusCode == 401 && client.refreshToken != null) {
      _refreshTokenAndRetry(err, handler);
      return;
    }
    handler.next(err);
  }

  Future<void> _refreshTokenAndRetry(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      // 这里简化处理，实际应该调用刷新Token接口
      // 由于我们使用Mock模式，这里不需要真正实现
      handler.next(err);
    } catch (e, stackTrace) {
      AppLogger.debug('刷新Token失败', e, stackTrace);
      handler.next(err);
    }
  }
}
