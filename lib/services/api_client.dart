import 'dart:io';

import 'package:flutter/material.dart';
import 'package:himx/models/user_model.dart';
import 'package:himx/services/auth_service.dart';
import 'package:himx/utils/constants.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_response.dart';
import 'http_client.dart';

class ApiClient {
  final Dio _dio = HttpClient().dio;
  String? _token;

  // Public getter for Dio instance (needed for SSE connections)
  Dio get dio => _dio;

  Future<T> get<T>({
    required String path,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return _handleResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> post<T>({required String path, dynamic data, required T Function(dynamic json) fromJson}) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<T> put<T>({required String path, dynamic data, required T Function(dynamic json) fromJson}) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE 请求
  Future<T> delete<T>({required String path, required T Function(dynamic json) fromJson}) async {
    try {
      final response = await _dio.delete(path);
      return _handleResponse(response, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  T _handleResponse<T>(Response response, T Function(dynamic json) fromJson) {
    if (response.statusCode == 200) {
      final apiResponse = ApiResponse.fromJson(response.data, fromJson);
      if (apiResponse.code == "0") {
        // 后端返回 200 表示成功
        return apiResponse.data as T;
      } else {
        throw ApiException(int.parse(apiResponse.code ?? '-1'), apiResponse.message ?? 'Unknown error');
      }
    }
    throw ApiException(-1, 'Network error');
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      // 处理Dio错误
      return ApiException(error.response?.statusCode ?? -1, error.message ?? 'Network error');
    }
    return ApiException(-1, error.toString());
  }

  Future<UserInfo> loginWithDevice() async {
    try {
      final response = await post(path: AppConstants.loginEndpoint, fromJson: (json) => UserInfo.fromJson(json));

      if (response.token != null) {
        await AuthService().saveUser(response, response.token!);
      }
      return response;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Apple 登录
  Future<UserInfo> loginWithApple({required String user, required String fullName, required String email}) async {
    try {
      final response = await post(
        path: AppConstants.loginWithAppleEndpoint,
        data: {'user': user, 'fullName': fullName, 'email': email},
        fromJson: (json) => UserInfo.fromJson(json),
      );

      if (response.token != null) {
        await AuthService().saveUser(response, response.token!);
      }
      return response;
    } catch (e) {
      debugPrint(e.toString());
      throw Exception('Apple login failed: $e');
    }
  }

  Future<UserInfo> getUserInfo() async {
    try {
      final response = await get<UserInfo>(
        path: AppConstants.userInfoEndpoint,
        fromJson: (json) => UserInfo.fromJson(json),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to get user info: $e');
    }
  }

  Future<UserInfo> checkRevenuecatStatus() async {
    try {
      final response = await post<UserInfo>(
        path: AppConstants.checkRevenuecatStatusEndpoint,
        fromJson: (json) => UserInfo.fromJson(json),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to check revenuecat status: $e');
    }
  }

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

      final response = await _dio.post(AppConstants.uploadImageEndpoint, data: formData);

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

class ApiException implements Exception {
  final int code;
  final String message;

  ApiException(this.code, this.message);

  @override
  String toString() => 'ApiException: $code, $message';
}

// Add new exception class for insufficient credits
class InsufficientCreditsException implements Exception {
  final String message;

  InsufficientCreditsException(this.message);

  @override
  String toString() => 'InsufficientCreditsException: $message';
}
