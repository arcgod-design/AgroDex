import 'package:agrodex_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Reusable Card component reproducing React card.tsx styling
/// with border radius 8dp (0.5rem), border color, and optional elevation.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppConstants.space16),
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.elevation = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cardContent = Padding(
      padding: padding ?? EdgeInsets.zero,
      child: child,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      side: BorderSide(color: borderColor ?? theme.dividerColor, width: 1.0),
    );

    if (onTap != null) {
      return Card(
        color: backgroundColor ?? theme.cardColor,
        elevation: elevation,
        margin: margin ?? EdgeInsets.zero,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(onTap: onTap, child: cardContent),
      );
    }

    return Card(
      color: backgroundColor ?? theme.cardColor,
      elevation: elevation,
      margin: margin ?? EdgeInsets.zero,
      shape: shape,
      child: cardContent,
    );
  }
}
