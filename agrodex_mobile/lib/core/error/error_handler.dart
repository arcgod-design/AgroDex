import 'dart:convert';
import 'package:agrodex_mobile/core/error/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Global error handler utility to transform exceptions and Supabase errors
/// into clean, user-friendly [Failure] instances.
class ErrorHandler {
  ErrorHandler._();

  /// Converts any thrown [Object] into a typed [Failure].
  static Failure handle(Object error) {
    if (error is Failure) {
      return error;
    }

    if (error is AppException) {
      return _mapExceptionToFailure(error);
    }

    if (error is supabase.AuthException) {
      return AuthFailure(error.message, code: error.statusCode);
    }

    if (error is supabase.FunctionException) {
      return _parseFunctionException(error);
    }

    if (error is supabase.PostgrestException) {
      return ServerFailure(
        error.message,
        code: error.code,
        details: error.details,
      );
    }

    // Attempt JSON parse if error message contains structured JSON
    final message = error.toString();
    try {
      final parsed = jsonDecode(message);
      if (parsed is Map<String, dynamic>) {
        final errText =
            parsed['error'] ??
            parsed['message'] ??
            'An unexpected error occurred';
        final hint = parsed['hint'] != null ? '\n💡 ${parsed['hint']}' : '';
        return ServerFailure('$errText$hint');
      }
    } catch (_) {
      // Ignore JSON parse error
    }

    return ServerFailure(message.replaceAll('Exception: ', ''));
  }

  static Failure _mapExceptionToFailure(AppException exception) {
    if (exception is AuthException) {
      return AuthFailure(exception.message, code: exception.code);
    }
    if (exception is ValidationException) {
      return ValidationFailure(exception.message, code: exception.code);
    }
    if (exception is NetworkException) {
      return NetworkFailure(exception.message, code: exception.code);
    }
    return ServerFailure(
      exception.message,
      code: exception.code,
      details: exception.details,
    );
  }

  static Failure _parseFunctionException(supabase.FunctionException error) {
    try {
      if (error.details != null && error.details is Map) {
        final map = error.details as Map;
        final msg = map['error'] ?? map['message'] ?? 'Edge Function error';
        final hint = map['hint'] != null ? '\n💡 ${map['hint']}' : '';
        return ServerFailure('$msg$hint', code: error.status.toString());
      }
    } catch (_) {
      // Ignore
    }
    return ServerFailure(
      error.reasonPhrase ?? 'Failed to invoke Supabase Edge Function',
      code: error.status.toString(),
    );
  }
}
