import 'package:flutter/foundation.dart';

/// Clean logging service for debugging API calls, state changes, and errors.
class LoggerService {
  LoggerService._();

  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('🐛 $prefix$message');
    }
  }

  static void info(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('ℹ️ $prefix$message');
    }
  }

  static void warn(String message, [String? tag]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('⚠️ $prefix$message');
    }
  }

  static void error(
    String message, [
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  ]) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('❌ $prefix$message');
      if (error != null) debugPrint('Error: $error');
      if (stackTrace != null) debugPrint('StackTrace:\n$stackTrace');
    }
  }
}
