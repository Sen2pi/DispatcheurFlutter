import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/online_users_provider.dart';
import '../../providers/voip_provider.dart';
import '../../widgets/dashboard/dashboard_stats.dart';
import '../../widgets/layout/app_drawer.dart';
import '../../widgets/layout/top_bar.dart';
import '../../../data/models/user_model.dart'; // ✅ ADICIONAR ESTA LINHA

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final voipState = ref.watch(voipProvider);
    final onlineUsersState = ref.watch(onlineUsersProvider);
    final user = authState.user;

    return Scaffold(
      appBar: const TopBar(),
      drawer: const AppDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFE2E8F0),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com boas-vindas
              if (user != null) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF3B82F6),
                      child: user.avatar != null
                          ? ClipOval(
                              child: Image.network(
                                user.avatar!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Text(
                                  user.initials, // ✅ AGORA FUNCIONA
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            )
                          : Text(
                              user.initials, // ✅ AGORA FUNCIONA
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bem-vindo, ${user.name}!',
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: user.statusColor, // ✅ AGORA FUNCIONA
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                user.statusText, // ✅ AGORA FUNCIONA
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // ✅ CORRIGIDO: PopupMenuButton com tipo correto
                    PopupMenuButton<UserStatus>(
                      onSelected: (UserStatus status) {
                        // ✅ TIPO CORRETO
                        ref
                            .read(authProvider.notifier)
                            .updateUserStatus(status);
                      },
                      itemBuilder: (context) => UserStatus.values.map((status) {
                        return PopupMenuItem<UserStatus>(
                          // ✅ TIPO CORRETO
                          value: status,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  // ✅ CORRIGIDO: Criar um user temporário para ter acesso ao statusColor
                                  color: _getStatusColor(status),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(_getStatusText(status)), // ✅ FUNÇÃO HELPER
                            ],
                          ),
                        );
                      }).toList(),
                      child: const Icon(Icons.arrow_drop_down),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],

              // Stats cards
              DashboardStats(
                voipState: voipState,
                onlineUsersState: onlineUsersState,
              ),

              const SizedBox(height: 32),

              // Conteúdo principal
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Coluna esquerda
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildOnlineUsersCard(onlineUsersState),
                        const SizedBox(height: 24),
                        _buildRecentActivityCard(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Coluna direita
                  Expanded(
                    child: Column(
                      children: [
                        _buildQuickActionsCard(),
                        const SizedBox(height: 24),
                        _buildSystemStatusCard(),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ FUNÇÕES HELPER PARA STATUS
  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.online:
        return const Color(0xFF22c55e);
      case UserStatus.away:
        return const Color(0xFFf59e0b);
      case UserStatus.busy:
        return const Color(0xFFef4444);
      case UserStatus.offline:
        return const Color(0xFF64748b);
    }
  }

  String _getStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.online:
        return 'Online';
      case UserStatus.away:
        return 'Ausente';
      case UserStatus.busy:
        return 'Ocupado';
      case UserStatus.offline:
        return 'Offline';
    }
  }

  Widget _buildOnlineUsersCard(OnlineUsersState onlineUsersState) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Utilizadores Online',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (onlineUsersState.users.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Nenhum utilizador online'),
                ),
              )
            else
              ...onlineUsersState.users.take(5).map((user) {
                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF3B82F6),
                        child: Text(
                          user.initials, // ✅ AGORA FUNCIONA
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: user.statusColor, // ✅ AGORA FUNCIONA
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(user.name),
                  subtitle: Text(
                    user.statusText, // ✅ AGORA FUNCIONA
                    style: TextStyle(
                      color: user.statusColor, // ✅ AGORA FUNCIONA
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atividade Recente',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.phone_in_talk, color: Color(0xFF22c55e)),
              title: Text('Chamada atendida'),
              subtitle: Text('João Silva - há 5 minutos'),
            ),
            const ListTile(
              leading: Icon(Icons.phone_missed, color: Color(0xFFef4444)),
              title: Text('Chamada perdida'),
              subtitle: Text('Maria Santos - há 12 minutos'),
            ),
            const ListTile(
              leading: Icon(Icons.note, color: Color(0xFFf59e0b)),
              title: Text('Nova nota adicionada'),
              subtitle: Text('Pedro Costa - há 1 hora'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ações Rápidas',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Função em desenvolvimento')),
                  );
                },
                icon: const Icon(Icons.phone),
                label: const Text('Nova Chamada'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Função em desenvolvimento')),
                  );
                },
                icon: const Icon(Icons.note_add),
                label: const Text('Nova Nota'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Função em desenvolvimento')),
                  );
                },
                icon: const Icon(Icons.settings),
                label: const Text('Configurações'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estado do Sistema',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Color(0xFF22c55e)),
              title: Text('Servidor VoIP'),
              subtitle: Text('Online'),
            ),
            const ListTile(
              leading: Icon(Icons.check_circle, color: Color(0xFF22c55e)),
              title: Text('Base de Dados'),
              subtitle: Text('Conectada'),
            ),
            const ListTile(
              leading: Icon(Icons.warning, color: Color(0xFFf59e0b)),
              title: Text('Backup'),
              subtitle: Text('Último backup há 2 horas'),
            ),
          ],
        ),
      ),
    );
  }
}
