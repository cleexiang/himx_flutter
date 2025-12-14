import 'package:shared_preferences/shared_preferences.dart';
import 'package:himx/models/user_model.dart';
import 'package:himx/utils/constants.dart';
import 'dart:convert';

/// 认证服务 - 管理用户登录状态
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserInfo? _currentUser;
  String? _token;

  UserInfo? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _currentUser != null;

  /// 初始化 - 从本地加载用户信息
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(AppConstants.userTokenKey);
    
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      try {
        _currentUser = UserInfo.fromJson(json.decode(userJson));
      } catch (e) {
        print('Failed to parse user data: $e');
        await clearUserData();
      }
    }
  }

  /// 保存用户信息
  Future<void> saveUser(UserInfo user, String token) async {
    _currentUser = user;
    _token = token;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userTokenKey, token);
    await prefs.setString(AppConstants.userKey, json.encode(user.toJson()));
  }

  /// 更新用户信息
  Future<void> updateUser(UserInfo user) async {
    _currentUser = user;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.userKey, json.encode(user.toJson()));
  }

  /// 清除用户数据（登出）
  Future<void> clearUserData() async {
    _currentUser = null;
    _token = null;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.userTokenKey);
    await prefs.remove(AppConstants.userKey);
  }
}

