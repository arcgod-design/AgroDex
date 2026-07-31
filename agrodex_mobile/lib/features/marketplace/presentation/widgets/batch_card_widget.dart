import 'package:agrodex_mobile/core/theme/app_spacing.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/map_batch_model.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/widgets/verification_status_badge.dart';
import 'package:flutter/material.dart';

/// Reusable card displaying an agricultural batch with status badge and metadata.
class BatchCardWidget extends StatelessWidget {
  /// The batch record to render.
  final MapBatch batch;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  /// Creates a [BatchCardWidget].
  const BatchCardWidget({super.key, required this.batch, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
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
                  VerificationStatusBadge(
                    status: batch.status,
                    trustScore: batch.aiAnalysis?.confidence != null
                        ? (batch.aiAnalysis!.confidence * 100).round()
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      batch.location,
                      style: theme.textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Qty: ${batch.quantity}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Harvest: ${batch.harvestDate}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
