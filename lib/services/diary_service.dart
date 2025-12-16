import 'package:flutter/material.dart';

import '../models/diary_entry.dart';
import 'package:himx/services/api_client.dart';

class DiaryService {
  final ApiClient _apiClient = ApiClient();

  /// 获取日记列表
  /// [roleId] 角色ID
  /// [pageSize] 每页条数
  /// [pageNumber] 页码
  Future<List<DiaryEntry>> getDiaryList({required String roleId, int pageSize = 20, int pageNumber = 1}) async {
    try {
      final response = await _apiClient.get<List<DiaryEntry>>(
        path: '/rest/v1/himx/diary/list',
        queryParameters: {'role_id': roleId, 'page_size': pageSize, 'page_number': pageNumber},
        fromJson: (json) {
          if (json is List) {
            return json.map((item) => DiaryEntry.fromJson(item)).toList();
          }
          return [];
        },
      );
      return response;
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Failed to get diary list: $e');
    }
  }

  /// 创建日记
  Future<DiaryEntry> createDiary({
    required String roleId,
    required DiaryType type,
    required String title,
    required String content,
    required DateTime timestamp,
    List<String>? mediaUrls,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _apiClient.post<DiaryEntry>(
        path: '/rest/v1/himx/diary',
        data: {
          'role_id': roleId,
          'type': type.toString().split('.').last,
          'title': title,
          'content': content,
          'timestamp': timestamp.toIso8601String(),
          'media_urls': mediaUrls ?? [],
          'metadata': metadata ?? {},
        },
        fromJson: (json) => DiaryEntry.fromJson(json),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to create diary: $e');
    }
  }

  /// 更新日记
  Future<DiaryEntry> updateDiary({
    required int diaryId,
    String? title,
    String? content,
    DateTime? timestamp,
    List<String>? mediaUrls,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (timestamp != null) data['timestamp'] = timestamp.toIso8601String();
      if (mediaUrls != null) data['media_urls'] = mediaUrls;
      if (metadata != null) data['metadata'] = metadata;

      final response = await _apiClient.put<DiaryEntry>(
        path: '/rest/v1/himx/diary/$diaryId',
        data: data,
        fromJson: (json) => DiaryEntry.fromJson(json),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to update diary: $e');
    }
  }

  /// 删除日记
  Future<void> deleteDiary(int diaryId) async {
    try {
      await _apiClient.delete(path: '/rest/v1/himx/diary/$diaryId', fromJson: (json) => null);
    } catch (e) {
      throw Exception('Failed to delete diary: $e');
    }
  }
}
