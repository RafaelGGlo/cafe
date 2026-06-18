import 'package:flutter/material.dart';

import '../models/produto.dart';
import '../services/produto_service.dart';
import 'tela_cadastro_produto.dart';
import 'tela_editar_produto.dart';

class TelaGerenciarProdutos extends StatelessWidget {
  const TelaGerenciarProdutos({super.key});

  static const _coffeeBrown = Color(0xFF5B3924);
  static const _lightBeige = Color(0xFFF7EFE5);
  static const _softGreen = Color(0xFF6D8B74);

  String _formatarPreco(double valor) {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: const Text('Gerenciar produtos'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Voltar',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TelaCadastroProduto(),
            ),
          );
        },
        backgroundColor: _coffeeBrown,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo produto'),
      ),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: ProdutoService.instance,
          builder: (context, _) {
            final produtos = ProdutoService.instance.listarTodos();

            if (produtos.isEmpty) {
              return const Center(child: Text('Nenhum produto cadastrado.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 92),
              itemCount: produtos.length,
              itemBuilder: (context, index) {
                final produto = produtos[index];
                return _ProdutoGerenciamentoCard(
                  produto: produto,
                  formatarPreco: _formatarPreco,
                  onEditar: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TelaEditarProduto(produto: produto),
                      ),
                    );
                  },
                  onAlterarStatus: () {
                    ProdutoService.instance.alterarDisponibilidade(
                      produto.id,
                      !produto.disponivel,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProdutoGerenciamentoCard extends StatelessWidget {
  const _ProdutoGerenciamentoCard({
    required this.produto,
    required this.formatarPreco,
    required this.onEditar,
    required this.onAlterarStatus,
  });

  final Produto produto;
  final String Function(double valor) formatarPreco;
  final VoidCallback onEditar;
  final VoidCallback onAlterarStatus;

  @override
  Widget build(BuildContext context) {
    const coffeeBrown = TelaGerenciarProdutos._coffeeBrown;
    const lightBeige = TelaGerenciarProdutos._lightBeige;
    const softGreen = TelaGerenciarProdutos._softGreen;
    final statusColor = produto.disponivel
        ? softGreen
        : const Color(0xFFB94A48);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: lightBeige,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(produto.icone, color: coffeeBrown),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      produto.nome,
                      style: const TextStyle(
                        color: coffeeBrown,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${produto.categoria} • ${formatarPreco(produto.preco)}',
                      style: TextStyle(
                        color: coffeeBrown.withValues(alpha: 0.65),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            produto.descricao.isEmpty ? 'Sem descrição.' : produto.descricao,
            style: TextStyle(
              color: coffeeBrown.withValues(alpha: 0.65),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  produto.disponivel ? 'Disponível' : 'Indisponível',
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onAlterarStatus,
                child: Text(produto.disponivel ? 'Desativar' : 'Ativar'),
              ),
              const SizedBox(width: 8),
              FilledButton.tonalIcon(
                onPressed: onEditar,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
