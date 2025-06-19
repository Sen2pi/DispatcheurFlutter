import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:sip_ua/sip_ua.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';

import '../data/models/call_model.dart';
import '../core/constants/voip_constants.dart';
import '../core/errors/exceptions.dart';

class VoipEngine {
  static final VoipEngine _instance = VoipEngine._internal();
  factory VoipEngine() => _instance;
  VoipEngine._internal();

  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  SIPUAHelper? _sipHelper;
  UaSettings? _settings;

  // State
  final Map<String, CallModel> _activeCalls = {};
  final Map<String, Call> _sipCalls = {};
  final StreamController<List<CallModel>> _callsController =
      StreamController<List<CallModel>>.broadcast();
  final StreamController<VoipEngineState> _stateController =
      StreamController<VoipEngineState>.broadcast();

  bool _isRegistered = false;
  bool _isConnected = false;
  String? _currentUser;

  // Audio devices
  String? _selectedMicrophone;
  String? _selectedSpeaker;
  List<MediaDeviceInfo> _audioInputs = [];
  List<MediaDeviceInfo> _audioOutputs = [];

  // Conference management
  final Map<String, List<String>> _conferences = {};

  // Stream getters
  Stream<List<CallModel>> get callsStream => _callsController.stream;
  Stream<VoipEngineState> get stateStream => _stateController.stream;
  List<CallModel> get activeCalls => _activeCalls.values.toList();
  bool get isRegistered => _isRegistered;
  bool get isConnected => _isConnected;
  String? get currentUser => _currentUser;

  Future<void> initialize() async {
    try {
      _logger.i('Inicializando VoIP Engine...');

      _sipHelper = SIPUAHelper();
      _sipHelper!.addSipUaHelperListener(this);

      // Inicializar WebRTC
      await _initializeWebRTC();

      // Enumerar dispositivos de áudio
      await _enumerateAudioDevices();

      _logger.i('VoIP Engine inicializado com sucesso');
    } catch (e) {
      _logger.e('Erro na inicialização do VoIP Engine: $e');
      throw VoipException('Falha na inicialização: $e');
    }
  }

  Future<void> _initializeWebRTC() async {
    try {
      // Configurar WebRTC
      Map<String, dynamic> mediaConstraints = {
        'audio': {
          'mandatory': {
            'echoCancellation': true,
            'noiseSuppression': true,
            'autoGainControl': true,
          },
          'optional': [],
        },
        'video': false,
      };

      // Testar acesso aos dispositivos
      final stream = await navigator.mediaDevices.getUserMedia(
        mediaConstraints,
      );
      stream.getTracks().forEach((track) => track.stop());

      _logger.d('WebRTC inicializado com sucesso');
    } catch (e) {
      _logger.e('Erro na inicialização WebRTC: $e');
      throw VoipException('Erro no WebRTC: $e');
    }
  }

  Future<void> _enumerateAudioDevices() async {
    try {
      final devices = await navigator.mediaDevices.enumerateDevices();

      _audioInputs = devices
          .where((device) => device.kind == 'audioinput')
          .toList();

      _audioOutputs = devices
          .where((device) => device.kind == 'audiooutput')
          .toList();

      _logger.d(
        'Dispositivos de áudio enumerados: '
        '${_audioInputs.length} inputs, ${_audioOutputs.length} outputs',
      );
    } catch (e) {
      _logger.w('Erro ao enumerar dispositivos: $e');
    }
  }

  Future<bool> connect({
    required String server,
    required String username,
    required String password,
    required String displayName,
    int port = 5060,
    bool secure = false,
  }) async {
    try {
      _logger.i('Conectando ao servidor SIP: $server:$port');

      _settings = UaSettings();
      _settings!.webSocketUrl = '${secure ? 'wss' : 'ws'}://$server:$port/ws';
      _settings!.uri = 'sip:$username@$server';
      _settings!.authorizationUser = username;
      _settings!.password = password;
      _settings!.displayName = displayName;
      _settings!.userAgent = VoipConstants.defaultUserAgent;
      _settings!.dtmfMode = DtmfMode.RFC2833;

      // Configurar ICE servers
      _settings!.iceServers = VoipConstants.defaultIceServers;

      // Configurar codecs
      _settings!.sessionTimersExpires = 120;
      _settings!.register = true;

      await _sipHelper!.start(_settings!);
      _currentUser = username;

      _updateState(VoipEngineState.connecting);

      return true;
    } catch (e) {
      _logger.e('Erro na conexão SIP: $e');
      _updateState(VoipEngineState.disconnected);
      throw VoipException('Falha na conexão: $e');
    }
  }

