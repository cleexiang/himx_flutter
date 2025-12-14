class ApiResponse<T> {
  String? code;
  String? message;
  T? data;

  ApiResponse({this.code, this.message, this.data});

  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic json) fromJson) {
    return ApiResponse(
      code: json['code'] as String?,
      message: json['message'] as String?,
      data: json['data'] == null ? null : fromJson(json['data']),
    );
  }
}
