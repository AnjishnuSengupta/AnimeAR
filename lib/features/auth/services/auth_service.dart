import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../../../core/constants/app_constants.dart';

class AuthService {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  FirebaseAuth get auth {
    _auth ??= FirebaseAuth.instance;
    return _auth!;
  }

  FirebaseFirestore get firestore {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  Stream<User?> get authStateChanges async* {
    try {
      debugPrint('AuthService: Setting up auth state changes stream');
      // Check if Firebase is initialized
      if (Firebase.apps.isEmpty) {
        debugPrint('AuthService: Firebase not initialized, yielding null');
        yield null;
        return;
      }
      // Firebase should already be initialized by main.dart
      yield* auth.authStateChanges();
    } catch (e) {
      debugPrint('AuthService: Error in auth state changes: $e');
      yield null;
    }
  }

  Future<AppUser?> getCurrentUser() async {
    try {
      final user = auth.currentUser;
      if (user == null) return null;

      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        return AppUser.fromJson({'id': user.uid, ...userDoc.data()!});
      }

      // Create user document if it doesn't exist
      final newUser = AppUser(
        id: user.uid,
        email: user.email!,
        name: user.displayName ?? 'User',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _createUserDocument(newUser);
      return newUser;
    } catch (e) {
      return null;
    }
  }

  Future<UserCredential> signUpWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      debugPrint('AuthService: Attempting to sign up with email: $email');
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        debugPrint(
          'AuthService: User created successfully, updating display name',
        );
        await credential.user!.updateDisplayName(name);

        final user = AppUser(
          id: credential.user!.uid,
          email: email,
          name: name,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        debugPrint('AuthService: Creating user document in Firestore');
        await _createUserDocument(user);

        debugPrint('AuthService: Sign up completed successfully');
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService: Firebase Auth Exception during sign up: ${e.code} - ${e.message}',
      );
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Unexpected error during sign up: $e');
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      debugPrint('AuthService: Attempting to sign in with email: $email');
      final credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        debugPrint('AuthService: Sign in successful, updating last login');
        await _updateLastLogin(credential.user!.uid);
      }

      debugPrint('AuthService: Sign in completed successfully');
      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService: Firebase Auth Exception during sign in: ${e.code} - ${e.message}',
      );
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Unexpected error during sign in: $e');
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      debugPrint('AuthService: Starting Google Sign-In');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        debugPrint('AuthService: Google Sign-In was cancelled by user');
        throw Exception('Google Sign-In was cancelled');
      }

      debugPrint('AuthService: Google user obtained: ${googleUser.email}');
      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      debugPrint(
        'AuthService: Google auth details obtained, creating Firebase credential',
      );
      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      debugPrint('AuthService: Signing in to Firebase with Google credential');
      // Once signed in, return the UserCredential
      final userCredential = await auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        debugPrint(
          'AuthService: Google Sign-In successful, creating user document',
        );
        // Create or update user document
        final user = AppUser(
          id: userCredential.user!.uid,
          email: userCredential.user!.email!,
          name: userCredential.user!.displayName ?? 'User',
          photoUrl: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _createUserDocument(user);

        debugPrint('AuthService: Google Sign-In completed successfully');
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'AuthService: Firebase Auth Exception during Google Sign-In: ${e.code} - ${e.message}',
      );
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('AuthService: Unexpected error during Google Sign-In: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      // Sign out from Google Sign-In
      try {
        await GoogleSignIn().signOut();
      } catch (e) {
        // Ignore Google Sign-In errors during logout
      }

      await auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        // Delete user document from Firestore
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .delete();

        // Delete the Firebase Auth account
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> _createUserDocument(AppUser user) async {
    try {
      debugPrint('AuthService: Creating user document for ${user.email}');
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toJson());
      debugPrint('AuthService: User document created successfully');
    } catch (e) {
      debugPrint('AuthService: Error creating user document: $e');
      throw Exception('Failed to create user document: $e');
    }
  }

  Future<void> _updateLastLogin(String userId) async {
    try {
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'lastLoginAt': DateTime.now()});
    } catch (e) {
      // Don't throw error for login update failure
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'The account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided for that user.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Signing in with Email and Password is not enabled.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}
