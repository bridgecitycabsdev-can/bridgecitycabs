import 'package:dio/dio.dart';

import '../phone/canada_phone.dart';

Map<String, dynamic>? jsonMap(Object? data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  return null;
}

String errorMessage(Object error) {
  if (error is PhoneException) return error.message;
  if (error is DioException) {
    final message = jsonMap(error.response?.data)?['message'];
    if (message is String && message.isNotEmpty) return message;
    if (message is List && message.isNotEmpty) return '${message.first}';
  }
  return 'Something went wrong. Try again.';
}

String? errorCode(Object error) {
  if (error is! DioException) return null;
  final code = jsonMap(error.response?.data)?['code'];
  return code is String && code.isNotEmpty ? code : null;
}

Map<String, dynamic>? errorBody(Object error) {
  if (error is! DioException) return null;
  return jsonMap(error.response?.data);
}
