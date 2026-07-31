import 'package:agrodex_mobile/features/marketplace/domain/models/map_batch_model.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/register_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/tokenize_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_registration_models.dart';

/// DTO helper methods for Marketplace payload serialization and deserialization.
class MarketplaceDtos {
  MarketplaceDtos._();

  /// Deserializes a raw map into [RegisterBatchResponse].
  static RegisterBatchResponse fromRegisterBatchJson(
    Map<String, dynamic> json,
  ) {
    return RegisterBatchResponse.fromJson(json);
  }

  /// Serializes a [RegisterBatchRequest] into JSON map for Edge Function payload.
  static Map<String, dynamic> toRegisterBatchJson(
    RegisterBatchRequest request,
  ) {
    return request.toJson();
  }

  /// Deserializes a raw map into [VerifyRegistrationResponse].
  static VerifyRegistrationResponse fromVerifyRegistrationJson(
    Map<String, dynamic> json,
  ) {
    return VerifyRegistrationResponse.fromJson(json);
  }

  /// Deserializes a raw map into [VerifyBatchResult] union type.
  static VerifyBatchResult fromVerifyBatchJson(Map<String, dynamic> json) {
    return VerifyBatchResult.fromJson(json);
  }

  /// Deserializes a raw map into [TokenizeBatchResponse].
  static TokenizeBatchResponse fromTokenizeBatchJson(
    Map<String, dynamic> json,
  ) {
    return TokenizeBatchResponse.fromJson(json);
  }

  /// Deserializes a list of dynamic maps into a list of [MapBatch].
  static List<MapBatch> fromMapBatchesList(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((e) => MapBatch.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
