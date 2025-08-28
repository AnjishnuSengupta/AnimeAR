import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/anime_info.dart';
import '../models/anime_character.dart';

class AnimeApiService {
  static final AnimeApiService _instance = AnimeApiService._internal();
  factory AnimeApiService() => _instance;
  AnimeApiService._internal();

  late final Dio _dio;

  // API Base URLs
  static const String _jikanBaseUrl = 'https://api.jikan.moe/v4';
  static const String _anilistUrl = 'https://graphql.anilist.co';
  static const String _traceMoeUrl = 'https://api.trace.moe';
  static const String _waifuPicsUrl = 'https://api.waifu.pics';

  void initialize() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        headers: {'User-Agent': 'AnimeAR/1.0.0', 'Accept': 'application/json'},
      ),
    );

    // Add interceptors for logging and error handling
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false,
        logPrint: (object) {
          if (dotenv.getBool('DEBUG_MODE', fallback: false)) {
            debugPrint('[API] $object');
          }
        },
      ),
    );
  }

  /// Search anime by title using Jikan API (MyAnimeList)
  Future<List<AnimeInfo>> searchAnime(String query, {int limit = 10}) async {
    try {
      final response = await _dio.get(
        '$_jikanBaseUrl/anime',
        queryParameters: {
          'q': query,
          'limit': limit,
          'order_by': 'popularity',
          'sort': 'desc',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final animeList = data['data'] as List;
        return animeList.map((anime) => AnimeInfo.fromJson(anime)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error searching anime: $e');
      return [];
    }
  }

  /// Get anime details by ID using Jikan API
  Future<AnimeInfo?> getAnimeById(String id) async {
    try {
      final response = await _dio.get('$_jikanBaseUrl/anime/$id');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return AnimeInfo.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching anime details: $e');
      return null;
    }
  }

  /// Get anime characters using Jikan API
  Future<List<AnimeCharacter>> getAnimeCharacters(String animeId) async {
    try {
      final response = await _dio.get(
        '$_jikanBaseUrl/anime/$animeId/characters',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final characterList = data['data'] as List;

        return characterList.map((item) {
          final character = item['character'] as Map<String, dynamic>;
          final voiceActors = item['voice_actors'] as List? ?? [];
          final voiceActor = voiceActors.isNotEmpty
              ? voiceActors.first['person']['name'] as String? ?? ''
              : '';
          final voiceActorImage = voiceActors.isNotEmpty
              ? voiceActors.first['person']['images']['jpg']['image_url']
                        as String? ??
                    ''
              : '';

          return AnimeCharacter(
            id: character['mal_id'].toString(),
            name: character['name'] as String,
            japaneseName: character['name_kanji'] as String? ?? '',
            nickname: character['nicknames']?.join(', ') ?? '',
            animeName: '', // Will be populated separately
            imageUrl: character['images']['jpg']['image_url'] as String,
            imageUrls: [
              character['images']['jpg']['image_url'] as String,
              if (character['images']['jpg']['small_image_url'] != null)
                character['images']['jpg']['small_image_url'] as String,
            ],
            description: character['about'] as String? ?? '',
            tags: [],
            source: 'jikan',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            role: item['role'] as String? ?? 'Unknown',
            voiceActor: voiceActor,
            voiceActorImage: voiceActorImage,
            externalIds: {
              'mal_id': character['mal_id'],
              'url': character['url'],
            },
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching anime characters: $e');
      return [];
    }
  }

  /// Search characters using Jikan API
  Future<List<AnimeCharacter>> searchCharacters(
    String query, {
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '$_jikanBaseUrl/characters',
        queryParameters: {
          'q': query,
          'limit': limit,
          'order_by': 'favorites',
          'sort': 'desc',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final characterList = data['data'] as List;

        return characterList.map((character) {
          return AnimeCharacter(
            id: character['mal_id'].toString(),
            name: character['name'] as String,
            japaneseName: character['name_kanji'] as String? ?? '',
            nickname: character['nicknames']?.join(', ') ?? '',
            animeName: character['anime']?.isNotEmpty == true
                ? character['anime'][0]['anime']['title'] as String
                : '',
            imageUrl: character['images']['jpg']['image_url'] as String,
            imageUrls: [
              character['images']['jpg']['image_url'] as String,
              if (character['images']['jpg']['small_image_url'] != null)
                character['images']['jpg']['small_image_url'] as String,
            ],
            description: character['about'] as String? ?? '',
            tags: [],
            source: 'jikan',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            externalIds: {
              'mal_id': character['mal_id'],
              'url': character['url'],
            },
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error searching characters: $e');
      return [];
    }
  }

  /// Get character details by ID using Jikan API
  Future<AnimeCharacter?> getCharacterById(String id) async {
    try {
      final response = await _dio.get('$_jikanBaseUrl/characters/$id');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final character = data['data'] as Map<String, dynamic>;

        return AnimeCharacter(
          id: character['mal_id'].toString(),
          name: character['name'] as String,
          japaneseName: character['name_kanji'] as String? ?? '',
          nickname: character['nicknames']?.join(', ') ?? '',
          animeName: '', // Will be populated from anime data
          imageUrl: character['images']['jpg']['image_url'] as String,
          imageUrls: [
            character['images']['jpg']['image_url'] as String,
            if (character['images']['jpg']['small_image_url'] != null)
              character['images']['jpg']['small_image_url'] as String,
          ],
          description: character['about'] as String? ?? '',
          tags: [],
          source: 'jikan',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          externalIds: {'mal_id': character['mal_id'], 'url': character['url']},
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching character details: $e');
      return null;
    }
  }

  /// Get top/popular anime using Jikan API
  Future<List<AnimeInfo>> getTopAnime({
    String type = 'tv',
    String filter = 'bypopularity',
    int limit = 25,
  }) async {
    try {
      final response = await _dio.get(
        '$_jikanBaseUrl/top/anime',
        queryParameters: {'type': type, 'filter': filter, 'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final animeList = data['data'] as List;
        return animeList.map((anime) => AnimeInfo.fromJson(anime)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching top anime: $e');
      return [];
    }
  }

  /// Get seasonal anime using Jikan API
  Future<List<AnimeInfo>> getSeasonalAnime({
    int? year,
    String season = 'now',
    int limit = 25,
  }) async {
    try {
      final currentYear = year ?? DateTime.now().year;
      final response = await _dio.get(
        '$_jikanBaseUrl/seasons/$currentYear/$season',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final animeList = data['data'] as List;
        return animeList.map((anime) => AnimeInfo.fromJson(anime)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching seasonal anime: $e');
      return [];
    }
  }

  /// Search using AniList GraphQL API
  Future<List<AnimeInfo>> searchAnimeAniList(
    String query, {
    int limit = 10,
  }) async {
    try {
      const graphqlQuery = '''
        query (\$search: String, \$perPage: Int) {
          Page(perPage: \$perPage) {
            media(search: \$search, type: ANIME) {
              id
              title {
                romaji
                english
                native
              }
              description
              coverImage {
                large
                medium
              }
              bannerImage
              episodes
              duration
              status
              averageScore
              popularity
              genres
              studios {
                nodes {
                  name
                }
              }
              season
              seasonYear
              trailer {
                id
                site
              }
            }
          }
        }
      ''';

      final response = await _dio.post(
        _anilistUrl,
        data: {
          'query': graphqlQuery,
          'variables': {'search': query, 'perPage': limit},
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final mediaList = data['data']['Page']['media'] as List;

        return mediaList.map((media) {
          return AnimeInfo(
            id: media['id'].toString(),
            title: media['title']['romaji'] as String? ?? '',
            englishTitle: media['title']['english'] as String? ?? '',
            japaneseTitle: media['title']['native'] as String? ?? '',
            synopsis: media['description'] as String? ?? '',
            imageUrl: media['coverImage']['large'] as String? ?? '',
            trailerUrl: media['trailer'] != null
                ? 'https://www.youtube.com/watch?v=${media['trailer']['id']}'
                : '',
            status: media['status'] as String? ?? '',
            type: 'ANIME',
            episodes: media['episodes'] as int? ?? 0,
            duration: media['duration'] as int? ?? 0,
            rating: '',
            score: (media['averageScore'] as num?)?.toDouble() ?? 0.0,
            popularity: media['popularity'] as int? ?? 0,
            rank: 0,
            source: 'anilist',
            genres: List<String>.from(media['genres'] as List? ?? []),
            themes: [],
            demographics: [],
            studios:
                (media['studios']['nodes'] as List?)
                    ?.map((studio) => studio['name'] as String)
                    .toList() ??
                [],
            producers: [],
            titles: {
              'romaji': media['title']['romaji'] as String? ?? '',
              'english': media['title']['english'] as String? ?? '',
              'native': media['title']['native'] as String? ?? '',
            },
            season: media['season'] as String? ?? '',
            year: media['seasonYear'] as int? ?? DateTime.now().year,
            external: {'anilist_id': media['id']},
          );
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error searching anime on AniList: $e');
      return [];
    }
  }

  /// Get random waifu/character image
  Future<String?> getRandomCharacterImage({String category = 'waifu'}) async {
    try {
      final response = await _dio.get('$_waifuPicsUrl/sfw/$category');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['url'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching random character image: $e');
      return null;
    }
  }

  /// Trace anime from image using trace.moe
  Future<Map<String, dynamic>?> traceAnimeFromImage(String imageUrl) async {
    try {
      final response = await _dio.get(
        '$_traceMoeUrl/search',
        queryParameters: {'url': imageUrl},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data;
      }
      return null;
    } catch (e) {
      debugPrint('Error tracing anime from image: $e');
      return null;
    }
  }

  /// Get anime recommendations
  Future<List<AnimeInfo>> getRecommendations(String animeId) async {
    try {
      final response = await _dio.get(
        '$_jikanBaseUrl/anime/$animeId/recommendations',
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final recommendations = data['data'] as List;

        return recommendations.map((rec) {
          final entry = rec['entry'] as Map<String, dynamic>;
          return AnimeInfo.fromJson(entry);
        }).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching recommendations: $e');
      return [];
    }
  }

  /// Get anime by genre
  Future<List<AnimeInfo>> getAnimeByGenre(
    String genre, {
    int limit = 25,
  }) async {
    try {
      final response = await _dio.get(
        '$_jikanBaseUrl/anime',
        queryParameters: {
          'genres': genre,
          'limit': limit,
          'order_by': 'popularity',
          'sort': 'desc',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final animeList = data['data'] as List;
        return animeList.map((anime) => AnimeInfo.fromJson(anime)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching anime by genre: $e');
      return [];
    }
  }

  /// Get currently airing anime
  Future<List<AnimeInfo>> getCurrentlyAiring({int limit = 25}) async {
    try {
      final response = await _dio.get(
        '$_jikanBaseUrl/anime',
        queryParameters: {
          'status': 'airing',
          'limit': limit,
          'order_by': 'popularity',
          'sort': 'desc',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final animeList = data['data'] as List;
        return animeList.map((anime) => AnimeInfo.fromJson(anime)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching currently airing anime: $e');
      return [];
    }
  }
}
