import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Complete Material 3 Light and Dark themes reproducing React index.css colors,
/// typography (Manrope & Open Sans), and spacing/radius.
class AppTheme {
  AppTheme._();

  // Core Brand Colors matching React index.css
  static const Color primaryGreen = Color(0xFF16A34A); // Emerald 600
  static const Color primaryGreenLight = Color(0xFF22C55E); // Emerald 500
  static const Color primaryGreenDark = Color(0xFF15803D); // Emerald 700

  // Risk Level Colors matching React TrustBadge.tsx / fraud scoring
  static const Color safeColor = Color(0xFF16A34A); // Green 600
  static const Color lowRiskColor = Color(0xFF3B82F6); // Blue 500
  static const Color mediumRiskColor = Color(0xFFEAB308); // Yellow 500
  static const Color highRiskColor = Color(0xFFF97316); // Orange 500
  static const Color criticalRiskColor = Color(0xFFDC2626); // Red 600

  // Light Mode Colors
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightForeground = Color(0xFF09090B);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE4E4E7);
  static const Color lightMuted = Color(0xFFF4F4F5);
  static const Color lightMutedForeground = Color(0xFF71717A);

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF09090B);
  static const Color darkForeground = Color(0xFFFAFAFA);
  static const Color darkCard = Color(0xFF18181B);
  static const Color darkBorder = Color(0xFF27272A);
  static const Color darkMuted = Color(0xFF27272A);
  static const Color darkMutedForeground = Color(0xFFA1A1AA);

  /// Builds custom text theme using Manrope for headings and Open Sans for body.
  static TextTheme _buildTextTheme(TextTheme base, Color color) {
    return base.copyWith(
      displayLarge: GoogleFonts.manrope(
        textStyle: base.displayLarge,
        fontWeight: FontWeight.w800,
        color: color,
      ),
      displayMedium: GoogleFonts.manrope(
        textStyle: base.displayMedium,
        fontWeight: FontWeight.w800,
        color: color,
      ),
      displaySmall: GoogleFonts.manrope(
        textStyle: base.displaySmall,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineLarge: GoogleFonts.manrope(
        textStyle: base.headlineLarge,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineMedium: GoogleFonts.manrope(
        textStyle: base.headlineMedium,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      headlineSmall: GoogleFonts.manrope(
        textStyle: base.headlineSmall,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleLarge: GoogleFonts.manrope(
        textStyle: base.titleLarge,
        fontWeight: FontWeight.w700,
        color: color,
      ),
      titleMedium: GoogleFonts.manrope(
        textStyle: base.titleMedium,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      titleSmall: GoogleFonts.manrope(
        textStyle: base.titleSmall,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      bodyLarge: GoogleFonts.openSans(
        textStyle: base.bodyLarge,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodyMedium: GoogleFonts.openSans(
        textStyle: base.bodyMedium,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodySmall: GoogleFonts.openSans(
        textStyle: base.bodySmall,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      labelLarge: GoogleFonts.openSans(
        textStyle: base.labelLarge,
        fontWeight: FontWeight.w600,
        color: color,
      ),
      labelMedium: GoogleFonts.openSans(
        textStyle: base.labelMedium,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      labelSmall: GoogleFonts.openSans(
        textStyle: base.labelSmall,
        fontWeight: FontWeight.w500,
        color: color,
      ),
    );
  }

  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreen,
      brightness: Brightness.light,
      primary: primaryGreen,
      secondary: const Color(0xFF0284C7),
      surface: lightBackground,
      error: criticalRiskColor,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: lightBackground,
      textTheme: _buildTextTheme(base.textTheme, lightForeground),
      cardTheme: CardThemeData(
        color: lightCard,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0), // 0.5rem
          side: const BorderSide(color: lightBorder, width: 1.0),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackground,
        foregroundColor: lightForeground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: lightForeground,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: criticalRiskColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: lightForeground,
          side: const BorderSide(color: lightBorder),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryGreenLight,
      brightness: Brightness.dark,
      primary: primaryGreenLight,
      secondary: const Color(0xFF38BDF8),
      surface: darkBackground,
      error: criticalRiskColor,
    );

    return base.copyWith(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBackground,
      textTheme: _buildTextTheme(base.textTheme, darkForeground),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 1,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(color: darkBorder, width: 1.0),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: darkBackground,
        foregroundColor: darkForeground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: darkForeground,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: primaryGreenLight, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: criticalRiskColor),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreenLight,
          foregroundColor: darkBackground,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkForeground,
          side: const BorderSide(color: darkBorder),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
