class HimxRole {
  final int id;
  final String roleId;
  final String name;
  final String imageUrl;
  final String? videoUrl;
  final String? shortDescription;
  final String description;
  final String? firstMessage;
  final String? tags;
  final String? location;

  HimxRole({
    required this.id,
    required this.roleId,
    required this.name,
    required this.imageUrl,
    this.videoUrl,
    this.shortDescription,
    required this.description,
    this.firstMessage,
    this.tags,
    this.location,
  });

  factory HimxRole.fromJson(Map<String, dynamic> json) {
    return HimxRole(
      id: json['id'] as int,
      roleId: json['roleId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      videoUrl: json['videoUrl'] as String?,
      shortDescription: json['shortDescription'] as String?,
      description: json['description'] as String,
      firstMessage: json['first_message'] as String?,
      tags: json['tags'] as String?,
      location: json['location'] as String?,
    );
  }
}
