import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../data/models/call_model.dart';
import '../core/errors/exceptions.dart';

enum VoipEngineState {
  disconnected,
  connecting,
  connected,
  registered,
  unregistered,
  error,
}

class VoipEngine {
  static final VoipEngine _instance = VoipEngine._internal();
  factory VoipEngine() => _instance;
  VoipEngine._internal();

  // Estado principal
  VoipEngineState _state = VoipEngineState.disconnected;
  bool _isConnected = false;
  bool _isRegistered = false;
  String? _currentUser;

  // Chamadas
  final Map<String, CallModel> _calls = {};
  String? _activeCallId;
  final StreamController<List<CallModel>> _callsController =
      StreamController<List<CallModel>>.broadcast();
  final StreamController<VoipEngineState> _stateController =
      StreamController<VoipEngineState>.broadcast();

  // Configurações
  final int maxConcurrentCalls = 10;
  final Uuid _uuid = const Uuid();

  // Dispositivos de áudio (mock)
  String? _selectedMicrophone;
  String? _selectedSpeaker;
  final List<MockMediaDevice> _audioInputs = [];
  final List<MockMediaDevice> _audioOutputs = [];

  // Timers
  Timer? _statusTimer;
  Timer? _callDurationTimer;

  // Getters
  VoipEngineState get state => _state;
  bool get isConnected => _isConnected;
  bool get isRegistered => _isRegistered;
  String? get currentUser => _currentUser;
  List<CallModel> get activeCalls => _calls.values.toList();
  String? get activeCallId => _activeCallId;
  String? get selectedMicrophone => _selectedMicrophone;
  String? get selectedSpeaker => _selectedSpeaker;
  List<MockMediaDevice> get availableMicrophones => _audioInputs;
  List<MockMediaDevice> get availableSpeakers => _audioOutputs;

  // Streams
  Stream<List<CallModel>> get callsStream => _callsController.stream;
  Stream<VoipEngineState> get stateStream => _stateController.stream;

  /// Inicializar o engine
  Future<void> initialize() async {
    try {
      debugPrint('🔧 Inicializando VoIP Engine...');

      // Mock de dispositivos de áudio
      await _initializeMockAudioDevices();

      // Carregar configurações salvas
      await _loadSavedSettings();

      _updateState(VoipEngineState.disconnected);

      // Timer para atualizar duração das chamadas
      _startCallDurationTimer();

      debugPrint('✅ VoIP Engine inicializado');
    } catch (e) {
      debugPrint('❌ Erro na inicialização: $e');
      throw VoipException('Falha na inicialização: $e');
    }
  }

  /// Conectar ao servidor SIP (mock)
  Future<bool> connect({
    required String server,
    required String username,
    required String password,
    required String displayName,
    int port = 5060,
    bool secure = false,
  }) async {
    try {
      debugPrint('🔗 Conectando a $server:$port como $username');

      _updateState(VoipEngineState.connecting);

      // Simular tempo de conexão
      await Future.delayed(const Duration(seconds: 2));

      // Simular sucesso (90% de chance)
      if (Random().nextDouble() > 0.1) {
        _isConnected = true;
        _isRegistered = true;
        _currentUser = username;

        await _saveCredentials({
          'server': server,
          'username': username,
          'password': password,
          'displayName': displayName,
          'port': port,
          'secure': secure,
        });

        _updateState(VoipEngineState.registered);

        // Simular chamada recebida após 10 segundos
        _simulateIncomingCallAfterDelay();

        debugPrint('✅ Conectado e registrado como $username');
        return true;
      } else {
        throw Exception('Falha na autenticação');
      }
    } catch (e) {
      debugPrint('❌ Erro na conexão: $e');
      _updateState(VoipEngineState.error);
      throw VoipException('Erro na conexão: $e');
    }
  }

  /// Fazer uma chamada
  Future<String> makeCall(String destination) async {
    if (!_isRegistered) {
      throw VoipException('Não registrado no servidor SIP');
    }

    if (_calls.length >= maxConcurrentCalls) {
      throw VoipException(
          'Limite máximo de $maxConcurrentCalls chamadas atingido');
    }

    try {
      final callId = _uuid.v4();

      debugPrint('📞 Fazendo chamada para $destination (ID: $callId)');

      final call = CallModel(
        id: callId,
        destination: destination,
        direction: CallDirection.outgoing,
        state: CallState.connecting,
        startTime: DateTime.now(),
        isOutbound: true,
        displayName: _formatDisplayName(destination),
      );

      _calls[callId] = call;
      _notifyCallsUpdate();

      // Simular progresso da chamada
      _simulateCallProgress(callId);

      return callId;
    } catch (e) {
      debugPrint('❌ Erro ao fazer chamada: $e');
      throw VoipException('Erro na chamada: $e');
    }
  }

