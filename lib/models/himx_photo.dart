class HimxPhoto {
  final int id;
  final String userId;
  final String roleId;
  final String imageUrl;
  final String? prompt;
  final String characterImageUrl;
  final String? userImageUrl;
  final String aspectRatio;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  HimxPhoto({
    required this.id,
    required this.userId,
    required this.roleId,
    required this.imageUrl,
    this.prompt,
    required this.characterImageUrl,
    this.userImageUrl,
    required this.aspectRatio,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convenience getter for location from metadata
  String? get location => metadata?['location'] as String?;

  factory HimxPhoto.fromJson(Map<String, dynamic> json) {
    return HimxPhoto(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      roleId: json['role_id'] as String,
      imageUrl: json['image_url'] as String,
      prompt: json['prompt'] as String?,
      characterImageUrl: json['character_image_url'] as String,
      userImageUrl: json['user_image_url'] as String?,
      aspectRatio: json['aspect_ratio'] as String? ?? '3:4',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'role_id': roleId,
      'image_url': imageUrl,
      'prompt': prompt,
      'character_image_url': characterImageUrl,
      'user_image_url': userImageUrl,
      'aspect_ratio': aspectRatio,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
