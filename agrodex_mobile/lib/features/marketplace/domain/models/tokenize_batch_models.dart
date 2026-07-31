// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_batch_models.dart';

/// Request payload for tokenizing an HCS batch into a Hedera Token Service NFT.
/// Matches [TokenizeBatchRequest] in React [api.ts].
@immutable
class TokenizeBatchRequest {
  /// List of HCS transaction IDs to tokenize.
  final List<String> hcsTransactionIds;

  /// Optional Supabase database batch ID to link.
  final String? batchId;

  /// Creates an immutable [TokenizeBatchRequest].
  const TokenizeBatchRequest({required this.hcsTransactionIds, this.batchId});

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
    'hcsTransactionIds': hcsTransactionIds,
    if (batchId != null) 'batchId': batchId,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TokenizeBatchRequest &&
        listEquals(other.hcsTransactionIds, hcsTransactionIds) &&
        other.batchId == batchId;
  }

  @override
  int get hashCode => Object.hash(Object.hashAll(hcsTransactionIds), batchId);
}

/// Successful tokenization response from Supabase Edge Function `tokenize-batch`.
/// Matches [TokenizeBatchResponse] in React [api.ts].
@immutable
class TokenizeBatchResponse {
  /// Whether tokenization succeeded.
  final bool success;

  /// Minted Hedera token ID (e.g., 0.0.12345).
  final String tokenId;

  /// Minted Hedera serial number.
  final String serialNumber;

  /// Linked Supabase batch UUID if any.
  final String? batchId;

  /// List of tokenized HCS transaction IDs.
  final List<String> hcsTransactionIds;

  /// Optional AI summary generated during tokenization.
  final VerifyAiSummary? aiSummary;

  /// Creates an immutable [TokenizeBatchResponse].
  const TokenizeBatchResponse({
    required this.success,
    required this.tokenId,
    required this.serialNumber,
    this.batchId,
    required this.hcsTransactionIds,
    this.aiSummary,
  });

  /// Deserializes from a JSON map.
  factory TokenizeBatchResponse.fromJson(Map<String, dynamic> json) {
    final aiJson = json['ai_summary'] ?? json['aiSummary'];
    return TokenizeBatchResponse(
      success: json['success'] == true,
      tokenId: json['tokenId'] as String? ?? json['token_id'] as String? ?? '',
      serialNumber:
          json['serialNumber']?.toString() ??
          json['serial_number']?.toString() ??
          '',
      batchId: json['batchId'] as String? ?? json['batch_id'] as String?,
      hcsTransactionIds:
          (json['hcsTransactionIds'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['hcs_transaction_ids'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      aiSummary: aiJson != null && aiJson is Map
          ? VerifyAiSummary.fromJson(Map<String, dynamic>.from(aiJson))
          : null,
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
    'success': success,
    'tokenId': tokenId,
    'serialNumber': serialNumber,
    if (batchId != null) 'batchId': batchId,
    'hcsTransactionIds': hcsTransactionIds,
    if (aiSummary != null) 'ai_summary': aiSummary!.toJson(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TokenizeBatchResponse &&
        other.success == success &&
        other.tokenId == tokenId &&
        other.serialNumber == serialNumber &&
        other.batchId == batchId;
  }

  @override
  int get hashCode => Object.hash(success, tokenId, serialNumber, batchId);
}