  /// Atender uma chamada
  Future<void> answerCall(String callId) async {
    final call = _calls[callId];
    if (call == null) {
      throw VoipException('Chamada não encontrada: $callId');
    }

    if (call.direction != CallDirection.incoming) {
      throw VoipException('Apenas chamadas recebidas podem ser atendidas');
    }

    try {
      debugPrint('✅ Atendendo chamada $callId');

      final updatedCall = call.copyWith(
        state: CallState.established,
        answeredTime: DateTime.now(),
      );

      _calls[callId] = updatedCall;
      _setActiveCall(callId);
      _notifyCallsUpdate();
    } catch (e) {
      debugPrint('❌ Erro ao atender: $e');
      throw VoipException('Erro ao atender: $e');
    }
  }

  /// Finalizar uma chamada
  Future<void> hangupCall(String callId) async {
    final call = _calls[callId];
    if (call == null) {
      debugPrint('⚠️ Tentativa de desligar chamada inexistente: $callId');
      return;
    }

    try {
      debugPrint('📴 Finalizando chamada $callId');

      final updatedCall = call.copyWith(
        state: CallState.ended,
        endTime: DateTime.now(),
      );

      _calls[callId] = updatedCall;

      // Se era a chamada ativa, limpar
      if (_activeCallId == callId) {
        _activeCallId = null;
      }

      _notifyCallsUpdate();

      // Remover após delay
      Timer(const Duration(seconds: 3), () {
        _calls.remove(callId);
        _notifyCallsUpdate();
      });
    } catch (e) {
      debugPrint('❌ Erro ao finalizar: $e');
      _calls.remove(callId);
      _notifyCallsUpdate();
    }
  }

  /// Colocar em espera/retomar
  Future<void> holdCall(String callId, bool hold) async {
    final call = _calls[callId];
    if (call == null) {
      throw VoipException('Chamada não encontrada: $callId');
    }

    if (call.state != CallState.established) {
      throw VoipException('Apenas chamadas estabelecidas podem ser pausadas');
    }

    try {
      debugPrint(
          '${hold ? '⏸️' : '▶️'} ${hold ? 'Pausando' : 'Retomando'} chamada $callId');

      final updatedCall = call.copyWith(isHeld: hold);
      _calls[callId] = updatedCall;
      _notifyCallsUpdate();
    } catch (e) {
      debugPrint('❌ Erro ao pausar/retomar: $e');
      throw VoipException('Erro na operação: $e');
    }
  }

  /// Transferir chamada
  Future<void> transferCall(String callId, String destination) async {
    final call = _calls[callId];
    if (call == null) {
      throw VoipException('Chamada não encontrada: $callId');
    }

    if (call.state != CallState.established) {
      throw VoipException(
          'Apenas chamadas estabelecidas podem ser transferidas');
    }

    try {
      debugPrint('📞➡️ Transferindo chamada $callId para $destination');

      final updatedCall = call.copyWith(
        transferTarget: destination,
        state: CallState.ended,
        endTime: DateTime.now(),
      );

      _calls[callId] = updatedCall;
      _notifyCallsUpdate();

      // Remover após delay
      Timer(const Duration(seconds: 2), () {
        _calls.remove(callId);
        _notifyCallsUpdate();
      });
    } catch (e) {
      debugPrint('❌ Erro na transferência: $e');
      throw VoipException('Erro na transferência: $e');
    }
  }

  /// Enviar DTMF
  Future<void> sendDTMF(String callId, String digits) async {
    final call = _calls[callId];
    if (call == null) {
      throw VoipException('Chamada não encontrada: $callId');
    }

    if (call.state != CallState.established) {
      throw VoipException('Apenas chamadas estabelecidas podem enviar DTMF');
    }

    try {
      debugPrint('🎹 Enviando DTMF "$digits" para chamada $callId');

      // Simular envio
      await Future.delayed(const Duration(milliseconds: 100));
    } catch (e) {
      debugPrint('❌ Erro no DTMF: $e');
      throw VoipException('Erro no DTMF: $e');
    }
  }

