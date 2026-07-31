import 'package:agrodex_mobile/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:agrodex_mobile/features/auth/domain/models/auth_state.dart';
import 'package:agrodex_mobile/features/auth/domain/models/user_profile.dart';
import 'package:agrodex_mobile/features/auth/domain/repositories/auth_repository.dart';
import 'package:agrodex_mobile/features/auth/presentation/controllers/auth_controller.dart';
import 'package:agrodex_mobile/shared/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

/// Provider for [AuthRepository] implementation backed by Supabase.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  return SupabaseAuthRepository(supabaseClient);
});

/// Global state controller provider managing reactive [AuthState].
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final authRepository = ref.watch(authRepositoryProvider);
    return AuthController(authRepository);
  },
);

/// Reactive helper provider exposing the current authenticated Supabase user.
final currentUserProvider = Provider<sb.User?>((ref) {
  return ref.watch(authControllerProvider).user;
});

/// Reactive helper provider exposing the current user's profile and wallet data.
final userProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authControllerProvider).profile;
});

/// Boolean provider indicating whether an active authenticated session exists.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).isAuthenticated;
});