  Future<void> disconnect() async {
    try {
      _logger.i('Desconectando VoIP Engine...');

      // Finalizar todas as chamadas
      for (final callId in _activeCalls.keys.toList()) {
        await hangupCall(callId);
      }

      // Parar SIP
      await _sipHelper?.stop();

      // Limpar estado
      _activeCalls.clear();
      _sipCalls.clear();
      _conferences.clear();
      _isConnected = false;
      _isRegistered = false;
      _currentUser = null;

      _updateState(VoipEngineState.disconnected);
      _notifyCallsUpdate();

      _logger.i('VoIP Engine desconectado');
    } catch (e) {
      _logger.e('Erro na desconexão: $e');
    }
  }

  Future<String> makeCall(String destination) async {
    if (!_isRegistered) {
      throw VoipException('Não registrado no servidor SIP');
    }

    if (_activeCalls.length >= VoipConstants.maxConcurrentCalls) {
      throw VoipException('Limite máximo de chamadas atingido');
    }

    try {
      _logger.i('Iniciando chamada para: $destination');

      final callId = _uuid.v4();

      // Criar modelo da chamada
      final callModel = CallModel(
        id: callId,
        destination: destination,
        direction: CallDirection.outgoing,
        state: CallState.connecting,
        startTime: DateTime.now(),
        isOutbound: true,
      );

      _activeCalls[callId] = callModel;
      _notifyCallsUpdate();

      // Configurar constraints de mídia
      final mediaConstraints = <String, dynamic>{
        'audio': {
          'mandatory': {
            'echoCancellation': true,
            'noiseSuppression': true,
            'autoGainControl': true,
          },
          'optional': _selectedMicrophone != null
              ? [
                  {'sourceId': _selectedMicrophone},
                ]
              : [],
        },
        'video': false,
      };

      // Fazer chamada SIP
      final sipCall = await _sipHelper!.call(
        destination,
        voiceonly: true,
        mediaConstraints: mediaConstraints,
      );

      _sipCalls[callId] = sipCall;

      // Atualizar estado
      _updateCallState(callId, CallState.ringing);

      _logger.i('Chamada iniciada com ID: $callId');
      return callId;
    } catch (e) {
      _logger.e('Erro ao fazer chamada: $e');
      _activeCalls.remove(callId);
      _notifyCallsUpdate();
      throw VoipException('Erro na chamada: $e');
    }
  }

  Future<void> answerCall(String callId) async {
    final call = _activeCalls[callId];
    final sipCall = _sipCalls[callId];

    if (call == null || sipCall == null) {
      throw VoipException('Chamada não encontrada: $callId');
    }

    if (call.direction != CallDirection.incoming) {
      throw VoipException('Apenas chamadas recebidas podem ser atendidas');
    }

    try {
      _logger.i('Atendendo chamada: $callId');

      // Configurar constraints de mídia
      final mediaConstraints = <String, dynamic>{
        'audio': {
          'mandatory': {
            'echoCancellation': true,
            'noiseSuppression': true,
            'autoGainControl': true,
          },
          'optional': _selectedMicrophone != null
              ? [
                  {'sourceId': _selectedMicrophone},
                ]
              : [],
        },
        'video': false,
      };

      await sipCall.answer(mediaConstraints);

      // Atualizar modelo
      final updatedCall = call.copyWith(
        state: CallState.established,
        answeredTime: DateTime.now(),
      );

      _activeCalls[callId] = updatedCall;
      _notifyCallsUpdate();

      _logger.i('Chamada atendida: $callId');
    } catch (e) {
      _logger.e('Erro ao atender chamada: $e');
      throw VoipException('Erro ao atender: $e');
    }
  }

  Future<void> hangupCall(String callId) async {
    final call = _activeCalls[callId];
    final sipCall = _sipCalls[callId];

    if (call == null) {
      _logger.w('Tentativa de desligar chamada inexistente: $callId');
      return;
    }

    try {
      _logger.i('Finalizando chamada: $callId');

      // Finalizar chamada SIP
      if (sipCall != null) {
        await sipCall.hangup();
      }

      // Atualizar modelo
      final updatedCall = call.copyWith(
        state: CallState.ended,
        endTime: DateTime.now(),
      );

      _activeCalls[callId] = updatedCall;

      // Remover após um delay para permitir visualização
      Timer(const Duration(seconds: 2), () {
        _activeCalls.remove(callId);
        _sipCalls.remove(callId);
        _notifyCallsUpdate();
      });

      _notifyCallsUpdate();

      _logger.i('Chamada finalizada: $callId');
    } catch (e) {
      _logger.e('Erro ao finalizar chamada: $e');
      // Remover mesmo com erro
      _activeCalls.remove(callId);
      _sipCalls.remove(callId);
      _notifyCallsUpdate();
    }
  }

