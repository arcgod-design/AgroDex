import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Abstraction for picking or capturing images for agricultural batch registration.
abstract class ImagePickerService {
  /// Picks an image from camera or gallery and returns base64 encoded string.
  Future<String?> pickImage({bool fromCamera = false});
}

/// Simulated / default implementation of [ImagePickerService] for batch registration.
class DefaultImagePickerService implements ImagePickerService {
  /// 1x1 transparent PNG base64 placeholder for default/test image data.
  static const String sampleBase64Image =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==';

  @override
  Future<String?> pickImage({bool fromCamera = false}) async {
    // In demo or test mode, returns a sample base64 string representing a batch photo.
    // Can be backed by package:image_picker when native camera plugin is attached.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return base64Encode(utf8.encode('AgroDex Batch Sample Image Data'));
  }
}

/// Provider for [ImagePickerService].
final imagePickerServiceProvider = Provider<ImagePickerService>((ref) {
  return DefaultImagePickerService();
});
