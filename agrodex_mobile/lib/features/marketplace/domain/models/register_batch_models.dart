// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';

/// Request payload for registering a new batch on Hedera Consensus Service.
/// Matches [RegisterBatchRequest] from React [api.ts].
@immutable
class RegisterBatchRequest {
  /// The type of agricultural product (e.g., Arabica Coffee).
  final String productType;

  /// Quantity string including unit (e.g., "500 kg").
  final String quantity;

  /// Origin or harvest location string.
  final String location;

  /// Base64 or URL encoded image data.
  final String imageData;

  /// Harvest date formatted as YYYY-MM-DD.
  final String harvestDate;

  /// Optional AI verification audit trail payload.
  final Object? aiVerification;

  /// Creates an immutable [RegisterBatchRequest].
  const RegisterBatchRequest({
    required this.productType,
    required this.quantity,
    required this.location,
    required this.imageData,
    required this.harvestDate,
    this.aiVerification,
  });

  /// Serializes to a JSON map matching the Edge Function contract.
  Map<String, dynamic> toJson() => {
    'productType': productType,
    'quantity': quantity,
    'location': location,
    'imageData': imageData,
    'harvestDate': harvestDate,
    if (aiVerification != null) 'aiVerification': aiVerification,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegisterBatchRequest &&
        other.productType == productType &&
        other.quantity == quantity &&
        other.location == location &&
        other.imageData == imageData &&
        other.harvestDate == harvestDate;
  }

  @override
  int get hashCode =>
      Object.hash(productType, quantity, location, imageData, harvestDate);
}

/// AI Analysis metadata returned by the batch registration endpoint.
@immutable
class AiAnalysisSummary {
  /// Generated descriptive caption of the batch image.
  final String caption;

  /// List of detected anomalies, if any.
  final List<String> anomalies;

  /// AI confidence score from 0.0 to 1.0.
  final double confidence;

  /// Semantic tags describing the crop/batch.
  final List<String> tags;

  /// Timestamp when analysis was generated.
  final String generatedAt;

  /// Execution duration in milliseconds.
  final int ms;

  /// Creates an immutable [AiAnalysisSummary].
  const AiAnalysisSummary({
    required this.caption,
    required this.anomalies,
    required this.confidence,
    required this.tags,
    required this.generatedAt,
    required this.ms,
  });

  /// Deserializes from JSON map.
  factory AiAnalysisSummary.fromJson(Map<String, dynamic> json) {
    return AiAnalysisSummary(
      caption: json['caption'] as String? ?? '',
      anomalies:
          (json['anomalies'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      confidence: (json['confidence'] as num?)?.toDouble() ?? 1.0,
      tags:
          (json['tags'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      generatedAt:
          json['generatedAt'] as String? ??
          json['generated_at'] as String? ??
          '',
      ms: (json['ms'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
    'caption': caption,
    'anomalies': anomalies,
    'confidence': confidence,
    'tags': tags,
    'generatedAt': generatedAt,
    'ms': ms,
  };
}

/// Response payload from registering a batch on Hedera via Supabase Edge Function.
/// Matches [RegisterBatchResponse] from React [api.ts].
@immutable
class RegisterBatchResponse {
  /// Whether registration succeeded.
  final bool success;

  /// The Hedera Consensus Service transaction ID.
  final String hcsTransactionId;

  /// The generated Supabase batch record ID (UUID).
  final String batchId;

  /// Optional AI visual analysis summary.
  final AiAnalysisSummary? aiAnalysis;

  /// Human-readable response message.
  final String message;

  /// Creates an immutable [RegisterBatchResponse].
  const RegisterBatchResponse({
    required this.success,
    required this.hcsTransactionId,
    required this.batchId,
    this.aiAnalysis,
    required this.message,
  });

  /// Deserializes from a JSON map.
  factory RegisterBatchResponse.fromJson(Map<String, dynamic> json) {
    final aiJson = json['ai_analysis'] ?? json['aiAnalysis'];
    return RegisterBatchResponse(
      success: json['success'] == true,
      hcsTransactionId:
          json['hcsTransactionId'] as String? ??
          json['hcs_transaction_id'] as String? ??
          '',
      batchId: json['batchId'] as String? ?? json['batch_id'] as String? ?? '',
      aiAnalysis: aiJson != null && aiJson is Map
          ? AiAnalysisSummary.fromJson(Map<String, dynamic>.from(aiJson))
          : null,
      message: json['message'] as String? ?? '',
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
    'success': success,
    'hcsTransactionId': hcsTransactionId,
    'batchId': batchId,
    if (aiAnalysis != null) 'ai_analysis': aiAnalysis!.toJson(),
    'message': message,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RegisterBatchResponse &&
        other.success == success &&
        other.hcsTransactionId == hcsTransactionId &&
        other.batchId == batchId &&
        other.message == message;
  }

  @override
  int get hashCode => Object.hash(success, hcsTransactionId, batchId, message);
}
