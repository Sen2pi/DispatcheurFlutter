import 'package:flutter/material.dart';

import '../../../data/models/call_model.dart';
import '../common/glass_container.dart';

class CallCard extends StatelessWidget {
  const CallCard({
    super.key,
    required this.call,
    required this.onAnswer,
    required this.onHangup,
    required this.onHold,
    required this.onTransfer,
    required this.onDTMF,
    this.onSetActive,
    this.isActive = false,
  });

  final CallModel call;
  final VoidCallback onAnswer;
  final VoidCallback onHangup;
  final VoidCallback onHold;
  final VoidCallback onTransfer;
  final VoidCallback onDTMF;
  final VoidCallback? onSetActive;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _getCallColor(call).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header da chamada
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
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              '${call.direction == CallDirection.incoming ? 'Recebida' : 'Efetuada'} • ',
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            Text(
                              call.formattedDuration,
                              style: TextStyle(
                                fontSize: isMobile ? 11 : 12,
                                color: const Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(isMobile),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Botões de controle
              _buildControlButtons(context, isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(bool isMobile) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
    );
  }

  Widget _buildControlButtons(BuildContext context, bool isMobile) {
    final buttons = <Widget>[];

    // Botões para chamadas tocando
    if (call.state == CallState.ringing) {
      if (call.direction == CallDirection.incoming) {
        buttons.addAll([
          _buildActionButton(
            icon: Icons.call,
            color: Colors.green,
            onPressed: onAnswer,
            tooltip: 'Atender',
            isMobile: isMobile,
          ),
          _buildActionButton(
            icon: Icons.call_end,
            color: Colors.red,
            onPressed: onHangup,
            tooltip: 'Recusar',
            isMobile: isMobile,
          ),
        ]);
      } else {
        buttons.add(
          _buildActionButton(
            icon: Icons.call_end,
            color: Colors.red,
            onPressed: onHangup,
            tooltip: 'Cancelar',
            isMobile: isMobile,
          ),
        );
      }
    }

    // Botões para chamadas estabelecidas
    if (call.state == CallState.established) {
      buttons.addAll([
        _buildActionButton(
          icon: call.isHeld ? Icons.play_arrow : Icons.pause,
          color: call.isHeld ? Colors.blue : Colors.orange,
          onPressed: onHold,
          tooltip: call.isHeld ? 'Retomar' : 'Pausar',
          isMobile: isMobile,
        ),
        _buildActionButton(
          icon: Icons.dialpad,
          color: Colors.purple,
          onPressed: onDTMF,
          tooltip: 'DTMF',
          isMobile: isMobile,
        ),
        _buildActionButton(
          icon: Icons.swap_calls,
          color: Colors.green,
          onPressed: onTransfer,
          tooltip: 'Transferir',
          isMobile: isMobile,
        ),
        _buildActionButton(
          icon: Icons.call_end,
          color: Colors.red,
          onPressed: onHangup,
          tooltip: 'Desligar',
          isMobile: isMobile,
        ),
      ]);

      // Botão para ativar chamada
      if (!isActive && onSetActive != null) {
        buttons.insert(
          0,
          _buildActionButton(
            icon: Icons.volume_up,
            color: Colors.blue,
            onPressed: onSetActive!,
            tooltip: 'Ativar',
            isMobile: isMobile,
          ),
        );
      }
    }

    return Wrap(
      spacing: isMobile ? 6 : 8,
      children: buttons,
    );
  }

  Widget _buildActionButton({
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
