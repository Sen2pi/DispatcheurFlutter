import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:dart_sip_ua/dart_sip_ua.dart';
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

  UA? _userAgent;
  UaSettings? _settings;

  // State Management
  final Map<String, CallModel> _activeCalls = {};
  final Map<String, Call> _sipCalls = {};
  final StreamController<List<CallModel>> _callsController =
      StreamController<List<CallModel>>.broadcast();
  final StreamController<VoipEngineState> _stateController =
      StreamController<VoipEngineState>.broadcast();

  bool _isRegistered = false;
  bool _isConnected = false;
  String? _currentUser;

  // Audio Management
  String? _selectedMicrophone;
  String? _selectedSpeaker;
  List<MediaDeviceInfo> _audioInputs = [];
  List<MediaDeviceInfo> _audioOutputs = [];

  // Auto-reconnection
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  final int _maxReconnectAttempts = 5;

  // Conference Management
  final Map<String, List<String>> _conferences = {};

  // Stream getters
  Stream<List<CallModel>> get callsStream => _callsController.stream;
  Stream<VoipEngineState> get stateStream => _stateController.stream;
  List<CallModel> get activeCalls => _activeCalls.values.toList();
  bool get isRegistered => _isRegistered;
  bool get isConnected => _isConnected;
  String? get currentUser => _currentUser;

  /// Inicializa o VoIP Engine
  Future<void> initialize() async {
    try {
      _logger.i('Inicializando VoIP Engine...');

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

  /// Inicializa WebRTC
  Future<void> _initializeWebRTC() async {
    try {
      // Testar acesso aos dispositivos
      final stream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      });

      // Parar o stream de teste
      stream.getTracks().forEach((track) => track.stop());

      _logger.d('WebRTC inicializado com sucesso');
    } catch (e) {
      _logger.e('Erro na inicialização WebRTC: $e');
      throw VoipException('Erro no WebRTC: $e');
    }
  }

  /// Enumera dispositivos de áudio disponíveis
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
        'Dispositivos de áudio: ${_audioInputs.length} inputs, ${_audioOutputs.length} outputs',
      );
    } catch (e) {
      _logger.w('Erro ao enumerar dispositivos: $e');
    }
  }

  /// Conecta ao servidor SIP
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

      // Configurar settings
      _settings = UaSettings();
      _settings!.uri = 'sip:$username@$server';
      _settings!.authorizationUser = username;
      _settings!.password = password;
      _settings!.displayName = displayName;
      _settings!.userAgent = VoipConstants.defaultUserAgent;
      _settings!.transportOptions = TransportOptions(
        wsServers: ['${secure ? 'wss' : 'ws'}://$server:$port/ws'],
      );

      // Configurar WebRTC
      _settings!.mediaConstraints = {
        'audio': {
          'mandatory': {
            'echoCancellation': true,
            'noiseSuppression': true,
            'autoGainControl': true,
          },
        },
        'video': false,
      };

      // Criar User Agent
      _userAgent = UA(_settings!);

      // Configurar listeners
      _setupUserAgentListeners();

      // Iniciar
      _userAgent!.start();
      _currentUser = username;

      _updateState(VoipEngineState.connecting);

      return true;
    } catch (e) {
      _logger.e('Erro na conexão SIP: $e');
      _updateState(VoipEngineState.disconnected);
      throw VoipException('Falha na conexão: $e');
    }
  }

  /// Configura os listeners do User Agent
  void _setupUserAgentListeners() {
    if (_userAgent == null) return;

    // Listener de conexão
    _userAgent!.on(EventSocketConnecting(), (EventSocketConnecting data) {
      _logger.d('Conectando...');
      _updateState(VoipEngineState.connecting);
    });

    _userAgent!.on(EventSocketConnected(), (EventSocketConnected data) {
      _logger.i('Socket conectado');
      _isConnected = true;
      _updateState(VoipEngineState.connected);
    });

    _userAgent!.on(EventSocketDisconnected(), (EventSocketDisconnected data) {
      _logger.w('Socket desconectado');
      _isConnected = false;
      _isRegistered = false;
      _updateState(VoipEngineState.disconnected);
      _handleReconnection();
    });

    // Listener de registro
    _userAgent!.on(EventRegistered(), (EventRegistered data) {
      _logger.i('Registrado com sucesso');
      _isRegistered = true;
      _reconnectAttempts = 0; // Reset counter on success
      _updateState(VoipEngineState.registered);
    });

    _userAgent!.on(EventUnregister(), (EventUnregister data) {
      _logger.w('Não registrado');
      _isRegistered = false;
      _updateState(VoipEngineState.unregistered);
    });

    _userAgent!.on(EventRegistrationFailed(), (EventRegistrationFailed data) {
      _logger.e('Falha no registro: ${data.cause}');
      _updateState(VoipEngineState.error);
    });

    // Listener de chamadas recebidas
    _userAgent!.on(EventCallReceived(), (EventCallReceived data) {
      _logger.i('Nova chamada recebida de: ${data.originator}');
      _handleIncomingCall(data.call);
    });

    // Listener de chamadas finalizadas
    _userAgent!.on(EventCallEnded(), (EventCallEnded data) {
      _logger.i('Chamada finalizada: ${data.call.id}');
      _handleCallEnded(data.call);
    });
  }

  /// Manipula reconexão automática
  void _handleReconnection() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _logger.e('Máximo de tentativas de reconexão atingido');
      return;
    }

    _reconnectAttempts++;
    final delay = Duration(seconds: _reconnectAttempts * 2);

    _logger.i(
      'Tentativa de reconexão ${_reconnectAttempts}/${_maxReconnectAttempts} em ${delay.inSeconds}s',
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_userAgent != null && !_isConnected) {
        _userAgent!.start();
      }
    });
  }

  /// Manipula chamadas recebidas
  void _handleIncomingCall(Call call) {
    final callId = _uuid.v4();

    final callModel = CallModel(
      id: callId,
      destination: call.remote_identity?.uri.toString() ?? 'Desconhecido',
      direction: CallDirection.incoming,
      state: CallState.ringing,
      startTime: DateTime.now(),
    );

    _activeCalls[callId] = callModel;
    _sipCalls[callId] = call;

    // Configurar listeners da chamada
    _setupCallListeners(call, callId);

    _notifyCallsUpdate();
  }

  /// Configura listeners para uma chamada específica
  void _setupCallListeners(Call call, String callId) {
    call.on(EventCallAccepted(), (EventCallAccepted data) {
      _updateCallState(callId, CallState.established);
    });

    call.on(EventCallFailed(), (EventCallFailed data) {
      _updateCallState(callId, CallState.failed);
    });

    call.on(EventCallEnded(), (EventCallEnded data) {
      _updateCallState(callId, CallState.ended);
      Timer(const Duration(seconds: 2), () {
        _activeCalls.remove(callId);
        _sipCalls.remove(callId);
        _notifyCallsUpdate();
      });
    });
  }

  /// Manipula chamadas finalizadas
  void _handleCallEnded(Call call) {
    // Encontrar o callId correspondente
    String? callId;
    for (final entry in _sipCalls.entries) {
      if (entry.value == call) {
        callId = entry.key;
        break;
      }
    }

    if (callId != null) {
      _updateCallState(callId, CallState.ended);
      Timer(const Duration(seconds: 2), () {
        _activeCalls.remove(callId);
        _sipCalls.remove(callId);
        _notifyCallsUpdate();
      });
    }
  }

  /// Faz uma chamada
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

      // Configurar opções da chamada
      final callOptions = CallOptions(
        mediaConstraints: {
          'audio': {
            'mandatory': {
              'echoCancellation': true,
              'noiseSuppression': true,
              'autoGainControl': true,
            },
          },
          'video': false,
        },
      );

      // Fazer chamada SIP
      final call = _userAgent!.call(destination, callOptions);
      _sipCalls[callId] = call;

      // Configurar listeners
      _setupCallListeners(call, callId);

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

  /// Atende uma chamada
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

      sipCall.answer();

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

  /// Finaliza uma chamada
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
        sipCall.hangup();
      }

      // Atualizar modelo
      final updatedCall = call.copyWith(
        state: CallState.ended,
        endTime: DateTime.now(),
      );

      _activeCalls[callId] = updatedCall;

      // Remover após um delay
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

  /// Coloca chamada em espera/retoma
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
        sipCall.hold();
      } else {
        sipCall.unhold();
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

  /// Transfere uma chamada
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

      sipCall.refer(destination);

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

  /// Envia DTMF
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
          sipCall.sendDTMF(digit);
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

  /// Desconecta do servidor SIP
  Future<void> disconnect() async {
    try {
      _logger.i('Desconectando VoIP Engine...');

      // Cancelar timer de reconexão
      _reconnectTimer?.cancel();

      // Finalizar todas as chamadas
      for (final callId in _activeCalls.keys.toList()) {
        await hangupCall(callId);
      }

      // Parar User Agent
      _userAgent?.stop();

      // Limpar estado
      _activeCalls.clear();
      _sipCalls.clear();
      _conferences.clear();
      _isConnected = false;
      _isRegistered = false;
      _currentUser = null;
      _reconnectAttempts = 0;

      _updateState(VoipEngineState.disconnected);
      _notifyCallsUpdate();

      _logger.i('VoIP Engine desconectado');
    } catch (e) {
      _logger.e('Erro na desconexão: $e');
    }
  }

  /// Utilitários
  CallModel? getCall(String callId) => _activeCalls[callId];

  List<MediaDeviceInfo> get availableMicrophones => _audioInputs;
  List<MediaDeviceInfo> get availableSpeakers => _audioOutputs;
  String? get selectedMicrophone => _selectedMicrophone;
  String? get selectedSpeaker => _selectedSpeaker;

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
    _reconnectTimer?.cancel();
    _callsController.close();
    _stateController.close();
    _userAgent?.stop();
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
