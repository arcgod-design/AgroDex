// ignore_for_file: invalid_annotation_target

import 'package:flutter/foundation.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/register_batch_models.dart';

/// Database batch record retrieved for MapExplore and SupplyChainMap.
/// Matches [MapBatch] in React [SupplyChainMap.tsx] and [getBatches] in [api.ts].
@immutable
class MapBatch {
  /// Unique batch UUID.
  final String id;

  /// Human-readable batch name or code.
  final String batchName;

  /// Harvest location string (e.g. "Aceh, Indonesia").
  final String location;

  /// Quantity string (e.g. "500 kg").
  final String quantity;

  /// Harvest date formatted as YYYY-MM-DD.
  final String harvestDate;

  /// Status string ("approved", "flagged", "pending").
  final String status;

  /// Supabase user UUID of the farmer who registered the batch.
  final String? farmerId;

  /// Optional HCS transaction ID.
  final String? hcsTxId;

  /// Optional visual AI analysis summary.
  final AiAnalysisSummary? aiAnalysis;

  /// Creates an immutable [MapBatch].
  const MapBatch({
    required this.id,
    required this.batchName,
    required this.location,
    required this.quantity,
    required this.harvestDate,
    required this.status,
    this.farmerId,
    this.hcsTxId,
    this.aiAnalysis,
  });

  /// Deserializes from a JSON map.
  factory MapBatch.fromJson(Map<String, dynamic> json) {
    final aiJson = json['ai_analysis'] ?? json['aiAnalysis'];
    return MapBatch(
      id: json['id'] as String? ?? '',
      batchName:
          json['batchName'] as String? ??
          json['batch_name'] as String? ??
          'Unnamed Batch',
      location: json['location'] as String? ?? 'Unknown Location',
      quantity: json['quantity'] as String? ?? '',
      harvestDate:
          json['harvestDate'] as String? ??
          json['harvest_date'] as String? ??
          '',
      status: json['status'] as String? ?? 'approved',
      farmerId: json['farmerId'] as String? ?? json['farmer_id'] as String?,
      hcsTxId: json['hcsTxId'] as String? ?? json['hcs_tx_id'] as String?,
      aiAnalysis: aiJson != null && aiJson is Map
          ? AiAnalysisSummary.fromJson(Map<String, dynamic>.from(aiJson))
          : null,
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'batch_name': batchName,
    'location': location,
    'quantity': quantity,
    'harvest_date': harvestDate,
    'status': status,
    if (farmerId != null) 'farmer_id': farmerId,
    if (hcsTxId != null) 'hcs_tx_id': hcsTxId,
    if (aiAnalysis != null) 'ai_analysis': aiAnalysis!.toJson(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MapBatch &&
        other.id == id &&
        other.batchName == batchName &&
        other.location == location &&
        other.status == status;
  }

  @override
  int get hashCode => Object.hash(id, batchName, location, status);
}
