import 'package:flutter/material.dart';

import '../models/item_pedido.dart';

class ItemPedidoCard extends StatelessWidget {
  const ItemPedidoCard({
    super.key,
    required this.item,
    required this.formatarPreco,
    required this.onAumentar,
    required this.onDiminuir,
    required this.onRemover,
  });

  final ItemPedido item;
  final String Function(double valor) formatarPreco;
  final VoidCallback onAumentar;
  final VoidCallback onDiminuir;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    const coffeeBrown = Color(0xFF5B3924);
    const softGreen = Color(0xFF6D8B74);
    const lightBeige = Color(0xFFF7EFE5);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: coffeeBrown.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: lightBeige,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.produto.icone, color: coffeeBrown),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.produto.nome,
                      style: const TextStyle(
                        color: coffeeBrown,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Preço: ${formatarPreco(item.produto.preco)}',
                      style: TextStyle(
                        color: coffeeBrown.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Subtotal: ${formatarPreco(item.subtotal)}',
                      style: const TextStyle(
                        color: softGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onRemover, child: const Text('Remover')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'Quantidade:',
                style: TextStyle(
                  color: coffeeBrown,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _BotaoQuantidade(icon: Icons.remove, onPressed: onDiminuir),
              SizedBox(
                width: 42,
                child: Text(
                  '${item.quantidade}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: coffeeBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _BotaoQuantidade(icon: Icons.add, onPressed: onAumentar),
            ],
          ),
        ],
      ),
    );
  }
}

class _BotaoQuantidade extends StatelessWidget {
  const _BotaoQuantidade({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const coffeeBrown = Color(0xFF5B3924);

    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton.outlined(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        color: coffeeBrown,
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
