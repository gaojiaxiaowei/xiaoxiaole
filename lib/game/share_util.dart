import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'stats_manager.dart';
import '../core/app_logger.dart';

/// 分享工具类
class ShareUtil {
  /// 分享游戏成绩
  ///
  /// [score] - 分数
  /// [rowsCleared] - 消除行数
  /// [colsCleared] - 消除列数
  /// [gameMode] - 游戏模式
  /// [maxCombo] - 最高连击（可选）
  static Future<bool> shareGameResult({
    required int score,
    required int rowsCleared,
    required int colsCleared,
    required GameMode gameMode,
    int maxCombo = 0,
  }) async {
    try {
      // 构建分享文本
      final modeText = gameMode == GameMode.classic ? '经典模式' : '计时模式';
      final buffer = StringBuffer();

      buffer.writeln('🎮 Block Blast 游戏战绩');
      buffer.writeln('');
      buffer.writeln('📊 模式: $modeText');
      buffer.writeln('🏆 分数: $score');
      buffer.writeln('📏 消除行数: $rowsCleared');
      buffer.writeln('📐 消除列数: $colsCleared');

      if (maxCombo > 0) {
        buffer.writeln('⚡ 最高连击: $maxCombo');
      }

      buffer.writeln('');
      buffer.writeln('来挑战我的分数吧！');

      // 调用系统分享面板
      await Share.share(
        buffer.toString(),
        subject: 'Block Blast 游戏战绩',
      );

      return true;
    } on MissingPluginException catch (e) {
      // 测试环境中插件不可用
      AppLogger.warning('分享功能在当前环境不可用: $e');
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('分享失败', e, stackTrace);
      return false;
    }
  }
  
  /// 分享游戏成绩（带截图）
  ///
  /// [score] - 分数
  /// [rowsCleared] - 消除行数
  /// [colsCleared] - 消除列数
  /// [gameMode] - 游戏模式
  /// [maxCombo] - 最高连击（可选）
  /// [imagePath] - 截图路径
  static Future<bool> shareGameResultWithImage({
    required int score,
    required int rowsCleared,
    required int colsCleared,
    required GameMode gameMode,
    int maxCombo = 0,
    required String imagePath,
  }) async {
    try {
      // 构建分享文本
      final modeText = gameMode == GameMode.classic ? '经典模式' : '计时模式';
      final buffer = StringBuffer();

      buffer.writeln('🎮 Block Blast 游戏战绩');
      buffer.writeln('');
      buffer.writeln('📊 模式: $modeText');
      buffer.writeln('🏆 分数: $score');
      buffer.writeln('📏 消除行数: $rowsCleared');
      buffer.writeln('📐 消除列数: $colsCleared');

      if (maxCombo > 0) {
        buffer.writeln('⚡ 最高连击: $maxCombo');
      }

      buffer.writeln('');
      buffer.writeln('来挑战我的分数吧！');

      // 调用系统分享面板（带图片）
      await Share.shareXFiles(
        [XFile(imagePath)],
        text: buffer.toString(),
        subject: 'Block Blast 游戏战绩',
      );

      return true;
    } on MissingPluginException catch (e) {
      // 测试环境中插件不可用
      AppLogger.warning('分享功能在当前环境不可用: $e');
      return false;
    } catch (e, stackTrace) {
      AppLogger.error('分享失败', e, stackTrace);
      return false;
    }
  }
}
