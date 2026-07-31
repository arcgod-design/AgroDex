import 'package:flutter/foundation.dart';

/// Risk level enumeration matching React [SupplyChainRiskLevel].
enum SupplyChainRiskLevel {
  low,
  moderate,
  elevated,
  critical;

  /// Parses from a string value ('low', 'moderate', 'elevated', 'critical').
  static SupplyChainRiskLevel fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'low':
      case 'safe':
        return SupplyChainRiskLevel.low;
      case 'moderate':
      case 'medium':
        return SupplyChainRiskLevel.moderate;
      case 'elevated':
      case 'high':
        return SupplyChainRiskLevel.elevated;
      case 'critical':
        return SupplyChainRiskLevel.critical;
      default:
        return SupplyChainRiskLevel.low;
    }
  }

  /// Converts to React lowercase string format.
  String toShortString() => name;
}

/// Scorecard representing a KPI on the Risk Intelligence dashboard.
@immutable
class RiskScoreCard {
  /// Identifier: 'overall' | 'delay' | 'fraud' | 'inventory' | 'supplier'.
  final String id;

  /// Display label.
  final String label;

  /// Score out of 100.
  final int score;

  /// Point change from previous period.
  final int change;

  /// Risk level.
  final SupplyChainRiskLevel level;

  /// Detailed description of the scorecard signal.
  final String description;

  /// Creates an immutable [RiskScoreCard].
  const RiskScoreCard({
    required this.id,
    required this.label,
    required this.score,
    required this.change,
    required this.level,
    required this.description,
  });

  /// Deserializes from JSON map.
  factory RiskScoreCard.fromJson(Map<String, dynamic> json) {
    return RiskScoreCard(
      id: json['id'] as String? ?? 'overall',
      label: json['label'] as String? ?? 'Risk',
      score: (json['score'] as num?)?.toInt() ?? 0,
      change: (json['change'] as num?)?.toInt() ?? 0,
      level: SupplyChainRiskLevel.fromString(json['level'] as String?),
      description: json['description'] as String? ?? '',
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'score': score,
    'change': change,
    'level': level.toShortString(),
    'description': description,
  };
}

/// Logistics delay prediction for an active agricultural lane.
@immutable
class DelayPrediction {
  /// Lane name (e.g. 'West Java Farm Cluster -> Jakarta Port').
  final String lane;

  /// Expected ETA string.
  final String eta;

  /// Probability of delay (0-100%).
  final int delayProbability;

  /// Estimated delay in hours.
  final int predictedDelayHours;

  /// Primary driver cause.
  final String driver;

  /// Creates an immutable [DelayPrediction].
  const DelayPrediction({
    required this.lane,
    required this.eta,
    required this.delayProbability,
    required this.predictedDelayHours,
    required this.driver,
  });

  /// Deserializes from JSON map.
  factory DelayPrediction.fromJson(Map<String, dynamic> json) {
    return DelayPrediction(
      lane: json['lane'] as String? ?? 'Unknown Lane',
      eta: json['eta'] as String? ?? '',
      delayProbability: (json['delayProbability'] as num?)?.toInt() ?? 0,
      predictedDelayHours: (json['predictedDelayHours'] as num?)?.toInt() ?? 0,
      driver: json['driver'] as String? ?? '',
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'lane': lane,
    'eta': eta,
    'delayProbability': delayProbability,
    'predictedDelayHours': predictedDelayHours,
    'driver': driver,
  };
}

/// Fraud probability indicator and signals.
@immutable
class FraudIndicator {
  /// Display label.
  final String label;

  /// Overall probability (0-100%).
  final int probability;

  /// Risk level.
  final SupplyChainRiskLevel level;

  /// Contributing positive or warning signals.
  final List<String> signals;

  /// Creates an immutable [FraudIndicator].
  const FraudIndicator({
    required this.label,
    required this.probability,
    required this.level,
    required this.signals,
  });

