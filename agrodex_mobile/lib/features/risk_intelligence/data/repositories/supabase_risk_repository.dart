import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/logger_service.dart';
import '../../domain/models/ai_chat_models.dart';
import '../../domain/models/fraud_overview_models.dart';
import '../../domain/models/supply_chain_risk_models.dart';
import '../../domain/repositories/risk_repository.dart';

/// Implementation of [RiskRepository] backed by Supabase Edge Functions and backend API,
/// with automatic fallback to baseline assessment snapshots matching React [supplyChainRiskAi.ts].
class SupabaseRiskRepository implements RiskRepository {
  final ApiClient _apiClient;
  final SupabaseClient _supabaseClient;

  SupabaseRiskRepository({
    required ApiClient client,
    required SupabaseClient supabase,
  }) : _apiClient = client,
       _supabaseClient = supabase;

  @override
  Future<SupplyChainRiskAssessment> getSupplyChainRiskAssessment({
    bool forceRefresh = false,
  }) async {
    try {
      final endpoint = forceRefresh
          ? '/api/ai/risk-assessment?refresh=true'
          : '/api/ai/risk-assessment';
      final response = await _apiClient.get(endpoint);
      if (response.statusCode == 200 && response.data != null) {
        final dataMap = response.data is String
            ? jsonDecode(response.data as String) as Map<String, dynamic>
            : response.data as Map<String, dynamic>;

        if (dataMap['ok'] == true && dataMap['data'] != null) {
          return SupplyChainRiskAssessment.fromJson(
            dataMap['data'] as Map<String, dynamic>,
          );
        }
      }
    } catch (_) {
      // Fallback to baseline snapshot if backend endpoint is unavailable or offline
    }
    return _buildBaselineRiskAssessment();
  }

  @override
  Future<FraudOverview> getFraudOverview({bool forceRefresh = false}) async {
    try {
      final endpoint = forceRefresh
          ? '/api/fraud/overview?refresh=true'
          : '/api/fraud/overview';
      final response = await _apiClient.get(endpoint);
      if (response.statusCode == 200 && response.data != null) {
        final dataMap = response.data is String
            ? jsonDecode(response.data as String) as Map<String, dynamic>
            : response.data as Map<String, dynamic>;

        if (dataMap['ok'] == true && dataMap['data'] != null) {
          return FraudOverview.fromJson(
            dataMap['data'] as Map<String, dynamic>,
          );
        }
      }
    } catch (_) {
      // Fallback to baseline overview snapshot if API is offline
    }
    return _buildBaselineFraudOverview();
  }

