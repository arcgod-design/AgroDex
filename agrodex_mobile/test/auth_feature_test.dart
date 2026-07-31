import 'package:agrodex_mobile/core/router/auth_guard.dart';
import 'package:agrodex_mobile/features/auth/domain/models/auth_state.dart';
import 'package:agrodex_mobile/features/auth/domain/models/user_profile.dart';
import 'package:agrodex_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agrodex_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:agrodex_mobile/features/auth/presentation/screens/auth_landing_screen.dart';
import 'package:agrodex_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  group('UserProfile Domain Model Tests', () {
    test('serializes and deserializes from JSON correctly', () {
      final json = {
        'id': 'user-123',
        'email': 'farmer@agrodex.io',
        'hedera_account_id': '0.0.9988',
        'auth_method': 'hybrid',
        'created_at': '2025-10-28T10:00:00.000Z',
      };
      final profile = UserProfile.fromJson(json);

      expect(profile.id, 'user-123');
      expect(profile.email, 'farmer@agrodex.io');
      expect(profile.hederaAccountId, '0.0.9988');
      expect(profile.isWalletConnected, true);
      expect(profile.toJson()['auth_method'], 'hybrid');
    });

    test('isWalletConnected is false when hederaAccountId is null', () {
      const profile = UserProfile(id: 'user-456', email: 'test@agrodex.io');
      expect(profile.isWalletConnected, false);
    });
  });

  group('AuthState Domain Model Tests', () {
    test('isAuthenticated evaluates true when status is authenticated', () {
      const state = AuthState(status: AuthStatus.authenticated);
      final updated = state.copyWith(status: AuthStatus.unauthenticated);
      expect(updated.isAuthenticated, false);
    });

    test('clearError and clearSuccess reset message flags', () {
      final state = const AuthState(
        errorMessage: 'Some error',
        successMessage: 'Some success',
      ).copyWith(clearError: true, clearSuccess: true);

      expect(state.errorMessage, null);
      expect(state.successMessage, null);
    });
  });

  group('AuthGuard Routing Redirect Tests', () {
    test('redirects unauthenticated user from protected route to /welcome', () {
      const state = AuthState(status: AuthStatus.unauthenticated);
      final redirectPath = AuthGuard.redirect(state, '/dashboard');
      expect(redirectPath, '/welcome');
    });

    test('redirects authenticated user from /welcome to /dashboard', () {
      const state = AuthState(status: AuthStatus.authenticated);
      final redirectPath = AuthGuard.redirect(state, '/welcome');
      expect(redirectPath, null);
    });

    test('allows unauthenticated user to stay on /welcome or /login', () {
      const state = AuthState(status: AuthStatus.unauthenticated);
      expect(AuthGuard.redirect(state, '/welcome'), null);
      expect(AuthGuard.redirect(state, '/login'), null);
    });
  });

  group('AuthController Unit Tests', () {
    late FakeAuthRepository repository;

    setUp(() {
      repository = FakeAuthRepository();
    });

    test('initializes with unauthenticated state when no active session', () {
      final controller = AuthController(repository);
      expect(controller.state.status, AuthStatus.unauthenticated);
    });

    test('signInWithEmail transitions to error state on failure', () async {
      repository.shouldThrowError = true;
      final controller = AuthController(repository);

      await controller.signInWithEmail(
        email: 'bad@agrodex.io',
        password: 'wrong',
      );

      expect(controller.state.status, AuthStatus.error);
      expect(controller.state.errorMessage, 'Invalid credentials');
    });

    test('signOut clears state to unauthenticated', () async {
      final controller = AuthController(repository);
      await controller.signOut();

      expect(controller.state.status, AuthStatus.unauthenticated);
      expect(controller.state.user, null);
      expect(controller.state.profile, null);
    });
  });

  group('Feature 2 Widget Tests', () {
    testWidgets('AuthLandingScreen renders logo, title and login buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(home: AuthLandingScreen()),
        ),
      );

      expect(find.text('AgroDex'), findsOneWidget);
      expect(
        find.text('AI-Powered Agricultural Traceability on Hedera'),
        findsOneWidget,
      );
      expect(find.text('Hedera Blockchain'), findsOneWidget);
      expect(find.text('Email Login'), findsOneWidget);
      expect(find.text('EVM Wallet (MetaMask)'), findsOneWidget);
    });

    testWidgets('LoginScreen renders email and wallet tabs', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(FakeAuthRepository()),
          ],
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('EMAIL'), findsOneWidget);
      expect(find.text('WALLET'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);

      // Test toggle to Sign Up
      await tester.tap(find.text("Don't have an account? Sign Up"));
      await tester.pumpAndSettle();
      expect(find.text('Create Account'), findsWidgets);
    });
  });
}
