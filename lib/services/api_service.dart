import 'package:dio/dio.dart';
import '../models/boyfriend.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late Dio _dio;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: 'https://your-api-url.com/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<List<Boyfriend>> getBoyfriendList() async {
    try {
      final response = await _dio.get('/boyfriends');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Boyfriend.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load boyfriends');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<String> sendChatMessage({
    required String boyfriendId,
    required String message,
    required String nickname,
    required String personality,
    required String userNickname,
  }) async {
    try {
      final response = await _dio.post(
        '/chat',
        data: {
          'boyfriendId': boyfriendId,
          'message': message,
          'nickname': nickname,
          'personality': personality,
          'userNickname': userNickname,
        },
      );

      if (response.statusCode == 200) {
        return response.data['reply'] as String;
      } else {
        throw Exception('Failed to get chat response');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  Future<void> saveCharacterSettings({
    required String boyfriendId,
    required String nickname,
    required String personality,
    required String userNickname,
  }) async {
    try {
      await _dio.post(
        '/settings',
        data: {
          'boyfriendId': boyfriendId,
          'nickname': nickname,
          'personality': personality,
          'userNickname': userNickname,
        },
      );
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
