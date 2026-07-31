import 'dart:async';

import 'package:agrodex_mobile/core/error/failures.dart';
import 'package:agrodex_mobile/features/auth/domain/models/user_profile.dart';
import 'package:agrodex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Fake implementation of AuthRepository for unit & widget testing.
class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<sb.AuthState>.broadcast();
  sb.Session? _session;
  sb.User? _user;
  UserProfile? _profile;
  bool shouldThrowError = false;

  @override
  Stream<sb.AuthState> get onAuthStateChange => _controller.stream;

  @override
  sb.Session? get currentSession => _session;

  @override
  sb.User? get currentUser => _user;

  void setMockSession(
    sb.User user,
    sb.Session session, {
    UserProfile? profile,
  }) {
    _user = user;
    _session = session;
    _profile = profile;
    _controller.add(sb.AuthState(sb.AuthChangeEvent.signedIn, session));
  }

  @override
  Future<sb.AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (shouldThrowError) {
      throw const AuthFailure('Invalid credentials', code: '401');
    }
    return sb.AuthResponse(session: _session, user: _user);
  }

  @override
  Future<sb.AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? redirectTo,
  }) async {
    if (shouldThrowError) {
      throw const AuthFailure('Sign up failed');
    }
    return sb.AuthResponse(session: _session, user: _user);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _session = null;
    _profile = null;
    _controller.add(const sb.AuthState(sb.AuthChangeEvent.signedOut, null));
  }

  @override
  Future<UserProfile?> fetchUserProfile(String userId) async {
    return _profile;
  }

  @override
  Future<void> linkHederaWallet({
    required String userId,
    required String accountId,
    required String authMethod,
  }) async {
    if (shouldThrowError) {
      throw const ServerFailure('Wallet linking failed');
    }
    _profile = _profile?.copyWith(
      hederaAccountId: accountId,
      authMethod: authMethod,
    );
  }
}
