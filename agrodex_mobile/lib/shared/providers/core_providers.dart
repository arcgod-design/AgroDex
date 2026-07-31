import 'package:agrodex_mobile/core/network/api_client.dart';
import 'package:agrodex_mobile/core/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider for the initialized [StorageService].
/// Must be overridden in main.dart after SharedPreferences initialization.
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError(
    'storageServiceProvider has not been initialized in main.dart',
  );
});

/// Provider for the initialized Supabase SDK [SupabaseClient].
///
/// Riverpod providers are **lazy** — this body only executes when the provider
/// is first read (always after [runApp] and after [Supabase.initialize] has
/// completed in `main()`). If a `_isInitialized` assertion fires at runtime,
/// Supabase initialization failed silently: verify that `.env` is listed under
/// `flutter.assets` in `pubspec.yaml` and that `VITE_SUPABASE_ANON_KEY` is set.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Provider for the clean HTTP [ApiClient] with Supabase Auth headers.
final apiClientProvider = Provider<ApiClient>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return ApiClient(supabaseClient: supabase);
});

/// Riverpod StateNotifier controlling light, dark, and system ThemeMode,
/// persisted to SharedPreferences via [StorageService].
class ThemeModeController extends StateNotifier<ThemeMode> {
  final StorageService _storage;

  ThemeModeController(this._storage) : super(_loadInitialMode(_storage));

  static ThemeMode _loadInitialMode(StorageService storage) {
    final saved = storage.getThemeMode();
    if (saved == 'dark') return ThemeMode.dark;
    if (saved == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final String modeString;
    switch (mode) {
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    await _storage.saveThemeMode(modeString);
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeController, ThemeMode>(
  (ref) {
    final storage = ref.watch(storageServiceProvider);
    return ThemeModeController(storage);
  },
);
