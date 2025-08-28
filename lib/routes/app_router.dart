import 'package:go_router/go_router.dart';
import '../core/widgets/splash_screen.dart';
import '../core/widgets/auth_wrapper.dart';
import '../features/auth/screens/auth_screen.dart';
import '../core/widgets/main_navigation.dart';
import '../features/home/screens/home_screen.dart';
import '../features/ar/screens/ar_camera_screen.dart';
import '../features/social/screens/social_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/settings_screen.dart';
import '../features/profile/screens/collection_screen.dart';
import '../features/home/screens/character_detail_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/home',
    routes: [
      // Splash screen
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth screen (no auth wrapper needed)
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),

      // Main navigation with shell route and auth wrapper
      ShellRoute(
        builder: (context, state, child) =>
            AuthWrapper(child: MainNavigation(child: child)),
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/ar',
            builder: (context, state) => const ARCameraScreen(),
          ),
          GoRoute(
            path: '/social',
            builder: (context, state) => const SocialScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Additional screens with auth wrapper
      GoRoute(
        path: '/settings',
        builder: (context, state) => AuthWrapper(child: const SettingsScreen()),
      ),
      GoRoute(
        path: '/collection',
        builder: (context, state) =>
            AuthWrapper(child: const CollectionScreen()),
      ),
      GoRoute(
        path: '/character/:id',
        builder: (context, state) {
          final characterId = state.pathParameters['id']!;
          return AuthWrapper(
            child: CharacterDetailScreen(characterId: characterId),
          );
        },
      ),
    ],
  );
}
