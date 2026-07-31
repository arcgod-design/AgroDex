import 'package:agrodex_mobile/core/router/auth_guard.dart';
import 'package:agrodex_mobile/features/auth/domain/models/auth_state.dart';
import 'package:agrodex_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:agrodex_mobile/features/auth/presentation/screens/auth_landing_screen.dart';
import 'package:agrodex_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/screens/app_hub_screen.dart';
import 'package:agrodex_mobile/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/screens/batch_registration_screen.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/screens/batch_tokenize_screen.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/screens/batch_verify_screen.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/screens/map_explore_screen.dart';
import 'package:agrodex_mobile/features/risk_intelligence/presentation/screens/risk_intelligence_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// App routes catalog matching GoRouter paths.
enum AppRoute {
  welcome('/welcome'),
  login('/login'),
  appHub('/app'),
  dashboard('/dashboard'),
  register('/register'),
  tokenize('/tokenize'),
  verify('/verify'),
  map('/map'),
  riskIntelligence('/risk-intelligence');

  final String path;
  const AppRoute(this.path);
}

/// [ChangeNotifier] that bridges Riverpod [AuthState] changes to GoRouter's
/// [refreshListenable] mechanism.
///
/// GoRouter calls its [redirect] callback whenever [notifyListeners] fires.
/// By wiring this notifier to [authControllerProvider] via [ref.listen], we
/// let GoRouter re-evaluate the redirect **without** creating a new GoRouter
/// instance. This is the correct Riverpod + GoRouter integration pattern.
///
/// **Why this matters**: if [appRouterProvider] calls [ref.watch] on
/// [authControllerProvider] and returns `GoRouter(...)`, a *new* GoRouter
/// instance is created on every auth state change (including harmless calls
/// like `clearMessages()`). A fresh GoRouter always resets the navigation
/// stack to [initialLocation], which is what caused the Sign Up button to
/// navigate back to /welcome.
class _AuthStateNotifier extends ChangeNotifier {
  AuthState _authState;

  _AuthStateNotifier(this._authState);

  AuthState get authState => _authState;

  void update(AuthState next) {
    if (_authState == next) return; // avoid redundant notifications
    _authState = next;
    notifyListeners();
  }
}

/// Provider for the global [GoRouter] instance.
///
/// The router is created **exactly once** per [ProviderScope] lifetime.
/// Auth state changes are communicated to GoRouter via [refreshListenable]
/// so redirect logic re-runs without rebuilding the router.
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthStateNotifier(ref.read(authControllerProvider));

  // Forward every future auth state change to the notifier.
  // ref.listen (not ref.watch) keeps the GoRouter instance stable.
  ref.listen<AuthState>(authControllerProvider, (_, next) {
    notifier.update(next);
  });

  // Dispose the notifier when the provider is disposed.
  ref.onDispose(notifier.dispose);

  return GoRouter(
    initialLocation: '/welcome',
    debugLogDiagnostics: kDebugMode,
    refreshListenable: notifier,
    redirect: (BuildContext context, GoRouterState state) {
      return AuthGuard.redirect(notifier.authState, state.matchedLocation);
    },
    routes: [
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        builder: (context, state) => const AuthLandingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/app',
        name: 'appHub',
        builder: (context, state) => const AppHubScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const BatchRegistrationScreen(),
      ),
      GoRoute(
        path: '/tokenize',
        name: 'tokenize',
        builder: (context, state) => const BatchTokenizeScreen(),
      ),
      GoRoute(
        path: '/verify',
        name: 'verify',
        builder: (context, state) => const BatchVerifyScreen(),
      ),
      GoRoute(
        path: '/verify/:batchId',
        name: 'verifyBatchId',
        builder: (context, state) =>
            BatchVerifyScreen(batchId: state.pathParameters['batchId']),
      ),
      GoRoute(
        path: '/verify/:tokenId/:serialNumber',
        name: 'verifyTokenSerial',
        builder: (context, state) => BatchVerifyScreen(
          tokenId: state.pathParameters['tokenId'],
          serialNumber: state.pathParameters['serialNumber'],
        ),
      ),
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) => const MapExploreScreen(),
      ),
      GoRoute(
        path: '/risk-intelligence',
        name: 'riskIntelligence',
        builder: (context, state) => const RiskIntelligenceScreen(),
      ),
    ],
  );
});
