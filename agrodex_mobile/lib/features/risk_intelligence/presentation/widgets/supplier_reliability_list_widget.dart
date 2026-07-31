import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/supply_chain_risk_models.dart';

/// Renders a list of Supplier Reliability cards with incident counts and progress bars.
class SupplierReliabilityListWidget extends StatelessWidget {
  /// Supplier items.
  final List<SupplierReliability> suppliers;

  /// Creates a [SupplierReliabilityListWidget].
  const SupplierReliabilityListWidget({super.key, required this.suppliers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (suppliers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: suppliers.map((supplier) {
        final color = _getReliabilityColor(supplier.reliability);

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supplier.supplier,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${supplier.incidents} incident${supplier.incidents == 1 ? '' : 's'} · ${supplier.trend}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${supplier.reliability}%',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapSm,
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: supplier.reliability / 100.0,
                  backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getReliabilityColor(int reliability) {
    if (reliability >= 85) return const Color(0xFF059669); // Emerald
    if (reliability >= 70) return const Color(0xFFD97706); // Amber
    return const Color(0xFFDC2626); // Red
  }
}
