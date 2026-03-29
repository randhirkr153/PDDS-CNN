import 'dart:io';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../models/prediction_result.dart';
import '../utils/image_preprocessing.dart';

class ModelService {
  static const String _tag = '[ModelService]';
  static const int _inputSize = 224;
  static const String _modelPath = 'assets/model.tflite';
  static const String _labelPath = 'assets/labels.txt';

  late Interpreter _interpreter;
  late List<String> _labels;
  bool _isReady = false;

  bool get isReady => _isReady;

  /// Initializes the TFLite interpreter and loads class labels.
  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      await _loadLabels();
      _isReady = true;
      _log('Successfully initialized interpreter and labels.');
    } catch (e) {
      _log('Failed to initialize ModelService: $e');
      rethrow;
    }
  }

  Future<void> _loadLabels() async {
    final raw = await rootBundle.loadString(_labelPath);
    _labels = raw
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();
    _log('Loaded ${_labels.length} labels from assets.');
  }

  Future<PredictionResult?> runModel(File imageFile) async {
    if (!_isReady) {
      throw Exception('ModelService used before initialization.');
    }

    try {
      _log('--- STARTING INFERENCE ---');
      final bytes = await imageFile.readAsBytes();
      _log('Image loaded. Size: ${bytes.length} bytes.');

      // 1-3. Load, Resize, Normalize, and Convert to Tensor
      final inputTensor =
          ImagePreprocessing.preprocessImage(bytes, _inputSize);
      _log('Image preprocessed to $_inputSize x $_inputSize.');

      // DEBUG: Log sample pixel values
      try {
        final samplePixel = inputTensor[0][0][0];
        _log('Sample Pixel (0,0): R=${samplePixel[0]}, G=${samplePixel[1]}, B=${samplePixel[2]}');
      } catch (e) {
        _log('Failed to log sample pixel: $e');
      }

      // Setup output tensor of shape [1, 38]
      final outputTensor =
          List.generate(1, (_) => List.filled(_labels.length, 0.0));

      // 4. Run interpreter
      _log('Running TFLite interpreter...');
      _interpreter.run(inputTensor, outputTensor);
      _log('TFLite interpreter finished processing.');

      // 5. Get output tensor probabilities
      final probabilities = outputTensor[0];
      
      // Let's print out the top 5 raw predictions for debugging!
      try {
         final tempProbs = List<double>.from(probabilities);
         final tempLabels = List<String>.from(_labels);
         _log('--- TOP 5 RAW PREDICTIONS ---');
         for(int k=0; k<5; k++) {
            var mIdx = 0;
            var mProb = tempProbs[0];
            for(int i=1; i<tempProbs.length; i++) {
               if(tempProbs[i] > mProb) {
                 mProb = tempProbs[i];
                 mIdx = i;
               }
            }
            if(mProb > 0) {
               _log('${k+1}: [${mProb.toStringAsFixed(4)}] ${tempLabels[mIdx]}');
            }
            tempProbs[mIdx] = -1.0; // remove from next iteration
         }
         _log('---------------------------');
      } catch (e) {
         _log('Could not print raw top 5: $e');
      }

      int maxIdx = 0;
      double maxProb = probabilities[0];

      // 6. Compute highest probability
      for (int i = 1; i < probabilities.length; i++) {
        if (probabilities[i] > maxProb) {
          maxProb = probabilities[i];
          maxIdx = i;
        }
      }

      final mappedLabel = _labels[maxIdx];
      _log('FINAL RESULT: $mappedLabel with confidence $maxProb');

      // 7. Map to label and return struct
      return PredictionResult(
        label: mappedLabel,
        confidence: maxProb,
      );
    } catch (e, st) {
      _log('Error during inference pipeline: $e\n$st');
      return null;
    }
  }

  void dispose() {
    if (_isReady) {
      _interpreter.close();
      _isReady = false;
      _log('Interpreter successfully disposed.');
    }
  }

  void _log(String msg) {
    // ignore: avoid_print
    print('$_tag $msg');
  }
}
