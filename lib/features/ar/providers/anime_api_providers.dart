import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/anime_api_service.dart';
import '../models/anime_info.dart';
import '../models/anime_character.dart';

// Service providers
final animeApiServiceProvider = Provider<AnimeApiService>((ref) {
  return AnimeApiService();
});

// Search providers
final searchAnimeProvider = FutureProvider.autoDispose
    .family<List<AnimeInfo>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final apiService = ref.read(animeApiServiceProvider);
      return apiService.searchAnime(query);
    });

final searchCharactersProvider = FutureProvider.autoDispose
    .family<List<AnimeCharacter>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final apiService = ref.read(animeApiServiceProvider);
      return apiService.searchCharacters(query);
    });

// Anime details providers
final animeDetailsProvider = FutureProvider.autoDispose
    .family<AnimeInfo?, String>((ref, animeId) async {
      final apiService = ref.read(animeApiServiceProvider);
      return apiService.getAnimeById(animeId);
    });

final animeCharactersProvider = FutureProvider.autoDispose
    .family<List<AnimeCharacter>, String>((ref, animeId) async {
      final apiService = ref.read(animeApiServiceProvider);
      return apiService.getAnimeCharacters(animeId);
    });

final characterDetailsProvider = FutureProvider.autoDispose
    .family<AnimeCharacter?, String>((ref, characterId) async {
      final apiService = ref.read(animeApiServiceProvider);
      return apiService.getCharacterById(characterId);
    });

// Popular/trending providers
final topAnimeProvider = FutureProvider.autoDispose<List<AnimeInfo>>((
  ref,
) async {
  final apiService = ref.read(animeApiServiceProvider);
  return apiService.getTopAnime(limit: 25);
});

final seasonalAnimeProvider = FutureProvider.autoDispose<List<AnimeInfo>>((
  ref,
) async {
  final apiService = ref.read(animeApiServiceProvider);
  return apiService.getSeasonalAnime();
});

final currentlyAiringProvider = FutureProvider.autoDispose<List<AnimeInfo>>((
  ref,
) async {
  final apiService = ref.read(animeApiServiceProvider);
  return apiService.getCurrentlyAiring();
});

// Recommendations provider
final animeRecommendationsProvider = FutureProvider.autoDispose
    .family<List<AnimeInfo>, String>((ref, animeId) async {
      final apiService = ref.read(animeApiServiceProvider);
      return apiService.getRecommendations(animeId);
    });

// Genre-based provider
final animeByGenreProvider = FutureProvider.autoDispose
    .family<List<AnimeInfo>, String>((ref, genre) async {
      final apiService = ref.read(animeApiServiceProvider);
      return apiService.getAnimeByGenre(genre);
    });

// AniList search provider (alternative API)
final searchAnimeAniListProvider = FutureProvider.autoDispose
    .family<List<AnimeInfo>, String>((ref, query) async {
      if (query.isEmpty) return [];
      final apiService = ref.read(animeApiServiceProvider);
      return apiService.searchAnimeAniList(query);
    });

// Random character image provider
final randomCharacterImageProvider = FutureProvider.autoDispose
    .family<String?, String>((ref, category) async {
      final apiService = ref.read(animeApiServiceProvider);
      return apiService.getRandomCharacterImage(category: category);
    });

// Image tracing provider (trace.moe)
final traceAnimeFromImageProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>?, String>((ref, imageUrl) async {
      final apiService = ref.read(animeApiServiceProvider);
      return apiService.traceAnimeFromImage(imageUrl);
    });
