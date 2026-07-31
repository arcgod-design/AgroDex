import 'package:agrodex_mobile/core/theme/app_theme.dart';
import 'package:agrodex_mobile/features/dashboard/domain/models/audit_log_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Renders the verification audit journal table with search, filter, sort, and pagination.
class AuditJournalCardWidget extends StatelessWidget {
  final AuditLogsResponse? logsResponse;
  final bool isLoading;
  final String? errorMessage;
  final String search;
  final String status;
  final String sortBy;
  final String sortOrder;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSortChanged;
  final ValueChanged<int> onPageChanged;

  const AuditJournalCardWidget({
    super.key,
    this.logsResponse,
    this.isLoading = false,
    this.errorMessage,
    required this.search,
    required this.status,
    required this.sortBy,
    required this.sortOrder,
    required this.onSearchChanged,
    required this.onStatusChanged,
    required this.onSortChanged,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entries = logsResponse?.data ?? [];
    final pagination =
        logsResponse?.pagination ??
        const AuditLogsPagination(
          totalRecords: 0,
          totalPages: 1,
          currentPage: 1,
          limit: 10,
        );

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
              Icon(
                Icons.insights_outlined,
                size: 22,
                color: AppTheme.primaryGreen,
              ),
              const SizedBox(width: 8),
              Text(
                'Verification Audit Journal',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Real-time ledger of blockchain certifications',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          // Controls row
          _buildControls(context),
          const SizedBox(height: 16),
          // Table content
          if (isLoading)
            _buildLoadingSkeletons()
          else if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Error loading audit logs: $errorMessage',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          else if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Center(
                child: Text(
                  'No verification records found.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else ...[
            _buildTable(context, entries),
            if (pagination.totalPages > 1)
              _buildPagination(context, pagination),
          ],
        ],
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search by Token ID...',
            isDense: true,
            prefixIcon: const Icon(Icons.search, size: 18),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status segmented control
            ToggleButtons(
              borderRadius: BorderRadius.circular(8),
              constraints: const BoxConstraints(minHeight: 32, minWidth: 64),
              isSelected: [
                status == 'all',
                status == 'approved',
                status == 'flagged',
              ],
              onPressed: (idx) {
                const map = ['all', 'approved', 'flagged'];
                onStatusChanged(map[idx]);
              },
              children: const [
                Text('All', style: TextStyle(fontSize: 12)),
                Text('Approved', style: TextStyle(fontSize: 12)),
                Text('Flagged', style: TextStyle(fontSize: 12)),
              ],
            ),
            // Sort selection
            DropdownButton<String>(
              value: '$sortBy:$sortOrder',
              underline: const SizedBox(),
              style: Theme.of(context).textTheme.bodySmall,
              onChanged: (val) {
                if (val != null) onSortChanged(val);
              },
              items: const [
                DropdownMenuItem(
                  value: 'created_at:desc',
                  child: Text('Newest First'),
                ),
                DropdownMenuItem(
                  value: 'created_at:asc',
                  child: Text('Oldest First'),
                ),
                DropdownMenuItem(
                  value: 'trustScore:desc',
                  child: Text('Score High-Low'),
                ),
                DropdownMenuItem(
                  value: 'trustScore:asc',
                  child: Text('Score Low-High'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingSkeletons() {
    return Column(
      children: List.generate(
        5,
        (idx) => Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<AuditLogEntry> entries) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 16,
        horizontalMargin: 8,
        headingRowHeight: 40,
        dataRowMinHeight: 48,
        dataRowMaxHeight: 64,
        columns: const [
          DataColumn(label: Text('Lot ID')),
          DataColumn(label: Text('Score')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: entries.map((entry) {
          final isApproved = entry.status == 'approved';
          final scoreColor = entry.score >= 80
              ? AppTheme.primaryGreen
              : const Color(0xFFF97316);

          return DataRow(
            cells: [
              DataCell(
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${entry.tokenId} (S/N: ${entry.serialNumber})',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (entry.trustExplanation != null &&
                        entry.trustExplanation!.isNotEmpty)
                      Text(
                        entry.trustExplanation!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  '${entry.score}/100',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: isApproved
                        ? AppTheme.primaryGreen.withValues(alpha: 0.12)
                        : const Color(0xFFF97316).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isApproved
                          ? AppTheme.primaryGreen
                          : const Color(0xFFF97316),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    entry.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isApproved
                          ? AppTheme.primaryGreen
                          : const Color(0xFFF97316),
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy, size: 16),
                      tooltip: 'Copy Token ID',
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: entry.tokenId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Token ID copied!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPagination(
    BuildContext context,
    AuditLogsPagination pagination,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Page ${pagination.currentPage} of ${pagination.totalPages} '
            '(${pagination.totalRecords} logs)',
            style: Theme.of(context).textTheme.labelSmall,
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: pagination.currentPage > 1
                    ? () => onPageChanged(pagination.currentPage - 1)
                    : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: pagination.currentPage < pagination.totalPages
                    ? () => onPageChanged(pagination.currentPage + 1)
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
