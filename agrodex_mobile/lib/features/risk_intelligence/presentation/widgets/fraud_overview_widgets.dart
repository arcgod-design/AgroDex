import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/fraud_overview_models.dart';

/// Renders Fraud Level Counts badges ('SAFE', 'LOW', 'MEDIUM', 'HIGH', 'CRITICAL').
class FraudLevelCountsWidget extends StatelessWidget {
  /// The level counts map.
  final Map<String, int> levelCounts;

  /// Creates a [FraudLevelCountsWidget].
  const FraudLevelCountsWidget({super.key, required this.levelCounts});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _LevelBadge(
          label: 'SAFE',
          count: levelCounts['SAFE'] ?? 0,
          color: const Color(0xFF059669),
        ),
        _LevelBadge(
          label: 'LOW',
          count: levelCounts['LOW'] ?? 0,
          color: const Color(0xFF0284C7),
        ),
        _LevelBadge(
          label: 'MEDIUM',
          count: levelCounts['MEDIUM'] ?? 0,
          color: const Color(0xFFD97706),
        ),
        _LevelBadge(
          label: 'HIGH',
          count: levelCounts['HIGH'] ?? 0,
          color: const Color(0xFFDC2626),
        ),
        _LevelBadge(
          label: 'CRITICAL',
          count: levelCounts['CRITICAL'] ?? 0,
          color: const Color(0xFF7C3AED),
        ),
      ],
    );
  }
}

class _LevelBadge extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _LevelBadge({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders Top Farmer Risk Ranking list.
class FarmerRankingListWidget extends StatelessWidget {
  /// Farmer ranking items.
  final List<FarmerRankingItem> farmers;

  /// Creates a [FarmerRankingListWidget].
  const FarmerRankingListWidget({super.key, required this.farmers});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (farmers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: farmers.map((farmer) {
        final color = _getLevelColor(farmer.worstLevel);

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farmer ${farmer.farmerId.length > 8 ? farmer.farmerId.substring(0, 8) : farmer.farmerId}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${farmer.batchCount} batches · Avg risk ${farmer.avgScore}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${farmer.maxScore}',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      farmer.worstLevel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return const Color(0xFF7C3AED);
      case 'HIGH':
        return const Color(0xFFDC2626);
      case 'MEDIUM':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF059669);
    }
  }
}

/// Renders Geographic Regional Analytics cards.
class RegionalAnalyticsListWidget extends StatelessWidget {
  /// Regional analytics items.
  final List<RegionalAnalyticsItem> items;

  /// Creates a [RegionalAnalyticsListWidget].
  const RegionalAnalyticsListWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: items.map((item) {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.region,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.totalBatches} total batches analyzed',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                  ),
                ],
              ),
              Row(
                children: [
                  _StatBadge(
                    label: 'Outliers',
                    value: '${item.outlierCount}',
                    color: item.outlierCount > 0
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF059669),
                  ),
                  const SizedBox(width: 8),
                  _StatBadge(
                    label: 'Avg Risk',
                    value: '${item.avgRisk}',
                    color: const Color(0xFFD97706),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
