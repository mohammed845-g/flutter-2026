import 'package:dio/dio.dart';

/// A service to handle authentication API calls using Dio.
class AuthService {
  // Base URL configuration
  static const String _baseUrl = 'http://192.168.1.11:3000';

  final Dio _dio;

  // Constructor allowing an optional Dio instance
  AuthService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          );

  /// Authenticates a user (Admin or Employee) with their email and password.
  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/login', // تعديل مسار الـ endpoint ليتوافق مع السيرفر عندك
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data != null) {
        // Successful login
        return response.data as Map<String, dynamic>;
      }

      return null;
    } on DioException catch (e) {
      _handleDioError(e);
      return null;
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Centralized error handling for Dio requests
  void _handleDioError(DioException e) {
    if (e.response != null) {
      final errorMessage =
          e.response?.data?['message'] ?? 'Authentication failed';
      throw Exception(
        'Server Error (${e.response?.statusCode}): $errorMessage',
      );
    } else if (e.type == DioExceptionType.connectionTimeout) {
      throw Exception('Connection timeout. Please check your server or network.');
    } else {
      throw Exception('Network error: ${e.message}');
    }
  }
}