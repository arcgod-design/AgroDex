// ignore_for_file: prefer_initializing_formals
import 'dart:convert';
import 'package:agrodex_mobile/core/constants/app_constants.dart';
import 'package:agrodex_mobile/core/error/failures.dart';
import 'package:agrodex_mobile/core/network/api_client.dart';
import 'package:agrodex_mobile/core/services/logger_service.dart';
import 'package:agrodex_mobile/core/utils/date_formatter.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/map_batch_model.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/register_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/tokenize_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_registration_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of [MarketplaceRepository] using Supabase and backend APIs,
/// matching React [src/lib/api.ts] exactly.
class SupabaseMarketplaceRepository implements MarketplaceRepository {
  final ApiClient _apiClient;
  final SupabaseClient _supabase;
  final SharedPreferences _prefs;

  static const String _lastBatchIdKey = 'last_registered_batch_id';

  /// Creates a [SupabaseMarketplaceRepository].
  SupabaseMarketplaceRepository({
    required ApiClient apiClient,
    required SupabaseClient supabaseClient,
    required SharedPreferences sharedPreferences,
  }) : _apiClient = apiClient,
       _supabase = supabaseClient,
       _prefs = sharedPreferences;

  @override
  Future<VerifyRegistrationResponse> verifyRegistration(
    VerifyRegistrationRequest request,
  ) async {
    try {
      final response = await _apiClient.post(
        '/api/ai/verify-registration',
        body: request.toJson(),
      );

      if (response is Map<String, dynamic>) {
        return VerifyRegistrationResponse.fromJson(response);
      }
      return VerifyRegistrationResponse.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } catch (e) {
      LoggerService.warn(
        'Express AI verification unavailable, falling back to local verification: $e',
        'SupabaseMarketplaceRepository',
      );
      return VerifyRegistrationResponse(
        ok: true,
        data: generateLocalFallbackVerification(request),
      );
    }
  }

  @override
  Future<RegisterBatchResponse> registerBatch(
    RegisterBatchRequest request,
  ) async {
    final normalizedDate = request.harvestDate.isNotEmpty
        ? DateFormatter.normalizeDate(request.harvestDate)
        : DateFormatter.todayIso();

    final normalizedPayload = {
      ...request.toJson(),
      'harvestDate': normalizedDate,
    };

    final headers = <String, String>{};
    final session = _supabase.auth.currentSession;
    if (session?.accessToken != null) {
      headers['Authorization'] = 'Bearer ${session!.accessToken}';
    }

    try {
      final response = await _supabase.functions.invoke(
        'register-batch',
        body: normalizedPayload,
        headers: headers,
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return RegisterBatchResponse.fromJson(data);
      }
      if (data is Map) {
        return RegisterBatchResponse.fromJson(Map<String, dynamic>.from(data));
      }
      if (data is String && data.isNotEmpty) {
        return RegisterBatchResponse.fromJson(
          jsonDecode(data) as Map<String, dynamic>,
        );
      }

      throw const ServerException('Invalid response from register-batch');
    } on FunctionException catch (e) {
      dynamic serverError;
      try {
        serverError = jsonDecode(e.details.toString());
      } catch (_) {
        try {
          serverError = jsonDecode(e.reasonPhrase ?? '');
        } catch (_) {}
      }

      final reqId = serverError is Map && serverError['id'] != null
          ? ' (Request ID: ${serverError['id']})'
          : '';
      final msg = serverError is Map
          ? (serverError['message'] ??
                serverError['error'] ??
                e.reasonPhrase ??
                'Failed to register batch')
          : (e.reasonPhrase ?? 'Failed to register batch');
      final hint = serverError is Map && serverError['hint'] != null
          ? '\n💡 ${serverError['hint']}'
          : '';

      throw ServerException('$msg$reqId$hint');
    } catch (e) {
      if (e is AppException) rethrow;
      throw ServerException(e.toString());
    }
  }

