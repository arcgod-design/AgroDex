import 'package:agrodex_mobile/core/theme/app_colors.dart';
import 'package:agrodex_mobile/core/theme/app_spacing.dart';
import 'package:agrodex_mobile/features/marketplace/domain/validators/marketplace_validators.dart';
import 'package:flutter/material.dart';

/// Modal dialog for scanning or simulating QR code verification payloads.
/// Matches React [QrScannerModal.tsx] in styling and validation.
class QrScannerModalWidget extends StatefulWidget {
  /// Whether the scanner modal is visible.
  final bool isOpen;

  /// Callback when modal is closed.
  final VoidCallback onClose;

  /// Callback when a valid QR payload is decoded.
  final ValueChanged<String> onScanSuccess;

  /// Callback when scanning encounters an error.
  final ValueChanged<String>? onScanError;

  /// Creates a [QrScannerModalWidget].
  const QrScannerModalWidget({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onScanSuccess,
    this.onScanError,
  });

  /// Displays this modal as a dialog in the current [context].
  static Future<void> show(
    BuildContext context, {
    required ValueChanged<String> onScanSuccess,
    ValueChanged<String>? onScanError,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => QrScannerModalWidget(
        isOpen: true,
        onClose: () => Navigator.of(context).pop(),
        onScanSuccess: (text) {
          Navigator.of(context).pop();
          onScanSuccess(text);
        },
        onScanError: onScanError,
      ),
    );
  }

  @override
  State<QrScannerModalWidget> createState() => _QrScannerModalWidgetState();
}

class _QrScannerModalWidgetState extends State<QrScannerModalWidget> {
  final TextEditingController _manualInputController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _manualInputController.dispose();
    super.dispose();
  }

  void _handleSimulateScan() {
    final text = _manualInputController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a QR code JSON payload or URL.';
      });
      return;
    }

    final parsed = MarketplaceValidators.validateQrPayload(text);
    if (parsed == null) {
      setState(() {
        _errorMessage =
            'Invalid QR Code format. Please check the JSON or URL syntax.';
      });
      widget.onScanError?.call('Invalid QR Code format.');
      return;
    }

    widget.onScanSuccess(text);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      'Scan Verification QR Code',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Align the QR code within the frame to verify batch authenticity.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 48,
                    color: theme.colorScheme.primary.withValues(alpha: 0.7),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Camera Scanner Active',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _manualInputController,
              decoration: InputDecoration(
                labelText: 'Manual QR Payload / URL (Test Mode)',
                hintText: '{"batchId":"f47ac10b-58cc-4372-a567-0e02b2c3d479"}',
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onClose,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton.icon(
                  onPressed: _handleSimulateScan,
                  icon: const Icon(Icons.check),
                  label: const Text('Simulate Scan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
