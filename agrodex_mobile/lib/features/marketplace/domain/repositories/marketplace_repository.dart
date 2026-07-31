import 'package:agrodex_mobile/features/marketplace/domain/models/map_batch_model.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/register_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/tokenize_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_registration_models.dart';

/// Abstract contract for Marketplace operations matching React [api.ts].
abstract class MarketplaceRepository {
  /// Pre-verifies batch registration parameters with AI or local fallback.
  Future<VerifyRegistrationResponse> verifyRegistration(
    VerifyRegistrationRequest request,
  );

  /// Registers a batch onto Hedera Consensus Service via Edge Function.
  Future<RegisterBatchResponse> registerBatch(RegisterBatchRequest request);

  /// Tokenizes HCS transactions into a Hedera NFT.
  Future<TokenizeBatchResponse> tokenizeBatch(
    TokenizeBatchRequest request, {
    bool isDemoMode = false,
  });

  /// Verifies a batch by Hedera [tokenId] and [serialNumber].
  Future<VerifyBatchResult> verifyBatch(String tokenId, String serialNumber);

  /// Verifies a batch by Supabase [batchId] UUID.
  Future<VerifyBatchResult> verifyBatchById(String batchId);

  /// Retrieves all registered agricultural batches for Supply Chain Map.
  Future<List<MapBatch>> getBatches();

  /// Persists the last registered batch ID to local storage.
  Future<void> saveLastRegisteredBatchId(String batchId);

  /// Retrieves the last registered batch ID from local storage.
  Future<String?> getLastRegisteredBatchId();
}
