import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/voip_engine.dart';
import '../../providers/voip_provider.dart';
import '../common/glass_container.dart';
import 'call_card.dart';
import 'dial_pad.dart';
import 'contacts_overlay.dart';
import 'notes_overlay.dart';
import 'history_overlay.dart';
import 'dtmf_dialog.dart';
import 'transfer_overlay.dart';
import 'audio_controls_overlay.dart';

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
  // Estados principais
  bool _isExpanded = false;
  String _dialNumber = '';

  // Estados dos overlays
  bool _contactsOverlayOpen = false;
  bool _notesOverlayOpen = false;
  bool _historyOverlayOpen = false;
  bool _transferOverlayOpen = false;
  bool _audioDevicesOverlayOpen = false;

  // Estados dos dialogs
  bool _dtmfDialogOpen = false;
  String? _dtmfCallId;
  String? _transferCallId;

  // Conferência
  bool _conferenceMode = false;
  String? _conferenceInitiatorId;
  bool _merging = false;

  // Controladores de animação
  late AnimationController _expandController;
  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Inicializar VoIP
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voipProvider.notifier).initialize();
    });
  }

  @override
  void dispose() {
    _expandController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voipState = ref.watch(voipProvider);
    final voipNotifier = ref.read(voipProvider.notifier);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1024;

    return Stack(
      children: [
        // Interface principal VoIP
        _buildMainInterface(context, voipState, voipNotifier, isMobile),

        // Overlays
        if (_contactsOverlayOpen) _buildContactsOverlay(isMobile),
        if (_notesOverlayOpen) _buildNotesOverlay(isMobile),
        if (_historyOverlayOpen) _buildHistoryOverlay(isMobile),
        if (_transferOverlayOpen) _buildTransferOverlay(voipState, isMobile),
        if (_audioDevicesOverlayOpen)
          _buildAudioDevicesOverlay(voipState, isMobile),

        // Dialog DTMF
        if (_dtmfDialogOpen && _dtmfCallId != null)
          _buildDTMFDialog(voipState, voipNotifier, isMobile),
      ],
    );
  }

  Widget _buildMainInterface(
    BuildContext context,
    VoipState voipState,
    VoipNotifier voipNotifier,
    bool isMobile,
  ) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // FABs adicionais quando expandido
          if (_isExpanded) ..._buildSecondaryFabs(isMobile),

          const SizedBox(height: 12),

          // Interface principal
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isExpanded ? (isMobile ? screenSize.width - 40 : 450) : 60,
            height:
                _isExpanded ? (isMobile ? screenSize.height - 80 : 600) : 60,
            child: _isExpanded
                ? _buildExpandedInterface(voipState, voipNotifier, isMobile)
                : _buildCollapsedFAB(voipState, isMobile),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSecondaryFabs(bool isMobile) {
    return [
      // FAB Histórico
      FloatingActionButton(
        mini: true,
        heroTag: "history",
        backgroundColor: _historyOverlayOpen
            ? const Color(0xFF8b5cf6)
            : const Color(0xFF6366f1),
        onPressed: () =>
            setState(() => _historyOverlayOpen = !_historyOverlayOpen),
        child: Icon(
          Icons.history,
          color: Colors.white,
          size: isMobile ? 20 : 24,
        ),
      ),

      const SizedBox(height: 8),

      // FAB Notas
      FloatingActionButton(
        mini: true,
        heroTag: "notes",
        backgroundColor: _notesOverlayOpen
            ? const Color(0xFFd97706)
            : const Color(0xFFf59e0b),
        onPressed: () => setState(() => _notesOverlayOpen = !_notesOverlayOpen),
        child: Icon(
          Icons.note,
          color: Colors.white,
          size: isMobile ? 20 : 24,
        ),
      ),

      const SizedBox(height: 8),

      // FAB Contactos
      FloatingActionButton(
        mini: true,
        heroTag: "contacts",
        backgroundColor: _contactsOverlayOpen
            ? const Color(0xFF059669)
            : const Color(0xFF10b981),
        onPressed: () =>
            setState(() => _contactsOverlayOpen = !_contactsOverlayOpen),
        child: Icon(
          Icons.contacts,
          color: Colors.white,
          size: isMobile ? 20 : 24,
        ),
      ),
    ];
  }

  Widget _buildExpandedInterface(
    VoipState voipState,
    VoipNotifier voipNotifier,
    bool isMobile,
  ) {
    return GlassContainer(
      borderRadius: 16,
      child: Column(
        children: [
          // Header
          _buildHeader(voipState, isMobile),

          // Botão de conexão se necessário
          if (!voipState.isConnected)
            _buildConnectionSection(voipNotifier, isMobile),

          // Lista de chamadas
          Expanded(
            child: _buildCallsList(voipState, voipNotifier, isMobile),
          ),

          // Dialpad
          _buildDialPad(voipState, voipNotifier, isMobile),

          // Botões de ação
          _buildActionButtons(isMobile),
        ],
      ),
    );
  }

  Widget _buildCollapsedFAB(VoipState voipState, bool isMobile) {
    return GestureDetector(
      onTap: () {
        setState(() => _isExpanded = true);
        _expandController.forward();
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: voipState.isConnected
                ? [const Color(0xFF22c55e), const Color(0xFF16a34a)]
                : [const Color(0xFF3b82f6), const Color(0xFF1d4ed8)],
          ),
          boxShadow: [
            BoxShadow(
              color: (voipState.isConnected ? Colors.green : Colors.blue)
                  .withOpacity(0.4),
              blurRadius: 15,
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
          _buildConnectionStatus(voipState),
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
      statusText = 'Conectado';
    } else if (voipState.isConnecting) {
      statusColor = Colors.orange;
      statusText = 'Conectando...';
    } else {
      statusColor = Colors.red;
      statusText = 'Desconectado';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.2),
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
  }

  Widget _buildConnectionSection(VoipNotifier voipNotifier, bool isMobile) {
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'VoIP Desconectado',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e3a8a),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure as credenciais para conectar',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => voipNotifier.initialize(),
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
  }

  Widget _buildCallsList(
    VoipState voipState,
    VoipNotifier voipNotifier,
    bool isMobile,
  ) {
    if (voipState.activeCalls.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_disabled, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhuma chamada ativa',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      itemCount: voipState.activeCalls.length,
      itemBuilder: (context, index) {
        final call = voipState.activeCalls[index];
        return CallCard(
          call: call,
          onAnswer: () => voipNotifier.answerCall(call.id),
          onHangup: () => voipNotifier.hangupCall(call.id),
          onHold: () => voipNotifier.holdCall(call.id, !call.isHeld),
          onTransfer: () => _openTransferOverlay(call.id),
          onDTMF: () => _openDTMFDialog(call.id),
          onSetActive: () => voipNotifier.setActiveCall(call.id),
          onStartConference: () => _startConference(call.id),
          isActive: call.id == voipState.activeCallId,
        );
      },
    );
  }

  Widget _buildDialPad(
    VoipState voipState,
    VoipNotifier voipNotifier,
    bool isMobile,
  ) {
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
              hintText: 'Número para ligar',
              prefixIcon: const Icon(Icons.dialpad),
              suffixIcon: IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: _dialNumber.isNotEmpty && voipState.isConnected
                    ? () => _makeCall(voipNotifier)
                    : null,
              ),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) => setState(() => _dialNumber = value),
            onSubmitted: (_) => _makeCall(voipNotifier),
          ),
          if (voipState.activeCalls.length >= 10) ...[
            const SizedBox(height: 8),
            const Text(
              'Limite máximo de 10 chamadas atingido',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionFAB(
            icon: Icons.volume_up,
            label: 'Áudio',
            color: Colors.green,
            onPressed: () => setState(() => _audioDevicesOverlayOpen = true),
          ),
        ],
      ),
    );
  }

  Widget _buildActionFAB({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          mini: true,
          backgroundColor: color,
          onPressed: onPressed,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  // Overlay Builders
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
    return NotesOverlay(
      isOpen: _notesOverlayOpen,
      onClose: () => setState(() => _notesOverlayOpen = false),
      isMobile: isMobile,
    );
  }

  Widget _buildHistoryOverlay(bool isMobile) {
    return HistoryOverlay(
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
    return AudioControlsOverlay(
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

  Widget _buildDTMFDialog(
    VoipState voipState,
    VoipNotifier voipNotifier,
    bool isMobile,
  ) {
    return DTMFDialog(
      isOpen: _dtmfDialogOpen,
      callId: _dtmfCallId!,
      onClose: () => setState(() => _dtmfDialogOpen = false),
      onSendDTMF: (callId, digits) {
        voipNotifier.sendDTMF(callId, digits);
      },
      isMobile: isMobile,
    );
  }

  // Helper Methods
  void _makeCall(VoipNotifier voipNotifier) {
    if (_dialNumber.isNotEmpty) {
      voipNotifier.makeCall(_dialNumber);
      setState(() => _dialNumber = '');
    }
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

  void _startConference(String callId) {
    setState(() {
      _conferenceMode = true;
      _conferenceInitiatorId = callId;
    });
  }
}
