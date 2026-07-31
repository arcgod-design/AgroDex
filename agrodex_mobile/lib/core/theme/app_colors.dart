import 'package:agrodex_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Semantic color aliases mapping to [AppTheme] design tokens.
class AppColors {
  AppColors._();

  static const Color primary = AppTheme.primaryGreen;
  static const Color success = AppTheme.safeColor;
  static const Color warning = AppTheme.mediumRiskColor;
  static const Color error = AppTheme.criticalRiskColor;

  static const Color surfaceLight = AppTheme.lightCard;
  static const Color surfaceDark = AppTheme.darkCard;

  static const Color backgroundLight = AppTheme.lightBackground;
  static const Color backgroundDark = AppTheme.darkBackground;

  static const Color textSecondaryLight = AppTheme.lightMutedForeground;
  static const Color textSecondaryDark = AppTheme.darkMutedForeground;
}
