import 'package:flutter/material.dart';
import 'dart:ui';

class NumericKeypad extends StatefulWidget {
  const NumericKeypad({
    super.key,
    required this.isOpen,
    required this.onClose,
    required this.onNumberSelected,
    required this.isMobile,
  });

  final bool isOpen;
  final VoidCallback onClose;
  final Function(String) onNumberSelected;
  final bool isMobile;

  @override
  State<NumericKeypad> createState() => _NumericKeypadState();
}

class _NumericKeypadState extends State<NumericKeypad>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

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
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
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
  void didUpdateWidget(NumericKeypad oldWidget) {
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
              alignment: Alignment.bottomCenter,
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  width: double.infinity,
                  height: widget.isMobile ? 350 : 400,
                  margin: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1e3a8a),
                        Color(0xFF3b82f6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF3b82f6).withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Column(
                      children: [
                        _buildHeader(),
                        Expanded(child: _buildKeypad()),
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
      padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
      child: Row(
        children: [
          const Icon(Icons.dialpad, color: Colors.white),
          const SizedBox(width: 8),
          const Text(
            'Clavier Numérique',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    return Padding(
      padding: EdgeInsets.all(widget.isMobile ? 16 : 20),
      child: Column(
        children: _keypadLayout.map((row) {
          return Expanded(
            child: Row(
              children: row.map((keyData) {
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    child: _buildKeypadButton(keyData),
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKeypadButton(Map<String, String> keyData) {
    final digit = keyData['digit']!;
    final letters = keyData['letters']!;

    return GestureDetector(
      onTap: () => widget.onNumberSelected(digit),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.2),
              Colors.white.withOpacity(0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              digit,
              style: TextStyle(
                fontSize: widget.isMobile ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (letters.isNotEmpty)
              Text(
                letters,
                style: TextStyle(
                  fontSize: widget.isMobile ? 10 : 12,
                  color: Colors.white70,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
