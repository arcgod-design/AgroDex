import 'package:agrodex_mobile/core/services/storage_service.dart';
import 'package:agrodex_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:agrodex_mobile/main.dart';
import 'package:agrodex_mobile/shared/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  testWidgets('AgroDexApp smoke test renders welcome auth landing screen', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.init();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWithValue(storageService),
          authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
        ],
        child: const AgroDexApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify that the initial welcome screen appears
    expect(find.text('AgroDex'), findsOneWidget);
    expect(
      find.text('AI-Powered Agricultural Traceability on Hedera'),
      findsOneWidget,
    );
    expect(find.text('Hedera Verified • Testnet'), findsOneWidget);
    expect(find.text('Email Login'), findsOneWidget);
  });
}
