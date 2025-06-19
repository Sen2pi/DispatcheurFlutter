import 'package:flutter/material.dart';

import '../../providers/voip_provider.dart';
import '../../providers/online_users_provider.dart';
import '../common/glass_container.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({
    super.key,
    required this.voipState,
    required this.onlineUsersState,
  });

  final VoipState voipState;
  final OnlineUsersState onlineUsersState;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Utilizadores Online',
            value: '${onlineUsersState.users.length}',
            icon: Icons.people,
            color: const Color(0xFF22c55e),
            subtitle: '${onlineUsersState.totalActive} ativos',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Chamadas Ativas',
            value: '${voipState.activeCalls.length}',
            icon: Icons.phone_in_talk,
            color: const Color(0xFF3B82F6),
            subtitle:
                voipState.isConnected ? 'Sistema online' : 'Sistema offline',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Em Espera',
            value:
                '${voipState.activeCalls.where((call) => call.isHeld).length}',
            icon: Icons.pause,
            color: const Color(0xFFf59e0b),
            subtitle: 'Chamadas pausadas',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            title: 'Conferências',
            value:
                '${voipState.activeCalls.where((call) => call.isConference).length}',
            icon: Icons.group,
            color: const Color(0xFF8b5cf6),
            subtitle: 'Chamadas em grupo',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }
}
