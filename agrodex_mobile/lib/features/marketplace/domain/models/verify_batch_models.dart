// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';

/// Base class representing any outcome of batch verification.
/// Matches [VerifyBatchResult] union type from React [api.ts].
@immutable
abstract class VerifyBatchResult {
  /// Whether the batch was successfully verified.
  final bool verified;

  /// The reason code if verification failed ("not_found", "deleted", or null).
  final String? reason;

  /// Creates a [VerifyBatchResult].
  const VerifyBatchResult({required this.verified, this.reason});

  /// Deserializes from a JSON map into the appropriate subtype.
  factory VerifyBatchResult.fromJson(Map<String, dynamic> json) {
    final reason = json['reason'] as String?;
    if (reason == 'not_found' ||
        (json['verified'] == false && reason == 'not_found')) {
      return VerifyBatchNotFoundResult.fromJson(json);
    }
    if (reason == 'deleted' ||
        (json['verified'] == false && reason == 'deleted')) {
      return VerifyBatchDeletedResult.fromJson(json);
    }
    return VerifyBatchResponse.fromJson(json);
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson();
}

/// Supabase database record information for a verified batch.
@immutable
class BatchInfo {
  /// Unique batch UUID.
  final String id;

  /// Display name of the batch.
  final String batchName;

  /// Type of agricultural product.
  final String productType;

  /// Quantity string.
  final String quantity;

  /// Origin location.
  final String location;

  /// Harvest date YYYY-MM-DD.
  final String harvestDate;

  /// Photo URL or placeholder.
  final String photoUrl;

  /// HCS transaction ID.
  final String hcsTxId;

  /// Creation timestamp.
  final String createdAt;

  /// Optional Hedera token ID if tokenized.
  final String? hederaTokenId;

  /// Optional Hedera serial number if tokenized.
  final String? hederaSerialNumber;

  /// Optional tokenization timestamp.
  final String? tokenizedAt;

  /// Optional QR code verification URL.
  final String? qrCodeUrl;

  /// Optional deletion timestamp.
  final String? deletedAt;

  /// Creates an immutable [BatchInfo].
  const BatchInfo({
    required this.id,
    required this.batchName,
    required this.productType,
    required this.quantity,
    required this.location,
    required this.harvestDate,
    required this.photoUrl,
    required this.hcsTxId,
    required this.createdAt,
    this.hederaTokenId,
    this.hederaSerialNumber,
    this.tokenizedAt,
    this.qrCodeUrl,
    this.deletedAt,
  });

  /// Deserializes from JSON map.
  factory BatchInfo.fromJson(Map<String, dynamic> json) {
    return BatchInfo(
      id: json['id'] as String? ?? '',
      batchName:
          json['batchName'] as String? ?? json['batch_name'] as String? ?? '',
      productType:
          json['productType'] as String? ??
          json['product_type'] as String? ??
          '',
      quantity: json['quantity'] as String? ?? '',
      location: json['location'] as String? ?? '',
      harvestDate:
          json['harvestDate'] as String? ??
          json['harvest_date'] as String? ??
          '',
      photoUrl:
          json['photoUrl'] as String? ?? json['photo_url'] as String? ?? '',
      hcsTxId: json['hcsTxId'] as String? ?? json['hcs_tx_id'] as String? ?? '',
      createdAt:
          json['createdAt'] as String? ?? json['created_at'] as String? ?? '',
      hederaTokenId:
          json['hederaTokenId'] as String? ??
          json['hedera_token_id'] as String?,
      hederaSerialNumber:
          json['hederaSerialNumber'] as String? ??
          json['hedera_serial_number'] as String?,
      tokenizedAt:
          json['tokenizedAt'] as String? ?? json['tokenized_at'] as String?,
      qrCodeUrl: json['qrCodeUrl'] as String? ?? json['qr_code_url'] as String?,
      deletedAt: json['deletedAt'] as String? ?? json['deleted_at'] as String?,
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'batch_name': batchName,
    'product_type': productType,
    'quantity': quantity,
    'location': location,
    'harvest_date': harvestDate,
    'photo_url': photoUrl,
    'hcs_tx_id': hcsTxId,
    'created_at': createdAt,
    if (hederaTokenId != null) 'hedera_token_id': hederaTokenId,
    if (hederaSerialNumber != null) 'hedera_serial_number': hederaSerialNumber,
    if (tokenizedAt != null) 'tokenized_at': tokenizedAt,
    if (qrCodeUrl != null) 'qr_code_url': qrCodeUrl,
    if (deletedAt != null) 'deleted_at': deletedAt,
  };
}

/// Timeline event entry in verified AI summary.
@immutable
class VerifyTimelineEvent {
  /// Event timestamp.
  final String timestamp;

