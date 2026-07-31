import 'dart:convert';
import 'package:agrodex_mobile/core/constants/app_constants.dart';
import 'package:agrodex_mobile/core/error/failures.dart';
import 'package:agrodex_mobile/core/services/logger_service.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;

/// Clean HTTP Client for making REST API calls to Supabase Edge Functions
/// and the backend Express API (VITE_API_BASE_URL).
/// Automatically injects Authorization Bearer and apikey headers.
class ApiClient {
  final http.Client _client;
  final SupabaseClient? _supabase;

  ApiClient({http.Client? client, SupabaseClient? supabaseClient})
    : _client = client ?? http.Client(),
      _supabase = supabaseClient;

  /// Builds standardized authorization headers matching React buildAuthHeaders().
  Future<Map<String, String>> buildHeaders({
    Map<String, String>? additionalHeaders,
    bool includeApiKey = false,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeApiKey && AppConstants.supabaseAnonKey.isNotEmpty) {
      headers['apikey'] = AppConstants.supabaseAnonKey;
      headers['Authorization'] = 'Bearer ${AppConstants.supabaseAnonKey}';
    }

    try {
      final session = _supabase?.auth.currentSession;
      if (session?.accessToken != null) {
        headers['Authorization'] = 'Bearer ${session!.accessToken}';
      }
    } catch (e) {
      LoggerService.warn(
        'Failed to retrieve current Supabase session token: $e',
        'ApiClient',
      );
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Sends HTTP GET request and parses JSON response.
  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    bool useApiBaseUrl = true,
    bool includeApiKey = false,
  }) async {
    final baseUrl = useApiBaseUrl ? AppConstants.apiBaseUrl : '';
    final url = Uri.parse('$baseUrl$endpoint');
    final mergedHeaders = await buildHeaders(
      additionalHeaders: headers,
      includeApiKey: includeApiKey,
    );

    LoggerService.debug('GET $url', 'ApiClient');

    try {
      final response = await _client
          .get(url, headers: mergedHeaders)
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Sends HTTP POST request with JSON body.
  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    bool useApiBaseUrl = true,
    bool includeApiKey = false,
  }) async {
    final baseUrl = useApiBaseUrl ? AppConstants.apiBaseUrl : '';
    final url = Uri.parse('$baseUrl$endpoint');
    final mergedHeaders = await buildHeaders(
      additionalHeaders: headers,
      includeApiKey: includeApiKey,
    );

    LoggerService.debug('POST $url', 'ApiClient');

    try {
      final response = await _client
          .post(
            url,
            headers: mergedHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Sends HTTP PATCH request with JSON body.
  Future<dynamic> patch(
    String endpoint, {
    required Map<String, dynamic> body,
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    final mergedHeaders = await buildHeaders(additionalHeaders: headers);

    LoggerService.debug('PATCH $url', 'ApiClient');

    try {
      final response = await _client
          .patch(url, headers: mergedHeaders, body: jsonEncode(body))
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Sends HTTP DELETE request.
  Future<dynamic> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');
    final mergedHeaders = await buildHeaders(additionalHeaders: headers);

    LoggerService.debug('DELETE $url', 'ApiClient');

    try {
      final response = await _client
          .delete(url, headers: mergedHeaders)
          .timeout(const Duration(seconds: 30));
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _handleResponse(http.Response response) {
    dynamic payload;
    try {
      if (response.body.isNotEmpty) {
        payload = jsonDecode(response.body);
      }
    } catch (_) {
      payload = null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload ?? <String, dynamic>{'ok': true};
    }

    if (response.statusCode == 401) {
      throw const AuthException(
        'Authentication session is missing or has expired. Please log in again.',
      );
    }
    if (response.statusCode == 429) {
      throw const ServerException(
        'Too many requests. Please slow down and try again later.',
      );
    }

    final message = payload is Map
        ? (payload['error'] ??
              payload['message'] ??
              payload['details'] ??
              'HTTP ${response.statusCode}')
        : 'HTTP ${response.statusCode}';

    throw ServerException(
      message.toString(),
      code: response.statusCode.toString(),
      details: payload,
    );
  }

  AppException _handleError(Object e) {
    if (e is AppException) return e;
    return NetworkException('Network error: $e');
  }
}
