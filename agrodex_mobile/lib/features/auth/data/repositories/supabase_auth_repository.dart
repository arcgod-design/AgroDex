import 'package:agrodex_mobile/core/error/error_handler.dart';
import 'package:agrodex_mobile/core/services/logger_service.dart';
import 'package:agrodex_mobile/features/auth/domain/models/user_profile.dart';
import 'package:agrodex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Concrete Supabase implementation of [AuthRepository] matching React
/// auth client and profile storage behavior.
class SupabaseAuthRepository implements AuthRepository {
  final sb.SupabaseClient _supabaseClient;

  const SupabaseAuthRepository(this._supabaseClient);

  @override
  Stream<sb.AuthState> get onAuthStateChange =>
      _supabaseClient.auth.onAuthStateChange;

  @override
  sb.Session? get currentSession => _supabaseClient.auth.currentSession;

  @override
  sb.User? get currentUser => _supabaseClient.auth.currentUser;

  @override
  Future<sb.AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      LoggerService.info(
        'Signing in with email: $email',
        'SupabaseAuthRepository',
      );
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } on sb.AuthException catch (e, stackTrace) {
      LoggerService.error(
        'SignIn AuthException',
        e,
        stackTrace,
        'SupabaseAuthRepository',
      );
      throw ErrorHandler.handle(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'SignIn unexpected error',
        e,
        stackTrace,
        'SupabaseAuthRepository',
      );
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<sb.AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? redirectTo,
  }) async {
    try {
      LoggerService.info(
        'Signing up with email: $email',
        'SupabaseAuthRepository',
      );
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: redirectTo,
      );
      return response;
    } on sb.AuthException catch (e, stackTrace) {
      LoggerService.error(
        'SignUp AuthException',
        e,
        stackTrace,
        'SupabaseAuthRepository',
      );
      throw ErrorHandler.handle(e);
    } catch (e, stackTrace) {
      LoggerService.error(
        'SignUp unexpected error',
        e,
        stackTrace,
        'SupabaseAuthRepository',
      );
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      LoggerService.info('Signing out current user', 'SupabaseAuthRepository');
      await _supabaseClient.auth.signOut();
    } catch (e, stackTrace) {
      LoggerService.error(
        'SignOut error',
        e,
        stackTrace,
        'SupabaseAuthRepository',
      );
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<UserProfile?> fetchUserProfile(String userId) async {
    try {
      LoggerService.debug(
        'Fetching profile for userId: $userId',
        'SupabaseAuthRepository',
      );
      final data = await _supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) {
        return null;
      }
      return UserProfile.fromJson(data);
    } catch (e, stackTrace) {
      LoggerService.error(
        'fetchUserProfile error',
        e,
        stackTrace,
        'SupabaseAuthRepository',
      );
      return null;
    }
  }

  @override
  Future<void> linkHederaWallet({
    required String userId,
    required String accountId,
    required String authMethod,
  }) async {
    try {
      LoggerService.info(
        'Linking Hedera account ($accountId) to profile ($userId)',
        'SupabaseAuthRepository',
      );
      await _supabaseClient
          .from('profiles')
          .update({'hedera_account_id': accountId, 'auth_method': authMethod})
          .eq('id', userId);
    } catch (e, stackTrace) {
      LoggerService.error(
        'linkHederaWallet error',
        e,
        stackTrace,
        'SupabaseAuthRepository',
      );
      throw ErrorHandler.handle(e);
    }
  }
}
