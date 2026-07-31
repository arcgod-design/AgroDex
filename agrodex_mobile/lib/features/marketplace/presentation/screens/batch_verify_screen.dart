import 'package:agrodex_mobile/core/theme/app_colors.dart';
import 'package:agrodex_mobile/core/theme/app_spacing.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/widgets/marketplace_empty_error_widgets.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/widgets/qr_scanner_modal_widget.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/widgets/verification_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen for verifying batch provenance and rendering Hedera certificates.
/// Matches React [BatchVerify.tsx] exactly.
class BatchVerifyScreen extends ConsumerStatefulWidget {
  /// Optional Supabase batch ID UUID.
  final String? batchId;

  /// Optional Hedera token ID.
  final String? tokenId;

  /// Optional Hedera serial number.
  final String? serialNumber;

  /// Creates a [BatchVerifyScreen].
  const BatchVerifyScreen({
    super.key,
    this.batchId,
    this.tokenId,
    this.serialNumber,
  });

  @override
  ConsumerState<BatchVerifyScreen> createState() => _BatchVerifyScreenState();
}

class _BatchVerifyScreenState extends ConsumerState<BatchVerifyScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleOpenScanner() {
    QrScannerModalWidget.show(
      context,
      onScanSuccess: (decodedText) {
        // Navigate or lookup based on decoded payload
        if (decodedText.contains('/verify/')) {
          final uri = Uri.tryParse(decodedText);
          if (uri != null) {
            final segments = uri.pathSegments;
            final idx = segments.indexOf('verify');
            if (idx >= 0 && idx + 1 < segments.length) {
              context.push('/verify/${segments[idx + 1]}');
              return;
            }
          }
        }
        // Try as raw UUID
        if (decodedText.length == 36 && decodedText.contains('-')) {
          context.push('/verify/$decodedText');
        }
      },
    );
  }

  void _handleSearchSubmit() {
    final clean = _searchController.text.trim();
    if (clean.isEmpty) return;
    context.push('/verify/$clean');
  }

  @override
  Widget build(BuildContext context) {
    final hasParam =
        (widget.batchId != null && widget.batchId!.isNotEmpty) ||
        (widget.tokenId != null && widget.serialNumber != null);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Provenance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan QR Code',
            onPressed: _handleOpenScanner,
          ),
        ],
      ),
      body: !hasParam
          ? _buildSearchHub(context, theme)
          : _buildVerificationContent(context),
    );
  }

  Widget _buildSearchHub(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Icon(
            Icons.verified_user_outlined,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Supply Chain Proof of Authenticity',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Enter a Lot UUID, Hedera Token ID, or scan a physical QR code to verify immutable supply chain provenance.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Lot ID / Batch UUID',
              hintText: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _handleSearchSubmit,
              ),
            ),
            onSubmitted: (_) => _handleSearchSubmit(),
          ),
          const SizedBox(height: AppSpacing.md),
          ElevatedButton.icon(
            onPressed: _handleSearchSubmit,
            icon: const Icon(Icons.verified),
            label: const Text('Verify Lot'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: _handleOpenScanner,
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR Code'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationContent(BuildContext context) {
    final params = VerifyBatchParams(
      batchId: widget.batchId,
      tokenId: widget.tokenId,
      serialNumber: widget.serialNumber,
    );

    final asyncResult = ref.watch(verifyBatchProvider(params));

    return asyncResult.when(
      loading: () => const MarketplaceLoadingWidget(
        label: 'Verifying cryptographic proof on Hedera...',
      ),
      error: (err, _) => MarketplaceErrorWidget(
        message: err.toString(),
        onRetry: () => ref.invalidate(verifyBatchProvider(params)),
      ),
      data: (result) {
        if (result is VerifyBatchNotFoundResult) {
          return MarketplaceEmptyWidget(
            title: 'Lot Not Found',
            description:
                'This batch ID or token serial is not yet listed in AgroDex.',
            actionLabel: 'Search Again',
            onAction: () => context.go('/verify'),
          );
        }
        if (result is VerifyBatchDeletedResult) {
          return MarketplaceEmptyWidget(
            title: 'Lot Withdrawn / Deleted',
            description: 'This batch record was removed from AgroDex registry.',
            actionLabel: 'Return to Hub',
            onAction: () => context.go('/verify'),
          );
        }
        if (result is VerifyBatchResponse) {
          return _buildCertificate(context, result);
        }
        return const MarketplaceEmptyWidget(
          title: 'Unknown Verification State',
          description: 'Could not resolve lot status.',
        );
      },
    );
  }

  Widget _buildCertificate(BuildContext context, VerifyBatchResponse res) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                res.batch?.batchName ?? 'Verified Agricultural Lot',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              VerificationStatusBadge(
                status: res.status,
                trustScore: res.aiSummary?.trustScore,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Cryptographically verified on Hedera Consensus Service.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (res.aiSummary != null) ...[
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.psychology,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Provenance Assessment',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      res.aiSummary!.summaryEn,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (res.aiSummary!.trustExplanation.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Explanation: ${res.aiSummary!.trustExplanation}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (res.batch != null) ...[
            Text('Lot Specifications', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    _buildRow('Product Type', res.batch!.productType),
                    const Divider(),
                    _buildRow('Quantity', res.batch!.quantity),
                    const Divider(),
                    _buildRow('Harvest Origin', res.batch!.location),
                    const Divider(),
                    _buildRow('Harvest Date', res.batch!.harvestDate),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
          Text(
            'Hedera DLT Registry Tokens',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                children: [
                  _buildRow('Hedera Token ID', res.tokenId),
                  const Divider(),
                  _buildRow('NFT Serial Number', res.serialNumber),
                  const Divider(),
                  _buildRow(
                    'HCS Transactions',
                    res.hcsTransactionIds.length.toString(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: () => context.push('/map'),
            icon: const Icon(Icons.map_outlined),
            label: const Text('View on Supply Chain Map'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Flexible(
            child: Text(
              value.isNotEmpty ? value : 'N/A',
              textAlign: TextAlign.end,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
