import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/supply_chain_risk_models.dart';

/// Renders a Visual Risk Heatmap grid of Region x Supply-Chain Stage.
class RiskHeatmapWidget extends StatelessWidget {
  /// The heatmap cells list.
  final List<HeatmapCell> cells;

  /// Creates a [RiskHeatmapWidget].
  const RiskHeatmapWidget({super.key, required this.cells});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final regions = cells.map((c) => c.region).toSet().toList();
    final stages = cells.map((c) => c.stage).toSet().toList();

    if (regions.isEmpty || stages.isEmpty) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        constraints: const BoxConstraints(minWidth: 540),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: Region label + Stage labels
            Row(
              children: [
                const SizedBox(
                  width: 90,
                  child: Text(
                    'Region',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
                ...stages.map(
                  (stage) => SizedBox(
                    width: 76,
                    child: Center(
                      child: Text(
                        stage,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.gapSm,

            // Region rows
            ...regions.map((region) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 90,
                      child: Text(
                        region,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ...stages.map((stage) {
                      final cell = cells.cast<HeatmapCell?>().firstWhere(
                        (c) => c?.region == region && c?.stage == stage,
                        orElse: () => null,
                      );
                      final risk = cell?.risk ?? 0;
                      final level = _getHeatLevel(risk);
                      final color = _getCellColor(level);
                      final opacity = (0.45 + (risk / 180.0)).clamp(0.2, 1.0);

                      return SizedBox(
                        width: 76,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Container(
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: opacity),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$risk',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  SupplyChainRiskLevel _getHeatLevel(int risk) {
    if (risk >= 82) return SupplyChainRiskLevel.critical;
    if (risk >= 62) return SupplyChainRiskLevel.elevated;
    if (risk >= 40) return SupplyChainRiskLevel.moderate;
    return SupplyChainRiskLevel.low;
  }

  Color _getCellColor(SupplyChainRiskLevel level) {
    switch (level) {
      case SupplyChainRiskLevel.low:
        return const Color(0xFF10B981); // Emerald 500
      case SupplyChainRiskLevel.moderate:
        return const Color(0xFFF59E0B); // Amber 500
      case SupplyChainRiskLevel.elevated:
        return const Color(0xFFEF4444); // Red 500
      case SupplyChainRiskLevel.critical:
        return const Color(0xFF8B5CF6); // Violet 500
    }
  }
}
