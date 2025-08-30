import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class CameraService {
  static CameraController? _controller;
  static bool _isInitialized = false;
  static List<CameraDescription> _cameras = [];

  /// Initialize cameras
  static Future<void> initializeCameras() async {
    if (_cameras.isEmpty) {
      try {
        _cameras = await availableCameras();
      } catch (e) {
        debugPrint('Error initializing cameras: $e');
        throw CameraException(
          'camera_init_failed',
          'Failed to initialize cameras',
        );
      }
    }
  }

  /// Get available cameras
  static List<CameraDescription> get cameras => _cameras;

  /// Get current camera controller
  static CameraController? get controller => _controller;

  /// Check if camera is initialized
  static bool get isInitialized => _isInitialized;

  /// Initialize camera with specific camera (default: back camera)
  static Future<CameraController> initializeCamera({
    CameraDescription? camera,
    ResolutionPreset resolution = ResolutionPreset.high,
    bool enableAudio = false,
  }) async {
    // Ensure cameras are loaded
    if (_cameras.isEmpty) {
      await initializeCameras();
    }

    if (_cameras.isEmpty) {
      throw CameraException(
        'no_cameras',
        'No cameras available on this device',
      );
    }

    // Select camera (default to back camera)
    final selectedCamera =
        camera ??
        _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );

    // Dispose existing controller if any
    await _disposeController();

    try {
      // Create new controller
      _controller = CameraController(
        selectedCamera,
        resolution,
        enableAudio: enableAudio,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      // Initialize controller
      await _controller!.initialize();
      _isInitialized = true;

      debugPrint('Camera initialized successfully');
      return _controller!;
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  /// Switch camera (front/back)
  static Future<CameraController?> switchCamera() async {
    if (_controller == null || _cameras.length < 2) {
      return _controller;
    }

    final currentCamera = _controller!.description;
    final newCamera = _cameras.firstWhere(
      (camera) => camera.lensDirection != currentCamera.lensDirection,
      orElse: () => currentCamera,
    );

    if (newCamera == currentCamera) {
      return _controller; // No other camera available
    }

    try {
      return await initializeCamera(camera: newCamera);
    } catch (e) {
      debugPrint('Error switching camera: $e');
      return _controller;
    }
  }

  /// Set flash mode
  static Future<void> setFlashMode(FlashMode mode) async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.setFlashMode(mode);
      } catch (e) {
        debugPrint('Error setting flash mode: $e');
      }
    }
  }

  /// Get current flash mode
  static FlashMode get flashMode {
    return _controller?.value.flashMode ?? FlashMode.auto;
  }

  /// Cycle through flash modes
  static Future<FlashMode> cycleFlashMode() async {
    final currentMode = flashMode;
    FlashMode nextMode;

    switch (currentMode) {
      case FlashMode.off:
        nextMode = FlashMode.auto;
        break;
      case FlashMode.auto:
        nextMode = FlashMode.always;
        break;
      case FlashMode.always:
        nextMode = FlashMode.torch;
        break;
      case FlashMode.torch:
        nextMode = FlashMode.off;
        break;
    }

    await setFlashMode(nextMode);
    return nextMode;
  }

  /// Set zoom level (0.0 to 1.0)
  static Future<void> setZoomLevel(double zoom) async {
    if (_controller != null && _isInitialized) {
      try {
        final clampedZoom = zoom.clamp(0.0, 1.0);
        await _controller!.setZoomLevel(clampedZoom);
      } catch (e) {
        debugPrint('Error setting zoom level: $e');
      }
    }
  }

  /// Set exposure offset
  static Future<void> setExposureOffset(double offset) async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.setExposureOffset(offset);
      } catch (e) {
        debugPrint('Error setting exposure offset: $e');
      }
    }
  }

  /// Take a picture
  static Future<XFile?> takePicture() async {
    if (_controller == null || !_isInitialized) {
      throw CameraException('camera_not_initialized', 'Camera not initialized');
    }

    try {
      final image = await _controller!.takePicture();
      return image;
    } catch (e) {
      debugPrint('Error taking picture: $e');
      rethrow;
    }
  }

  /// Start image stream for real-time processing
  static Future<void> startImageStream(
    Function(CameraImage) onImageAvailable,
  ) async {
    if (_controller == null || !_isInitialized) {
      throw CameraException('camera_not_initialized', 'Camera not initialized');
    }

    try {
      await _controller!.startImageStream(onImageAvailable);
    } catch (e) {
      debugPrint('Error starting image stream: $e');
      rethrow;
    }
  }

  /// Stop image stream
  static Future<void> stopImageStream() async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.stopImageStream();
      } catch (e) {
        debugPrint('Error stopping image stream: $e');
      }
    }
  }

  /// Focus on a specific point
  static Future<void> focusOnPoint(Offset point) async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.setFocusPoint(point);
        await _controller!.setExposurePoint(point);
      } catch (e) {
        debugPrint('Error setting focus point: $e');
      }
    }
  }

  /// Dispose camera controller
  static Future<void> _disposeController() async {
    if (_controller != null) {
      try {
        if (_controller!.value.isStreamingImages) {
          await _controller!.stopImageStream();
        }
        await _controller!.dispose();
      } catch (e) {
        debugPrint('Error disposing camera controller: $e');
      } finally {
        _controller = null;
        _isInitialized = false;
      }
    }
  }

  /// Dispose all camera resources
  static Future<void> dispose() async {
    await _disposeController();
  }

  /// Check if device has multiple cameras
  static bool get hasMultipleCameras => _cameras.length > 1;

  /// Check if device has front camera
  static bool get hasFrontCamera => _cameras.any(
    (camera) => camera.lensDirection == CameraLensDirection.front,
  );

  /// Check if device has back camera
  static bool get hasBackCamera => _cameras.any(
    (camera) => camera.lensDirection == CameraLensDirection.back,
  );

  /// Get camera info string
  static String getCameraInfo() {
    if (_controller == null) return 'No camera initialized';

    final camera = _controller!.description;
    return '${camera.name} (${camera.lensDirection.name})';
  }

  /// Handle camera errors
  static String getCameraErrorMessage(CameraException error) {
    switch (error.code) {
      case 'camera_access_denied':
        return 'Camera access denied. Please grant camera permission.';
      case 'camera_access_denied_without_prompt':
        return 'Camera access denied. Please enable camera permission in settings.';
      case 'camera_access_restricted':
        return 'Camera access is restricted on this device.';
      case 'audio_access_denied':
        return 'Audio access denied.';
      case 'audio_access_denied_without_prompt':
        return 'Audio access denied. Please enable microphone permission in settings.';
      case 'audio_access_restricted':
        return 'Audio access is restricted on this device.';
      default:
        return error.description ?? 'An unknown camera error occurred.';
    }
  }

  /// Lock capture orientation
  static Future<void> lockCaptureOrientation() async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.lockCaptureOrientation();
      } catch (e) {
        debugPrint('Error locking capture orientation: $e');
      }
    }
  }

  /// Unlock capture orientation
  static Future<void> unlockCaptureOrientation() async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.unlockCaptureOrientation();
      } catch (e) {
        debugPrint('Error unlocking capture orientation: $e');
      }
    }
  }

  /// Pause camera preview
  static Future<void> pausePreview() async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.pausePreview();
      } catch (e) {
        debugPrint('Error pausing preview: $e');
      }
    }
  }

  /// Resume camera preview
  static Future<void> resumePreview() async {
    if (_controller != null && _isInitialized) {
      try {
        await _controller!.resumePreview();
      } catch (e) {
        debugPrint('Error resuming preview: $e');
      }
    }
  }
}
