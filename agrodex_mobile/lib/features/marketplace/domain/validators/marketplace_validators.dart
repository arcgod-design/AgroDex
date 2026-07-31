import 'dart:convert';
import 'package:agrodex_mobile/core/error/failures.dart';

/// Parsed payload result from decoding a QR code in AgroDex.
class QrScanPayload {
  /// Supabase batch UUID if extracted.
  final String? batchId;

  /// Optional verification URL.
  final String? verificationUrl;

  /// Raw verification URL if scanned as a direct link.
  final String? rawUrl;

  /// Creates a [QrScanPayload].
  const QrScanPayload({this.batchId, this.verificationUrl, this.rawUrl});
}

/// Validation utilities for Marketplace batch registration, tokenization,
/// and QR code scanning. Matches React [BatchVerify.tsx] and [BatchRegistration.tsx].
class MarketplaceValidators {
  MarketplaceValidators._();

  static final RegExp _uuidRegex = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  static final RegExp _urlRegex = RegExp(
    r'^(https?:\/\/)?([\da-z\.-]+)\.([a-z\.]{2,6})([\/\w \.-]*)*\/?$',
    caseSensitive: false,
  );

  /// Validates registration form inputs and throws [ValidationException] if invalid.
  static void validateRegistration({
    required String productType,
    required String quantity,
    required String location,
    required String harvestDate,
  }) {
    if (productType.trim().isEmpty) {
      throw const ValidationException('Product type is required.');
    }
    if (quantity.trim().isEmpty) {
      throw const ValidationException('Quantity is required.');
    }
    if (location.trim().length < 3) {
      throw const ValidationException(
        'Location must be at least 3 characters long.',
      );
    }
    if (harvestDate.trim().isEmpty) {
      throw const ValidationException('Harvest date is required.');
    }
  }

  /// Validates a list of HCS Transaction IDs for tokenization.
  static List<String> parseAndValidateHcsTxIds(String input) {
    final ids = input
        .split(RegExp(r'[\n,]'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (ids.isEmpty) {
      throw const ValidationException(
        'Please enter at least one HCS Transaction ID.',
      );
    }

    return ids;
  }

  /// Parses and validates a QR code string matching React [validateQrPayload].
  /// Returns [QrScanPayload] if valid, or `null` if unrecognized/unsafe.
  static QrScanPayload? validateQrPayload(String text) {
    final clean = text.trim();
    if (clean.toLowerCase().contains('javascript:') ||
        clean.contains('<script')) {
      return null;
    }

    try {
      final data = jsonDecode(clean);
      if (data is Map) {
        final batchId = data['batchId']?.toString();
        if (batchId == null || !_uuidRegex.hasMatch(batchId)) {
          return null;
        }

        final url = data['verificationUrl']?.toString() ?? '';
        if (url.isNotEmpty) {
          if (url.toLowerCase().contains('javascript:') ||
              url.contains('<script')) {
            return null;
          }
          if (!_urlRegex.hasMatch(url)) {
            return null;
          }
        }

        return QrScanPayload(batchId: batchId, verificationUrl: url);
      }
    } catch (_) {
      // Not JSON, check if it is a direct verification URL
    }

    if (_urlRegex.hasMatch(clean) && clean.toLowerCase().contains('/verify/')) {
      return QrScanPayload(rawUrl: clean);
    }

    return null;
  }
}
