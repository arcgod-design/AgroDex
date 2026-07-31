import 'package:agrodex_mobile/core/constants/app_constants.dart';
import 'package:agrodex_mobile/core/error/failures.dart';
import 'package:agrodex_mobile/core/network/api_client.dart';
import 'package:agrodex_mobile/core/services/logger_service.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/audit_log_model.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/dashboard_health_model.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/dashboard_stats_model.dart';
import 'package:agrodex_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';

/// Concrete implementation of [DashboardRepository] over HTTP and Supabase edge functions.
class HttpDashboardRepository implements DashboardRepository {
  final ApiClient _apiClient;

  HttpDashboardRepository({required this._apiClient});

  @override
  Future<DashboardStats> fetchDashboardStats() async {
    try {
      final response = await _apiClient.get('/api/dashboard-stats');
      if (response is Map<String, dynamic>) {
        return DashboardStats.fromJson(response);
      }
      throw const ServerFailure('Invalid payload from dashboard-stats');
    } on Failure {
      rethrow;
    } catch (e, st) {
      LoggerService.error(
        'Failed to fetch dashboard stats',
        e,
        st,
        'HttpDashboardRepository',
      );
      throw ServerFailure('Failed to fetch dashboard stats: $e');
    }
  }

  @override
  Future<DashboardHealth> fetchDashboardHealth() async {
    try {
      final response = await _apiClient.get('/api/dashboard-health');
      if (response is Map<String, dynamic>) {
        return DashboardHealth.fromJson(response);
      }
      throw const ServerFailure('Invalid payload from dashboard-health');
    } on Failure {
      rethrow;
    } catch (e, st) {
      LoggerService.error(
        'Failed to fetch dashboard health',
        e,
        st,
        'HttpDashboardRepository',
      );
      throw ServerFailure('Failed to fetch dashboard health: $e');
    }
  }

  @override
  Future<AuditLogsResponse> fetchAuditLogs({
    int page = 1,
    int limit = 10,
    String status = 'all',
    String search = '',
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': '$page',
        'limit': '$limit',
        'status': status,
        'search': search,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };
      final uri = Uri.parse(
        '${AppConstants.supabaseUrl}/functions/v1/audit-logs',
      ).replace(queryParameters: queryParams);

      final response = await _apiClient.get(
        uri.toString(),
        useApiBaseUrl: false,
        includeApiKey: true,
      );

      if (response is Map<String, dynamic>) {
        return AuditLogsResponse.fromJson(response);
      }
      throw const ServerFailure('Invalid payload from audit-logs');
    } on Failure {
      rethrow;
    } catch (e, st) {
      LoggerService.error(
        'Failed to fetch audit logs',
        e,
        st,
        'HttpDashboardRepository',
      );
      throw ServerFailure('Failed to fetch audit logs: $e');
    }
  }
}
