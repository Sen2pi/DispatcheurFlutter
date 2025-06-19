import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/call_model.dart';
import '../core/constants/voip_constants.dart';
import '../core/errors/exceptions.dart';

class VoipEngine {
  static final VoipEngine _instance = VoipEngine._internal();
  factory VoipEngine() => _instance;
  VoipEngine._internal();

  final Logger _logger = Logger();
  final Uuid _uuid = const Uuid();

  // State Management
  final Map<String, CallModel> _activeCalls = {};
  final StreamController<List<CallModel>> _callsController =
      StreamController<List<CallModel>>.broadcast();
  final StreamController<VoipEngineState> _stateController =
      StreamController<VoipEngineState>.broadcast();

  bool _isRegistered = false;
  bool _isConnected = false;
  String? _currentUser;

  // Mock WebRTC para demonstração (substituir por implementação real)
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

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
      await _initializeWebRTC();
      _logger.i('VoIP Engine inicializado com sucesso');
    } catch (e) {
      _logger.e('Erro na inicialização do VoIP Engine: $e');
      throw VoipException('Falha na inicialização: $e');
    }
  }

  Future<void> _initializeWebRTC() async {
    try {
      final configuration = <String, dynamic>{
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
        ]
      };

      _peerConnection = await createPeerConnection(configuration);
      _logger.d('WebRTC inicializado com sucesso');
    } catch (e) {
      _logger.e('Erro na inicialização WebRTC: $e');
      throw VoipException('Erro no WebRTC: $e');
    }
  }

  /// Conecta ao servidor SIP (Mock para demonstração)
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

      // Simular conexão
      await Future.delayed(const Duration(seconds: 2));

      _currentUser = username;
      _isConnected = true;
      _isRegistered = true;

      _updateState(VoipEngineState.connected);

      // Salvar credenciais
      await _saveCredentials({
        'server': server,
        'username': username,
        'password': password,
        'displayName': displayName,
        'port': port,
        'secure': secure,
      });

      return true;
    } catch (e) {
      _logger.e('Erro na conexão SIP: $e');
      _updateState(VoipEngineState.disconnected);
      throw VoipException('Falha na conexão: $e');
    }
  }

  /// Faz uma chamada (Mock)
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

      // Simular progresso da chamada
      _simulateCallProgress(callId);

      _logger.i('Chamada iniciada com ID: $callId');
      return callId;
    } catch (e) {
      _logger.e('Erro ao fazer chamada: $e');
      throw VoipException('Erro na chamada: $e');
    }
  }

  /// Simular progresso da chamada para demonstração
  Future<void> _simulateCallProgress(String callId) async {
    await Future.delayed(const Duration(seconds: 1));
    _updateCallState(callId, CallState.ringing);

    await Future.delayed(const Duration(seconds: 3));
    _updateCallState(callId, CallState.established);
  }

  /// Atende uma chamada
  Future<void> answerCall(String callId) async {
    final call = _activeCalls[callId];

    if (call == null) {
      throw VoipException('Chamada não encontrada: $callId');
    }

    if (call.direction != CallDirection.incoming) {
      throw VoipException('Apenas chamadas recebidas podem ser atendidas');
    }

    try {
      _logger.i('Atendendo chamada: $callId');

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

    if (call == null) {
      _logger.w('Tentativa de desligar chamada inexistente: $callId');
      return;
    }

    try {
      _logger.i('Finalizando chamada: $callId');

      final updatedCall = call.copyWith(
        state: CallState.ended,
        endTime: DateTime.now(),
      );

      _activeCalls[callId] = updatedCall;

      // Remover após um delay
      Timer(const Duration(seconds: 2), () {
        _activeCalls.remove(callId);
        _notifyCallsUpdate();
      });

      _notifyCallsUpdate();

      _logger.i('Chamada finalizada: $callId');
    } catch (e) {
      _logger.e('Erro ao finalizar chamada: $e');
      _activeCalls.remove(callId);
      _notifyCallsUpdate();
    }
  }

  /// Coloca chamada em espera/retoma
  Future<void> holdCall(String callId, bool hold) async {
    final call = _activeCalls[callId];

    if (call == null) {
      throw VoipException('Chamada não encontrada: $callId');
    }

    if (call.state != CallState.established) {
      throw VoipException(
          'Apenas chamadas estabelecidas podem ser colocadas em espera');
    }

    try {
      _logger
          .i('${hold ? 'Colocando em espera' : 'Retomando'} chamada: $callId');

      final updatedCall = call.copyWith(isHeld: hold);
      _activeCalls[callId] = updatedCall;
      _notifyCallsUpdate();

      _logger.i('Chamada ${hold ? 'em espera' : 'retomada'}: $callId');
    } catch (e) {
      _logger
          .e('Erro ao ${hold ? 'colocar em espera' : 'retomar'} chamada: $e');
      throw VoipException('Erro na operação: $e');
    }
  }

  /// Transfere uma chamada
  Future<void> transferCall(String callId, String destination) async {
    final call = _activeCalls[callId];

    if (call == null) {
      throw VoipException('Chamada não encontrada: $callId');
    }

    if (call.state != CallState.established) {
      throw VoipException(
          'Apenas chamadas estabelecidas podem ser transferidas');
    }

    try {
      _logger.i('Transferindo chamada $callId para: $destination');

      final updatedCall = call.copyWith(
        transferTarget: destination,
        state: CallState.ended,
        endTime: DateTime.now(),
      );

      _activeCalls[callId] = updatedCall;

      Timer(const Duration(seconds: 2), () {
        _activeCalls.remove(callId);
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

    if (call == null) {
      throw VoipException('Chamada não encontrada: $callId');
    }

    if (call.state != CallState.established) {
      throw VoipException('Apenas chamadas estabelecidas podem enviar DTMF');
    }

    try {
      _logger.d('Enviando DTMF "$digits" para chamada: $callId');

      for (final digit in digits.split('')) {
        if (VoipConstants.dtmfDigits.contains(digit)) {
          // Simular envio DTMF
          await Future.delayed(VoipConstants.dtmfToneDuration);
        }
      }

      _logger.d('DTMF enviado com sucesso: $digits');
    } catch (e) {
      _logger.e('Erro ao enviar DTMF: $e');
      throw VoipException('Erro no DTMF: $e');
    }
  }

  /// Merge de chamadas para conferência
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

  /// Simular chamada recebida (para testes)
  Future<void> simulateIncomingCall(String fromNumber) async {
    final callId = _uuid.v4();

    final callModel = CallModel(
      id: callId,
      destination: fromNumber,
      direction: CallDirection.incoming,
      state: CallState.ringing,
      startTime: DateTime.now(),
      displayName: 'Contato $fromNumber',
    );

    _activeCalls[callId] = callModel;
    _notifyCallsUpdate();

    _logger.i('Chamada recebida simulada: $callId de $fromNumber');
  }

  /// Verificar se tem credenciais salvas
  Future<bool> hasVoipCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentials = prefs.getString('voip_credentials');
      return credentials != null;
    } catch (e) {
      return false;
    }
  }

  /// Salvar credenciais
  Future<void> _saveCredentials(Map<String, dynamic> credentials) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('voip_credentials', json.encode(credentials));
    } catch (e) {
      _logger.e('Erro ao salvar credenciais: $e');
    }
  }

  /// Carregar credenciais salvas
  Future<Map<String, dynamic>?> _loadCredentials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final credentialsJson = prefs.getString('voip_credentials');

      if (credentialsJson != null) {
        return json.decode(credentialsJson) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _logger.e('Erro ao carregar credenciais: $e');
      return null;
    }
  }

  /// Desconecta do servidor SIP
  Future<void> disconnect() async {
    try {
      _logger.i('Desconectando VoIP Engine...');

      // Finalizar todas as chamadas
      for (final callId in _activeCalls.keys.toList()) {
        await hangupCall(callId);
      }

      _activeCalls.clear();
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

  /// Utilitários
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
    _peerConnection?.dispose();
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
