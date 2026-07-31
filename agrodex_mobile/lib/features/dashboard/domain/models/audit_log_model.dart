import 'package:flutter/foundation.dart';

/// Single audit log entry matching React `AuditLogEntry` interface.
@immutable
class AuditLogEntry {
  final String tokenId;
  final String serialNumber;
  final int score;
  final String? trustExplanation;
  final String rationale;
  final String verifiedAt;
  final String status; // 'approved' | 'flagged'

  const AuditLogEntry({
    required this.tokenId,
    required this.serialNumber,
    required this.score,
    this.trustExplanation,
    required this.rationale,
    required this.verifiedAt,
    required this.status,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    return AuditLogEntry(
      tokenId: json['token_id']?.toString() ?? '',
      serialNumber: json['serial_number']?.toString() ?? '',
      score: _toInt(json['score']),
      trustExplanation: json['trustExplanation']?.toString(),
      rationale: json['rationale']?.toString() ?? '',
      verifiedAt: json['verified_at']?.toString() ?? '',
      status: json['status']?.toString() ?? 'approved',
    );
  }

  Map<String, dynamic> toJson() => {
    'token_id': tokenId,
    'serial_number': serialNumber,
    'score': score,
    'trustExplanation': trustExplanation,
    'rationale': rationale,
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

/// Pagination metadata matching React `AuditLogsPagination` interface.
@immutable
class AuditLogsPagination {
  final int totalRecords;
  final int totalPages;
  final int currentPage;
  final int limit;

  const AuditLogsPagination({
    required this.totalRecords,
    required this.totalPages,
    required this.currentPage,
    required this.limit,
  });

  factory AuditLogsPagination.fromJson(Map<String, dynamic> json) {
    return AuditLogsPagination(
      totalRecords: _toInt(json['totalRecords'] ?? json['total_records']),
      totalPages: _toInt(json['totalPages'] ?? json['total_pages']),
      currentPage: _toInt(json['currentPage'] ?? json['current_page'] ?? 1),
      limit: _toInt(json['limit'] ?? 10),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalRecords': totalRecords,
    'totalPages': totalPages,
    'currentPage': currentPage,
    'limit': limit,
  };

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }
}

/// Paginated audit logs response payload matching React `AuditLogsResponse`.
@immutable
class AuditLogsResponse {
  final bool ok;
  final List<AuditLogEntry> data;
  final AuditLogsPagination pagination;

  const AuditLogsResponse({
    required this.ok,
    required this.data,
    required this.pagination,
  });

  factory AuditLogsResponse.fromJson(Map<String, dynamic> json) {
    final list =
        (json['data'] as List?)
            ?.map(
              (e) =>
                  AuditLogEntry.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList() ??
        [];
    return AuditLogsResponse(
      ok: json['ok'] == true,
      data: list,
      pagination: json['pagination'] != null
          ? AuditLogsPagination.fromJson(
              Map<String, dynamic>.from(json['pagination'] as Map),
            )
          : const AuditLogsPagination(
              totalRecords: 0,
              totalPages: 1,
              currentPage: 1,
              limit: 10,
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    'ok': ok,
    'data': data.map((e) => e.toJson()).toList(),
    'pagination': pagination.toJson(),
  };
}
