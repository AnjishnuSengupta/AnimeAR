import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../services/permission_service.dart';
import '../constants/app_constants.dart';
import '../../features/permissions/screens/permission_screen.dart';

final appInitializationProvider = FutureProvider<bool>((ref) async {
  // Check if this is the first app launch
  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  if (isFirstLaunch) {
    return false; // Show permission screen
  }

  // Check if essential permissions are still granted
  final essentialGranted =
      await PermissionService.areEssentialPermissionsGranted();
  return essentialGranted;
});

class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialization = ref.watch(appInitializationProvider);

    return initialization.when(
      data: (hasPermissions) {
        if (!hasPermissions) {
          return PermissionScreen(
            onPermissionsGranted: () async {
              // Mark first launch as complete
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isFirstLaunch', false);

              // Navigate to home screen after permissions are granted
              if (context.mounted) {
                context.go(AppConstants.homeRoute);
              }
            },
          );
        }

        // Permissions granted, navigate to home
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go(AppConstants.homeRoute);
          }
        });

        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading AnimeAR...'),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Initializing AnimeAR...'),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(appInitializationProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
