import '../data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthResult {
  final UserModel user;
  final String token;

  AuthResult({required this.user, required this.token});
}

abstract class AuthService {
  Future<AuthResult> login({required String email, required String password});
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<String?> getToken();
  Future<void> updateUserStatus(UserStatus status);
}

class AuthServiceImpl implements AuthService {
  @override
  Future<AuthResult> login(
      {required String email, required String password}) async {
    await Future.delayed(const Duration(seconds: 1));

    final user = UserModel(
      id: '1',
      name: 'João Silva',
      email: email,
      status: UserStatus.online,
      isOnline: true,
    );

    return AuthResult(user: user, token: 'mock_token_123');
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return null;
  }

  @override
  Future<String?> getToken() async {
    return null;
  }

  @override
  Future<void> updateUserStatus(UserStatus status) async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthServiceImpl();
});
