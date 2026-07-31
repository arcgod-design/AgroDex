import 'package:agrodex_mobile/core/constants/app_constants.dart';
import 'package:agrodex_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Reusable circular AI Trust Badge widget matching React TrustBadge.tsx.
/// - Score > 85: green (safeColor)
/// - Score > 60: yellow (mediumRiskColor)
/// - Score <= 60: red (criticalRiskColor)
class TrustBadgeWidget extends StatelessWidget {
  final num? score;
  final double size;

  const TrustBadgeWidget({
    super.key,
    required this.score,
    this.size = 96.0, // w-24 h-24
  });

  @override
  Widget build(BuildContext context) {
    if (score == null) {
      return const SizedBox.shrink();
    }

    final intScore = score!.round();
    final Color badgeColor = _getScoreColor(intScore);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$intScore',
                style: GoogleFonts.manrope(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              Text(
                '/ 100',
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.space8),
        Text(
          'AI TRUST SCORE',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score > 85) return AppTheme.safeColor;
    if (score > 60) return AppTheme.mediumRiskColor;
    return AppTheme.criticalRiskColor;
  }
}
