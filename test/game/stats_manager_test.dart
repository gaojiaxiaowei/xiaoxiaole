import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/game/stats_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ScoreRecord - 分数记录测试', () {
    group('toJson - 序列化', () {
      test('应该正确序列化基础分数记录', () {
        final record = ScoreRecord(100, DateTime(2024, 1, 1, 12, 0));
        
        final json = record.toJson();
        
        expect(json['score'], 100);
        expect(json['date'], '2024-01-01T12:00:00.000');
        expect(json['rowsCleared'], 0);
        expect(json['colsCleared'], 0);
      });

      test('应该正确序列化带消除数据的记录', () {
        final record = ScoreRecord(
          150,
          DateTime(2024, 1, 1, 12, 0),
          rowsCleared: 2,
          colsCleared: 3,
        );
        
        final json = record.toJson();
        
        expect(json['score'], 150);
        expect(json['rowsCleared'], 2);
        expect(json['colsCleared'], 3);
      });

      test('应该正确处理0分记录', () {
        final record = ScoreRecord(0, DateTime(2024, 1, 1));
        
        final json = record.toJson();
        
        expect(json['score'], 0);
      });
    });

    group('fromJson - 反序列化', () {
      test('应该正确反序列化基础记录', () {
        final json = {
          'score': 100,
          'date': '2024-01-01T12:00:00.000',
        };
        
        final record = ScoreRecord.fromJson(json);
        
        expect(record.score, 100);
        expect(record.date, DateTime(2024, 1, 1, 12, 0));
        expect(record.rowsCleared, 0);
        expect(record.colsCleared, 0);
      });

      test('应该正确反序列化带消除数据的记录', () {
        final json = {
          'score': 150,
          'date': '2024-01-01T12:00:00.000',
          'rowsCleared': 2,
          'colsCleared': 3,
        };
        
        final record = ScoreRecord.fromJson(json);
        
        expect(record.score, 150);
        expect(record.rowsCleared, 2);
        expect(record.colsCleared, 3);
      });

      test('应该处理缺失的可选字段（默认为0）', () {
        final json = {
          'score': 100,
          'date': '2024-01-01T12:00:00.000',
        };
        
        final record = ScoreRecord.fromJson(json);
        
        expect(record.rowsCleared, 0);
        expect(record.colsCleared, 0);
      });
    });

    group('序列化往返测试', () {
      test('toJson -> fromJson 应该还原原始对象', () {
        final original = ScoreRecord(
          200,
          DateTime(2024, 6, 15, 14, 30),
          rowsCleared: 5,
          colsCleared: 2,
        );
        
        final json = original.toJson();
        final restored = ScoreRecord.fromJson(json);
        
        expect(restored.score, original.score);
        expect(restored.date, original.date);
        expect(restored.rowsCleared, original.rowsCleared);
        expect(restored.colsCleared, original.colsCleared);
      });

      test('多个记录的序列化往返', () {
        final records = [
          ScoreRecord(100, DateTime(2024, 1, 1), rowsCleared: 1),
          ScoreRecord(200, DateTime(2024, 1, 2), colsCleared: 2),
          ScoreRecord(300, DateTime(2024, 1, 3), rowsCleared: 3, colsCleared: 1),
        ];
        
        final jsonList = records.map((r) => r.toJson()).toList();
        final restored = jsonList.map((json) => ScoreRecord.fromJson(json)).toList();
        
        expect(restored.length, 3);
        expect(restored[0].score, 100);
        expect(restored[1].score, 200);
        expect(restored[2].score, 300);
      });
    });
  });

  group('StatsManager - 分数历史记录测试', () {
    setUp(() {
      // 清空 SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    group('getScoreHistory - 读取历史记录', () {
      test('初始状态应该返回空列表', () async {
        final manager = StatsManager();
        
        final history = await manager.getScoreHistory();
        
        expect(history, isEmpty);
      });

      test('应该正确读取已保存的历史记录', () async {
        final prefs = await SharedPreferences.getInstance();
        final records = [
          {'score': 100, 'date': '2024-01-01T12:00:00.000', 'rowsCleared': 1, 'colsCleared': 0},
          {'score': 200, 'date': '2024-01-02T12:00:00.000', 'rowsCleared': 2, 'colsCleared': 1},
        ];
        await prefs.setString('block_blast_score_history', 
          '[{"score":100,"date":"2024-01-01T12:00:00.000","rowsCleared":1,"colsCleared":0},{"score":200,"date":"2024-01-02T12:00:00.000","rowsCleared":2,"colsCleared":1}]'
        );
        
        final manager = StatsManager();
        final history = await manager.getScoreHistory();
        
        expect(history.length, 2);
        expect(history[0].score, 100);
        expect(history[1].score, 200);
      });

      test('应该处理损坏的JSON数据', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('block_blast_score_history', 'invalid json');
        
        final manager = StatsManager();
        final history = await manager.getScoreHistory();
        
        expect(history, isEmpty);
      });
    });

    group('addScoreToHistory - 添加分数记录', () {
      test('应该添加分数到历史记录', () async {
        final manager = StatsManager();
        
        await manager.addScoreToHistory(100, rowsCleared: 1, colsCleared: 0);
        
        final history = await manager.getScoreHistory();
        expect(history.length, 1);
        expect(history[0].score, 100);
        expect(history[0].rowsCleared, 1);
        expect(history[0].colsCleared, 0);
      });

      test('新记录应该插入到列表开头', () async {
        final manager = StatsManager();
        
        await manager.addScoreToHistory(100);
        await manager.addScoreToHistory(200);
        
        final history = await manager.getScoreHistory();
        expect(history.length, 2);
        expect(history[0].score, 200); // 最新的在前
        expect(history[1].score, 100);
      });

      test('应该只保留最近10局记录', () async {
        final manager = StatsManager();
        
        // 添加15条记录
        for (int i = 1; i <= 15; i++) {
          await manager.addScoreToHistory(i * 10);
        }
        
        final history = await manager.getScoreHistory();
        expect(history.length, 10);
        // 最新的10条记录（150, 140, ..., 60）
        expect(history[0].score, 150);
        expect(history[9].score, 60);
      });

      test('不应该记录0分', () async {
        final manager = StatsManager();
        
        await manager.addScoreToHistory(0);
        
        final history = await manager.getScoreHistory();
        expect(history, isEmpty);
      });

      test('不应该记录负分', () async {
        final manager = StatsManager();
        
        await manager.addScoreToHistory(-10);
        
        final history = await manager.getScoreHistory();
        expect(history, isEmpty);
      });

      test('应该记录日期时间', () async {
        final manager = StatsManager();
        final before = DateTime.now();
        
        await manager.addScoreToHistory(100);
        
        final history = await manager.getScoreHistory();
        expect(history[0].date.isAfter(before.subtract(Duration(seconds: 1))), true);
        expect(history[0].date.isBefore(DateTime.now().add(Duration(seconds: 1))), true);
      });
    });

    group('resetAllStats - 清空统计数据', () {
      test('应该清空分数历史记录', () async {
        final manager = StatsManager();
        
        await manager.addScoreToHistory(100);
        await manager.addScoreToHistory(200);
        
        await manager.resetAllStats();
        
        final history = await manager.getScoreHistory();
        expect(history, isEmpty);
      });

      test('应该清空所有统计数据', () async {
        final manager = StatsManager();
        
        // 添加一些数据
        await manager.incrementTotalGames();
        await manager.updateHighScore(500);
        await manager.addRowsCleared(10);
        await manager.addColsCleared(5);
        await manager.addScoreToHistory(100);
        
        // 重置
        await manager.resetAllStats();
        
        // 验证所有数据被清空
        expect(await manager.getTotalGames(), 0);
        expect(await manager.getHighScore(), 0);
        expect(await manager.getTotalRowsCleared(), 0);
        expect(await manager.getTotalColsCleared(), 0);
        expect(await manager.getScoreHistory(), isEmpty);
      });
    });

    group('综合场景测试', () {
      test('完整游戏流程：添加多个分数并验证历史', () async {
        final manager = StatsManager();
        
        // 模拟多局游戏
        await manager.addScoreToHistory(100, rowsCleared: 1, colsCleared: 0);
        await manager.addScoreToHistory(150, rowsCleared: 2, colsCleared: 1);
        await manager.addScoreToHistory(80, rowsCleared: 1, colsCleared: 0);
        
        final history = await manager.getScoreHistory();
        
        expect(history.length, 3);
        expect(history[0].score, 80); // 最新的
        expect(history[1].score, 150);
        expect(history[2].score, 100);
        
        // 验证消除数据
        expect(history[0].rowsCleared, 1);
        expect(history[0].colsCleared, 0);
        expect(history[1].rowsCleared, 2);
        expect(history[1].colsCleared, 1);
      });

      test('边界情况：刚好10条记录', () async {
        final manager = StatsManager();
        
        // 添加刚好10条
        for (int i = 1; i <= 10; i++) {
          await manager.addScoreToHistory(i * 10);
        }
        
        var history = await manager.getScoreHistory();
        expect(history.length, 10);
        
        // 再添加一条，应该还是10条
        await manager.addScoreToHistory(999);
        history = await manager.getScoreHistory();
        expect(history.length, 10);
        expect(history[0].score, 999); // 最新的
      });
    });
  });

  group('StatsManager - 计时模式测试', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    group('getHighScoreTimed - 计时模式最高分', () {
      test('初始状态应该返回0', () async {
        final manager = StatsManager();
        
        final highScore = await manager.getHighScoreTimed();
        
        expect(highScore, 0);
      });

      test('应该正确读取已保存的最高分', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('block_blast_high_score_timed', 500);
        
        final manager = StatsManager();
        final highScore = await manager.getHighScoreTimed();
        
        expect(highScore, 500);
      });
    });

    group('updateHighScoreTimed - 更新计时模式最高分', () {
      test('首次更新应该保存分数', () async {
        final manager = StatsManager();
        
        await manager.updateHighScoreTimed(300);
        
        final highScore = await manager.getHighScoreTimed();
        expect(highScore, 300);
      });

      test('更高分数应该更新记录', () async {
        final manager = StatsManager();
        
        await manager.updateHighScoreTimed(300);
        await manager.updateHighScoreTimed(500);
        
        final highScore = await manager.getHighScoreTimed();
        expect(highScore, 500);
      });

      test('更低分数不应该更新记录', () async {
        final manager = StatsManager();
        
        await manager.updateHighScoreTimed(500);
        await manager.updateHighScoreTimed(300);
        
        final highScore = await manager.getHighScoreTimed();
        expect(highScore, 500);
      });

      test('相同分数不应该更新记录', () async {
        final manager = StatsManager();
        
        await manager.updateHighScoreTimed(500);
        await manager.updateHighScoreTimed(500);
        
        final highScore = await manager.getHighScoreTimed();
        expect(highScore, 500);
      });

      test('0分不应该更新记录', () async {
        final manager = StatsManager();
        
        await manager.updateHighScoreTimed(0);
        
        final highScore = await manager.getHighScoreTimed();
        expect(highScore, 0);
      });
    });

    group('getScoreHistory - 计时模式分数历史', () {
      test('计时模式应该有独立的历史记录', () async {
        final manager = StatsManager();
        
        // 添加经典模式记录
        await manager.addScoreToHistory(100, mode: GameMode.classic);
        
        // 添加计时模式记录
        await manager.addScoreToHistory(200, mode: GameMode.timed);
        
        // 验证各自的历史记录
        final classicHistory = await manager.getScoreHistory(mode: GameMode.classic);
        final timedHistory = await manager.getScoreHistory(mode: GameMode.timed);
        
        expect(classicHistory.length, 1);
        expect(classicHistory[0].score, 100);
        
        expect(timedHistory.length, 1);
        expect(timedHistory[0].score, 200);
      });

      test('计时模式历史记录初始为空', () async {
        final manager = StatsManager();
        
        final history = await manager.getScoreHistory(mode: GameMode.timed);
        
        expect(history, isEmpty);
      });

      test('计时模式应该只保留最近10局', () async {
        final manager = StatsManager();
        
        // 添加15条计时模式记录
        for (int i = 1; i <= 15; i++) {
          await manager.addScoreToHistory(i * 10, mode: GameMode.timed);
        }
        
        final history = await manager.getScoreHistory(mode: GameMode.timed);
        expect(history.length, 10);
        expect(history[0].score, 150); // 最新的
        expect(history[9].score, 60);  // 最旧的
      });

      test('计时模式不应该记录0分', () async {
        final manager = StatsManager();
        
        await manager.addScoreToHistory(0, mode: GameMode.timed);
        
        final history = await manager.getScoreHistory(mode: GameMode.timed);
        expect(history, isEmpty);
      });
    });

    group('resetAllStats - 清空计时模式数据', () {
      test('应该清空计时模式最高分', () async {
        final manager = StatsManager();
        
        await manager.updateHighScoreTimed(500);
        await manager.resetAllStats();
        
        final highScore = await manager.getHighScoreTimed();
        expect(highScore, 0);
      });

      test('应该清空计时模式历史记录', () async {
        final manager = StatsManager();
        
        await manager.addScoreToHistory(100, mode: GameMode.timed);
        await manager.addScoreToHistory(200, mode: GameMode.timed);
        await manager.resetAllStats();
        
        final history = await manager.getScoreHistory(mode: GameMode.timed);
        expect(history, isEmpty);
      });

      test('应该同时清空经典模式和计时模式数据', () async {
        final manager = StatsManager();
        
        // 添加两种模式的数据
        await manager.updateHighScore(500);
        await manager.updateHighScoreTimed(300);
        await manager.addScoreToHistory(100, mode: GameMode.classic);
        await manager.addScoreToHistory(200, mode: GameMode.timed);
        
        // 重置
        await manager.resetAllStats();
        
        // 验证全部清空
        expect(await manager.getHighScore(), 0);
        expect(await manager.getHighScoreTimed(), 0);
        expect(await manager.getScoreHistory(mode: GameMode.classic), isEmpty);
        expect(await manager.getScoreHistory(mode: GameMode.timed), isEmpty);
      });
    });

    group('综合场景 - 计时模式', () {
      test('完整计时模式游戏流程', () async {
        final manager = StatsManager();
        
        // 模拟多局计时模式游戏
        await manager.addScoreToHistory(150, rowsCleared: 2, colsCleared: 1, mode: GameMode.timed);
        await manager.updateHighScoreTimed(150);
        
        await manager.addScoreToHistory(200, rowsCleared: 3, colsCleared: 0, mode: GameMode.timed);
        await manager.updateHighScoreTimed(200);
        
        await manager.addScoreToHistory(180, rowsCleared: 2, colsCleared: 2, mode: GameMode.timed);
        await manager.updateHighScoreTimed(180); // 这个不会更新，因为180 < 200
        
        final history = await manager.getScoreHistory(mode: GameMode.timed);
        final highScore = await manager.getHighScoreTimed();
        
        expect(history.length, 3);
        expect(history[0].score, 180); // 最新的
        expect(history[1].score, 200);
        expect(history[2].score, 150);
        
        expect(highScore, 200); // 最高分保持200
      });

      test('两种模式互不干扰', () async {
        final manager = StatsManager();
        
        // 经典模式
        await manager.addScoreToHistory(100, mode: GameMode.classic);
        await manager.updateHighScore(100);
        
        // 计时模式
        await manager.addScoreToHistory(200, mode: GameMode.timed);
        await manager.updateHighScoreTimed(200);
        
        // 再添加经典模式
        await manager.addScoreToHistory(150, mode: GameMode.classic);
        await manager.updateHighScore(150);
        
        // 验证各自独立
        final classicHistory = await manager.getScoreHistory(mode: GameMode.classic);
        final timedHistory = await manager.getScoreHistory(mode: GameMode.timed);
        final classicHigh = await manager.getHighScore();
        final timedHigh = await manager.getHighScoreTimed();
        
        expect(classicHistory.length, 2);
        expect(timedHistory.length, 1);
        expect(classicHigh, 150);
        expect(timedHigh, 200);
      });
    });
  });
}
