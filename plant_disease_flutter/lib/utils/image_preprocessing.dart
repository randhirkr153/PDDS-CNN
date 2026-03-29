import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Utility class for image preprocessing for TFLite inference.
class ImagePreprocessing {
  /// Prepares an image for EfficientNetB0 inference.
  /// - Decodes raw bytes.
  /// - Resizes to [targetSize] x [targetSize].
  /// - Converts to RGB (ignoring alpha).
  /// - Normalizes pixel values to [0.0, 1.0].
  /// - Returns a nested list matching the required Float32 tensor shape: [1, targetSize, targetSize, 3].
  static List<List<List<List<double>>>> preprocessImage(
      Uint8List imageBytes, int targetSize) {
    // 1. Decode image
    final originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) {
      throw Exception('Failed to decode image data.');
    }

    // 2. Resize to 224x224
    final resizedImage = img.copyResize(
      originalImage,
      width: targetSize,
      height: targetSize,
    );

    // 3. Convert to Float32 Tensor [1, 224, 224, 3] and normalize
    return List.generate(
      1,
      (_) => List.generate(
        targetSize,
        (y) => List.generate(
          targetSize,
          (x) {
            // Get pixel (Image library returns #AABBGGRR or similar depending on version; getPixel is safe)
            final pixel = resizedImage.getPixel(x, y);
            
            // 4. Normalize to [0, 1]
            return [
              pixel.r.toDouble(), // Red
              pixel.g.toDouble(), // Green
              pixel.b.toDouble(), // Blue
            ];
          },
        ),
      ),
    );
  }
}
