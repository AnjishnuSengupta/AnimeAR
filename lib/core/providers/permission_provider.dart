import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/permission_service.dart';

// Provider to check if essential permissions are granted
final essentialPermissionsProvider = FutureProvider<bool>((ref) async {
  return await PermissionService.areEssentialPermissionsGranted();
});

// Provider to check all permission statuses
final allPermissionsProvider = FutureProvider<Map<AppPermission, bool>>((
  ref,
) async {
  return await PermissionService.checkAllPermissions();
});

// Provider to manage permission request state
class PermissionNotifier extends StateNotifier<bool> {
  PermissionNotifier() : super(false);

  Future<bool> requestPermission(AppPermission permission) async {
    state = true; // Loading
    try {
      final status = await PermissionService.requestPermission(permission);
      return status == PermissionStatus.granted;
    } finally {
      state = false; // Not loading
    }
  }

  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    state = true; // Loading
    try {
      return await PermissionService.requestAllPermissions();
    } finally {
      state = false; // Not loading
    }
  }
}

final permissionNotifierProvider =
    StateNotifierProvider<PermissionNotifier, bool>((ref) {
      return PermissionNotifier();
    });

// Convenience provider to refresh permission checks
final refreshPermissionsProvider = Provider<void>((ref) {
  ref.invalidate(essentialPermissionsProvider);
  ref.invalidate(allPermissionsProvider);
});
