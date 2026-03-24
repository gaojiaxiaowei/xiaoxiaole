/// API 数据模型定义
/// 
/// 包含所有API请求和响应的数据结构

// ==================== 通用响应 ====================

/// API 基础响应结构
class ApiResponse<T> {
  final int code;
  final String message;
  final T? data;

  ApiResponse({
    required this.code,
    required this.message,
    this.data,
  });

  bool get isSuccess => code == 200;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse<T>(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
    );
  }
}

// ==================== 用户相关 ====================

/// 用户注册请求
class RegisterRequest {
  final String username;
  final String password;
  final String? nickname;
  final String deviceId;

  RegisterRequest({
    required this.username,
    required this.password,
    this.nickname,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'nickname': nickname,
        'device_id': deviceId,
      };
}

/// 用户登录请求
class LoginRequest {
  final String username;
  final String password;
  final String deviceId;

  LoginRequest({
    required this.username,
    required this.password,
    required this.deviceId,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'device_id': deviceId,
      };
}

/// 登录/注册响应
class AuthResponse {
  final String userId;
  final String username;
  final String nickname;
  final String? avatar;
  final String token;
  final String refreshToken;
  final int expiresAt;
  final UserStats? stats;

  AuthResponse({
    required this.userId,
    required this.username,
    required this.nickname,
    this.avatar,
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
    this.stats,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String?,
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: json['expires_at'] as int,
      stats: json['stats'] != null
          ? UserStats.fromJson(json['stats'])
          : null,
    );
  }
}

/// 用户统计数据
class UserStats {
  final int totalGames;
  final int highestScore;
  final int totalScore;
  final int? dailyStreak;
  final int? challengesCompleted;

  UserStats({
    required this.totalGames,
    required this.highestScore,
    required this.totalScore,
    this.dailyStreak,
    this.challengesCompleted,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalGames: json['total_games'] as int? ?? 0,
      highestScore: json['highest_score'] as int? ?? 0,
      totalScore: json['total_score'] as int? ?? 0,
      dailyStreak: json['daily_streak'] as int?,
      challengesCompleted: json['challenges_completed'] as int?,
    );
  }
}

/// 用户信息
class UserProfile {
  final String userId;
  final String username;
  final String nickname;
  final String? avatar;
  final int level;
  final int experience;
  final String createdAt;
  final UserStats stats;

  UserProfile({
    required this.userId,
    required this.username,
    required this.nickname,
    this.avatar,
    required this.level,
    required this.experience,
    required this.createdAt,
    required this.stats,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'] as String,
      username: json['username'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String?,
      level: json['level'] as int? ?? 1,
      experience: json['experience'] as int? ?? 0,
      createdAt: json['created_at'] as String,
      stats: UserStats.fromJson(json['stats'] ?? {}),
    );
  }
}

// ==================== 分数相关 ====================

/// 提交分数请求
class SubmitScoreRequest {
  final int score;
  final int linesCleared;
  final int blocksPlaced;
  final String gameMode;
  final int durationSeconds;
  final String deviceId;
  final int timestamp;

