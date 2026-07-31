import 'package:flutter/foundation.dart';

/// Service status item matching React `ServiceStatus` interface.
@immutable
class ServiceStatus {
  final bool ok;
  final int ms;
  final String? model;
  final String? error;

  const ServiceStatus({
    required this.ok,
    required this.ms,
    this.model,
    this.error,
  });

  factory ServiceStatus.fromJson(Map<String, dynamic> json) {
    return ServiceStatus(
      ok: json['ok'] == true,
      ms: _toInt(json['ms']),
      model: json['model']?.toString(),
      error: json['error']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'ok': ok,
    'ms': ms,
    'model': model,
    'error': error,
  };

  static int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is int) return val;
    if (val is double) return val.toInt();
    return int.tryParse(val.toString()) ?? 0;
  }
}

/// System health status matching React `HealthStatus` interface.
@immutable
class HealthStatus {
  final ServiceStatus supabase;
  final ServiceStatus hedera;
  final ServiceStatus gemini;

  const HealthStatus({
    required this.supabase,
    required this.hedera,
    required this.gemini,
  });

  factory HealthStatus.fromJson(Map<String, dynamic> json) {
    return HealthStatus(
      supabase: json['supabase'] != null
          ? ServiceStatus.fromJson(
              Map<String, dynamic>.from(json['supabase'] as Map),
            )
          : const ServiceStatus(ok: false, ms: 0),
      hedera: json['hedera'] != null
          ? ServiceStatus.fromJson(
              Map<String, dynamic>.from(json['hedera'] as Map),
            )
          : const ServiceStatus(ok: false, ms: 0),
      gemini: json['gemini'] != null
          ? ServiceStatus.fromJson(
              Map<String, dynamic>.from(json['gemini'] as Map),
            )
          : const ServiceStatus(ok: false, ms: 0),
    );
  }

  Map<String, dynamic> toJson() => {
    'supabase': supabase.toJson(),
    'hedera': hedera.toJson(),
    'gemini': gemini.toJson(),
  };
}

/// Full dashboard health response payload.
@immutable
class DashboardHealth {
  final HealthStatus? status;

  const DashboardHealth({this.status});

  factory DashboardHealth.fromJson(Map<String, dynamic> json) {
    return DashboardHealth(
      status: json['status'] != null
          ? HealthStatus.fromJson(
              Map<String, dynamic>.from(json['status'] as Map),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() => {'status': status?.toJson()};
}
