import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/permission_service.dart';
import '../providers/ar_camera_provider.dart';
import '../widgets/ar_overlay.dart';
import '../widgets/detection_result_card.dart';

class ARCameraScreen extends ConsumerStatefulWidget {
  const ARCameraScreen({super.key});

  @override
  ConsumerState<ARCameraScreen> createState() => _ARCameraScreenState();
}

class _ARCameraScreenState extends ConsumerState<ARCameraScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _hasPermission = false;
  bool _isLoading = false;
  FlashMode _flashMode = FlashMode.auto;
  List<CameraDescription> _cameras = [];
  int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check camera permission
      final hasPermission = await PermissionService.isPermissionGranted(
        AppPermission.camera,
      );

      if (!hasPermission) {
        // Request permission
        final granted = await PermissionService.handlePermissionRequest(
          context,
          AppPermission.camera,
        );

        if (!granted) {
          setState(() {
            _hasPermission = false;
            _isLoading = false;
          });
          return;
        }
      }

      setState(() {
        _hasPermission = true;
      });

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        throw Exception('No cameras available on this device');
      }

      // Initialize camera controller
      _cameraController = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isLoading = false;
        });

        // Simulate detection for demo
        _simulateDetection();
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _hasPermission = false;
          _isCameraInitialized = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Camera error: ${e.toString()}'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Go Home',
              onPressed: () => context.go('/home'),
            ),
          ),
        );
      }
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _cameraController?.dispose();

      _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras.length;

      _cameraController = CameraController(
        _cameras[_selectedCameraIndex],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error switching camera: $e');
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to switch camera: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      switch (_flashMode) {
        case FlashMode.off:
          _flashMode = FlashMode.auto;
          break;
        case FlashMode.auto:
          _flashMode = FlashMode.always;
          break;
        case FlashMode.always:
          _flashMode = FlashMode.torch;
          break;
        case FlashMode.torch:
          _flashMode = FlashMode.off;
          break;
      }

      await _cameraController!.setFlashMode(_flashMode);
      setState(() {});
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  IconData _getFlashIconData() {
    switch (_flashMode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.torch:
        return Icons.highlight;
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
          IconButton(icon: Icon(_getFlashIconData()), onPressed: _toggleFlash),
          if (_cameras.length > 1)
            IconButton(
              icon: const Icon(Icons.flip_camera_android),
              onPressed: _switchCamera,
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
                onPressed: _initializeCamera,
                child: const Text('Grant Permission'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text(
                  'Go to Home',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading || !_isCameraInitialized || _cameraController == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'Initializing camera...',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text(
                  'Go to Home',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Real camera preview with error boundary
    try {
      return ClipRect(
        child: AspectRatio(
          aspectRatio: _cameraController!.value.aspectRatio,
          child: CameraPreview(_cameraController!),
        ),
      );
    } catch (e) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                'Camera Error: ${e.toString()}',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initializeCamera,
                child: const Text('Retry'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text(
                  'Go to Home',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }
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
