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
    required this.onSendDTMF,
    this.isActive = false,
    this.onSetActive,
    this.onStartConference,
  });

  final CallModel call;
  final VoidCallback onAnswer;
  final VoidCallback onHangup;
  final VoidCallback onHold;
  final VoidCallback onTransfer;
  final VoidCallback onSendDTMF;
  final bool isActive;
  final VoidCallback? onSetActive;
  final VoidCallback? onStartConference;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header da chamada
          Row(
            children: [
              _buildCallIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      call.displayName ?? call.destination,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${call.direction == CallDirection.incoming ? 'Recebida' : 'Feita'} • ',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF64748B)),
                        ),
                        Text(
                          call.formattedDuration,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: const Color(0xFF64748B)),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusChip(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Botões de controle
          _buildControlButtons(context),
        ],
      ),
    );
  }

  Widget _buildCallIcon() {
    IconData iconData;
    Color iconColor;

    switch (call.state) {
      case CallState.ringing:
        iconData = call.direction == CallDirection.incoming
            ? Icons.call_received
            : Icons.call_made;
        iconColor = call.direction == CallDirection.incoming
            ? Colors.green
            : Colors.blue;
        break;
      case CallState.established:
        iconData = call.isHeld ? Icons.pause : Icons.phone_in_talk;
        iconColor = call.isHeld ? Colors.orange : Colors.blue;
        break;
      default:
        iconData = Icons.phone;
        iconColor = Colors.grey;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: iconColor.withOpacity(0.1),
        border: Border.all(color: iconColor, width: 2),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor()),
      ),
      child: Text(
        call.statusText,
        style: TextStyle(
          color: _getStatusColor(),
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getStatusColor() {
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

  Widget _buildControlButtons(BuildContext context) {
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
          ),
          _buildActionButton(
            icon: Icons.call_end,
            color: Colors.red,
            onPressed: onHangup,
            tooltip: 'Recusar',
          ),
        ]);
      } else {
        buttons.add(
          _buildActionButton(
            icon: Icons.call_end,
            color: Colors.red,
            onPressed: onHangup,
            tooltip: 'Cancelar',
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
        ),
        _buildActionButton(
          icon: Icons.dialpad,
          color: Colors.purple,
          onPressed: onSendDTMF,
          tooltip: 'DTMF',
        ),
        _buildActionButton(
          icon: Icons.swap_calls,
          color: Colors.green,
          onPressed: onTransfer,
          tooltip: 'Transferir',
        ),
        _buildActionButton(
          icon: Icons.call_end,
          color: Colors.red,
          onPressed: onHangup,
          tooltip: 'Desligar',
        ),
      ]);

      // Botão para ativar chamada (se não estiver ativa)
      if (!isActive && onSetActive != null) {
        buttons.insert(
          0,
          _buildActionButton(
            icon: Icons.volume_up,
            color: Colors.blue,
            onPressed: onSetActive!,
            tooltip: 'Ativar',
          ),
        );
      }

      // Botão de conferência
      if (onStartConference != null) {
        buttons.insert(
          buttons.length - 1,
          _buildActionButton(
            icon: Icons.group_add,
            color: Colors.indigo,
            onPressed: onStartConference!,
            tooltip: 'Conferência',
          ),
        );
      }
    }

    return Wrap(spacing: 8, children: buttons);
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.1),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: IconButton(
          icon: Icon(icon, size: 18),
          color: color,
          padding: EdgeInsets.zero,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
