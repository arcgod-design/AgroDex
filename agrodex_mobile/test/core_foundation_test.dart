import 'package:agrodex_mobile/core/error/error_handler.dart';
import 'package:agrodex_mobile/core/error/failures.dart';
import 'package:agrodex_mobile/core/utils/date_formatter.dart';
import 'package:agrodex_mobile/shared/models/api_response.dart';
import 'package:agrodex_mobile/shared/widgets/app_button.dart';
import 'package:agrodex_mobile/shared/widgets/app_card.dart';
import 'package:agrodex_mobile/shared/widgets/trust_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateFormatter Unit Tests', () {
    test('normalizes DD-MM-YYYY to YYYY-MM-DD correctly', () {
      final result = DateFormatter.normalizeDate('28-10-2025');
      expect(result, '2025-10-28');
    });

    test('preserves valid YYYY-MM-DD date format unchanged', () {
      final result = DateFormatter.normalizeDate('2025-10-28');
      expect(result, '2025-10-28');
    });

    test('throws ValidationException when input is ambiguous or invalid', () {
      expect(
        () => DateFormatter.normalizeDate('99-99-2025'),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('ApiResponse DTO Unit Tests', () {
    test('creates success response correctly', () {
      final response = ApiResponse.success('Batch 101', message: 'Registered');
      expect(response.ok, true);
      expect(response.data, 'Batch 101');
      expect(response.message, 'Registered');
    });

    test('creates error response correctly', () {
      final response = ApiResponse<void>.error('Batch not found');
      expect(response.ok, false);
      expect(response.error, 'Batch not found');
    });

    test('parses JSON payload via fromJson', () {
      final json = {
        'ok': true,
        'data': {'id': 1},
        'message': 'OK',
      };
      final response = ApiResponse.fromJson(
        json,
        (obj) => (obj as Map<String, dynamic>)['id'] as int,
      );
      expect(response.ok, true);
      expect(response.data, 1);
      expect(response.message, 'OK');
    });
  });

  group('ErrorHandler Unit Tests', () {
    test('converts AuthException into AuthFailure', () {
      const exception = AuthException('Token expired', code: '401');
      final failure = ErrorHandler.handle(exception);
      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Token expired');
      expect(failure.code, '401');
    });

    test('converts ValidationException into ValidationFailure', () {
      const exception = ValidationException('Invalid date format');
      final failure = ErrorHandler.handle(exception);
      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Invalid date format');
    });

    test('converts generic exceptions into ServerFailure', () {
      final failure = ErrorHandler.handle(Exception('Server unreachable'));
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'Server unreachable');
    });
  });

  group('Reusable UI Widget Tests', () {
    testWidgets('AppButton renders label and triggers callback', (
      tester,
    ) async {
      bool pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(label: 'Submit', onPressed: () => pressed = true),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(pressed, true);
    });

    testWidgets('TrustBadgeWidget renders score and color properly', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: TrustBadgeWidget(score: 92))),
      );

      expect(find.text('92'), findsOneWidget);
      expect(find.text('/ 100'), findsOneWidget);
      expect(find.text('AI TRUST SCORE'), findsOneWidget);
    });

    testWidgets('AppCard renders child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppCard(child: Text('Card Content Test'))),
        ),
      );

      expect(find.text('Card Content Test'), findsOneWidget);
    });
  });
}
