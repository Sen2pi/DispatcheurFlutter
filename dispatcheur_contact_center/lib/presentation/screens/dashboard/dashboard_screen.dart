import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../voip/voip_screen.dart';
import '../../widgets/common/glass_container.dart';
import '../../providers/voip_provider.dart';
import '../../providers/auth_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializar VoIP Engine
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voipProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final voipState = ref.watch(voipProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF0F9FF), Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(context, authState),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Status do VoIP
                      _buildVoipStatus(context, voipState),

                      const SizedBox(height: 24),

                      // Estatísticas rápidas
                      _buildQuickStats(context, voipState),

                      const Spacer(),

                      // Botões de ação rápida
                      _buildQuickActions(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // VoIP Interface sobreposta
      floatingActionButton: const VoipScreen(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader(BuildContext context, AuthState authState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF3B82F6),
            child: Text(
              authState.user?.name?.substring(0, 1).toUpperCase() ?? 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bem-vindo',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  authState.user?.name ?? 'Utilizador',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => ref.read(authProvider.notifier).logout(),
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
          ),
        ],
      ),
    );
  }

  Widget _buildVoipStatus(BuildContext context, VoipState voipState) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                voipState.isConnected ? Icons.phone : Icons.phone_disabled,
                color: voipState.isConnected ? Colors.green : Colors.red,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Estado VoIP',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: voipState.isConnected
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: voipState.isConnected ? Colors.green : Colors.red,
                  ),
                ),
                child: Text(
                  voipState.isConnected ? 'Conectado' : 'Desconectado',
                  style: TextStyle(
                    color: voipState.isConnected ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (voipState.currentUser != null) ...[
            Text(
              'Utilizador: ${voipState.currentUser}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'Chamadas ativas: ${voipState.activeCalls.length}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, VoipState voipState) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Chamadas Ativas',
            voipState.activeCalls.length.toString(),
            Icons.phone_in_talk,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Em Espera',
            voipState.activeCalls
                .where((call) => call.isHeld)
                .length
                .toString(),
            Icons.pause,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Conferências',
            voipState.activeCalls
                .where((call) => call.isConference)
                .length
                .toString(),
            Icons.group,
            Colors.purple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Ações Rápidas',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GlassButton(
                onPressed: () {
                  // Implementar acesso a contactos
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.contacts, size: 24),
                    SizedBox(height: 4),
                    Text('Contactos'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassButton(
                onPressed: () {
                  // Implementar histórico
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 24),
                    SizedBox(height: 4),
                    Text('Histórico'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GlassButton(
                onPressed: () {
                  // Implementar configurações
                },
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.settings, size: 24),
                    SizedBox(height: 4),
                    Text('Configurações'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
