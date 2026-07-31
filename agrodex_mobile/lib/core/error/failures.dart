import 'package:flutter/foundation.dart';

/// Base abstract class for all application failures in AgroDex.
@immutable
abstract class Failure {
  final String message;
  final String? code;
  final dynamic details;

  const Failure(this.message, {this.code, this.details});

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}

/// Represents server-side errors (HTTP 4xx/5xx or Supabase function failures).
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, super.details});
}

/// Represents network connectivity or timeout errors.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code, super.details});
}

/// Represents authentication or authorization failures (401/403).
class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.code, super.details});
}

/// Represents validation or input format failures (e.g., date formatting).
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, super.details});
}

/// Represents a requested resource not found (404 / batch not found).
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code, super.details});
}

/// Base Exception hierarchy for throwing inside repositories/data sources.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(super.message, {super.code, super.details});
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.details});
}

class AuthException extends AppException {
  const AuthException(super.message, {super.code, super.details});
}

class ValidationException extends AppException {
  const ValidationException(super.message, {super.code, super.details});
}
