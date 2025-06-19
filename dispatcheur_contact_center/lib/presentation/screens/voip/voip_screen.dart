import 'package:flutter/material.dart';

class VoipScreen extends StatelessWidget {
  const VoipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        // TODO: Implementar interface VoIP
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interface VoIP em desenvolvimento'),
          ),
        );
      },
      backgroundColor: const Color(0xFF3B82F6),
      child: const Icon(Icons.phone, color: Colors.white),
    );
  }
}
