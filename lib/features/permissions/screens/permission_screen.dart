import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/permission_service.dart';

class PermissionScreen extends ConsumerStatefulWidget {
  final VoidCallback onPermissionsGranted;

  const PermissionScreen({super.key, required this.onPermissionsGranted});

  @override
  ConsumerState<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends ConsumerState<PermissionScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final Map<AppPermission, bool> _permissionStatus = {
    AppPermission.camera: false,
    AppPermission.location: false,
    AppPermission.notification: false,
    AppPermission.storage: false,
  };

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _checkCurrentPermissions();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkCurrentPermissions() async {
    final permissions = await PermissionService.checkAllPermissions();
    setState(() {
      _permissionStatus.addAll(permissions);
    });
  }

  Future<void> _requestPermission(AppPermission permission) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final granted = await PermissionService.handlePermissionRequest(
        context,
        permission,
      );

      setState(() {
        _permissionStatus[permission] = granted;
      });

      // Check if essential permissions are granted
      if (_permissionStatus[AppPermission.camera] == true) {
        _checkIfCanProceed();
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _requestAllPermissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Request permissions one by one for better UX
      for (final permission in AppPermission.values) {
        if (!_permissionStatus[permission]!) {
          final granted = await PermissionService.handlePermissionRequest(
            context,
            permission,
          );
          setState(() {
            _permissionStatus[permission] = granted;
          });
        }
      }

      _checkIfCanProceed();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _checkIfCanProceed() {
    // Check if essential permissions (camera) are granted
    if (_permissionStatus[AppPermission.camera] == true) {
      widget.onPermissionsGranted();
    }
  }

  void _skipOptionalPermissions() {
    // Only proceed if camera permission is granted
    if (_permissionStatus[AppPermission.camera] == true) {
      widget.onPermissionsGranted();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera permission is required to use AnimeAR'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF6C5CE7), // Primary color
              const Color(0xFF6C5CE7).withOpacity(0.8),
              const Color(0xFF0D0E1B), // Background color
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  Expanded(child: _buildPermissionsList()),
                  const SizedBox(height: 24),
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.camera_alt_rounded,
            size: 50,
            color: Color(0xFF6C5CE7), // Primary color
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Welcome to AnimeAR',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'To get started, we need some permissions to provide you with the best AR experience',
          style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.9)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPermissionsList() {
    return ListView(
      children: [
        _buildPermissionCard(
          AppPermission.camera,
          Icons.camera_alt_rounded,
          'Camera',
          'Required for AR character recognition',
          isRequired: true,
        ),
        const SizedBox(height: 12),
        _buildPermissionCard(
          AppPermission.location,
          Icons.location_on_rounded,
          'Location',
          'For location-based recommendations',
          isRequired: false,
        ),
        const SizedBox(height: 12),
        _buildPermissionCard(
          AppPermission.notification,
          Icons.notifications_rounded,
          'Notifications',
          'Stay updated with new anime releases',
          isRequired: false,
        ),
        const SizedBox(height: 12),
        _buildPermissionCard(
          AppPermission.storage,
          Icons.storage_rounded,
          'Storage',
          'Save your favorite character images',
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildPermissionCard(
    AppPermission permission,
    IconData icon,
    String title,
    String description, {
    bool isRequired = false,
  }) {
    final isGranted = _permissionStatus[permission] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted
              ? Colors.green
              : isRequired
              ? Colors.orange
              : Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isGranted
                  ? Colors.green.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isGranted ? Colors.green : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _isLoading ? null : () => _requestPermission(permission),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isGranted ? Colors.green : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      isGranted ? Icons.check : Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final cameraGranted = _permissionStatus[AppPermission.camera] ?? false;
    final allOptionalGranted = _permissionStatus.entries
        .where((e) => e.key != AppPermission.camera)
        .every((e) => e.value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _requestAllPermissions,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF6C5CE7), // Primary color
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isLoading
              ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6C5CE7), // Primary color
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('Requesting Permissions...'),
                  ],
                )
              : const Text(
                  'Allow All Permissions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
        if (cameraGranted) ...[
          const SizedBox(height: 12),
          TextButton(
            onPressed: _skipOptionalPermissions,
            child: Text(
              allOptionalGranted
                  ? 'Continue to App'
                  : 'Skip Optional Permissions',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
