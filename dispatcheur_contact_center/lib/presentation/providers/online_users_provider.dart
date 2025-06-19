import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../data/models/user_model.dart';
import '../../services/api_service.dart';

part 'online_users_provider.freezed.dart';

@freezed
class OnlineUsersState with _$OnlineUsersState {
  const factory OnlineUsersState({
    @Default([]) List<UserModel> users,
    @Default(false) bool isLoading,
    String? error,
  }) = _OnlineUsersState;
}

class OnlineUsersNotifier extends StateNotifier<OnlineUsersState> {
  OnlineUsersNotifier(this._apiService) : super(const OnlineUsersState()) {
    _startPolling();
  }

  final ApiService _apiService;
  Timer? _pollingTimer;

  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      fetchOnlineUsers();
    });

    // Fetch inicial
    fetchOnlineUsers();
  }

  Future<void> fetchOnlineUsers() async {
    try {
      final users = await _apiService.getOnlineUsers();
      state = state.copyWith(
        users: users,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  List<UserModel> getUsersByStatus(UserStatus status) {
    return state.users.where((user) => user.status == status).toList();
  }

  int get onlineCount => getUsersByStatus(UserStatus.online).length;
  int get awayCount => getUsersByStatus(UserStatus.away).length;
  int get busyCount => getUsersByStatus(UserStatus.busy).length;
  int get totalActive => onlineCount + awayCount + busyCount;

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}

final onlineUsersProvider =
    StateNotifierProvider<OnlineUsersNotifier, OnlineUsersState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return OnlineUsersNotifier(apiService);
});
