import 'package:flutter/foundation.dart';

/// Generic API response DTO matching React response wrappers ({ ok: boolean, data: ... }).
@immutable
class ApiResponse<T> {
  final bool ok;
  final T? data;
  final String? error;
  final String? message;
  final Map<String, dynamic>? details;

  const ApiResponse({
    required this.ok,
    this.data,
    this.error,
    this.message,
    this.details,
  });

  factory ApiResponse.success(T data, {String? message}) {
    return ApiResponse<T>(ok: true, data: data, message: message);
  }

  factory ApiResponse.error(String error, {Map<String, dynamic>? details}) {
    return ApiResponse<T>(ok: false, error: error, details: details);
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResponse<T>(
      ok: json['ok'] == true || json['success'] == true,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
      error: json['error']?.toString(),
      message: json['message']?.toString(),
      details: json['details'] is Map<String, dynamic>
          ? json['details'] as Map<String, dynamic>
          : null,
    );
  }

  @override
  String toString() => 'ApiResponse(ok: $ok, message: $message, error: $error)';
}
