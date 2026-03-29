import 'package:flutter/material.dart';
import '../services/disease_repository.dart';

/// A reusable dialog widget that displays disease symptoms and management info.
class DiseaseDetailDialog extends StatelessWidget {
  final DiseaseInfo disease;

  const DiseaseDetailDialog({super.key, required this.disease});

  /// Convenience method to show this dialog.
  static void show(BuildContext context, DiseaseInfo disease) {
    showDialog(
      context: context,
      builder: (_) => DiseaseDetailDialog(disease: disease),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Disease Name Header
              Center(
                child: Text(
                  disease.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Symptoms
              const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Symptoms',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(disease.symptoms, style: const TextStyle(fontSize: 15, height: 1.4)),
              const SizedBox(height: 16),

              // Management
              const Row(
                children: [
                  Icon(Icons.local_florist, color: Color(0xFF2E7D32), size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Management',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF2E7D32)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(disease.management, style: const TextStyle(fontSize: 15, height: 1.4)),
              const SizedBox(height: 20),

              // Close Button
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
