import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class ImageHelper {
  static const int _targetWidth = 1024;
  static const int _targetQuality = 85;

  /// Compresses and resizes the image to safe dimensions.
  /// Returns a new [File] that is safe to display and upload.
  static Future<File?> compressImage(File file) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = '${dir.path}/${const Uuid().v4()}_compressed.jpg';

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: _targetQuality,
        minWidth: _targetWidth,
        minHeight: _targetWidth, // Maintain aspect ratio
      );

      return result != null ? File(result.path) : null;
    } catch (e) {
      // In case of error (e.g. format not supported), return original file or null based on strictness
      // Here we return null to be safe and avoid crashing Upload pipeline with bad files
      print('Error compressing image: $e');
      return null;
    }
  }
}
