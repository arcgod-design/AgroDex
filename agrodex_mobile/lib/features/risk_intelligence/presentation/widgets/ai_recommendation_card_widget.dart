import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/supply_chain_risk_models.dart';

/// Renders an AI Recommendation intervention card with priority badge.
class AiRecommendationCardWidget extends StatelessWidget {
  /// The recommendation data model.
  final Recommendation recommendation;

  /// Creates an [AiRecommendationCardWidget].
  const AiRecommendationCardWidget({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getPriorityColor(recommendation.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: AppSpacing.borderRadiusMd,
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.35)),
            ),
            child: Text(
              recommendation.priority,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          AppSpacing.gapSm,

          // Title
          Text(
            recommendation.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),

          // Action step
          Text(
            recommendation.action,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              height: 1.4,
            ),
          ),
          AppSpacing.gapSm,

          // Expected impact
          Row(
            children: [
              const Icon(Icons.trending_up, size: 14, color: Color(0xFF059669)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  recommendation.impact,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return const Color(0xFFDC2626); // Red 600
      case 'medium':
        return const Color(0xFFD97706); // Amber 600
      case 'low':
      default:
        return const Color(0xFF059669); // Emerald 600
    }
  }
}
