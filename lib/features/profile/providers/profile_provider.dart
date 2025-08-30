import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../../auth/providers/auth_provider.dart';

// Profile service provider
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

// Current user profile provider (stream)
final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  final profileService = ref.read(profileServiceProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        print(
          '🔥 ProfileProvider: No authenticated user, returning empty stream',
        );
        return Stream.value(null);
      }

      print(
        '🔥 ProfileProvider: Setting up profile stream for user ${user.uid}',
      );

      // First create or update the profile, then stream it
      return Stream.fromFuture(
            profileService.createOrUpdateUserProfile(
              uid: user.uid,
              email: user.email!,
              displayName: user.displayName,
              photoURL: user.photoURL,
            ),
          )
          .asyncExpand((_) {
            // After creating/updating profile, stream the actual profile
            return profileService.getUserProfileStream(user.uid);
          })
          .handleError((error) {
            print('🔥 ProfileProvider: Error in profile stream: $error');
            return null;
          });
    },
    loading: () {
      print('🔥 ProfileProvider: Auth state loading, returning empty stream');
      return Stream.value(null);
    },
    error: (error, stack) {
      print('🔥 ProfileProvider: Auth state error: $error');
      return Stream.value(null);
    },
  );
});

// Profile controller for actions
final profileControllerProvider = Provider<ProfileController>((ref) {
  return ProfileController(ref);
});

class ProfileController {
  final Ref _ref;

  ProfileController(this._ref);

  /// Creates or updates user profile after authentication
  Future<void> createOrUpdateUserProfile(User user) async {
    try {
      print('🔥 ProfileController: Creating/updating profile for ${user.uid}');

      final profileService = _ref.read(profileServiceProvider);
      await profileService.createOrUpdateUserProfile(
        uid: user.uid,
        email: user.email!,
        displayName: user.displayName,
        photoURL: user.photoURL,
      );

      print('✅ ProfileController: Profile created/updated successfully');
    } catch (e) {
      print('❌ ProfileController: Error creating/updating profile: $e');
      rethrow;
    }
  }

  /// Updates user preferences
  Future<void> updatePreferences(Map<String, dynamic> preferences) async {
    try {
      final user = _ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      print('🔥 ProfileController: Updating preferences for ${user.uid}');

      final profileService = _ref.read(profileServiceProvider);
      await profileService.updateUserPreferences(user.uid, preferences);

      print('✅ ProfileController: Preferences updated successfully');
    } catch (e) {
      print('❌ ProfileController: Error updating preferences: $e');
      rethrow;
    }
  }

  /// Increments AR session count
  Future<void> incrementARSessionCount() async {
    try {
      final user = _ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      print(
        '🔥 ProfileController: Incrementing AR session count for ${user.uid}',
      );

      final profileService = _ref.read(profileServiceProvider);
      await profileService.incrementARSessionCount(user.uid);

      print('✅ ProfileController: AR session count incremented');
    } catch (e) {
      print('❌ ProfileController: Error incrementing AR session count: $e');
      rethrow;
    }
  }

  /// Adds discovered location
  Future<void> addDiscoveredLocation(String locationId) async {
    try {
      final user = _ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      print('🔥 ProfileController: Adding discovered location for ${user.uid}');

      final profileService = _ref.read(profileServiceProvider);
      await profileService.addDiscoveredLocation(user.uid, locationId);

      print('✅ ProfileController: Discovered location added');
    } catch (e) {
      print('❌ ProfileController: Error adding discovered location: $e');
      rethrow;
    }
  }

  /// Adds favorite character
  Future<void> addFavoriteCharacter(String characterName) async {
    try {
      final user = _ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      print('🔥 ProfileController: Adding favorite character for ${user.uid}');

      final profileService = _ref.read(profileServiceProvider);
      await profileService.addFavoriteCharacter(user.uid, characterName);

      print('✅ ProfileController: Favorite character added');
    } catch (e) {
      print('❌ ProfileController: Error adding favorite character: $e');
      rethrow;
    }
  }

  /// Removes favorite character
  Future<void> removeFavoriteCharacter(String characterName) async {
    try {
      final user = _ref.read(authStateProvider).value;
      if (user == null) {
        throw Exception('No authenticated user');
      }

      print(
        '🔥 ProfileController: Removing favorite character for ${user.uid}',
      );

      final profileService = _ref.read(profileServiceProvider);
      await profileService.removeFavoriteCharacter(user.uid, characterName);

      print('✅ ProfileController: Favorite character removed');
    } catch (e) {
      print('❌ ProfileController: Error removing favorite character: $e');
      rethrow;
    }
  }
}
