import 'package:agrodex_mobile/features/dashboard/domain/models/audit_log_model.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/dashboard_health_model.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/dashboard_stats_model.dart';

/// Abstract repository contract for Dashboard statistics, health checks, and audit logs.
abstract class DashboardRepository {
  /// Fetches KPIs, audit overview, and AI insights from `/api/dashboard-stats`.
  Future<DashboardStats> fetchDashboardStats();

  /// Fetches real-time service status for Hedera, Supabase, and Gemini from `/api/dashboard-health`.
  Future<DashboardHealth> fetchDashboardHealth();

  /// Fetches paginated, searchable, and sortable verification audit logs from Supabase function `audit-logs`.
  Future<AuditLogsResponse> fetchAuditLogs({
    int page = 1,
    int limit = 10,
    String status = 'all',
    String search = '',
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  });
}
