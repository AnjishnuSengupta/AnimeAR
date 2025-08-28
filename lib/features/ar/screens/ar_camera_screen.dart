import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:permission_handler/permission_handler.dart'; // Temporarily disabled

import '../providers/ar_camera_provider.dart';
import '../widgets/ar_overlay.dart';
import '../widgets/detection_result_card.dart';

class ARCameraScreen extends ConsumerStatefulWidget {
  const ARCameraScreen({super.key});

  @override
  ConsumerState<ARCameraScreen> createState() => _ARCameraScreenState();
}

class _ARCameraScreenState extends ConsumerState<ARCameraScreen> {
  bool _isCameraInitialized = false;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    // Simplified permission handling - assumes permissions are granted
    // In a production app, you would handle camera permissions here
    setState(() {
      _hasPermission = true;
      _isCameraInitialized = true;
    });

    // Simulate detection for demo
    if (_hasPermission) {
      _simulateDetection();
    }
  }

  void _simulateDetection() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        final mockResult = {
          'confidence': 0.85,
          'character': 'Naruto Uzumaki',
          'anime': 'Naruto',
          'bounds': [0.2, 0.3, 0.6, 0.7],
        };
        ref.read(arDetectionProvider.notifier).addDetection(mockResult);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final detections = ref.watch(arDetectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AR Camera'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.flash_auto), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.flip_camera_android),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildCameraPreview(),
          if (_isCameraInitialized) ...[
            AROverlay(detections: detections),
            _buildDetectionResults(detections),
          ],
          _buildControlsOverlay(),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (!_hasPermission) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, color: Colors.white, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Camera permission required',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPermissions,
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isCameraInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }

    // Placeholder camera preview
    return Container(
      color: Colors.black,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam, color: Colors.white, size: 100),
            SizedBox(height: 16),
            Text(
              'Camera Preview',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
            Text(
              '(Demo Mode)',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionResults(List<Map<String, dynamic>> detections) {
    if (detections.isEmpty) {
      return const SizedBox.shrink();
    }

    return Positioned(
      bottom: 100,
      left: 16,
      right: 16,
      child: SizedBox(
        height: 120,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: detections.length,
          itemBuilder: (context, index) {
            final detection = detections[index];
            return Padding(
              padding: EdgeInsets.only(
                right: index < detections.length - 1 ? 12 : 0,
              ),
              child: DetectionResultCard(
                character: detection['character'],
                anime: detection['anime'],
                confidence: detection['confidence'],
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${detection['character']} detected!'),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildControlsOverlay() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            heroTag: 'gallery',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Gallery feature coming soon!')),
              );
            },
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: const Icon(Icons.photo_library, color: Colors.white),
          ),
          FloatingActionButton.large(
            heroTag: 'capture',
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Image captured!')));
            },
            backgroundColor: Colors.white,
            child: Icon(
              Icons.camera_alt,
              color: Theme.of(context).colorScheme.primary,
              size: 32,
            ),
          ),
          FloatingActionButton(
            heroTag: 'settings',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AR settings coming soon!')),
              );
            },
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
