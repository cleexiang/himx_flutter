import 'api_client.dart';
import 'dart:async';
import 'package:himx/models/himx_role.dart';
import 'package:himx/models/himx_user_role.dart';

class HimxApi {
  final ApiClient _apiClient = ApiClient();

  /// 推荐角色列表（首页"发现更多"）
  Future<List<HimxRole>> getRecommendedRoles() async {
    return _apiClient.get<List<HimxRole>>(
      path: '/rest/v1/himx/roles/recommended',
      fromJson: (json) {
        final List<dynamic> data = json as List<dynamic>;
        return data.map((item) => HimxRole.fromJson(item as Map<String, dynamic>)).toList();
      },
    );
  }

  /// 我的角色列表（首页"我的约会"）- 包含用户设置
  Future<List<HimxUserRole>> getMyRoles() async {
    return _apiClient.get<List<HimxUserRole>>(
      path: '/rest/v1/himx/roles/my',
      fromJson: (json) {
        final List<dynamic> data = json as List<dynamic>;
        return data.map((item) => HimxUserRole.fromJson(item as Map<String, dynamic>)).toList();
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
}

/// 聊天消息模型
class ChatMessage {
  final int id;
  final String? q;
  final String? a;
  final String? createdTime;

  ChatMessage({required this.id, this.q, this.a, this.createdTime});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      q: json['q'] as String?,
      a: json['a'] as String?,
      createdTime: json['created_time'] as String?,
    );
  }
}

/// 聊天响应模型
class ChatResponse {
  final ChatMessage message;

  ChatResponse({required this.message});

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(message: ChatMessage.fromJson(json['message'] as Map<String, dynamic>));
  }
}
