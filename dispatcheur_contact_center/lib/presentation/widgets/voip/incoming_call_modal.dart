import 'package:flutter/material.dart';
import 'dart:ui';

class IncomingCallModal extends StatefulWidget {
  const IncomingCallModal({
    super.key,
    required this.isOpen,
    this.callerInfo,
    required this.onAnswer,
    required this.onReject,
  });

  final bool isOpen;
  final dynamic callerInfo;
  final VoidCallback onAnswer;
  final VoidCallback onReject;

  @override
  State<IncomingCallModal> createState() => _IncomingCallModalState();
}

class _IncomingCallModalState extends State<IncomingCallModal>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotateAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.linear,
    ));

    if (widget.isOpen) {
      _pulseController.repeat(reverse: true);
      _scaleController.forward();
      _rotateController.repeat();
    }
  }

  @override
  void didUpdateWidget(IncomingCallModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _pulseController.repeat(reverse: true);
      _scaleController.forward();
      _rotateController.repeat();
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _pulseController.stop();
      _scaleController.reverse();
      _rotateController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox();

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Center(
              child: Container(
                width: 320,
                height: 420,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1e3a8a),
                      Color(0xFF3b82f6),
                      Color(0xFF60a5fa),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3b82f6).withOpacity(0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar animado do caller
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.2),
                                  Colors.white.withOpacity(0.1),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: RotationTransition(
                              turns: _rotateAnimation,
                              child: const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Texto de chamada recebida
                    const Text(
                      'Appel entrant',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Informações do caller
                    Text(
                      widget.callerInfo?.toString() ?? 'Numéro inconnu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Botões de ação animados
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Botão rejeitar
                        _buildActionButton(
                          icon: Icons.call_end,
                          color: Colors.red,
                          onPressed: widget.onReject,
                          tooltip: 'Refuser',
                        ),

                        // Botão atender
                        _buildActionButton(
                          icon: Icons.call,
                          color: Colors.green,
                          onPressed: widget.onAnswer,
                          tooltip: 'Répondre',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_pulseAnimation.value - 1.0) * 0.1,
          child: Tooltip(
            message: tooltip,
            child: GestureDetector(
              onTap: onPressed,
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
