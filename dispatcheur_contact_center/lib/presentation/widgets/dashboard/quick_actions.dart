import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../common/glass_container.dart';

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ações Rápidas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1,
            children: [
              _buildActionButton(
                icon: Icons.phone,
                label: 'Nova Chamada',
                color: const Color(0xFF22c55e),
                onTap: () {
                  // TODO: Abrir discador
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abrir discador')),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.contacts,
                label: 'Contactos',
                color: const Color(0xFF3B82F6),
                onTap: () {
                  // TODO: Abrir contactos
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abrir contactos')),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.history,
                label: 'Histórico',
                color: const Color(0xFF8b5cf6),
                onTap: () {
                  // TODO: Abrir histórico
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abrir histórico')),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.note_add,
                label: 'Nova Nota',
                color: const Color(0xFFf59e0b),
                onTap: () {
                  // TODO: Nova nota
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nova nota')),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.analytics,
                label: 'Relatórios',
                color: const Color(0xFFef4444),
                onTap: () {
                  // TODO: Abrir relatórios
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abrir relatórios')),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.settings,
                label: 'Configurações',
                color: const Color(0xFF64748b),
                onTap: () {
                  // TODO: Abrir configurações
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abrir configurações')),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.group_add,
                label: 'Conferência',
                color: const Color(0xFF06b6d4),
                onTap: () {
                  // TODO: Nova conferência
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Nova conferência')),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.help,
                label: 'Ajuda',
                color: const Color(0xFF84cc16),
                onTap: () {
                  // TODO: Abrir ajuda
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abrir ajuda')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
