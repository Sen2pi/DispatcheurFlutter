import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/api_service.dart';

part 'auth_provider.freezed.dart';

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    UserModel? user,
    @Default(false) bool isAuthenticated,
    @Default(false) bool isLoading,
    String? error,
    String? token,
  }) = _AuthState;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService, this._apiService) : super(const AuthState()) {
    _init();
  }

  final AuthService _authService;
  final ApiService _apiService;

  void _init() {
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = await _authService.getCurrentUser();
      final token = await _authService.getToken();

      if (user != null && token != null) {
        state = state.copyWith(
          user: user,
          token: token,
          isAuthenticated: true,
          isLoading: false,
          error: null,
        );

        // Atualizar status online
        await updateOnlineStatus(true);
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isAuthenticated: false,
      );
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.login(email: email, password: password);

      if (result.user != null && result.token != null) {
        state = state.copyWith(
          user: result.user,
          token: result.token,
          isAuthenticated: true,
          isLoading: false,
          error: null,
        );

        // Atualizar status online
        await updateOnlineStatus(true);

        return true;
      } else {
        state = state.copyWith(
          error: 'Credenciais inválidas',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      // Atualizar status offline antes de logout
      await updateOnlineStatus(false);

      await _authService.logout();

      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    if (state.user == null) return;

    try {
      final user = await _authService.updateProfile(updatedUser);
      state = state.copyWith(user: user);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    if (state.user == null) return;

    try {
      final updatedUser = state.user!.copyWith(
        isOnline: isOnline,
        status: isOnline ? UserStatus.online : UserStatus.offline,
        lastSeen: DateTime.now(),
      );

      await _authService.updateOnlineStatus(updatedUser);
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      // Log erro mas não atualizar UI para não afetar experiência
      print('Erro ao atualizar status online: $e');
    }
  }

  Future<void> updateUserStatus(UserStatus status) async {
    if (state.user == null) return;

    try {
      final updatedUser = state.user!.copyWith(
        status: status,
        lastSeen: DateTime.now(),
      );

      await _authService.updateProfile(updatedUser);
      state = state.copyWith(user: updatedUser);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(authService, apiService);
});
