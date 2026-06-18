import 'package:flutter/material.dart';

class BotaoPrincipal extends StatelessWidget {
  const BotaoPrincipal({
    super.key,
    required this.texto,
    required this.onPressed,
  });

  final String texto;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const coffeeBrown = Color(0xFF5B3924);

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: coffeeBrown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          texto,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
