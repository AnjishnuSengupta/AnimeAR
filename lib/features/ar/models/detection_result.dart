// Import the AnimeCharacter model
import 'anime_character.dart';

class DetectionResult {
  final String id;
  final AnimeCharacter character;
  final double confidence;
  final DateTime detectedAt;
  final String userId;
  final Map<String, dynamic> boundingBox; // x, y, width, height
  final String imageUrl; // captured image
  final Map<String, dynamic> metadata;

  const DetectionResult({
    required this.id,
    required this.character,
    required this.confidence,
    required this.detectedAt,
    required this.userId,
    required this.boundingBox,
    required this.imageUrl,
    this.metadata = const {},
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      id: json['id'] as String,
      character: AnimeCharacter.fromJson(
        json['character'] as Map<String, dynamic>,
      ),
      confidence: (json['confidence'] as num).toDouble(),
      detectedAt: DateTime.parse(json['detectedAt'] as String),
      userId: json['userId'] as String,
      boundingBox: json['boundingBox'] as Map<String, dynamic>,
      imageUrl: json['imageUrl'] as String,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'character': character.toJson(),
      'confidence': confidence,
      'detectedAt': detectedAt.toIso8601String(),
      'userId': userId,
      'boundingBox': boundingBox,
      'imageUrl': imageUrl,
      'metadata': metadata,
    };
  }

  DetectionResult copyWith({
    String? id,
    AnimeCharacter? character,
    double? confidence,
    DateTime? detectedAt,
    String? userId,
    Map<String, dynamic>? boundingBox,
    String? imageUrl,
    Map<String, dynamic>? metadata,
  }) {
    return DetectionResult(
      id: id ?? this.id,
      character: character ?? this.character,
      confidence: confidence ?? this.confidence,
      detectedAt: detectedAt ?? this.detectedAt,
      userId: userId ?? this.userId,
      boundingBox: boundingBox ?? this.boundingBox,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DetectionResult && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'DetectionResult(id: $id, character: ${character.name}, confidence: $confidence)';
  }
}
