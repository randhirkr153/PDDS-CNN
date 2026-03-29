import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads and queries the plant disease JSON knowledge base.
///
/// Provides case-insensitive, trim-safe disease lookups.
class DiseaseRepository {
  static const String _tag = '[DiseaseRepository]';
  static const String _dataPath = 'assets/data.json';

  /// Pre-indexed map: lowercased disease name → {symptoms, management}
  final Map<String, DiseaseInfo> _index = {};

  bool get isReady => _index.isNotEmpty;

  /// Loads `data.json` and builds a lookup index.
  Future<void> initialize() async {
    try {
      final raw = await rootBundle.loadString(_dataPath);
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final diseases = json['plant_disease'] as List<dynamic>? ?? [];

      for (final d in diseases) {
        final name = (d['name'] as String?)?.toLowerCase().trim() ?? '';
        if (name.isEmpty) continue;
        _index[name] = DiseaseInfo(
          name: d['name'] as String? ?? '',
          symptoms: d['symptoms'] as String? ?? 'No symptom data available.',
          management: d['management'] as String? ?? 'No management data available.',
        );
      }
      _log('Indexed ${_index.length} diseases.');
    } catch (e) {
      _log('Failed to load disease data: $e');
      rethrow;
    }
  }

  /// Looks up a disease by name (case-insensitive).
  /// Returns `null` if not found.
  DiseaseInfo? lookup(String diseaseName) {
    return _index[diseaseName.toLowerCase().trim()];
  }

  void _log(String msg) {
    // ignore: avoid_print
    print('$_tag $msg');
  }
}

/// Immutable data class for a single disease entry.
class DiseaseInfo {
  final String name;
  final String symptoms;
  final String management;

  const DiseaseInfo({
    required this.name,
    required this.symptoms,
    required this.management,
  });
}
