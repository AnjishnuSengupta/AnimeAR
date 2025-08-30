import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class ProfileService {
  FirebaseFirestore? _firestore;
  FirebaseAuth? _auth;

  FirebaseFirestore get firestore {
    try {
      _firestore ??= FirebaseFirestore.instance;
      return _firestore!;
    } catch (e) {
      debugPrint('ProfileService: Error accessing Firestore: $e');
      rethrow;
    }
  }

  FirebaseAuth get auth {
    try {
      _auth ??= FirebaseAuth.instance;
      return _auth!;
    } catch (e) {
      debugPrint('ProfileService: Error accessing Firebase Auth: $e');
      rethrow;
    }
  }

  /// Creates or updates user profile in Firestore
  Future<void> createOrUpdateUserProfile({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      print('🔥 ProfileService: Creating/updating user profile for $uid');

      final userRef = firestore.collection('users').doc(uid);

      // Check if user document exists
      final doc = await userRef.get();

      if (doc.exists) {
        // Check if this is an old AppUser document (has ISO8601 strings) and convert it
        final data = doc.data() as Map<String, dynamic>;
        final isOldFormat = data['createdAt'] is String;

        if (isOldFormat) {
          print(
            '🔥 ProfileService: Converting old AppUser document to UserProfile format',
          );
          // Convert old AppUser document to UserProfile format
          final userProfile = UserProfile(
            uid: uid,
            email: email,
            displayName: displayName ?? data['name'] ?? email.split('@')[0],
            photoURL: photoURL ?? data['photoUrl'],
            createdAt: data['createdAt'] != null
                ? DateTime.parse(data['createdAt'])
                : DateTime.now(),
            lastSignIn: DateTime.now(),
            arSessionsCount: 0,
            discoveredLocationsCount: 0,
            favoriteCharacters: List<String>.from(
              data['favoriteCharacters'] ?? [],
            ),
            preferences: {
              'theme': 'dark',
              'notifications': true,
              'showLocationInProfile': true,
            },
          );

          await userRef.set(userProfile.toFirestore());
          print('✅ ProfileService: Converted and updated user profile');
        } else {
          // Update existing UserProfile document
          await userRef.update({
            'lastSignIn': FieldValue.serverTimestamp(),
            'email': email,
            if (displayName != null) 'displayName': displayName,
            if (photoURL != null) 'photoURL': photoURL,
          });
          print('✅ ProfileService: Updated existing user profile');
        }
      } else {
        // Create new user profile
        final userProfile = UserProfile(
          uid: uid,
          email: email,
          displayName: displayName ?? email.split('@')[0],
          photoURL: photoURL,
          createdAt: DateTime.now(),
          lastSignIn: DateTime.now(),
          arSessionsCount: 0,
          discoveredLocationsCount: 0,
          favoriteCharacters: [],
          preferences: {
            'theme': 'dark',
            'notifications': true,
            'showLocationInProfile': true,
          },
        );

        await userRef.set(userProfile.toFirestore());
        print('✅ ProfileService: Created new user profile');
      }
    } catch (e) {
      print('❌ ProfileService: Error creating/updating user profile: $e');
      rethrow;
    }
  }

  /// Gets user profile from Firestore
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      print('🔥 ProfileService: Fetching user profile for $uid');

      final doc = await firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final profile = UserProfile.fromFirestore(doc);
        print('✅ ProfileService: User profile fetched successfully');
        return profile;
      } else {
        print('⚠️ ProfileService: User profile not found');
        return null;
      }
    } catch (e) {
      print('❌ ProfileService: Error fetching user profile: $e');
      rethrow;
    }
  }

  /// Gets user profile stream for real-time updates
  Stream<UserProfile?> getUserProfileStream(String uid) {
    print('🔥 ProfileService: Setting up user profile stream for $uid');

    return firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists) {
        print('✅ ProfileService: Profile stream updated');
        return UserProfile.fromFirestore(doc);
      } else {
        print('⚠️ ProfileService: Profile not found in stream');
        return null;
      }
    });
  }

  /// Updates user preferences
  Future<void> updateUserPreferences(
    String uid,
    Map<String, dynamic> preferences,
  ) async {
    try {
      print('🔥 ProfileService: Updating user preferences for $uid');

      await firestore.collection('users').doc(uid).update({
        'preferences': preferences,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      print('✅ ProfileService: User preferences updated');
    } catch (e) {
      print('❌ ProfileService: Error updating user preferences: $e');
      rethrow;
    }
  }

  /// Increments AR session count
  Future<void> incrementARSessionCount(String uid) async {
    try {
      print('🔥 ProfileService: Incrementing AR session count for $uid');

      await firestore.collection('users').doc(uid).update({
        'arSessionsCount': FieldValue.increment(1),
        'lastARSession': FieldValue.serverTimestamp(),
      });

      print('✅ ProfileService: AR session count incremented');
    } catch (e) {
      print('❌ ProfileService: Error incrementing AR session count: $e');
      rethrow;
    }
  }

  /// Adds discovered location
  Future<void> addDiscoveredLocation(String uid, String locationId) async {
    try {
      print('🔥 ProfileService: Adding discovered location for $uid');

      await firestore.collection('users').doc(uid).update({
        'discoveredLocationsCount': FieldValue.increment(1),
        'lastDiscovery': FieldValue.serverTimestamp(),
      });

      // Also add to user's discoveries subcollection
      await firestore
          .collection('users')
          .doc(uid)
          .collection('discoveries')
          .doc(locationId)
          .set({
            'locationId': locationId,
            'discoveredAt': FieldValue.serverTimestamp(),
          });

      print('✅ ProfileService: Discovered location added');
    } catch (e) {
      print('❌ ProfileService: Error adding discovered location: $e');
      rethrow;
    }
  }

  /// Adds favorite character
  Future<void> addFavoriteCharacter(String uid, String characterName) async {
    try {
      print('🔥 ProfileService: Adding favorite character for $uid');

      await firestore.collection('users').doc(uid).update({
        'favoriteCharacters': FieldValue.arrayUnion([characterName]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ ProfileService: Favorite character added');
    } catch (e) {
      print('❌ ProfileService: Error adding favorite character: $e');
      rethrow;
    }
  }

  /// Removes favorite character
  Future<void> removeFavoriteCharacter(String uid, String characterName) async {
    try {
      print('🔥 ProfileService: Removing favorite character for $uid');

      await firestore.collection('users').doc(uid).update({
        'favoriteCharacters': FieldValue.arrayRemove([characterName]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ ProfileService: Favorite character removed');
    } catch (e) {
      print('❌ ProfileService: Error removing favorite character: $e');
      rethrow;
    }
  }
}
