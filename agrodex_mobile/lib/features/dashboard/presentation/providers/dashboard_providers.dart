import 'package:agrodex_mobile/core/network/api_client.dart';
import 'package:agrodex_mobile/features/dashboard/data/repositories/http_dashboard_repository.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/audit_log_model.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/dashboard_health_model.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/dashboard_stats_model.dart';
import 'package:agrodex_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the singleton ApiClient.
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Provider for [DashboardRepository].
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return HttpDashboardRepository(apiClient: client);
});

/// FutureProvider fetching real-time dashboard statistics (KPIs, audit lists, AI Insight).
final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.fetchDashboardStats();
});

/// FutureProvider fetching system health status (Hedera, Supabase, Gemini).
final dashboardHealthProvider = FutureProvider<DashboardHealth>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  return repository.fetchDashboardHealth();
});

/// Filter and pagination state for the verification audit logs table.
@immutable
class AuditLogsFilterState {
  final int page;
  final int limit;
  final String status; // 'all', 'approved', 'flagged'
  final String search;
  final String sortBy;
  final String sortOrder;

  const AuditLogsFilterState({
    this.page = 1,
    this.limit = 10,
    this.status = 'all',
    this.search = '',
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
  });

  AuditLogsFilterState copyWith({
    int? page,
    int? limit,
    String? status,
    String? search,
    String? sortBy,
    String? sortOrder,
  }) {
    return AuditLogsFilterState(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      status: status ?? this.status,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuditLogsFilterState &&
        other.page == page &&
        other.limit == limit &&
        other.status == status &&
        other.search == search &&
        other.sortBy == sortBy &&
        other.sortOrder == sortOrder;
  }

  @override
  int get hashCode =>
      Object.hash(page, limit, status, search, sortBy, sortOrder);
}

/// StateProvider for [AuditLogsFilterState].
final auditLogsFilterProvider = StateProvider<AuditLogsFilterState>(
  (ref) => const AuditLogsFilterState(),
);

/// FutureProvider fetching verification audit logs based on [auditLogsFilterProvider].
final auditLogsProvider = FutureProvider<AuditLogsResponse>((ref) async {
  final repository = ref.watch(dashboardRepositoryProvider);
  final filter = ref.watch(auditLogsFilterProvider);

  return repository.fetchAuditLogs(
    page: filter.page,
    limit: filter.limit,
    status: filter.status,
    search: filter.search,
    sortBy: filter.sortBy,
    sortOrder: filter.sortOrder,
  );
});
