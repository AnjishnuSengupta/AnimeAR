class AnimeInfo {
  final String id;
  final String title;
  final String englishTitle;
  final String japaneseTitle;
  final String synopsis;
  final String imageUrl;
  final String trailerUrl;
  final String status; // airing, completed, upcoming
  final String type; // TV, Movie, OVA, Special, ONA
  final int episodes;
  final int duration; // in minutes
  final String rating; // G, PG, PG-13, R
  final double score;
  final int popularity;
  final int rank;
  final String source; // manga, novel, original
  final List<String> genres;
  final List<String> themes;
  final List<String> demographics;
  final List<String> studios;
  final List<String> producers;
  final Map<String, String> titles; // Different language titles
  final DateTime? startDate;
  final DateTime? endDate;
  final String season; // spring, summer, fall, winter
  final int year;
  final Map<String, dynamic> external; // MAL ID, AniList ID, etc.
  final Map<String, dynamic> metadata;

  const AnimeInfo({
    required this.id,
    required this.title,
    required this.englishTitle,
    required this.japaneseTitle,
    required this.synopsis,
    required this.imageUrl,
    required this.trailerUrl,
    required this.status,
    required this.type,
    required this.episodes,
    required this.duration,
    required this.rating,
    required this.score,
    required this.popularity,
    required this.rank,
    required this.source,
    required this.genres,
    required this.themes,
    required this.demographics,
    required this.studios,
    required this.producers,
    required this.titles,
    this.startDate,
    this.endDate,
    required this.season,
    required this.year,
    this.external = const {},
    this.metadata = const {},
  });

  factory AnimeInfo.fromJson(Map<String, dynamic> json) {
    return AnimeInfo(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      englishTitle:
          json['title_english'] as String? ?? json['title'] as String? ?? '',
      japaneseTitle: json['title_japanese'] as String? ?? '',
      synopsis: json['synopsis'] as String? ?? '',
      imageUrl: _extractImageUrl(json),
      trailerUrl: _extractTrailerUrl(json),
      status: json['status'] as String? ?? 'Unknown',
      type: json['type'] as String? ?? 'Unknown',
      episodes: json['episodes'] as int? ?? 0,
      duration: json['duration'] as int? ?? 0,
      rating: json['rating'] as String? ?? 'Unknown',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      popularity: json['popularity'] as int? ?? 0,
      rank: json['rank'] as int? ?? 0,
      source: json['source'] as String? ?? 'Unknown',
      genres: _extractStringList(json['genres']),
      themes: _extractStringList(json['themes']),
      demographics: _extractStringList(json['demographics']),
      studios: _extractStringList(json['studios']),
      producers: _extractStringList(json['producers']),
      titles: Map<String, String>.from(json['titles'] as Map? ?? {}),
      startDate: _parseDate(json['aired']?['from'] ?? json['start_date']),
      endDate: _parseDate(json['aired']?['to'] ?? json['end_date']),
      season: json['season'] as String? ?? 'Unknown',
      year: json['year'] as int? ?? DateTime.now().year,
      external: Map<String, dynamic>.from(json['external_links'] as Map? ?? {}),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  static String _extractImageUrl(Map<String, dynamic> json) {
    if (json['images'] != null) {
      final images = json['images'] as Map<String, dynamic>;
      if (images['jpg'] != null) {
        return images['jpg']['large_image_url'] as String? ??
            images['jpg']['image_url'] as String? ??
            '';
      }
    }
    return json['image_url'] as String? ?? json['cover_image'] as String? ?? '';
  }

  static String _extractTrailerUrl(Map<String, dynamic> json) {
    if (json['trailer'] != null) {
      final trailer = json['trailer'] as Map<String, dynamic>;
      return trailer['url'] as String? ?? trailer['embed_url'] as String? ?? '';
    }
    return json['trailer_url'] as String? ?? '';
  }

  static List<String> _extractStringList(dynamic data) {
    if (data == null) return [];
    if (data is List) {
      return data
          .map((item) {
            if (item is String) return item;
            if (item is Map) return item['name'] as String? ?? '';
            return item.toString();
          })
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return [];
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'title_english': englishTitle,
      'title_japanese': japaneseTitle,
      'synopsis': synopsis,
      'image_url': imageUrl,
      'trailer_url': trailerUrl,
      'status': status,
      'type': type,
      'episodes': episodes,
      'duration': duration,
      'rating': rating,
      'score': score,
      'popularity': popularity,
      'rank': rank,
      'source': source,
      'genres': genres,
      'themes': themes,
      'demographics': demographics,
      'studios': studios,
      'producers': producers,
      'titles': titles,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'season': season,
      'year': year,
      'external_links': external,
      'metadata': metadata,
    };
  }

  AnimeInfo copyWith({
    String? id,
    String? title,
    String? englishTitle,
    String? japaneseTitle,
    String? synopsis,
    String? imageUrl,
    String? trailerUrl,
    String? status,
    String? type,
    int? episodes,
    int? duration,
    String? rating,
    double? score,
    int? popularity,
    int? rank,
    String? source,
    List<String>? genres,
    List<String>? themes,
    List<String>? demographics,
    List<String>? studios,
    List<String>? producers,
    Map<String, String>? titles,
    DateTime? startDate,
    DateTime? endDate,
    String? season,
    int? year,
    Map<String, dynamic>? external,
    Map<String, dynamic>? metadata,
  }) {
    return AnimeInfo(
      id: id ?? this.id,
      title: title ?? this.title,
      englishTitle: englishTitle ?? this.englishTitle,
      japaneseTitle: japaneseTitle ?? this.japaneseTitle,
      synopsis: synopsis ?? this.synopsis,
      imageUrl: imageUrl ?? this.imageUrl,
      trailerUrl: trailerUrl ?? this.trailerUrl,
      status: status ?? this.status,
      type: type ?? this.type,
      episodes: episodes ?? this.episodes,
      duration: duration ?? this.duration,
      rating: rating ?? this.rating,
      score: score ?? this.score,
      popularity: popularity ?? this.popularity,
      rank: rank ?? this.rank,
      source: source ?? this.source,
      genres: genres ?? this.genres,
      themes: themes ?? this.themes,
      demographics: demographics ?? this.demographics,
      studios: studios ?? this.studios,
      producers: producers ?? this.producers,
      titles: titles ?? this.titles,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      season: season ?? this.season,
      year: year ?? this.year,
      external: external ?? this.external,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnimeInfo && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AnimeInfo(id: $id, title: $title, englishTitle: $englishTitle)';
  }
}