  /// Deserializes from JSON map.
  factory FraudIndicator.fromJson(Map<String, dynamic> json) {
    return FraudIndicator(
      label: json['label'] as String? ?? 'Fraud Probability',
      probability: (json['probability'] as num?)?.toInt() ?? 0,
      level: SupplyChainRiskLevel.fromString(json['level'] as String?),
      signals:
          (json['signals'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'label': label,
    'probability': probability,
    'level': level.toShortString(),
    'signals': signals,
  };
}

/// AI Recommendation item for supply chain intervention.
@immutable
class Recommendation {
  /// Unique identifier.
  final String id;

  /// Priority string ('High', 'Medium', 'Low').
  final String priority;

  /// Recommendation title.
  final String title;

  /// Action step description.
  final String action;

  /// Estimated impact description.
  final String impact;

  /// Creates an immutable [Recommendation].
  const Recommendation({
    required this.id,
    required this.priority,
    required this.title,
    required this.action,
    required this.impact,
  });

  /// Deserializes from JSON map.
  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as String? ?? '',
      priority: json['priority'] as String? ?? 'Medium',
      title: json['title'] as String? ?? '',
      action: json['action'] as String? ?? '',
      impact: json['impact'] as String? ?? '',
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'priority': priority,
    'title': title,
    'action': action,
    'impact': impact,
  };
}

/// Heatmap cell representing risk score for a region and supply chain stage.
@immutable
class HeatmapCell {
  /// Region name (e.g. 'Java', 'Sumatra', 'Sulawesi', 'Bali').
  final String region;

  /// Stage ('Farm', 'Processing', 'Cold Chain', 'Port', 'Distributor').
  final String stage;

  /// Risk score (0-100).
  final int risk;

  /// Creates an immutable [HeatmapCell].
  const HeatmapCell({
    required this.region,
    required this.stage,
    required this.risk,
  });

  /// Deserializes from JSON map.
  factory HeatmapCell.fromJson(Map<String, dynamic> json) {
    return HeatmapCell(
      region: json['region'] as String? ?? '',
      stage: json['stage'] as String? ?? '',
      risk: (json['risk'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'region': region,
    'stage': stage,
    'risk': risk,
  };
}

/// Trend data point across 30 days.
@immutable
class RiskTrendPoint {
  /// Date label (e.g. 'Jun 01').
  final String date;

  /// Overall risk score.
  final int overallRisk;

  /// Delay risk score.
  final int delayRisk;

  /// Fraud risk score.
  final int fraudRisk;

  /// Inventory risk score.
  final int inventoryRisk;

  /// Creates an immutable [RiskTrendPoint].
  const RiskTrendPoint({
    required this.date,
    required this.overallRisk,
    required this.delayRisk,
    required this.fraudRisk,
    required this.inventoryRisk,
  });

  /// Deserializes from JSON map.
  factory RiskTrendPoint.fromJson(Map<String, dynamic> json) {
    return RiskTrendPoint(
      date: json['date'] as String? ?? '',
      overallRisk: (json['overallRisk'] as num?)?.toInt() ?? 0,
      delayRisk: (json['delayRisk'] as num?)?.toInt() ?? 0,
      fraudRisk: (json['fraudRisk'] as num?)?.toInt() ?? 0,
      inventoryRisk: (json['inventoryRisk'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'date': date,
    'overallRisk': overallRisk,
    'delayRisk': delayRisk,
    'fraudRisk': fraudRisk,
    'inventoryRisk': inventoryRisk,
  };
}

/// Inventory risk signal for a verified SKU.
@immutable
class InventorySignal {
  /// Stock Keeping Unit (e.g. 'Organic Rice AGX-RC-12').
  final String sku;

  /// Current inventory coverage in days.
  final double coverageDays;

  /// Reorder urgency level.
  final SupplyChainRiskLevel reorderUrgency;

  /// Qualitative note.
  final String note;

  /// Creates an immutable [InventorySignal].
  const InventorySignal({
    required this.sku,
    required this.coverageDays,
    required this.reorderUrgency,
    required this.note,
  });

  /// Deserializes from JSON map.
  factory InventorySignal.fromJson(Map<String, dynamic> json) {
    return InventorySignal(
      sku: json['sku'] as String? ?? '',
      coverageDays: (json['coverageDays'] as num?)?.toDouble() ?? 0.0,
      reorderUrgency: SupplyChainRiskLevel.fromString(
        json['reorderUrgency'] as String?,
      ),
      note: json['note'] as String? ?? '',
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'sku': sku,
    'coverageDays': coverageDays,
    'reorderUrgency': reorderUrgency.toShortString(),
    'note': note,
  };
}

/// Reliability index and trend for a supply chain partner.
@immutable
class SupplierReliability {
  /// Supplier name.
  final String supplier;

  /// Reliability index (0-100%).
  final int reliability;

  /// Number of recorded incidents.
  final int incidents;

  /// Trend string ('improving', 'stable', 'declining').
  final String trend;

  /// Creates an immutable [SupplierReliability].
  const SupplierReliability({
    required this.supplier,
    required this.reliability,
    required this.incidents,
    required this.trend,
  });

  /// Deserializes from JSON map.
  factory SupplierReliability.fromJson(Map<String, dynamic> json) {
    return SupplierReliability(
      supplier: json['supplier'] as String? ?? '',
      reliability: (json['reliability'] as num?)?.toInt() ?? 0,
      incidents: (json['incidents'] as num?)?.toInt() ?? 0,
      trend: json['trend'] as String? ?? 'stable',
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'supplier': supplier,
    'reliability': reliability,
    'incidents': incidents,
    'trend': trend,
  };
}

/// Comprehensive AI Supply Chain Risk Assessment report matching React [SupplyChainRiskAssessment].
@immutable
class SupplyChainRiskAssessment {
  /// ISO timestamp when the report was generated.
  final String generatedAt;

  /// Narrative AI summary.
  final String summary;

  /// Confidence score of the AI assessment (0-100%).
  final int confidence;

  /// KPI scorecards.
  final List<RiskScoreCard> scoreCards;

  /// Delay predictions across lanes.
  final List<DelayPrediction> delayPredictions;

  /// Fraud indicator metrics.
  final FraudIndicator fraudIndicator;

  /// AI intervention recommendations.
  final List<Recommendation> recommendations;

  /// Region x Stage risk heatmap cells.
  final List<HeatmapCell> heatmap;

  /// 30-day risk trends.
  final List<RiskTrendPoint> trends;

  /// Inventory coverage signals.
  final List<InventorySignal> inventorySignals;

  /// Supplier reliability list.
  final List<SupplierReliability> suppliers;

  /// Whether this assessment is from local fallback.
  final bool isFallback;

  /// Creates an immutable [SupplyChainRiskAssessment].
  const SupplyChainRiskAssessment({
    required this.generatedAt,
    required this.summary,
    required this.confidence,
    required this.scoreCards,
    required this.delayPredictions,
    required this.fraudIndicator,
    required this.recommendations,
    required this.heatmap,
    required this.trends,
    required this.inventorySignals,
    required this.suppliers,
    this.isFallback = false,
  });

  /// Deserializes from JSON map.
  factory SupplyChainRiskAssessment.fromJson(
    Map<String, dynamic> json, {
    bool isFallback = false,
  }) {
    return SupplyChainRiskAssessment(
      generatedAt:
          json['generatedAt'] as String? ??
          DateTime.now().toUtc().toIso8601String(),
      summary: json['summary'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toInt() ?? 90,
      scoreCards:
          (json['scoreCards'] as List?)
              ?.map((e) => RiskScoreCard.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      delayPredictions:
          (json['delayPredictions'] as List?)
              ?.map((e) => DelayPrediction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      fraudIndicator: json['fraudIndicator'] != null
          ? FraudIndicator.fromJson(
              json['fraudIndicator'] as Map<String, dynamic>,
            )
          : const FraudIndicator(
              label: 'Fraud Probability',
              probability: 0,
              level: SupplyChainRiskLevel.low,
              signals: [],
            ),
      recommendations:
          (json['recommendations'] as List?)
              ?.map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      heatmap:
          (json['heatmap'] as List?)
              ?.map((e) => HeatmapCell.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      trends:
          (json['trends'] as List?)
              ?.map((e) => RiskTrendPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      inventorySignals:
          (json['inventorySignals'] as List?)
              ?.map((e) => InventorySignal.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      suppliers:
          (json['suppliers'] as List?)
              ?.map(
                (e) => SupplierReliability.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      isFallback: isFallback,
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'generatedAt': generatedAt,
    'summary': summary,
    'confidence': confidence,
    'scoreCards': scoreCards.map((e) => e.toJson()).toList(),
    'delayPredictions': delayPredictions.map((e) => e.toJson()).toList(),
    'fraudIndicator': fraudIndicator.toJson(),
    'recommendations': recommendations.map((e) => e.toJson()).toList(),
    'heatmap': heatmap.map((e) => e.toJson()).toList(),
    'trends': trends.map((e) => e.toJson()).toList(),
    'inventorySignals': inventorySignals.map((e) => e.toJson()).toList(),
    'suppliers': suppliers.map((e) => e.toJson()).toList(),
  };
}
