import 'package:agrodex_mobile/core/theme/app_theme.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/dashboard_stats_model.dart';
import 'package:flutter/material.dart';

/// Renders the Recent Activities card matching React `Dashboard.tsx`.
class RecentActivitiesCardWidget extends StatelessWidget {
  final DashboardAudit audit;

  const RecentActivitiesCardWidget({super.key, required this.audit});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activities = _buildActivitiesList();

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
              Icon(Icons.history, size: 22, color: AppTheme.primaryGreen),
              const SizedBox(width: 8),
              Text(
                'Recent Activities',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Latest actions across the platform',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          if (activities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No recent activity yet.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            Column(
              children: activities.map((item) {
                final isApproved = item.type == 'approved';
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
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
                              item.title,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isApproved ? 'Approved' : 'Flagged for Review',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: isApproved
                                    ? AppTheme.primaryGreen
                                    : const Color(0xFFF97316),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatTimestamp(item.timestamp),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  List<_ActivityItem> _buildActivitiesList() {
    final list = <_ActivityItem>[
      ...audit.approvedLots.map(
        (l) => _ActivityItem(
          type: 'approved',
          title: 'Lot ${l.tokenId}/${l.serialNumber} approved',
          timestamp: l.verifiedAt,
        ),
      ),
      ...audit.flaggedLots.map(
        (l) => _ActivityItem(
          type: 'flagged',
          title: 'Lot ${l.tokenId}/${l.serialNumber} flagged',
          timestamp: l.verifiedAt,
        ),
      ),
    ];

    list.sort((a, b) {
      final ta =
          DateTime.tryParse(a.timestamp ?? '')?.millisecondsSinceEpoch ?? 0;
      final tb =
          DateTime.tryParse(b.timestamp ?? '')?.millisecondsSinceEpoch ?? 0;
      return tb.compareTo(ta);
    });

    return list.take(10).toList();
  }

  String _formatTimestamp(String? raw) {
    if (raw == null || raw.isEmpty) return 'Unknown time';
    try {
      final dt = DateTime.parse(raw);
      return '${dt.month}/${dt.day}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }
}

class _ActivityItem {
  final String type;
  final String title;
  final String? timestamp;

  _ActivityItem({required this.type, required this.title, this.timestamp});
}
