import 'package:agrodex_mobile/core/theme/app_spacing.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/map_batch_model.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/widgets/batch_card_widget.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/widgets/map_pin_card_widget.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/widgets/marketplace_empty_error_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen displaying the agricultural Supply Chain Map and lot explorer.
/// Matches React [MapExplore.tsx] and [SupplyChainMap.tsx] 1:1.
class MapExploreScreen extends ConsumerStatefulWidget {
  /// Creates a [MapExploreScreen].
  const MapExploreScreen({super.key});

  @override
  ConsumerState<MapExploreScreen> createState() => _MapExploreScreenState();
}

class _MapExploreScreenState extends ConsumerState<MapExploreScreen> {
  MapBatch? _selectedBatch;

  @override
  Widget build(BuildContext context) {
    final batchesAsync = ref.watch(mapBatchesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supply Chain Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Map',
            onPressed: () => ref.invalidate(mapBatchesProvider),
          ),
        ],
      ),
      body: batchesAsync.when(
        loading: () => const MarketplaceLoadingWidget(
          label: 'Loading supply chain data...',
        ),
        error: (err, _) => MarketplaceErrorWidget(
          message: err.toString(),
          onRetry: () => ref.invalidate(mapBatchesProvider),
        ),
        data: (batches) {
          if (batches.isEmpty) {
            return const MarketplaceEmptyWidget(
              title: 'No Registered Batches Found',
              description:
                  'There are currently no agricultural batches registered in the supply chain map.',
            );
          }
          return _buildExploreContent(context, theme, batches);
        },
      ),
    );
  }

  Widget _buildExploreContent(
    BuildContext context,
    ThemeData theme,
    List<MapBatch> batches,
  ) {
    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Indonesia Agricultural Provenance Map',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Explore registered agricultural batches across Indonesia. Click on any lot to view provenance, fraud risk, and Hedera verification status.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final batch = batches[index];
                  return BatchCardWidget(
                    batch: batch,
                    onTap: () {
                      setState(() {
                        _selectedBatch = batch;
                      });
                    },
                  );
                }, childCount: batches.length),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
        if (_selectedBatch != null)
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: MapPinCardWidget(
              batch: _selectedBatch!,
              onClose: () {
                setState(() {
                  _selectedBatch = null;
                });
              },
              onVerify: () {
                final id = _selectedBatch!.id;
                setState(() {
                  _selectedBatch = null;
                });
                context.push('/verify/$id');
              },
            ),
          ),
      ],
    );
  }
}
