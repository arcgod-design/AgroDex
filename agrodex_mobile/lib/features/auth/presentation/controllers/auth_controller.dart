import 'dart:async';

import 'package:agrodex_mobile/core/error/error_handler.dart';
import 'package:agrodex_mobile/core/error/failures.dart';
import 'package:agrodex_mobile/core/services/logger_service.dart';
import 'package:agrodex_mobile/features/auth/domain/models/auth_state.dart';
import 'package:agrodex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// StateNotifier controller managing authentication flow, session persistence,
/// profile synchronization, and error handling.
class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<sb.AuthState>? _authSubscription;

  AuthController(this._authRepository) : super(const AuthState()) {
    _init();
  }

  void _init() {
    final currentSession = _authRepository.currentSession;
    final currentUser = _authRepository.currentUser;

    if (currentSession != null && currentUser != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: currentUser,
        session: currentSession,
      );
      _fetchProfile(currentUser.id);
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    _authSubscription = _authRepository.onAuthStateChange.listen((authState) {
      final session = authState.session;
      final user = session?.user;

      if (session != null && user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          session: session,
        );
        _fetchProfile(user.id);
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          session: null,
          profile: null,
        );
      }
    });
  }

  Future<void> _fetchProfile(String userId) async {
    try {
      final profile = await _authRepository.fetchUserProfile(userId);
      if (mounted && profile != null) {
        state = state.copyWith(profile: profile);
      }
    } catch (e, stackTrace) {
      LoggerService.error(
        'Failed to fetch user profile',
        e,
        stackTrace,
        'AuthController',
      );
    }
  }

  /// Authenticates user with email and password.
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearSuccess: true,
    );
    try {
      final response = await _authRepository.signInWithEmail(
        email: email,
        password: password,
      );
      final user = response.user;
      final session = response.session;

      if (user != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          session: session,
        );
        await _fetchProfile(user.id);
      }
    } catch (e) {
      final failure = e is Failure ? e : ErrorHandler.handle(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  /// Registers user with email and password.
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? redirectTo,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearSuccess: true,
    );
    try {
      final response = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        redirectTo: redirectTo,
      );
      final user = response.user;
      final session = response.session;

      if (user != null && session == null) {
        // Verification email sent
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          successMessage:
              'Please check your email and verify your account before signing in.',
        );
      } else if (user != null && session != null) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          session: session,
          successMessage: 'Account created successfully!',
        );
        await _fetchProfile(user.id);
      }
    } catch (e) {
      final failure = e is Failure ? e : ErrorHandler.handle(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  /// Logs out current user and clears state tokens.
  Future<void> signOut() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      clearError: true,
      clearSuccess: true,
    );
    try {
      await _authRepository.signOut();
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        session: null,
        profile: null,
      );
    } catch (e) {
      final failure = e is Failure ? e : ErrorHandler.handle(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  /// Links a Hedera wallet address to the current profile.
  Future<void> linkHederaWallet(String accountId) async {
    final user = state.user;
    if (user == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No user logged in to link wallet',
      );
      return;
    }

    try {
      final authMethod = user.email != null ? 'hybrid' : 'wallet';
      await _authRepository.linkHederaWallet(
        userId: user.id,
        accountId: accountId,
        authMethod: authMethod,
      );
      await _fetchProfile(user.id);
      state = state.copyWith(
        successMessage: 'Hedera account linked successfully!',
      );
    } catch (e) {
      final failure = e is Failure ? e : ErrorHandler.handle(e);
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      );
    }
  }

  /// Clears any active error or success notification banners from state.
  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
