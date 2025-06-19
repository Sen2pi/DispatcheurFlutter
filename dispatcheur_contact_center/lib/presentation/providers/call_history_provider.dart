import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../data/models/call_model.dart';

part 'call_history_provider.freezed.dart';

@freezed
class CallHistoryState with _$CallHistoryState {
  const factory CallHistoryState({
    @Default([]) List<CallModel> calls,
    @Default(false) bool isLoading,
    String? error,
  }) = _CallHistoryState;
}

class CallHistoryNotifier extends StateNotifier<CallHistoryState> {
  CallHistoryNotifier() : super(const CallHistoryState()) {
    loadHistory();
  }

  static const String _storageKey = 'voip_call_history';
  static const int _maxHistoryItems = 50;

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_storageKey) ?? [];

      final calls = historyJson
          .map((json) => CallModel.fromJson(jsonDecode(json)))
          .toList();

      calls.sort((a, b) => b.startTime.compareTo(a.startTime));

      state = state.copyWith(
        calls: calls,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> addCall(CallModel call) async {
    try {
      final updatedCalls = [call, ...state.calls];

      // Manter apenas os últimos N itens
      if (updatedCalls.length > _maxHistoryItems) {
        updatedCalls.removeRange(_maxHistoryItems, updatedCalls.length);
      }

      await _saveHistory(updatedCalls);

      state = state.copyWith(calls: updatedCalls);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> clearHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);

      state = state.copyWith(calls: []);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _saveHistory(List<CallModel> calls) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = calls.map((call) => jsonEncode(call.toJson())).toList();

    await prefs.setStringList(_storageKey, historyJson);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final callHistoryProvider =
    StateNotifierProvider<CallHistoryNotifier, CallHistoryState>((ref) {
  return CallHistoryNotifier();
});
