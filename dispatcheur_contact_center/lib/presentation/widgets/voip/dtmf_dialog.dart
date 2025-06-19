import 'package:flutter/material.dart';

import '../common/glass_container.dart';

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

class _DTMFDialogState extends State<DTMFDialog> {
  String _dtmfBuffer = '';

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
  Widget build(BuildContext context) {
    if (!widget.isOpen) return const SizedBox();

    return Positioned.fill(
      child: GestureDetector(
        onTap: widget.onClose,
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                width: widget.isMobile ? 280 : 320,
                padding: const EdgeInsets.all(20),
                child: GlassContainer(
                  borderRadius: 20,
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
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.dialpad, color: Color(0xFF1E3A8A)),
        const SizedBox(width: 8),
        const Text(
          'Teclado DTMF',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A8A),
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.close, color: Color(0xFF64748B)),
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
        color: const Color(0xFF3B82F6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
      ),
      child: Text(
        _dtmfBuffer.isEmpty ? 'Sequência DTMF' : _dtmfBuffer,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _dtmfBuffer.isEmpty ? Colors.grey : const Color(0xFF1E3A8A),
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

    return GestureDetector(
      onTap: () => _handleDigitPress(digit),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF3B82F6).withOpacity(0.2),
              const Color(0xFF93C5FD).withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF3B82F6).withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3B82F6).withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              digit,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
              ),
            ),
            if (letters.isNotEmpty)
              Text(
                letters,
                style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFF3B82F6),
                ),
              ),
          ],
        ),
      ),
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
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _dtmfBuffer.isNotEmpty ? _sendDTMF : null,
            icon: const Icon(Icons.send),
            label: const Text('Enviar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _handleDigitPress(String digit) {
    setState(() {
      _dtmfBuffer += digit;
    });

    // Enviar imediatamente cada dígito
    widget.onSendDTMF(widget.callId, digit);
  }

  void _clearBuffer() {
    setState(() {
      _dtmfBuffer = '';
    });
  }

  void _sendDTMF() {
    if (_dtmfBuffer.isNotEmpty) {
      widget.onSendDTMF(widget.callId, _dtmfBuffer);
      _clearBuffer();
    }
  }
}
