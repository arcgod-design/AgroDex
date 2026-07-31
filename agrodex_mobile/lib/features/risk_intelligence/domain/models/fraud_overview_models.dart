import 'package:flutter/foundation.dart';

/// Summary statistics for fraud overview.
@immutable
class FraudSummaryStats {
  /// Total number of analyzed batches.
  final int totalAnalyzed;

  /// Count of SAFE batches.
  final int safeCount;

  /// Count of LOW risk batches.
  final int lowCount;

  /// Count of MEDIUM risk batches.
  final int mediumCount;

  /// Count of HIGH risk batches.
  final int highCount;

  /// Count of CRITICAL risk batches.
  final int criticalCount;

  /// Count of flagged batches (HIGH + CRITICAL).
  final int flaggedCount;

  /// Percentage of safe batches (0-100).
  final int safeRate;

  /// Creates an immutable [FraudSummaryStats].
  const FraudSummaryStats({
    required this.totalAnalyzed,
    required this.safeCount,
    required this.lowCount,
    required this.mediumCount,
    required this.highCount,
    required this.criticalCount,
    required this.flaggedCount,
    required this.safeRate,
  });

  /// Deserializes from JSON map.
  factory FraudSummaryStats.fromJson(Map<String, dynamic> json) {
    return FraudSummaryStats(
      totalAnalyzed: (json['totalAnalyzed'] as num?)?.toInt() ?? 0,
      safeCount: (json['safeCount'] as num?)?.toInt() ?? 0,
      lowCount: (json['lowCount'] as num?)?.toInt() ?? 0,
      mediumCount: (json['mediumCount'] as num?)?.toInt() ?? 0,
      highCount: (json['highCount'] as num?)?.toInt() ?? 0,
      criticalCount: (json['criticalCount'] as num?)?.toInt() ?? 0,
      flaggedCount: (json['flaggedCount'] as num?)?.toInt() ?? 0,
      safeRate: (json['safeRate'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'totalAnalyzed': totalAnalyzed,
    'safeCount': safeCount,
    'lowCount': lowCount,
    'mediumCount': mediumCount,
    'highCount': highCount,
    'criticalCount': criticalCount,
    'flaggedCount': flaggedCount,
    'safeRate': safeRate,
  };
}

/// A flagged or analyzed batch in fraud overview.
@immutable
class FraudBatchScore {
  /// Batch UUID.
  final String batchId;

  /// Batch name or title.
  final String batchName;

  /// Fraud risk score (0-100).
  final int riskScore;

  /// Risk level string ('SAFE', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL').
  final String riskLevel;

  /// Explanation summary.
  final String summary;

  /// Creates an immutable [FraudBatchScore].
  const FraudBatchScore({
    required this.batchId,
    required this.batchName,
    required this.riskScore,
    required this.riskLevel,
    required this.summary,
  });

  /// Deserializes from JSON map.
  factory FraudBatchScore.fromJson(Map<String, dynamic> json) {
    return FraudBatchScore(
      batchId: json['batchId'] as String? ?? json['batch_id'] as String? ?? '',
      batchName:
          json['batchName'] as String? ?? json['batch_name'] as String? ?? '',
      riskScore:
          (json['riskScore'] as num?)?.toInt() ??
          (json['risk_score'] as num?)?.toInt() ??
          0,
      riskLevel:
          json['riskLevel'] as String? ??
          json['risk_level'] as String? ??
          'SAFE',
      summary: json['summary'] as String? ?? '',
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'batchId': batchId,
    'batchName': batchName,
    'riskScore': riskScore,
    'riskLevel': riskLevel,
    'summary': summary,
  };
}

/// Farmer ranking item ordered by max fraud risk score.
@immutable
class FarmerRankingItem {
  /// Farmer Supabase user ID.
  final String farmerId;

  /// Total batch count analyzed.
  final int batchCount;

  /// Maximum recorded risk score.
  final int maxScore;

  /// Worst risk level recorded.
  final String worstLevel;

  /// Average risk score.
  final int avgScore;

  /// Creates an immutable [FarmerRankingItem].
  const FarmerRankingItem({
    required this.farmerId,
    required this.batchCount,
    required this.maxScore,
    required this.worstLevel,
    required this.avgScore,
  });

  /// Deserializes from JSON map.
  factory FarmerRankingItem.fromJson(Map<String, dynamic> json) {
    return FarmerRankingItem(
      farmerId: json['farmerId'] as String? ?? '',
      batchCount: (json['batchCount'] as num?)?.toInt() ?? 0,
      maxScore: (json['maxScore'] as num?)?.toInt() ?? 0,
      worstLevel: json['worstLevel'] as String? ?? 'SAFE',
      avgScore: (json['avgScore'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'farmerId': farmerId,
    'batchCount': batchCount,
    'maxScore': maxScore,
    'worstLevel': worstLevel,
    'avgScore': avgScore,
  };
}

/// Regional outlier analytics item.
@immutable
class RegionalAnalyticsItem {
  /// Region name.
  final String region;

  /// Number of flagged outlier batches in this region.
  final int outlierCount;

  /// Average risk score in this region.
  final int avgRisk;

  /// Total batches analyzed in this region.
  final int totalBatches;

  /// Creates an immutable [RegionalAnalyticsItem].
  const RegionalAnalyticsItem({
    required this.region,
    required this.outlierCount,
    required this.avgRisk,
    required this.totalBatches,
  });

  /// Deserializes from JSON map.
  factory RegionalAnalyticsItem.fromJson(Map<String, dynamic> json) {
    return RegionalAnalyticsItem(
      region: json['region'] as String? ?? '',
      outlierCount: (json['outlierCount'] as num?)?.toInt() ?? 0,
      avgRisk: (json['avgRisk'] as num?)?.toInt() ?? 0,
      totalBatches: (json['totalBatches'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'region': region,
    'outlierCount': outlierCount,
    'avgRisk': avgRisk,
    'totalBatches': totalBatches,
  };
}

/// Complete Fraud Overview report from GET /api/fraud/overview.
@immutable
class FraudOverview {
  /// Summary stats.
  final FraudSummaryStats summary;

  /// Level counts map.
  final Map<String, int> levelCounts;

  /// Top risky batches.
  final List<FraudBatchScore> topRiskyBatches;

  /// Farmer ranking list.
  final List<FarmerRankingItem> farmerRanking;

  /// Regional analytics items.
  final List<RegionalAnalyticsItem> regionalAnalytics;

  /// ISO timestamp when generated.
  final String generatedAt;

  /// Creates an immutable [FraudOverview].
  const FraudOverview({
    required this.summary,
    required this.levelCounts,
    required this.topRiskyBatches,
    required this.farmerRanking,
    required this.regionalAnalytics,
    required this.generatedAt,
  });

  /// Deserializes from JSON map.
  factory FraudOverview.fromJson(Map<String, dynamic> json) {
    final rawCounts = json['levelCounts'] as Map<String, dynamic>? ?? const {};
    final counts = rawCounts.map(
      (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0),
    );

    return FraudOverview(
      summary: json['summary'] != null
          ? FraudSummaryStats.fromJson(json['summary'] as Map<String, dynamic>)
          : const FraudSummaryStats(
              totalAnalyzed: 0,
              safeCount: 0,
              lowCount: 0,
              mediumCount: 0,
              highCount: 0,
              criticalCount: 0,
              flaggedCount: 0,
              safeRate: 100,
            ),
      levelCounts: counts,
      topRiskyBatches:
          (json['topRiskyBatches'] as List?)
              ?.map((e) => FraudBatchScore.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      farmerRanking:
          (json['farmerRanking'] as List?)
              ?.map(
                (e) => FarmerRankingItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      regionalAnalytics:
          (json['regionalAnalytics'] as List?)
              ?.map(
                (e) =>
                    RegionalAnalyticsItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      generatedAt:
          json['generatedAt'] as String? ??
          DateTime.now().toUtc().toIso8601String(),
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'summary': summary.toJson(),
    'levelCounts': levelCounts,
    'topRiskyBatches': topRiskyBatches.map((e) => e.toJson()).toList(),
    'farmerRanking': farmerRanking.map((e) => e.toJson()).toList(),
    'regionalAnalytics': regionalAnalytics.map((e) => e.toJson()).toList(),
    'generatedAt': generatedAt,
  };
}
