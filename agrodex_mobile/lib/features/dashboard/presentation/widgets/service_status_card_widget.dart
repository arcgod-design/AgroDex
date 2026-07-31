import 'package:agrodex_mobile/core/theme/app_theme.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/dashboard_health_model.dart';
import 'package:flutter/material.dart';

/// Renders the System Service Status card matching React `Dashboard.tsx`.
class ServiceStatusCardWidget extends StatelessWidget {
  final HealthStatus? healthStatus;
  final bool isLoading;
  final String? errorMessage;

  const ServiceStatusCardWidget({
    super.key,
    this.healthStatus,
    this.isLoading = false,
    this.errorMessage,
  });

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
          Row(
            children: [
              Icon(Icons.bolt, size: 22, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'System Service Status',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time health check of core infrastructure',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('Verification des services...'),
              ),
            )
          else if (errorMessage != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      '⚠️ Connection Error',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      errorMessage!,
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Verifier que le backend est demarre et accessible.',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (healthStatus == null)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Text(
                      '⚠️ No Data',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Unable to retrieve service status.'),
                  ],
                ),
              ),
            )
          else ...[
            _buildServiceRow(
              context,
              name: 'Hedera Mirror Node',
              status: healthStatus!.hedera,
            ),
            const SizedBox(height: 10),
            _buildServiceRow(
              context,
              name: 'Supabase DB',
              status: healthStatus!.supabase,
            ),
            const SizedBox(height: 10),
            _buildServiceRow(
              context,
              name: 'Gemini AI',
              status: healthStatus!.gemini,
              subtitleSuffix: healthStatus!.gemini.model != null
                  ? ' (${healthStatus!.gemini.model})'
                  : '',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildServiceRow(
    BuildContext context, {
    required String name,
    required ServiceStatus status,
    String subtitleSuffix = '',
  }) {
    final theme = Theme.of(context);
    final isOk = status.ok;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isOk ? AppTheme.primaryGreen : theme.colorScheme.error,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name$subtitleSuffix',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    isOk ? 'Operational' : 'Offline',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (!isOk && status.error != null)
                    Text(
                      status.error!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                ],
              ),
            ],
          ),
          Text(
            status.ms > 0 ? '${status.ms}ms' : '--',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
