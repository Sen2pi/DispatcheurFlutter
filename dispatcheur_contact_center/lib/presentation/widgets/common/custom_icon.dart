import 'package:flutter/material.dart';

class CustomIcon extends StatelessWidget {
  const CustomIcon({
    super.key,
    required this.src,
    required this.alt,
    this.size = 40,
    this.color,
    this.style,
    this.filter,
  });

  final String src;
  final String alt;
  final double size;
  final Color? color;
  final BoxFit? style;
  final String? filter;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      src,
      width: size,
      height: size,
      fit: style ?? BoxFit.contain,
      color: color,
      colorBlendMode: filter != null ? BlendMode.srcIn : null,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          _getIconFromAsset(src),
          size: size,
          color: color ?? Colors.grey,
        );
      },
    );
  }

  IconData _getIconFromAsset(String assetPath) {
    if (assetPath.contains('botao-play')) return Icons.play_arrow;
    if (assetPath.contains('botao-x')) return Icons.close;
    if (assetPath.contains('como')) return Icons.call;
    if (assetPath.contains('intercambio')) return Icons.swap_calls;
    if (assetPath.contains('livro-de-contatos')) return Icons.contacts;
    if (assetPath.contains('pausa')) return Icons.pause;
    if (assetPath.contains('notas')) return Icons.note;
    if (assetPath.contains('atendimento-ao-cliente')) return Icons.phone;
    return Icons.image;
  }
}
