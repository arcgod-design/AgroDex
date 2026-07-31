import 'package:agrodex_mobile/features/risk_intelligence/domain/models/ai_chat_models.dart';
import 'package:agrodex_mobile/features/risk_intelligence/domain/models/fraud_overview_models.dart';
import 'package:agrodex_mobile/features/risk_intelligence/domain/models/supply_chain_risk_models.dart';
import 'package:agrodex_mobile/features/risk_intelligence/domain/repositories/risk_repository.dart';
import 'package:agrodex_mobile/features/risk_intelligence/presentation/providers/risk_providers.dart';
import 'package:agrodex_mobile/features/risk_intelligence/presentation/screens/risk_intelligence_screen.dart';
import 'package:agrodex_mobile/features/risk_intelligence/presentation/widgets/risk_score_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeRiskRepository implements RiskRepository {
  @override
  Future<SupplyChainRiskAssessment> getSupplyChainRiskAssessment({
    bool forceRefresh = false,
  }) async {
    return const SupplyChainRiskAssessment(
      generatedAt: '2026-06-27T08:45:00.000Z',
      summary: 'Test AI assessment summary.',
      confidence: 95,
      scoreCards: [
        RiskScoreCard(
          id: 'overall',
          label: 'Overall Risk',
          score: 64,
          change: -7,
          level: SupplyChainRiskLevel.elevated,
          description: 'Overall aggregate risk description.',
        ),
      ],
      delayPredictions: [],
      fraudIndicator: FraudIndicator(
        label: 'Fraud Probability',
        probability: 32,
        level: SupplyChainRiskLevel.moderate,
        signals: ['Test signal 1', 'Test signal 2'],
      ),
      recommendations: [
        Recommendation(
          id: 'rec-1',
          priority: 'High',
          title: 'Test Recommendation',
          action: 'Perform audit action',
          impact: 'Reduces risk by 10%',
        ),
      ],
      heatmap: [HeatmapCell(region: 'Java', stage: 'Farm', risk: 34)],
      trends: [
        RiskTrendPoint(
          date: 'Jun 01',
          overallRisk: 58,
          delayRisk: 61,
          fraudRisk: 42,
          inventoryRisk: 49,
        ),
      ],
      inventorySignals: [],
      suppliers: [],
      isFallback: true,
    );
  }

  @override
  Future<FraudOverview> getFraudOverview({bool forceRefresh = false}) async {
    return FraudOverview(
      summary: const FraudSummaryStats(
        totalAnalyzed: 10,
        safeCount: 8,
        lowCount: 1,
        mediumCount: 1,
        highCount: 0,
        criticalCount: 0,
        flaggedCount: 0,
        safeRate: 80,
      ),
      levelCounts: const {'SAFE': 8, 'LOW': 1, 'MEDIUM': 1},
      topRiskyBatches: const [],
      farmerRanking: const [],
      regionalAnalytics: const [],
      generatedAt: '2026-06-27T08:45:00.000Z',
    );
  }

  @override
  Future<String> sendAiChatMessage(List<AiChatMessage> messages) async {
    return 'This is a test AI Assistant response.';
  }
}

