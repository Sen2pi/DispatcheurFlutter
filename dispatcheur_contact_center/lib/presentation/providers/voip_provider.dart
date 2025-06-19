import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../services/voip_engine.dart';
import '../../data/models/call_model.dart';
import '../../core/errors/exceptions.dart';

part 'voip_provider.freezed.dart';

@freezed
class VoipState with _$VoipState {
  const factory VoipState({
    @Default([]) List<CallModel> activeCalls,
    @Default(VoipEngineState.disconnected) VoipEngineState engineState,
    @Default(false) bool isConnected,
    @Default(false) bool isRegistered,
    @Default(false) bool isConnecting,
    String? error,
    String? currentUser,
    String? selectedMicrophone,
    String? selectedSpeaker,
    @Default([]) List<MediaDeviceInfo> availableMicrophones,
    @Default([]) List<MediaDeviceInfo> availableSpeakers,
    String? activeCallId,
    @Default(10) int maxConcurrentCalls,
  }) = _VoipState;
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
      );
    });

    // Atualizar dispositivos de áudio
    _updateAudioDevices();
  }

  Future<void> initialize() async {
    try {
      state = state.copyWith(isConnecting: true, error: null);
      await _voipEngine.initialize();
      await _updateAudioDevices();
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

  Future<void> disconnect() async {
    try {
      await _voipEngine.disconnect();
      state = state.copyWith(
        isConnected: false,
        isRegistered: false,
        currentUser: null,
        activeCalls: [],
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<String> makeCall(String destination) async {
    try {
      if (state.activeCalls.length >= state.maxConcurrentCalls) {
        throw VoipException(
            'Limite máximo de ${state.maxConcurrentCalls} chamadas atingido');
      }

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
      state = state.copyWith(selectedMicrophone: deviceId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> setSpeaker(String deviceId) async {
    try {
      await _voipEngine.setSelectedSpeaker(deviceId);
      state = state.copyWith(selectedSpeaker: deviceId);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void setActiveCall(String callId) {
    state = state.copyWith(activeCallId: callId);
  }

  Future<void> _updateAudioDevices() async {
    try {
      state = state.copyWith(
        availableMicrophones: _voipEngine.availableMicrophones,
        availableSpeakers: _voipEngine.availableSpeakers,
        selectedMicrophone: _voipEngine.selectedMicrophone,
        selectedSpeaker: _voipEngine.selectedSpeaker,
      );
    } catch (e) {
      print('Erro ao atualizar dispositivos de áudio: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final voipProvider = StateNotifierProvider<VoipNotifier, VoipState>((ref) {
  return VoipNotifier(VoipEngine());
});
