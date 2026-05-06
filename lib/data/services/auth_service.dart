import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthService {
  final Dio _dio = DioClient().dio;
  final _storage = const FlutterSecureStorage();

  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'username': username,
        'password': password,
      });
      
      final data = response.data;
      
      // Robust token extraction
      final token = data['token'] ?? 
                   data['accessToken'] ?? 
                   (data['data'] != null ? data['data']['token'] : null) ??
                   (data['data'] != null ? data['data']['accessToken'] : null);
      
      if (token != null) {
        await _storage.write(key: 'access_token', value: token);
      }
      
      // Robust user data extraction
      final userData = data['user'] ?? 
                       data['data'] ?? 
                       data;
      
      if (userData == null) {
        throw Exception("Không tìm thấy thông tin người dùng trong phản hồi");
      }

      return UserModel.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getMe() async {
    try {
      final response = await _dio.get('/auth/me');
      final data = response.data;
      final userData = data['user'] ?? data['data'] ?? data;
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> googleLogin(String idToken) async {
    try {
      final response = await _dio.post('/auth/google', data: {
        'idToken': idToken,
      });
      
      final data = response.data;
      final token = data['accessToken'] ?? data['token'];
      
      if (token != null) {
        await _storage.write(key: 'access_token', value: token);
      }
      
      final userData = data['user'] ?? data['data'] ?? data;
      return UserModel.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }
}
