import 'package:agrodex_mobile/core/error/failures.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/map_batch_model.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/register_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/tokenize_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_registration_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/validators/marketplace_validators.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/screens/batch_registration_screen.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/screens/batch_tokenize_screen.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/screens/batch_verify_screen.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/widgets/batch_card_widget.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/widgets/verification_status_badge.dart';
import 'package:agrodex_mobile/features/marketplace/domain/repositories/marketplace_repository.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeMarketplaceRepository implements MarketplaceRepository {
  @override
  Future<VerifyRegistrationResponse> verifyRegistration(
    VerifyRegistrationRequest request,
  ) async {
    return const VerifyRegistrationResponse(
      ok: true,
      data: VerifyRegistrationSummary(
        productSummary: 'Test Product',
        verificationSummary: {},
        cooperativeReadiness: CooperativeReadiness(status: 'Ready', notes: []),
        warnings: [],
        consistencyChecks: [],
        statistics: {},
        fallback: true,
      ),
    );
  }

  @override
  Future<RegisterBatchResponse> registerBatch(
    RegisterBatchRequest request,
  ) async {
    return const RegisterBatchResponse(
      success: true,
      hcsTransactionId: '0.0.123@170000.00',
      batchId: 'uuid-123',
      message: 'Success',
    );
  }

  @override
  Future<TokenizeBatchResponse> tokenizeBatch(
    TokenizeBatchRequest request, {
    bool isDemoMode = false,
  }) async {
    return const TokenizeBatchResponse(
      success: true,
      tokenId: '0.0.9999',
      serialNumber: '1',
      batchId: 'uuid-123',
      hcsTransactionIds: ['tx1'],
    );
  }

  @override
  Future<VerifyBatchResult> verifyBatch(
    String tokenId,
    String serialNumber,
  ) async {
    return const VerifyBatchResponse(
      success: true,
      cached: false,
      tokenId: '0.0.9999',
      serialNumber: '1',
      nftMetadata: {},
      hcsTransactionIds: ['tx1'],
      hcsMessages: [],
      verifiedAt: '2026-07-30T12:00:00Z',
      status: 'verified',
    );
  }

  @override
  Future<VerifyBatchResult> verifyBatchById(String batchId) async {
    return const VerifyBatchResponse(
      success: true,
      cached: false,
      tokenId: '0.0.9999',
      serialNumber: '1',
      nftMetadata: {},
      hcsTransactionIds: ['tx1'],
      hcsMessages: [],
      verifiedAt: '2026-07-30T12:00:00Z',
      status: 'verified',
    );
  }

  @override
  Future<List<MapBatch>> getBatches() async {
    return const [
      MapBatch(
        id: 'map-101',
        batchName: 'Sumatra Coffee',
        location: 'Aceh',
        quantity: '500 kg',
        harvestDate: '2026-04-10',
        status: 'approved',
      ),
    ];
  }

  @override
  Future<String?> getLastRegisteredBatchId() async => 'uuid-123';

  @override
  Future<void> saveLastRegisteredBatchId(String batchId) async {}
}

