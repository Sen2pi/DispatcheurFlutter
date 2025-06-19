import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;

import '../../widgets/voip/quick_notes_overlay.dart';
import '../../widgets/voip/call_history_overlay.dart';
import '../../widgets/voip/contacts_overlay.dart';
import '../../widgets/voip/dtmf_dialog.dart';
import '../../widgets/voip/transfer_overlay.dart';
import '../../widgets/voip/audio_devices_overlay.dart';
import '../../widgets/voip/incoming_call_modal.dart';
import '../../widgets/voip/numeric_keypad.dart';
import '../../widgets/voip/credentials_form.dart';
import '../../widgets/common/custom_icon.dart';
import '../../providers/voip_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../data/models/call_model.dart';

class VoipApp extends ConsumerStatefulWidget {
  const VoipApp({
    super.key,
    this.onCallContact,
  });

  final Function(String)? onCallContact;

  @override
  ConsumerState<VoipApp> createState() => _VoipAppState();
}

class _VoipAppState extends ConsumerState<VoipApp>
    with TickerProviderStateMixin {
  // Estados principais (como no React)
  bool _isExpanded = false;
  String _dialNumber = '';
  bool _numericKeypadOpen = false;
  bool _credentialsOpen = false;

  // Estados dos overlays (exatamente como no React)
  bool _contactsOverlayOpen = false;
  bool _notesOverlayOpen = false;
  bool _historyOverlayOpen = false;
  bool _transferOverlayOpen = false;
  bool _audioDevicesOverlayOpen = false;

  // Estados dos dialogs
  bool _dtmfDialogOpen = false;
  String? _dtmfCallId;
  String? _transferCallId;

  // Estados de chamadas recebidas
  bool _incomingCallModal = false;
  Map<String, dynamic>? _incomingCallInfo;
  String? _incomingCallId;

  // Estados de transferência
  final Map<String, String> _transferNumbers = {};
  final Map<String, bool> _showTransfers = {};

  // Estados de conferência (como no React)
  bool _conferenceMode = false;
  String? _conferenceInitiatorId;
  bool _merging = false;

  // Estados de conexão
  String _connectionStatus = 'disconnected';
  String _registrationStatus = 'unregistered';
  String _statusMessage = 'Non connecté';
  Map<String, dynamic>? _credentials;
  bool _hasAutoCredentials = false;
  Map<String, dynamic>? _currentUser;
  bool _autoConnecting = false;
  bool _initialConnectionAttempted = false;
  bool _canMakeCallsState = false;

  // Dispositivos de áudio
  String _selectedMicrophone = '';
  String _selectedSpeaker = '';

  // Chamadas
  List<CallModel> _calls = [];
  String? _activeCallId;
  Map<String, dynamic> _callsStatus = {
    'total': 0,
    'ringing': 0,
    'established': 0,
    'held': 0,
    'maxConcurrent': 10,
  };

  // Mensagens
  String? _connectionError;
  String _successMessage = '';
  DateTime? _lastConnectionAttempt;

  // Controladores de animação
  late AnimationController _expandController;
  late AnimationController _pulseController;
  late AnimationController _glowController;

  // Refs para posicionamento (como no React)
  final Map<String, GlobalKey> _dtmfButtonRefs = {};
  final GlobalKey _voipAppKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVoip();
    _loadSavedDevices();
  }

  void _initializeAnimations() {
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController.repeat(reverse: true);
    _glowController.repeat(reverse: true);
  }

  void _initializeVoip() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voipProvider.notifier).initialize();
      _checkAutoCredentials();
    });
  }

  void _loadSavedDevices() {
    // TODO: Implementar carregamento de dispositivos salvos
  }

  void _checkAutoCredentials() {
    // TODO: Implementar verificação de credenciais automáticas
  }

  @override
  void dispose() {
    _expandController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voipState = ref.watch(voipProvider);
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    // Responsividade baseada no React original
    final isMobile = screenSize.width < 768;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1024;
    final isSmallScreen = screenSize.height < 900;

    return Container(
      key: _voipAppKey,
      child: Stack(
        children: [
          // Interface principal VoIP
          _buildMainInterface(
              context, voipState, authState, isMobile, isTablet),

          // Overlays (mesma estrutura do React)
          if (_contactsOverlayOpen) _buildContactsOverlay(isMobile),
          if (_notesOverlayOpen) _buildNotesOverlay(isMobile),
          if (_historyOverlayOpen) _buildHistoryOverlay(isMobile),
          if (_transferOverlayOpen) _buildTransferOverlay(voipState, isMobile),
          if (_audioDevicesOverlayOpen)
            _buildAudioDevicesOverlay(voipState, isMobile),

          // Dialogs
          if (_dtmfDialogOpen && _dtmfCallId != null)
            _buildDTMFDialog(voipState, isMobile),
          if (_credentialsOpen) _buildCredentialsDialog(),
          if (_incomingCallModal && _incomingCallInfo != null)
            _buildIncomingCallModal(),
          if (_numericKeypadOpen) _buildNumericKeypad(),
        ],
      ),
    );
  }

  Widget _buildMainInterface(
    BuildContext context,
    VoipState voipState,
    AuthState authState,
    bool isMobile,
    bool isTablet,
  ) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // FABs secundários quando expandido (como no React)
          if (_isExpanded) ..._buildSecondaryFabs(isMobile),

          const SizedBox(height: 12),

          // Interface principal com animação
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: _getResponsiveWidth(isMobile, isTablet),
            height: _getResponsiveHeight(isMobile, isTablet),
            child: _isExpanded
                ? _buildExpandedInterface(voipState, authState, isMobile)
                : _buildCollapsedFAB(voipState, isMobile),
          ),
        ],
      ),
    );
  }

  double _getResponsiveWidth(bool isMobile, bool isTablet) {
    if (!_isExpanded) return 60;
    if (isMobile) return MediaQuery.of(context).size.width - 40;
    if (isTablet) return 400;
    return 450;
  }

  double _getResponsiveHeight(bool isMobile, bool isTablet) {
    if (!_isExpanded) return 60;
    final screenHeight = MediaQuery.of(context).size.height;
    if (isMobile) return screenHeight - 80;
    if (isTablet) return math.min(750, screenHeight - 100);
    return math.min(850, screenHeight - 100);
  }

  List<Widget> _buildSecondaryFabs(bool isMobile) {
    return [
      // FAB Histórico (como no React)
      _buildSecondaryFab(
        icon: Icons.history,
        color: _historyOverlayOpen
            ? const Color(0xFF8b5cf6)
            : const Color(0xFF6366f1),
        onPressed: () =>
            setState(() => _historyOverlayOpen = !_historyOverlayOpen),
        tooltip: 'Historique des appels',
        heroTag: "history",
        isMobile: isMobile,
        isActive: _historyOverlayOpen,
      ),

      const SizedBox(height: 8),

      // FAB Notas (como no React)
      _buildSecondaryFab(
        icon: Icons.note,
        color: _notesOverlayOpen
            ? const Color(0xFFd97706)
            : const Color(0xFFf59e0b),
        onPressed: () => setState(() => _notesOverlayOpen = !_notesOverlayOpen),
        tooltip: 'Notes rapides',
        heroTag: "notes",
        isMobile: isMobile,
        isActive: _notesOverlayOpen,
      ),

      const SizedBox(height: 8),

      // FAB Contactos (como no React)
      _buildSecondaryFab(
        icon: Icons.contacts,
        color: _contactsOverlayOpen
            ? const Color(0xFF059669)
            : const Color(0xFF10b981),
        onPressed: () =>
            setState(() => _contactsOverlayOpen = !_contactsOverlayOpen),
        tooltip: 'Contacts',
        heroTag: "contacts",
        isMobile: isMobile,
        isActive: _contactsOverlayOpen,
      ),
    ];
  }

  Widget _buildSecondaryFab({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
    required String heroTag,
    required bool isMobile,
    required bool isActive,
  }) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Transform.scale(
          scale: isActive ? 1.0 + (_pulseController.value * 0.05) : 1.0,
          child: Tooltip(
            message: tooltip,
            child: FloatingActionButton(
              mini: true,
              heroTag: heroTag,
              backgroundColor: color,
              onPressed: onPressed,
              elevation: isActive ? 8 + (_pulseController.value * 4) : 6,
              child: Icon(
                icon,
                color: Colors.white,
                size: isMobile ? 20 : 24,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedInterface(
      VoipState voipState, AuthState authState, bool isMobile) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Glassmorphism baseado no React
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3b82f6).withOpacity(0.15),
            const Color(0xFF93c5fd).withOpacity(0.1),
            const Color(0xFFdbeafe).withOpacity(0.05),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF3b82f6).withOpacity(0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3b82f6).withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Column(
            children: [
              // Header (como no React)
              _buildHeader(voipState, isMobile),

              // Status Section
              _buildStatusSection(voipState, authState, isMobile),

              // Lista de chamadas (scrollable)
              Expanded(
                child: _buildCallsList(voipState, isMobile),
              ),

              // Dialpad
              _buildDialPad(voipState, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsedFAB(VoipState voipState, bool isMobile) {
    return GestureDetector(
      onTap: () {
        setState(() => _isExpanded = true);
        _expandController.forward();
      },
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: voipState.isConnected
                    ? [
                        Color.lerp(const Color(0xFF22c55e),
                            const Color(0xFF16a34a), _pulseController.value)!,
                        const Color(0xFF16a34a),
                      ]
                    : [
                        Color.lerp(const Color(0xFF3b82f6),
                            const Color(0xFF1d4ed8), _pulseController.value)!,
                        const Color(0xFF1d4ed8),
                      ],
              ),
              boxShadow: [
                BoxShadow(
                  color: (voipState.isConnected ? Colors.green : Colors.blue)
                      .withOpacity(0.4 + (_pulseController.value * 0.2)),
                  blurRadius: 15 + (_pulseController.value * 5),
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(Icons.phone, color: Colors.white, size: 30),
                ),
                if (voipState.activeCalls.isNotEmpty)
                  Positioned(
                    top: 5,
                    right: 5,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${voipState.activeCalls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(VoipState voipState, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1e3a8a), Color(0xFF3b82f6)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.phone, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'DispatcheurCC',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          // Botões de controle (como no React)
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.history, color: Colors.white, size: 18),
                onPressed: () => setState(() => _historyOverlayOpen = true),
                tooltip: 'Historique',
              ),
              IconButton(
                icon: const Icon(Icons.note, color: Colors.white, size: 18),
                onPressed: () => setState(() => _notesOverlayOpen = true),
                tooltip: 'Notes',
              ),
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white, size: 18),
                onPressed: () => setState(() => _credentialsOpen = true),
                tooltip: 'Configurations',
              ),
            ],
          ),

          // Status de conexão
          _buildConnectionStatus(voipState),

          // Contador de chamadas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${voipState.activeCalls.length}/${voipState.maxConcurrentCalls}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () {
              setState(() => _isExpanded = false);
              _expandController.reverse();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(VoipState voipState) {
    Color statusColor;
    String statusText;

    if (voipState.isConnected && voipState.isRegistered) {
      statusColor = Colors.green;
      statusText = 'Connecté';
    } else if (voipState.isConnecting || _autoConnecting) {
      statusColor = Colors.orange;
      statusText = 'Connexion...';
    } else {
      statusColor = Colors.red;
      statusText = 'Déconnecté';
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color:
                statusColor.withOpacity(0.2 + (_pulseController.value * 0.1)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            statusText,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusSection(
      VoipState voipState, AuthState authState, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          // Informações do usuário (como no React)
          if (voipState.currentUser != null) ...[
            Row(
              children: [
                const Icon(Icons.person, color: Color(0xFF3b82f6)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Utilisateur: ${voipState.currentUser}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1e3a8a),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Botão de configurações de áudio (como no React)
          if (voipState.isConnected) ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        setState(() => _audioDevicesOverlayOpen = true),
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Dispositifs Audio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3b82f6),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Mensagens de erro ou sucesso (como no React)
          if (voipState.error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      voipState.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () =>
                        ref.read(voipProvider.notifier).clearError(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Mensagem de sucesso
          if (_successMessage.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _successMessage,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.green),
                    onPressed: () => setState(() => _successMessage = ''),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildCallsList(VoipState voipState, bool isMobile) {
    if (voipState.activeCalls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_disabled,
              size: isMobile ? 48 : 64,
              color: Colors.grey.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun appel actif',
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1e3a8a),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jusqu\'à ${voipState.maxConcurrentCalls} appels simultanés',
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                color: Colors.grey,
              ),
            ),
            if (voipState.isConnected) ...[
              const SizedBox(height: 8),
              const Text(
                '✅ Prêt à recevoir et émettre des appels',
                style: TextStyle(
                  color: Color(0xFF22c55e),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      itemCount: voipState.activeCalls.length,
      itemBuilder: (context, index) {
        final call = voipState.activeCalls[index];
        return _buildCallCard(call, voipState, isMobile);
      },
    );
  }

  Widget _buildCallCard(CallModel call, VoipState voipState, bool isMobile) {
    final isActive = call.id == voipState.activeCallId;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getCallColor(call).withOpacity(0.1),
              _getCallColor(call).withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getCallColor(call).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: isMobile ? 16 : 20,
                    backgroundColor: _getCallColor(call),
                    child: Icon(
                      _getCallIcon(call),
                      color: Colors.white,
                      size: isMobile ? 16 : 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          call.displayName ?? call.destination,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1e3a8a),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${call.direction == CallDirection.incoming ? 'Entrant' : 'Sortant'} • ',
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                color: const Color(0xFF64748b),
                              ),
                            ),
                            Text(
                              call.formattedDuration,
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                color: const Color(0xFF64748b),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getCallColor(call).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: _getCallColor(call)),
                              ),
                              child: Text(
                                call.statusText,
                                style: TextStyle(
                                  color: _getCallColor(call),
                                  fontSize: isMobile ? 9 : 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Botões de controle
              _buildCallControls(call, voipState, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCallControls(
      CallModel call, VoipState voipState, bool isMobile) {
    return Wrap(
      spacing: isMobile ? 6 : 8,
      children: [
        // Botões para chamadas tocando
        if (call.state == CallState.ringing &&
            call.direction == CallDirection.incoming) ...[
          _buildControlButton(
            icon: Icons.call,
            color: Colors.green,
            onPressed: () => _handleAnswer(call.id),
            tooltip: 'Répondre',
            isMobile: isMobile,
          ),
          _buildControlButton(
            icon: Icons.call_end,
            color: Colors.red,
            onPressed: () => _handleHangup(call.id),
            tooltip: 'Refuser',
            isMobile: isMobile,
          ),
        ],

        // Botões para chamadas estabelecidas
        if (call.state == CallState.established) ...[
          _buildControlButton(
            icon: call.isHeld ? Icons.play_arrow : Icons.pause,
            color: call.isHeld ? Colors.blue : Colors.orange,
            onPressed: () => _handleHold(call.id),
            tooltip: call.isHeld ? 'Reprendre' : 'Suspendre',
            isMobile: isMobile,
          ),
          _buildControlButton(
            icon: Icons.dialpad,
            color: Colors.purple,
            onPressed: () => _openDTMFDialog(call.id),
            tooltip: 'DTMF',
            isMobile: isMobile,
          ),
          _buildControlButton(
            icon: Icons.swap_calls,
            color: Colors.green,
            onPressed: () => _openTransferOverlay(call.id),
            tooltip: 'Transférer',
            isMobile: isMobile,
          ),
          if (!call.isActive)
            _buildControlButton(
              icon: Icons.volume_up,
              color: Colors.blue,
              onPressed: () => _handleSetActive(call.id),
              tooltip: 'Activer',
              isMobile: isMobile,
            ),
        ],

        // Botão desligar (sempre presente)
        _buildControlButton(
          icon: Icons.call_end,
          color: Colors.red,
          onPressed: () => _handleHangup(call.id),
          tooltip: 'Raccrocher',
          isMobile: isMobile,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
    required bool isMobile,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: isMobile ? 32 : 36,
        height: isMobile ? 32 : 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: IconButton(
          icon: Icon(icon, size: isMobile ? 16 : 18),
          color: color,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
        ),
      ),
    );
  }

  Widget _buildDialPad(VoipState voipState, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFe2e8f0)),
        ),
      ),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Numéro à appeler',
              prefixIcon: IconButton(
                icon: const Icon(Icons.dialpad),
                onPressed: () => setState(() => _numericKeypadOpen = true),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: _dialNumber.isNotEmpty && voipState.isConnected
                    ? () => _makeCall()
                    : null,
              ),
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: const Color(0xFF3b82f6).withOpacity(0.1),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) => setState(() => _dialNumber = value),
            onSubmitted: (_) => _makeCall(),
          ),
          if (voipState.activeCalls.length >= voipState.maxConcurrentCalls) ...[
            const SizedBox(height: 8),
            Text(
              'Limite de ${voipState.maxConcurrentCalls} appels atteint',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Overlay Builders (como no React)
  Widget _buildContactsOverlay(bool isMobile) {
    return ContactsOverlay(
      isOpen: _contactsOverlayOpen,
      onClose: () => setState(() => _contactsOverlayOpen = false),
      isMobile: isMobile,
      onCallContact: (number) {
        setState(() {
          _dialNumber = number;
          _contactsOverlayOpen = false;
        });
      },
    );
  }

  Widget _buildNotesOverlay(bool isMobile) {
    return QuickNotesOverlay(
      isOpen: _notesOverlayOpen,
      onClose: () => setState(() => _notesOverlayOpen = false),
      isMobile: isMobile,
    );
  }

  Widget _buildHistoryOverlay(bool isMobile) {
    return CallHistoryOverlay(
      isOpen: _historyOverlayOpen,
      onClose: () => setState(() => _historyOverlayOpen = false),
      isMobile: isMobile,
      onCallNumber: (number) {
        setState(() {
          _dialNumber = number;
          _historyOverlayOpen = false;
        });
      },
    );
  }

  Widget _buildTransferOverlay(VoipState voipState, bool isMobile) {
    return TransferOverlay(
      isOpen: _transferOverlayOpen,
      callId: _transferCallId,
      onClose: () => setState(() => _transferOverlayOpen = false),
      onTransfer: (callId, number) {
        ref.read(voipProvider.notifier).transferCall(callId, number);
        setState(() => _transferOverlayOpen = false);
      },
      isMobile: isMobile,
    );
  }

  Widget _buildAudioDevicesOverlay(VoipState voipState, bool isMobile) {
    return AudioDevicesOverlay(
      isOpen: _audioDevicesOverlayOpen,
      onClose: () => setState(() => _audioDevicesOverlayOpen = false),
      onMicrophoneChanged: (deviceId) {
        ref.read(voipProvider.notifier).setMicrophone(deviceId);
      },
      onSpeakerChanged: (deviceId) {
        ref.read(voipProvider.notifier).setSpeaker(deviceId);
      },
      selectedMicrophone: voipState.selectedMicrophone,
      selectedSpeaker: voipState.selectedSpeaker,
      availableMicrophones: voipState.availableMicrophones,
      availableSpeakers: voipState.availableSpeakers,
      isMobile: isMobile,
    );
  }

  Widget _buildDTMFDialog(VoipState voipState, bool isMobile) {
    return DTMFDialog(
      isOpen: _dtmfDialogOpen,
      callId: _dtmfCallId!,
      onClose: () => setState(() => _dtmfDialogOpen = false),
      onSendDTMF: (callId, digits) {
        ref.read(voipProvider.notifier).sendDTMF(callId, digits);
      },
      isMobile: isMobile,
    );
  }

  Widget _buildCredentialsDialog() {
    return CredentialsForm(
      open: _credentialsOpen,
      onClose: () => setState(() => _credentialsOpen = false),
      onSubmit: (credentials) {
        ref.read(voipProvider.notifier).connect(
              server: credentials['server'],
              username: credentials['username'],
              password: credentials['password'],
              displayName: credentials['displayName'],
              port: credentials['port'],
              secure: credentials['secure'],
            );
        setState(() => _credentialsOpen = false);
      },
    );
  }

  Widget _buildIncomingCallModal() {
    return IncomingCallModal(
      isOpen: _incomingCallModal,
      callerInfo: _incomingCallInfo,
      onAnswer: () => _handleAnswerFromModal(),
      onReject: () => _handleRejectFromModal(),
    );
  }

  Widget _buildNumericKeypad() {
    return NumericKeypad(
      isOpen: _numericKeypadOpen,
      onClose: () => setState(() => _numericKeypadOpen = false),
      onNumberSelected: (number) {
        setState(() {
          _dialNumber += number;
        });
      },
      isMobile: MediaQuery.of(context).size.width < 768,
    );
  }

  // Event Handlers (como no React)
  void _makeCall() {
    if (_dialNumber.isNotEmpty) {
      ref.read(voipProvider.notifier).makeCall(_dialNumber);
      setState(() {
        _dialNumber = '';
        _successMessage = 'Appel initié vers $_dialNumber';
      });
      // Auto limpar mensagem após 3 segundos
      Timer(const Duration(seconds: 3), () {
        setState(() => _successMessage = '');
      });
    }
  }

  void _handleAnswer(String callId) {
    ref.read(voipProvider.notifier).answerCall(callId);
    setState(() => _successMessage = 'Appel répondu');
    Timer(const Duration(seconds: 2), () {
      setState(() => _successMessage = '');
    });
  }

  void _handleHangup(String callId) {
    ref.read(voipProvider.notifier).hangupCall(callId);
    setState(() => _successMessage = 'Appel terminé');
    Timer(const Duration(seconds: 2), () {
      setState(() => _successMessage = '');
    });
  }

  void _handleHold(String callId) {
    final voipState = ref.read(voipProvider);
    final call = voipState.activeCalls.firstWhere((c) => c.id == callId);
    ref.read(voipProvider.notifier).holdCall(callId, !call.isHeld);
    setState(() =>
        _successMessage = call.isHeld ? 'Appel repris' : 'Appel en attente');
    Timer(const Duration(seconds: 2), () {
      setState(() => _successMessage = '');
    });
  }

  void _handleSetActive(String callId) {
    ref.read(voipProvider.notifier).setActiveCall(callId);
    setState(() => _successMessage = 'Appel activé');
    Timer(const Duration(seconds: 2), () {
      setState(() => _successMessage = '');
    });
  }

  void _openTransferOverlay(String callId) {
    setState(() {
      _transferCallId = callId;
      _transferOverlayOpen = true;
    });
  }

  void _openDTMFDialog(String callId) {
    setState(() {
      _dtmfCallId = callId;
      _dtmfDialogOpen = true;
    });
  }

  void _handleAnswerFromModal() {
    if (_incomingCallId != null) {
      ref.read(voipProvider.notifier).answerCall(_incomingCallId!);
      setState(() {
        _incomingCallModal = false;
        _incomingCallInfo = null;
        _incomingCallId = null;
        _successMessage = 'Appel répondu';
      });
      Timer(const Duration(seconds: 2), () {
        setState(() => _successMessage = '');
      });
    }
  }

  void _handleRejectFromModal() {
    if (_incomingCallId != null) {
      ref.read(voipProvider.notifier).hangupCall(_incomingCallId!);
      setState(() {
        _incomingCallModal = false;
        _incomingCallInfo = null;
        _incomingCallId = null;
        _successMessage = 'Appel rejeté';
      });
      Timer(const Duration(seconds: 2), () {
        setState(() => _successMessage = '');
      });
    }
  }

  // Utility methods
  Color _getCallColor(CallModel call) {
    switch (call.state) {
      case CallState.ringing:
        return call.direction == CallDirection.incoming
            ? Colors.green
            : Colors.blue;
      case CallState.established:
        return call.isHeld ? Colors.orange : Colors.blue;
      case CallState.ended:
        return Colors.grey;
      case CallState.failed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getCallIcon(CallModel call) {
    switch (call.state) {
      case CallState.ringing:
        return call.direction == CallDirection.incoming
            ? Icons.call_received
            : Icons.call_made;
      case CallState.established:
        return call.isHeld ? Icons.pause : Icons.phone_in_talk;
      case CallState.ended:
        return Icons.call_end;
      case CallState.failed:
        return Icons.call_end;
      default:
        return Icons.phone;
    }
  }
}
