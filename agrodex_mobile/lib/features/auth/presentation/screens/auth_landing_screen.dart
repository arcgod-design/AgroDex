import 'package:agrodex_mobile/core/constants/app_constants.dart';
import 'package:agrodex_mobile/shared/extensions/context_extensions.dart';
import 'package:agrodex_mobile/shared/widgets/app_button.dart';
import 'package:agrodex_mobile/shared/widgets/app_card.dart';
import 'package:agrodex_mobile/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Welcome / Auth Landing Screen mirroring React `AuthLanding.tsx`.
/// Displays Hedera & Gemini feature highlights and quick authentication options.
class AuthLandingScreen extends ConsumerWidget {
  const AuthLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colorScheme.primary.withValues(alpha: 0.15),
              context.colorScheme.surface,
              context.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.space24,
              vertical: AppConstants.space16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header badge
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.space12,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: context.colorScheme.primary.withValues(
                        alpha: 0.12,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusCircular,
                      ),
                      border: Border.all(
                        color: context.colorScheme.primary.withValues(
                          alpha: 0.3,
                        ),
                      ),
                    ),
                    child: Text(
                      'Hedera Verified • Testnet',
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.space32),

                // Hero Copy
                Text(
                  'AgroDex',
                  style: context.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: context.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: AppConstants.space8),
                Text(
                  'AI-Powered Agricultural Traceability on Hedera',
                  style: context.textTheme.titleMedium?.copyWith(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: AppConstants.space24),

                // Feature checklist
                _buildFeatureItem(
                  context,
                  title: 'Hedera Blockchain',
                  description: 'Immutable proof of every step on HCS & HTS.',
                ),
                const SizedBox(height: AppConstants.space12),
                _buildFeatureItem(
                  context,
                  title: 'Gemini 3.1 Flash Lite',
                  description: 'Real-time audits, Trust Scores, and buyer Q&A.',
                ),
                const SizedBox(height: AppConstants.space12),
                _buildFeatureItem(
                  context,
                  title: 'Multilingual',
                  description:
                      'AI-generated audit reports in English & French.',
                ),
                const SizedBox(height: AppConstants.space24),

                // AI Insight Quote Card
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"This batch shows consistent traceability across 3 harvest stages with high confidence."',
                        style: context.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: AppConstants.space8),
                      Text(
                        '— Generated by Gemini 3.1 Flash Lite',
                        style: context.textTheme.labelSmall?.copyWith(
                          color: context.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.space32),

                // Auth Action Buttons
                AppButton(
                  label: 'Email Login',
                  variant: AppButtonVariant.primary,
                  onPressed: () {
                    context.go('/login');
                  },
                ),
                const SizedBox(height: AppConstants.space12),
                AppButton(
                  label: 'EVM Wallet (MetaMask)',
                  variant: AppButtonVariant.outline,
                  onPressed: () {
                    AppSnackbar.show(
                      context,
                      message: 'MetaMask / WalletConnect support coming soon.',
                      type: SnackbarType.info,
                    );
                  },
                ),
                const SizedBox(height: AppConstants.space12),
                AppButton(
                  label: 'Hedera Native (HashPack)',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    AppSnackbar.show(
                      context,
                      message: 'HashPack / HashConnect support coming soon.',
                      type: SnackbarType.info,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle, color: context.colorScheme.primary, size: 20),
        const SizedBox(width: AppConstants.space12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: context.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
