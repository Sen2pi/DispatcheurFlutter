import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_provider.dart';
import '../../providers/voip_provider.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final voipState = ref.watch(voipProvider);
    final user = authState.user;

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3B82F6),
              Color(0xFF1D4ED8),
            ],
          ),
        ),
        child: Column(
          children: [
            // Header do drawer
            _buildDrawerHeader(user),

            // Menu items
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    // Dashboard
                    _buildMenuItem(
                      icon: Icons.dashboard,
                      title: 'Dashboard',
                      subtitle: 'Visão geral do sistema',
                      onTap: () {
                        Navigator.of(context).pop();
                        // Já estamos no dashboard
                      },
                      isActive: true,
                    ),

                    // VoIP
                    _buildMenuItem(
                      icon: Icons.phone,
                      title: 'VoIP',
                      subtitle: voipState.isConnected
                          ? '${voipState.activeCalls.length} chamadas ativas'
                          : 'Desconectado',
                      trailing: voipState.isConnected
                          ? const Icon(Icons.circle,
                              color: Color(0xFF22c55e), size: 12)
                          : const Icon(Icons.circle,
                              color: Color(0xFFef4444), size: 12),
                      onTap: () {
                        Navigator.of(context).pop();
                        // TODO: Abrir interface VoIP
                      },
                    ),

                    // Contactos
                    _buildMenuItem(
                      icon: Icons.contacts,
                      title: 'Contactos',
                      subtitle: 'Gerir contactos',
                      onTap: () {
                        Navigator.of(context).pop();
                        // TODO: Navegar para contactos
                      },
                    ),

                    // Histórico
                    _buildMenuItem(
                      icon: Icons.history,
                      title: 'Histórico',
                      subtitle: 'Histórico de chamadas',
                      onTap: () {
                        Navigator.of(context).pop();
                        // TODO: Navegar para histórico
                      },
                    ),

                    // Relatórios
                    _buildMenuItem(
                      icon: Icons.analytics,
                      title: 'Relatórios',
                      subtitle: 'Estatísticas e análises',
                      onTap: () {
                        Navigator.of(context).pop();
                        // TODO: Navegar para relatórios
                      },
                    ),

                    const Divider(height: 32),

                    // Configurações
                    _buildMenuItem(
                      icon: Icons.settings,
                      title: 'Configurações',
                      subtitle: 'Configurações do sistema',
                      onTap: () {
                        Navigator.of(context).pop();
                        // TODO: Navegar para configurações
                      },
                    ),

                    // Ajuda
                    _buildMenuItem(
                      icon: Icons.help,
                      title: 'Ajuda',
                      subtitle: 'Suporte e documentação',
                      onTap: () {
                        Navigator.of(context).pop();
                        // TODO: Navegar para ajuda
                      },
                    ),

                    const Spacer(),

                    // Versão
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'DispatcheurCC v1.0.0',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(UserModel? user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 20),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: user?.avatar != null
                    ? ClipOval(
                        child: Image.network(
                          user!.avatar!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Text(
                            user.initials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 28,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        user?.initials ?? 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
              ),
              if (user != null)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: user.statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Nome
          Text(
            user?.name ?? 'Utilizador',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            user?.email ?? '',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Status
          if (user != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: user.statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    user.statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    bool isActive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF3B82F6).withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF3B82F6)
                : const Color(0xFF3B82F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.white : const Color(0xFF3B82F6),
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive ? const Color(0xFF3B82F6) : const Color(0xFF1E293B),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
        trailing: trailing,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
