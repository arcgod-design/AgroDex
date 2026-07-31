import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/supply_chain_risk_models.dart';

/// Renders a KPI Score Card for the Risk Intelligence dashboard.
class RiskScoreCardWidget extends StatelessWidget {
  /// The scorecard data model.
  final RiskScoreCard card;

  /// Creates a [RiskScoreCardWidget].
  const RiskScoreCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getLevelColor(card.level);

    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(_getScoreIcon(card.id), size: 18, color: color),
                ),
              ],
            ),
            AppSpacing.gapSm,

            // Score out of 100
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${card.score}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/100',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            AppSpacing.gapSm,

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: card.score / 100.0,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
            AppSpacing.gapMd,

            // Level badge and point delta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _getLevelLabel(card.level),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                Text(
                  '${card.change > 0 ? '+' : ''}${card.change} pts',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: card.change > 0
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ],
            ),
            AppSpacing.gapSm,

            // Description
            Text(
              card.description,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(SupplyChainRiskLevel level) {
    switch (level) {
      case SupplyChainRiskLevel.low:
        return const Color(0xFF059669); // Emerald 600
      case SupplyChainRiskLevel.moderate:
        return const Color(0xFFD97706); // Amber 600
      case SupplyChainRiskLevel.elevated:
        return const Color(0xFFDC2626); // Red 600
      case SupplyChainRiskLevel.critical:
        return const Color(0xFF7C3AED); // Violet 600
    }
  }

  String _getLevelLabel(SupplyChainRiskLevel level) {
    switch (level) {
      case SupplyChainRiskLevel.low:
        return 'Low';
      case SupplyChainRiskLevel.moderate:
        return 'Moderate';
      case SupplyChainRiskLevel.elevated:
        return 'Elevated';
      case SupplyChainRiskLevel.critical:
        return 'Critical';
    }
  }

  IconData _getScoreIcon(String id) {
    switch (id) {
      case 'overall':
        return Icons.psychology;
      case 'delay':
        return Icons.schedule;
      case 'fraud':
        return Icons.gpp_maybe;
      case 'inventory':
        return Icons.inventory_2;
      case 'supplier':
        return Icons.verified_user;
      default:
        return Icons.analytics;
    }
  }
}
