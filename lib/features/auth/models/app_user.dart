class AppUser {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final List<String> favoriteCharacters;
  final List<String> discoveredCharacters;
  final int level;
  final int experiencePoints;

  const AppUser({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
    required this.createdAt,
    required this.lastLoginAt,
    this.favoriteCharacters = const [],
    this.discoveredCharacters = const [],
    this.level = 1,
    this.experiencePoints = 0,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      favoriteCharacters: List<String>.from(json['favoriteCharacters'] ?? []),
      discoveredCharacters: List<String>.from(
        json['discoveredCharacters'] ?? [],
      ),
      level: json['level'] as int? ?? 1,
      experiencePoints: json['experiencePoints'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
      'favoriteCharacters': favoriteCharacters,
      'discoveredCharacters': discoveredCharacters,
      'level': level,
      'experiencePoints': experiencePoints,
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    List<String>? favoriteCharacters,
    List<String>? discoveredCharacters,
    int? level,
    int? experiencePoints,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      favoriteCharacters: favoriteCharacters ?? this.favoriteCharacters,
      discoveredCharacters: discoveredCharacters ?? this.discoveredCharacters,
      level: level ?? this.level,
      experiencePoints: experiencePoints ?? this.experiencePoints,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.photoUrl == photoUrl &&
        other.createdAt == createdAt &&
        other.lastLoginAt == lastLoginAt &&
        other.level == level &&
        other.experiencePoints == experiencePoints;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      email,
      name,
      photoUrl,
      createdAt,
      lastLoginAt,
      level,
      experiencePoints,
    );
  }

  @override
  String toString() {
    return 'AppUser(id: $id, email: $email, name: $name, level: $level)';
  }
}
