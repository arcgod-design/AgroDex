import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/supply_chain_risk_models.dart';

/// Renders a list of verified SKU Inventory Coverage days and reorder urgency signals.
class InventorySignalsWidget extends StatelessWidget {
  /// The inventory signal items.
  final List<InventorySignal> signals;

  /// Creates an [InventorySignalsWidget].
  const InventorySignalsWidget({super.key, required this.signals});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (signals.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: signals.map((signal) {
        final color = _getUrgencyColor(signal.reorderUrgency);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: AppSpacing.borderRadiusMd,
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      signal.sku,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${signal.coverageDays.toStringAsFixed(1)} days',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapSm,
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (signal.coverageDays / 14.0).clamp(0.05, 1.0),
                  backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
              AppSpacing.gapSm,
              Text(
                signal.note,
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getUrgencyColor(SupplyChainRiskLevel level) {
    switch (level) {
      case SupplyChainRiskLevel.low:
        return const Color(0xFF059669);
      case SupplyChainRiskLevel.moderate:
        return const Color(0xFFD97706);
      case SupplyChainRiskLevel.elevated:
        return const Color(0xFFDC2626);
      case SupplyChainRiskLevel.critical:
        return const Color(0xFF7C3AED);
    }
  }
}
