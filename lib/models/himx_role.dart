class HimxRole {
  final int id;
  final String roleId;
  final String name;
  final String imageUrl;
  final String? videoUrl;
  final String description;

  HimxRole({
    required this.id,
    required this.roleId,
    required this.name,
    required this.imageUrl,
    this.videoUrl,
    required this.description,
  });

  factory HimxRole.fromJson(Map<String, dynamic> json) {
    return HimxRole(
      id: json['id'] as int,
      roleId: json['roleId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      videoUrl: json['videoUrl'] as String?,
      description: json['description'] as String,
    );
  }
}
