import 'package:agrodex_mobile/core/constants/app_constants.dart';
import 'package:agrodex_mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:agrodex_mobile/shared/extensions/context_extensions.dart';
import 'package:agrodex_mobile/shared/widgets/app_button.dart';
import 'package:agrodex_mobile/shared/widgets/app_card.dart';
import 'package:agrodex_mobile/shared/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Authentication Screen supporting Email/Password Sign-In and Sign-Up,
/// plus Hedera / EVM Wallet connections matching React `Login.tsx`.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      AppSnackbar.show(
        context,
        message: 'Please enter both email and password.',
        type: SnackbarType.error,
      );
      return;
    }

    final authNotifier = ref.read(authControllerProvider.notifier);
    if (_isSignUp) {
      await authNotifier.signUpWithEmail(email: email, password: password);
    } else {
      await authNotifier.signInWithEmail(email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Create Account' : 'Welcome Back'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Use pop() — not go('/welcome') — so we return to the previous
            // route on the stack. go('/welcome') triggers GoRouter to replace
            // the entire stack, which causes the AuthGuard to re-evaluate and
            // can produce unexpected redirect loops on some navigation paths.
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/welcome');
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isSignUp
                    ? 'Start tracking agricultural batches on Hedera'
                    : 'Sign in to access your AgroDex account',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.space24),

              // Mode Tabs (Email vs Wallet)
              Container(
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusCircular,
                  ),
                  border: Border.all(
                    color: context.colorScheme.onSurface.withValues(alpha: 0.1),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicator: BoxDecoration(
                    color: context.colorScheme.primary,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusCircular,
                    ),
                  ),
                  labelColor: context.colorScheme.onPrimary,
                  unselectedLabelColor: context.colorScheme.onSurface
                      .withValues(alpha: 0.7),
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.email_outlined, size: 18),
                      text: 'EMAIL',
                    ),
                    Tab(
                      icon: Icon(
                        Icons.account_balance_wallet_outlined,
                        size: 18,
                      ),
                      text: 'WALLET',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.space24),

              // Error banner
              if (authState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.space12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    border: Border.all(
                      color: context.colorScheme.error.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: context.colorScheme.error,
                      ),
                      const SizedBox(width: AppConstants.space8),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.error,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.space16),
              ],

              // Success banner
              if (authState.successMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppConstants.space12),
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                    border: Border.all(
                      color: context.colorScheme.primary.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: context.colorScheme.primary,
                      ),
                      const SizedBox(width: AppConstants.space8),
                      Expanded(
                        child: Text(
                          authState.successMessage!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.space16),
              ],

              // Tab Views
              SizedBox(
                height: 420,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildEmailTab(context, authState.isLoading),
                    _buildWalletTab(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailTab(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppConstants.space8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email Address',
            prefixIcon: Icon(Icons.mail_outline),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: AppConstants.space16),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: AppConstants.space24),
        AppButton(
          label: _isSignUp ? 'Create Account' : 'Sign In',
          variant: AppButtonVariant.primary,
          isLoading: isLoading,
          onPressed: _handleSubmit,
        ),
        const SizedBox(height: AppConstants.space16),
        TextButton(
          onPressed: () {
            setState(() {
              _isSignUp = !_isSignUp;
              ref.read(authControllerProvider.notifier).clearMessages();
            });
          },
          child: Text(
            _isSignUp
                ? 'Already have an account? Sign In'
                : "Don't have an account? Sign Up",
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletTab(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: AppConstants.space8),
        AppCard(
          child: ListTile(
            leading: const Icon(
              Icons.account_balance_wallet,
              color: Colors.orange,
            ),
            title: const Text('MetaMask'),
            subtitle: const Text('Connect EVM wallet on Hedera'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              AppSnackbar.show(
                context,
                message: 'MetaMask connection modal opening...',
                type: SnackbarType.info,
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.space12),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.wallet, color: Colors.green),
            title: const Text('HashPack'),
            subtitle: const Text('Connect Hedera native wallet'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              AppSnackbar.show(
                context,
                message: 'HashPack connection modal opening...',
                type: SnackbarType.info,
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.space12),
        AppCard(
          child: ListTile(
            leading: const Icon(Icons.shield_outlined, color: Colors.purple),
            title: const Text('Core Wallet'),
            subtitle: const Text('Connect Core EVM wallet'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              AppSnackbar.show(
                context,
                message: 'Core wallet connection modal opening...',
                type: SnackbarType.info,
              );
            },
          ),
        ),
      ],
    );
  }
}
