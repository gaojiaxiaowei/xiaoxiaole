import 'package:dio/dio.dart';
import 'app_logger.dart';

/// 错误类型枚举
enum ErrorType {
  /// 网络错误
  network,
  /// 业务逻辑错误
  business,
  /// 参数错误
  validation,
  /// 权限错误
  permission,
  /// 超时错误
  timeout,
  /// 未知错误
  unknown,
}

/// 统一错误处理
class ErrorHandler {
  /// 记录错误日志
  static void log(
    Object error,
    StackTrace stackTrace, {
    String? context,
    ErrorType? type,
  }) {
    final errorType = type ?? _classifyError(error);
    final message = context != null 
        ? '[${errorType.name}] [$context] $error'
        : '[${errorType.name}] $error';
    
    AppLogger.error(message, error, stackTrace);
  }

  /// 运行同步代码并捕获异常
  static T runGuarded<T>(
    T Function() action, {
    T? defaultValue,
    String? context,
    ErrorType? type,
  }) {
    try {
      return action();
    } catch (e, stack) {
      log(e, stack, context: context, type: type);
      return defaultValue as T;
    }
  }

  /// 运行异步代码并捕获异常
  static Future<T> runGuardedAsync<T>(
    Future<T> Function() action, {
    T? defaultValue,
    String? context,
    ErrorType? type,
  }) async {
    try {
      return await action();
    } catch (e, stack) {
      log(e, stack, context: context, type: type);
      return defaultValue as T;
    }
  }

  /// 将错误转换为用户友好的消息
  static String toUserMessage(Object error, {String? fallback}) {
    final errorType = _classifyError(error);
    
    switch (errorType) {
      case ErrorType.network:
        return '网络连接失败，请检查网络设置';
      case ErrorType.timeout:
        return '请求超时，请稍后重试';
      case ErrorType.permission:
        return '权限不足，请联系管理员';
      case ErrorType.validation:
        return _extractValidationMessage(error);
      case ErrorType.business:
        return _extractBusinessMessage(error);
      case ErrorType.unknown:
      default:
        return fallback ?? '操作失败，请稍后重试';
    }
  }

  /// 分类错误类型
  static ErrorType _classifyError(Object error) {
    // Dio 网络错误
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ErrorType.timeout;
        case DioExceptionType.connectionError:
        case DioExceptionType.badResponse:
          return ErrorType.network;
        default:
          return ErrorType.unknown;
      }
    }

    // 根据错误消息判断
    final errorString = error.toString().toLowerCase();
    
    if (errorString.contains('network') || 
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      return ErrorType.network;
    }
    
    if (errorString.contains('timeout')) {
      return ErrorType.timeout;
    }
    
    if (errorString.contains('permission') || 
        errorString.contains('unauthorized') ||
        errorString.contains('forbidden')) {
      return ErrorType.permission;
    }
    
    if (errorString.contains('invalid') || 
        errorString.contains('required') ||
        errorString.contains('format')) {
      return ErrorType.validation;
    }

    return ErrorType.unknown;
  }

  /// 提取参数验证错误消息
  static String _extractValidationMessage(Object error) {
    final errorString = error.toString();
    
    // 尝试提取具体的验证错误信息
    if (errorString.contains(':')) {
      return errorString.split(':').last.trim();
    }
    
    return '输入信息有误，请检查后重试';
  }

  /// 提取业务错误消息
  static String _extractBusinessMessage(Object error) {
    final errorString = error.toString();
    
    // 尝试提取具体的业务错误信息
    if (errorString.contains(':')) {
      return errorString.split(':').last.trim();
    }
    
    return errorString;
  }
}
