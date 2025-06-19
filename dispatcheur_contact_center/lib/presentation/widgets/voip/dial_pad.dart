import 'package:flutter/material.dart';

class DialPad extends StatefulWidget {
  const DialPad({
    super.key,
    required this.onNumberPressed,
    required this.onCallPressed,
    this.dialNumber = '',
  });

  final Function(String) onNumberPressed;
  final VoidCallback onCallPressed;
  final String dialNumber;

  @override
  State<DialPad> createState() => _DialPadState();
}

class _DialPadState extends State<DialPad> {
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
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Column(
        children: [
          // Display do número
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF3B82F6).withOpacity(0.1),
                  const Color(0xFF93C5FD).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
              ),
            ),
            child: Text(
              widget.dialNumber.isEmpty
                  ? 'Número para ligar'
                  : widget.dialNumber,
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.w500,
                color: widget.dialNumber.isEmpty
                    ? Colors.grey
                    : const Color(0xFF1E3A8A),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Teclado numérico
          Column(
            children: _keypadLayout.map((row) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: row.map((keyData) {
                    return _buildKeypadButton(keyData, isMobile);
                  }).toList(),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Botões de ação
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Botão backspace
              _buildActionButton(
                icon: Icons.backspace,
                color: Colors.orange,
                onPressed: () => _handleBackspace(),
                tooltip: 'Apagar',
                isMobile: isMobile,
              ),

              // Botão chamar
              _buildActionButton(
                icon: Icons.call,
                color: Colors.green,
                onPressed:
                    widget.dialNumber.isNotEmpty ? widget.onCallPressed : null,
                tooltip: 'Ligar',
                isMobile: isMobile,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(Map<String, String> keyData, bool isMobile) {
    final digit = keyData['digit']!;
    final letters = keyData['letters']!;

    return GestureDetector(
      onTap: () => widget.onNumberPressed(digit),
      child: Container(
        width: isMobile ? 50 : 60,
        height: isMobile ? 50 : 60,
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
              style: TextStyle(
                fontSize: isMobile ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E3A8A),
              ),
            ),
            if (letters.isNotEmpty)
              Text(
                letters,
                style: TextStyle(
                  fontSize: isMobile ? 8 : 9,
                  color: const Color(0xFF3B82F6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    required String tooltip,
    required bool isMobile,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: isMobile ? 50 : 60,
        height: isMobile ? 50 : 60,
        decoration: BoxDecoration(
          color: onPressed != null
              ? color.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: onPressed != null
                ? color.withOpacity(0.3)
                : Colors.grey.withOpacity(0.3),
          ),
        ),
        child: IconButton(
          icon: Icon(icon, size: isMobile ? 20 : 24),
          color: onPressed != null ? color : Colors.grey,
          onPressed: onPressed,
        ),
      ),
    );
  }

  void _handleBackspace() {
    if (widget.dialNumber.isNotEmpty) {
      final newNumber =
          widget.dialNumber.substring(0, widget.dialNumber.length - 1);
      widget.onNumberPressed('\b'); // Sinal especial para backspace
    }
  }
}
