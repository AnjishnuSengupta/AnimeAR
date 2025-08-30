import 'package:go_router/go_router.dart';
import '../core/constants/app_constants.dart';
import '../core/widgets/splash_screen.dart';
import '../core/widgets/auth_wrapper.dart';
import '../core/widgets/app_startup_widget.dart';
import '../features/auth/screens/auth_screen.dart';
import '../core/widgets/main_navigation.dart';
import '../features/home/screens/home_screen.dart';
import '../features/ar/screens/ar_camera_screen.dart';
import '../features/ar/screens/camera_test_screen.dart';
import '../features/social/screens/social_screen.dart';
import '../features/profile/screens/profile_screen.dart';
import '../features/profile/screens/settings_screen.dart';
import '../features/profile/screens/collection_screen.dart';
import '../features/home/screens/character_detail_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: AppConstants.splashRoute,
    routes: [
      // Splash/startup route - handles initial app startup logic
      GoRoute(
        path: AppConstants.splashRoute,
        builder: (context, state) => const AppStartupWidget(),
      ),

      // Auth screen (no auth wrapper needed)
      GoRoute(
        path: AppConstants.authRoute,
        builder: (context, state) => const AuthScreen(),
      ),

      // Main navigation with shell route and auth wrapper
      ShellRoute(
        builder: (context, state, child) =>
            AuthWrapper(child: MainNavigation(child: child)),
        routes: [
          GoRoute(
            path: AppConstants.homeRoute,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppConstants.arCameraRoute,
            builder: (context, state) => const ARCameraScreen(),
          ),
          GoRoute(
            path: AppConstants.socialRoute,
            builder: (context, state) => const SocialScreen(),
          ),
          GoRoute(
            path: AppConstants.profileRoute,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // Additional screens with auth wrapper
      GoRoute(
        path: AppConstants.settingsRoute,
        builder: (context, state) => AuthWrapper(child: const SettingsScreen()),
      ),
      GoRoute(
        path: AppConstants.collectionRoute,
        builder: (context, state) =>
            AuthWrapper(child: const CollectionScreen()),
      ),
      GoRoute(
        path: '${AppConstants.characterDetailRoute}/:id',
        builder: (context, state) {
          final characterId = state.pathParameters['id']!;
          return AuthWrapper(
            child: CharacterDetailScreen(characterId: characterId),
          );
        },
      ),

      // Camera test screen (for development and testing)
      GoRoute(
        path: '/camera-test',
        builder: (context, state) => const CameraTestScreen(),
      ),
    ],
  );
}
