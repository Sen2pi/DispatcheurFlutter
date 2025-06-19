import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';

import '../common/glass_container.dart';

class CallHistoryOverlay extends ConsumerStatefulWidget {
  const CallHistoryOverlay({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.isMobile,
    required this.onCallNumber,
  });

  final bool isOpen;
  final VoidCallback onClose;
  final bool isMobile;
  final Function(String) onCallNumber;

  @override
  ConsumerState<CallHistoryOverlay> createState() => _CallHistoryOverlayState();
}

class _CallHistoryOverlayState extends ConsumerState<CallHistoryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _loadHistory();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    if (widget.isOpen) {
      _animationController.forward();
    }
  }

  void _loadHistory() {
    try {
      // TODO: Implementar com SharedPreferences
      const savedHistory = '[]'; // Mock
      final List<dynamic> historyList = json.decode(savedHistory);
      setState(() {
        _history = historyList.cast<Map<String, dynamic>>();
      });
    } catch (e) {
      setState(() {
        _history = [];
      });
    }
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Limpar Histórico'),
        content: const Text('Deseja apagar todo o histórico de chamadas?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _history.clear();
              });
              // TODO: Implementar limpeza no SharedPreferences
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(CallHistoryOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _animationController.forward();
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _animationController.reverse();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox();

    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: SlideTransition(
            position: _slideAnimation,
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: widget.isMobile
                      ? MediaQuery.of(context).size.width * 0.9
                      : 400,
                  height: double.infinity,
                  margin: EdgeInsets.only(
                    top: widget.isMobile ? 50 : 80,
                    bottom: widget.isMobile ? 50 : 80,
                    right: widget.isMobile ? 20 : 80,
                  ),
                  child: GlassContainer(
                    borderRadius: 16,
                    child: Column(
                      children: [
                        _buildHeader(),
                        Expanded(child: _buildHistoryList()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
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
          const Icon(Icons.history, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            'Historique des Appels',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: _clearHistory,
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    if (_history.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_disabled, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Aucun historique',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              'L\'historique des appels apparaîtra ici',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final call = _history[index];
        return _buildHistoryItem(call);
      },
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> call) {
    final status = _getCallStatus(call);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCallIcon(call)['color'],
          child: Icon(
            _getCallIcon(call)['icon'],
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          call['number'] ?? 'Numéro inconnu',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1e3a8a),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              call['direction'] == 'incoming'
                  ? 'Appel entrant'
                  : 'Appel sortant',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              _formatCallTime(call['timestamp']),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
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
                color: status['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status['label'],
                style: TextStyle(
                  color: status['color'],
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (call['duration'] != null)
              Text(
                call['duration'],
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        onTap: () => widget.onCallNumber(call['number'] ?? ''),
      ),
    );
  }

  Map<String, dynamic> _getCallIcon(Map<String, dynamic> call) {
    if (call['direction'] == 'incoming') {
      return {'icon': Icons.call_received, 'color': const Color(0xFFf59e0b)};
    }
    return {'icon': Icons.call_made, 'color': const Color(0xFF3b82f6)};
  }

  Map<String, dynamic> _getCallStatus(Map<String, dynamic> call) {
    switch (call['status']) {
      case 'answered':
        return {'label': 'Répondu', 'color': const Color(0xFF10b981)};
      case 'missed':
        return {'label': 'Manqué', 'color': const Color(0xFFef4444)};
      case 'rejected':
        return {'label': 'Rejeté', 'color': const Color(0xFFef4444)};
      default:
        return {'label': 'Terminé', 'color': const Color(0xFF64748b)};
    }
  }

  String _formatCallTime(String? timestamp) {
    if (timestamp == null) return 'Maintenant';

    try {
      final callTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(callTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} jour${difference.inDays > 1 ? 's' : ''} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} heure${difference.inHours > 1 ? 's' : ''} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'À l\'instant';
      }
    } catch (e) {
      return 'Maintenant';
    }
  }
}
