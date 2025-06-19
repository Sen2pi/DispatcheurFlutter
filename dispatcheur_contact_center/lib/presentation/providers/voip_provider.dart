import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/voip_engine.dart';
import '../../data/models/call_model.dart';

class VoipState {
  final List<CallModel> activeCalls;
  final VoipEngineState engineState;
  final bool isConnected;
  final bool isRegistered;
  final bool isConnecting;
  final String? error;
  final String? currentUser;
  final String? selectedMicrophone;
  final String? selectedSpeaker;
  final List<dynamic> availableMicrophones;
  final List<dynamic> availableSpeakers;
  final String? activeCallId;
  final int maxConcurrentCalls;

  const VoipState({
    this.activeCalls = const [],
    this.engineState = VoipEngineState.disconnected,
    this.isConnected = false,
    this.isRegistered = false,
    this.isConnecting = false,
    this.error,
    this.currentUser,
    this.selectedMicrophone,
    this.selectedSpeaker,
    this.availableMicrophones = const [],
    this.availableSpeakers = const [],
    this.activeCallId,
    this.maxConcurrentCalls = 10,
  });

  VoipState copyWith({
    List<CallModel>? activeCalls,
    VoipEngineState? engineState,
    bool? isConnected,
    bool? isRegistered,
    bool? isConnecting,
    String? error,
    String? currentUser,
    String? selectedMicrophone,
    String? selectedSpeaker,
    List<dynamic>? availableMicrophones,
    List<dynamic>? availableSpeakers,
    String? activeCallId,
    int? maxConcurrentCalls,
  }) {
    return VoipState(
      activeCalls: activeCalls ?? this.activeCalls,
      engineState: engineState ?? this.engineState,
      isConnected: isConnected ?? this.isConnected,
      isRegistered: isRegistered ?? this.isRegistered,
      isConnecting: isConnecting ?? this.isConnecting,
      error: error ?? this.error,
      currentUser: currentUser ?? this.currentUser,
      selectedMicrophone: selectedMicrophone ?? this.selectedMicrophone,
      selectedSpeaker: selectedSpeaker ?? this.selectedSpeaker,
      availableMicrophones: availableMicrophones ?? this.availableMicrophones,
      availableSpeakers: availableSpeakers ?? this.availableSpeakers,
      activeCallId: activeCallId ?? this.activeCallId,
      maxConcurrentCalls: maxConcurrentCalls ?? this.maxConcurrentCalls,
    );
  }
}

class VoipNotifier extends StateNotifier<VoipState> {
  VoipNotifier(this._voipEngine) : super(const VoipState()) {
    _init();
  }

  final VoipEngine _voipEngine;

  void _init() {
    // Escutar mudanças nas chamadas
    _voipEngine.callsStream.listen((calls) {
      state = state.copyWith(activeCalls: calls);
    });

    // Escutar mudanças no estado do engine
    _voipEngine.stateStream.listen((engineState) {
      state = state.copyWith(
        engineState: engineState,
        isConnected: _voipEngine.isConnected,
        isRegistered: _voipEngine.isRegistered,
        currentUser: _voipEngine.currentUser,
        selectedMicrophone: _voipEngine.selectedMicrophone,
        selectedSpeaker: _voipEngine.selectedSpeaker,
        availableMicrophones: _voipEngine.availableMicrophones,
        availableSpeakers: _voipEngine.availableSpeakers,
        activeCallId: _voipEngine.activeCallId,
        maxConcurrentCalls: _voipEngine.maxConcurrentCalls,
      );
    });
  }

  Future<void> initialize() async {
    try {
      state = state.copyWith(isConnecting: true, error: null);
      await _voipEngine.initialize();
      state = state.copyWith(isConnecting: false);
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isConnecting: false,
      );
    }
  }

  Future<void> connect({
    required String server,
    required String username,
    required String password,
    required String displayName,
    int port = 5060,
    bool secure = false,
  }) async {
    try {
      state = state.copyWith(isConnecting: true, error: null);

      await _voipEngine.connect(
        server: server,
        username: username,
        password: password,
        displayName: displayName,
        port: port,
        secure: secure,
      );

      state = state.copyWith(isConnecting: false);
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<String> makeCall(String destination) async {
    try {
      return await _voipEngine.makeCall(destination);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> answerCall(String callId) async {
    try {
      await _voipEngine.answerCall(callId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> hangupCall(String callId) async {
    try {
      await _voipEngine.hangupCall(callId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> holdCall(String callId, bool hold) async {
    try {
      await _voipEngine.holdCall(callId, hold);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> transferCall(String callId, String destination) async {
    try {
      await _voipEngine.transferCall(callId, destination);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> sendDTMF(String callId, String digits) async {
    try {
      await _voipEngine.sendDTMF(callId, digits);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> mergeCalls(String callId1, String callId2) async {
    try {
      await _voipEngine.mergeCalls(callId1, callId2);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> setMicrophone(String deviceId) async {
    try {
      await _voipEngine.setSelectedMicrophone(deviceId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> setSpeaker(String deviceId) async {
    try {
      await _voipEngine.setSelectedSpeaker(deviceId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void setActiveCall(String callId) {
    _voipEngine.setActiveCall(callId);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final voipProvider = StateNotifierProvider<VoipNotifier, VoipState>((ref) {
  return VoipNotifier(VoipEngine());
});
