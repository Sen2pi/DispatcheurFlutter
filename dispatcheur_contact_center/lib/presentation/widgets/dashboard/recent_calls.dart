import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/call_model.dart';
import '../common/glass_container.dart';

class RecentCalls extends ConsumerWidget {
  const RecentCalls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Implementar provider para histórico de chamadas
    final recentCalls = _getMockCalls();

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Chamadas Recentes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // TODO: Ver todas as chamadas
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ver todas as chamadas')),
                  );
                },
                child: const Text('Ver todas'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: recentCalls.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.phone_disabled,
                          size: 64,
                          color: Color(0xFF64748B),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma chamada recente',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: recentCalls.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final call = recentCalls[index];
                      return _buildCallItem(call);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallItem(CallModel call) {
    final isIncoming = call.direction == CallDirection.incoming;
    final statusColor = _getCallStatusColor(call);
    final statusIcon = _getCallStatusIcon(call);

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          statusIcon,
          color: statusColor,
          size: 20,
        ),
      ),
      title: Text(
        call.displayName ?? call.destination,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E3A8A),
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isIncoming ? 'Chamada recebida' : 'Chamada efetuada',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _formatCallTime(call.startTime),
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              call.statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          if (call.answeredTime != null)
            Text(
              call.formattedDuration,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      onTap: () {
        // TODO: Mostrar detalhes da chamada ou ligar novamente
      },
    );
  }

  Color _getCallStatusColor(CallModel call) {
    switch (call.state) {
      case CallState.established:
        return const Color(0xFF22c55e);
      case CallState.ended:
        return const Color(0xFF64748B);
      case CallState.failed:
        return const Color(0xFFef4444);
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getCallStatusIcon(CallModel call) {
    if (call.direction == CallDirection.incoming) {
      return Icons.call_received;
    } else {
      return Icons.call_made;
    }
  }

  String _formatCallTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} dia${difference.inDays > 1 ? 's' : ''} atrás';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''} atrás';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''} atrás';
    } else {
      return 'Agora mesmo';
    }
  }

  List<CallModel> _getMockCalls() {
    // Mock data - em produção, isto viria de um provider
    final now = DateTime.now();
    return [
      CallModel(
        id: '1',
        destination: '+351912345678',
        direction: CallDirection.incoming,
        state: CallState.ended,
        startTime: now.subtract(const Duration(minutes: 15)),
        answeredTime: now.subtract(const Duration(minutes: 14)),
        endTime: now.subtract(const Duration(minutes: 12)),
        displayName: 'João Silva',
      ),
      CallModel(
        id: '2',
        destination: '+351987654321',
        direction: CallDirection.outgoing,
        state: CallState.ended,
        startTime: now.subtract(const Duration(hours: 2)),
        answeredTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1, minutes: 55)),
        displayName: 'Maria Santos',
      ),
      CallModel(
        id: '3',
        destination: '+351555123456',
        direction: CallDirection.incoming,
        state: CallState.failed,
        startTime: now.subtract(const Duration(hours: 4)),
        displayName: 'Pedro Costa',
      ),
    ];
  }
}