  SubmitScoreRequest({
    required this.score,
    required this.linesCleared,
    required this.blocksPlaced,
    required this.gameMode,
    required this.durationSeconds,
    required this.deviceId,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Map<String, dynamic> toJson() => {
        'score': score,
        'lines_cleared': linesCleared,
        'blocks_placed': blocksPlaced,
        'game_mode': gameMode,
        'duration_seconds': durationSeconds,
        'device_id': deviceId,
        'timestamp': timestamp,
      };
}

/// 提交分数响应
class SubmitScoreResponse {
  final String recordId;
  final int score;
  final int rank;
  final bool isNewHigh;
  final ScoreRewards? rewards;

  SubmitScoreResponse({
    required this.recordId,
    required this.score,
    required this.rank,
    required this.isNewHigh,
    this.rewards,
  });

  factory SubmitScoreResponse.fromJson(Map<String, dynamic> json) {
    return SubmitScoreResponse(
      recordId: json['record_id'] as String,
      score: json['score'] as int,
      rank: json['rank'] as int,
      isNewHigh: json['is_new_high'] as bool? ?? false,
      rewards: json['rewards'] != null
          ? ScoreRewards.fromJson(json['rewards'])
          : null,
    );
  }
}

/// 分数奖励
class ScoreRewards {
  final int experience;
  final int coins;

  ScoreRewards({
    required this.experience,
    required this.coins,
  });

  factory ScoreRewards.fromJson(Map<String, dynamic> json) {
    return ScoreRewards(
      experience: json['experience'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
    );
  }
}

/// 排行榜条目
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String nickname;
  final String? avatar;
  final int score;
  final String updatedAt;

  LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.nickname,
    this.avatar,
    required this.score,
    required this.updatedAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int,
      userId: json['user_id'] as String,
      nickname: json['nickname'] as String,
      avatar: json['avatar'] as String?,
      score: json['score'] as int,
      updatedAt: json['updated_at'] as String,
    );
  }
}

/// 排行榜数据
class LeaderboardData {
  final String type;
  final int page;
  final int pageSize;
  final int total;
  final int myRank;
  final int myScore;
  final List<LeaderboardEntry> leaderboard;

  LeaderboardData({
    required this.type,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.myRank,
    required this.myScore,
    required this.leaderboard,
  });

  factory LeaderboardData.fromJson(Map<String, dynamic> json) {
    return LeaderboardData(
      type: json['type'] as String,
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      total: json['total'] as int,
      myRank: json['my_rank'] as int,
      myScore: json['my_score'] as int,
      leaderboard: (json['leaderboard'] as List)
          .map((e) => LeaderboardEntry.fromJson(e))
          .toList(),
    );
  }
}

/// 历史记录条目
class ScoreRecord {
  final String recordId;
  final int score;
  final int linesCleared;
  final int blocksPlaced;
  final String gameMode;
  final int durationSeconds;
  final String createdAt;

  ScoreRecord({
    required this.recordId,
    required this.score,
    required this.linesCleared,
    required this.blocksPlaced,
    required this.gameMode,
    required this.durationSeconds,
    required this.createdAt,
  });

  factory ScoreRecord.fromJson(Map<String, dynamic> json) {
    return ScoreRecord(
      recordId: json['record_id'] as String,
      score: json['score'] as int,
      linesCleared: json['lines_cleared'] as int,
      blocksPlaced: json['blocks_placed'] as int,
      gameMode: json['game_mode'] as String,
      durationSeconds: json['duration_seconds'] as int,
      createdAt: json['created_at'] as String,
    );
  }
}

/// 历史记录数据
class ScoreHistoryData {
  final int page;
  final int pageSize;
  final int total;
  final List<ScoreRecord> records;

  ScoreHistoryData({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.records,
  });

  factory ScoreHistoryData.fromJson(Map<String, dynamic> json) {
    return ScoreHistoryData(
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      total: json['total'] as int,
      records: (json['records'] as List)
          .map((e) => ScoreRecord.fromJson(e))
          .toList(),
    );
  }
}

// ==================== 每日挑战 ====================

/// 挑战目标
class ChallengeTarget {
  final String type;
  final int value;

  ChallengeTarget({
    required this.type,
    required this.value,
  });

  factory ChallengeTarget.fromJson(Map<String, dynamic> json) {
    return ChallengeTarget(
      type: json['type'] as String,
      value: json['value'] as int,
    );
  }
}

/// 挑战奖励
class ChallengeRewards {
  final int experience;
  final int coins;
  final String? badge;

  ChallengeRewards({
    required this.experience,
    required this.coins,
    this.badge,
  });

  factory ChallengeRewards.fromJson(Map<String, dynamic> json) {
    return ChallengeRewards(
      experience: json['experience'] as int? ?? 0,
      coins: json['coins'] as int? ?? 0,
      badge: json['badge'] as String?,
    );
  }
}

/// 挑战进度
class ChallengeProgress {
  final int current;
  final int target;

  ChallengeProgress({
    required this.current,
    required this.target,
  });

  factory ChallengeProgress.fromJson(Map<String, dynamic> json) {
    return ChallengeProgress(
      current: json['current'] as int,
      target: json['target'] as int,
    );
  }
  
