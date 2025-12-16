import 'api_client.dart';
import 'package:himx/models/chat_message.dart';
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
}
