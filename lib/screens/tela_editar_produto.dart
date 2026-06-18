import 'package:flutter/material.dart';

import '../models/produto.dart';
import '../services/produto_service.dart';
import '../widgets/produto_form.dart';

class TelaEditarProduto extends StatelessWidget {
  const TelaEditarProduto({super.key, required this.produto});

  final Produto produto;

  static const _coffeeBrown = Color(0xFF5B3924);
  static const _lightBeige = Color(0xFFF7EFE5);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: const Text('Editar produto'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: _coffeeBrown.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ProdutoForm(
                produto: produto,
                textoBotao: 'Salvar alterações',
                onSalvar:
                    ({
                      required nome,
                      required descricao,
                      required categoria,
                      required preco,
                      required disponivel,
                    }) {
                      ProdutoService.instance.atualizarProduto(
                        produto.copyWith(
                          nome: nome,
                          descricao: descricao,
                          categoria: categoria,
                          preco: preco,
                          disponivel: disponivel,
                        ),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Produto atualizado com sucesso'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      Navigator.pop(context);
                    },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