  Future<void> holdCall(String callId, bool hold) async {
    final call = _activeCalls[callId];
    final sipCall = _sipCalls[callId];

    if (call == null || sipCall == null) {
      throw VoipException('Chamada não encontrada: $callId');
    }

    if (call.state != CallState.established) {
      throw VoipException(
        'Apenas chamadas estabelecidas podem ser colocadas em espera',
      );
    }

    try {
      _logger.i(
        '${hold ? 'Colocando em espera' : 'Retomando'} chamada: $callId',
      );

      if (hold) {
        await sipCall.hold();
      } else {
        await sipCall.unhold();
      }

      // Atualizar modelo
      final updatedCall = call.copyWith(isHeld: hold);
      _activeCalls[callId] = updatedCall;
      _notifyCallsUpdate();

      _logger.i('Chamada ${hold ? 'em espera' : 'retomada'}: $callId');
    } catch (e) {
      _logger.e(
        'Erro ao ${hold ? 'colocar em espera' : 'retomar'} chamada: $e',
      );
      throw VoipException('Erro na operação: $e');
    }
  }

  Future<void> transferCall(String callId, String destination) async {
    final call = _activeCalls[callId];
    final sipCall = _sipCalls[callId];

    if (call == null || sipCall == null) {
      throw VoipException('Chamada não encontrada: $callId');
    }

    if (call.state != CallState.established) {
      throw VoipException(
        'Apenas chamadas estabelecidas podem ser transferidas',
      );
    }

    try {
      _logger.i('Transferindo chamada $callId para: $destination');

      await sipCall.refer(destination);

      // Atualizar modelo
      final updatedCall = call.copyWith(
        transferTarget: destination,
        state: CallState.ended,
        endTime: DateTime.now(),
      );

      _activeCalls[callId] = updatedCall;

      // Remover após delay
      Timer(const Duration(seconds: 2), () {
        _activeCalls.remove(callId);
        _sipCalls.remove(callId);
        _notifyCallsUpdate();
      });

      _notifyCallsUpdate();

      _logger.i('Chamada transferida: $callId -> $destination');
    } catch (e) {
      _logger.e('Erro na transferência: $e');
      throw VoipException('Erro na transferência: $e');
    }
  }

  Future<void> sendDTMF(String callId, String digits) async {
    final call = _activeCalls[callId];
    final sipCall = _sipCalls[callId];

    if (call == null || sipCall == null) {
      throw VoipException('Chamada não encontrada: $callId');
    }

    if (call.state != CallState.established) {
      throw VoipException('Apenas chamadas estabelecidas podem enviar DTMF');
    }

    try {
      _logger.d('Enviando DTMF "$digits" para chamada: $callId');

      for (final digit in digits.split('')) {
        if (VoipConstants.dtmfDigits.contains(digit)) {
          await sipCall.sendDTMF(digit);
          // Pequeno delay entre dígitos
          await Future.delayed(VoipConstants.dtmfToneDuration);
        }
      }

      _logger.d('DTMF enviado com sucesso: $digits');
    } catch (e) {
      _logger.e('Erro ao enviar DTMF: $e');
      throw VoipException('Erro no DTMF: $e');
    }
  }

  Future<void> mergeCalls(String callId1, String callId2) async {
    final call1 = _activeCalls[callId1];
    final call2 = _activeCalls[callId2];

    if (call1 == null || call2 == null) {
      throw VoipException('Uma ou ambas as chamadas não foram encontradas');
    }

    if (call1.state != CallState.established ||
        call2.state != CallState.established) {
      throw VoipException('Ambas as chamadas devem estar estabelecidas');
    }

    try {
      _logger.i('Criando conferência entre $callId1 e $callId2');

      final conferenceId = _uuid.v4();
      _conferences[conferenceId] = [callId1, callId2];

      // Atualizar modelos das chamadas
      final updatedCall1 = call1.copyWith(
        isConference: true,
        participants: [callId2],
      );

      final updatedCall2 = call2.copyWith(
        isConference: true,
        participants: [callId1],
      );

      _activeCalls[callId1] = updatedCall1;
      _activeCalls[callId2] = updatedCall2;

      _notifyCallsUpdate();

      _logger.i('Conferência criada: $conferenceId');
    } catch (e) {
      _logger.e('Erro ao criar conferência: $e');
      throw VoipException('Erro na conferência: $e');
    }
  }

