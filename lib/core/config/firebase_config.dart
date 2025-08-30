import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../firebase_options.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      debugPrint('FirebaseConfig: Starting Firebase initialization');

      // Check if Firebase is already initialized
      if (Firebase.apps.isNotEmpty) {
        debugPrint('FirebaseConfig: Firebase already initialized');
        return;
      }

      debugPrint('FirebaseConfig: Initializing Firebase with platform options');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      debugPrint(
        'FirebaseConfig: Firebase initialization completed successfully',
      );
    } catch (e) {
      debugPrint('FirebaseConfig: Error initializing Firebase: $e');
      rethrow;
    }
  }

  static bool get isDebugMode {
    return dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  }

  static String get logLevel {
    return dotenv.env['LOG_LEVEL'] ?? 'info';
  }

  static String? get tfliteModelUrl {
    return dotenv.env['TFLITE_MODEL_URL'];
  }

  static String? get animeApiKey {
    return dotenv.env['ANIME_DATABASE_API_KEY'];
  }
}