  @override
  Future<TokenizeBatchResponse> tokenizeBatch(
    TokenizeBatchRequest request, {
    bool isDemoMode = false,
  }) async {
    LoggerService.debug(
      'Calling tokenize-batch with ${request.hcsTransactionIds.length} txs, Demo mode: $isDemoMode',
      'SupabaseMarketplaceRepository',
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (AppConstants.supabaseAnonKey.isNotEmpty) ...{
        'Authorization': 'Bearer ${AppConstants.supabaseAnonKey}',
        'apikey': AppConstants.supabaseAnonKey,
      },
    };

    if (isDemoMode) {
      headers['x-demo-mode'] = 'true';
    }

    try {
      final response = await _apiClient.post(
        '/functions/v1/tokenize-batch',
        body: request.toJson(),
        headers: headers,
        useApiBaseUrl: false,
      );

      if (response is Map<String, dynamic>) {
        return TokenizeBatchResponse.fromJson(response);
      }
      return TokenizeBatchResponse.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } catch (e) {
      LoggerService.error(
        'Tokenize batch error: $e',
        e,
        null,
        'SupabaseMarketplaceRepository',
      );
      if (e is ServerException) {
        final details = e.details;
        if (details is Map) {
          final errDetails = details['error'] ?? 'Failed to tokenize batch';
          final errStack = details['details'] ?? '';
          final ts = details['timestamp'] ?? '';
          final extra = [
            if (errStack.toString().isNotEmpty) 'Details: $errStack',
            if (ts.toString().isNotEmpty) 'Time: $ts',
          ].join('\n\n');
          throw ServerException(
            extra.isNotEmpty ? '$errDetails\n\n$extra' : errDetails.toString(),
            code: e.code,
            details: details,
          );
        }
      }
      rethrow;
    }
  }

  @override
  Future<VerifyBatchResult> verifyBatch(
    String tokenId,
    String serialNumber,
  ) async {
    try {
      final response = await _apiClient.post(
        '/functions/v1/verify-batch',
        body: {
          'tokenId': tokenId,
          'serialNumber': int.tryParse(serialNumber) ?? 1,
        },
        useApiBaseUrl: false,
      );

      if (response is Map<String, dynamic>) {
        return VerifyBatchResult.fromJson(response);
      }
      return VerifyBatchResult.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } on ServerException catch (e) {
      final details = e.details;
      if (e.code == '404' &&
          details is Map &&
          details['stage'] == 'database_query') {
        return VerifyBatchNotFoundResult(
          details: Map<String, dynamic>.from(details),
        );
      }
      final msg = details is Map
          ? (details['error'] ?? details['message'] ?? 'HTTP ${e.code}')
          : e.message;
      throw ServerException('verify-batch failed: $msg', code: e.code);
    }
  }

  @override
  Future<VerifyBatchResult> verifyBatchById(String batchId) async {
    try {
      final response = await _apiClient.get('/api/batches/$batchId');
      if (response is Map<String, dynamic>) {
        return VerifyBatchResult.fromJson(response);
      }
      return VerifyBatchResult.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
    } on ServerException catch (e) {
      final details = e.details;
      if (e.code == '404') {
        return VerifyBatchNotFoundResult(
          details: details is Map ? Map<String, dynamic>.from(details) : null,
        );
      }
      if (e.code == '410') {
        return VerifyBatchDeletedResult(
          details: details is Map ? Map<String, dynamic>.from(details) : null,
        );
      }
      final msg = details is Map
          ? (details['error'] ?? details['message'] ?? 'HTTP ${e.code}')
          : e.message;
      throw ServerException('verifyBatchById failed: $msg', code: e.code);
    }
  }

  @override
  Future<List<MapBatch>> getBatches() async {
    try {
      final data = await _supabase
          .from('batches')
          .select(
            'id, batch_name, location, quantity, harvest_date, status, farmer_id, hcs_tx_id, ai_analysis',
          )
          .order('created_at', ascending: false);

      final list = data as List<dynamic>;
      return list
          .whereType<Map>()
          .map((e) => MapBatch.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      throw ServerException('Failed to fetch batches: $e');
    }
  }

  @override
  Future<void> saveLastRegisteredBatchId(String batchId) async {
    await _prefs.setString(_lastBatchIdKey, batchId);
  }

  @override
  Future<String?> getLastRegisteredBatchId() async {
    return _prefs.getString(_lastBatchIdKey);
  }
}
