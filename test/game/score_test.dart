import 'package:flutter_test/flutter_test.dart';
import 'package:block_blast/game/clear.dart';

void main() {
  group('ClearLogic - 计分测试', () {
    group('calculateScore - 基础分数', () {
      test('消除1行应该得10分', () {
        final score = ClearLogic.calculateScore(1, 0);
        expect(score, 10);
      });

      test('消除1列应该得10分', () {
        final score = ClearLogic.calculateScore(0, 1);
        expect(score, 10);
      });

      test('消除2行应该得30分（含小连击）', () {
        final score = ClearLogic.calculateScore(2, 0);
        // 基础分 = 20，小连击+10
        expect(score, 30);
      });

      test('消除2列应该得30分（含小连击）', () {
        final score = ClearLogic.calculateScore(0, 2);
        // 基础分 = 20，小连击+10
        expect(score, 30);
      });

      test('消除1行1列应该得20分基础分', () {
        final score = ClearLogic.calculateScore(1, 1);
        // 基础分 = (1+1) * 10 = 20
        // 总数2，小连击+10
        expect(score, 30);
      });

      test('消除3行应该得60分（含大连击）', () {
        final score = ClearLogic.calculateScore(3, 0);
        // 基础分 = 30，大连击+30
        expect(score, 60);
      });

      test('消除4行应该得90分（含超级连击）', () {
        final score = ClearLogic.calculateScore(4, 0);
        // 基础分 = 40，超级连击+50
        expect(score, 90);
      });

      test('消除0行0列应该得0分', () {
        final score = ClearLogic.calculateScore(0, 0);
        expect(score, 0);
      });

      test('消除5行应该得100分（含超级连击）', () {
        final score = ClearLogic.calculateScore(5, 0);
        // 基础分 = 50，超级连击+50
        expect(score, 100);
      });
    });

    group('calculateScore - 连击加成', () {
      test('消除1行1列（总数2）应该有小连击加成10分', () {
        final score = ClearLogic.calculateScore(1, 1);
        // 基础分 = 20，小连击+10
        expect(score, 30);
      });

      test('消除2行（总数2）应该有小连击加成10分', () {
        final score = ClearLogic.calculateScore(2, 0);
        // 基础分 = 20，小连击+10
        expect(score, 30);
      });

      test('消除2列（总数2）应该有小连击加成10分', () {
        final score = ClearLogic.calculateScore(0, 2);
        // 基础分 = 20，小连击+10
        expect(score, 30);
      });

      test('消除3行（总数3）应该有大连击加成30分', () {
        final score = ClearLogic.calculateScore(3, 0);
        // 基础分 = 30，大连击+30
        expect(score, 60);
      });

      test('消除2行1列（总数3）应该有大连击加成30分', () {
        final score = ClearLogic.calculateScore(2, 1);
        // 基础分 = 30，大连击+30
        expect(score, 60);
      });

      test('消除1行2列（总数3）应该有大连击加成30分', () {
        final score = ClearLogic.calculateScore(1, 2);
        // 基础分 = 30，大连击+30
        expect(score, 60);
      });

      test('消除4行（总数4）应该有超级连击加成50分', () {
        final score = ClearLogic.calculateScore(4, 0);
        // 基础分 = 40，超级连击+50
        expect(score, 90);
      });

      test('消除2行2列（总数4）应该有超级连击加成50分', () {
        final score = ClearLogic.calculateScore(2, 2);
        // 基础分 = 40，超级连击+50
        expect(score, 90);
      });

      test('消除5行（总数5）应该有超级连击加成50分', () {
        final score = ClearLogic.calculateScore(5, 0);
        // 基础分 = 50，超级连击+50
        expect(score, 100);
      });

      test('消除3行2列（总数5）应该有超级连击加成50分', () {
        final score = ClearLogic.calculateScore(3, 2);
        // 基础分 = 50，超级连击+50
        expect(score, 100);
      });

      test('消除8行8列（全清）应该有最高分数', () {
        final score = ClearLogic.calculateScore(8, 8);
        // 基础分 = 160，超级连击+50
        expect(score, 210);
      });
    });

    group('calculateScore - 边界情况', () {
      test('单行消除无连击加成', () {
        final score = ClearLogic.calculateScore(1, 0);
        // 基础分 = 10，无连击（总数1）
        expect(score, 10);
      });

      test('单列消除无连击加成', () {
        final score = ClearLogic.calculateScore(0, 1);
        // 基础分 = 10，无连击（总数1）
        expect(score, 10);
      });

      test('6行消除应该有超级连击', () {
        final score = ClearLogic.calculateScore(6, 0);
        // 基础分 = 60，超级连击+50
        expect(score, 110);
      });

      test('7行消除应该有超级连击', () {
        final score = ClearLogic.calculateScore(7, 0);
        // 基础分 = 70，超级连击+50
        expect(score, 120);
      });

      test('8行消除（全清）应该有超级连击', () {
        final score = ClearLogic.calculateScore(8, 0);
        // 基础分 = 80，超级连击+50
        expect(score, 130);
      });

      test('4行4列消除应该有超级连击', () {
        final score = ClearLogic.calculateScore(4, 4);
        // 基础分 = 80，超级连击+50
        expect(score, 130);
      });
    });

    group('calculateScore - 综合场景', () {
      test('典型游戏场景：消除2行得30分', () {
        // 玩家放置一个横条，消除了2行
        final score = ClearLogic.calculateScore(2, 0);
        expect(score, 30);
      });

      test('典型游戏场景：消除1行1列得30分', () {
        // 玩家放置一个L形，同时消除1行1列
        final score = ClearLogic.calculateScore(1, 1);
        expect(score, 30);
      });

      test('高分场景：消除3行得60分', () {
        // 高水平玩家同时消除3行
        final score = ClearLogic.calculateScore(3, 0);
        expect(score, 60);
      });

      test('完美消除：十字消除（2行2列）得90分', () {
        // 放置十字形方块，消除2行2列
        final score = ClearLogic.calculateScore(2, 2);
        expect(score, 90);
      });

      test('极限消除：消除4行4列得130分', () {
        // 极限操作，消除4行4列
        final score = ClearLogic.calculateScore(4, 4);
        expect(score, 130);
      });

      test('最大消除：全清（8行8列）得210分', () {
        // 游戏历史最高分一次消除
        final score = ClearLogic.calculateScore(8, 8);
        expect(score, 210);
      });
    });

    group('calculateScore - 分数递增规律', () {
      test('消除数量递增，分数应该递增', () {
        final scores = <int>[];
        for (int i = 0; i <= 8; i++) {
          scores.add(ClearLogic.calculateScore(i, 0));
        }
        
        // 验证分数递增
        for (int i = 1; i < scores.length; i++) {
          expect(scores[i], greaterThan(scores[i - 1]));
        }
      });

      test('连击加成应该跳跃式增加', () {
        // 总数1 -> 总数2：+20分（10基础+10连击）
        final score1 = ClearLogic.calculateScore(1, 0);
        final score2 = ClearLogic.calculateScore(2, 0);
        expect(score2 - score1, 20);
        
        // 总数2 -> 总数3：+30分（10基础+20连击差）
        final score3 = ClearLogic.calculateScore(3, 0);
        expect(score3 - score2, 30);
        
        // 总数3 -> 总数4：+30分（10基础+20连击差）
        final score4 = ClearLogic.calculateScore(4, 0);
        expect(score4 - score3, 30);
      });
    });
  });
}
