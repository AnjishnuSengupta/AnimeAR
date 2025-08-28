import 'package:flutter/material.dart';

class AROverlay extends StatelessWidget {
  final List<Map<String, dynamic>> detections;

  const AROverlay({super.key, required this.detections});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Detection bounding boxes
        ...detections.map((detection) => _buildBoundingBox(context, detection)),

        // AR UI Elements
        _buildARInstructions(context),
        _buildDetectionCounter(context),
      ],
    );
  }

  Widget _buildBoundingBox(
    BuildContext context,
    Map<String, dynamic> detection,
  ) {
    final bounds = detection['bounds'] as List<double>?;
    if (bounds == null || bounds.length != 4) return const SizedBox.shrink();

    final screenSize = MediaQuery.of(context).size;
    final x = bounds[0] * screenSize.width;
    final y = bounds[1] * screenSize.height;
    final width = bounds[2] * screenSize.width;
    final height = bounds[3] * screenSize.height;

    return Positioned(
      left: x,
      top: y,
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Character name label
            Positioned(
              top: -30,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  detection['character'] ?? 'Unknown',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Confidence indicator
            Positioned(
              bottom: -20,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${((detection['confidence'] ?? 0.0) * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildARInstructions(BuildContext context) {
    return Positioned(
      top: 60,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.camera_alt,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Point camera at anime characters to detect them',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionCounter(BuildContext context) {
    if (detections.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 120,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '${detections.length} detected',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
