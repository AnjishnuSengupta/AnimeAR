import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/auth_service.dart';
import '../models/app_user.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) async* {
  try {
    debugPrint('AuthProvider: Starting auth state stream');
    // Firebase should already be initialized by main.dart
    final authService = ref.read(authServiceProvider);
    await for (final user in authService.authStateChanges) {
      debugPrint(
        'AuthProvider: Auth state changed - User: ${user?.email ?? 'null'}',
      );
      yield user;
    }
  } catch (e) {
    debugPrint('AuthProvider: Error in auth state stream: $e');
    // If Firebase is not initialized, yield null (no user)
    yield null;
  }
});

final userProvider = StreamProvider<AppUser?>((ref) async* {
  final authState = ref.watch(authStateProvider);

  await for (final user
      in authState.asData?.value != null
          ? Stream.value(authState.asData!.value)
          : Stream.value(null)) {
    if (user != null) {
      final authService = ref.read(authServiceProvider);
      final appUser = await authService.getCurrentUser();
      yield appUser;
    } else {
      yield null;
    }
  }
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      return AuthController(ref.read(authServiceProvider));
    });

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  AuthController(this._authService) : super(const AsyncValue.data(null));

  Future<void> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signUpWithEmailAndPassword(email, password, name);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithGoogle();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    try {
      await _authService.signOut();
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> resetPassword(String email) async {
    state = const AsyncValue.loading();
    try {
      await _authService.sendPasswordResetEmail(email);
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}
