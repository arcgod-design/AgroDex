import 'package:agrodex_mobile/core/error/failures.dart';
import 'package:agrodex_mobile/core/theme/app_spacing.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/register_batch_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/models/verify_registration_models.dart';
import 'package:agrodex_mobile/features/marketplace/domain/validators/marketplace_validators.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/providers/marketplace_providers.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/services/image_picker_service.dart';
import 'package:agrodex_mobile/features/marketplace/presentation/widgets/marketplace_empty_error_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen for registering a new agricultural batch with AI pre-verification.
/// Matches React [BatchRegistration.tsx] 1:1.
class BatchRegistrationScreen extends ConsumerStatefulWidget {
  /// Creates a [BatchRegistrationScreen].
  const BatchRegistrationScreen({super.key});

  @override
  ConsumerState<BatchRegistrationScreen> createState() =>
      _BatchRegistrationScreenState();
}

class _BatchRegistrationScreenState
    extends ConsumerState<BatchRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _productTypeController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController(text: 'kg');
  final _locationController = TextEditingController();
  final _harvestDateController = TextEditingController();
  final _harvestBatchController = TextEditingController();
  final _metadataController = TextEditingController();

  String? _imageData;
  String? _errorMessage;

  @override
  void dispose() {
    _productTypeController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _locationController.dispose();
    _harvestDateController.dispose();
    _harvestBatchController.dispose();
    _metadataController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final service = ref.read(imagePickerServiceProvider);
    final data = await service.pickImage();
    if (data != null) {
      setState(() {
        _imageData = data;
      });
    }
  }

  Future<void> _handleVerifyAndRegister() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      MarketplaceValidators.validateRegistration(
        productType: _productTypeController.text,
        quantity: _quantityController.text,
        location: _locationController.text,
        harvestDate: _harvestDateController.text,
      );
    } on ValidationException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
      return;
    }

    final controller = ref.read(batchRegistrationControllerProvider.notifier);

    final verifyReq = VerifyRegistrationRequest(
      productName: _productTypeController.text.trim(),
      harvestBatch: _harvestBatchController.text.trim(),
      quantity: _quantityController.text.trim(),
      unit: _unitController.text.trim(),
      location: _locationController.text.trim(),
      harvestDate: _harvestDateController.text.trim(),
      metadata: _metadataController.text.trim(),
    );

    final verificationRes = await controller.verifyRegistration(verifyReq);

    if (!mounted) return;

    final confirmed = await AiVerificationSummaryDialog.show(
      context,
      summary: verificationRes.data,
    );

    if (confirmed != true || !mounted) return;

    final registerReq = RegisterBatchRequest(
      productType: _productTypeController.text.trim(),
      quantity:
          '${_quantityController.text.trim()} ${_unitController.text.trim()}',
      location: _locationController.text.trim(),
      imageData: _imageData ?? DefaultImagePickerService.sampleBase64Image,
      harvestDate: _harvestDateController.text.trim(),
      aiVerification: verificationRes.data.toJson(),
    );

    try {
      final res = await controller.registerBatch(registerReq);
      if (res != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Batch Registered: ${res.message}'),
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
    final state = ref.watch(batchRegistrationControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register Batch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_2),
            tooltip: 'Verify by QR',
            onPressed: () => context.push('/verify'),
          ),
        ],
      ),
      body: state.when(
        loading: () => const MarketplaceLoadingWidget(
          label: 'Submitting batch registration to Hedera...',
        ),
        error: (err, _) => MarketplaceErrorWidget(
          message: err.toString(),
          onRetry: () =>
              ref.read(batchRegistrationControllerProvider.notifier).reset(),
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Create Immutable Supply Chain Lot',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Register agricultural batches onto Hedera Consensus Service with automated AI visual and provenance checks.',
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
            TextFormField(
              controller: _productTypeController,
              decoration: const InputDecoration(
                labelText: 'Product / Crop Type *',
                hintText: 'e.g. Arabica Coffee Beans',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Quantity *',
                      hintText: '500',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Harvest Location / Origin *',
                hintText: 'e.g. Aceh, Sumatra',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _harvestDateController,
              decoration: const InputDecoration(
                labelText: 'Harvest Date (YYYY-MM-DD) *',
                hintText: '2026-05-20',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _harvestBatchController,
              decoration: const InputDecoration(
                labelText: 'Harvest Batch Code',
                hintText: 'e.g. BATCH-2026-001',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _metadataController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Additional Metadata (JSON or Notes)',
                hintText: '{"farmId": "F-102", "grade": "Specialty A"}',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: Icon(
                _imageData != null
                    ? Icons.check_circle
                    : Icons.camera_alt_outlined,
              ),
              label: Text(
                _imageData != null
                    ? 'Batch Photo Attached'
                    : 'Attach Batch Photo / Sample',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _handleVerifyAndRegister,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Verify with AI & Register on Hedera',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView(
    BuildContext context,
    RegisterBatchResponse response,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.verified_outlined, size: 64, color: Colors.green),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Batch Successfully Registered',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            response.message,
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
                  Text('Batch UUID:', style: theme.textTheme.labelLarge),
                  Text(
                    response.batchId,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Hedera HCS Tx ID:', style: theme.textTheme.labelLarge),
                  Text(
                    response.hcsTransactionId,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
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
                        .read(batchRegistrationControllerProvider.notifier)
                        .reset();
                  },
                  child: const Text('Register Another'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.push('/verify/${response.batchId}'),
                  child: const Text('View Provenance'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