  @override
  Future<String> sendAiChatMessage(List<AiChatMessage> messages) async {
    // 1. Clean messages for Gemini API format (conversation must begin with 'user' role)
    final cleanMessages = <Map<String, dynamic>>[];
    bool foundFirstUser = false;
    for (final m in messages) {
      if (!foundFirstUser && m.role != AiChatRole.user) {
        continue; // Skip initial welcome/system assistant messages
      }
      foundFirstUser = true;
      cleanMessages.add({
        'role': m.role == AiChatRole.user ? 'user' : 'model',
        'parts': [
          {'text': m.content},
        ],
      });
    }

    final payload = {
      'contents': cleanMessages,
      'systemInstruction': {
        'parts': [
          {
            'text':
                "You are the helpful AgroDex AI Assistant, an AI designed to fight food fraud in Indonesia by pairing Hedera's immutable ledger with Gemini AI for real-time food auditing. Provide concise, accurate, and helpful answers about supply chain provenance, Hedera HCS timestamps, fraud signals, and general user questions.",
          },
        ],
      },
      'generationConfig': {
        'temperature': 0.4,
        'maxOutputTokens': 1024,
      },
    };

    final rawUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/${AppConstants.geminiModel}:generateContent?key=${AppConstants.geminiApiKey}';
    final url = Uri.parse(rawUrl);

    LoggerService.info(
      'GEMINI API REQUEST: url=$url | payload=${jsonEncode(payload)}',
      'SupabaseRiskRepository',
    );

    int? httpStatus;
    String? responseBody;
    String? fallbackReason;

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));

      httpStatus = response.statusCode;
      responseBody = response.body;

      LoggerService.info(
        'GEMINI API RAW RESPONSE (${response.statusCode}): ${response.body}',
        'SupabaseRiskRepository',
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String?;
            if (text != null && text.isNotEmpty) {
              return text.trim();
            } else {
              fallbackReason = 'Response parts[0][text] was empty or null';
            }
          } else {
            fallbackReason = 'Response content.parts was empty or null';
          }
        } else {
          fallbackReason = 'Response candidates list was empty or null';
        }
      } else {
        fallbackReason = 'HTTP status ${response.statusCode} was not 200';
      }
    } catch (e, st) {
      httpStatus ??= 0;
      responseBody ??= 'Exception occurred before response: $e';
      fallbackReason = 'Gemini API call threw exception: $e';
      LoggerService.error(
        'GEMINI API EXCEPTION: $e',
        e,
        st,
        'SupabaseRiskRepository',
      );
    }

    // Secondary fallback: Try legacy Supabase Edge function if Gemini direct call fails
    try {
      final edgePayload = {
        'messages': messages
            .map((m) => {'role': m.role.toShortString(), 'content': m.content})
            .toList(),
      };

      final response = await _supabaseClient.functions.invoke(
        'ai-chat',
        body: edgePayload,
      );

      if (response.status == 200 && response.data != null) {
        final textResponse = response.data.toString();
        final lines = textResponse.split('\n');
        final buffer = StringBuffer();
        for (final line in lines) {
          if (line.startsWith('0:')) {
            try {
              final chunk = jsonDecode(line.substring(2));
              buffer.write(chunk);
            } catch (_) {
              // Ignore malformed chunks
            }
          }
        }
        final parsed = buffer.toString();
        if (parsed.isNotEmpty) {
          return parsed;
        }
        return textResponse;
      }
    } catch (e) {
      LoggerService.debug(
        'Supabase Edge Function fallback failed: $e',
        'SupabaseRiskRepository',
      );
      fallbackReason = '$fallbackReason | Edge function also failed: $e';
    }

    // Only appear if both Gemini API and fallback requests actually fail
    return 'I am the AgroDex AI Assistant. I can help you inspect supply chain provenance, check Hedera HCS timestamps, and analyze fraud signals.';
  }

  /// Generates the exact baseline assessment snapshot from React [supplyChainRiskAi.ts].
  SupplyChainRiskAssessment _buildBaselineRiskAssessment() {
    const scoreCards = [
      RiskScoreCard(
        id: 'overall',
        label: 'Overall Risk',
        score: 64,
        change: -7,
        level: SupplyChainRiskLevel.elevated,
        description:
            'Weighted aggregate across delay, fraud, inventory, and supplier signals.',
      ),
      RiskScoreCard(
        id: 'delay',
        label: 'Delay Risk',
        score: 71,
        change: 9,
        level: SupplyChainRiskLevel.elevated,
        description:
            'Weather disruption and port dwell time are pressuring three active lanes.',
      ),
      RiskScoreCard(
        id: 'fraud',
        label: 'Fraud Risk',
        score: 38,
        change: -4,
        level: SupplyChainRiskLevel.moderate,
        description:
            'Two document mismatches need review before downstream release.',
      ),
      RiskScoreCard(
        id: 'inventory',
        label: 'Inventory Risk',
        score: 57,
        change: 6,
        level: SupplyChainRiskLevel.moderate,
        description:
            'Cold-chain reserve is below policy for high-demand verified lots.',
      ),
      RiskScoreCard(
        id: 'supplier',
        label: 'Supplier Reliability',
        score: 82,
        change: 3,
        level: SupplyChainRiskLevel.low,
        description:
            'Primary suppliers remain stable with improved on-time fulfillment.',
      ),
    ];

    const delayPredictions = [
      DelayPrediction(
        lane: 'West Java Farm Cluster -> Jakarta Port',
        eta: '2026-06-29 14:00',
        delayProbability: 78,
        predictedDelayHours: 18,
        driver: 'Heavy rainfall and port gate congestion',
      ),
      DelayPrediction(
        lane: 'North Sumatra Cooperative -> Medan Cold Hub',
        eta: '2026-06-28 09:30',
        delayProbability: 64,
        predictedDelayHours: 11,
        driver: 'Truck availability constraint',
      ),
      DelayPrediction(
        lane: 'Sulawesi Processor -> Surabaya Distributor',
        eta: '2026-06-30 18:15',
        delayProbability: 41,
        predictedDelayHours: 5,
        driver: 'Low ferry schedule redundancy',
      ),
    ];

    const fraudIndicator = FraudIndicator(
      label: 'Fraud Probability',
      probability: 32,
      level: SupplyChainRiskLevel.moderate,
      signals: [
        'Two harvest-date edits after tokenization',
        'One supplier certificate expires within 14 days',
        'No duplicate QR scan clusters in the last 72 hours',
      ],
    );

    const recommendations = [
      Recommendation(
        id: 'reroute-java-lane',
        priority: 'High',
        title: 'Pre-book alternate Jakarta receiving slot',
        action:
            'Move two high-value lots to the 06:00 cold dock window and reserve overflow storage.',
        impact: 'Reduces predicted delay exposure by 12-16 hours.',
      ),
      Recommendation(
        id: 'audit-docs',
        priority: 'Medium',
        title: 'Run targeted document review',
        action:
            'Request fresh supplier certificate attestations for batches AGX-2194 and AGX-2201.',
        impact: 'Lowers fraud confidence interval before distributor release.',
      ),
      Recommendation(
        id: 'inventory-buffer',
        priority: 'Medium',
        title: 'Increase verified stock buffer',
        action:
            'Shift 8% of verified rice inventory from reserve to active replenishment.',
        impact: 'Improves two-day service coverage for premium buyers.',
      ),
    ];

    const heatmap = [
      HeatmapCell(region: 'Java', stage: 'Farm', risk: 34),
      HeatmapCell(region: 'Java', stage: 'Processing', risk: 45),
      HeatmapCell(region: 'Java', stage: 'Cold Chain', risk: 62),
      HeatmapCell(region: 'Java', stage: 'Port', risk: 68),
      HeatmapCell(region: 'Java', stage: 'Distributor', risk: 51),
      HeatmapCell(region: 'Sumatra', stage: 'Farm', risk: 42),
      HeatmapCell(region: 'Sumatra', stage: 'Processing', risk: 58),
      HeatmapCell(region: 'Sumatra', stage: 'Cold Chain', risk: 74),
      HeatmapCell(region: 'Sumatra', stage: 'Port', risk: 79),
      HeatmapCell(region: 'Sumatra', stage: 'Distributor', risk: 66),
      HeatmapCell(region: 'Sulawesi', stage: 'Farm', risk: 29),
      HeatmapCell(region: 'Sulawesi', stage: 'Processing', risk: 37),
      HeatmapCell(region: 'Sulawesi', stage: 'Cold Chain', risk: 48),
      HeatmapCell(region: 'Sulawesi', stage: 'Port', risk: 55),
      HeatmapCell(region: 'Sulawesi', stage: 'Distributor', risk: 46),
      HeatmapCell(region: 'Bali', stage: 'Farm', risk: 24),
      HeatmapCell(region: 'Bali', stage: 'Processing', risk: 31),
      HeatmapCell(region: 'Bali', stage: 'Cold Chain', risk: 43),
      HeatmapCell(region: 'Bali', stage: 'Port', risk: 52),
      HeatmapCell(region: 'Bali', stage: 'Distributor', risk: 39),
    ];

    const trends = [
      RiskTrendPoint(
        date: 'Jun 01',
        overallRisk: 58,
        delayRisk: 61,
        fraudRisk: 42,
        inventoryRisk: 49,
      ),
      RiskTrendPoint(
        date: 'Jun 05',
        overallRisk: 55,
        delayRisk: 57,
        fraudRisk: 39,
        inventoryRisk: 52,
      ),
      RiskTrendPoint(
        date: 'Jun 09',
        overallRisk: 62,
        delayRisk: 68,
        fraudRisk: 44,
        inventoryRisk: 55,
      ),
      RiskTrendPoint(
        date: 'Jun 13',
        overallRisk: 66,
        delayRisk: 73,
        fraudRisk: 46,
        inventoryRisk: 59,
      ),
      RiskTrendPoint(
        date: 'Jun 17',
        overallRisk: 69,
        delayRisk: 77,
        fraudRisk: 41,
        inventoryRisk: 63,
      ),
      RiskTrendPoint(
        date: 'Jun 21',
        overallRisk: 67,
        delayRisk: 74,
        fraudRisk: 40,
        inventoryRisk: 61,
      ),
      RiskTrendPoint(
        date: 'Jun 25',
        overallRisk: 64,
        delayRisk: 71,
        fraudRisk: 38,
        inventoryRisk: 57,
      ),
    ];

    const inventorySignals = [
      InventorySignal(
        sku: 'Organic Rice AGX-RC-12',
        coverageDays: 3.2,
        reorderUrgency: SupplyChainRiskLevel.elevated,
        note: 'Demand spike from verified retail buyers',
      ),
      InventorySignal(
        sku: 'Cacao Beans AGX-CB-08',
        coverageDays: 6.7,
        reorderUrgency: SupplyChainRiskLevel.moderate,
        note: 'Cold hub capacity can absorb one delayed shipment',
      ),
      InventorySignal(
        sku: 'Arabica Coffee AGX-CF-04',
        coverageDays: 9.4,
        reorderUrgency: SupplyChainRiskLevel.low,
        note: 'Healthy buffer and stable producer cadence',
      ),
    ];

    const suppliers = [
      SupplierReliability(
        supplier: 'Nusantara Growers Cooperative',
        reliability: 91,
        incidents: 1,
        trend: 'improving',
      ),
      SupplierReliability(
        supplier: 'Sari Bumi Processing',
        reliability: 84,
        incidents: 2,
        trend: 'stable',
      ),
      SupplierReliability(
        supplier: 'Medan Cold Chain Partners',
        reliability: 73,
        incidents: 4,
        trend: 'declining',
      ),
    ];

    return SupplyChainRiskAssessment(
      generatedAt: '2026-06-27T08:45:00.000Z',
      summary:
          'AI analysis flags elevated logistics exposure driven by port dwell time, rainfall-sensitive lanes, and reduced cold-chain buffer. Fraud probability is moderate and improving after document checks, while supplier reliability remains the strongest stabilizing factor.',
      confidence: 91,
      scoreCards: scoreCards,
      delayPredictions: delayPredictions,
      fraudIndicator: fraudIndicator,
      recommendations: recommendations,
      heatmap: heatmap,
      trends: trends,
      inventorySignals: inventorySignals,
      suppliers: suppliers,
      isFallback: true,
    );
  }

  /// Builds a baseline fraud overview snapshot matching React defaults.
  FraudOverview _buildBaselineFraudOverview() {
    return FraudOverview(
      summary: const FraudSummaryStats(
        totalAnalyzed: 142,
        safeCount: 98,
        lowCount: 24,
        mediumCount: 12,
        highCount: 6,
        criticalCount: 2,
        flaggedCount: 8,
        safeRate: 69,
      ),
      levelCounts: const {
        'SAFE': 98,
        'LOW': 24,
        'MEDIUM': 12,
        'HIGH': 6,
        'CRITICAL': 2,
      },
      topRiskyBatches: const [
        FraudBatchScore(
          batchId: '8f7a9d3e-1111-4234-89ab-cdef01234567',
          batchName: 'Organic Robusta AGX-RB-99',
          riskScore: 84,
          riskLevel: 'CRITICAL',
          summary:
              'Multiple harvest-date edits and unverified location coordinates.',
        ),
        FraudBatchScore(
          batchId: '8f7a9d3e-2222-4234-89ab-cdef01234567',
          batchName: 'Sumatra Arabica Grade A',
          riskScore: 71,
          riskLevel: 'HIGH',
          summary: 'Expired organic certificate attestation.',
        ),
      ],
      farmerRanking: const [
        FarmerRankingItem(
          farmerId: 'farmer-uuid-001',
          batchCount: 12,
          maxScore: 84,
          worstLevel: 'CRITICAL',
          avgScore: 42,
        ),
        FarmerRankingItem(
          farmerId: 'farmer-uuid-002',
          batchCount: 8,
          maxScore: 71,
          worstLevel: 'HIGH',
          avgScore: 35,
        ),
      ],
      regionalAnalytics: const [
        RegionalAnalyticsItem(
          region: 'Sumatra',
          outlierCount: 4,
          avgRisk: 48,
          totalBatches: 62,
        ),
        RegionalAnalyticsItem(
          region: 'Java',
          outlierCount: 2,
          avgRisk: 34,
          totalBatches: 54,
        ),
        RegionalAnalyticsItem(
          region: 'Sulawesi',
          outlierCount: 1,
          avgRisk: 28,
          totalBatches: 26,
        ),
      ],
      generatedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }
}
