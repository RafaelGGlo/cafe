import 'package:flutter/material.dart';

import '../data/produtos_mock.dart';
import '../models/produto.dart';

class ProdutoService extends ChangeNotifier {
  ProdutoService._();

  static final ProdutoService instance = ProdutoService._();

  final List<Produto> _produtos = List<Produto>.from(produtosMock);

  List<Produto> listarTodos() {
    return List.unmodifiable(_produtos);
  }

  List<Produto> listarDisponiveis() {
    return _produtos.where((produto) => produto.disponivel).toList();
  }

  Produto? buscarPorId(String id) {
    for (final produto in _produtos) {
      if (produto.id == id) {
        return produto;
      }
    }
    return null;
  }

  Produto adicionarProduto({
    required String nome,
    required String descricao,
    required String categoria,
    required double preco,
    required bool disponivel,
  }) {
    final produto = Produto(
      id: 'produto-${DateTime.now().microsecondsSinceEpoch}',
      nome: nome,
      descricao: descricao,
      categoria: categoria,
      preco: preco,
      disponivel: disponivel,
      icone: _iconePorCategoria(categoria),
    );

    _produtos.add(produto);
    notifyListeners();
    return produto;
  }

  void atualizarProduto(Produto produtoAtualizado) {
    final index = _produtos.indexWhere(
      (produto) => produto.id == produtoAtualizado.id,
    );

    if (index == -1) {
      return;
    }

    _produtos[index] = produtoAtualizado.copyWith(
      icone: _iconePorCategoria(produtoAtualizado.categoria),
    );
    notifyListeners();
  }

  void alterarDisponibilidade(String id, bool disponivel) {
    final produto = buscarPorId(id);
    if (produto == null) {
      return;
    }

    atualizarProduto(produto.copyWith(disponivel: disponivel));
  }

  IconData _iconePorCategoria(String categoria) {
    final categoriaNormalizada = categoria.trim().toLowerCase();

    if (categoriaNormalizada.contains('café') ||
        categoriaNormalizada.contains('cafe')) {
      return Icons.local_cafe;
    }
    if (categoriaNormalizada.contains('salgado')) {
      return Icons.bakery_dining;
    }
    if (categoriaNormalizada.contains('doce')) {
      return Icons.cake;
    }
    if (categoriaNormalizada.contains('bebida') ||
        categoriaNormalizada.contains('suco')) {
      return Icons.local_drink;
    }

    return Icons.restaurant_menu;
  }
}
