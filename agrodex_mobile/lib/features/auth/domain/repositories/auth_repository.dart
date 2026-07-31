import 'package:agrodex_mobile/features/auth/domain/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Abstract repository interface defining authentication and profile
/// management operations in AgroDex.
abstract class AuthRepository {
  /// Stream of Supabase AuthState changes for reactive session tracking.
  Stream<sb.AuthState> get onAuthStateChange;

  /// Returns the current active Supabase session, if any.
  sb.Session? get currentSession;

  /// Returns the current logged in Supabase user, if any.
  sb.User? get currentUser;

  /// Authenticates a user with email and password via Supabase Auth.
  Future<sb.AuthResponse> signInWithEmail({
    required String email,
    required String password,
  });

  /// Registers a new user with email and password.
  Future<sb.AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? redirectTo,
  });

  /// Logs out the current user and clears session tokens.
  Future<void> signOut();

  /// Retrieves the profile associated with [userId] from the `profiles` table.
  Future<UserProfile?> fetchUserProfile(String userId);

  /// Links a Hedera Account ID to the user's Supabase profile.
  Future<void> linkHederaWallet({
    required String userId,
    required String accountId,
    required String authMethod,
  });
}
