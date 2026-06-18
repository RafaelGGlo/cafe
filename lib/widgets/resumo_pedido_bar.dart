import 'package:flutter/material.dart';

class ResumoPedidoBar extends StatelessWidget {
  const ResumoPedidoBar({
    super.key,
    required this.quantidadeItens,
    required this.total,
    required this.formatarPreco,
    required this.onVerPedido,
  });

  final int quantidadeItens;
  final double total;
  final String Function(double valor) formatarPreco;
  final VoidCallback onVerPedido;

  @override
  Widget build(BuildContext context) {
    const coffeeBrown = Color(0xFF5B3924);
    const softGreen = Color(0xFF6D8B74);

    if (quantidadeItens == 0) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 12),
      child: SizedBox(
        height: 58,
        width: double.infinity,
        child: FilledButton(
          onPressed: onVerPedido,
          style: FilledButton.styleFrom(
            backgroundColor: coffeeBrown,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: softGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$quantidadeItens',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Ver pedido',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              Text(
                formatarPreco(total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
