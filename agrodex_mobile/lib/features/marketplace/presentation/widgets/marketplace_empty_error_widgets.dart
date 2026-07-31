import 'package:agrodex_mobile/core/theme/app_colors.dart';
import 'package:agrodex_mobile/core/theme/app_spacing.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_registration_models.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/widgets/verification_status_badge.dart';
import 'package:flutter/material.dart';

/// Reusable loading spinner matching React's Loader2 animation in Marketplace.
class MarketplaceLoadingWidget extends StatelessWidget {
  /// Optional loading label text.
  final String label;

  /// Creates a [MarketplaceLoadingWidget].
  const MarketplaceLoadingWidget({
    super.key,
    this.label = 'Loading marketplace data...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable error state widget matching React error banners with retry action.
class MarketplaceErrorWidget extends StatelessWidget {
  /// Error message string.
  final String message;

  /// Callback when Retry button is tapped.
  final VoidCallback? onRetry;

  /// Creates a [MarketplaceErrorWidget].
  const MarketplaceErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Error Loading Data',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Reusable empty state widget matching React empty lot warnings.
class MarketplaceEmptyWidget extends StatelessWidget {
  /// Empty state title.
  final String title;

  /// Explanatory description.
  final String description;

  /// Optional action button label.
  final String? actionLabel;

  /// Optional action button callback.
  final VoidCallback? onAction;

  /// Creates a [MarketplaceEmptyWidget].
  const MarketplaceEmptyWidget({
    super.key,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dialog displaying the pre-registration AI verification summary before confirmation.
/// Matches React's AI pre-verification modal in BatchRegistration.tsx.
class AiVerificationSummaryDialog extends StatelessWidget {
  /// The AI verification summary to inspect.
  final VerifyRegistrationSummary summary;

  /// Callback when user approves registration after review.
  final VoidCallback onConfirm;

  /// Creates an [AiVerificationSummaryDialog].
  const AiVerificationSummaryDialog({
    super.key,
    required this.summary,
    required this.onConfirm,
  });

  /// Displays the dialog in the given [context].
  static Future<bool?> show(
    BuildContext context, {
    required VerifyRegistrationSummary summary,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AiVerificationSummaryDialog(
        summary: summary,
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'AI Provenance Verification',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            if (summary.fallback)
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        summary.warningMessage ??
                            'AI verification unavailable. Manual review recommended.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.md),
            Text(
              summary.productSummary,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            VerificationStatusBadge(
              status: summary.cooperativeReadiness.status,
            ),
            if (summary.warnings.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                'Warnings:',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ...summary.warnings.map(
                (w) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          w,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  onPressed: onConfirm,
                  child: const Text('Confirm & Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
