import 'package:agrodex_mobile/core/theme/app_colors.dart';
import 'package:agrodex_mobile/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Reusable trust score and verification status badge chips.
class VerificationStatusBadge extends StatelessWidget {
  /// The status string ("verified", "approved", "flagged", etc.).
  final String status;

  /// Optional AI trust score (0..100).
  final int? trustScore;

  /// Creates a [VerificationStatusBadge].
  const VerificationStatusBadge({
    super.key,
    required this.status,
    this.trustScore,
  });

  @override
  Widget build(BuildContext context) {
    final cleanStatus = status.toLowerCase();
    final isSuccess = cleanStatus == 'verified' || cleanStatus == 'approved';
    final color = isSuccess ? AppColors.success : AppColors.warning;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.full),
            border: Border.all(color: color.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSuccess ? Icons.verified : Icons.warning_amber_rounded,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                status.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
        if (trustScore != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: _getScoreColor(trustScore!).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              'Trust: $trustScore/100',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getScoreColor(trustScore!),
              ),
            ),
          ),
        ],
      ],
    );
  }

  static Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }
}
