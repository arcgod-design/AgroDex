import 'package:agrodex_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppButtonVariant { primary, secondary, outline, ghost, destructive }

enum AppButtonSize { small, medium, large }

/// Reusable production button reproducing React button.tsx variants
/// (default/primary, secondary, outline, ghost, destructive) with loading spinner.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final height = _getHeight();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getSpinnerColor(colorScheme),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.space8),
        ] else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: AppConstants.space8),
        ],
        Text(label, style: textStyle),
      ],
    );

    Widget buttonWidget;
    switch (variant) {
      case AppButtonVariant.primary:
        buttonWidget = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.secondary:
        buttonWidget = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.secondaryContainer,
            foregroundColor: colorScheme.onSecondaryContainer,
            elevation: 0,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.outline:
        buttonWidget = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
            side: BorderSide(color: theme.dividerColor),
            minimumSize: Size(isFullWidth ? double.infinity : 0, height),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.ghost:
        buttonWidget = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: colorScheme.onSurface,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.destructive:
        buttonWidget = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
            elevation: 0,
            minimumSize: Size(isFullWidth ? double.infinity : 0, height),
            padding: padding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            ),
          ),
          child: content,
        );
        break;
    }

    return buttonWidget;
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 32.0; // sm: h-8
      case AppButtonSize.medium:
        return 36.0; // default: h-9
      case AppButtonSize.large:
        return 44.0; // lg: h-10/44
    }
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12.0);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16.0);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24.0);
    }
  }

  TextStyle _getTextStyle() {
    return GoogleFonts.manrope(
      fontWeight: FontWeight.w600,
      fontSize: size == AppButtonSize.small ? 12.0 : 14.0,
    );
  }

  Color _getSpinnerColor(ColorScheme colorScheme) {
    if (variant == AppButtonVariant.primary ||
        variant == AppButtonVariant.destructive) {
      return Colors.white;
    }
    return colorScheme.primary;
  }
}
