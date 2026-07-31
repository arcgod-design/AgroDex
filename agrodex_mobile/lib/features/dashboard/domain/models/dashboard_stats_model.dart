import 'package:flutter/foundation.dart';

/// KPI counts matching React `DashboardKPIs` interface.
@immutable
class DashboardKpis {
  final int totalBatches;
  final int totalNfts;
  final int totalVerifications;
  final int aiVerified;

  const DashboardKpis({
    required this.totalBatches,
    required this.totalNfts,
    required this.totalVerifications,
    required this.aiVerified,
  });

  factory DashboardKpis.fromJson(Map<String, dynamic> json) {
    return DashboardKpis(
      totalBatches: _toInt(json['totalBatches']),
      totalNfts: _toInt(json['totalNfts']),
      totalVerifications: _toInt(
        json['totalVerifications'] ?? json['aiVerified'],
      ),
      aiVerified: _toInt(json['aiVerified'] ?? json['totalVerifications']),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalBatches': totalBatches,
    'totalNfts': totalNfts,
    'totalVerifications': totalVerifications,
    'aiVerified': aiVerified,
  };

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }
}

/// Verification audit lot item matching React `AuditLot` interface.
@immutable
class AuditLot {
  final String tokenId;
  final String serialNumber;
  final int score;
  final String? rationale;
  final String? trustExplanation;
  final String? verifiedAt;
  final String? status;

  const AuditLot({
    required this.tokenId,
    required this.serialNumber,
    required this.score,
    this.rationale,
    this.trustExplanation,
    this.verifiedAt,
    this.status,
  });

  factory AuditLot.fromJson(Map<String, dynamic> json) {
    return AuditLot(
      tokenId: json['token_id']?.toString() ?? '',
      serialNumber: json['serial_number']?.toString() ?? '',
      score: _toInt(json['score']),
      rationale: json['rationale']?.toString(),
      trustExplanation: json['trustExplanation']?.toString(),
      verifiedAt: json['verified_at']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'token_id': tokenId,
    'serial_number': serialNumber,
    'score': score,
    'rationale': rationale,
    'trustExplanation': trustExplanation,
    'verified_at': verifiedAt,
    'status': status,
  };

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }
}

/// Audit lists matching React `DashboardAudit` interface.
@immutable
class DashboardAudit {
  final List<AuditLot> approvedLots;
  final List<AuditLot> flaggedLots;

  const DashboardAudit({required this.approvedLots, required this.flaggedLots});

  factory DashboardAudit.fromJson(Map<String, dynamic> json) {
    final approvedList =
        (json['approvedLots'] as List?)
            ?.map((e) => AuditLot.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];
    final flaggedList =
        (json['flaggedLots'] as List?)
            ?.map((e) => AuditLot.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList() ??
        [];

    return DashboardAudit(approvedLots: approvedList, flaggedLots: flaggedList);
  }

  Map<String, dynamic> toJson() => {
    'approvedLots': approvedLots.map((e) => e.toJson()).toList(),
    'flaggedLots': flaggedLots.map((e) => e.toJson()).toList(),
  };
}

/// AI Insight data matching React `AIInsight` interface.
@immutable
class AiInsight {
  final String? insightEn;
  final String? error;

  const AiInsight({this.insightEn, this.error});

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      insightEn: json['insight_en']?.toString(),
      error: json['error']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'insight_en': insightEn, 'error': error};

  /// Normalizes and formats AI error messages matching React `getCleanInsightError`.
  static String? getCleanError(String? errorStr) {
    if (errorStr == null || errorStr.isEmpty) return null;
    final lower = errorStr.toLowerCase();

    if (lower.contains('api_key_invalid') ||
        lower.contains('api key not configured') ||
        lower.contains('api_key') ||
        lower.contains('key is invalid')) {
      return 'AI Insights are currently unavailable due to a service configuration issue.';
    }

    if (lower.contains('googlegenerativeai') ||
        lower.contains('bad request') ||
        lower.contains('fetch failed') ||
        lower.contains('http') ||
        lower.contains('status:')) {
      return 'AI Insights are currently unavailable due to a temporary service error.';
    }

    return errorStr;
  }
}

/// Full stats payload matching React `getDashboardStats` result.
@immutable
class DashboardStats {
  final DashboardKpis kpis;
  final DashboardAudit audit;
  final AiInsight? aiInsight;
  final String? generatedAt;

  const DashboardStats({
    required this.kpis,
    required this.audit,
    this.aiInsight,
    this.generatedAt,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      kpis: json['kpis'] != null
          ? DashboardKpis.fromJson(
              Map<String, dynamic>.from(json['kpis'] as Map),
            )
          : const DashboardKpis(
              totalBatches: 0,
              totalNfts: 0,
              totalVerifications: 0,
              aiVerified: 0,
            ),
      audit: json['audit'] != null
          ? DashboardAudit.fromJson(
              Map<String, dynamic>.from(json['audit'] as Map),
            )
          : const DashboardAudit(approvedLots: [], flaggedLots: []),
      aiInsight: json['aiInsight'] != null
          ? AiInsight.fromJson(
              Map<String, dynamic>.from(json['aiInsight'] as Map),
            )
          : null,
      generatedAt: json['generatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'kpis': kpis.toJson(),
    'audit': audit.toJson(),
    'aiInsight': aiInsight?.toJson(),
    'generatedAt': generatedAt,
  };
}
