import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/character_service.dart';
import '../services/detection_service.dart';
import '../models/anime_character.dart';
import '../models/detection_result.dart';

// Service providers
final characterServiceProvider = Provider<CharacterService>((ref) {
  return CharacterService();
});

final detectionServiceProvider = Provider<DetectionService>((ref) {
  return DetectionService();
});

// Character-related providers
final charactersProvider = FutureProvider.autoDispose<List<AnimeCharacter>>((
  ref,
) async {
  final characterService = ref.read(characterServiceProvider);
  return characterService.getCharacters();
});

final popularCharactersProvider =
    FutureProvider.autoDispose<List<AnimeCharacter>>((ref) async {
      final characterService = ref.read(characterServiceProvider);
      return characterService.getPopularCharacters();
    });

final characterProvider = FutureProvider.autoDispose
    .family<AnimeCharacter?, String>((ref, characterId) async {
      final characterService = ref.read(characterServiceProvider);
      return characterService.getCharacterById(characterId);
    });

final charactersByAnimeProvider = FutureProvider.autoDispose
    .family<List<AnimeCharacter>, String>((ref, animeName) async {
      final characterService = ref.read(characterServiceProvider);
      return characterService.getCharactersByAnime(animeName);
    });

final searchCharactersProvider = FutureProvider.autoDispose
    .family<List<AnimeCharacter>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final characterService = ref.read(characterServiceProvider);
      return characterService.searchCharacters(query);
    });

// Detection-related providers
final userDetectionsProvider = FutureProvider.autoDispose
    .family<List<DetectionResult>, String>((ref, userId) async {
      final detectionService = ref.read(detectionServiceProvider);
      return detectionService.getUserDetections(userId);
    });

final recentDetectionsProvider =
    FutureProvider.autoDispose<List<DetectionResult>>((ref) async {
      final detectionService = ref.read(detectionServiceProvider);
      return detectionService.getRecentDetections();
    });

final characterDetectionsProvider = FutureProvider.autoDispose
    .family<List<DetectionResult>, String>((ref, characterId) async {
      final detectionService = ref.read(detectionServiceProvider);
      return detectionService.getCharacterDetections(characterId);
    });

final userStatsProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, userId) async {
      final detectionService = ref.read(detectionServiceProvider);
      return detectionService.getUserStats(userId);
    });

final trendingCharactersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final detectionService = ref.read(detectionServiceProvider);
      return detectionService.getTrendingCharacters();
    });

final searchDetectionsProvider = FutureProvider.autoDispose
    .family<List<DetectionResult>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final detectionService = ref.read(detectionServiceProvider);
      return detectionService.searchDetections(query);
    });

// State providers for UI state management
final selectedCharacterProvider = StateProvider<AnimeCharacter?>((ref) => null);

final detectionResultProvider = StateProvider<DetectionResult?>((ref) => null);

final isDetectingProvider = StateProvider<bool>((ref) => false);

final cameraPermissionProvider = StateProvider<bool>((ref) => false);

final selectedAnimeFilterProvider = StateProvider<String?>((ref) => null);

final searchQueryProvider = StateProvider<String>((ref) => '');

// Loading state providers
final isLoadingDetectionsProvider = StateProvider<bool>((ref) => false);

final isLoadingCharactersProvider = StateProvider<bool>((ref) => false);

final isSavingDetectionProvider = StateProvider<bool>((ref) => false);

// Notification providers for user feedback
final notificationProvider = StateProvider<String?>((ref) => null);

final errorProvider = StateProvider<String?>((ref) => null);
