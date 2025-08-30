import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';

import '../../../core/services/permission_service.dart';
import '../../../core/services/camera_service.dart';

class CameraTestScreen extends ConsumerStatefulWidget {
  const CameraTestScreen({super.key});

  @override
  ConsumerState<CameraTestScreen> createState() => _CameraTestScreenState();
}

class _CameraTestScreenState extends ConsumerState<CameraTestScreen> {
  bool _hasPermission = false;
  bool _isInitialized = false;
  bool _isLoading = false;
  String _status = 'Checking permissions...';
  CameraController? _controller;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndInitialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _checkPermissionsAndInitialize() async {
    setState(() {
      _isLoading = true;
      _status = 'Checking camera permissions...';
    });

    try {
      // Check camera permission
      final hasPermission = await PermissionService.isPermissionGranted(
        AppPermission.camera,
      );

      setState(() {
        _hasPermission = hasPermission;
        _status = hasPermission
            ? 'Permission granted, initializing camera...'
            : 'Camera permission required';
      });

      if (!hasPermission) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Initialize camera
      setState(() {
        _status = 'Initializing camera...';
      });

      _controller = await CameraService.initializeCamera();

      setState(() {
        _isInitialized = true;
        _status = 'Camera ready!';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
        _isInitialized = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
      _status = 'Requesting camera permission...';
    });

    final granted = await PermissionService.handlePermissionRequest(
      context,
      AppPermission.camera,
    );

    if (granted) {
      await _checkPermissionsAndInitialize();
    } else {
      setState(() {
        _status = 'Camera permission denied';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Test'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[900],
            child: _buildCameraPreview(),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status: $_status',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatusInfo(),
                  const SizedBox(height: 16),
                  if (!_hasPermission)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _requestPermission,
                      child: const Text('Request Camera Permission'),
                    ),
                  if (_hasPermission && !_isInitialized && !_isLoading)
                    ElevatedButton(
                      onPressed: _checkPermissionsAndInitialize,
                      child: const Text('Initialize Camera'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 8),
            Text('Loading...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (!_hasPermission) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt, color: Colors.white, size: 48),
            SizedBox(height: 8),
            Text(
              'Camera Permission Required',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera, color: Colors.white, size: 48),
            SizedBox(height: 8),
            Text(
              'Camera Not Initialized',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return ClipRect(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: CameraPreview(_controller!),
      ),
    );
  }

  Widget _buildStatusInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Permission granted: $_hasPermission'),
        Text('Camera initialized: $_isInitialized'),
        Text('Loading: $_isLoading'),
        if (_controller != null) ...[
          Text('Camera info: ${CameraService.getCameraInfo()}'),
          Text('Multiple cameras: ${CameraService.hasMultipleCameras}'),
          Text('Front camera: ${CameraService.hasFrontCamera}'),
          Text('Back camera: ${CameraService.hasBackCamera}'),
        ],
      ],
    );
  }
}
