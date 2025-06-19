import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/call_model.dart';
import '../../providers/call_history_provider.dart';
import '../common/glass_container.dart';

class HistoryOverlay extends ConsumerStatefulWidget {
  const HistoryOverlay({
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
  ConsumerState<HistoryOverlay> createState() => _HistoryOverlayState();
}

class _HistoryOverlayState extends ConsumerState<HistoryOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
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

  @override
  void didUpdateWidget(HistoryOverlay oldWidget) {
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

    final historyState = ref.watch(callHistoryProvider);
    final historyNotifier = ref.read(callHistoryProvider.notifier);

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
                        _buildHeader(historyState, historyNotifier),
                        Expanded(child: _buildHistoryList(historyState)),
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

  Widget _buildHeader(CallHistoryState state, CallHistoryNotifier notifier) {
    return Container(
      padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
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
            'Histórico de Chamadas',
            style: TextStyle(
              color: Colors.white,
              fontSize: widget.isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (state.calls.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.white),
              onPressed: () => _showClearDialog(notifier),
            ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(CallHistoryState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.calls.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_disabled, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhuma chamada no histórico',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            Text(
              'O histórico de chamadas aparecerá aqui',
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
      itemCount: state.calls.length,
      itemBuilder: (context, index) {
        final call = state.calls[index];
        return _buildHistoryItem(call);
      },
    );
  }

  Widget _buildHistoryItem(CallModel call) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCallStatusColor(call),
          child: Icon(
            _getCallIcon(call),
            color: Colors.white,
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
              call.direction == CallDirection.incoming
                  ? 'Chamada recebida'
                  : 'Chamada efetuada',
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              _formatCallTime(call.startTime),
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
                color: _getCallStatusColor(call).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                call.statusText,
                style: TextStyle(
                  color: _getCallStatusColor(call),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (call.answeredTime != null)
              Text(
                call.formattedDuration,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        onTap: () => widget.onCallNumber(call.destination),
      ),
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

  IconData _getCallIcon(CallModel call) {
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

  void _showClearDialog(CallHistoryNotifier notifier) {
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
              notifier.clearHistory();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Limpar'),
          ),
        ],
      ),
    );
  }
}
