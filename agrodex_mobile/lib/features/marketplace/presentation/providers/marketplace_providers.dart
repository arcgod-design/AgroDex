import 'package:agrodex_mobile/features/marketplace/data/repositories/supabase_marketplace_repository.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/map_batch_model.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/register_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/tokenize_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_registration_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:agrodex_mobile/shared/providers/core_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global provider for the [MarketplaceRepository] singleton.
final marketplaceRepositoryProvider = Provider<MarketplaceRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final supabaseClient = ref.watch(supabaseClientProvider);
  final storageService = ref.watch(storageServiceProvider);
  return SupabaseMarketplaceRepository(
    apiClient: apiClient,
    supabaseClient: supabaseClient,
    sharedPreferences: storageService.prefs,
  );
});

/// Fetches all registered agricultural batches for Supply Chain Map.
final mapBatchesProvider = FutureProvider.autoDispose<List<MapBatch>>((
  ref,
) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getBatches();
});

/// Parameters for batch verification query.
@immutable
class VerifyBatchParams {
  /// Optional Supabase batch UUID.
  final String? batchId;

  /// Optional Hedera token ID.
  final String? tokenId;

  /// Optional Hedera serial number.
  final String? serialNumber;

  /// Creates immutable [VerifyBatchParams].
  const VerifyBatchParams({this.batchId, this.tokenId, this.serialNumber});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VerifyBatchParams &&
        other.batchId == batchId &&
        other.tokenId == tokenId &&
        other.serialNumber == serialNumber;
  }

  @override
  int get hashCode => Object.hash(batchId, tokenId, serialNumber);
}

/// Resolves proof of authenticity for a lot by ID or Token+Serial.
final verifyBatchProvider = FutureProvider.autoDispose
    .family<VerifyBatchResult, VerifyBatchParams>((ref, params) async {
      final repository = ref.watch(marketplaceRepositoryProvider);
      if (params.batchId != null && params.batchId!.isNotEmpty) {
        return repository.verifyBatchById(params.batchId!);
      }
      if (params.tokenId != null && params.serialNumber != null) {
        return repository.verifyBatch(params.tokenId!, params.serialNumber!);
      }
      throw ArgumentError(
        'VerifyBatchParams requires batchId or tokenId/serialNumber',
      );
    });

/// Fetches the ID of the last batch registered on this device.
final lastRegisteredBatchIdProvider = FutureProvider.autoDispose<String?>((
  ref,
) async {
  final repository = ref.watch(marketplaceRepositoryProvider);
  return repository.getLastRegisteredBatchId();
});

/// Controller managing AI verification and batch registration mutations.
class BatchRegistrationController
    extends StateNotifier<AsyncValue<RegisterBatchResponse?>> {
  final MarketplaceRepository _repository;

  /// Creates a [BatchRegistrationController].
  BatchRegistrationController(this._repository)
    : super(const AsyncValue.data(null));

  /// Calls Express AI verification or local fallback.
  Future<VerifyRegistrationResponse> verifyRegistration(
    VerifyRegistrationRequest request,
  ) async {
    return _repository.verifyRegistration(request);
  }

  /// Registers a batch via Supabase Edge Function and saves its ID.
  Future<RegisterBatchResponse?> registerBatch(
    RegisterBatchRequest request,
  ) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.registerBatch(request);
      if (result.batchId.isNotEmpty) {
        await _repository.saveLastRegisteredBatchId(result.batchId);
      }
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Reset state to initial.
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for [BatchRegistrationController].
final batchRegistrationControllerProvider =
    StateNotifierProvider.autoDispose<
      BatchRegistrationController,
      AsyncValue<RegisterBatchResponse?>
    >((ref) {
      final repository = ref.watch(marketplaceRepositoryProvider);
      return BatchRegistrationController(repository);
    });

/// Controller managing batch tokenization mutations.
class BatchTokenizationController
    extends StateNotifier<AsyncValue<TokenizeBatchResponse?>> {
  final MarketplaceRepository _repository;

  /// Creates a [BatchTokenizationController].
  BatchTokenizationController(this._repository)
    : super(const AsyncValue.data(null));

  /// Tokenizes a list of HCS transaction IDs into Hedera Token Service NFTs.
  Future<TokenizeBatchResponse?> tokenize(
    TokenizeBatchRequest request, {
    bool isDemoMode = false,
  }) async {
    state = const AsyncValue.loading();
    try {
      final result = await _repository.tokenizeBatch(
        request,
        isDemoMode: isDemoMode,
      );
      state = AsyncValue.data(result);
      return result;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  /// Reset state to initial.
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for [BatchTokenizationController].
final batchTokenizationControllerProvider =
    StateNotifierProvider.autoDispose<
      BatchTokenizationController,
      AsyncValue<TokenizeBatchResponse?>
    >((ref) {
      final repository = ref.watch(marketplaceRepositoryProvider);
      return BatchTokenizationController(repository);
    });
