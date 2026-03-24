import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:block_blast/game/daily_challenge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DailyChallenge', () {
    test('应该正确创建分数挑战', () {
      final challenge = DailyChallenge(
        date: DateTime(2025, 3, 20),
        type: ChallengeType.score,
        target: 500,
      );

      expect(challenge.date, equals(DateTime(2025, 3, 20)));
      expect(challenge.type, equals(ChallengeType.score));
      expect(challenge.target, equals(500));
      expect(challenge.isCompleted, isFalse);
      expect(challenge.progress, equals(0));
    });

    test('应该正确序列化和反序列化', () {
      final challenge = DailyChallenge(
        date: DateTime(2025, 3, 20),
        type: ChallengeType.clear,
        target: 20,
        isCompleted: true,
        completedTime: DateTime(2025, 3, 20, 10, 30),
        progress: 20,
      );

      final json = challenge.toJson();
      final reloaded = DailyChallenge.fromJson(json);

      expect(reloaded.date, equals(challenge.date));
      expect(reloaded.type, equals(challenge.type));
      expect(reloaded.target, equals(challenge.target));
      expect(reloaded.isCompleted, equals(challenge.isCompleted));
      expect(reloaded.progress, equals(challenge.progress));
    });

    test('应该正确计算进度百分比', () {
      final challenge = DailyChallenge(
        date: DateTime(2025, 3, 20),
        type: ChallengeType.score,
        target: 500,
        progress: 250,
      );

      expect(challenge.progressPercentage, equals(0.5));
    });

    test('进度百分比应该被限制在0.0到1.0之间', () {
      var challenge = DailyChallenge(
        date: DateTime(2025, 3, 20),
        type: ChallengeType.score,
        target: 500,
        progress: 600,
      );
      expect(challenge.progressPercentage, equals(1.0));

      challenge = DailyChallenge(
        date: DateTime(2025, 3, 20),
        type: ChallengeType.score,
        target: 500,
        progress: -10,
      );
      expect(challenge.progressPercentage, equals(0.0));
    });
  });

  group('DailyChallengeManager', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    test('应该生成每日挑战', () {
      final manager = DailyChallengeManager();
      final date = DateTime(2025, 3, 20);
      final challenge = manager.generateChallenge(date);

      expect(challenge.date, equals(date));
      expect(challenge.type, isIn(ChallengeType.values));
      expect(challenge.target, greaterThan(0));
      expect(challenge.isCompleted, isFalse);
      expect(challenge.progress, equals(0));
    });

    test('相同日期应该生成相同的挑战', () {
      final manager = DailyChallengeManager();
      final date = DateTime(2025, 3, 20);

      final challenge1 = manager.generateChallenge(date);
      final challenge2 = manager.generateChallenge(date);

      expect(challenge1.type, equals(challenge2.type));
      expect(challenge1.target, equals(challenge2.target));
    });

    test('不同日期应该生成不同的挑战', () {
      final manager = DailyChallengeManager();
      final date1 = DateTime(2025, 3, 20);
      final date2 = DateTime(2025, 3, 21);

      final challenge1 = manager.generateChallenge(date1);
      final challenge2 = manager.generateChallenge(date2);

      // 很大概率不同（虽然理论上可能相同，但概率极低）
      expect(
        challenge1.type == challenge2.type && challenge1.target == challenge2.target,
        isFalse,
        reason: '不同日期应该生成不同的挑战',
      );
    });

    test('应该正确更新分数挑战进度', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final manager = DailyChallengeManager();

      // 生成一个分数挑战
      final date = DateTime.now();
      var challenge = manager.generateChallenge(date);
      challenge = challenge.copyWith(type: ChallengeType.score, target: 500);

      // 保存初始挑战
      await prefs.setString(
        'block_blast_daily_challenge',
        '{"date":"${date.toIso8601String()}","type":0,"target":500,"isCompleted":false,"progress":0}',
      );

      // 更新进度
      final updated = await manager.updateProgress(score: 300);
      expect(updated.progress, equals(300));
      expect(updated.isCompleted, isFalse);
    });

    test('应该在达到目标时标记为完成', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      final manager = DailyChallengeManager();
      final date = DateTime.now();

      // 保存一个分数挑战
      await prefs.setString(
        'block_blast_daily_challenge',
        '{"date":"${date.toIso8601String()}","type":0,"target":500,"isCompleted":false,"progress":0}',
      );

      // 更新进度到目标值
      final updated = await manager.updateProgress(score: 500);
      expect(updated.progress, equals(500));
      expect(updated.isCompleted, isTrue);
      expect(updated.completedTime, isNotNull);
    });
  });
}
