import 'package:agrodex_mobile/core/theme/app_theme.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/dashboard_stats_model.dart';
import 'package:flutter/material.dart';

/// Renders the 3 KPI summary cards matching React `Dashboard.tsx`.
class KpiGridWidget extends StatelessWidget {
  final DashboardKpis kpis;
  final int flaggedCount;
  final bool isLoading;

  const KpiGridWidget({
    super.key,
    required this.kpis,
    required this.flaggedCount,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;
            if (isWide) {
              return Row(
                children: [
                  Expanded(
                    child: _buildCard(
                      context,
                      title: 'Registered Batches',
                      value: kpis.totalBatches,
                      subtitle: 'Total on platform',
                      iconData: Icons.description_outlined,
                      color: AppTheme.primaryGreen,
                      borderColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCard(
                      context,
                      title: 'NFTs Created',
                      value: kpis.totalNfts,
                      subtitle: 'Tokenized certificates',
                      iconData: Icons.monetization_on_outlined,
                      color: const Color(0xFF2563EB),
                      borderColor: const Color(
                        0xFF2563EB,
                      ).withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildCard(
                      context,
                      title: 'AI Verifications',
                      value: kpis.aiVerified,
                      subtitle: 'Verified batches',
                      iconData: Icons.verified_user_outlined,
                      color: const Color(0xFF9333EA),
                      borderColor: const Color(
                        0xFF9333EA,
                      ).withValues(alpha: 0.2),
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                _buildCard(
                  context,
                  title: 'Registered Batches',
                  value: kpis.totalBatches,
                  subtitle: 'Total on platform',
                  iconData: Icons.description_outlined,
                  color: AppTheme.primaryGreen,
                  borderColor: AppTheme.primaryGreen.withValues(alpha: 0.2),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  context,
                  title: 'NFTs Created',
                  value: kpis.totalNfts,
                  subtitle: 'Tokenized certificates',
                  iconData: Icons.monetization_on_outlined,
                  color: const Color(0xFF2563EB),
                  borderColor: const Color(0xFF2563EB).withValues(alpha: 0.2),
                ),
                const SizedBox(height: 12),
                _buildCard(
                  context,
                  title: 'AI Verifications',
                  value: kpis.aiVerified,
                  subtitle: 'Verified batches',
                  iconData: Icons.verified_user_outlined,
                  color: const Color(0xFF9333EA),
                  borderColor: const Color(0xFF9333EA).withValues(alpha: 0.2),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        if (!isLoading)
          Text(
            '${kpis.totalVerifications} verifications IA realisees, dont $flaggedCount lot(s) a surveiller.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required int value,
    required String subtitle,
    required IconData iconData,
    required Color color,
    required Color borderColor,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(iconData, size: 20, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          isLoading
              ? const SizedBox(
                  height: 32,
                  width: 32,
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : Text(
                  value.toString(),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
