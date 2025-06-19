import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/user_model.dart';
import '../../services/auth_service.dart';

part 'auth_provider.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    UserModel? user,
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    String? error,
    String? token,
  }) = _AuthState;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(const AuthState()) {
    _checkAuthStatus();
  }

  final AuthService _authService;

  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = await _authService.getCurrentUser();
      final token = await _authService.getToken();

      state = state.copyWith(
        user: user,
        token: token,
        isAuthenticated: user != null && token != null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isAuthenticated: false,
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      state = state.copyWith(
        user: result.user,
        token: result.token,
        isAuthenticated: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isAuthenticated: false,
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.logout();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthNotifier(authService);
});
