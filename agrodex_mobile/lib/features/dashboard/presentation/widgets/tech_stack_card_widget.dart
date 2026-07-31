import 'package:agrodex_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Renders the Technology Stack card matching React `Dashboard.tsx`.
class TechStackCardWidget extends StatelessWidget {
  const TechStackCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technology Stack',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Technologies used for traceability',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 600;
              if (isWide) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildTechItem(
                        context,
                        title: 'Hedera HCS',
                        subtitle: 'Immutable consensus',
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTechItem(
                        context,
                        title: 'Hedera HTS',
                        subtitle: 'NFT Tokenization',
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTechItem(
                        context,
                        title: 'Gemini 3.1 Flash Lite',
                        subtitle: 'Analysis & Provenance',
                        color: const Color(0xFF9333EA),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTechItem(
                        context,
                        title: 'Supabase',
                        subtitle: 'Database',
                        color: const Color(0xFFF97316),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTechItem(
                          context,
                          title: 'Hedera HCS',
                          subtitle: 'Immutable consensus',
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTechItem(
                          context,
                          title: 'Hedera HTS',
                          subtitle: 'NFT Tokenization',
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTechItem(
                          context,
                          title: 'Gemini 3.1 Flash Lite',
                          subtitle: 'Analysis & Provenance',
                          color: const Color(0xFF9333EA),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTechItem(
                          context,
                          title: 'Supabase',
                          subtitle: 'Database',
                          color: const Color(0xFFF97316),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTechItem(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
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
