import 'package:flutter/material.dart';

import '../models/produto.dart';

class ProdutoCard extends StatelessWidget {
  const ProdutoCard({
    super.key,
    required this.produto,
    required this.onAdicionar,
    required this.formatarPreco,
  });

  final Produto produto;
  final VoidCallback onAdicionar;
  final String Function(double valor) formatarPreco;

  @override
  Widget build(BuildContext context) {
    const coffeeBrown = Color(0xFF5B3924);
    const softGreen = Color(0xFF6D8B74);
    const lightBeige = Color(0xFFF7EFE5);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: coffeeBrown.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: lightBeige,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(produto.icone, color: coffeeBrown, size: 30),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  produto.nome,
                  style: const TextStyle(
                    color: coffeeBrown,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  produto.descricao,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: coffeeBrown.withValues(alpha: 0.62),
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatarPreco(produto.preco),
                  style: const TextStyle(
                    color: softGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 42,
            height: 42,
            child: IconButton.filled(
              onPressed: onAdicionar,
              style: IconButton.styleFrom(
                backgroundColor: coffeeBrown,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add),
              tooltip: 'Adicionar produto',
            ),
          ),
        ],
      ),
    );
  }
}
