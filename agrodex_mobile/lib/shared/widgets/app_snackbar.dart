import 'package:agrodex_mobile/core/constants/app_constants.dart';
import 'package:agrodex_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

enum SnackbarType { success, error, warning, info }

/// Reusable Material 3 Snackbar helper reproducing React toast notifications.
class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 4),
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    IconData icon;

    switch (type) {
      case SnackbarType.success:
        backgroundColor = AppTheme.primaryGreen;
        icon = Icons.check_circle_outline;
        break;
      case SnackbarType.error:
        backgroundColor = colorScheme.error;
        icon = Icons.error_outline;
        break;
      case SnackbarType.warning:
        backgroundColor = AppTheme.mediumRiskColor;
        icon = Icons.warning_amber_outlined;
        break;
      case SnackbarType.info:
        backgroundColor = colorScheme.secondary;
        icon = Icons.info_outline;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: AppConstants.space8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        ),
        duration: duration,
      ),
    );
  }
}