void main() {
  group('Feature 5: AI & Risk Intelligence Domain & Repository Tests', () {
    test('SupplyChainRiskLevel parsing and short string conversion', () {
      expect(
        SupplyChainRiskLevel.fromString('low'),
        equals(SupplyChainRiskLevel.low),
      );
      expect(
        SupplyChainRiskLevel.fromString('critical'),
        equals(SupplyChainRiskLevel.critical),
      );
      expect(
        SupplyChainRiskLevel.fromString('unknown'),
        equals(SupplyChainRiskLevel.low),
      );
      expect(SupplyChainRiskLevel.elevated.toShortString(), equals('elevated'));
    });

    test('RiskScoreCard JSON serialization and deserialization', () {
      const card = RiskScoreCard(
        id: 'delay',
        label: 'Delay Risk',
        score: 71,
        change: 9,
        level: SupplyChainRiskLevel.elevated,
        description: 'Weather disruption.',
      );

      final json = card.toJson();
      final decoded = RiskScoreCard.fromJson(json);

      expect(decoded.id, equals('delay'));
      expect(decoded.score, equals(71));
      expect(decoded.level, equals(SupplyChainRiskLevel.elevated));
    });

    test('FraudOverview JSON deserialization with defaults', () {
      final json = {
        'generatedAt': '2026-06-27T08:45:00.000Z',
        'levelCounts': {'SAFE': 5, 'LOW': 2},
      };

      final overview = FraudOverview.fromJson(json);
      expect(overview.levelCounts['SAFE'], equals(5));
      expect(overview.topRiskyBatches, isEmpty);
    });

    test('FakeRiskRepository returns valid assessment snapshot', () async {
      final repository = FakeRiskRepository();
      final assessment = await repository.getSupplyChainRiskAssessment();

      expect(assessment.confidence, equals(95));
      expect(assessment.scoreCards.first.id, equals('overall'));
      expect(assessment.isFallback, isTrue);
    });

    test('FakeRiskRepository returns valid fraud overview snapshot', () async {
      final repository = FakeRiskRepository();
      final overview = await repository.getFraudOverview();

      expect(overview.summary.totalAnalyzed, equals(10));
      expect(overview.summary.safeRate, equals(80));
    });
  });

  group('Feature 5: Riverpod Providers Tests', () {
    test('riskAssessmentProvider resolves correctly', () async {
      final container = ProviderContainer(
        overrides: [
          riskRepositoryProvider.overrideWithValue(FakeRiskRepository()),
        ],
      );
      addTearDown(container.dispose);

      final assessment = await container.read(riskAssessmentProvider.future);
      expect(assessment.confidence, equals(95));
      expect(assessment.scoreCards.length, equals(1));
    });

    test('aiChatControllerProvider sends message and updates state', () async {
      final container = ProviderContainer(
        overrides: [
          riskRepositoryProvider.overrideWithValue(FakeRiskRepository()),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(aiChatControllerProvider.notifier);
      expect(
        container.read(aiChatControllerProvider).value?.length,
        equals(1),
      ); // Initial welcome message

      await controller.sendMessage('Is batch AGX-2194 verified?');
      final messages = container.read(aiChatControllerProvider).value!;
      expect(messages.length, equals(3));
      expect(messages.last.role, equals(AiChatRole.assistant));
      expect(
        messages.last.content,
        equals('This is a test AI Assistant response.'),
      );
    });
  });

  group('Feature 5: Widget Tests', () {
    testWidgets('RiskScoreCardWidget renders label, score and level badge', (
      tester,
    ) async {
      const card = RiskScoreCard(
        id: 'overall',
        label: 'Overall Risk',
        score: 64,
        change: -7,
        level: SupplyChainRiskLevel.elevated,
        description: 'Test scorecard description.',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: RiskScoreCardWidget(card: card)),
        ),
      );

      expect(find.text('Overall Risk'), findsOneWidget);
      expect(find.text('64'), findsOneWidget);
      expect(find.text('/100'), findsOneWidget);
      expect(find.text('Elevated'), findsOneWidget);
      expect(find.text('-7 pts'), findsOneWidget);
    });

    testWidgets(
      'RiskIntelligenceScreen renders tabs and displays Key Risk Indicators',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              riskRepositoryProvider.overrideWithValue(FakeRiskRepository()),
            ],
            child: const MaterialApp(home: RiskIntelligenceScreen()),
          ),
        );

        // Initial pump
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('AI & Risk Intelligence'), findsOneWidget);
        expect(find.text('Supply Chain Risk'), findsOneWidget);
        expect(find.text('Fraud Overview'), findsOneWidget);
        expect(find.text('Verification Assistant'), findsOneWidget);

        expect(find.text('Key Risk Indicators'), findsOneWidget);
        expect(find.text('Overall Risk'), findsOneWidget);
      },
    );
  });
}
