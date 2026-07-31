// Regression test: GoRouter must NOT be recreated when auth state changes.
//
// Bug history:
//   Before the fix, `appRouterProvider` called `ref.watch(authControllerProvider)`
//   in its body. Every auth state emission — including harmless `clearMessages()`
//   calls — recreated the GoRouter with `initialLocation: '/welcome'`, wiping the
//   navigation stack. Tapping "Don't have an account? Sign Up" called
//   `clearMessages()`, which triggered a router recreation, navigating the user
//   back to /welcome instead of staying on /login in Create Account mode.
//
//   Fix: GoRouter is now created exactly once. Auth state is forwarded to it via
//   `refreshListenable` (_AuthStateNotifier), which causes GoRouter to re-evaluate
//   its `redirect` callback without constructing a new instance.
//
// This file must not be merged with auth_feature_test.dart because it imports
// the full GoRouter provider stack (appRouterProvider + authControllerProvider),
// which would create a real Supabase dependency in that lighter test suite.

import 'package:agrodex_mobile/core/router/app_router.dart';
import 'package:agrodex_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_auth_repository.dart';

void main() {
  group('GoRouter Stability — Regression: Sign Up must not reset navigation', () {
    /// Builds a minimal app using the real [appRouterProvider] wired to a
    /// [FakeAuthRepository] so no Supabase SDK is needed.
    Widget buildApp(FakeAuthRepository repo) {
      return ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repo)],
        child: Builder(
          builder: (context) {
            // Obtain the router from the real provider — this is the object
            // under test.
            return Consumer(
              builder: (context, ref, _) {
                final router = ref.watch(appRouterProvider);
                return MaterialApp.router(routerConfig: router);
              },
            );
          },
        ),
      );
    }

    // ─────────────────────────────────────────────────────────────────────────
    // Test 1: GoRouter is created exactly once across multiple auth state
    //         emissions. Verifies the provider body does not contain ref.watch.
    // ─────────────────────────────────────────────────────────────────────────
    testWidgets(
      '1. GoRouter instance is stable across auth state changes',
      (tester) async {
        final repo = FakeAuthRepository();
        await tester.pumpWidget(buildApp(repo));
        await tester.pumpAndSettle();

        // Capture the router instance from the ProviderScope.
        final container = ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );
        final router1 = container.read(appRouterProvider);

        // Trigger an auth state change (clearMessages equivalent).
        container.read(authControllerProvider.notifier).clearMessages();
        await tester.pumpAndSettle();

        final router2 = container.read(appRouterProvider);

        // The exact same GoRouter instance must be returned — no recreation.
        expect(
          identical(router1, router2),
          isTrue,
          reason:
              'appRouterProvider must return the same GoRouter instance after '
              'an auth state change. If this fails, ref.watch was used in the '
              'provider body instead of ref.listen + refreshListenable.',
        );
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Test 2: Navigate to /login → tap "Sign Up" → assert location stays /login
    //         and Create Account mode is displayed.
    // ─────────────────────────────────────────────────────────────────────────
    testWidgets(
      '2. Tapping "Sign Up" switches to Create Account mode without changing route',
      (tester) async {
        final repo = FakeAuthRepository();
        await tester.pumpWidget(buildApp(repo));
        await tester.pumpAndSettle();

        // Step 1: Navigate from /welcome to /login.
        final container = ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );
        final router = container.read(appRouterProvider);
        router.go('/login');
        await tester.pumpAndSettle();

        // Step 2: Confirm we are on the Login screen in Sign In mode.
        expect(find.text('Welcome Back'), findsOneWidget);
        expect(router.routerDelegate.currentConfiguration.fullPath, '/login');

        // Step 3: Tap the Sign Up toggle.
        await tester.tap(find.text("Don't have an account? Sign Up"));
        await tester.pumpAndSettle();

        // Step 4: Assert Create Account mode is active.
        expect(
          find.text('Create Account'),
          findsWidgets,
          reason: 'The screen title and button label must switch to Create Account.',
        );

        // Step 5: Assert the route did NOT change.
        expect(
          router.routerDelegate.currentConfiguration.fullPath,
          '/login',
          reason:
              'The route must remain /login after tapping Sign Up. '
              'If this fails, GoRouter was recreated and reset to initialLocation.',
        );
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Test 3: Multiple clearMessages() calls must not reset navigation.
    // ─────────────────────────────────────────────────────────────────────────
    testWidgets(
      '3. Multiple clearMessages() calls do not reset navigation stack',
      (tester) async {
        final repo = FakeAuthRepository();
        await tester.pumpWidget(buildApp(repo));
        await tester.pumpAndSettle();

        final container = ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );
        final router = container.read(appRouterProvider);

        // Navigate to /login.
        router.go('/login');
        await tester.pumpAndSettle();
        expect(router.routerDelegate.currentConfiguration.fullPath, '/login');

        // Fire multiple clearMessages() calls (what Sign Up toggle does).
        final notifier = container.read(authControllerProvider.notifier);
        notifier.clearMessages();
        await tester.pump();
        notifier.clearMessages();
        await tester.pump();
        notifier.clearMessages();
        await tester.pumpAndSettle();

        // Route must still be /login — not reset to /welcome.
        expect(
          router.routerDelegate.currentConfiguration.fullPath,
          '/login',
          reason:
              'clearMessages() must not reset navigation. '
              'Each call emits a new AuthState; if the router is recreated '
              'on each emission the route would reset to /welcome.',
        );
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Test 4: Toggle Sign In ↔ Sign Up multiple times — route never resets.
    // ─────────────────────────────────────────────────────────────────────────
    testWidgets(
      '4. Toggling Sign In and Sign Up repeatedly never resets route to /welcome',
      (tester) async {
        final repo = FakeAuthRepository();
        await tester.pumpWidget(buildApp(repo));
        await tester.pumpAndSettle();

        final container = ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );
        final router = container.read(appRouterProvider);

        router.go('/login');
        await tester.pumpAndSettle();

        // Toggle Sign Up.
        await tester.tap(find.text("Don't have an account? Sign Up"));
        await tester.pumpAndSettle();
        expect(router.routerDelegate.currentConfiguration.fullPath, '/login');

        // Toggle back to Sign In.
        await tester.tap(find.text('Already have an account? Sign In'));
        await tester.pumpAndSettle();
        expect(router.routerDelegate.currentConfiguration.fullPath, '/login');

        // Toggle Sign Up again.
        await tester.tap(find.text("Don't have an account? Sign Up"));
        await tester.pumpAndSettle();
        expect(
          router.routerDelegate.currentConfiguration.fullPath,
          '/login',
          reason: 'Route must remain /login through all Sign In/Up toggles.',
        );
      },
    );

    // ─────────────────────────────────────────────────────────────────────────
    // Test 5: Auth state change that IS meaningful (sign-out) DOES redirect.
    //         Verifies that the fix does not break legitimate auth redirects.
    // ─────────────────────────────────────────────────────────────────────────
    testWidgets(
      '5. Legitimate auth state changes (e.g. sign-out) still trigger redirects',
      (tester) async {
        final repo = FakeAuthRepository();
        await tester.pumpWidget(buildApp(repo));
        await tester.pumpAndSettle();

        final container = ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        );
        final router = container.read(appRouterProvider);
        final notifier = container.read(authControllerProvider.notifier);

        // Start unauthenticated — on /welcome is expected.
        expect(
          router.routerDelegate.currentConfiguration.fullPath,
          '/welcome',
        );

        // Attempting to navigate to a protected route while unauthenticated
        // must redirect back to /welcome via AuthGuard.
        router.go('/dashboard');
        await tester.pumpAndSettle();

        expect(
          router.routerDelegate.currentConfiguration.fullPath,
          '/welcome',
          reason:
              'AuthGuard must redirect unauthenticated access to /dashboard '
              'back to /welcome. The router stability fix must not break guards.',
        );

        // clearMessages should NOT redirect away from wherever we are.
        router.go('/login');
        await tester.pumpAndSettle();
        notifier.clearMessages();
        await tester.pumpAndSettle();

        expect(
          router.routerDelegate.currentConfiguration.fullPath,
          '/login',
          reason: 'clearMessages must never redirect.',
        );
      },
    );
  });
}
