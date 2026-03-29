
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// Encapsulates TFLite model loading, image preprocessing, and inference.
///
/// Designed to be initialized once and reused across the app lifecycle.
class ClassifierService {
  static const String _tag = '[ClassifierService]';
  static const int inputSize = 200;
  static const String _modelPath = 'assets/model.tflite';
  static const String _labelPath = 'assets/labels.txt';

  Interpreter? _interpreter;
  List<String> _labels = [];

  bool get isReady => _interpreter != null && _labels.isNotEmpty;
  List<String> get labels => _labels;

  /// Loads the TFLite model and class labels from assets.
  /// Throws [Exception] if critical assets fail to load.
  Future<void> initialize() async {
    await _loadModel();
    await _loadLabels();
    if (!isReady) {
      throw Exception('$_tag Failed to initialize: model or labels missing.');
    }
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _log('Model loaded successfully.');
    } catch (e) {
      _log('CRITICAL — Failed to load model: $e');
      rethrow;
    }
  }

  Future<void> _loadLabels() async {
    try {
      final raw = await rootBundle.loadString(_labelPath);
      _labels = raw
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
      _log('Loaded ${_labels.length} labels.');
    } catch (e) {
      _log('CRITICAL — Failed to load labels: $e');
      rethrow;
    }
  }

  /// Runs inference on raw image bytes.
  ///
  /// Returns a [ClassificationResult] containing the predicted label
  /// and its softmax probability. Returns `null` if inference fails.
  Future<ClassificationResult?> classify(Uint8List imageBytes) async {
    if (!isReady) {
      _log('classify() called before initialization.');
      return null;
    }

    try {
      // Decode and resize
      final original = img.decodeImage(imageBytes);
      if (original == null) {
        _log('Failed to decode image.');
        return null;
      }
      final resized = img.copyResize(original, width: inputSize, height: inputSize);

      // Build input tensor as a pre-allocated nested list (Float32)
      // Shape: [1, 200, 200, 3], normalized to [0.0, 1.0]
      final input = List.generate(
        1,
        (_) => List.generate(
          inputSize,
          (y) => List.generate(inputSize, (x) {
            final p = resized.getPixel(x, y);
            return [p.r / 255.0, p.g / 255.0, p.b / 255.0];
          }),
        ),
      );

      // Output tensor: [1, numClasses]
      final output = List.generate(1, (_) => List.filled(_labels.length, 0.0));

      _interpreter!.run(input, output);

      // Find argmax — model already applies softmax
      final probs = output[0];
      int bestIdx = 0;
      for (int i = 1; i < probs.length; i++) {
        if (probs[i] > probs[bestIdx]) bestIdx = i;
      }

      return ClassificationResult(
        label: _labels[bestIdx],
        confidence: probs[bestIdx],
      );
    } catch (e, st) {
      _log('Inference error: $e\n$st');
      return null;
    }
  }

  /// Releases the interpreter's native resources.
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _log('Interpreter disposed.');
  }

  void _log(String msg) {
    // Use print in debug; in production replace with a logging framework.
    // ignore: avoid_print
    print('$_tag $msg');
  }
}

/// Immutable result of a single classification.
class ClassificationResult {
  final String label;
  final double confidence;

  const ClassificationResult({
    required this.label,
    required this.confidence,
  });

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
}
