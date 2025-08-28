import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/providers/auth_provider.dart';
import 'splash_screen.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AuthWrapper({super.key, required this.child});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // User is not authenticated, redirect to auth
          if (!_hasNavigated) {
            _hasNavigated = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.go('/auth');
              }
            });
          }
          return const SplashScreen();
        }
        // User is authenticated, show the requested page
        _hasNavigated = false;
        return widget.child;
      },
      loading: () => const SplashScreen(),
      error: (error, stackTrace) {
        debugPrint('AuthWrapper: Error in auth state: $error');
        // On error, redirect to auth
        if (!_hasNavigated) {
          _hasNavigated = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              context.go('/auth');
            }
          });
        }
        return const SplashScreen();
      },
    );
  }
}
