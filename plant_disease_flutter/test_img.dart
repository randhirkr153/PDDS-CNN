import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // Create a tiny 3x3 red image manually
  final image = img.Image(width: 3, height: 3, numChannels: 3);
  for (final p in image) {
    p.r = 255;
    p.g = 0;
    p.b = 0;
  }
  
  // Encode to png bytes
  final bytes = img.encodePng(image);
  
  // Rerun preprocessing step 1
  final decoded = img.decodeImage(bytes)!;
  final resized = img.copyResize(decoded, width: 3, height: 3);
  
  // Show pixel 0,0 float values
  final pixel = resized.getPixel(0, 0);
  
  print('Decoded Pixel raw: r=${pixel.r}, g=${pixel.g}, b=${pixel.b}');
  print('Float calc: R: ${pixel.r.toDouble() / 255.0}, G: ${pixel.g.toDouble() / 255.0}, B: ${pixel.b.toDouble() / 255.0}');
}
