import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/user_model.dart';

class ApiService {
  late final Dio _dio;

  Dio get dio => _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl:
          dotenv.env['API_BASE_URL'] ?? 'https://api.dispatcheur-cc.fr/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Adicionar token de autorização
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('token');

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        handler.next(options);
      },
      onError: (error, handler) {
        print('API Error: ${error.response?.statusCode} - ${error.message}');
        handler.next(error);
      },
    ));

    // Logger interceptor para desenvolvimento
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }

  Future<List<UserModel>> getOnlineUsers() async {
    try {
      final response = await _dio.get('/users/online');

      final List<dynamic> usersData = response.data['users'] ?? [];
      return usersData.map((userData) => UserModel.fromJson(userData)).toList();
    } catch (e) {
      print('Erro ao buscar usuários online: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getVoipCredentials(String userId) async {
    try {
      final response = await _dio.get('/user/$userId/voip-credentials');
      return response.data;
    } catch (e) {
      throw Exception('Erro ao buscar credenciais VoIP: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getContacts() async {
    try {
      final response = await _dio.get('/contacts');
      return List<Map<String, dynamic>>.from(response.data['contacts'] ?? []);
    } catch (e) {
      print('Erro ao buscar contatos: $e');
      return [];
    }
  }

  Future<void> logCall({
    required String callId,
    required String number,
    required String direction,
    required String status,
    String? duration,
  }) async {
    try {
      await _dio.post('/calls/log', data: {
        'callId': callId,
        'number': number,
        'direction': direction,
        'status': status,
        'duration': duration,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Erro ao logar chamada: $e');
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
