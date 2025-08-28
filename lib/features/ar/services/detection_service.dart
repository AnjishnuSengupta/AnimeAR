import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/detection_result.dart';
import '../../../core/constants/app_constants.dart';

class DetectionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference get _detectionsCollection =>
      _firestore.collection(AppConstants.detectionsCollection);

  CollectionReference get _userDetectionsCollection =>
      _firestore.collection(AppConstants.userDetectionsCollection);

  /// Save a detection result to Firebase
  Future<String> saveDetection(DetectionResult detection) async {
    try {
      final docRef = await _detectionsCollection.add(detection.toJson());

      // Also save to user-specific collection for easier querying
      await _userDetectionsCollection.add({
        ...detection.toJson(),
        'detectionId': docRef.id,
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save detection: $e');
    }
  }

  /// Upload detection image to Firebase Storage
  Future<String> uploadDetectionImage(File imageFile, String userId) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_$userId.jpg';
      final ref = _storage.ref().child('detections/$fileName');

      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload detection image: $e');
    }
  }

  /// Get detection results for a specific user
  Future<List<DetectionResult>> getUserDetections(
    String userId, {
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _detectionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('detectedAt', descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map(
            (doc) => DetectionResult.fromJson({
              'id': doc.id,
              ...(doc.data() as Map<String, dynamic>),
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user detections: $e');
    }
  }

  /// Get recent detections across all users (for social features)
  Future<List<DetectionResult>> getRecentDetections({int limit = 20}) async {
    try {
      final querySnapshot = await _detectionsCollection
          .orderBy('detectedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => DetectionResult.fromJson({
              'id': doc.id,
              ...(doc.data() as Map<String, dynamic>),
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch recent detections: $e');
    }
  }

  /// Get detections for a specific character
  Future<List<DetectionResult>> getCharacterDetections(
    String characterId, {
    int limit = 30,
  }) async {
    try {
      final querySnapshot = await _detectionsCollection
          .where('character.id', isEqualTo: characterId)
          .orderBy('detectedAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => DetectionResult.fromJson({
              'id': doc.id,
              ...(doc.data() as Map<String, dynamic>),
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch character detections: $e');
    }
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final detectionsSnapshot = await _detectionsCollection
          .where('userId', isEqualTo: userId)
          .get();

      final totalDetections = detectionsSnapshot.docs.length;

      // Count unique characters
      final uniqueCharacters = <String>{};
      final animeSeriesCount = <String, int>{};
      double totalConfidence = 0;

      for (final doc in detectionsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final character = data['character'] as Map<String, dynamic>;

        uniqueCharacters.add(character['id'] as String);

        final animeName = character['animeName'] as String;
        animeSeriesCount[animeName] = (animeSeriesCount[animeName] ?? 0) + 1;

        totalConfidence += (data['confidence'] as num).toDouble();
      }

      final averageConfidence = totalDetections > 0
          ? totalConfidence / totalDetections
          : 0.0;

      return {
        'totalDetections': totalDetections,
        'uniqueCharacters': uniqueCharacters.length,
        'animeSeries': animeSeriesCount.length,
        'averageConfidence': averageConfidence,
        'favoriteAnime': animeSeriesCount.isNotEmpty
            ? animeSeriesCount.entries
                  .reduce((a, b) => a.value > b.value ? a : b)
                  .key
            : null,
        'animeBreakdown': animeSeriesCount,
      };
    } catch (e) {
      throw Exception('Failed to fetch user stats: $e');
    }
  }

  /// Delete a detection
  Future<void> deleteDetection(String detectionId) async {
    try {
      await _detectionsCollection.doc(detectionId).delete();

      // Also delete from user-specific collection
      final userDetectionsQuery = await _userDetectionsCollection
          .where('detectionId', isEqualTo: detectionId)
          .get();

      for (final doc in userDetectionsQuery.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete detection: $e');
    }
  }

  /// Get trending characters (most detected recently)
  Future<List<Map<String, dynamic>>> getTrendingCharacters({
    int limit = 10,
    int daysBack = 7,
  }) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysBack));

      final querySnapshot = await _detectionsCollection
          .where('detectedAt', isGreaterThan: cutoffDate)
          .get();

      final characterCounts = <String, Map<String, dynamic>>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final character = data['character'] as Map<String, dynamic>;
        final characterId = character['id'] as String;

        if (characterCounts.containsKey(characterId)) {
          characterCounts[characterId]!['count'] += 1;
        } else {
          characterCounts[characterId] = {'character': character, 'count': 1};
        }
      }

      final sortedCharacters = characterCounts.values.toList()
        ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

      return sortedCharacters.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to fetch trending characters: $e');
    }
  }

  /// Search detections by character name or anime
  Future<List<DetectionResult>> searchDetections(
    String query, {
    String? userId,
    int limit = 20,
  }) async {
    try {
      // Note: Firestore doesn't support full-text search out of the box
      // For production, consider using Algolia or similar service
      Query baseQuery = _detectionsCollection;

      if (userId != null) {
        baseQuery = baseQuery.where('userId', isEqualTo: userId);
      }

      final querySnapshot = await baseQuery
          .orderBy('detectedAt', descending: true)
          .limit(limit * 2) // Get more to filter locally
          .get();

      final results = querySnapshot.docs
          .map(
            (doc) => DetectionResult.fromJson({
              'id': doc.id,
              ...(doc.data() as Map<String, dynamic>),
            }),
          )
          .where((detection) {
            final characterName = detection.character.name.toLowerCase();
            final animeName = detection.character.animeName.toLowerCase();
            final searchQuery = query.toLowerCase();

            return characterName.contains(searchQuery) ||
                animeName.contains(searchQuery);
          })
          .take(limit)
          .toList();

      return results;
    } catch (e) {
      throw Exception('Failed to search detections: $e');
    }
  }
}
