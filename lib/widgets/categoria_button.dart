import 'package:flutter/material.dart';

class CategoriaButton extends StatelessWidget {
  const CategoriaButton({
    super.key,
    required this.label,
    required this.selecionada,
    required this.onTap,
  });

  final String label;
  final bool selecionada;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const coffeeBrown = Color(0xFF5B3924);
    const softGreen = Color(0xFF6D8B74);

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(label),
        selected: selecionada,
        onSelected: (_) => onTap(),
        showCheckmark: false,
        labelStyle: TextStyle(
          color: selecionada ? Colors.white : coffeeBrown,
          fontWeight: FontWeight.w700,
        ),
        selectedColor: softGreen,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selecionada ? softGreen : const Color(0xFFE2D3C2),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
