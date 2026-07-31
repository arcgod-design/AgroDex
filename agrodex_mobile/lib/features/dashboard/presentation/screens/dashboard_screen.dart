import 'package:agrodex_mobile/core/router/app_router.dart';
import 'package:agrodex_mobile/core/theme/app_theme.dart';
import 'package:agrodex_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/dashboard_stats_model.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/widgets/ai_insight_card_widget.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/widgets/audit_journal_card_widget.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/widgets/kpi_grid_widget.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/widgets/recent_activities_card_widget.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/widgets/service_status_card_widget.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/widgets/tech_stack_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Production Dashboard screen matching React `src/pages/Dashboard.tsx`.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final healthAsync = ref.watch(dashboardHealthProvider);
    final auditLogsAsync = ref.watch(auditLogsProvider);
    final filterState = ref.watch(auditLogsFilterProvider);

    final isBackendUnavailable =
        healthAsync.hasError ||
        statsAsync.hasError ||
        (healthAsync.valueOrNull?.status != null &&
            (!healthAsync.valueOrNull!.status!.supabase.ok ||
                !healthAsync.valueOrNull!.status!.hedera.ok ||
                !healthAsync.valueOrNull!.status!.gemini.ok));

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shield_outlined, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Text(
              'AgroDex',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () => context.go(AppRoute.appHub.path),
            icon: const Icon(Icons.home_outlined, size: 18),
            label: const Text('Hub'),
          ),
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dashboardStatsProvider);
          ref.invalidate(dashboardHealthProvider);
          ref.invalidate(auditLogsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Hero Banner
              _buildHeroSection(context),
              // Body content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isBackendUnavailable)
                      _buildUnavailableBanner(context, ref),
                    // KPI Grid
                    KpiGridWidget(
                      kpis:
                          statsAsync.valueOrNull?.kpis ??
                          const DashboardKpis(
                            totalBatches: 0,
                            totalNfts: 0,
                            totalVerifications: 0,
                            aiVerified: 0,
                          ),
                      flaggedCount:
                          statsAsync.valueOrNull?.audit.flaggedLots.length ?? 0,
                      isLoading: statsAsync.isLoading,
                    ),
                    const SizedBox(height: 20),
                    // AI Insight Card
                    AiInsightCardWidget(
                      insight: statsAsync.valueOrNull?.aiInsight,
                      generatedAt: statsAsync.valueOrNull?.generatedAt,
                      isLoading: statsAsync.isLoading,
                      errorMessage: statsAsync.error?.toString(),
                    ),
                    const SizedBox(height: 20),
                    // Audit Journal and Service Status
                    AuditJournalCardWidget(
                      logsResponse: auditLogsAsync.valueOrNull,
                      isLoading: auditLogsAsync.isLoading,
                      errorMessage: auditLogsAsync.error?.toString(),
                      search: filterState.search,
                      status: filterState.status,
                      sortBy: filterState.sortBy,
                      sortOrder: filterState.sortOrder,
                      onSearchChanged: (val) {
                        ref.read(auditLogsFilterProvider.notifier).state =
                            filterState.copyWith(search: val, page: 1);
                      },
                      onStatusChanged: (val) {
                        ref.read(auditLogsFilterProvider.notifier).state =
                            filterState.copyWith(status: val, page: 1);
                      },
                      onSortChanged: (val) {
                        final parts = val.split(':');
                        ref
                            .read(auditLogsFilterProvider.notifier)
                            .state = filterState.copyWith(
                          sortBy: parts[0],
                          sortOrder: parts.length > 1 ? parts[1] : 'desc',
                          page: 1,
                        );
                      },
                      onPageChanged: (newPage) {
                        ref.read(auditLogsFilterProvider.notifier).state =
                            filterState.copyWith(page: newPage);
                      },
                    ),
                    const SizedBox(height: 20),
                    ServiceStatusCardWidget(
                      healthStatus: healthAsync.valueOrNull?.status,
                      isLoading: healthAsync.isLoading,
                      errorMessage: healthAsync.error?.toString(),
                    ),
                    const SizedBox(height: 20),
                    // Recent Activities
                    RecentActivitiesCardWidget(
                      audit:
                          statsAsync.valueOrNull?.audit ??
                          const DashboardAudit(
                            approvedLots: [],
                            flaggedLots: [],
                          ),
                    ),
                    const SizedBox(height: 20),
                    // Technology Stack
                    const TechStackCardWidget(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.12),
            const Color(0xFF2563EB).withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 14,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  'Powered by Hedera + AI',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
              children: [
                const TextSpan(text: 'Fighting '),
                TextSpan(
                  text: 'Food Fraud ',
                  style: TextStyle(color: AppTheme.primaryGreen),
                ),
                const TextSpan(text: 'in Indonesia'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Blockchain verification and AI-driven fraud detection for agricultural supply chains.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnavailableBanner(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: theme.colorScheme.onErrorContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard temporarily unavailable',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Some backend services (HTTP 503) are unreachable or degraded.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onErrorContainer.withValues(
                      alpha: 0.9,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () {
              ref.invalidate(dashboardStatsProvider);
              ref.invalidate(dashboardHealthProvider);
              ref.invalidate(auditLogsProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: theme.colorScheme.onError,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
