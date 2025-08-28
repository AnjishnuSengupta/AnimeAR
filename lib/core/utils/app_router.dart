import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../../features/auth/screens/auth_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/ar/screens/ar_camera_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/social/screens/social_screen.dart';
import '../../features/home/screens/character_detail_screen.dart';
import '../../features/profile/screens/settings_screen.dart';
import '../../features/profile/screens/collection_screen.dart';
import '../widgets/splash_screen.dart';
import '../widgets/main_navigation.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.splashRoute,
    routes: [
      GoRoute(
        path: AppConstants.splashRoute,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.authRoute,
        builder: (context, state) => const AuthScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainNavigation(child: child),
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
      GoRoute(
        path: '${AppConstants.characterDetailRoute}/:characterId',
        builder: (context, state) {
          final characterId = state.pathParameters['characterId']!;
          return CharacterDetailScreen(characterId: characterId);
        },
      ),
      GoRoute(
        path: AppConstants.settingsRoute,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppConstants.collectionRoute,
        builder: (context, state) => const CollectionScreen(),
      ),
    ],
  );
});