  /// Event description.
  final String event;

  /// Hedera transaction ID.
  final String txId;

  /// Creates an immutable [VerifyTimelineEvent].
  const VerifyTimelineEvent({
    required this.timestamp,
    required this.event,
    required this.txId,
  });

  /// Deserializes from a JSON map.
  factory VerifyTimelineEvent.fromJson(Map<String, dynamic> json) {
    return VerifyTimelineEvent(
      timestamp: json['timestamp'] as String? ?? '',
      event: json['event'] as String? ?? '',
      txId: json['txId'] as String? ?? json['tx_id'] as String? ?? '',
    );
  }

  /// Serializes to JSON map.
  Map<String, dynamic> toJson() => {
    'timestamp': timestamp,
    'event': event,
    'txId': txId,
  };
}

/// AI Provenance summary embedded in [VerifyBatchResponse].
@immutable
class VerifyAiSummary {
  /// Summary in English.
  final String summaryEn;

  /// Summary in French.
  final String summaryFr;

  /// Chronological event timeline.
  final List<VerifyTimelineEvent> timeline;

  /// Trust score (0 to 100).
  final int trustScore;

  /// Explanation of trust score.
  final String trustExplanation;

  /// Timestamp of analysis generation.
  final String generatedAt;

  /// Processing time in ms.
  final int ms;

  /// Creates an immutable [VerifyAiSummary].
  const VerifyAiSummary({
    required this.summaryEn,
    required this.summaryFr,
    required this.timeline,
    required this.trustScore,
    required this.trustExplanation,
    required this.generatedAt,
    required this.ms,
  });

