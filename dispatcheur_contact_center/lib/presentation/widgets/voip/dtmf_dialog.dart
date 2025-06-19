import 'package:flutter/material.dart';
import 'dart:ui';

class DTMFDialog extends StatefulWidget {
  const DTMFDialog({
    super.key,
    required this.isOpen,
    required this.callId,
    required this.onClose,
    required this.onSendDTMF,
    required this.isMobile,
  });

  final bool isOpen;
  final String callId;
  final VoidCallback onClose;
  final Function(String, String) onSendDTMF;
  final bool isMobile;

  @override
  State<DTMFDialog> createState() => _DTMFDialogState();
}

class _DTMFDialogState extends State<DTMFDialog> with TickerProviderStateMixin {
  String _dtmfBuffer = '';
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  final List<List<Map<String, String>>> _keypadLayout = [
    [
      {'digit': '1', 'letters': ''},
      {'digit': '2', 'letters': 'ABC'},
      {'digit': '3', 'letters': 'DEF'},
    ],
    [
      {'digit': '4', 'letters': 'GHI'},
      {'digit': '5', 'letters': 'JKL'},
      {'digit': '6', 'letters': 'MNO'},
    ],
    [
      {'digit': '7', 'letters': 'PQRS'},
      {'digit': '8', 'letters': 'TUV'},
      {'digit': '9', 'letters': 'WXYZ'},
    ],
    [
      {'digit': '*', 'letters': ''},
      {'digit': '0', 'letters': '+'},
      {'digit': '#', 'letters': ''},
    ],
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    if (widget.isOpen) {
      _scaleController.forward();
    }
  }

  @override
  void didUpdateWidget(DTMFDialog oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOpen && !oldWidget.isOpen) {
      _scaleController.forward();
    } else if (!widget.isOpen && oldWidget.isOpen) {
      _scaleController.reverse();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _handleDigitPress(String digit) async {
    // Feedback tátil
    if (widget.isMobile) {
      // Simular vibração no web
    }

    // Animação de botão
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });

    setState(() {
      _dtmfBuffer += digit;
    });

    // Enviar DTMF imediatamente
    widget.onSendDTMF(widget.callId, digit);
  }

  void _clearBuffer() {
    setState(() {
      _dtmfBuffer = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox();

    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Center(
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    width: widget.isMobile ? 280 : 320,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0x4D3B82F6), // rgba(59, 130, 246, 0.3)
                          Color(0x3393C5FD), // rgba(147, 197, 253, 0.2)
                          Color(0x26DBEAFE), // rgba(219, 234, 254, 0.15)
                          Color(0x1AEFF6FF), // rgba(239, 246, 255, 0.1)
                        ],
                      ),
                      border: Border.all(
                        color:
                            const Color(0x663B82F6), // rgba(59, 130, 246, 0.4)
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x4D3B82F6), // rgba(59, 130, 246, 0.3)
                          blurRadius: 40,
                          offset: Offset(0, 20),
                        ),
                      ],
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 16),
                          _buildBuffer(),
                          const SizedBox(height: 16),
                          _buildKeypad(),
                          const SizedBox(height: 16),
                          _buildControls(),
                        ],
                      ),
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
    return Row(
      children: [
        const Icon(Icons.dialpad, color: Color(0xFF1e3a8a)),
        const SizedBox(width: 8),
        const Text(
          'Clavier Numérique',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e3a8a),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF64748b)),
          onPressed: widget.onClose,
        ),
      ],
    );
  }

  Widget _buildBuffer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0x333B82F6), // rgba(59, 130, 246, 0.2)
            Color(0x2693C5FD), // rgba(147, 197, 253, 0.15)
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x4D3B82F6)),
      ),
      child: Text(
        _dtmfBuffer.isEmpty ? 'Séquence DTMF' : _dtmfBuffer,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _dtmfBuffer.isEmpty ? Colors.grey : const Color(0xFF1e3a8a),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildKeypad() {
    return Column(
      children: _keypadLayout.map((row) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((keyData) {
              return _buildKeypadButton(keyData);
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildKeypadButton(Map<String, String> keyData) {
    final digit = keyData['digit']!;
    final letters = keyData['letters']!;

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: () => _handleDigitPress(digit),
            child: Container(
              width: widget.isMobile ? 50 : 60,
              height: widget.isMobile ? 50 : 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0x403B82F6), // rgba(59, 130, 246, 0.25)
                    Color(0x2693C5FD), // rgba(147, 197, 253, 0.15)
                    Color(0x1ADBEAFE), // rgba(219, 234, 254, 0.1)
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0x4D3B82F6), // rgba(59, 130, 246, 0.3)
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x333B82F6), // rgba(59, 130, 246, 0.2)
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    digit,
                    style: TextStyle(
                      fontSize: widget.isMobile ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1e3a8a),
                    ),
                  ),
                  if (letters.isNotEmpty)
                    Text(
                      letters,
                      style: TextStyle(
                        fontSize: widget.isMobile ? 8 : 9,
                        color: const Color(0xFF3b82f6),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _dtmfBuffer.isNotEmpty ? _clearBuffer : null,
            icon: const Icon(Icons.backspace),
            label: const Text('Limpar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFf59e0b),
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onClose,
            icon: const Icon(Icons.close),
            label: const Text('Fermer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3b82f6),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
