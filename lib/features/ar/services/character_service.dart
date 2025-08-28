import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/anime_character.dart';
import '../models/anime_info.dart';
import '../../../core/constants/app_constants.dart';
import 'anime_api_service.dart';

class CharacterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AnimeApiService _animeApiService = AnimeApiService();

  // Collection references
  CollectionReference get _charactersCollection =>
      _firestore.collection(AppConstants.charactersCollection);

  /// Get all anime characters with pagination
  Future<List<AnimeCharacter>> getCharacters({
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query query = _charactersCollection.orderBy('name').limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map(
            (doc) => AnimeCharacter.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch characters: $e');
    }
  }

  /// Search characters using both local database and API
  Future<List<AnimeCharacter>> searchCharacters(String query) async {
    try {
      // First search local database
      final localResults = await _searchCharactersLocal(query);

      // If we have enough local results, return them
      if (localResults.length >= 5) {
        return localResults;
      }

      // Otherwise, search API and cache results
      final apiResults = await _animeApiService.searchCharacters(query);

      // Cache new characters from API to local database
      for (final character in apiResults) {
        await _cacheCharacterIfNew(character);
      }

      // Combine results, preferring local data
      final seenIds = localResults.map((c) => c.id).toSet();
      final combinedResults = [...localResults];

      for (final character in apiResults) {
        if (!seenIds.contains(character.id)) {
          combinedResults.add(character);
          seenIds.add(character.id);
        }
      }

      return combinedResults.take(10).toList();
    } catch (e) {
      // Fallback to local search if API fails
      return _searchCharactersLocal(query);
    }
  }

  /// Search characters in local database
  Future<List<AnimeCharacter>> _searchCharactersLocal(String query) async {
    try {
      final nameResults = await _charactersCollection
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10)
          .get();

      final animeResults = await _charactersCollection
          .where('animeName', isGreaterThanOrEqualTo: query)
          .where('animeName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(10)
          .get();

      final characters = <AnimeCharacter>[];
      final seenIds = <String>{};

      // Combine and deduplicate results
      for (final doc in [...nameResults.docs, ...animeResults.docs]) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          characters.add(
            AnimeCharacter.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          );
        }
      }

      return characters;
    } catch (e) {
      throw Exception('Failed to search characters locally: $e');
    }
  }

  /// Cache character if it doesn't exist in local database
  Future<void> _cacheCharacterIfNew(AnimeCharacter character) async {
    try {
      final existingDoc = await _charactersCollection.doc(character.id).get();
      if (!existingDoc.exists) {
        await _charactersCollection.doc(character.id).set(character.toJson());
      }
    } catch (e) {
      // Ignore caching errors, don't let them break the search
      debugPrint('Failed to cache character ${character.name}: $e');
    }
  }

  /// Get character with enhanced API data
  Future<AnimeCharacter?> getCharacterById(String id) async {
    try {
      // First try local database
      final doc = await _charactersCollection.doc(id).get();
      if (doc.exists) {
        return AnimeCharacter.fromJson({
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        });
      }

      // If not found locally, try API
      final apiCharacter = await _animeApiService.getCharacterById(id);
      if (apiCharacter != null) {
        // Cache the result
        await _cacheCharacterIfNew(apiCharacter);
        return apiCharacter;
      }

      return null;
    } catch (e) {
      throw Exception('Failed to fetch character: $e');
    }
  }

  /// Get characters by anime with API enhancement
  Future<List<AnimeCharacter>> getCharactersByAnime(String animeName) async {
    try {
      // Search local database first
      final localCharacters = await _charactersCollection
          .where('animeName', isEqualTo: animeName)
          .orderBy('name')
          .get();

      final characters = localCharacters.docs
          .map(
            (doc) => AnimeCharacter.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      // If we have local data, return it (optionally enhance with API data)
      if (characters.isNotEmpty) {
        return characters;
      }

      // If no local data, search for anime and get characters from API
      final animeResults = await _animeApiService.searchAnime(
        animeName,
        limit: 1,
      );
      if (animeResults.isNotEmpty) {
        final anime = animeResults.first;
        final apiCharacters = await _animeApiService.getAnimeCharacters(
          anime.id,
        );

        // Cache the characters
        for (final character in apiCharacters) {
          await _cacheCharacterIfNew(character.copyWith(animeName: animeName));
        }

        return apiCharacters
            .map((c) => c.copyWith(animeName: animeName))
            .toList();
      }

      return [];
    } catch (e) {
      throw Exception('Failed to fetch characters by anime: $e');
    }
  }

  /// Get anime information for a character
  Future<AnimeInfo?> getAnimeInfoForCharacter(String characterId) async {
    try {
      final character = await getCharacterById(characterId);
      if (character == null || character.animeName.isEmpty) {
        return null;
      }

      // Search for anime information
      final animeResults = await _animeApiService.searchAnime(
        character.animeName,
        limit: 1,
      );
      return animeResults.isNotEmpty ? animeResults.first : null;
    } catch (e) {
      debugPrint('Failed to get anime info for character: $e');
      return null;
    }
  }

  /// Sync popular characters from API to local database
  Future<void> syncPopularCharacters() async {
    try {
      // Get top anime
      final topAnime = await _animeApiService.getTopAnime(limit: 10);

      for (final anime in topAnime) {
        final characters = await _animeApiService.getAnimeCharacters(anime.id);

        for (final character in characters) {
          await _cacheCharacterIfNew(
            character.copyWith(animeName: anime.title, animeInfo: anime),
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to sync popular characters: $e');
    }
  }

  /// Get popular characters (by detection count)
  Future<List<AnimeCharacter>> getPopularCharacters({int limit = 10}) async {
    try {
      // This would typically involve aggregating detection data
      // For now, we'll return recent characters
      final querySnapshot = await _charactersCollection
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => AnimeCharacter.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch popular characters: $e');
    }
  }

  /// Add a new character (admin function)
  Future<String> addCharacter(AnimeCharacter character) async {
    try {
      final docRef = await _charactersCollection.add(character.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add character: $e');
    }
  }

  /// Update character information (admin function)
  Future<void> updateCharacter(String id, AnimeCharacter character) async {
    try {
      await _charactersCollection.doc(id).update(character.toJson());
    } catch (e) {
      throw Exception('Failed to update character: $e');
    }
  }

  /// Delete character (admin function)
  Future<void> deleteCharacter(String id) async {
    try {
      await _charactersCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete character: $e');
    }
  }

  /// Get characters by tags
  Future<List<AnimeCharacter>> getCharactersByTags(List<String> tags) async {
    try {
      final querySnapshot = await _charactersCollection
          .where('tags', arrayContainsAny: tags)
          .limit(20)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => AnimeCharacter.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch characters by tags: $e');
    }
  }

  /// Stream of characters for real-time updates
  Stream<List<AnimeCharacter>> watchCharacters({int limit = 20}) {
    return _charactersCollection
        .orderBy('name')
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => AnimeCharacter.fromJson({
                  'id': doc.id,
                  ...doc.data() as Map<String, dynamic>,
                }),
              )
              .toList(),
        );
  }
}