  double get percentage => target > 0 ? current / target : 0;
}

/// 今日挑战数据
class DailyChallengeData {
  final String challengeId;
  final String date;
  final String title;
  final String description;
  final ChallengeTarget target;
  final ChallengeRewards rewards;
  final bool isCompleted;
  final ChallengeProgress? progress;
  final String expiresAt;

  DailyChallengeData({
    required this.challengeId,
    required this.date,
    required this.title,
    required this.description,
    required this.target,
    required this.rewards,
    required this.isCompleted,
    this.progress,
    required this.expiresAt,
  });

  factory DailyChallengeData.fromJson(Map<String, dynamic> json) {
    return DailyChallengeData(
      challengeId: json['challenge_id'] as String,
      date: json['date'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      target: ChallengeTarget.fromJson(json['target']),
      rewards: ChallengeRewards.fromJson(json['rewards']),
      isCompleted: json['is_completed'] as bool? ?? false,
      progress: json['progress'] != null
          ? ChallengeProgress.fromJson(json['progress'])
          : null,
      expiresAt: json['expires_at'] as String,
    );
  }
}

/// 完成挑战请求
class CompleteChallengeRequest {
  final String challengeId;
  final int score;
  final int linesCleared;
  final int blocksPlaced;
  final int durationSeconds;
  final int timestamp;

  CompleteChallengeRequest({
    required this.challengeId,
    required this.score,
    required this.linesCleared,
    required this.blocksPlaced,
    required this.durationSeconds,
    int? timestamp,
  }) : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch ~/ 1000;

  Map<String, dynamic> toJson() => {
        'challenge_id': challengeId,
        'score': score,
        'lines_cleared': linesCleared,
        'blocks_placed': blocksPlaced,
        'duration_seconds': durationSeconds,
        'timestamp': timestamp,
      };
}

/// 完成挑战响应
class CompleteChallengeResponse {
  final String challengeId;
  final bool completed;
  final ChallengeRewards? rewardsClaimed;
  final int? newLevel;
  final int? newExperience;

  CompleteChallengeResponse({
    required this.challengeId,
    required this.completed,
    this.rewardsClaimed,
    this.newLevel,
    this.newExperience,
  });

  factory CompleteChallengeResponse.fromJson(Map<String, dynamic> json) {
    return CompleteChallengeResponse(
      challengeId: json['challenge_id'] as String,
      completed: json['completed'] as bool,
      rewardsClaimed: json['rewards_claimed'] != null
          ? ChallengeRewards.fromJson(json['rewards_claimed'])
          : null,
      newLevel: json['new_level'] as int?,
      newExperience: json['new_experience'] as int?,
    );
  }
}

// ==================== 离线数据 ====================

/// 待同步的分数记录
class PendingScore {
  final String id;
  final SubmitScoreRequest request;
  final bool synced;

  PendingScore({
    required this.id,
    required this.request,
    this.synced = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'request': request.toJson(),
        'synced': synced,
      };

  factory PendingScore.fromJson(Map<String, dynamic> json) {
    return PendingScore(
      id: json['id'] as String,
      request: SubmitScoreRequest(
        score: json['request']['score'] as int,
        linesCleared: json['request']['lines_cleared'] as int,
        blocksPlaced: json['request']['blocks_placed'] as int,
        gameMode: json['request']['game_mode'] as String,
        durationSeconds: json['request']['duration_seconds'] as int,
        deviceId: json['request']['device_id'] as String,
        timestamp: json['request']['timestamp'] as int?,
      ),
      synced: json['synced'] as bool? ?? false,
    );
  }
}

/// Token刷新请求
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {'refresh_token': refreshToken};
}

/// Token刷新响应
class TokenRefreshResponse {
  final String token;
  final String refreshToken;
  final int expiresAt;

  TokenRefreshResponse({
    required this.token,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory TokenRefreshResponse.fromJson(Map<String, dynamic> json) {
    return TokenRefreshResponse(
      token: json['token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresAt: json['expires_at'] as int,
    );
  }
}
