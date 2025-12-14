class HimxUserRole {
  final int id;
  final String roleId;
  final String name;
  final String imageUrl;
  final String? videoUrl;
  final String description;

  /// friend | lover | married
  final String relationshipLevel;

  // 用户对角色的设置（CharacterSettings 字段整合进来）
  final String nickname;
  final String personality;
  final String userNickname;

  final String? createdAt;
  final String? updatedAt;

  HimxUserRole({
    required this.id,
    required this.roleId,
    required this.name,
    required this.imageUrl,
    this.videoUrl,
    required this.description,
    required this.relationshipLevel,
    this.nickname = '',
    this.personality = '',
    this.userNickname = '',
    this.createdAt,
    this.updatedAt,
  });

  factory HimxUserRole.fromJson(Map<String, dynamic> json) {
    return HimxUserRole(
      id: json['id'] as int,
      roleId: json['roleId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      videoUrl: json['videoUrl'] as String?,
      description: json['description'] as String,
      relationshipLevel: (json['relationshipLevel'] as String?) ?? 'friend',
      nickname: (json['nickname'] as String?) ?? '',
      personality: (json['personality'] as String?) ?? '',
      userNickname: (json['userNickname'] as String?) ?? '',
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