  /// Criar conferência
  Future<void> mergeCalls(String callId1, String callId2) async {
    final call1 = _calls[callId1];
    final call2 = _calls[callId2];

    if (call1 == null || call2 == null) {
      throw VoipException('Uma ou ambas as chamadas não foram encontradas');
    }

    if (call1.state != CallState.established ||
        call2.state != CallState.established) {
      throw VoipException('Ambas as chamadas devem estar estabelecidas');
    }

    try {
      debugPrint('🤝 Criando conferência entre $callId1 e $callId2');

      final updatedCall1 = call1.copyWith(
        isConference: true,
        participants: [callId2],
      );

      final updatedCall2 = call2.copyWith(
        isConference: true,
        participants: [callId1],
      );

      _calls[callId1] = updatedCall1;
      _calls[callId2] = updatedCall2;

      _notifyCallsUpdate();
    } catch (e) {
      debugPrint('❌ Erro na conferência: $e');
      throw VoipException('Erro na conferência: $e');
    }
  }

  /// Definir chamada ativa
  void setActiveCall(String callId) {
    if (_calls.containsKey(callId)) {
      _setActiveCall(callId);
      _notifyCallsUpdate();
    }
  }

  /// Configurar microfone
  Future<void> setSelectedMicrophone(String deviceId) async {
    _selectedMicrophone = deviceId;
    await _saveSelectedDevice('microphone', deviceId);
    debugPrint('🎤 Microfone selecionado: $deviceId');
  }

  /// Configurar alto-falante
  Future<void> setSelectedSpeaker(String deviceId) async {
    _selectedSpeaker = deviceId;
    await _saveSelectedDevice('speaker', deviceId);
    debugPrint('🔊 Alto-falante selecionado: $deviceId');
  }

  /// Desconectar
  Future<void> disconnect() async {
    try {
      debugPrint('🔌 Desconectando VoIP Engine...');

      // Finalizar todas as chamadas
      for (final callId in _calls.keys.toList()) {
        await hangupCall(callId);
      }

      _calls.clear();
      _activeCallId = null;
      _isConnected = false;
      _isRegistered = false;
      _currentUser = null;

      _updateState(VoipEngineState.disconnected);
      _notifyCallsUpdate();
    } catch (e) {
      debugPrint('❌ Erro na desconexão: $e');
    }
  }

  /// Verificar se tem credenciais
  bool hasVoipCredentials() {
    // Mock - sempre retorna true para teste
    return true;
  }

  /// Auto-conectar
  Future<bool> autoConnect(
    Function(Map<String, dynamic>) onStatusChange,
    Map<String, Function> callbacks,
  ) async {
    // Mock de auto-conexão
    await Future.delayed(const Duration(seconds: 1));

    return await connect(
      server: 'mock.server.com',
      username: 'user123',
      password: 'password123',
      displayName: 'Mock User',
    );
  }

  /// Obter informações do usuário atual
  Map<String, dynamic> getCurrentUserInfo() {
    return {
      'username': _currentUser,
      'server': 'mock.server.com',
      'displayName': 'Mock User',
    };
  }

  /// Obter chamada por ID
  CallModel? getCall(String callId) => _calls[callId];

  /// Limpar auto-conexão
  void resetAutoConnect() {
    // Mock
  }

  /// Marcar próxima chamada como saída
  void markNextCallAsOutbound() {
    // Mock
  }

