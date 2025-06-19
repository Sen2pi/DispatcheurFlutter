import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static const String _userKey = 'user';
  static const String _tokenKey = 'token';

  final Dio _dio;

  AuthService(this._dio);

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;

      if (data['success'] == true) {
        final user = UserModel.fromJson(data['user']);
        final token = data['token'];

        // Salvar localmente
        await _saveUser(user);
        await _saveToken(token);

        return AuthResult(user: user, token: token);
      } else {
        throw Exception(data['message'] ?? 'Erro no login');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Credenciais inválidas');
      }
      throw Exception('Erro de conexão: ${e.message}');
    } catch (e) {
      throw Exception('Erro inesperado: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson != null) {
        final userMap = json.decode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userMap);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel> updateProfile(UserModel updatedUser) async {
    try {
      final response =
          await _dio.put('/user/profile', data: updatedUser.toJson());

      final user = UserModel.fromJson(response.data['user']);
      await _saveUser(user);

      return user;
    } catch (e) {
      throw Exception('Erro ao atualizar perfil: $e');
    }
  }

  Future<void> updateOnlineStatus(UserModel user) async {
    try {
      await _dio.patch('/user/status', data: {
        'isOnline': user.isOnline,
        'status': user.status.name,
        'lastSeen': user.lastSeen?.toIso8601String(),
      });

      await _saveUser(user);
    } catch (e) {
      // Log mas não lançar erro para não afetar UX
      print('Erro ao atualizar status online: $e');
    }
  }

  Future<void> _saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }
}

class AuthResult {
  final UserModel? user;
  final String? token;

  AuthResult({this.user, this.token});
}

final authServiceProvider = Provider<AuthService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthService(apiService.dio);
});
