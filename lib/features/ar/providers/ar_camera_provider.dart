import 'package:flutter_riverpod/flutter_riverpod.dart';

class ARDetectionState {
  final List<Map<String, dynamic>> detections;
  final bool isDetecting;
  final String? error;

  const ARDetectionState({
    this.detections = const [],
    this.isDetecting = false,
    this.error,
  });

  ARDetectionState copyWith({
    List<Map<String, dynamic>>? detections,
    bool? isDetecting,
    String? error,
  }) {
    return ARDetectionState(
      detections: detections ?? this.detections,
      isDetecting: isDetecting ?? this.isDetecting,
      error: error ?? this.error,
    );
  }
}

class ARDetectionNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  ARDetectionNotifier() : super([]);

  void addDetection(Map<String, dynamic> detection) {
    // Only keep the most recent 5 detections
    final newDetections = [detection, ...state];
    if (newDetections.length > 5) {
      newDetections.removeLast();
    }
    state = newDetections;
  }

  void clearDetections() {
    state = [];
  }

  void removeDetection(int index) {
    if (index >= 0 && index < state.length) {
      final newDetections = List<Map<String, dynamic>>.from(state);
      newDetections.removeAt(index);
      state = newDetections;
    }
  }
}

final arDetectionProvider =
    StateNotifierProvider<ARDetectionNotifier, List<Map<String, dynamic>>>((
      ref,
    ) {
      return ARDetectionNotifier();
    });
