import 'package:himx/models/user_model.dart';
import 'package:himx/utils/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class GlobalData {
  static final GlobalData _instance = GlobalData._internal();
  static const String env = String.fromEnvironment('env', defaultValue: 'prod');

  factory GlobalData() => _instance;
  GlobalData._internal();

  bool isFirstTimeUse = true;
  String appVersion = '';
  String osVersion = '';
  String deviceId = '';
  String deviceName = '';
  String currentLanguage = '';
  String currentRegion = '';
}
