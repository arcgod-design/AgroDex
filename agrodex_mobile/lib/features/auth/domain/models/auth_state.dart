import 'package:agrodex_mobile/features/auth/domain/models/user_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Represents the status of the authentication session in the application.
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Immutable authentication state holding session tokens, current user,
/// profile data, and error/success messaging.
@immutable
class AuthState {
  final AuthStatus status;
  final sb.User? user;
  final sb.Session? session;
  final UserProfile? profile;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.session,
    this.profile,
    this.errorMessage,
    this.successMessage,
  });

  bool get isAuthenticated =>
      status == AuthStatus.authenticated && (user != null || session != null);

  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    sb.User? user,
    sb.Session? session,
    UserProfile? profile,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      session: session ?? this.session,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess
          ? null
          : (successMessage ?? this.successMessage),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user?.id == user?.id &&
        other.session?.accessToken == session?.accessToken &&
        other.profile == profile &&
        other.errorMessage == errorMessage &&
        other.successMessage == successMessage;
  }

  @override
  int get hashCode => Object.hash(
    status,
    user?.id,
    session?.accessToken,
    profile,
    errorMessage,
    successMessage,
  );

  @override
  String toString() =>
      'AuthState(status: $status, userId: ${user?.id}, error: $errorMessage)';
}
