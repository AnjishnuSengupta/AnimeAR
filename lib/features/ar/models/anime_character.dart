import 'anime_info.dart';

class AnimeCharacter {
  final String id;
  final String name;
  final String japaneseName;
  final String nickname;
  final String animeName;
  final AnimeInfo? animeInfo;
  final String imageUrl;
  final List<String> imageUrls; // Multiple character images
  final String description;
  final List<String> tags;
  final String source; // anime series source
  final DateTime createdAt;
  final DateTime updatedAt;
  final double confidence; // detection confidence
  final Map<String, dynamic> metadata;

  // Character specific details
  final String role; // main, supporting, minor
  final String voiceActor;
  final String voiceActorImage;
  final int age;
  final String gender;
  final String birthday;
  final String bloodType;
  final String height;
  final String weight;
  final List<String> abilities;
  final List<String> quotes;
  final Map<String, dynamic> relationships; // family, friends, etc.
  final Map<String, dynamic> externalIds; // MAL ID, AniList ID, etc.

  const AnimeCharacter({
    required this.id,
    required this.name,
    this.japaneseName = '',
    this.nickname = '',
    required this.animeName,
    this.animeInfo,
    required this.imageUrl,
    this.imageUrls = const [],
    required this.description,
    required this.tags,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.confidence = 0.0,
    this.metadata = const {},
    this.role = 'Unknown',
    this.voiceActor = '',
    this.voiceActorImage = '',
    this.age = 0,
    this.gender = 'Unknown',
    this.birthday = '',
    this.bloodType = '',
    this.height = '',
    this.weight = '',
    this.abilities = const [],
    this.quotes = const [],
    this.relationships = const {},
    this.externalIds = const {},
  });

  factory AnimeCharacter.fromJson(Map<String, dynamic> json) {
    return AnimeCharacter(
      id: json['id'] as String,
      name: json['name'] as String,
      japaneseName: json['japanese_name'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      animeName: json['animeName'] as String,
      animeInfo: json['anime_info'] != null
          ? AnimeInfo.fromJson(json['anime_info'] as Map<String, dynamic>)
          : null,
      imageUrl: json['imageUrl'] as String,
      imageUrls: List<String>.from(json['image_urls'] as List? ?? []),
      description: json['description'] as String,
      tags: List<String>.from(json['tags'] as List),
      source: json['source'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      role: json['role'] as String? ?? 'Unknown',
      voiceActor: json['voice_actor'] as String? ?? '',
      voiceActorImage: json['voice_actor_image'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      gender: json['gender'] as String? ?? 'Unknown',
      birthday: json['birthday'] as String? ?? '',
      bloodType: json['blood_type'] as String? ?? '',
      height: json['height'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      abilities: List<String>.from(json['abilities'] as List? ?? []),
      quotes: List<String>.from(json['quotes'] as List? ?? []),
      relationships: Map<String, dynamic>.from(
        json['relationships'] as Map? ?? {},
      ),
      externalIds: Map<String, dynamic>.from(
        json['external_ids'] as Map? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'japanese_name': japaneseName,
      'nickname': nickname,
      'animeName': animeName,
      'anime_info': animeInfo?.toJson(),
      'imageUrl': imageUrl,
      'image_urls': imageUrls,
      'description': description,
      'tags': tags,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'confidence': confidence,
      'metadata': metadata,
      'role': role,
      'voice_actor': voiceActor,
      'voice_actor_image': voiceActorImage,
      'age': age,
      'gender': gender,
      'birthday': birthday,
      'blood_type': bloodType,
      'height': height,
      'weight': weight,
      'abilities': abilities,
      'quotes': quotes,
      'relationships': relationships,
      'external_ids': externalIds,
    };
  }

  AnimeCharacter copyWith({
    String? id,
    String? name,
    String? japaneseName,
    String? nickname,
    String? animeName,
    AnimeInfo? animeInfo,
    String? imageUrl,
    List<String>? imageUrls,
    String? description,
    List<String>? tags,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? confidence,
    Map<String, dynamic>? metadata,
    String? role,
    String? voiceActor,
    String? voiceActorImage,
    int? age,
    String? gender,
    String? birthday,
    String? bloodType,
    String? height,
    String? weight,
    List<String>? abilities,
    List<String>? quotes,
    Map<String, dynamic>? relationships,
    Map<String, dynamic>? externalIds,
  }) {
    return AnimeCharacter(
      id: id ?? this.id,
      name: name ?? this.name,
      japaneseName: japaneseName ?? this.japaneseName,
      nickname: nickname ?? this.nickname,
      animeName: animeName ?? this.animeName,
      animeInfo: animeInfo ?? this.animeInfo,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      confidence: confidence ?? this.confidence,
      metadata: metadata ?? this.metadata,
      role: role ?? this.role,
      voiceActor: voiceActor ?? this.voiceActor,
      voiceActorImage: voiceActorImage ?? this.voiceActorImage,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      birthday: birthday ?? this.birthday,
      bloodType: bloodType ?? this.bloodType,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      abilities: abilities ?? this.abilities,
      quotes: quotes ?? this.quotes,
      relationships: relationships ?? this.relationships,
      externalIds: externalIds ?? this.externalIds,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnimeCharacter && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AnimeCharacter(id: $id, name: $name, animeName: $animeName)';
  }
}
