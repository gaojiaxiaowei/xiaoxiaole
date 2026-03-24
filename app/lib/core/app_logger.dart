import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 统一日志管理
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static final Logger _simpleLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  /// 调试日志 - 仅在调试模式输出
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _simpleLogger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// 信息日志
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _simpleLogger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 警告日志
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _simpleLogger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 错误日志
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// 致命错误日志
  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  /// 追踪日志 - 仅在调试模式输出
  static void trace(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      _simpleLogger.t(message, error: error, stackTrace: stackTrace);
    }
  }
}
