import 'package:himx/models/user_model.dart';
import 'package:himx/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GlobalData {
  static final GlobalData _instance = GlobalData._internal();
  static const String env = String.fromEnvironment('env', defaultValue: 'prod');

  UserInfo? _user;
  String? _token;

  factory GlobalData() => _instance;
  GlobalData._internal();

  UserInfo? get user => _user;

  String? get token => _token;

  Future<void> setUser(UserInfo? user) async {
    _user = user;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (user != null) {
      await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));
    } else {
      await prefs.remove(AppConstants.userKey);
    }
  }

  Future<void> setToken(String? token) async {
    _token = token;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (token != null) {
      await prefs.setString(AppConstants.userTokenKey, token);
    } else {
      await prefs.remove(AppConstants.userTokenKey);
    }
  }

  bool isFirstTimeUse = true;
  String appVersion = '';
  String osVersion = '';
  String deviceId = '';
  String deviceName = '';
  String currentLanguage = '';
  String currentRegion = '';

  /// Initializes global data by loading persisted user and profile data
  /// Returns true if initialization was successful
  Future<bool> initialize() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String? userData = prefs.getString(AppConstants.userKey);
      if (userData != null) {
        final json = jsonDecode(userData);
        _user = UserInfo.fromJson(json);
      }

      _token = prefs.getString(AppConstants.userTokenKey);

      return true;
    } catch (err) {
      print('Failed to initialize GlobalData: $err');
      return false;
    }
  }
}
