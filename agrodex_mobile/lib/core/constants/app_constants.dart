import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized application constants matching AgroDex React configuration (.env).
class AppConstants {
  AppConstants._();

  static String? _env(String key) =>
      dotenv.isInitialized ? dotenv.env[key] : null;

  // API & Supabase Endpoints from .env
  static String get supabaseUrl =>
      _env('VITE_SUPABASE_URL') ??
      'https://nhoqsqktwygqvovhonre.supabase.co';
  static String get supabaseAnonKey =>
      _env('VITE_SUPABASE_ANON_KEY') ?? '';
  static String get apiBaseUrl =>
      _env('VITE_API_BASE_URL') ?? 'http://localhost:4000';
  static String get mirrorNodeUrl =>
      _env('VITE_MIRROR_NODE_URL') ??
      'https://testnet.mirrornode.hedera.com';
  static String get walletConnectProjectId =>
      _env('VITE_WALLETCONNECT_PROJECT_ID') ?? '';
  static String get hederaNetwork =>
      _env('VITE_HEDERA_NETWORK') ?? 'testnet';
  static String get geminiApiKey =>
      _env('GEMINI_API_KEY') ??
      _env('VITE_GEMINI_API_KEY') ??
      '';
  static String get geminiModel =>
      _env('GEMINI_MODEL') ??
      _env('VITE_GEMINI_MODEL') ??
      'gemini-2.5-flash';

  // Storage Keys
  static const String themeStorageKey = 'agrodex-theme';
  static const String localeStorageKey = 'agrodex-locale';

  // Spacing Tokens (matching Tailwind 4px grid)
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;

  // Border Radius (matching React index.css --radius: 0.5rem = 8.0dp)
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusCircular = 999.0;

  // Animation Durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
}
