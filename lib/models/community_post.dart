import 'himx_photo.dart';
import 'himx_user_role.dart';

/// 社区帖子模型 - 展示用户与AI角色互动的内容
class CommunityPost {
  final int id;
  final String roleId;
  final String roleName;
  final String roleImageUrl;
  final String contentType; // dating / outfit
  final String imageUrl;
  final String aspectRatio; // "3:4" 或 "9:16"
  final String? location;
  final DateTime createdAt;

  CommunityPost({
    required this.id,
    required this.roleId,
    required this.roleName,
    required this.roleImageUrl,
    required this.contentType,
    required this.imageUrl,
    required this.aspectRatio,
    this.location,
    required this.createdAt,
  });

  /// 从 HimxPhoto 和角色信息创建
  factory CommunityPost.fromPhoto(
    HimxPhoto photo,
    HimxUserRole role,
    String type,
  ) {
    return CommunityPost(
      id: photo.id,
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
}
