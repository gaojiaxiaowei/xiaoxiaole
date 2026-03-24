import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:block_blast/api/api_models.dart';
import 'package:block_blast/api/api_client.dart';
import 'package:block_blast/api/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  setUp(() async {
    // 设置 SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
  });
  group('API Models', () {
    test('RegisterRequest toJson', () {
      final request = RegisterRequest(
        username: 'testuser',
        password: 'password123',
        nickname: 'Test User',
        deviceId: 'device123',
      );

      final json = request.toJson();
      
      expect(json['username'], 'testuser');
      expect(json['password'], 'password123');
      expect(json['nickname'], 'Test User');
      expect(json['device_id'], 'device123');
    });

    test('LoginRequest toJson', () {
      final request = LoginRequest(
        username: 'testuser',
        password: 'password123',
        deviceId: 'device123',
      );

      final json = request.toJson();
      
      expect(json['username'], 'testuser');
      expect(json['password'], 'password123');
      expect(json['device_id'], 'device123');
    });

    test('SubmitScoreRequest toJson', () {
      final request = SubmitScoreRequest(
        score: 10000,
        linesCleared: 15,
        blocksPlaced: 50,
        gameMode: 'classic',
        durationSeconds: 180,
        deviceId: 'device123',
      );

      final json = request.toJson();
      
      expect(json['score'], 10000);
      expect(json['lines_cleared'], 15);
      expect(json['blocks_placed'], 50);
      expect(json['game_mode'], 'classic');
      expect(json['duration_seconds'], 180);
      expect(json['device_id'], 'device123');
      expect(json['timestamp'], isNotNull);
    });

    test('CompleteChallengeRequest toJson', () {
      final request = CompleteChallengeRequest(
        challengeId: 'c_20240320',
        score: 10000,
        linesCleared: 15,
        blocksPlaced: 50,
        durationSeconds: 180,
      );

      final json = request.toJson();
      
      expect(json['challenge_id'], 'c_20240320');
      expect(json['score'], 10000);
      expect(json['lines_cleared'], 15);
    });

    test('AuthResponse fromJson', () {
      final json = {
        'user_id': 'u_123',
        'username': 'testuser',
        'nickname': 'Test User',
        'avatar': 'https://example.com/avatar.png',
        'token': 'test_token',
        'refresh_token': 'test_refresh',
        'expires_at': 1711111111,
        'stats': {
          'total_games': 100,
          'highest_score': 10000,
          'total_score': 100000,
        },
      };

      final response = AuthResponse.fromJson(json);
      
      expect(response.userId, 'u_123');
      expect(response.username, 'testuser');
      expect(response.nickname, 'Test User');
      expect(response.avatar, 'https://example.com/avatar.png');
      expect(response.token, 'test_token');
      expect(response.refreshToken, 'test_refresh');
      expect(response.expiresAt, 1711111111);
      expect(response.stats?.totalGames, 100);
      expect(response.stats?.highestScore, 10000);
    });

    test('UserProfile fromJson', () {
      final json = {
        'user_id': 'u_123',
        'username': 'testuser',
        'nickname': 'Test User',
        'avatar': 'https://example.com/avatar.png',
        'level': 15,
        'experience': 12500,
        'created_at': '2024-01-15T10:30:00Z',
        'stats': {
          'total_games': 100,
          'highest_score': 10000,
          'total_score': 100000,
          'daily_streak': 7,
          'challenges_completed': 45,
        },
      };

      final profile = UserProfile.fromJson(json);
      
      expect(profile.userId, 'u_123');
      expect(profile.level, 15);
      expect(profile.experience, 12500);
      expect(profile.stats.dailyStreak, 7);
    });

    test('LeaderboardEntry fromJson', () {
      final json = {
        'rank': 1,
        'user_id': 'u_001',
        'nickname': 'Top Player',
        'avatar': 'https://example.com/1.png',
        'score': 25000,
        'updated_at': '2024-03-20T10:00:00Z',
      };

      final entry = LeaderboardEntry.fromJson(json);
      
      expect(entry.rank, 1);
      expect(entry.userId, 'u_001');
      expect(entry.nickname, 'Top Player');
      expect(entry.score, 25000);
    });

    test('LeaderboardData fromJson', () {
      final json = {
        'type': 'global',
        'page': 1,
        'page_size': 20,
        'total': 10000,
        'my_rank': 156,
        'my_score': 9856,
        'leaderboard': [
          {
            'rank': 1,
            'user_id': 'u_001',
            'nickname': 'Top Player',
            'avatar': 'https://example.com/1.png',
            'score': 25000,
            'updated_at': '2024-03-20T10:00:00Z',
          },
        ],
      };

      final data = LeaderboardData.fromJson(json);
      
      expect(data.type, 'global');
      expect(data.page, 1);
      expect(data.total, 10000);
      expect(data.myRank, 156);
      expect(data.leaderboard.length, 1);
      expect(data.leaderboard[0].nickname, 'Top Player');
    });

    test('DailyChallengeData fromJson', () {
      final json = {
        'challenge_id': 'c_20240320',
        'date': '2024-03-20',
        'title': '消除大师',
        'description': '在单局游戏中消除至少15行',
        'target': {
          'type': 'lines_cleared',
          'value': 15,
        },
        'rewards': {
          'experience': 200,
          'coins': 100,
          'badge': 'elimination_master',
        },
        'is_completed': false,
        'progress': {
          'current': 8,
          'target': 15,
        },
        'expires_at': '2024-03-21T00:00:00Z',
      };

      final challenge = DailyChallengeData.fromJson(json);
      
      expect(challenge.challengeId, 'c_20240320');
      expect(challenge.title, '消除大师');
      expect(challenge.target.type, 'lines_cleared');
      expect(challenge.target.value, 15);
      expect(challenge.rewards.experience, 200);
      expect(challenge.rewards.coins, 100);
      expect(challenge.isCompleted, false);
      expect(challenge.progress?.current, 8);
      expect(challenge.progress?.percentage, closeTo(0.533, 0.01));
    });

    test('PendingScore serialization', () {
      final pending = PendingScore(
        id: 'score_123',
        request: SubmitScoreRequest(
          score: 10000,
          linesCleared: 15,
          blocksPlaced: 50,
          gameMode: 'classic',
          durationSeconds: 180,
          deviceId: 'device123',
        ),
        synced: false,
      );

      final json = pending.toJson();
      final restored = PendingScore.fromJson(json);
      
      expect(restored.id, 'score_123');
      expect(restored.request.score, 10000);
      expect(restored.synced, false);
    });
  });

  group('API Client', () {
    late ApiClient client;

    setUp(() {
      client = ApiClient(config: const ApiClientConfig(enableMock: true));
    });

    test('Mock user registration', () async {
      await client.init();
      
      final response = await client.post<AuthResponse>(
        '/api/user/register',
        data: RegisterRequest(
          username: 'newuser',
          password: 'password123',
          deviceId: 'device123',
        ).toJson(),
        fromJson: (data) => AuthResponse.fromJson(data),
      );

      expect(response.isSuccess, true);
      expect(response.data, isNotNull);
      expect(response.data!.username, 'newuser');
      expect(response.data!.token, isNotEmpty);
    });

    test('Mock user login', () async {
      await client.init();
      
      final response = await client.post<AuthResponse>(
        '/api/user/login',
        data: LoginRequest(
          username: 'testuser',
          password: 'password123',
          deviceId: 'device123',
        ).toJson(),
        fromJson: (data) => AuthResponse.fromJson(data),
      );

      expect(response.isSuccess, true);
      expect(response.data, isNotNull);
      expect(response.data!.stats, isNotNull);
    });

    test('Mock get profile', () async {
      await client.init();
      
      final response = await client.get<UserProfile>(
        '/api/user/profile',
        fromJson: (data) => UserProfile.fromJson(data),
      );

      expect(response.isSuccess, true);
      expect(response.data, isNotNull);
      expect(response.data!.level, greaterThan(0));
      expect(response.data!.stats.totalGames, greaterThanOrEqualTo(0));
    });

    test('Mock submit score', () async {
      await client.init();
      
      final response = await client.post<SubmitScoreResponse>(
        '/api/score/submit',
        data: SubmitScoreRequest(
          score: 8856,
          linesCleared: 12,
          blocksPlaced: 45,
          gameMode: 'classic',
          durationSeconds: 180,
          deviceId: 'device123',
        ).toJson(),
        fromJson: (data) => SubmitScoreResponse.fromJson(data),
      );

      expect(response.isSuccess, true);
      expect(response.data, isNotNull);
      expect(response.data!.score, 8856);
      expect(response.data!.rank, greaterThan(0));
    });

    test('Mock get leaderboard', () async {
      await client.init();
      
      final response = await client.get<LeaderboardData>(
        '/api/score/leaderboard',
        queryParameters: {'type': 'global', 'page': 1},
        fromJson: (data) => LeaderboardData.fromJson(data),
      );

      expect(response.isSuccess, true);
      expect(response.data, isNotNull);
      expect(response.data!.leaderboard, isNotEmpty);
      expect(response.data!.leaderboard[0].rank, 1);
    });

    test('Mock get score history', () async {
      await client.init();
      
      final response = await client.get<ScoreHistoryData>(
        '/api/score/history',
        fromJson: (data) => ScoreHistoryData.fromJson(data),
      );

      expect(response.isSuccess, true);
      expect(response.data, isNotNull);
      expect(response.data!.records, isNotEmpty);
    });

    test('Mock get today challenge', () async {
      await client.init();
      
      final response = await client.get<DailyChallengeData>(
        '/api/challenge/today',
        fromJson: (data) => DailyChallengeData.fromJson(data),
      );

      expect(response.isSuccess, true);
      expect(response.data, isNotNull);
      expect(response.data!.title, isNotEmpty);
      expect(response.data!.target.value, greaterThan(0));
    });

    test('Mock complete challenge', () async {
      await client.init();
      
      final response = await client.post<CompleteChallengeResponse>(
        '/api/challenge/complete',
        data: CompleteChallengeRequest(
          challengeId: 'c_20240320',
          score: 8856,
          linesCleared: 15,
          blocksPlaced: 45,
          durationSeconds: 180,
        ).toJson(),
        fromJson: (data) => CompleteChallengeResponse.fromJson(data),
      );

      expect(response.isSuccess, true);
      expect(response.data, isNotNull);
      expect(response.data!.completed, true);
    });

    test('Auth save and clear', () async {
      await client.init();
      
      final auth = AuthResponse(
        userId: 'u_123',
        username: 'testuser',
        nickname: 'Test User',
        token: 'test_token',
        refreshToken: 'test_refresh',
        expiresAt: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
      );

      await client.saveAuth(auth);
      expect(client.token, 'test_token');
      expect(client.refreshToken, 'test_refresh');
      expect(client.isTokenExpired, false);

      await client.clearAuth();
      expect(client.token, isNull);
      expect(client.refreshToken, isNull);
    });
  });

  group('API Service', () {
    late ApiService service;

    setUp(() {
      service = ApiService(client: ApiClient(
        config: const ApiClientConfig(enableMock: true),
      ));
    });

    test('Service initialization', () async {
      await service.init();
      // 初始化成功即通过
      expect(true, true);
    });

    test('Register and check login status', () async {
      await service.init();
      
      expect(service.isLoggedIn, false);
      
      final response = await service.register(
        username: 'newuser',
        password: 'password123',
      );

      expect(response.isSuccess, true);
      expect(service.isLoggedIn, true);
    });

    test('Login and logout', () async {
      await service.init();
      
      final response = await service.login(
        username: 'testuser',
        password: 'password123',
      );

      expect(response.isSuccess, true);
      expect(service.isLoggedIn, true);

      await service.logout();
      expect(service.isLoggedIn, false);
    });

    test('Get profile', () async {
      await service.init();
      
      final response = await service.getProfile();

      expect(response.isSuccess, true);
      expect(response.data, isNotNull);
    });

    test('Submit score', () async {
      await service.init();
      
      final response = await service.submitScore(
        score: 10000,
        linesCleared: 15,
        blocksPlaced: 50,
        gameMode: 'classic',
        durationSeconds: 180,
      );

      expect(response.isSuccess, true);
      expect(response.data, isNotNull);
    });

    test('Get leaderboard', () async {
      await service.init();
      
      final response = await service.getLeaderboard(type: 'global');

      expect(response.isSuccess, true);
      expect(response.data, isNotNull);
      expect(response.data!.leaderboard, isNotEmpty);
    });

    test('Get score history', () async {
      await service.init();
      
      final response = await service.getScoreHistory();

      expect(response.isSuccess, true);
      expect(response.data, isNotNull);
    });

    test('Get today challenge', () async {
      await service.init();
      
      final response = await service.getTodayChallenge();

      expect(response.isSuccess, true);
      expect(response.data, isNotNull);
    });

    test('Complete challenge', () async {
      await service.init();
      
      // 先获取今日挑战
      final challengeResponse = await service.getTodayChallenge();
      expect(challengeResponse.isSuccess, true);
      
      // 完成挑战
      final response = await service.completeChallenge(
        challengeId: challengeResponse.data!.challengeId,
        score: 10000,
        linesCleared: 15,
        blocksPlaced: 50,
        durationSeconds: 180,
      );

      expect(response.isSuccess, true);
      expect(response.data!.completed, true);
    });

    test('Device ID persistence', () async {
      await service.init();
      
      final id1 = await service.deviceId;
      final id2 = await service.deviceId;
      
      expect(id1, id2);
      expect(id1, startsWith('device_'));
    });
  });
}
