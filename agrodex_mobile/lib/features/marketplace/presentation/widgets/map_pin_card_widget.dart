import 'package:agrodex_mobile/core/theme/app_colors.dart';
import 'package:agrodex_mobile/core/theme/app_spacing.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/map_batch_model.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/widgets/verification_status_badge.dart';
import 'package:flutter/material.dart';

/// Interactive card popover displayed when selecting a pin on SupplyChainMap.
class MapPinCardWidget extends StatelessWidget {
  /// The selected batch.
  final MapBatch batch;

  /// Callback to close popover.
  final VoidCallback onClose;

  /// Callback to navigate to verification certificate.
  final VoidCallback onVerify;

  /// Creates a [MapPinCardWidget].
  const MapPinCardWidget({
    super.key,
    required this.batch,
    required this.onClose,
    required this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 8,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    batch.batchName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: onClose,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            VerificationStatusBadge(status: batch.status),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Location: ${batch.location}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'Quantity: ${batch.quantity}',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              'Harvest Date: ${batch.harvestDate}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onVerify,
                icon: const Icon(Icons.verified_user_outlined, size: 18),
                label: const Text('View Provenance Certificate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
