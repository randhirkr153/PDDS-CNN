class PredictionResult {
  final String label;
  final double confidence;

  const PredictionResult({
    required this.label,
    required this.confidence,
  });

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';
}
