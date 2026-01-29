import 'dart:io';
import 'api_client.dart';
import 'package:himx/models/chat_message.dart';
import 'package:himx/models/community_post.dart';
import 'package:himx/models/himx_role.dart';
import 'package:himx/models/himx_user_role.dart';
import 'package:himx/models/himx_photo.dart';
import 'package:himx/models/user_model.dart';
import 'auth_service.dart';
import 'package:himx/utils/constants.dart';
import 'package:dio/dio.dart';

class HimxApi {
  final ApiClient _apiClient = ApiClient();

  /// 推荐角色列表（首页"发现更多"）
  Future<List<HimxRole>> getRecommendedRoles() async {
    return _apiClient.get<List<HimxRole>>(
      path: '/rest/v1/himx/roles/recommended',
      fromJson: (json) {
        final List<dynamic> data = json as List<dynamic>;
        return data
            .map((item) => HimxRole.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// 我的角色列表（首页"我的约会"）- 包含用户设置
  Future<List<HimxUserRole>> getMyRoles() async {
    return _apiClient.get<List<HimxUserRole>>(
      path: '/rest/v1/himx/roles/my',
      fromJson: (json) {
        final List<dynamic> data = json as List<dynamic>;
        return data
            .map((item) => HimxUserRole.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Start Dating：建立用户-角色关系并保存设置
  Future<void> startDating({
    required String roleId,
    required String nickname,
    required String personality,
    required String userNickname,
    String relationshipLevel = 'lover',
  }) async {
    await _apiClient.post<Map<String, dynamic>>(
      path: '/rest/v1/himx/roles/start',
      data: {
        'roleId': roleId,
        'relationshipLevel': relationshipLevel,
        'nickname': nickname,
        'personality': personality,
        'userNickname': userNickname,
      },
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// 聊天
  /// [roleId] 角色ID
  /// [q] 用户输入的问题
  /// [lang] 语言 (en/zh/ja/ko/es)
  /// 返回AI回复的ChatMessage
  Future<ChatMessage> chat({
    required int roleId,
    required String q,
    required String lang,
  }) async {
    return _apiClient.post<ChatMessage>(
      path: '/rest/v1/himx/chat',
      data: {'role_id': roleId, 'q': q, 'lang': lang},
      fromJson: (json) {
        // Response format: { "message": { "id":..., "q":..., "a":..., "created_time":... } }
        final msgData = json['message'] as Map<String, dynamic>;
        // We only care about the AI answer part for the return value
        // But we construct a ChatMessage from the answer
        final id = msgData['id'].toString();
        final createdTime =
            DateTime.tryParse(msgData['created_time'] ?? '') ?? DateTime.now();
        return ChatMessage(
          id: '${id}_a',
          content: msgData['a'] ?? '',
          isUser: false,
          timestamp: createdTime,
        );
      },
    );
  }

  /// 获取聊天记录
  /// [roleId] 角色ID
  /// 返回所有拆分后的消息列表（包括用户提问和AI回复）
  Future<List<ChatMessage>> getChatList({required int roleId}) async {
    return _apiClient.get<List<ChatMessage>>(
      path: '/rest/v1/himx/chat/list',
      queryParameters: {'role_id': roleId},
      fromJson: (json) {
        final List<dynamic> data = json as List<dynamic>;
        final List<ChatMessage> allMessages = [];
        for (var item in data) {
          allMessages.addAll(
            ChatMessage.listFromApiRecord(item as Map<String, dynamic>),
          );
        }
        return allMessages;
      },
    );
  }

  /// 生成约会照片
  /// [roleId] 角色ID
  /// [location] 约会地点
  /// [characterImageUrl] 角色图片URL
  /// [userImageUrl] 用户图片URL（可选）
  /// [aspectRatio] 图片宽高比（默认为"3:4"）
  /// 返回生成的照片数据
  Future<HimxPhoto> generateDatingPhoto({
    required String roleId,
    required String location,
    required String characterImageUrl,
    String? userImageUrl,
    String aspectRatio = '3:4',
  }) async {
    return _apiClient.post<HimxPhoto>(
      path: '/rest/v1/himx/dating/photo/generate',
      data: {
        'role_id': roleId,
        'location': location,
        'character_image_url': characterImageUrl,
        'user_image_url': userImageUrl,
        'aspect_ratio': aspectRatio,
      },
      fromJson: (json) => HimxPhoto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 生成装扮照片
  /// [roleId] 角色ID
  /// [characterImageUrl] 角色图片URL
  /// [outfitDescription] 装扮描述（可选）
  /// [referenceImageUrl] 参考图片URL（可选）
  /// [aspectRatio] 图片宽高比（默认为"3:4"）
  /// 返回生成的照片数据
  Future<HimxPhoto> generateOutfitPhoto({
    required String roleId,
    required String characterImageUrl,
    String? outfitDescription,
    String? referenceImageUrl,
    String aspectRatio = '3:4',
  }) async {
    return _apiClient.post<HimxPhoto>(
      path: '/rest/v1/himx/outfit/photo/generate',
      data: {
        'role_id': roleId,
        'character_image_url': characterImageUrl,
        'outfit_description': outfitDescription,
        'refence_image_url': referenceImageUrl,
        'aspect_ratio': aspectRatio,
      },
      fromJson: (json) => HimxPhoto.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取相册列表
  /// [roleId] 角色ID
  /// [type] 照片类型（dating|outfit）
  /// [pageSize] 每页数量（默认20）
  /// [pageNumber] 页码（默认1）
  /// 返回照片列表
  Future<List<HimxPhoto>> getPhotoList({
    required String roleId,
    String type = 'dating',
    int pageSize = 20,
    int pageNumber = 1,
  }) async {
    return _apiClient.get<List<HimxPhoto>>(
      path: '/rest/v1/himx/photo/list',
      queryParameters: {
        'role_id': roleId,
        'type': type,
        'page_size': pageSize,
        'page_number': pageNumber,
      },
      fromJson: (json) {
        final List<dynamic> data = json as List<dynamic>;
        return data
            .map((item) => HimxPhoto.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// 删除照片
  /// [photoId] 照片ID
  Future<void> deletePhoto({required int photoId}) async {
    await _apiClient.delete<Map<String, dynamic>>(
      path: '/rest/v1/himx/photo/$photoId',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// 分享内容到社区
  /// [photoId] 要分享的照片ID
  /// [roleId] 角色ID
  /// [contentType] 内容类型（dating|outfit）
  /// [description] 分享描述（可选）
  /// [location] 位置信息（可选）
  Future<CommunityPost> shareToCommunity({
    required int photoId,
    required String roleId,
    required String contentType,
    String? description,
    String? location,
  }) async {
    return _apiClient.post<CommunityPost>(
      path: '/rest/v1/himx/community/share',
      data: {
        'photo_id': photoId,
        'role_id': roleId,
        'content_type': contentType,
        'description': description,
        'location': location,
      },
      fromJson: (json) => CommunityPost.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 获取社区时间线
  /// [pageSize] 每页数量（默认20）
  /// [pageNumber] 页码（默认1）
  /// 返回社区时间线数据
  Future<List<CommunityPost>> getCommunityFeed({
    int pageSize = 20,
    int pageNumber = 1,
  }) async {
    return _apiClient.get<List<CommunityPost>>(
      path: '/rest/v1/himx/community/feed',
      queryParameters: {
        'page_size': pageSize,
        'page_number': pageNumber,
      },
      fromJson: (json) {
        final feedData = json as Map<String, dynamic>;
        final List<dynamic> posts = feedData['posts'] as List<dynamic>? ?? [];
        return posts
            .map((item) => CommunityPost.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// 点赞社区帖子
  /// [postId] 帖子ID
  Future<void> likeCommunityPost({required int postId}) async {
    await _apiClient.post<Map<String, dynamic>>(
      path: '/rest/v1/himx/community/like/$postId',
      data: {},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// 取消点赞社区帖子
  /// [postId] 帖子ID
  Future<void> unlikeCommunityPost({required int postId}) async {
    await _apiClient.delete<Map<String, dynamic>>(
      path: '/rest/v1/himx/community/like/$postId',
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  // =====================================================
  // 认证和账户相关接口
  // =====================================================

  /// 设备登录
  /// 返回用户信息和token
  Future<UserInfo> loginWithDevice() async {
    try {
      final response = await _apiClient.post<UserInfo>(
        path: AppConstants.loginEndpoint,
        fromJson: (json) => UserInfo.fromJson(json),
      );

      if (response.token != null) {
        await AuthService().saveUser(response, response.token!);
      }
      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Apple 登录
  /// [user] Apple用户ID
  /// [fullName] 用户全名
  /// [email] 用户邮箱
  /// 返回用户信息和token
  Future<UserInfo> loginWithApple({
    required String user,
    required String fullName,
    required String email,
  }) async {
    try {
      final response = await _apiClient.post<UserInfo>(
        path: AppConstants.loginWithAppleEndpoint,
        data: {'user': user, 'fullName': fullName, 'email': email},
        fromJson: (json) => UserInfo.fromJson(json),
      );

      if (response.token != null) {
        await AuthService().saveUser(response, response.token!);
      }
      return response;
    } catch (e) {
      throw Exception('Apple login failed: $e');
    }
  }

  /// 获取用户信息
  /// 返回当前登录用户的详细信息
  Future<UserInfo> getUserInfo() async {
    try {
      final response = await _apiClient.get<UserInfo>(
        path: AppConstants.userInfoEndpoint,
        fromJson: (json) => UserInfo.fromJson(json),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  /// 更新用户昵称
  /// [nickName] 新昵称
  /// 返回更新后的用户信息
  Future<UserInfo> updateNickname(String nickName) async {
    return _apiClient.put<UserInfo>(
      path: '/rest/v1/user/profile',
      data: {'nick_name': nickName},
      fromJson: (json) => UserInfo.fromJson(json as Map<String, dynamic>),
    );
  }

  /// 登出
  /// 调用后端登出接口清理会话
  Future<void> logout() async {
    await _apiClient.post<Map<String, dynamic>>(
      path: '/rest/v1/user/logout',
      data: {},
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  /// 检查 RevenueCat 订阅状态
  /// 返回更新后的用户信息
  Future<UserInfo> checkRevenuecatStatus() async {
    try {
      final response = await _apiClient.post<UserInfo>(
        path: AppConstants.checkRevenuecatStatusEndpoint,
        fromJson: (json) => UserInfo.fromJson(json),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to check revenuecat status: $e');
    }
  }

  // =====================================================
  // 文件上传接口
  // =====================================================

  /// 上传图片
  /// [imageFile] 要上传的图片文件
  /// 返回上传后的图片URL
  Future<String> uploadImage(File imageFile) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: DioMediaType.parse('image/jpeg'),
        ),
      });

      final response = await _apiClient.dio.post(
        AppConstants.uploadImageEndpoint,
        data: formData,
      );

      if (response.data['code'] == '0') {
        return response.data['data']['url'];
      } else {
        throw Exception(response.data['msg'] ?? 'Upload failed');
      }
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }
}
