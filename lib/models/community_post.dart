import 'himx_photo.dart';
import 'himx_user_role.dart';

/// 社区帖子模型 - 展示用户与AI角色互动的内容
class CommunityPost {
  final int id;
  final String userId;
  final String userName;
  final String userAvatarUrl;
  final String roleId;
  final String roleName;
  final String roleImageUrl;
  final String contentType; // dating / outfit
  final String imageUrl;
  final String aspectRatio; // "3:4" 或 "9:16"
  final String? location;
  final DateTime createdAt;
  final int likeCount;
  final bool isLiked;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.roleId,
    required this.roleName,
    required this.roleImageUrl,
    required this.contentType,
    required this.imageUrl,
    required this.aspectRatio,
    this.location,
    required this.createdAt,
    this.likeCount = 0,
    this.isLiked = false,
  });

  /// 从 HimxPhoto 和角色信息创建
  factory CommunityPost.fromPhoto(
    HimxPhoto photo,
    HimxUserRole role,
    String type, {
    required String userId,
    required String userName,
    required String userAvatarUrl,
  }) {
    return CommunityPost(
      id: photo.id,
      userId: userId,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      roleId: photo.roleId,
      roleName: role.name,
      roleImageUrl: role.imageUrl,
      contentType: type,
      imageUrl: photo.imageUrl,
      aspectRatio: photo.aspectRatio,
      location: photo.location,
      createdAt: photo.createdAt,
    );
  }

  /// 计算显示用的宽高比
  double get displayAspectRatio {
    final parts = aspectRatio.split(':');
    if (parts.length == 2) {
      final width = double.tryParse(parts[0]) ?? 3;
      final height = double.tryParse(parts[1]) ?? 4;
      return width / height;
    }
    return 0.75; // 默认 3:4
  }

  /// 获取内容类型的显示名称
  String get contentTypeDisplay {
    switch (contentType) {
      case 'dating':
        return '约会';
      case 'outfit':
        return '换装';
      default:
        return contentType;
    }
  }

  /// 从 JSON 创建 CommunityPost
  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? json['userId'] ?? '',
      userName: json['user_name'] ?? json['userName'] ?? '',
      userAvatarUrl: json['user_avatar_url'] ?? json['userAvatarUrl'] ?? '',
      roleId: json['role_id'] ?? json['roleId'] ?? '',
      roleName: json['role_name'] ?? json['roleName'] ?? '',
      roleImageUrl: json['role_image_url'] ?? json['roleImageUrl'] ?? '',
      contentType: json['content_type'] ?? json['contentType'] ?? 'dating',
      imageUrl: json['image_url'] ?? json['imageUrl'] ?? '',
      aspectRatio: json['aspect_ratio'] ?? json['aspectRatio'] ?? '3:4',
      location: json['location'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : (json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now()),
      likeCount: json['like_count'] ?? json['likeCount'] ?? 0,
      isLiked: json['is_liked'] ?? json['isLiked'] ?? false,
    );
  }
}
