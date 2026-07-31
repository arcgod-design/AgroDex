import 'package:agrodex_mobile/core/error/failures.dart';
import 'package:agrodex_mobile/core/theme/app_spacing.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/tokenize_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/validators/marketplace_validators.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/widgets/marketplace_empty_error_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen for tokenizing Hedera Consensus Service batches into HTS NFTs.
/// Matches React [BatchTokenize.tsx] 1:1.
class BatchTokenizeScreen extends ConsumerStatefulWidget {
  /// Creates a [BatchTokenizeScreen].
  const BatchTokenizeScreen({super.key});

  @override
  ConsumerState<BatchTokenizeScreen> createState() =>
      _BatchTokenizeScreenState();
}

class _BatchTokenizeScreenState extends ConsumerState<BatchTokenizeScreen> {
  final _txIdsController = TextEditingController();
  bool _isDemoMode = false;
  String? _errorMessage;

  @override
  void dispose() {
    _txIdsController.dispose();
    super.dispose();
  }

  Future<void> _handleTokenize() {
    setState(() {
      _errorMessage = null;
    });

    final List<String> ids;
    try {
      ids = MarketplaceValidators.parseAndValidateHcsTxIds(
        _txIdsController.text,
      );
    } on ValidationException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
      return Future<void>.value();
    }

    return _executeTokenize(ids);
  }

  Future<void> _executeTokenize(List<String> ids) async {
    final controller = ref.read(batchTokenizationControllerProvider.notifier);
    final lastBatchId = await ref.read(lastRegisteredBatchIdProvider.future);

    final req = TokenizeBatchRequest(
      hcsTransactionIds: ids,
      batchId: lastBatchId,
    );

    try {
      final res = await controller.tokenize(req, isDemoMode: _isDemoMode);
      if (res != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Token Minted: ${res.tokenId} #${res.serialNumber}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e is AppException ? e.message : e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batchTokenizationControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tokenize Batch')),
      body: state.when(
        loading: () => const MarketplaceLoadingWidget(
          label: 'Minting Hedera Token Service NFT...',
        ),
        error: (err, _) => MarketplaceErrorWidget(
          message: err.toString(),
          onRetry: () =>
              ref.read(batchTokenizationControllerProvider.notifier).reset(),
        ),
        data: (response) {
          if (response != null && response.success) {
            return _buildSuccessView(context, response);
          }
          return _buildFormView(context, theme);
        },
      ),
    );
  }

  Widget _buildFormView(BuildContext context, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mint Hedera NFT Token',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Convert immutable Consensus Service supply chain logs into a transferable Hedera Token Service (HTS) Non-Fungible Token.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: Colors.red),
              ),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
          TextField(
            controller: _txIdsController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText:
                  'HCS Transaction IDs (one per line or comma separated)',
              hintText:
                  '0.0.12345@1715000000.000000000\n0.0.12345@1715000005.000000000',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SwitchListTile(
            title: const Text('Demo / Simulation Mode'),
            subtitle: const Text(
              'Simulate token minting without broadcast fee requirements.',
            ),
            value: _isDemoMode,
            onChanged: (val) {
              setState(() {
                _isDemoMode = val;
              });
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton.icon(
            onPressed: _handleTokenize,
            icon: const Icon(Icons.token_outlined),
            label: const Text('Tokenize Batch on Hedera'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(
    BuildContext context,
    TokenizeBatchResponse response,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.token, size: 64, color: Colors.green),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Batch Successfully Tokenized',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hedera NFT created and linked to batch records.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hedera Token ID:', style: theme.textTheme.labelLarge),
                  Text(
                    response.tokenId,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Serial Number:', style: theme.textTheme.labelLarge),
                  Text(
                    '#${response.serialNumber}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  if (response.batchId != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Linked Batch UUID:',
                      style: theme.textTheme.labelLarge,
                    ),
                    Text(
                      response.batchId!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    ref
                        .read(batchTokenizationControllerProvider.notifier)
                        .reset();
                  },
                  child: const Text('Tokenize Another'),
                ),
              ),
              if (response.batchId != null) ...[
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        context.push('/verify/${response.batchId}'),
                    child: const Text('Verify Lot'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