void main() {
  group('Feature 4: Marketplace Domain Models & DTOs', () {
    test('RegisterBatchRequest serialization and equality', () {
      const req1 = RegisterBatchRequest(
        productType: 'Arabica Coffee',
        quantity: '500 kg',
        location: 'Aceh, Sumatra',
        imageData: 'base64data',
        harvestDate: '2026-05-20',
      );
      const req2 = RegisterBatchRequest(
        productType: 'Arabica Coffee',
        quantity: '500 kg',
        location: 'Aceh, Sumatra',
        imageData: 'base64data',
        harvestDate: '2026-05-20',
      );

      expect(req1, equals(req2));
      expect(req1.toJson()['productType'], 'Arabica Coffee');
      expect(req1.toJson()['harvestDate'], '2026-05-20');
    });

    test('RegisterBatchResponse deserialization', () {
      final json = {
        'success': true,
        'hcs_transaction_id': '0.0.123@17000000.00',
        'batch_id': 'uuid-batch-101',
        'message': 'Registered successfully',
        'ai_analysis': {
          'caption': 'Healthy green coffee beans',
          'confidence': 0.96,
          'anomalies': [],
          'tags': ['coffee', 'arabica'],
          'generatedAt': '2026-05-20T10:00:00Z',
          'ms': 180,
        },
      };

      final res = RegisterBatchResponse.fromJson(json);
      expect(res.success, isTrue);
      expect(res.hcsTransactionId, '0.0.123@17000000.00');
      expect(res.batchId, 'uuid-batch-101');
      expect(res.aiAnalysis?.caption, 'Healthy green coffee beans');
      expect(res.aiAnalysis?.confidence, 0.96);
    });

    test('generateLocalFallbackVerification replicates React logic 1:1', () {
      const reqGood = VerifyRegistrationRequest(
        productName: 'Cocoa Beans',
        harvestBatch: 'B-100',
        quantity: '200',
        unit: 'kg',
        location: 'Sumatra Farm',
        harvestDate: '2025-01-10',
      );

      final summaryGood = generateLocalFallbackVerification(reqGood);
      expect(summaryGood.fallback, isTrue);
      expect(summaryGood.cooperativeReadiness.status, 'Ready');
      expect(summaryGood.warnings, isEmpty);
      expect(summaryGood.verificationSummary['quantity'], 'Provided: 200 kg');

      const reqBad = VerifyRegistrationRequest(
        productName: 'Cocoa Beans',
        harvestBatch: 'B-101',
        quantity: '100',
        unit: 'kg',
        location: 'A', // Too short
        harvestDate: '2099-01-01', // Future date
      );

      final summaryBad = generateLocalFallbackVerification(reqBad);
      expect(summaryBad.cooperativeReadiness.status, 'Review Required');
      expect(summaryBad.warnings.length, greaterThanOrEqualTo(1));
      expect(
        summaryBad.consistencyChecks,
        contains('Future harvest date detected'),
      );
    });

    test(
      'VerifyBatchResult union deserialization (Response, NotFound, Deleted)',
      () {
        final okJson = {
          'success': true,
          'cached': false,
          'tokenId': '0.0.5555',
          'serialNumber': '1',
          'nftMetadata': {},
          'hcsTransactionIds': ['tx1', 'tx2'],
          'hcsMessages': [],
          'verifiedAt': '2026-05-20T10:00:00Z',
          'status': 'verified',
        };
        final okRes = VerifyBatchResult.fromJson(okJson);
        expect(okRes, isA<VerifyBatchResponse>());
        expect((okRes as VerifyBatchResponse).tokenId, '0.0.5555');

        final notFoundJson = {'verified': false, 'reason': 'not_found'};
        final notFoundRes = VerifyBatchResult.fromJson(notFoundJson);
        expect(notFoundRes, isA<VerifyBatchNotFoundResult>());
        expect(notFoundRes.verified, isFalse);

        final deletedJson = {'verified': false, 'reason': 'deleted'};
        final deletedRes = VerifyBatchResult.fromJson(deletedJson);
        expect(deletedRes, isA<VerifyBatchDeletedResult>());
        expect(deletedRes.verified, isFalse);
      },
    );

    test('TokenizeBatchResponse deserialization', () {
      final json = {
        'success': true,
        'tokenId': '0.0.7777',
        'serialNumber': '12',
        'batchId': 'uuid-101',
        'hcsTransactionIds': ['tx-a', 'tx-b'],
      };

      final res = TokenizeBatchResponse.fromJson(json);
      expect(res.success, isTrue);
      expect(res.tokenId, '0.0.7777');
      expect(res.serialNumber, '12');
      expect(res.hcsTransactionIds.length, 2);
    });

    test('MapBatch deserialization', () {
      final json = {
        'id': 'map-101',
        'batch_name': 'Sumatra Organic Coffee',
        'location': 'Aceh, Indonesia',
        'quantity': '400 kg',
        'harvest_date': '2026-04-10',
        'status': 'approved',
      };

      final batch = MapBatch.fromJson(json);
      expect(batch.id, 'map-101');
      expect(batch.batchName, 'Sumatra Organic Coffee');
      expect(batch.status, 'approved');
    });
  });

  group('Feature 4: MarketplaceValidators & QR Scanner Logic', () {
    test(
      'validateRegistration throws ValidationException on invalid input',
      () {
        expect(
          () => MarketplaceValidators.validateRegistration(
            productType: '',
            quantity: '10',
            location: 'Aceh',
            harvestDate: '2026-01-01',
          ),
          throwsA(isA<ValidationException>()),
        );

        expect(
          () => MarketplaceValidators.validateRegistration(
            productType: 'Coffee',
            quantity: '100',
            location: 'A',
            harvestDate: '2026-01-01',
          ),
          throwsA(isA<ValidationException>()),
        );
      },
    );

    test('parseAndValidateHcsTxIds correctly splits lines and commas', () {
      const input = '0.0.123@1700.000\n0.0.123@1701.000, 0.0.123@1702.000';
      final ids = MarketplaceValidators.parseAndValidateHcsTxIds(input);
      expect(ids.length, 3);
      expect(ids.first, '0.0.123@1700.000');
    });

    test('validateQrPayload parses UUID JSON, URL, and rejects XSS schemes', () {
      const validJson =
          '{"batchId": "f47ac10b-58cc-4372-a567-0e02b2c3d479", "verificationUrl": "https://agrodex.io/verify/123"}';
      final payload = MarketplaceValidators.validateQrPayload(validJson);
      expect(payload, isNotNull);
      expect(payload!.batchId, 'f47ac10b-58cc-4372-a567-0e02b2c3d479');

      const validUrl =
          'https://agrodex.io/verify/f47ac10b-58cc-4372-a567-0e02b2c3d479';
      final urlPayload = MarketplaceValidators.validateQrPayload(validUrl);
      expect(urlPayload, isNotNull);
      expect(urlPayload!.rawUrl, validUrl);

      const xssJson =
          '{"batchId": "f47ac10b-58cc-4372-a567-0e02b2c3d479", "verificationUrl": "javascript:alert(1)"}';
      final xssPayload = MarketplaceValidators.validateQrPayload(xssJson);
      expect(xssPayload, isNull);
    });
  });

  group('Feature 4: Reusable Marketplace Widgets & Screens', () {
    testWidgets(
      'VerificationStatusBadge renders correct label and trust score',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: VerificationStatusBadge(status: 'verified', trustScore: 95),
            ),
          ),
        );

        expect(find.text('VERIFIED'), findsOneWidget);
        expect(find.text('Trust: 95/100'), findsOneWidget);
        expect(find.byIcon(Icons.verified), findsOneWidget);
      },
    );

    testWidgets('BatchCardWidget renders lot information', (tester) async {
      const sampleBatch = MapBatch(
        id: '1',
        batchName: 'Sumatra Coffee',
        location: 'Aceh',
        quantity: '500 kg',
        harvestDate: '2026-04-10',
        status: 'approved',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: BatchCardWidget(batch: sampleBatch)),
        ),
      );

      expect(find.text('Sumatra Coffee'), findsOneWidget);
      expect(find.text('Aceh'), findsOneWidget);
      expect(find.text('Qty: 500 kg'), findsOneWidget);
      expect(find.text('APPROVED'), findsOneWidget);
    });

    testWidgets('BatchRegistrationScreen renders form fields', (tester) async {
      final fakeRepo = FakeMarketplaceRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            marketplaceRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: BatchRegistrationScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Create Immutable Supply Chain Lot'), findsOneWidget);
      expect(find.text('Product / Crop Type *'), findsOneWidget);
      expect(find.text('Quantity *'), findsOneWidget);
      expect(find.text('Harvest Location / Origin *'), findsOneWidget);
      expect(find.text('Verify with AI & Register on Hedera'), findsOneWidget);
    });

    testWidgets('BatchVerifyScreen renders search hub when no parameters', (
      tester,
    ) async {
      final fakeRepo = FakeMarketplaceRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            marketplaceRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: BatchVerifyScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Supply Chain Proof of Authenticity'), findsOneWidget);
      expect(find.text('Lot ID / Batch UUID'), findsOneWidget);
      expect(find.text('Verify Lot'), findsOneWidget);
      expect(find.text('Scan QR Code'), findsOneWidget);
    });

    testWidgets('BatchTokenizeScreen renders tokenization form', (
      tester,
    ) async {
      final fakeRepo = FakeMarketplaceRepository();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            marketplaceRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(home: BatchTokenizeScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mint Hedera NFT Token'), findsOneWidget);
      expect(
        find.text('HCS Transaction IDs (one per line or comma separated)'),
        findsOneWidget,
      );
      expect(find.text('Demo / Simulation Mode'), findsOneWidget);
      expect(find.text('Tokenize Batch on Hedera'), findsOneWidget);
    });
  });
}