  // Métodos privados
  void _updateState(VoipEngineState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  void _notifyCallsUpdate() {
    _callsController.add(activeCalls);
  }

  void _setActiveCall(String? callId) {
    _activeCallId = callId;

    // Atualizar flag isActive nas chamadas
    for (final entry in _calls.entries) {
      final call = entry.value;
      final isActive = entry.key == callId;
      if (call.isActive != isActive) {
        _calls[entry.key] = call.copyWith(isActive: isActive);
      }
    }
  }

  Future<void> _initializeMockAudioDevices() async {
    _audioInputs.addAll([
      MockMediaDevice('mic1', 'Microfone Padrão'),
      MockMediaDevice('mic2', 'Microfone USB'),
      MockMediaDevice('mic3', 'Microfone Bluetooth'),
    ]);

    _audioOutputs.addAll([
      MockMediaDevice('speaker1', 'Alto-falantes Padrão'),
      MockMediaDevice('speaker2', 'Headphones'),
      MockMediaDevice('speaker3', 'Alto-falantes Bluetooth'),
    ]);
  }

  Future<void> _loadSavedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _selectedMicrophone = prefs.getString('voip_selected_microphone');
      _selectedSpeaker = prefs.getString('voip_selected_speaker');
    } catch (e) {
      debugPrint('⚠️ Erro ao carregar configurações: $e');
    }
  }

  Future<void> _saveCredentials(Map<String, dynamic> credentials) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('voip_credentials', credentials.toString());
    } catch (e) {
      debugPrint('⚠️ Erro ao salvar credenciais: $e');
    }
  }

  Future<void> _saveSelectedDevice(String type, String deviceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('voip_selected_$type', deviceId);
    } catch (e) {
      debugPrint('⚠️ Erro ao salvar dispositivo: $e');
    }
  }

  void _startCallDurationTimer() {
    _callDurationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Atualizar duração das chamadas ativas
      bool hasActiveCall = false;
      for (final entry in _calls.entries) {
        final call = entry.value;
        if (call.state == CallState.established ||
            call.state == CallState.ringing) {
          hasActiveCall = true;
          break;
        }
      }

      if (hasActiveCall) {
        _notifyCallsUpdate();
      }
    });
  }

  void _simulateCallProgress(String callId) async {
    // Simular progresso: connecting -> ringing -> established
    await Future.delayed(const Duration(milliseconds: 500));

    final call = _calls[callId];
    if (call != null && call.state == CallState.connecting) {
      _calls[callId] = call.copyWith(state: CallState.ringing);
      _notifyCallsUpdate();

      // Simular atendimento automático após 3-8 segundos
      final waitTime = 3 + Random().nextInt(6);
      await Future.delayed(Duration(seconds: waitTime));

      final updatedCall = _calls[callId];
      if (updatedCall != null && updatedCall.state == CallState.ringing) {
        _calls[callId] = updatedCall.copyWith(
          state: CallState.established,
          answeredTime: DateTime.now(),
        );
        _setActiveCall(callId);
        _notifyCallsUpdate();
      }
    }
  }

  void _simulateIncomingCallAfterDelay() {
    // Simular chamada recebida após 10-30 segundos
    final delay = 10 + Random().nextInt(21);
    Timer(Duration(seconds: delay), () {
      _simulateIncomingCall();
    });
  }

  void _simulateIncomingCall() {
    if (_calls.length >= maxConcurrentCalls) return;

    final callId = _uuid.v4();
    final phoneNumbers = ['+351912345678', '+351987654321', '+351555123456'];
    final names = ['João Silva', 'Maria Santos', 'Pedro Costa'];

    final randomIndex = Random().nextInt(phoneNumbers.length);
    final destination = phoneNumbers[randomIndex];
    final displayName = names[randomIndex];

    debugPrint('📞 Simulando chamada recebida de $displayName ($destination)');

    final call = CallModel(
      id: callId,
      destination: destination,
      direction: CallDirection.incoming,
      state: CallState.ringing,
      startTime: DateTime.now(),
      displayName: displayName,
    );

    _calls[callId] = call;
    _notifyCallsUpdate();

    // Auto-finalizar se não atendida em 30 segundos
    Timer(const Duration(seconds: 30), () {
      final currentCall = _calls[callId];
      if (currentCall != null && currentCall.state == CallState.ringing) {
        _calls[callId] = currentCall.copyWith(
          state: CallState.ended,
          endTime: DateTime.now(),
        );
        _notifyCallsUpdate();

        Timer(const Duration(seconds: 3), () {
          _calls.remove(callId);
          _notifyCallsUpdate();
        });
      }
    });
  }

  String _formatDisplayName(String destination) {
    // Simular nomes baseados no número
    if (destination.contains('123')) return 'Empresa ABC';
    if (destination.contains('456')) return 'Cliente XYZ';
    if (destination.contains('789')) return 'Suporte Técnico';
    return 'Contacto $destination';
  }

  void dispose() {
    _statusTimer?.cancel();
    _callDurationTimer?.cancel();
    _callsController.close();
    _stateController.close();
  }
}

// Classe mock para dispositivos de mídia
class MockMediaDevice {
  final String deviceId;
  final String label;

  MockMediaDevice(this.deviceId, this.label);
}