  /// Deserializes from a JSON map.
  factory VerifyAiSummary.fromJson(Map<String, dynamic> json) {
    final timelineList =
        (json['timeline'] as List?)
            ?.map(
              (e) => VerifyTimelineEvent.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList() ??
        const [];
    return VerifyAiSummary(
      summaryEn:
          json['summary_en'] as String? ?? json['summaryEn'] as String? ?? '',
      summaryFr:
          json['summary_fr'] as String? ?? json['summaryFr'] as String? ?? '',
      timeline: timelineList,
      trustScore: (json['trustScore'] as num?)?.toInt() ?? 100,
      trustExplanation: json['trustExplanation'] as String? ?? '',
      generatedAt:
          json['generatedAt'] as String? ??
          json['generated_at'] as String? ??
          '',
      ms: (json['ms'] as num?)?.toInt() ?? 0,
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
    'summary_en': summaryEn,
    'summary_fr': summaryFr,
    'timeline': timeline.map((e) => e.toJson()).toList(),
    'trustScore': trustScore,
    'trustExplanation': trustExplanation,
    'generatedAt': generatedAt,
    'ms': ms,
  };
}

/// Successful verification response for a batch.
/// Matches [VerifyBatchResponse] in React [api.ts].
@immutable
class VerifyBatchResponse extends VerifyBatchResult {
  /// Whether verification succeeded.
  final bool success;

  /// Whether response was cached server-side.
  final bool cached;

  /// Verified token ID.
  final String tokenId;

  /// Verified serial number.
  final String serialNumber;

  /// Raw NFT metadata map.
  final Map<String, dynamic> nftMetadata;

  /// List of HCS transaction IDs.
  final List<String> hcsTransactionIds;

  /// List of raw HCS message maps.
  final List<Map<String, dynamic>> hcsMessages;

  /// Optional AI provenance summary.
  final VerifyAiSummary? aiSummary;

  /// ISO verification timestamp.
  final String verifiedAt;

  /// Verification status string.
  final String status;

  /// Optional Supabase batch DB record.
  final BatchInfo? batch;

  /// Creates an immutable [VerifyBatchResponse].
  const VerifyBatchResponse({
    required this.success,
    required this.cached,
    required this.tokenId,
    required this.serialNumber,
    required this.nftMetadata,
    required this.hcsTransactionIds,
    required this.hcsMessages,
    this.aiSummary,
    required this.verifiedAt,
    required this.status,
    this.batch,
  }) : super(verified: true);

  /// Deserializes from JSON map.
  factory VerifyBatchResponse.fromJson(Map<String, dynamic> json) {
    final aiJson = json['ai_summary'] ?? json['aiSummary'];
    final batchJson = json['batch'];
    return VerifyBatchResponse(
      success: json['success'] == true || json['ok'] == true,
      cached: json['cached'] == true,
      tokenId: json['tokenId'] as String? ?? json['token_id'] as String? ?? '',
      serialNumber:
          json['serialNumber']?.toString() ??
          json['serial_number']?.toString() ??
          '',
      nftMetadata: json['nftMetadata'] != null && json['nftMetadata'] is Map
          ? Map<String, dynamic>.from(json['nftMetadata'] as Map)
          : const {},
      hcsTransactionIds:
          (json['hcsTransactionIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['hcs_transaction_ids'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      hcsMessages:
          (json['hcsMessages'] as List?)
              ?.whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList() ??
          const [],
      aiSummary: aiJson != null && aiJson is Map
          ? VerifyAiSummary.fromJson(Map<String, dynamic>.from(aiJson))
          : null,
      verifiedAt:
          json['verifiedAt'] as String? ?? json['verified_at'] as String? ?? '',
      status: json['status'] as String? ?? 'verified',
      batch: batchJson != null && batchJson is Map
          ? BatchInfo.fromJson(Map<String, dynamic>.from(batchJson))
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'success': success,
    'verified': verified,
    'cached': cached,
    'tokenId': tokenId,
    'serialNumber': serialNumber,
    'nftMetadata': nftMetadata,
    'hcsTransactionIds': hcsTransactionIds,
    'hcsMessages': hcsMessages,
    if (aiSummary != null) 'ai_summary': aiSummary!.toJson(),
    'verifiedAt': verifiedAt,
    'status': status,
    if (batch != null) 'batch': batch!.toJson(),
  };
}

/// Verification result when a lot is not listed in AgroDex (HTTP 404).
/// Matches [VerifyBatchNotFoundResult] in React [api.ts].
@immutable
class VerifyBatchNotFoundResult extends VerifyBatchResult {
  /// Optional details map returned by backend.
  final Map<String, dynamic>? details;

  /// Creates a [VerifyBatchNotFoundResult].
  const VerifyBatchNotFoundResult({this.details})
    : super(verified: false, reason: 'not_found');

  /// Deserializes from a JSON map.
  factory VerifyBatchNotFoundResult.fromJson(Map<String, dynamic> json) {
    final details = json['details'];
    return VerifyBatchNotFoundResult(
      details: details != null && details is Map
          ? Map<String, dynamic>.from(details)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'verified': false,
    'reason': 'not_found',
    if (details != null) 'details': details,
  };
}

/// Verification result when a lot was deleted/withdrawn (HTTP 410).
/// Matches [VerifyBatchDeletedResult] in React [api.ts].
@immutable
class VerifyBatchDeletedResult extends VerifyBatchResult {
  /// Optional details map returned by backend.
  final Map<String, dynamic>? details;

  /// Creates a [VerifyBatchDeletedResult].
  const VerifyBatchDeletedResult({this.details})
    : super(verified: false, reason: 'deleted');

  /// Deserializes from a JSON map.
  factory VerifyBatchDeletedResult.fromJson(Map<String, dynamic> json) {
    final details = json['details'];
    return VerifyBatchDeletedResult(
      details: details != null && details is Map
          ? Map<String, dynamic>.from(details)
          : null,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'verified': false,
    'reason': 'deleted',
    if (details != null) 'details': details,
  };
}
