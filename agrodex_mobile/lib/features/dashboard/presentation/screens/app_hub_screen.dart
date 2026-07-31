import 'package:agrodex_mobile/core/theme/app_theme.dart';
import 'package:agrodex_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Main App Hub screen matching React `src/pages/Index.tsx`.
/// Serves as the primary navigation portal for authenticated users.
class AppHubScreen extends ConsumerWidget {
  const AppHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.shield_outlined, color: AppTheme.primaryGreen),
            const SizedBox(width: 8),
            Text(
              'AgroDex Hub',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout_outlined),
            onPressed: () async {
              await ref.read(authControllerProvider.notifier).signOut();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero
            _buildHero(context),
            // Quick Navigation Hub
            _buildNavHub(context),
            // Problem Section
            _buildProblemSection(context),
            // Solution Section
            _buildSolutionSection(context),
            // How It Works
            _buildHowItWorksSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.12),
            const Color(0xFF2563EB).withValues(alpha: 0.12),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 16,
                  color: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 6),
                Text(
                  'Powered by Hedera + AI',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.primaryGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Fighting Food Fraud in Indonesia',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Immutable agricultural traceability powered by Hedera consensus and Gemini 3.1 Flash Lite AI analysis.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavHub(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Access Hub',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNavCard(
                  context,
                  title: 'Dashboard',
                  subtitle: 'Real-time ledger & KPIs',
                  icon: Icons.bar_chart_outlined,
                  color: AppTheme.primaryGreen,
                  onTap: () => context.go('/dashboard'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNavCard(
                  context,
                  title: 'Verify Batch',
                  subtitle: 'Check certificate',
                  icon: Icons.verified_user_outlined,
                  color: const Color(0xFF2563EB),
                  onTap: () => context.go('/verify'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNavCard(
                  context,
                  title: 'Register Batch',
                  subtitle: 'New harvest record',
                  icon: Icons.description_outlined,
                  color: const Color(0xFF9333EA),
                  onTap: () => context.go('/register'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNavCard(
                  context,
                  title: 'Tokenize',
                  subtitle: 'Create HTS NFT',
                  icon: Icons.monetization_on_outlined,
                  color: const Color(0xFFF97316),
                  onTap: () => context.go('/tokenize'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNavCard(
                  context,
                  title: 'Supply Chain Map',
                  subtitle: 'Explore clusters',
                  icon: Icons.map_outlined,
                  color: const Color(0xFF0D9488),
                  onTap: () => context.go('/map'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNavCard(
                  context,
                  title: 'Risk Intelligence',
                  subtitle: 'AI fraud & delay audit',
                  icon: Icons.psychology_outlined,
                  color: const Color(0xFFE11D48),
                  onTap: () => context.go('/risk-intelligence'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 10),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProblemSection(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Food Fraud Costs Billions',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(context, '40%', 'Mislabeled produce'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(context, '\$40B', 'Global fraud loss'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatItem(context, '0%', 'Trust without data'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String val, String label) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionSection(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AgroDex: Blockchain + AI',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildSolutionCard(
            context,
            title: 'Hedera HCS',
            description:
                'Immutable timestamped consensus ledger for every event.',
            icon: Icons.link,
          ),
          const SizedBox(height: 10),
          _buildSolutionCard(
            context,
            title: 'Hedera HTS',
            description: 'Tokenized NFT certificates proving authenticity.',
            icon: Icons.token,
          ),
          const SizedBox(height: 10),
          _buildSolutionCard(
            context,
            title: 'Gemini 3.1 Flash Lite',
            description: 'AI audit and provenance score generation.',
            icon: Icons.auto_awesome,
          ),
        ],
      ),
    );
  }

  Widget _buildSolutionCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryGreen, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStepRow(
            context,
            '01',
            'Register Harvest',
            'Capture data & photo via HCS',
          ),
          const SizedBox(height: 10),
          _buildStepRow(
            context,
            '02',
            'Tokenize Certificate',
            'Mint NFT on HTS with AI score',
          ),
          const SizedBox(height: 10),
          _buildStepRow(
            context,
            '03',
            'Verify Batch',
            'Scan QR or enter batch ID',
          ),
        ],
      ),
    );
  }

  Widget _buildStepRow(
    BuildContext context,
    String step,
    String title,
    String desc,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            step,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryGreen,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                desc,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
