import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

enum AppPermission { camera, location, notification, storage }

class PermissionService {
  static const Map<AppPermission, Permission> _permissionMap = {
    AppPermission.camera: Permission.camera,
    AppPermission.location: Permission.locationWhenInUse,
    AppPermission.notification: Permission.notification,
    AppPermission.storage: Permission.storage,
  };

  static const Map<AppPermission, String> _permissionMessages = {
    AppPermission.camera:
        'Camera access is required to scan and recognize anime characters.',
    AppPermission.location:
        'Location access helps us provide location-based anime recommendations.',
    AppPermission.notification:
        'Notifications keep you updated about new anime releases and character discoveries.',
    AppPermission.storage:
        'Storage access is needed to save your favorite character images.',
  };

  /// Check if a specific permission is granted
  static Future<bool> isPermissionGranted(AppPermission permission) async {
    final status = await _permissionMap[permission]!.status;
    return status == PermissionStatus.granted;
  }

  /// Check if all essential permissions are granted
  static Future<bool> areEssentialPermissionsGranted() async {
    final cameraGranted = await isPermissionGranted(AppPermission.camera);
    return cameraGranted; // Camera is the only essential permission for core functionality
  }

  /// Check if all permissions are granted
  static Future<Map<AppPermission, bool>> checkAllPermissions() async {
    final Map<AppPermission, bool> results = {};

    for (final permission in AppPermission.values) {
      results[permission] = await isPermissionGranted(permission);
    }

    return results;
  }

  /// Request a specific permission
  static Future<PermissionStatus> requestPermission(
    AppPermission permission,
  ) async {
    return await _permissionMap[permission]!.request();
  }

  /// Request multiple permissions
  static Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<AppPermission> permissions,
  ) async {
    final permissionsToRequest = permissions
        .map((p) => _permissionMap[p]!)
        .toList();

    return await permissionsToRequest.request();
  }

  /// Request all app permissions
  static Future<Map<Permission, PermissionStatus>>
  requestAllPermissions() async {
    return await requestPermissions(AppPermission.values);
  }

  /// Get permission message for user
  static String getPermissionMessage(AppPermission permission) {
    return _permissionMessages[permission] ??
        'This permission is required for the app to function properly.';
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermissionPermanentlyDenied(
    AppPermission permission,
  ) async {
    final status = await _permissionMap[permission]!.status;
    return status == PermissionStatus.permanentlyDenied;
  }

  /// Open app settings
  static Future<bool> openAppSettings() async {
    try {
      return await openAppSettings();
    } catch (e) {
      debugPrint('Error opening app settings: $e');
      return false;
    }
  }

  /// Show permission rationale dialog
  static Future<bool?> showPermissionDialog(
    BuildContext context,
    AppPermission permission, {
    String? customMessage,
  }) async {
    final message = customMessage ?? getPermissionMessage(permission);

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Permission Required'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Deny'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Allow'),
            ),
          ],
        );
      },
    );
  }

  /// Show settings dialog for permanently denied permissions
  static Future<bool?> showSettingsDialog(
    BuildContext context,
    AppPermission permission,
  ) async {
    final permissionName = permission.name.toLowerCase();

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permission Denied'),
          content: Text(
            'The $permissionName permission has been permanently denied. '
            'Please enable it in the app settings to continue using this feature.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(true);
                await openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Handle permission request with proper flow
  static Future<bool> handlePermissionRequest(
    BuildContext context,
    AppPermission permission, {
    String? customMessage,
  }) async {
    // Check if already granted
    if (await isPermissionGranted(permission)) {
      return true;
    }

    // Check if permanently denied
    if (await isPermissionPermanentlyDenied(permission)) {
      final shouldOpenSettings = await showSettingsDialog(context, permission);
      return shouldOpenSettings == true;
    }

    // Show rationale dialog
    final shouldRequest = await showPermissionDialog(
      context,
      permission,
      customMessage: customMessage,
    );
    if (shouldRequest != true) {
      return false;
    }

    // Request permission
    final status = await requestPermission(permission);
    return status == PermissionStatus.granted;
  }

  /// Get permission status description
  static String getPermissionStatusDescription(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.limited:
        return 'Limited';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.provisional:
        return 'Provisional';
    }
  }
}
