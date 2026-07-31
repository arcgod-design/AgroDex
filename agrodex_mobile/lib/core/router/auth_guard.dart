import 'package:agrodex_mobile/features/auth/domain/models/auth_state.dart';

/// Navigation guard protecting routes that require authentication
/// and redirecting authenticated users away from auth landing screens.
class AuthGuard {
  static const List<String> _publicRoutes = [
    '/welcome',
    '/login',
    '/about',
    '/verify',
    '/map',
  ];

  /// Evaluates [authState] against [targetLocation] and returns a new route path
  /// if a redirect is required, or `null` if navigation should proceed normally.
  static String? redirect(AuthState authState, String targetLocation) {
    final isAuthenticated = authState.isAuthenticated;
    final isPublicRoute = _publicRoutes.any(
      (route) =>
          targetLocation == route || targetLocation.startsWith('$route/'),
    );

    // If unauthenticated and trying to access a protected route, redirect to /welcome
    if (!isAuthenticated && !isPublicRoute) {
      return '/welcome';
    }

    // If authenticated and trying to access /welcome or /login, redirect to /dashboard
    if (isAuthenticated &&
        (targetLocation == '/welcome' || targetLocation == '/login')) {
      return '/dashboard';
    }

    return null;
  }
}
