import 'package:dio/dio.dart';
import 'package:himx/common/globaldata.dart';
import 'package:uuid/uuid.dart';

class BaseRequestInterceptor extends Interceptor {
  final _uuid = const Uuid();
  String? _token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (GlobalData().token != null) {
      options.headers.addAll({"Authorization": "Bearer ${GlobalData().token}"});
    }

    // Add common headers
    options.headers.addAll({
      "X-App-Key": "6740486302", // Replace with actual app key
      "trace_id": _uuid.v4(), // Add unique trace ID for each request
      "appVersion": GlobalData().appVersion,
      "osVersion": GlobalData().osVersion,
      "deviceId": GlobalData().deviceId,
      "deviceName": GlobalData().deviceName,
      "lang": GlobalData().currentLanguage,
      "region": GlobalData().currentRegion,
    });

    super.onRequest(options, handler);
  }

  void setToken(String? token) {
    _token = token;
  }
}

class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  late Dio _dio;
  late BaseRequestInterceptor _requestInterceptor;

  factory HttpClient() => _instance;

  HttpClient._internal() {
    _dio = Dio(
      BaseOptions(
        // baseUrl: 'https://prod.mobileai.app',
        baseUrl: 'http://127.0.0.1:8000',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 45),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors
      ..add(BaseRequestInterceptor())
      ..add(LogInterceptor(responseHeader: false, responseBody: true));
  }

  // 获取dio实例
  Dio get dio => _dio;

  // 设置 token
  void setToken(String? token) {
    _requestInterceptor.setToken(token);
  }
}
