import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime lastSignIn;
  final int arSessionsCount;
  final int discoveredLocationsCount;
  final List<String> favoriteCharacters;
  final Map<String, dynamic> preferences;
  final DateTime? lastARSession;
  final DateTime? lastDiscovery;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoURL,
    required this.createdAt,
    required this.lastSignIn,
    this.arSessionsCount = 0,
    this.discoveredLocationsCount = 0,
    this.favoriteCharacters = const [],
    this.preferences = const {},
    this.lastARSession,
    this.lastDiscovery,
  });

  /// Creates UserProfile from Firestore document
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserProfile(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'],
      createdAt: _parseTimestamp(data['createdAt']) ?? DateTime.now(),
      lastSignIn: _parseTimestamp(data['lastSignIn']) ?? DateTime.now(),
      arSessionsCount: data['arSessionsCount'] ?? 0,
      discoveredLocationsCount: data['discoveredLocationsCount'] ?? 0,
      favoriteCharacters: List<String>.from(data['favoriteCharacters'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      lastARSession: _parseTimestamp(data['lastARSession']),
      lastDiscovery: _parseTimestamp(data['lastDiscovery']),
    );
  }

  /// Safely parses timestamp from Firestore data
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;

    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }

    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        print('⚠️ UserProfile: Failed to parse timestamp string: $timestamp');
        return null;
      }
    }

    if (timestamp is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(timestamp);
      } catch (e) {
        print('⚠️ UserProfile: Failed to parse timestamp int: $timestamp');
        return null;
      }
    }

    print('⚠️ UserProfile: Unknown timestamp type: ${timestamp.runtimeType}');
    return null;
  }

  /// Converts UserProfile to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastSignIn': Timestamp.fromDate(lastSignIn),
      'arSessionsCount': arSessionsCount,
      'discoveredLocationsCount': discoveredLocationsCount,
      'favoriteCharacters': favoriteCharacters,
      'preferences': preferences,
      if (lastARSession != null)
        'lastARSession': Timestamp.fromDate(lastARSession!),
      if (lastDiscovery != null)
        'lastDiscovery': Timestamp.fromDate(lastDiscovery!),
    };
  }

  /// Creates a copy of this UserProfile with updated fields
  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    DateTime? createdAt,
    DateTime? lastSignIn,
    int? arSessionsCount,
    int? discoveredLocationsCount,
    List<String>? favoriteCharacters,
    Map<String, dynamic>? preferences,
    DateTime? lastARSession,
    DateTime? lastDiscovery,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      lastSignIn: lastSignIn ?? this.lastSignIn,
      arSessionsCount: arSessionsCount ?? this.arSessionsCount,
      discoveredLocationsCount:
          discoveredLocationsCount ?? this.discoveredLocationsCount,
      favoriteCharacters: favoriteCharacters ?? this.favoriteCharacters,
      preferences: preferences ?? this.preferences,
      lastARSession: lastARSession ?? this.lastARSession,
      lastDiscovery: lastDiscovery ?? this.lastDiscovery,
    );
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, email: $email, displayName: $displayName, '
        'arSessionsCount: $arSessionsCount, discoveredLocationsCount: $discoveredLocationsCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserProfile && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;
}
