class AppConstants {
  static const String appName = 'AnimeAR';
  static const String appVersion = '1.0.0';

  // Routing paths
  static const String splashRoute = '/';
  static const String authRoute = '/auth';
  static const String homeRoute = '/home';
  static const String arCameraRoute = '/ar-camera';
  static const String profileRoute = '/profile';
  static const String socialRoute = '/social';
  static const String characterDetailRoute = '/character-detail';
  static const String settingsRoute = '/settings';
  static const String collectionRoute = '/collection';

  // Database
  static const String dbName = 'anime_ar.db';
  static const int dbVersion = 1;

  // Collections
  static const String charactersTable = 'characters';
  static const String favoritesTable = 'favorites';
  static const String discoveredTable = 'discovered_characters';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String postsCollection = 'posts';
  static const String charactersCollection = 'characters';
  static const String commentsCollection = 'comments';
  static const String detectionsCollection = 'detections';
  static const String userDetectionsCollection = 'user_detections';

  // Storage
  static const String profileImagesPath = 'profile_images';
  static const String characterImagesPath = 'character_images';
  static const String postImagesPath = 'post_images';

  // AR Configuration
  static const double detectionConfidenceThreshold = 0.7;
  static const int maxDetectionResults = 5;
  static const Duration detectionCooldown = Duration(seconds: 2);

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;
}
