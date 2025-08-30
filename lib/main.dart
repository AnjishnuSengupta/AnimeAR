import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/widgets/splash_screen.dart';
import 'core/config/firebase_config.dart';
import 'features/ar/services/anime_api_service.dart';
import 'routes/app_router.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(child: AnimeARApp()));
}

class AnimeARApp extends StatelessWidget {
  const AnimeARApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const SplashScreen(),
          );
        }

        if (snapshot.hasError) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 64),
                    const SizedBox(height: 16),
                    Text('Initialization Error: ${snapshot.error}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Restart the app
                        main();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          routerConfig: AppRouter.router,
        );
      },
    );
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('Main: Starting app initialization');

      // Load environment variables for other configurations
      debugPrint('Main: Loading environment variables');
      await dotenv.load(fileName: '.env');

      // Initialize Firebase with the new configuration
      debugPrint('Main: Initializing Firebase');
      await FirebaseConfig.initialize();
      debugPrint('Main: Firebase initialized successfully');

      // Initialize anime API service
      debugPrint('Main: Initializing Anime API service');
      AnimeApiService().initialize();

      // Initialize cameras
      debugPrint('Main: Initializing cameras');
      try {
        cameras = await availableCameras();
        debugPrint('Main: Found ${cameras.length} cameras');
      } catch (e) {
        debugPrint('Main: Error initializing cameras: $e');
        cameras = [];
      }

      debugPrint('Main: App initialization completed successfully');
    } catch (e) {
      debugPrint('Main: Error during initialization: $e');
      cameras = [];
      // Don't rethrow Firebase errors, just log them
      // The app can still work without Firebase in development
    }
  }
}