  Future<void> setSelectedMicrophone(String deviceId) async {
    try {
      // Testar o dispositivo
      final stream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'deviceId': {'exact': deviceId},
        },
        'video': false,
      });

      // Parar o stream de teste
      stream.getTracks().forEach((track) => track.stop());

      _selectedMicrophone = deviceId;
      _logger.d('Microfone selecionado: $deviceId');
    } catch (e) {
      _logger.e('Erro ao selecionar microfone: $e');
      throw VoipException('Erro no microfone: $e');
    }
  }

  Future<void> setSelectedSpeaker(String deviceId) async {
    try {
      // Para dispositivos que suportam setSinkId
      _selectedSpeaker = deviceId;
      _logger.d('Alto-falante selecionado: $deviceId');
    } catch (e) {
      _logger.e('Erro ao selecionar alto-falante: $e');
      throw VoipException('Erro no alto-falante: $e');
    }
  }

  List<MediaDeviceInfo> get availableMicrophones => _audioInputs;
  List<MediaDeviceInfo> get availableSpeakers => _audioOutputs;
  String? get selectedMicrophone => _selectedMicrophone;
  String? get selectedSpeaker => _selectedSpeaker;

  CallModel? getCall(String callId) => _activeCalls[callId];

  void _updateCallState(String callId, CallState state) {
    final call = _activeCalls[callId];
    if (call != null) {
      _activeCalls[callId] = call.copyWith(state: state);
      _notifyCallsUpdate();
    }
  }

  void _updateState(VoipEngineState state) {
    _stateController.add(state);
  }

  void _notifyCallsUpdate() {
    _callsController.add(activeCalls);
  }

  void dispose() {
    _callsController.close();
    _stateController.close();
    _sipHelper?.stop();
  }
}

// SIP.js Event Handlers
extension VoipEngineEventHandlers on VoipEngine {
  void onRegistrationStateChanged(RegistrationState state) {
    _isRegistered = state.state == RegistrationStateEnum.REGISTERED;
    _logger.i('Estado de registro: ${state.state}');

    if (_isRegistered) {
      _updateState(VoipEngineState.registered);
    } else {
      _updateState(VoipEngineState.unregistered);
    }
  }

  void onTransportStateChanged(TransportState state) {
    _isConnected = state.state == TransportStateEnum.CONNECTED;
    _logger.i('Estado de transporte: ${state.state}');

    if (_isConnected) {
      _updateState(VoipEngineState.connected);
    } else {
      _updateState(VoipEngineState.disconnected);
    }
  }

  void onNewCall(Call call) {
    _logger.i('Nova chamada recebida: ${call.id}');

    final callId = _uuid.v4();
    final callModel = CallModel(
      id: callId,
      destination: call.remote_identity ?? 'Desconhecido',
      direction: CallDirection.incoming,
      state: CallState.ringing,
      startTime: DateTime.now(),
    );

    _activeCalls[callId] = callModel;
    _sipCalls[callId] = call;
    _notifyCallsUpdate();
  }

  void onCallStateChanged(Call call, CallState state) {
    // Encontrar o callId correspondente
    String? callId;
    for (final entry in _sipCalls.entries) {
      if (entry.value == call) {
        callId = entry.key;
        break;
      }
    }

    if (callId != null) {
      _logger.d('Estado da chamada $callId: ${state.state}');

      switch (state.state) {
        case CallStateEnum.STREAM:
          _updateCallState(callId, CallState.established);
          break;
        case CallStateEnum.ENDED:
          _updateCallState(callId, CallState.ended);
          // Limpar após delay
          Timer(const Duration(seconds: 2), () {
            _activeCalls.remove(callId);
            _sipCalls.remove(callId);
            _notifyCallsUpdate();
          });
          break;
        case CallStateEnum.FAILED:
          _updateCallState(callId, CallState.failed);
          break;
        default:
          break;
      }
    }
  }
}

enum VoipEngineState {
  disconnected,
  connecting,
  connected,
  registered,
  unregistered,
  error,
}
