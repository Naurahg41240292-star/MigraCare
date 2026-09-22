import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Hasil prediksi yang siap ditampilkan ke UI
class ScreeningResult {
  final String label;          // nama tipe migrain
  final double confidence;     // 0.0 - 1.0
  final List<MapEntry<String, double>> probabilities; // semua kelas, terurut

  ScreeningResult({
    required this.label,
    required this.confidence,
    required this.probabilities,
  });
}

/// Singleton — model cukup dimuat sekali
class ScreeningService {
  ScreeningService._();
  static final ScreeningService instance = ScreeningService._();

  Interpreter? _interpreter;
  List<double> _min = [];
  List<double> _max = [];
  Map<String, String> _labels = {};

  bool get isLoaded => _interpreter != null;

  Future<void> ensureLoaded() async {
    if (isLoaded) return;

    // 1. Muat metadata (mapping label + min/max scaling)
    final raw = await rootBundle.loadString('assets/images/model_metadata.json');
    final meta = jsonDecode(raw);
    _min = (meta['scaler_min'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    _max = (meta['scaler_max'] as List)
        .map((e) => (e as num).toDouble())
        .toList();
    _labels = (meta['label_mapping'] as Map)
        .map((k, v) => MapEntry(k.toString(), v.toString()));

    // 2. Muat model TFLite
    _interpreter = await Interpreter.fromAsset('assets/images/model_migrain.tflite');
  }

  /// Input: 23 fitur MENTAH (urutan WAJIB sama dengan kolom CSV!)
  ScreeningResult predict(List<double> features) {
    if (!isLoaded) throw StateError('Model belum dimuat');
    if (features.length != 23) {
      throw ArgumentError('Fitur harus 23, dapat ${features.length}');
    }

    // Min-max scaling — SAMA seperti MinMaxScaler di Colab
    final scaled = List<double>.generate(23, (i) {
      final range = _max[i] - _min[i];
      return range == 0 ? 0.0 : (features[i] - _min[i]) / range;
    });

    // Inferensi — shape input [1, 23], output [1, 7]
    final input = [scaled];
    final output = [List<double>.filled(_labels.length, 0.0)];
    _interpreter!.run(input, output);

    // Argmax: cari kelas dengan probabilitas tertinggi
    final probs = output[0];
    int best = 0;
    for (int i = 1; i < probs.length; i++) {
      if (probs[i] > probs[best]) best = i;
    }

    // Urutkan semua probabilitas (untuk ditampilkan di halaman hasil)
    final all = <MapEntry<String, double>>[
      for (int i = 0; i < probs.length; i++)
        MapEntry(_labels[i.toString()] ?? 'Kelas $i', probs[i]),
    ]..sort((a, b) => b.value.compareTo(a.value));

    return ScreeningResult(
      label: _labels[best.toString()] ?? 'Tidak dikenal',
      confidence: probs[best],
      probabilities: all,
    );
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}