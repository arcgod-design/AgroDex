import 'package:agrodex_mobile/core/error/failures.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/audit_log_model.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/dashboard_health_model.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/dashboard_stats_model.dart';
import 'package:agrodex_mobile/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/screens/app_hub_screen.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/widgets/ai_insight_card_widget.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/widgets/kpi_grid_widget.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/widgets/service_status_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeDashboardRepository implements DashboardRepository {
  DashboardStats statsToReturn = const DashboardStats(
    kpis: DashboardKpis(
      totalBatches: 120,
      totalNfts: 105,
      totalVerifications: 350,
      aiVerified: 98,
    ),
    aiInsight: AiInsight(
      insightEn: 'Supply chain integrity verified via Hedera HCS.',
    ),
    audit: DashboardAudit(approvedLots: [], flaggedLots: []),
    generatedAt: '2026-07-30T12:00:00Z',
  );

  DashboardHealth healthToReturn = const DashboardHealth(
    status: HealthStatus(
      hedera: ServiceStatus(ok: true, ms: 45),
      supabase: ServiceStatus(ok: true, ms: 12),
      gemini: ServiceStatus(ok: true, ms: 120, model: 'gemini-3.1-flash-lite'),
    ),
  );

  AuditLogsResponse auditLogsToReturn = const AuditLogsResponse(
    ok: true,
    data: [
      AuditLogEntry(
        tokenId: '0.0.123456',
        serialNumber: '1',
        status: 'approved',
        score: 95,
        rationale: 'All checks passed',
        verifiedAt: '2026-07-30T11:00:00Z',
        trustExplanation: 'All checks passed',
      ),
    ],
    pagination: AuditLogsPagination(
      totalRecords: 1,
      totalPages: 1,
      currentPage: 1,
      limit: 10,
    ),
  );

  @override
  Future<DashboardStats> fetchDashboardStats() async => statsToReturn;

  @override
  Future<DashboardHealth> fetchDashboardHealth() async => healthToReturn;

  @override
  Future<AuditLogsResponse> fetchAuditLogs({
    String search = '',
    String status = 'all',
    int page = 1,
    int limit = 10,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async => auditLogsToReturn;
}

class FakeDegradedDashboardRepository extends FakeDashboardRepository {
  @override
  Future<DashboardHealth> fetchDashboardHealth() async {
    throw const ServerFailure(
      'Failed to fetch dashboard health: ServerException: HTTP 503',
    );
  }
}

void main() {
  group('Dashboard Domain Models Tests', () {
    test('DashboardStats serializes and deserializes from JSON correctly', () {
      final json = {
        'kpis': {
          'totalBatches': 50,
          'totalNfts': 45,
          'totalVerifications': 100,
          'aiVerified': 48,
        },
        'aiInsight': {'insight_en': 'Consistent ledger data.', 'error': null},
        'audit': {'approvedLots': [], 'flaggedLots': []},
        'generatedAt': '2026-07-30T10:00:00Z',
      };

      final stats = DashboardStats.fromJson(json);
      expect(stats.kpis.totalBatches, 50);
      expect(stats.kpis.totalNfts, 45);
      expect(stats.aiInsight?.insightEn, 'Consistent ledger data.');
      expect(stats.generatedAt, '2026-07-30T10:00:00Z');
    });

    test('AiInsight.getCleanError cleans error messages matching React', () {
      expect(
        AiInsight.getCleanError('status: 503 Service Unavailable'),
        'AI Insights are currently unavailable due to a temporary service error.',
      );
      expect(
        AiInsight.getCleanError('Some general network timeout occurred'),
        'Some general network timeout occurred',
      );
      expect(AiInsight.getCleanError(null), null);
    });

    test('DashboardHealth parses status and response time correctly', () {
      final json = {
        'status': {
          'hedera': {'ok': true, 'ms': 30},
          'supabase': {'ok': true, 'ms': 15},
          'gemini': {'ok': false, 'ms': 0, 'error': 'Quota exceeded'},
        },
        'timestamp': '2026-07-30T10:00:00Z',
      };

      final health = DashboardHealth.fromJson(json);
      expect(health.status!.hedera.ok, true);
      expect(health.status!.gemini.ok, false);
      expect(health.status!.gemini.error, 'Quota exceeded');
    });

    test('AuditLogsResponse parses entries and pagination info', () {
      final json = {
        'data': [
          {
            'token_id': '0.0.999',
            'serial_number': '5',
            'status': 'approved',
            'score': 92,
            'rationale': 'Passed',
            'verified_at': '2026-07-30T10:00:00Z',
          },
        ],
        'pagination': {
          'total_records': 1,
          'total_pages': 1,
          'current_page': 1,
          'limit': 10,
        },
      };

      final res = AuditLogsResponse.fromJson(json);
      expect(res.data.length, 1);
      expect(res.data.first.tokenId, '0.0.999');
      expect(res.data.first.score, 92);
      expect(res.pagination.totalRecords, 1);
    });
  });

  group('Dashboard Riverpod Providers Unit Tests', () {
    test('auditLogsFilterProvider updates search and status state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final filter = container.read(auditLogsFilterProvider);
      expect(filter.search, '');
      expect(filter.status, 'all');

      container.read(auditLogsFilterProvider.notifier).state = filter.copyWith(
        search: '0.0.123',
        status: 'approved',
      );

      final updated = container.read(auditLogsFilterProvider);
      expect(updated.search, '0.0.123');
      expect(updated.status, 'approved');
    });

    test('dashboardStatsProvider returns data from repository', () async {
      final fakeRepo = FakeDashboardRepository();
      final container = ProviderContainer(
        overrides: [dashboardRepositoryProvider.overrideWithValue(fakeRepo)],
      );
      addTearDown(container.dispose);

      final stats = await container.read(dashboardStatsProvider.future);
      expect(stats.kpis.totalBatches, 120);
      expect(stats.kpis.totalNfts, 105);
      expect(
        stats.aiInsight?.insightEn,
        'Supply chain integrity verified via Hedera HCS.',
      );
    });
  });

  group('Dashboard UI Widgets Tests', () {
    testWidgets('KpiGridWidget renders 3 KPI cards with titles and values', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: KpiGridWidget(
              kpis: DashboardKpis(
                totalBatches: 25,
                totalNfts: 20,
                totalVerifications: 60,
                aiVerified: 19,
              ),
              flaggedCount: 1,
            ),
          ),
        ),
      );

      expect(find.text('Registered Batches'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
      expect(find.text('NFTs Created'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
      expect(find.text('AI Verifications'), findsOneWidget);
      expect(find.text('19'), findsOneWidget);
    });

    testWidgets('AiInsightCardWidget renders title and insight text', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AiInsightCardWidget(
              insight: AiInsight(
                insightEn: 'Verified Hedera ledger records match AI scan.',
              ),
              generatedAt: '2026-07-30T12:00:00Z',
            ),
          ),
        ),
      );

      expect(find.text('AI Insight'), findsOneWidget);
      expect(
        find.textContaining('Verified Hedera ledger records match AI scan.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'ServiceStatusCardWidget displays Hedera, Supabase and Gemini statuses',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: ServiceStatusCardWidget(
                healthStatus: HealthStatus(
                  hedera: ServiceStatus(ok: true, ms: 25),
                  supabase: ServiceStatus(ok: true, ms: 10),
                  gemini: ServiceStatus(
                    ok: true,
                    ms: 110,
                    model: 'gemini-3.1-flash-lite',
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('System Service Status'), findsOneWidget);
        expect(find.text('Hedera Mirror Node'), findsOneWidget);
        expect(find.text('Supabase DB'), findsOneWidget);
        expect(find.text('Gemini AI (gemini-3.1-flash-lite)'), findsOneWidget);
        expect(find.text('Operational'), findsWidgets);
      },
    );
  });

  group('Dashboard Screen Integration Tests', () {
    testWidgets('DashboardScreen renders hero banner and all child cards', (
      tester,
    ) async {
      final fakeRepo = FakeDashboardRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [dashboardRepositoryProvider.overrideWithValue(fakeRepo)],
          child: const MaterialApp(home: DashboardScreen()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('AgroDex'), findsWidgets);
      expect(find.text('Powered by Hedera + AI'), findsOneWidget);
      expect(find.byType(RichText), findsWidgets);
      expect(find.text('Registered Batches'), findsOneWidget);
      expect(find.text('120'), findsOneWidget);
      expect(find.text('Verification Audit Journal'), findsOneWidget);
      expect(find.text('0.0.123456 (S/N: 1)'), findsOneWidget);
      expect(find.text('System Service Status'), findsOneWidget);
      expect(find.text('Technology Stack'), findsOneWidget);
    });

    testWidgets('AppHubScreen renders hero and quick access navigation hub', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AppHubScreen())),
      );

      expect(find.text('AgroDex Hub'), findsOneWidget);
      expect(find.text('Fighting Food Fraud in Indonesia'), findsOneWidget);
      expect(find.text('Quick Access Hub'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Verify Batch'), findsWidgets);
      expect(find.text('Register Batch'), findsOneWidget);
      expect(find.text('Tokenize'), findsOneWidget);
      expect(find.text('Food Fraud Costs Billions'), findsOneWidget);
      expect(find.text('AgroDex: Blockchain + AI'), findsOneWidget);
      expect(find.text('How It Works'), findsOneWidget);
    });

    testWidgets(
      'DashboardScreen shows temporarily unavailable banner and Retry button on HTTP 503 without crashing',
      (tester) async {
        final fakeRepo = FakeDegradedDashboardRepository();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              dashboardRepositoryProvider.overrideWithValue(fakeRepo),
            ],
            child: const MaterialApp(home: DashboardScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Dashboard temporarily unavailable'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);

        // Verify that the rest of the dashboard remains usable and rendered
        expect(find.text('Registered Batches'), findsOneWidget);
        expect(find.text('120'), findsOneWidget);
        expect(find.text('System Service Status'), findsOneWidget);
        expect(find.text('Technology Stack'), findsOneWidget);
      },
    );
  });
}
