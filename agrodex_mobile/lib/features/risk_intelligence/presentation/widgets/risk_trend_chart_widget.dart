import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/supply_chain_risk_models.dart';

/// Renders a responsive 30-day Risk Trend visual chart.
class RiskTrendChartWidget extends StatelessWidget {
  /// Trend points data.
  final List<RiskTrendPoint> points;

  /// Creates a [RiskTrendChartWidget].
  const RiskTrendChartWidget({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (points.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chart legend
        Row(
          children: [
            _LegendItem(color: const Color(0xFF059669), label: 'Overall'),
            const SizedBox(width: 16),
            _LegendItem(color: const Color(0xFF0284C7), label: 'Delay'),
            const SizedBox(width: 16),
            _LegendItem(color: const Color(0xFFD97706), label: 'Fraud'),
          ],
        ),
        AppSpacing.gapMd,

        // Custom responsive bar/trend visualizer
        SizedBox(
          height: 180,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: points.map((p) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Value bars group
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _BarColumn(
                              value: p.overallRisk,
                              color: const Color(0xFF059669),
                            ),
                            const SizedBox(width: 3),
                            _BarColumn(
                              value: p.delayRisk,
                              color: const Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 3),
                            _BarColumn(
                              value: p.fraudRisk,
                              color: const Color(0xFFD97706),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Date label
                      Text(
                        p.date,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _BarColumn extends StatelessWidget {
  final int value;
  final Color color;

  const _BarColumn({required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    // Score out of 100 relative to 100% height
    final fraction = (value / 100.0).clamp(0.08, 1.0);
    return Flexible(
      child: FractionallySizedBox(
        heightFactor: fraction,
        child: Container(
          width: 8,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
          ),
        ),
      ),
    );
  }
}
