import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/supply_chain_risk_models.dart';
import '../providers/risk_providers.dart';
import '../widgets/ai_chat_modal_widget.dart';
import '../widgets/ai_recommendation_card_widget.dart';
import '../widgets/delay_prediction_card_widget.dart';
import '../widgets/fraud_overview_widgets.dart';
import '../widgets/inventory_signals_widget.dart';
import '../widgets/risk_heatmap_widget.dart';
import '../widgets/risk_score_card_widget.dart';
import '../widgets/risk_trend_chart_widget.dart';
import '../widgets/supplier_reliability_list_widget.dart';
import '../widgets/verification_assistant_widget.dart';

/// Main Risk Intelligence and AI Supply Chain dashboard screen matching React RiskIntelligence.tsx.
class RiskIntelligenceScreen extends ConsumerStatefulWidget {
  /// Creates a [RiskIntelligenceScreen].
  const RiskIntelligenceScreen({super.key});

  @override
  ConsumerState<RiskIntelligenceScreen> createState() =>
      _RiskIntelligenceScreenState();
}

class _RiskIntelligenceScreenState extends ConsumerState<RiskIntelligenceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    ref.invalidate(riskAssessmentProvider);
    ref.invalidate(fraudOverviewProvider);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assessmentAsync = ref.watch(riskAssessmentProvider);
    final fraudAsync = ref.watch(fraudOverviewProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.psychology, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            const Text(
              'AI & Risk Intelligence',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.auto_awesome, color: AppColors.primary),
            tooltip: 'AI Chat Assistant',
            onPressed: () => AiChatModalWidget.show(context),
          ),
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            tooltip: 'Refresh AI Assessment',
            onPressed: _isRefreshing ? null : _handleRefresh,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Supply Chain Risk'),
            Tab(text: 'Fraud Overview'),
            Tab(text: 'Verification Assistant'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.chat_bubble_outline, size: 20),
        label: const Text(
          'AI Assistant',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        onPressed: () => AiChatModalWidget.show(context),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Supply Chain Risk
          assessmentAsync.when(
            loading: () => const _LoadingView(
              message: 'Analyzing supply chain risk signals...',
            ),
            error: (err, _) => _ErrorView(
              message: 'Failed to load AI risk assessment.',
              onRetry: _handleRefresh,
            ),
            data: (assessment) => _buildRiskTab(context, assessment),
          ),

          // Tab 2: Fraud Overview
          fraudAsync.when(
            loading: () => const _LoadingView(
              message: 'Aggregating fraud intelligence...',
            ),
            error: (err, _) => _ErrorView(
              message: 'Failed to load fraud overview.',
              onRetry: _handleRefresh,
            ),
            data: (overview) => _buildFraudTab(context, overview),
          ),

          // Tab 3: Verification Assistant
          SingleChildScrollView(
            padding: AppSpacing.paddingLg,
            child: const VerificationAssistantWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskTab(
    BuildContext context,
    SupplyChainRiskAssessment assessment,
  ) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Confidence Banner
            Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: AppSpacing.borderRadiusLg,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'AI-powered risk assessment',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${assessment.confidence}% Confidence',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapSm,
                  Text(
                    assessment.summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.gapLg,

            // KPI Scorecards Grid
            const Text(
              'Key Risk Indicators',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapMd,

            if (assessment.scoreCards.isEmpty)
              const _EmptyView(message: 'No KPI scorecards available.')
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth > 700 ? 3 : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      mainAxisExtent: 210,
                    ),
                    itemCount: assessment.scoreCards.length,
                    itemBuilder: (context, index) {
                      return RiskScoreCardWidget(
                        card: assessment.scoreCards[index],
                      );
                    },
                  );
                },
              ),
            AppSpacing.gapLg,

            // Fraud Indicator Section
            const Text(
              'Fraud Probability Indicator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapMd,
            Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: AppSpacing.borderRadiusLg,
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        assessment.fraudIndicator.label,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${assessment.fraudIndicator.probability}%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.gapSm,
                  ...assessment.fraudIndicator.signals.map((signal) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: Color(0xFF059669),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              signal,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            AppSpacing.gapLg,

            // 30-Day Risk Trends
            const Text(
              '30-Day Risk Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapMd,
            Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: AppSpacing.borderRadiusLg,
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: RiskTrendChartWidget(points: assessment.trends),
            ),
            AppSpacing.gapLg,

            // Delay Predictions
            const Text(
              'Logistics Delay Predictions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapMd,
            if (assessment.delayPredictions.isEmpty)
              const _EmptyView(message: 'No active delay warnings.')
            else
              ...assessment.delayPredictions.map(
                (p) => DelayPredictionCardWidget(prediction: p),
              ),
            AppSpacing.gapLg,

            // Visual Risk Heatmap
            const Text(
              'Visual Risk Heatmap (Region x Stage)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapMd,
            Container(
              padding: AppSpacing.paddingLg,
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: AppSpacing.borderRadiusLg,
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.1),
                ),
              ),
              child: RiskHeatmapWidget(cells: assessment.heatmap),
            ),
            AppSpacing.gapLg,

            // AI Recommendations
            const Text(
              'AI Intervention Recommendations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapMd,
            if (assessment.recommendations.isEmpty)
              const _EmptyView(
                message: 'No recommendations currently triggered.',
              )
            else
              ...assessment.recommendations.map(
                (r) => AiRecommendationCardWidget(recommendation: r),
              ),
            AppSpacing.gapLg,

            // Inventory Signals
            const Text(
              'Inventory Coverage Signals',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapMd,
            InventorySignalsWidget(signals: assessment.inventorySignals),
            AppSpacing.gapLg,

            // Supplier Reliability
            const Text(
              'Supplier Partner Reliability Index',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapMd,
            SupplierReliabilityListWidget(suppliers: assessment.suppliers),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildFraudTab(BuildContext context, dynamic overview) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppColors.primary,
      child: SingleChildScrollView(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fraud Level Distribution',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapMd,
            FraudLevelCountsWidget(levelCounts: overview.levelCounts),
            AppSpacing.gapLg,

            const Text(
              'Top Farmer Risk Ranking',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapMd,
            FarmerRankingListWidget(farmers: overview.farmerRanking),
            AppSpacing.gapLg,

            const Text(
              'Regional Outlier Analytics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            AppSpacing.gapMd,
            RegionalAnalyticsListWidget(items: overview.regionalAnalytics),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  final String message;
  const _LoadingView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(message, style: const TextStyle(color: Colors.grey)),
      ),
    );
  }
}
