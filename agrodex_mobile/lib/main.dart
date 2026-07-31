import 'package:agrodex_mobile/core/constants/app_constants.dart';
import 'package:agrodex_mobile/core/router/app_router.dart';
import 'package:agrodex_mobile/core/services/logger_service.dart';
import 'package:agrodex_mobile/core/services/storage_service.dart';
import 'package:agrodex_mobile/core/theme/app_theme.dart';
import 'package:agrodex_mobile/shared/providers/core_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Entry point for AgroDex Flutter Mobile application.
/// Initializes SharedPreferences, Supabase SDK, Dotenv, and Riverpod ProviderScope.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load local environment variables (.env fallback if present)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    LoggerService.warn(
      'Could not load .env file, using default configuration.',
      'main',
    );
  }

  // Initialize SharedPreferences storage service
  final storageService = await StorageService.init();

  // Initialize Supabase Flutter client.
  // Must NOT be wrapped in a try/catch — a failed init must be fatal.
  // If Supabase.initialize() throws and is swallowed, every subsequent
  // access to Supabase.instance.client will assert-fail at runtime.
  final supabaseUrl = AppConstants.supabaseUrl;
  final supabaseKey = AppConstants.supabaseAnonKey;

  assert(
    supabaseKey.isNotEmpty,
    '\n\nSUPABASE KEY IS EMPTY.\n'
    'Ensure agrodex_mobile/.env exists and contains VITE_SUPABASE_ANON_KEY.\n'
    'Also verify that .env is declared under flutter.assets in pubspec.yaml.\n',
  );

  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);

  runApp(
    ProviderScope(
      overrides: [storageServiceProvider.overrideWithValue(storageService)],
      child: const AgroDexApp(),
    ),
  );
}

/// Root application widget configuring Material 3 theme and routing via GoRouter.
class AgroDexApp extends ConsumerWidget {
  const AgroDexApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'AgroDex Mobile',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
